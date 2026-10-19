import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../stock/data/stock_api_service.dart';
import '../../stock/domain/stock_models.dart';
import '../domain/hotspot_models.dart';

abstract interface class HotspotRemoteSource {
  Future<List<MarketSectorQuote>> fetchSectors({required bool concept});

  Future<List<SectorStockQuote>> fetchConstituents(String sectorCode);

  Future<List<DailyKline>> fetchKlines(String code, String market);
}

class StockApiHotspotRemoteSource implements HotspotRemoteSource {
  final StockApiService api;

  const StockApiHotspotRemoteSource(this.api);

  @override
  Future<List<MarketSectorQuote>> fetchSectors({required bool concept}) {
    return api.fetchMarketSectors(concept: concept);
  }

  @override
  Future<List<SectorStockQuote>> fetchConstituents(String sectorCode) {
    return api.fetchSectorConstituents(sectorCode);
  }

  @override
  Future<List<DailyKline>> fetchKlines(String code, String market) {
    return api.fetchStockKline(code, market: market, days: 6);
  }
}

/// Loads the weekly BaoStock industry relationship snapshot bundled with the
/// app. Runtime market data remains owned by [StockApiService]; this catalog
/// only answers which industry a stock belongs to.
class BaoStockIndustryCatalog {
  static const assetPath = 'assets/data/baostock_industries.json';

  final Future<String> Function() _loadSnapshot;
  Map<String, String>? _cached;

  BaoStockIndustryCatalog({Future<String> Function()? loadSnapshot})
    : _loadSnapshot = loadSnapshot ?? _loadBundledSnapshot;

  static Future<String> _loadBundledSnapshot() {
    return rootBundle.loadString(assetPath);
  }

  Future<Map<String, String>> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final payload = jsonDecode(await _loadSnapshot());
    if (payload is! Map<String, dynamic> || payload['stocks'] is! Map) {
      throw const FormatException('BaoStock 行业关系快照格式无效');
    }
    final stocks = <String, String>{};
    for (final entry in (payload['stocks'] as Map).entries) {
      final code = entry.key.toString();
      final industry = entry.value?.toString().trim() ?? '';
      if (code.length == 6 && industry.isNotEmpty) {
        stocks[code] = industry;
      }
    }
    if (stocks.isEmpty) {
      throw const FormatException('BaoStock 行业关系快照为空');
    }
    _cached = Map.unmodifiable(stocks);
    return _cached!;
  }
}

/// Hotspot-only data source that combines a bundled BaoStock industry map
/// with the app's existing whole-market quote and K-line APIs.
///
/// It deliberately does not replace any existing recommendation/detail data
/// path. Concept boards remain unsupported until a separately licensed source
/// is added.
class IndustryAggregatedHotspotRemoteSource implements HotspotRemoteSource {
  final Future<List<StockQuote>> Function() _fetchQuotes;
  final Future<List<DailyKline>> Function(String code, String market)
  _fetchKlines;
  final BaoStockIndustryCatalog catalog;
  final int minimumMappedQuotes;

  Map<String, List<StockQuote>> _quotesByBoardCode = const {};

  IndustryAggregatedHotspotRemoteSource({
    required Future<List<StockQuote>> Function() fetchQuotes,
    required Future<List<DailyKline>> Function(String code, String market)
    fetchKlines,
    required this.catalog,
    this.minimumMappedQuotes = 1000,
  }) : _fetchQuotes = fetchQuotes,
       _fetchKlines = fetchKlines;

