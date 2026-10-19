// CachedStockApiService 装饰器测试
// 验证缓存命中跳过 API、缓存未命中调 API 并存储、clearCache 清除。
// 使用手动 fake 代替 mock 框架（项目不依赖 mocktail）。

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockpilot/features/stock/data/cached_stock_api_service.dart';
import 'package:stockpilot/features/stock/data/stock_api_service.dart';
import 'package:stockpilot/features/stock/data/kline_cache.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

// ---------------------------------------------------------------------------
// Fake StockApiService — 记录调用次数和返回值
// ---------------------------------------------------------------------------
class FakeStockApiService implements StockApiService {
  int fetchStockKlineCallCount = 0;
  int fetchHotspotKlinesCallCount = 0;
  List<DailyKline>? _response;
  List<StockQuote> recommendationResponse = const [];
  String? lastCode;
  String? lastMarket;
  int? lastDays;

  void setResponse(List<DailyKline> klines) {
    _response = klines;
  }

  @override
  Future<List<DailyKline>> fetchStockKline(
    String stockCode, {
    String market = 'SH',
    int days = 120,
  }) async {
    fetchStockKlineCallCount++;
    lastCode = stockCode;
    lastMarket = market;
    lastDays = days;
    return _response ?? [];
  }

  // Unused stubs — not needed for these tests.
  @override
  Future<List<StockQuote>> fetchAllMarketQuotes() async => [];
  @override
  Future<List<StockQuote>> fetchHotspotMarketQuotes() async => [];
  @override
  Future<List<DailyKline>> fetchHotspotKlines(
    String stockCode, {
    required String market,
    int days = 6,
  }) async {
    fetchHotspotKlinesCallCount++;
    lastCode = stockCode;
    lastMarket = market;
    lastDays = days;
    return _response ?? [];
  }

  @override
  Future<List<StockQuote>> fetchRecommendationCandidates({
    int limit = 50,
    String market = StockMarket.aShare,
  }) async => recommendationResponse.take(limit).toList();
  @override
  Future<List<MarketSectorQuote>> fetchMarketSectors({
    required bool concept,
    int limit = 100,
  }) async => [];
  @override
  Future<List<SectorStockQuote>> fetchSectorConstituents(
    String sectorCode, {
    int limit = 200,
  }) async => [];
  @override
  Future<StockQuote?> fetchStockQuote(
    String stockCode, {
    String market = 'SH',
  }) async => null;
  @override
  Future<List<StockSearchResult>> searchStock(String keyword) async => [];
  @override
  Future<List<StockNews>> fetchStockNews(
    String stockCode, {
    int page = 1,
    int pageSize = 10,
  }) async => [];
  @override
  Future<StockFundamentals?> fetchStockFundamentals(
    String stockCode, {
    required String stockName,
    String market = StockMarket.sh,
  }) async => null;
  @override
  String getSecid(String code, String market) =>
      '${StockMarket.eastMoneySecidPrefix(market)}.$code';
}

