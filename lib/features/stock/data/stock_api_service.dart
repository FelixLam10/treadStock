import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../domain/stock_models.dart';
import '../../../core/constants/api_constants.dart';
import 'market_data_transport.dart';
import 'stock_search_transport.dart';

abstract interface class RecommendationCacheMetadata {
  bool get lastRecommendationCandidatesWereCached;
  DateTime? get lastRecommendationCandidatesUpdatedAt;
}

/// Strips HTML/XML tags (e.g. Eastmoney wraps matched keywords in `<em>`)
/// and decodes basic entities so titles display as plain text. Conservative:
/// it removes anything between < >, then unescapes &amp;/&lt;/&gt;/&quot;.
String _stripHtml(String input) {
  if (!input.contains('<')) return input;
  var out = input.replaceAll(RegExp(r'<[^>]*>'), '');
  out = out
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ');
  return out;
}

/// HTTP client service for fetching stock data from East Money and Sina Finance APIs.
class StockApiService {
  static const int _marketQuotePageSize = 500;
  static const int _recommendationQuoteLimit = 50;

  late final Dio _dio;

  StockApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: kIsWeb
            ? null
            : {
                'User-Agent':
                    'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
                'Referer': 'https://www.eastmoney.com/',
              },
      ),
    );

    // Only enable request/response logging in debug builds to avoid leaking
    // sensitive data (URLs, tokens) in production logs.
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false),
      );
    }

    // Automatic retry for network errors and server-side failures.
    _dio.interceptors.add(
      _RetryInterceptor(
        maxRetries: ApiConstants.maxRetries,
        retryDelay: ApiConstants.retryDelay,
      ),
    );
  }

  /// Fetch all A-stock market quotes (price, change%, volume).
  Future<List<StockQuote>> fetchAllMarketQuotes() async {
    try {
      return await _fetchMarketQuotes(pageSize: _marketQuotePageSize);
    } catch (_) {
      return _fetchSinaMarketQuotes(limit: _marketQuotePageSize);
    }
  }

  /// Fetches the complete A-share quote universe used only by the hotspot
  /// aggregation pipeline.
  ///
  /// Existing recommendation/detail data paths intentionally keep their
  /// current sources and limits. Sina is paged here because a partial top-500
  /// snapshot would bias industry totals and leader rankings.
  Future<List<StockQuote>> fetchHotspotMarketQuotes() async {
    final markets = await Future.wait([
      _fetchAllSinaMarketQuotes('sh_a'),
      _fetchAllSinaMarketQuotes('sz_a'),
    ]);
    return [...markets[0], ...markets[1]];
  }

  /// Fetches the short K-line window used only by hotspot ranking.
  ///
  /// The hotspot pipeline already uses Sina's complete A-share snapshot, so
  /// going directly to the matching Sina K-line endpoint avoids an unnecessary
  /// failed East Money attempt for every candidate. Existing callers continue
  /// to use [fetchStockKline] and keep their current fallback order.
  Future<List<DailyKline>> fetchHotspotKlines(
    String stockCode, {
    required String market,
    int days = 6,
  }) {
    return _fetchSinaKline(stockCode, market: market, days: days);
  }

  /// Fetch only the highest-ranked market quotes needed by recommendation pages.
  ///
  /// East Money can be slow when requesting thousands of rows in one response.
  /// Recommendation only scores a small candidate pool, so this keeps the
  /// first-screen path fast and avoids whole-market receive timeouts.
  Future<List<StockQuote>> fetchRecommendationCandidates({
    int limit = _recommendationQuoteLimit,
    String market = StockMarket.aShare,
  }) async {
    if (market == StockMarket.hk) {
      try {
        final quotes = await _fetchMarketQuotesByFs(
          fs: 'm:116+t:3',
          pageSize: limit,
          maxItems: limit,
          fallbackMarket: StockMarket.hk,
        ).timeout(const Duration(seconds: 3));
        if (quotes.isNotEmpty) return quotes;
      } catch (_) {
        // Fall through to the Tencent liquid-stock universe.
      }
      return _fetchTencentMarketQuotes(StockMarket.hk, limit);
    }
    if (StockMarket.isUS(market)) {
      try {
        final quotes = await _fetchMarketQuotesByFs(
          fs: 'm:105,m:106,m:107',
          pageSize: limit,
          maxItems: limit,
          fallbackMarket: StockMarket.us,
        ).timeout(const Duration(seconds: 3));
        if (quotes.isNotEmpty) return quotes;
      } catch (_) {
        // Fall through to the Tencent liquid-stock universe.
      }
      return _fetchTencentMarketQuotes(StockMarket.us, limit);
    }

    try {
      return await _fetchMarketQuotes(pageSize: limit, maxItems: limit);
    } catch (_) {
      return _fetchSinaMarketQuotes(limit: limit);
    }
  }

  /// Fetch industry or concept sector snapshots for the hotspot page.
  ///
  /// East Money uses `m:90+t:2` for industry boards and `m:90+t:3` for
  /// concept boards. Only one page is loaded: the page ranks locally and
  /// never fans out to all constituents on first render.
  Future<List<MarketSectorQuote>> fetchMarketSectors({
    required bool concept,
    int limit = 100,
  }) async {
    final response = await _dio.get(
      marketDataUrl('${ApiConstants.eastmoneyPush}/clist/get'),
      queryParameters: {
        'pn': 1,
        'pz': limit,
        'po': 1,
        'np': 1,
        'fltt': 2,
        'invt': 2,
        'fid': 'f6',
        'fs': concept ? 'm:90+t:3' : 'm:90+t:2',
        'fields': 'f2,f3,f5,f6,f7,f8,f10,f12,f14',
      },
    );
    final payload = response.data?['data'];
    if (payload is! Map) {
      throw const FormatException('板块行情响应缺少 data');
    }
    final diff = payload['diff'];
    if (diff is! List) {
      if ((payload['total'] as num?)?.toInt() == 0) return const [];
      throw const FormatException('板块行情响应缺少 diff');
    }
    return diff
        .whereType<Map<String, dynamic>>()
        .map(MarketSectorQuote.fromJson)
        .where((item) => item.code.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  /// Fetch constituents for one East Money sector code (for example BK0475).
  Future<List<SectorStockQuote>> fetchSectorConstituents(
    String sectorCode, {
    int limit = 200,
  }) async {
    final response = await _dio.get(
      marketDataUrl('${ApiConstants.eastmoneyPush}/clist/get'),
      queryParameters: {
        'pn': 1,
        'pz': limit,
        'po': 1,
        'np': 1,
        'fltt': 2,
        'invt': 2,
        'fid': 'f6',
        'fs': 'b:$sectorCode+f:!50',
        'fields': 'f2,f3,f5,f6,f7,f8,f10,f12,f13,f14,f15,f16,f17,f18',
      },
    );
    final payload = response.data?['data'];
    if (payload is! Map) {
      throw const FormatException('板块成分股响应缺少 data');
    }
    final diff = payload['diff'];
    if (diff is! List) {
      if ((payload['total'] as num?)?.toInt() == 0) return const [];
      throw const FormatException('板块成分股响应缺少 diff');
    }
    return diff
        .whereType<Map<String, dynamic>>()
        .map(SectorStockQuote.fromJson)
        .where((item) => item.code.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  Future<List<StockQuote>> _fetchMarketQuotes({
    required int pageSize,
    int? maxItems,
  }) async {
    final quotes = <StockQuote>[];
    var page = 1;
    int? total;

    while (true) {
      final pageQuotes = await _fetchMarketQuotePage(page, pageSize);
      quotes.addAll(pageQuotes.quotes);

      total ??= pageQuotes.total;
      if (maxItems != null && quotes.length >= maxItems) {
        return quotes.take(maxItems).toList();
      }
      if (pageQuotes.quotes.isEmpty) return quotes;
      if (total != null && quotes.length >= total) return quotes;

      page++;
    }
  }

  Future<({List<StockQuote> quotes, int? total})> _fetchMarketQuotePage(
    int page,
    int pageSize,
  ) async {
    return _fetchMarketQuotePageByFs(
      page,
      pageSize,
      fs: 'm:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23,m:1+t:23,b:MK0021,m:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23',
    );
  }

  Future<List<StockQuote>> _fetchMarketQuotesByFs({
    required String fs,
    required int pageSize,
    required int maxItems,
    required String fallbackMarket,
  }) async {
    final pageQuotes = await _fetchMarketQuotePageByFs(
      1,
      pageSize,
      fs: fs,
      fallbackMarket: fallbackMarket,
    );
    return pageQuotes.quotes.take(maxItems).toList();
  }

  Future<({List<StockQuote> quotes, int? total})> _fetchMarketQuotePageByFs(
    int page,
    int pageSize, {
    required String fs,
    String? fallbackMarket,
  }) async {
    final quotes = <StockQuote>[];

    final response = await _dio.get(
      marketDataUrl('${ApiConstants.eastmoneyPush}/clist/get'),
      queryParameters: {
        'pn': page,
        'pz': pageSize,
        'po': 1,
        'np': 1,
        'fltt': 2,
        'invt': 2,
        'fid': 'f3',
        'fs': fs,
        'fields': 'f2,f3,f4,f5,f6,f7,f8,f12,f13,f14,f15,f16,f17,f18,f20,f100',
      },
    );

    final data = response.data;
    if (data == null) return (quotes: quotes, total: null);

    final quoteData = data['data'];
    final total = quoteData?['total'] is int ? quoteData['total'] as int : null;
    final diff = quoteData?['diff'];
    if (diff is! List) return (quotes: quotes, total: total);

    for (final item in diff) {
      try {
        quotes.add(
          StockQuote.fromJson(
            item as Map<String, dynamic>,
            fallbackMarket: fallbackMarket,
          ),
        );
      } catch (_) {
        // Skip malformed entries
      }
    }

    return (quotes: quotes, total: total);
  }

  Future<List<StockQuote>> _fetchSinaMarketQuotes({required int limit}) async {
    final perMarketLimit = (limit / 2).ceil();
    final results = <StockQuote>[
      ...await _fetchSinaMarketQuotePage('sz_a', perMarketLimit),
      ...await _fetchSinaMarketQuotePage('sh_a', perMarketLimit),
    ]..sort((a, b) => b.changePct.compareTo(a.changePct));

    return results.take(limit).toList();
  }

  Future<List<StockQuote>> _fetchSinaMarketQuotePage(
    String node,
    int limit, {
    int page = 1,
  }) async {
    final response = await _dio.get(
      marketDataUrl(
        'https://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/'
        'Market_Center.getHQNodeData',
      ),
      queryParameters: {
        'page': page,
        'num': limit,
        'sort': 'changepercent',
        'asc': 0,
        'node': node,
        'symbol': '',
        '_s_r_a': 'page',
      },
      options: Options(responseType: ResponseType.plain),
    );

    final rows = json.decode(response.data?.toString() ?? '[]');
    if (rows is! List) return [];

    final quotes = <StockQuote>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final symbol = row['symbol']?.toString() ?? '';
      final market = symbol.startsWith('sh')
          ? 'SH'
          : symbol.startsWith('sz')
          ? 'SZ'
          : null;
      if (market == null) continue;

      final code = row['code']?.toString() ?? '';
      final price = _parseDouble(row['trade']?.toString());
      final preClose = _parseDouble(row['settlement']?.toString());
      final highPrice = _parseDouble(row['high']?.toString()) ?? price ?? 0;
      final lowPrice = _parseDouble(row['low']?.toString()) ?? price ?? 0;
      final changeAmt = _parseDouble(row['pricechange']?.toString()) ?? 0;
      final changePct = _parseDouble(row['changepercent']?.toString()) ?? 0;
      if (code.isEmpty || price == null) continue;

      quotes.add(
        StockQuote(
          code: code,
          name: row['name']?.toString() ?? code,
          market: market,
          price: price,
          changePct: changePct,
          changeAmt: changeAmt,
          openPrice: _parseDouble(row['open']?.toString()) ?? price,
          highPrice: highPrice,
          lowPrice: lowPrice,
          preClose: preClose ?? price - changeAmt,
          volume: _parseDouble(row['volume']?.toString()) ?? 0,
          turnover: _parseDouble(row['turnoverratio']?.toString()) ?? 0,
          amount: _parseDouble(row['amount']?.toString()) ?? 0,
          amplitude: preClose == null || preClose == 0
              ? 0
              : (highPrice - lowPrice) / preClose * 100,
        ),
      );
    }

    return quotes;
  }

  Future<List<StockQuote>> _fetchAllSinaMarketQuotes(String node) async {
    const pageSize = 100;
    const concurrency = 6;
    final response = await _dio.get(
      marketDataUrl(
        'https://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/'
        'Market_Center.getHQNodeStockCount',
      ),
      queryParameters: {'node': node},
      options: Options(responseType: ResponseType.plain),
    );
    final totalText = response.data?.toString().replaceAll('"', '').trim();
    final total = int.tryParse(totalText ?? '');
    if (total == null || total <= 0) return const [];

    final pageCount = (total / pageSize).ceil();
    final quotes = <StockQuote>[];
    for (var start = 1; start <= pageCount; start += concurrency) {
      final end = (start + concurrency - 1).clamp(1, pageCount);
      final pages = await Future.wait([
        for (var page = start; page <= end; page++)
          _fetchSinaMarketQuotePage(node, pageSize, page: page),
      ]);
      for (final rows in pages) {
        quotes.addAll(rows);
      }
    }
    return quotes;
  }

  /// Fetch stock K-line data (daily).
  Future<List<DailyKline>> fetchStockKline(
    String stockCode, {
    String market = 'SH',
    int days = ApiConstants.defaultKlineDays,
  }) async {
    try {
      final klines =
          await _fetchEastMoneyKline(
            stockCode,
            market: market,
            days: days,
          ).timeout(
            StockMarket.isAShare(market)
                ? ApiConstants.receiveTimeout
                : const Duration(seconds: 3),
          );
      if (klines.isNotEmpty) return klines;
    } catch (_) {
      // Fall back below. East Money occasionally closes Dart HTTP connections
      // before sending headers on macOS.
    }

    if (StockMarket.isAShare(market)) {
      return _fetchSinaKline(stockCode, market: market, days: days);
    }
    final tencentKlines = await _fetchTencentKline(
      stockCode,
      market: market,
      days: days,
    );
    if (tencentKlines.isNotEmpty) return tencentKlines;
    return [];
  }

  Future<List<DailyKline>> _fetchEastMoneyKline(
    String stockCode, {
    required String market,
    required int days,
  }) async {
    final secid = getSecid(stockCode, market);
    final now = DateTime.now();
    final beg = DateTime(now.year - 1, now.month, now.day);
    final end = now;

    final response = await _dio.get(
      marketDataUrl('${ApiConstants.eastmoneyPushHis}/stock/kline/get'),
      queryParameters: {
        'secid': secid,
        'fields1': 'f1,f2,f3,f4,f5,f6',
        'fields2': 'f51,f52,f53,f54,f55,f56,f57',
        'klt': ApiConstants.klineTypeDaily,
        'fqt': ApiConstants.fqTypeForward,
        'beg':
            '${beg.year}${beg.month.toString().padLeft(2, '0')}${beg.day.toString().padLeft(2, '0')}',
        'end':
            '${end.year}${end.month.toString().padLeft(2, '0')}${end.day.toString().padLeft(2, '0')}',
        'lmt': days,
      },
    );

    final data = response.data;
    final klinesStr = data?['data']?['klines'] as List<dynamic>?;
    if (klinesStr == null) return [];

    return DailyKline.parseKlines(klinesStr.cast<String>());
  }

  /// Fetch latest quote for one stock.
  ///
  /// This endpoint is more stable than the historical K-line endpoint and is
  /// used by watchlist surfaces so price data can still render when K-lines
  /// are temporarily unavailable.
  Future<StockQuote?> fetchStockQuote(
    String stockCode, {
    String market = 'SH',
  }) async {
    try {
      final response = await _dio
          .get(
            marketDataUrl('${ApiConstants.eastmoneyPush}/stock/get'),
            queryParameters: {
              'secid': getSecid(stockCode, market),
              'fields':
                  'f43,f44,f45,f46,f47,f48,f57,f58,f59,f60,f168,f169,f170',
            },
          )
          .timeout(
            StockMarket.isAShare(market)
                ? ApiConstants.receiveTimeout
                : const Duration(seconds: 3),
          );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return StockQuote.fromRealtimeJson(
          data,
          fallbackCode: stockCode,
          fallbackMarket: market,
        );
      }
    } catch (_) {
      // Fall back below.
    }

    if (StockMarket.isAShare(market)) {
      return _fetchSinaStockQuote(stockCode, market: market);
    }
    return _fetchTencentStockQuote(stockCode, market: market);
  }

  /// Fetch company profile, valuation and the latest reported performance.
  ///
  /// The public sources are requested independently so a temporary failure in
  /// one source does not hide the other sections. F10 data is currently only
  /// available for A-shares; other markets return null gracefully.
  Future<StockFundamentals?> fetchStockFundamentals(
    String stockCode, {
    required String stockName,
    String market = StockMarket.sh,
  }) async {
    if (!StockMarket.isAShare(market)) return null;

    Map<String, dynamic>? survey;
    Map<String, dynamic>? finance;
    Map<String, dynamic>? valuation;
    final marketCode = '${market.toUpperCase()}$stockCode';

    await Future.wait<void>([
      (() async {
        try {
          final response = await _dio.get(
            marketDataUrl(
              '${ApiConstants.eastmoneyF10}/CompanySurvey/PageAjax',
            ),
            queryParameters: {'code': marketCode},
            options: kIsWeb
                ? null
                : Options(
                    headers: {
                      'Referer': 'https://emweb.securities.eastmoney.com/',
                    },
                  ),
          );
          if (response.data is Map) {
            survey = Map<String, dynamic>.from(response.data as Map);
          }
        } catch (error, stackTrace) {
          debugPrint(
            '[StockApiService] company survey failed: $error\n$stackTrace',
          );
        }
      })(),
      (() async {
        try {
          final response = await _dio.get(
            marketDataUrl(
              '${ApiConstants.eastmoneyF10}/NewFinanceAnalysis/ZYZBAjaxNew',
            ),
            queryParameters: {'type': 0, 'code': marketCode},
            options: kIsWeb
                ? null
                : Options(
                    headers: {
                      'Referer': 'https://emweb.securities.eastmoney.com/',
                    },
                  ),
          );
          if (response.data is Map) {
            finance = Map<String, dynamic>.from(response.data as Map);
          }
        } catch (error, stackTrace) {
          debugPrint(
            '[StockApiService] finance summary failed: $error\n$stackTrace',
          );
        }
      })(),
      (() async {
        try {
          final response = await _dio.get(
            marketDataUrl('${ApiConstants.eastmoneyPush}/stock/get'),
            queryParameters: {
              'secid': getSecid(stockCode, market),
              'fltt': 2,
              'invt': 2,
              'fields': 'f9,f20,f23,f127',
            },
          );
          if (response.data is Map) {
            valuation = Map<String, dynamic>.from(response.data as Map);
          }
        } catch (error, stackTrace) {
          debugPrint(
            '[StockApiService] valuation snapshot failed: $error\n$stackTrace',
          );
        }
      })(),
    ]);

    final result = StockFundamentals.fromEastMoney(
      fallbackCode: stockCode,
      fallbackName: stockName,
      survey: survey,
      finance: finance,
      valuation: valuation,
    );
    return result.hasAnyData ? result : null;
  }

  Future<StockQuote?> _fetchTencentStockQuote(
    String stockCode, {
    required String market,
  }) async {
    final symbol = _tencentSymbol(stockCode, market);
    if (symbol == null) return null;

    final response = await _dio.get(
      marketDataUrl('https://qt.gtimg.cn/q=$symbol'),
      options: Options(responseType: ResponseType.plain),
    );
    final body = response.data?.toString() ?? '';
    final start = body.indexOf('"');
    final end = body.lastIndexOf('"');
    if (start < 0 || end <= start) return null;

    final fields = body.substring(start + 1, end).split('~');
    if (fields.length < 35) return null;

    final price = _parseDouble(fields[3]);
    final preClose = _parseDouble(fields[4]);
    final open = _parseDouble(fields[5]);
    final volume = _parseDouble(fields[6]);
    final changeAmt = _parseDouble(fields[31]) ?? 0;
    final changePct = _parseDouble(fields[32]) ?? 0;
    final high = _parseDouble(fields[33]);
    final low = _parseDouble(fields[34]);
    if (price == null) return null;

    return StockQuote(
      code: stockCode,
      name: stockCode,
      market: market,
      price: price,
      changePct: changePct,
      changeAmt: changeAmt,
      openPrice: open ?? price,
      highPrice: high ?? price,
      lowPrice: low ?? price,
      preClose: preClose ?? price - changeAmt,
      volume: volume ?? 0,
      turnover: 0,
    );
  }

  Future<List<StockQuote>> _fetchTencentMarketQuotes(
    String market,
    int limit,
  ) async {
    final universe = market == StockMarket.hk
        ? _tencentHkUniverse
        : _tencentUsUniverse;
    final selected = universe.take(limit).toList();
    final symbols = selected.map((item) => item.symbol).join(',');
    final response = await _dio.get(
      marketDataUrl('https://qt.gtimg.cn/q=$symbols'),
      options: Options(responseType: ResponseType.plain),
    );
    return parseTencentMarketQuotes(
      response.data?.toString() ?? '',
      market: market,
      universe: {for (final item in selected) item.code: item.name},
    );
  }

  Future<List<DailyKline>> _fetchTencentKline(
    String stockCode, {
    required String market,
    required int days,
  }) async {
    final symbol = _tencentSymbol(stockCode, market);
    if (symbol == null) return [];

    final endpoint = StockMarket.isUS(market)
        ? 'https://web.ifzq.gtimg.cn/appstock/app/usfqkline/get'
        : 'https://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get';
    final response = await _dio.get(
      marketDataUrl(endpoint),
      queryParameters: {'param': '$symbol,day,,,$days,qfq'},
    );

    final dynamic payload = response.data is String
        ? json.decode(response.data as String)
        : response.data;
    final data = payload?['data']?[symbol];
    final rows = data?['qfqday'] ?? data?['day'];
    if (rows is! List) return [];

    final klines = <DailyKline>[];
    for (final row in rows) {
      if (row is! List || row.length < 6) continue;
      final date = DateTime.tryParse(row[0].toString());
      final open = _parseDouble(row[1].toString());
      final close = _parseDouble(row[2].toString());
      final high = _parseDouble(row[3].toString());
      final low = _parseDouble(row[4].toString());
      final volume = _parseDouble(row[5].toString());
      if (date == null ||
          open == null ||
          close == null ||
          high == null ||
          low == null) {
        continue;
      }
      klines.add(
        DailyKline(
          date: date,
          open: open,
          close: close,
          high: high,
          low: low,
          volume: volume ?? 0,
          amount: 0,
          preClose: klines.isEmpty ? 0 : klines.last.close,
        ),
      );
    }
    return klines;
  }

  String? _tencentSymbol(String stockCode, String market) {
    if (market == StockMarket.hk) return 'hk$stockCode';
    if (StockMarket.isUS(market)) return 'us$stockCode';
    return null;
  }

  Future<StockQuote?> _fetchSinaStockQuote(
    String stockCode, {
    required String market,
  }) async {
    final symbol = '${market.toLowerCase()}$stockCode';
    final response = await _dio.get(
      marketDataUrl('https://hq.sinajs.cn/list=$symbol'),
      options: Options(
        responseType: ResponseType.plain,
        headers: kIsWeb ? null : {'Referer': 'https://finance.sina.com.cn/'},
      ),
    );
    final body = response.data?.toString() ?? '';
    final start = body.indexOf('"');
    final end = body.lastIndexOf('"');
    if (start < 0 || end <= start) return null;

    final fields = body.substring(start + 1, end).split(',');
    if (fields.length < 10) return null;

    final open = _parseDouble(fields[1]);
    final preClose = _parseDouble(fields[2]);
    final price = _parseDouble(fields[3]);
    final high = _parseDouble(fields[4]);
    final low = _parseDouble(fields[5]);
    final volume = _parseDouble(fields[8]);
    final amount = _parseDouble(fields[9]);
    if (price == null || preClose == null) return null;

    final changeAmt = price - preClose;
    final changePct = preClose == 0 ? 0.0 : changeAmt / preClose * 100;
    return StockQuote(
      code: stockCode,
      name: stockCode,
      market: market,
      price: price,
      changePct: changePct,
      changeAmt: changeAmt,
      openPrice: open ?? price,
      highPrice: high ?? price,
      lowPrice: low ?? price,
      preClose: preClose,
      volume: volume ?? 0,
      turnover: amount ?? 0,
    );
  }

  Future<List<DailyKline>> _fetchSinaKline(
    String stockCode, {
    required String market,
    required int days,
  }) async {
    final symbol = '${market.toLowerCase()}$stockCode';
    final now = DateTime.now();
    final callback = 'var _${symbol}_${now.year}_${now.month}_${now.day}=';
    final response = await _dio.get(
      marketDataUrl(
        'https://quotes.sina.cn/cn/api/jsonp_v2.php/$callback/'
        'CN_MarketDataService.getKLineData',
      ),
      queryParameters: {
        'symbol': symbol,
        'scale': 240,
        'ma': 'no',
        'datalen': days,
      },
      options: Options(responseType: ResponseType.plain),
    );

    final body = response.data?.toString() ?? '';
    final start = body.indexOf('[');
    final end = body.lastIndexOf(']');
    if (start < 0 || end <= start) return [];

    final rows = json.decode(body.substring(start, end + 1));
    if (rows is! List) return [];

    final klines = <DailyKline>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final date = DateTime.tryParse(row['day']?.toString() ?? '');
      final open = _parseDouble(row['open']?.toString());
      final high = _parseDouble(row['high']?.toString());
      final low = _parseDouble(row['low']?.toString());
      final close = _parseDouble(row['close']?.toString());
      final volume = _parseDouble(row['volume']?.toString());
      if (date == null ||
          open == null ||
          high == null ||
          low == null ||
          close == null) {
        continue;
      }
      klines.add(
        DailyKline(
          date: date,
          open: open,
          close: close,
          high: high,
          low: low,
          volume: volume ?? 0,
          amount: 0,
          preClose: klines.isEmpty ? open : klines.last.close,
        ),
      );
    }

    return klines;
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  /// Search stocks by code or name.
  Future<List<StockSearchResult>> searchStock(String keyword) async {
    if (keyword.trim().isEmpty) return [];

    try {
      final data = await fetchStockSearchData(
        _dio,
        endpoint: marketDataUrl(ApiConstants.eastmoneySearch),
        keyword: keyword.trim(),
        token: ApiConstants.searchToken,
        count: 20,
      );
      if (data == null) return [];

      final quoter = data['QuotationCodeTable']?['Data'] as List<dynamic>?;
      if (quoter == null) return [];

      return quoter
          .where(
            (item) =>
                item is Map<String, dynamic> &&
                StockMarket.isSupportedEastMoneySearch(item),
          )
          .take(AppConstants.maxSearchResults)
          .map(
            (item) => StockSearchResult.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch stock news from East Money.
  Future<List<StockNews>> fetchStockNews(
    String stockCode, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        marketDataUrl(ApiConstants.eastmoneySearchApi),
        queryParameters: {
          'cb': 'jQuery',
          'param':
              '{"uid":"","keyword":"$stockCode","type":["cmsArticleWebOld"],"pi":$page,"ps":$pageSize,"np":1}',
        },
        options: Options(responseType: ResponseType.plain),
      );

      // Parse JSONP response: extract JSON from callback wrapper.
      final body = response.data as String;
      final Map<String, dynamic> data;
      try {
        final startIndex = body.indexOf('(');
        if (startIndex >= 0) {
          final jsonPart = body.substring(
            startIndex + 1,
            body.lastIndexOf(')'),
          );
          data = json.decode(jsonPart) as Map<String, dynamic>;
        } else {
          data = json.decode(body) as Map<String, dynamic>;
        }
      } catch (e, st) {
        // JSONP/JSON decode failure — log so a future API change is visible
        // in debug instead of silently returning an empty news list.
        debugPrint('[StockApiService] news JSONP decode failed: $e\n$st');
        return [];
      }

      // The Eastmoney search-api wraps results under a top-level "result" key
      // (NOT "Data" — that was a stale assumption that always returned null).
      final result = data['result'] as Map<String, dynamic>?;
      final articles = result?['cmsArticleWebOld'] as List<dynamic>?;
      if (articles == null) return [];

      return articles.map((item) {
        final map = item as Map<String, dynamic>;
        // "date" is a string like "2026-06-21 18:05:00", not a millis int.
        // Parse defensively: fall back to now on unexpected formats.
        DateTime parseDate() {
          final raw = map['date'];
          if (raw is String) {
            return DateTime.tryParse(raw) ?? DateTime.now();
          }
          if (raw is int) {
            return DateTime.fromMillisecondsSinceEpoch(raw);
          }
          return DateTime.now();
        }

        return StockNews(
          id: (map['id'] ?? map['url'] ?? '').toString(),
          stockCode: stockCode,
          // Eastmoney wraps the matched keyword in <em>...</em>; strip so the
          // title shows as clean plain text instead of literal "<em>" tags.
          title: _stripHtml(map['title'] as String? ?? ''),
          source: map['mediaName'] as String? ?? '',
          sourceUrl: map['url'] as String? ?? '',
          publishedAt: parseDate(),
          fetchedAt: DateTime.now(),
        );
      }).toList();
    } catch (e, st) {
      // Network/parse errors: log instead of silently swallowing so a future
      // API change shows up in debug rather than an inexplicable empty list.
      debugPrint('[StockApiService] fetchStockNews failed: $e\n$st');
      return [];
    }
  }

  /// Get secid for a stock code.
  String getSecid(String code, String market) {
    return '${StockMarket.eastMoneySecidPrefix(market)}.$code';
  }
}

typedef _TencentUniverseItem = ({String symbol, String code, String name});

const List<_TencentUniverseItem> _tencentHkUniverse = [
  (symbol: 'hk00700', code: '00700', name: '腾讯控股'),
  (symbol: 'hk09988', code: '09988', name: '阿里巴巴-W'),
  (symbol: 'hk03690', code: '03690', name: '美团-W'),
  (symbol: 'hk01810', code: '01810', name: '小米集团-W'),
  (symbol: 'hk00941', code: '00941', name: '中国移动'),
  (symbol: 'hk01299', code: '01299', name: '友邦保险'),
  (symbol: 'hk02318', code: '02318', name: '中国平安'),
  (symbol: 'hk00939', code: '00939', name: '建设银行'),
  (symbol: 'hk01398', code: '01398', name: '工商银行'),
  (symbol: 'hk03988', code: '03988', name: '中国银行'),
  (symbol: 'hk00883', code: '00883', name: '中国海洋石油'),
  (symbol: 'hk00005', code: '00005', name: '汇丰控股'),
  (symbol: 'hk09618', code: '09618', name: '京东集团-SW'),
  (symbol: 'hk09888', code: '09888', name: '百度集团-SW'),
  (symbol: 'hk02020', code: '02020', name: '安踏体育'),
  (symbol: 'hk06809', code: '06809', name: '澜起科技'),
];

const List<_TencentUniverseItem> _tencentUsUniverse = [
  (symbol: 'usAAPL', code: 'AAPL', name: 'Apple'),
  (symbol: 'usMSFT', code: 'MSFT', name: 'Microsoft'),
  (symbol: 'usNVDA', code: 'NVDA', name: 'NVIDIA'),
  (symbol: 'usGOOGL', code: 'GOOGL', name: 'Alphabet'),
  (symbol: 'usAMZN', code: 'AMZN', name: 'Amazon'),
  (symbol: 'usMETA', code: 'META', name: 'Meta Platforms'),
  (symbol: 'usTSLA', code: 'TSLA', name: 'Tesla'),
  (symbol: 'usAVGO', code: 'AVGO', name: 'Broadcom'),
  (symbol: 'usAMD', code: 'AMD', name: 'AMD'),
  (symbol: 'usNFLX', code: 'NFLX', name: 'Netflix'),
  (symbol: 'usTSM', code: 'TSM', name: '台积电'),
  (symbol: 'usBABA', code: 'BABA', name: '阿里巴巴'),
  (symbol: 'usPDD', code: 'PDD', name: '拼多多'),
  (symbol: 'usJD', code: 'JD', name: '京东'),
  (symbol: 'usDRAM', code: 'DRAM', name: 'Roundhill Memory ETF'),
  (symbol: 'usSPY', code: 'SPY', name: 'SPDR S&P 500 ETF'),
];

@visibleForTesting
List<StockQuote> parseTencentMarketQuotes(
  String body, {
  required String market,
  required Map<String, String> universe,
}) {
  final quotes = <StockQuote>[];
  for (final line in body.split(';')) {
    final start = line.indexOf('"');
    final end = line.lastIndexOf('"');
    if (start < 0 || end <= start) continue;
    final fields = line.substring(start + 1, end).split('~');
    if (fields.length < 35) continue;

    final rawCode = fields[2].trim();
    final code = StockMarket.isUS(market) ? rawCode.split('.').first : rawCode;
    final price = double.tryParse(fields[3]);
    final preClose = double.tryParse(fields[4]);
    if (code.isEmpty || price == null || price <= 0) continue;
    final changeAmt = double.tryParse(fields[31]) ?? 0;
    quotes.add(
      StockQuote(
        code: code,
        name: universe[code] ?? code,
        market: market,
        price: price,
        changePct: double.tryParse(fields[32]) ?? 0,
        changeAmt: changeAmt,
        openPrice: double.tryParse(fields[5]) ?? price,
        highPrice: double.tryParse(fields[33]) ?? price,
        lowPrice: double.tryParse(fields[34]) ?? price,
        preClose: preClose ?? price - changeAmt,
        volume: double.tryParse(fields[6]) ?? 0,
        turnover: 0,
      ),
    );
  }
  quotes.sort((a, b) => b.changePct.compareTo(a.changePct));
  return quotes;
}

/// Simple retry interceptor that retries on network-level errors (connection
/// closed, timeout, etc.) and HTTP 5xx responses.
///
/// This avoids adding an external dependency while addressing the frequent
/// `HttpException: Connection closed before full header was received` errors
/// seen when calling East Money APIs from macOS desktop.
class _RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  _RetryInterceptor({required this.maxRetries, required this.retryDelay});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['_retryAttempt'] as int?) ?? 0;
    if (attempt >= maxRetries || !_isRetriable(err)) {
      return handler.next(err);
    }

    // Wait before retrying; use exponential-ish backoff: base * (attempt + 1)
    await Future<void>.delayed(retryDelay * (attempt + 1));

    final options = err.requestOptions.copyWith(
      extra: {...err.requestOptions.extra, '_retryAttempt': attempt + 1},
    );

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: options.connectTimeout ?? ApiConstants.connectTimeout,
          receiveTimeout: options.receiveTimeout ?? ApiConstants.receiveTimeout,
          headers: options.headers,
        ),
      );
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (e) {
      handler.next(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// Whether the error deserves a retry.
  bool _isRetriable(DioException err) {
    switch (err.type) {
      // Network-level errors where the server dropped the connection or
      // responded too slowly.
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.unknown:
        return true;

      // Server returned a response — retry only on 5xx.
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500;

      // Request was cancelled or bad — don't retry.
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return false;
    }
  }
}