  @override
  Future<List<MarketSectorQuote>> fetchSectors({required bool concept}) async {
    if (concept) {
      throw const HotspotSourceException('概念板块暂未接入稳定数据源，请先查看行业板块');
    }
    final groups = await _refreshGroups();
    return groups.entries
        .map((entry) {
          final quotes = entry.value;
          final amount = quotes.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );
          final volume = quotes.fold<double>(
            0,
            (sum, item) => sum + item.volume,
          );
          return MarketSectorQuote(
            code: entry.key,
            name: catalogIndustryName(entry.key),
            price: 0,
            changePct: _weightedAverage(
              quotes,
              (item) => item.changePct,
              (item) => item.amount,
            ),
            volume: volume,
            amount: amount,
            amplitude: _weightedAverage(
              quotes,
              _quoteAmplitude,
              (item) => item.amount,
            ),
            turnover: _weightedAverage(
              quotes,
              (item) => item.turnover,
              (item) => item.amount,
            ),
            volumeRatio: _weightedAverage(
              quotes.where((item) => item.volumeRatio > 0).toList(),
              (item) => item.volumeRatio,
              (item) => item.amount,
            ),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<SectorStockQuote>> fetchConstituents(String sectorCode) async {
    if (_quotesByBoardCode.isEmpty) await _refreshGroups();
    final quotes = _quotesByBoardCode[sectorCode] ?? const <StockQuote>[];
    return quotes
        .map(
          (item) => SectorStockQuote(
            code: item.code,
            name: item.name,
            market: item.market,
            price: item.price,
            changePct: item.changePct,
            volume: item.volume,
            amount: item.amount,
            amplitude: _quoteAmplitude(item),
            turnover: item.turnover,
            volumeRatio: item.volumeRatio,
            openPrice: item.openPrice,
            highPrice: item.highPrice,
            lowPrice: item.lowPrice,
            preClose: item.preClose,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<DailyKline>> fetchKlines(String code, String market) {
    return _fetchKlines(code, market);
  }

  Future<Map<String, List<StockQuote>>> _refreshGroups() async {
    final memberships = await catalog.load();
    final quotes = await _fetchQuotes();
    final groups = <String, List<StockQuote>>{};
    final industryByCode = <String, String>{};
    var mappedCount = 0;

    for (final quote in quotes) {
      if (!StockMarket.isAShare(quote.market)) continue;
      final industry = memberships[quote.code];
      if (industry == null || industry.isEmpty) continue;
      mappedCount++;
      final boardCode = _boardCode(industry);
      industryByCode[boardCode] = industry;
      groups.putIfAbsent(boardCode, () => <StockQuote>[]).add(quote);
    }
    if (mappedCount < minimumMappedQuotes) {
      throw HotspotSourceException(
        '全市场行情覆盖不足（仅匹配 $mappedCount 只），已停止生成可能失真的热点榜单',
      );
    }
    _industryByBoardCode = industryByCode;
    _quotesByBoardCode = groups;
    return groups;
  }

  Map<String, String> _industryByBoardCode = const {};

  String catalogIndustryName(String boardCode) {
    return _industryByBoardCode[boardCode] ?? boardCode;
  }

  static String _boardCode(String industry) {
    final encoded = base64Url.encode(utf8.encode(industry)).replaceAll('=', '');
    return 'BSI_$encoded';
  }

  static double _quoteAmplitude(StockQuote quote) {
    if (quote.amplitude > 0) return quote.amplitude;
    if (quote.preClose <= 0) return 0;
    return (quote.highPrice - quote.lowPrice) / quote.preClose * 100;
  }

  static double _weightedAverage(
    List<StockQuote> quotes,
    double Function(StockQuote item) value,
    double Function(StockQuote item) weight,
  ) {
    if (quotes.isEmpty) return 0;
    var weightedTotal = 0.0;
    var weightTotal = 0.0;
    var fallbackTotal = 0.0;
    var fallbackCount = 0;
    for (final quote in quotes) {
      final currentValue = value(quote);
      if (!currentValue.isFinite) continue;
      fallbackTotal += currentValue;
      fallbackCount++;
      final currentWeight = weight(quote);
      if (currentWeight > 0 && currentWeight.isFinite) {
        weightedTotal += currentValue * currentWeight;
        weightTotal += currentWeight;
      }
    }
    if (weightTotal > 0) return weightedTotal / weightTotal;
    return fallbackCount == 0 ? 0 : fallbackTotal / fallbackCount;
  }
}

/// Fetches and caches hotspot board/constituent snapshots.
///
/// The cache is deliberately a last-known-good snapshot: every user refresh
/// still attempts the network, but a temporary public-API outage leaves the
/// previous list visible with its original timestamp.
class HotspotService {
  static const _cacheVersion = 'v2';
  static const cacheMaxAge = Duration(days: 7);
  static const int historyCandidateLimit = 50;
  static const int historyConcurrency = 4;

  final HotspotRemoteSource source;
  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _now;

  const HotspotService({
    required this.source,
    Future<SharedPreferences> Function()? preferences,
    DateTime Function()? now,
  }) : _preferences = preferences ?? SharedPreferences.getInstance,
       _now = now ?? DateTime.now;

  Future<HotspotDataBatch<List<HotspotBoard>>> loadBoards(
    HotspotBoardType type,
  ) async {
    final key = 'hotspot_boards_${_cacheVersion}_${type.name}';
    try {
      final rows = await source.fetchSectors(
        concept: type == HotspotBoardType.concept,
      );
      if (rows.isEmpty) throw const HotspotSourceException('板块接口返回空数据');
      final data = rows
          .map(
            (row) => HotspotBoard(
              code: row.code,
              name: row.name,
              price: row.price,
              changePct: row.changePct,
              volume: row.volume,
              amount: row.amount,
              amplitude: row.amplitude,
              turnover: row.turnover,
              volumeRatio: row.volumeRatio,
            ),
          )
          .toList(growable: false);
      final updatedAt = _now();
      await _writeCache(key, updatedAt, data.map((e) => e.toJson()).toList());
      return HotspotDataBatch(data: data, updatedAt: updatedAt);
    } catch (error) {
      final cached = await _readCache(key, HotspotBoard.fromJson);
      if (cached != null) {
        return HotspotDataBatch(
          data: cached.data,
          updatedAt: cached.updatedAt,
          fromCache: true,
          warning: '板块数据刷新失败，当前显示本地缓存',
        );
      }
      if (error is HotspotSourceException) rethrow;
      throw const HotspotSourceException('板块数据暂时不可用，请稍后重试');
    }
  }

  Future<HotspotDataBatch<List<HotspotCandidate>>> loadCandidates(
    String sectorCode,
  ) async {
    final key = 'hotspot_candidates_${_cacheVersion}_$sectorCode';
    try {
      final rows = await source.fetchConstituents(sectorCode);
      if (rows.isEmpty) {
        return HotspotDataBatch(data: const [], updatedAt: _now());
      }
      final candidates = rows
          .map(
            (row) => HotspotCandidate(
              code: row.code,
              name: row.name,
              market: row.market,
              price: row.price,
              changePct: row.changePct,
              volume: row.volume,
              amount: row.amount,
              amplitude: row.amplitude,
              turnover: row.turnover,
              volumeRatio: row.volumeRatio,
              openPrice: row.openPrice,
              highPrice: row.highPrice,
              lowPrice: row.lowPrice,
              preClose: row.preClose,
            ),
          )
          .toList();
      final enriched = await _enrichHistory(candidates);
      final updatedAt = _now();
      await _writeCache(
        key,
        updatedAt,
        enriched.map((e) => e.toJson()).toList(),
      );
      return HotspotDataBatch(data: enriched, updatedAt: updatedAt);
    } catch (_) {
      final cached = await _readCache(key, HotspotCandidate.fromJson);
      if (cached != null) {
        return HotspotDataBatch(
          data: cached.data,
          updatedAt: cached.updatedAt,
          fromCache: true,
          warning: '成分股刷新失败，当前显示本地缓存',
        );
      }
      throw const HotspotSourceException('成分股数据暂时不可用，请稍后重试');
    }
  }

  Future<List<HotspotCandidate>> _enrichHistory(
    List<HotspotCandidate> candidates,
  ) async {
    final byAmount = [...candidates]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final targets = byAmount.take(historyCandidateLimit).toList();
    final returns =
        <String, ({double return5d, int activeDays, double volumeRatio})>{};

    for (var start = 0; start < targets.length; start += historyConcurrency) {
      final end = (start + historyConcurrency).clamp(0, targets.length);
      final chunk = targets.sublist(start, end);
      final results = await Future.wait(
        chunk.map((item) async {
          try {
            final klines = await source.fetchKlines(item.code, item.market);
            if (klines.length < 5) return null;
            final recent = klines.length > 6
                ? klines.sublist(klines.length - 6)
                : klines;
            final first = recent.first.close;
            final last = recent.last.close;
            if (first <= 0 || last <= 0) return null;
            final comparisonVolumes = recent.length > 1
                ? recent.take(recent.length - 1).where((day) => day.volume > 0)
                : const Iterable<DailyKline>.empty();
            final averageVolume = comparisonVolumes.isEmpty
                ? 0.0
                : comparisonVolumes.fold<double>(
                        0,
                        (sum, day) => sum + day.volume,
                      ) /
                      comparisonVolumes.length;
            final volumeRatio = item.volumeRatio > 0
                ? item.volumeRatio
                : averageVolume > 0
                ? item.volume / averageVolume
                : 0.0;
            return (
              code: item.code,
              return5d: (last / first - 1) * 100,
              activeDays: recent.reversed
                  .take(5)
                  .where((day) => day.volume > 0)
                  .length,
              volumeRatio: volumeRatio,
            );
          } catch (_) {
            return null;
          }
        }),
      );
      for (final result in results) {
        if (result != null) {
          returns[result.code] = (
            return5d: result.return5d,
            activeDays: result.activeDays,
            volumeRatio: result.volumeRatio,
          );
        }
      }
    }

    if (returns.isEmpty) return candidates;
    final boardReturn =
        returns.values.map((item) => item.return5d).reduce((a, b) => a + b) /
        returns.length;
    return candidates
        .map((item) {
          final history = returns[item.code];
          if (history == null) return item;
          return item.copyWith(
            volumeRatio: history.volumeRatio,
            return5d: history.return5d,
            relativeStrength5d: history.return5d - boardReturn,
            activeTradingDays5d: history.activeDays,
          );
        })
        .toList(growable: false);
  }

  Future<void> _writeCache(
    String key,
    DateTime updatedAt,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await _preferences();
    await prefs.setString(
      key,
      jsonEncode({'updatedAt': updatedAt.toIso8601String(), 'data': data}),
    );
  }

  Future<({List<T> data, DateTime updatedAt})?> _readCache<T>(
    String key,
    T Function(Map<String, dynamic>) decode,
  ) async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final updatedAt = DateTime.parse(json['updatedAt'] as String);
      if (_now().difference(updatedAt) > cacheMaxAge) return null;
      final data = (json['data'] as List<dynamic>)
          .map((item) => decode(item as Map<String, dynamic>))
          .toList();
      if (data.isEmpty) return null;
      return (data: data, updatedAt: updatedAt);
    } catch (_) {
      return null;
    }
  }
}

class HotspotSourceException implements Exception {
  final String message;

  const HotspotSourceException(this.message);

  @override
  String toString() => message;
}
