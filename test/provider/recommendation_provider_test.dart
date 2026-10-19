// T-PRV-02: StrategyRecommendationState error vs empty-data distinction.

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:stockpilot/features/analysis/domain/analysis_engine.dart';
import 'package:stockpilot/features/stock/data/stock_api_service.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/features/strategy/data/strategy_service.dart';
import 'package:stockpilot/features/strategy/domain/strategy_scoring_service.dart';
import 'package:stockpilot/features/strategy/presentation/strategy_recommendation_provider.dart';

class CountingStockApiService extends StockApiService
    implements RecommendationCacheMetadata {
  int klineCalls = 0;
  String? lastRecommendationMarket;
  bool returnEmptyCandidates = false;
  bool throwOnCandidates = false;
  @override
  bool lastRecommendationCandidatesWereCached = false;
  @override
  DateTime? lastRecommendationCandidatesUpdatedAt;

  @override
  Future<List<StockQuote>> fetchRecommendationCandidates({
    int limit = 50,
    String market = StockMarket.aShare,
  }) async {
    lastRecommendationMarket = market;
    if (throwOnCandidates) throw Exception('test failure');
    if (returnEmptyCandidates) return [];
    return List.generate(30, (i) {
      final code = (600000 + i).toString();
      return StockQuote(
        code: code,
        name: '测试$code',
        market: 'SH',
        price: 10 + i.toDouble(),
        changePct: 1,
        changeAmt: 0.1,
        openPrice: 10,
        highPrice: 11,
        lowPrice: 9,
        preClose: 9.9,
        volume: 100000,
        turnover: 1,
      );
    });
  }

  @override
  Future<List<DailyKline>> fetchStockKline(
    String stockCode, {
    String market = 'SH',
    int days = 120,
  }) async {
    klineCalls++;
    return List.generate(80, (i) {
      final close = 10 + i * 0.1;
      return DailyKline(
        date: DateTime(2026, 1, 1).add(Duration(days: i)),
        open: close - 0.1,
        close: close,
        high: close + 0.2,
        low: close - 0.2,
        volume: 100000 + i.toDouble(),
        amount: 1000000,
        preClose: i == 0 ? close - 0.1 : 10 + (i - 1) * 0.1,
      );
    });
  }
}

