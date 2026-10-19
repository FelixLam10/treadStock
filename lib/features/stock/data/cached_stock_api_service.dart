import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'stock_api_service.dart';
import 'kline_cache.dart';
import '../domain/stock_models.dart';

/// Decorator that wraps [StockApiService] with a local K-line cache layer.
///
/// - [fetchStockKline] checks the cache first; on miss it calls the API,
///   stores the result in the cache, then returns it.
/// - [clearCache] removes all cached entries.
class CachedStockApiService extends StockApiService
    implements RecommendationCacheMetadata {
  static const _recommendationCachePrefix = 'recommendation_quotes_v1_';
  static const recommendationCacheMaxAge = Duration(days: 7);

  final StockApiService _api;
  final KlineCacheDatabase _cache;
  final Future<SharedPreferences> Function() _preferences;

  @override
  bool lastRecommendationCandidatesWereCached = false;

  @override
  DateTime? lastRecommendationCandidatesUpdatedAt;

  CachedStockApiService({
    required StockApiService api,
    required KlineCacheDatabase cache,
    Future<SharedPreferences> Function()? preferences,
  }) : _api = api,
       _cache = cache,
       _preferences = preferences ?? SharedPreferences.getInstance;

  /// Fetch K-line data with caching.
  /// On cache hit (non-expired), returns cached data immediately.
  /// On cache miss, calls the API, stores the result, then returns it.
  @override
  Future<List<DailyKline>> fetchStockKline(
    String code, {
    String market = 'SH',
    int days = 120,
    Duration ttl = const Duration(minutes: 5),
  }) async {
    // Check cache first
    final cached = await _cache.getCachedKlines(
      code,
      market: market,
      days: days,
    );
    if (cached != null) return cached;

    // Cache miss → call API
    final klines = await _api.fetchStockKline(code, market: market, days: days);

    // Empty results usually mean an upstream failure. Do not let that poison
    // the cache and hide a source recovery or fallback response.
    if (klines.isNotEmpty) {
      await _cache.saveKlines(code, market, klines, days: days, ttl: ttl);
    }

    return klines;
  }

  @override
  Future<List<StockQuote>> fetchAllMarketQuotes() {
    return _api.fetchAllMarketQuotes();
  }

  @override
  Future<List<StockQuote>> fetchHotspotMarketQuotes() {
    return _api.fetchHotspotMarketQuotes();
  }

  @override
  Future<List<DailyKline>> fetchHotspotKlines(
    String stockCode, {
    required String market,
    int days = 6,
  }) async {
    final cached = await _cache.getCachedKlines(
      stockCode,
      market: market,
      days: days,
    );
    if (cached != null) return cached;

    final klines = await _api.fetchHotspotKlines(
      stockCode,
      market: market,
      days: days,
    );
    if (klines.isNotEmpty) {
      await _cache.saveKlines(
        stockCode,
        market,
        klines,
        days: days,
        ttl: const Duration(minutes: 5),
      );
    }
    return klines;
  }

  @override
  Future<List<MarketSectorQuote>> fetchMarketSectors({
    required bool concept,
    int limit = 100,
  }) {
    return _api.fetchMarketSectors(concept: concept, limit: limit);
  }

  @override
  Future<List<SectorStockQuote>> fetchSectorConstituents(
    String sectorCode, {
    int limit = 200,
  }) {
    return _api.fetchSectorConstituents(sectorCode, limit: limit);
  }

  @override
  Future<List<StockQuote>> fetchRecommendationCandidates({
    int limit = 50,
    String market = StockMarket.aShare,
  }) async {
    lastRecommendationCandidatesWereCached = false;
    lastRecommendationCandidatesUpdatedAt = null;

    try {
      final quotes = await _api.fetchRecommendationCandidates(
        limit: limit,
        market: market,
      );
      if (quotes.isNotEmpty) {
        final updatedAt = DateTime.now();
        await _saveRecommendationCandidates(market, quotes, updatedAt);
        lastRecommendationCandidatesUpdatedAt = updatedAt;
        return quotes;
      }
    } catch (_) {
      // Fall through to the most recent local snapshot.
    }

    final cached = await _readRecommendationCandidates(market);
    if (cached == null) return [];
    lastRecommendationCandidatesWereCached = true;
    lastRecommendationCandidatesUpdatedAt = cached.updatedAt;
    return cached.quotes.take(limit).toList();
  }

  Future<void> _saveRecommendationCandidates(
    String market,
    List<StockQuote> quotes,
    DateTime updatedAt,
  ) async {
    final prefs = await _preferences();
    await prefs.setString(
      '$_recommendationCachePrefix$market',
      jsonEncode({
        'updatedAt': updatedAt.toIso8601String(),
        'quotes': quotes.map(_quoteToJson).toList(),
      }),
    );
  }

  Future<({List<StockQuote> quotes, DateTime updatedAt})?>
  _readRecommendationCandidates(String market) async {
    try {
      final prefs = await _preferences();
      final text = prefs.getString('$_recommendationCachePrefix$market');
      if (text == null) return null;
      final json = jsonDecode(text) as Map<String, dynamic>;
      final updatedAt = DateTime.parse(json['updatedAt'] as String);
      if (DateTime.now().difference(updatedAt) > recommendationCacheMaxAge) {
        return null;
      }
      final quotes = (json['quotes'] as List<dynamic>)
          .map((item) => _quoteFromJson(item as Map<String, dynamic>))
          .toList();
      if (quotes.isEmpty) return null;
      return (quotes: quotes, updatedAt: updatedAt);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _quoteToJson(StockQuote quote) => {
    'code': quote.code,
    'name': quote.name,
    'market': quote.market,
    'price': quote.price,
    'changePct': quote.changePct,
    'changeAmt': quote.changeAmt,
    'openPrice': quote.openPrice,
    'highPrice': quote.highPrice,
    'lowPrice': quote.lowPrice,
    'preClose': quote.preClose,
    'volume': quote.volume,
    'turnover': quote.turnover,
    'amount': quote.amount,
    'amplitude': quote.amplitude,
    'volumeRatio': quote.volumeRatio,
    'marketCap': quote.marketCap,
    'industry': quote.industry,
  };

  StockQuote _quoteFromJson(Map<String, dynamic> json) => StockQuote(
    code: json['code'] as String,
    name: json['name'] as String,
    market: json['market'] as String,
    price: (json['price'] as num).toDouble(),
    changePct: (json['changePct'] as num).toDouble(),
    changeAmt: (json['changeAmt'] as num).toDouble(),
    openPrice: (json['openPrice'] as num).toDouble(),
    highPrice: (json['highPrice'] as num).toDouble(),
    lowPrice: (json['lowPrice'] as num).toDouble(),
    preClose: (json['preClose'] as num).toDouble(),
    volume: (json['volume'] as num).toDouble(),
    turnover: (json['turnover'] as num).toDouble(),
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    amplitude: (json['amplitude'] as num?)?.toDouble() ?? 0,
    volumeRatio: (json['volumeRatio'] as num?)?.toDouble() ?? 0,
    marketCap: (json['marketCap'] as num?)?.toDouble(),
    industry: json['industry'] as String?,
  );

  @override
  Future<StockQuote?> fetchStockQuote(
    String stockCode, {
    String market = 'SH',
  }) {
    return _api.fetchStockQuote(stockCode, market: market);
  }

  @override
  Future<StockFundamentals?> fetchStockFundamentals(
    String stockCode, {
    required String stockName,
    String market = StockMarket.sh,
  }) {
    return _api.fetchStockFundamentals(
      stockCode,
      stockName: stockName,
      market: market,
    );
  }

  @override
  Future<List<StockSearchResult>> searchStock(String keyword) {
    return _api.searchStock(keyword);
  }

  @override
  Future<List<StockNews>> fetchStockNews(
    String stockCode, {
    int page = 1,
    int pageSize = 10,
  }) {
    return _api.fetchStockNews(stockCode, page: page, pageSize: pageSize);
  }

  /// Clear all cached K-line data.
  Future<void> clearCache() async {
    await _cache.clearAll();
    final prefs = await _preferences();
    for (final market in const [
      StockMarket.aShare,
      StockMarket.hk,
      StockMarket.us,
    ]) {
      await prefs.remove('$_recommendationCachePrefix$market');
    }
    lastRecommendationCandidatesWereCached = false;
    lastRecommendationCandidatesUpdatedAt = null;
  }
}