void main() {
  late FakeStockApiService fakeApi;
  late KlineCacheDatabase cacheDb;
  late CachedStockApiService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeApi = FakeStockApiService();
    cacheDb = KlineCacheDatabase.forTesting(NativeDatabase.memory());
    service = CachedStockApiService(api: fakeApi, cache: cacheDb);
  });

  tearDown(() async {
    await cacheDb.close();
  });

  // ---------------------------------------------------------------------------
  // 测试辅助方法
  // ---------------------------------------------------------------------------
  final testKlines = [
    DailyKline(
      date: DateTime(2026, 1, 1),
      open: 10.0,
      close: 10.5,
      high: 11.0,
      low: 9.5,
      volume: 100000,
      amount: 1000000,
      preClose: 10.0,
    ),
    DailyKline(
      date: DateTime(2026, 1, 2),
      open: 10.5,
      close: 11.0,
      high: 11.5,
      low: 10.0,
      volume: 200000,
      amount: 2000000,
      preClose: 10.5,
    ),
  ];

  final testQuotes = [
    const StockQuote(
      code: 'DRAM',
      name: 'Roundhill Memory ETF',
      market: StockMarket.us,
      price: 60,
      changePct: 1.2,
      changeAmt: 0.7,
      openPrice: 59,
      highPrice: 61,
      lowPrice: 58.5,
      preClose: 59.3,
      volume: 100000,
      turnover: 1.1,
      marketCap: 20,
      industry: 'ETF',
    ),
  ];

  // ---------------------------------------------------------------------------
  // 缓存命中：不调用 API
  // ---------------------------------------------------------------------------
  test('缓存命中时直接返回缓存数据，不调 API', () async {
    fakeApi.setResponse(testKlines);

    // 第一次调用：缓存未命中，调 API
    final result1 = await service.fetchStockKline(
      '600519',
      market: 'SH',
      days: 120,
    );
    _expectKlinesEqual(result1, testKlines);
    expect(fakeApi.fetchStockKlineCallCount, 1);

    // 第二次调用：缓存命中，不调 API
    final result2 = await service.fetchStockKline(
      '600519',
      market: 'SH',
      days: 120,
    );
    _expectKlinesEqual(result2, testKlines);
    expect(fakeApi.fetchStockKlineCallCount, 1); // 仍然为 1
  });

  // ---------------------------------------------------------------------------
  // 缓存未命中：调用 API 并存储
  // ---------------------------------------------------------------------------
  test('缓存未命中时调 API 并返回结果', () async {
    fakeApi.setResponse(testKlines);

    final result = await service.fetchStockKline(
      '600519',
      market: 'SH',
      days: 120,
    );

    _expectKlinesEqual(result, testKlines);
    expect(fakeApi.fetchStockKlineCallCount, 1);
    expect(fakeApi.lastCode, '600519');
    expect(fakeApi.lastMarket, 'SH');
    expect(fakeApi.lastDays, 120);
  });

  // ---------------------------------------------------------------------------
  // 缓存未命中：API 返回空列表不缓存
  // ---------------------------------------------------------------------------
  test('缓存未命中且 API 返回空列表时允许下次重试', () async {
    fakeApi.setResponse([]);

    final result = await service.fetchStockKline(
      '000001',
      market: 'SZ',
      days: 60,
    );

    expect(result, isEmpty);
    expect(fakeApi.fetchStockKlineCallCount, 1);

    // 空结果通常是数据源故障，第二次调用应再次尝试 API。
    final result2 = await service.fetchStockKline(
      '000001',
      market: 'SZ',
      days: 60,
    );
    expect(result2, isEmpty);
    expect(fakeApi.fetchStockKlineCallCount, 2);
  });

  // ---------------------------------------------------------------------------
  // clearCache
  // ---------------------------------------------------------------------------
  test('clearCache 后重新调 API', () async {
    fakeApi.setResponse(testKlines);

    // 首次调 API
    await service.fetchStockKline('600519');
    expect(fakeApi.fetchStockKlineCallCount, 1);

    // 清除缓存
    await service.clearCache();

    // 应再次调 API
    await service.fetchStockKline('600519');
    expect(fakeApi.fetchStockKlineCallCount, 2);
  });

  // ---------------------------------------------------------------------------
  // 不同 stockCode 独立缓存
  // ---------------------------------------------------------------------------
  test('不同股票代码独立缓存', () async {
    fakeApi.setResponse(testKlines);

    await service.fetchStockKline('600519', market: 'SH');
    expect(fakeApi.fetchStockKlineCallCount, 1);

    await service.fetchStockKline('000001', market: 'SZ');
    expect(fakeApi.fetchStockKlineCallCount, 2);

    // 两个都应该有缓存了
    await service.fetchStockKline('600519', market: 'SH');
    await service.fetchStockKline('000001', market: 'SZ');
    expect(fakeApi.fetchStockKlineCallCount, 2); // 不增加
  });

  test('同一股票不同周期独立缓存', () async {
    fakeApi.setResponse(testKlines);

    await service.fetchStockKline('600519', market: 'SH', days: 60);
    expect(fakeApi.fetchStockKlineCallCount, 1);

    await service.fetchStockKline('600519', market: 'SH', days: 120);
    expect(fakeApi.fetchStockKlineCallCount, 2);

    await service.fetchStockKline('600519', market: 'SH', days: 60);
    await service.fetchStockKline('600519', market: 'SH', days: 120);
    expect(fakeApi.fetchStockKlineCallCount, 2);
  });

  test('热点专用 K 线入口调用专用数据源并复用本地缓存', () async {
    fakeApi.setResponse(testKlines);

    final first = await service.fetchHotspotKlines(
      '600519',
      market: 'SH',
      days: 6,
    );
    final second = await service.fetchHotspotKlines(
      '600519',
      market: 'SH',
      days: 6,
    );

    _expectKlinesEqual(first, testKlines);
    _expectKlinesEqual(second, testKlines);
    expect(fakeApi.fetchHotspotKlinesCallCount, 1);
    expect(fakeApi.fetchStockKlineCallCount, 0);
  });

  test('推荐候选成功后持久化，空响应时跨实例恢复', () async {
    fakeApi.recommendationResponse = testQuotes;
    final fresh = await service.fetchRecommendationCandidates(
      market: StockMarket.us,
    );
    expect(fresh.single.code, 'DRAM');
    expect(service.lastRecommendationCandidatesWereCached, false);

    final offlineApi = FakeStockApiService();
    final restoredService = CachedStockApiService(
      api: offlineApi,
      cache: cacheDb,
    );
    final restored = await restoredService.fetchRecommendationCandidates(
      market: StockMarket.us,
    );

    expect(restored.single.code, 'DRAM');
    expect(restored.single.industry, 'ETF');
    expect(restoredService.lastRecommendationCandidatesWereCached, true);
    expect(restoredService.lastRecommendationCandidatesUpdatedAt, isNotNull);
  });

  test('推荐候选缓存按市场隔离', () async {
    fakeApi.recommendationResponse = testQuotes;
    await service.fetchRecommendationCandidates(market: StockMarket.us);
    fakeApi.recommendationResponse = const [];

    final hk = await service.fetchRecommendationCandidates(
      market: StockMarket.hk,
    );

    expect(hk, isEmpty);
    expect(service.lastRecommendationCandidatesWereCached, false);
  });

  test('超过七天的推荐候选缓存不再使用', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'recommendation_quotes_v1_${StockMarket.us}',
      '{"updatedAt":"2020-01-01T00:00:00.000","quotes":[]}',
    );

    final result = await service.fetchRecommendationCandidates(
      market: StockMarket.us,
    );

    expect(result, isEmpty);
    expect(service.lastRecommendationCandidatesWereCached, false);
  });

  // ---------------------------------------------------------------------------
  // 自定义 TTL 传递
  // ---------------------------------------------------------------------------
  test('自定义 TTL 过期后重新调 API', () async {
    fakeApi.setResponse(testKlines);

    // 使用极短 TTL
    await service.fetchStockKline('600519', ttl: Duration.zero);

    // 等待过期
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // 应再次调 API
    await service.fetchStockKline('600519');
    expect(fakeApi.fetchStockKlineCallCount, 2);
  });
}

/// Helper to compare two DailyKline lists field-by-field.
void _expectKlinesEqual(List<DailyKline> actual, List<DailyKline> expected) {
  expect(actual.length, expected.length, reason: 'kline list length mismatch');
  for (var i = 0; i < actual.length; i++) {
    final a = actual[i];
    final e = expected[i];
    expect(a.date, e.date, reason: 'kline[$i].date mismatch');
    expect(a.open, e.open, reason: 'kline[$i].open mismatch');
    expect(a.close, e.close, reason: 'kline[$i].close mismatch');
    expect(a.high, e.high, reason: 'kline[$i].high mismatch');
    expect(a.low, e.low, reason: 'kline[$i].low mismatch');
    expect(a.volume, e.volume, reason: 'kline[$i].volume mismatch');
    expect(a.amount, e.amount, reason: 'kline[$i].amount mismatch');
    expect(a.preClose, e.preClose, reason: 'kline[$i].preClose mismatch');
  }
}