void main() {
  // T-PRV-02 (A3): StrategyRecommendationState must distinguish a hard load
  // error from a quote-source-empty condition so the UI can show the right
  // message instead of always blaming the network.
  group('T-PRV-02: StrategyRecommendationState error vs empty-data', () {
    test('初始状态不显示错误态', () {
      const state = StrategyRecommendationState();
      expect(state.hasError, false);
      expect(state.isEmptyData, false);
      expect(state.showErrorState, false);
    });

    test('行情源返回空 (isEmptyData) 不等于加载错误 (hasError)', () {
      final emptyData = const StrategyRecommendationState().copyWith(
        isEmptyData: true,
        errorMessage: '暂无行情数据',
      );
      expect(emptyData.isEmptyData, true);
      expect(emptyData.hasError, false);
      expect(emptyData.showErrorState, true);

      final hardError = const StrategyRecommendationState().copyWith(
        hasError: true,
        errorMessage: '数据更新失败',
      );
      expect(hardError.hasError, true);
      expect(hardError.isEmptyData, false);
      expect(hardError.showErrorState, true);

      // The two states are distinct even though both surface an error UI.
      expect(emptyData.hasError, isNot(hardError.hasError));
      expect(hardError.isEmptyData, isNot(emptyData.isEmptyData));
    });
  });

  group('recommendation loading priority', () {
    test('首屏只拉取有限数量的候选 K 线，避免 loading 等完整候选池', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final strategyService = StrategyService(db: db);
      final api = CountingStockApiService();
      final notifier = StrategyRecommendationNotifier(
        strategyService,
        api,
        StrategyScoringService(AnalysisEngine()),
      );

      await notifier.loadRecommendations();

      expect(notifier.state.isLoading, false);
      expect(
        api.klineCalls,
        lessThanOrEqualTo(initialRecommendationCandidateLimit + 1),
      );

      notifier.dispose();
      await db.close();
    });

    test('严格策略无命中时展示观察候选并标记为 fallback', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final strategyService = StrategyService(db: db);
      await strategyService.init();
      final strategy = strategyService.getStrategies().first;
      await (db.update(db.strategies)..where((t) => t.id.equals(strategy.id)))
          .write(const StrategiesCompanion(recommendThreshold: Value(11)));
      await strategyService.reloadCache();

      final notifier = StrategyRecommendationNotifier(
        strategyService,
        CountingStockApiService(),
        StrategyScoringService(AnalysisEngine()),
      );

      await notifier.loadRecommendations();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.groups, isNotEmpty);
      expect(notifier.state.groups.first.isFallbackCandidates, true);
      expect(notifier.state.groups.first.recommendations, isNotEmpty);

      notifier.dispose();
      await db.close();
    });

    test('切换推荐市场时传递对应市场参数', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final strategyService = StrategyService(db: db);
      final api = CountingStockApiService();
      final notifier = StrategyRecommendationNotifier(
        strategyService,
        api,
        StrategyScoringService(AnalysisEngine()),
      );

      await notifier.loadRecommendations(market: RecommendationMarket.us);

      expect(notifier.state.selectedMarket, RecommendationMarket.us);
      expect(api.lastRecommendationMarket, StockMarket.us);

      notifier.dispose();
      await db.close();
    });

    test('行情返回空时保留当前市场最近一次有效结果', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final strategyService = StrategyService(db: db);
      final api = CountingStockApiService();
      final notifier = StrategyRecommendationNotifier(
        strategyService,
        api,
        StrategyScoringService(AnalysisEngine()),
      );

      await notifier.loadRecommendations(market: RecommendationMarket.us);
      final previousGroups = notifier.state.groups;
      final previousUpdatedAt = notifier.state.lastUpdated;
      api.returnEmptyCandidates = true;

      await notifier.loadRecommendations(market: RecommendationMarket.us);

      expect(notifier.state.isEmptyData, true);
      expect(notifier.state.groups, same(previousGroups));
      expect(notifier.state.lastUpdated, previousUpdatedAt);
      expect(notifier.state.selectedMarket, RecommendationMarket.us);

      notifier.dispose();
      await db.close();
    });

    test('市场快照相互隔离，不会用 A 股结果充当美股缓存', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final strategyService = StrategyService(db: db);
      final api = CountingStockApiService();
      final notifier = StrategyRecommendationNotifier(
        strategyService,
        api,
        StrategyScoringService(AnalysisEngine()),
      );

      await notifier.loadRecommendations(market: RecommendationMarket.aShare);
      expect(notifier.state.groups, isNotEmpty);
      api.returnEmptyCandidates = true;

      await notifier.loadRecommendations(market: RecommendationMarket.us);

      expect(notifier.state.isEmptyData, true);
      expect(notifier.state.groups, isEmpty);
      expect(notifier.state.lastUpdated, equals(null));
      expect(notifier.state.selectedMarket, RecommendationMarket.us);

      notifier.dispose();
      await db.close();
    });

    test('候选行情来自持久化缓存时保留原始更新时间', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final strategyService = StrategyService(db: db);
      final cachedAt = DateTime(2026, 10, 7, 15, 30);
      final api = CountingStockApiService()
        ..lastRecommendationCandidatesWereCached = true
        ..lastRecommendationCandidatesUpdatedAt = cachedAt;
      final notifier = StrategyRecommendationNotifier(
        strategyService,
        api,
        StrategyScoringService(AnalysisEngine()),
      );

      await notifier.loadRecommendations(market: RecommendationMarket.us);

      expect(notifier.state.isStaleData, true);
      expect(notifier.state.lastUpdated, cachedAt);
      expect(notifier.state.errorMessage, contains('缓存'));

      notifier.dispose();
      await db.close();
    });
  });
}
