import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/providers.dart';
import '../../stock/data/cached_stock_api_service.dart';
import '../../analysis/domain/analysis_engine.dart';
import '../data/strategy_service.dart';
import '../domain/backtest_engine.dart';
import '../domain/backtest_models.dart';

// ── Backtest State ──────────────────────────────────────

enum BacktestStatus { idle, loading, done, error }

class BacktestState {
  final BacktestStatus status;
  final BacktestReport? report;
  final BacktestComparison? comparison;
  final String? errorMessage;

  const BacktestState({
    this.status = BacktestStatus.idle,
    this.report,
    this.comparison,
    this.errorMessage,
  });

  BacktestResult? get result => report?.result;

  BacktestState copyWith({
    BacktestStatus? status,
    BacktestReport? report,
    BacktestComparison? comparison,
    String? errorMessage,
  }) {
    return BacktestState(
      status: status ?? this.status,
      report: report ?? this.report,
      comparison: comparison ?? this.comparison,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Backtest Notifier ───────────────────────────────────

class BacktestNotifier extends StateNotifier<BacktestState> {
  final StrategyService _strategyService;
  final CachedStockApiService _apiService;
  final AnalysisEngine _analysisEngine;
  final Uuid _uuid;

  BacktestNotifier({
    required StrategyService strategyService,
    required CachedStockApiService apiService,
    required AnalysisEngine analysisEngine,
    Uuid uuid = const Uuid(),
  }) : _strategyService = strategyService,
       _apiService = apiService,
       _analysisEngine = analysisEngine,
       _uuid = uuid,
       super(const BacktestState());

  Future<void> runBacktest({
    required String strategyId,
    required String stockCode,
    required String stockName,
    required String market,
    String? strategyVersionId,
    BacktestConfig config = const BacktestConfig(),
  }) async {
    state = state.copyWith(status: BacktestStatus.loading);

    try {
      await _strategyService.init();
      final version = await _strategyService.getStrategyVersion(
        strategyId,
        versionId: strategyVersionId,
      );
      if (version == null) {
        state = state.copyWith(
          status: BacktestStatus.error,
          errorMessage: '策略版本不存在',
        );
        return;
      }
      final strategy = version.strategySnapshot;

      // Fetch kline data (up to 500 bars for backtest)
      final klines = await _apiService.fetchStockKline(
        stockCode,
        market: market,
        days: 500,
      );

      if (klines.length < 60) {
        state = state.copyWith(
          status: BacktestStatus.error,
          errorMessage: 'K线数据不足（需要至少60根）',
        );
        return;
      }

      final engine = BacktestEngine();
      final result = engine.run(
        klines: klines,
        strategy: strategy,
        config: config,
        stockCode: stockCode,
        analysisEngine: _analysisEngine,
      );

      final now = DateTime.now();
      final report = BacktestReport(
        id: _uuid.v4(),
        strategyId: strategyId,
        strategyVersionId: version.id,
        strategyVersionNumber: version.versionNumber,
        stockName: stockName,
        market: market,
        config: config,
        adjustmentMode: BacktestAdjustmentMode.forward,
        dataFingerprint: backtestDataFingerprint(klines),
        dataAsOf: klines.last.date,
        createdAt: now,
        result: result,
      );
      await _strategyService.saveBacktestReport(report);

      final history = await _strategyService.getBacktestReports(
        strategyId,
        stockCode: stockCode,
      );
      final otherVersions = history
          .where(
            (item) =>
                item.id != report.id &&
                item.strategyVersionId != report.strategyVersionId,
          )
          .toList();
      final baseline =
          otherVersions
              .where(
                (item) =>
                    item.result.stockCode == report.result.stockCode &&
                    item.market == report.market &&
                    item.adjustmentMode == report.adjustmentMode &&
                    item.dataFingerprint == report.dataFingerprint &&
                    item.config == report.config,
              )
              .firstOrNull ??
          otherVersions.firstOrNull;
      final comparison = baseline == null
          ? null
          : BacktestComparison.compare(baseline, report);

      if (!mounted) return;
      state = state.copyWith(
        status: BacktestStatus.done,
        report: report,
        comparison: comparison,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: BacktestStatus.error,
        errorMessage: '回测失败：$e',
      );
    }
  }

  void reset() {
    state = const BacktestState();
  }
}

// ── Import for cached API ──
// (CachedStockApiService is already imported via providers)

// ── Providers ───────────────────────────────────────────

final backtestProvider = StateNotifierProvider<BacktestNotifier, BacktestState>(
  (ref) {
    return BacktestNotifier(
      strategyService: ref.read(strategyServiceProvider),
      apiService: ref.read(cachedStockApiServiceProvider),
      analysisEngine: ref.read(analysisEngineProvider),
    );
  },
);
