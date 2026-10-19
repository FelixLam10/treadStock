import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/analysis/domain/analysis_engine.dart';
import 'package:stockpilot/features/stock/data/cached_stock_api_service.dart';
import 'package:stockpilot/features/stock/data/kline_cache.dart';
import 'package:stockpilot/features/stock/data/stock_api_service.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/features/strategy/data/strategy_service.dart';
import 'package:stockpilot/features/strategy/domain/backtest_models.dart';
import 'package:stockpilot/features/strategy/domain/strategy_knowledge_package.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/presentation/backtest_provider.dart';

class _FakeStrategyService extends StrategyService {
  _FakeStrategyService({required super.db, required this.versions});

  final List<StrategyVersionInfo> versions;
  final List<BacktestReport> savedReports = [];

  @override
  Future<void> init() async {}

  @override
  Future<StrategyVersionInfo?> getStrategyVersion(
    String strategyId, {
    String? versionId,
  }) async {
    return versions.firstWhere((version) => version.id == versionId);
  }

  @override
  Future<void> saveBacktestReport(BacktestReport report) async {
    savedReports.insert(0, report);
  }

  @override
  Future<List<BacktestReport>> getBacktestReports(
    String strategyId, {
    String? stockCode,
  }) async => savedReports
      .where((report) => report.result.stockCode == stockCode)
      .toList();
}

class _FakeCachedStockApiService extends CachedStockApiService {
  _FakeCachedStockApiService({required super.cache, required this.klines})
    : super(api: StockApiService());

  final List<DailyKline> klines;

  @override
  Future<List<DailyKline>> fetchStockKline(
    String code, {
    String market = 'SH',
    int days = 120,
    Duration ttl = const Duration(minutes: 5),
  }) async => klines;
}

List<DailyKline> _klines() {
  return List.generate(100, (index) {
    final price = 10 + index * 0.05;
    return DailyKline(
      date: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: price - 0.02,
      close: price,
      high: price + 0.1,
      low: price - 0.1,
      volume: 100000 + index * 100,
      amount: price * 100000,
      preClose: index == 0 ? price : price - 0.05,
    );
  });
}

StrategyVersionInfo _version(int number) {
  final now = DateTime(2026, 10, 8);
  final strategy = Strategy(
    id: 'strategy-1',
    name: '版本策略',
    recommendThreshold: 5,
    createdAt: now,
    updatedAt: now,
  );
  return StrategyVersionInfo(
    id: 'version-$number',
    strategyId: strategy.id,
    versionNumber: number,
    status: number == 1 ? 'active' : 'candidate',
    strategyType: StrategyKnowledgeType.custom,
    riskNotes: const [],
    pendingQuestions: const [],
    compatibilityIssues: const [],
    createdAt: now,
    sources: const [],
    strategySnapshot: strategy,
  );
}

void main() {
  test('T-F011-1/2: Provider 按版本运行、保存并比较相同输入的报告', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final cache = KlineCacheDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(cache.close);
    final service = _FakeStrategyService(
      db: db,
      versions: [_version(2), _version(1)],
    );
    final notifier = BacktestNotifier(
      strategyService: service,
      apiService: _FakeCachedStockApiService(cache: cache, klines: _klines()),
      analysisEngine: AnalysisEngine(),
    );
    addTearDown(notifier.dispose);

    await notifier.runBacktest(
      strategyId: 'strategy-1',
      strategyVersionId: 'version-1',
      stockCode: '600000',
      stockName: '浦发银行',
      market: 'SH',
    );

    expect(notifier.state.status, BacktestStatus.done);
    expect(notifier.state.report!.strategyVersionNumber, 1);
    expect(notifier.state.report!.dataFingerprint, isNotEmpty);
    expect(service.savedReports, hasLength(1));
    expect(notifier.state.comparison, isNull);

    notifier.reset();
    await notifier.runBacktest(
      strategyId: 'strategy-1',
      strategyVersionId: 'version-2',
      stockCode: '600000',
      stockName: '浦发银行',
      market: 'SH',
    );

    expect(service.savedReports, hasLength(2));
    expect(notifier.state.report!.strategyVersionNumber, 2);
    expect(notifier.state.comparison, isNotNull);
    expect(
      notifier.state.comparison!.status,
      BacktestComparisonStatus.insufficientSample,
    );
  });
}
