import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/features/strategy/domain/backtest_models.dart';

BacktestReport _report({
  String id = 'report-1',
  String versionId = 'version-1',
  int versionNumber = 1,
  int trades = 20,
  String fingerprint = 'same-data',
  BacktestConfig config = const BacktestConfig(),
  String stockCode = '600000',
}) {
  return BacktestReport(
    id: id,
    strategyId: 'strategy-1',
    strategyVersionId: versionId,
    strategyVersionNumber: versionNumber,
    stockName: '浦发银行',
    market: 'SH',
    config: config,
    adjustmentMode: BacktestAdjustmentMode.forward,
    dataFingerprint: fingerprint,
    dataAsOf: DateTime(2026, 10, 8),
    createdAt: DateTime(2026, 10, 8, 10),
    result: BacktestResult(
      strategyName: '测试策略',
      stockCode: stockCode,
      trades: const [],
      totalTrades: trades,
      winCount: trades ~/ 2,
      loseCount: trades - trades ~/ 2,
      winRate: 0.5,
      totalReturnPct: versionNumber * 2,
      maxDrawdownPct: -5,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2026, 10, 8),
      barsProcessed: 400,
    ),
  );
}

void main() {
  group('T-F011-1: 回测证据快照', () {
    test('配置 JSON 往返后保持可比较', () {
      const config = BacktestConfig(
        initialCapital: 200000,
        positionSize: 0.5,
        commissionRate: 0.0005,
        stampTaxRate: 0.001,
        slippage: 0.02,
        warmupBars: 80,
        maxTrades: 12,
        stopLossPct: -0.04,
        takeProfitPct: 0.12,
      );

      expect(BacktestConfig.fromJson(config.toJson()), config);
    });

    test('结果 JSON 可保存无亏损时的无限盈亏比', () {
      final result = BacktestResult(
        strategyName: '测试策略',
        stockCode: '600000',
        trades: const [],
        totalTrades: 2,
        profitFactor: double.infinity,
      );

      final restored = BacktestResult.fromJson(result.toJson());

      expect(restored.profitFactor, double.infinity);
      expect(restored.totalTrades, 2);
    });

    test('相同 K 线生成相同指纹，价格变化会改变指纹', () {
      final base = [
        DailyKline(
          date: DateTime(2026, 10, 8),
          open: 10,
          close: 10.2,
          high: 10.3,
          low: 9.9,
          volume: 1000,
          amount: 10200,
          preClose: 10,
        ),
      ];
      final changed = [
        DailyKline(
          date: DateTime(2026, 10, 8),
          open: 10,
          close: 10.21,
          high: 10.3,
          low: 9.9,
          volume: 1000,
          amount: 10210,
          preClose: 10,
        ),
      ];

      expect(backtestDataFingerprint(base), backtestDataFingerprint(base));
      expect(
        backtestDataFingerprint(base),
        isNot(backtestDataFingerprint(changed)),
      );
    });

    test('少于 20 笔完成交易时明确标记样本不足', () {
      final report = _report(trades: 19);

      expect(report.sampleStatus, BacktestSampleStatus.insufficient);
      expect(report.hasEnoughSample, isFalse);
      expect(report.sampleMessage, contains('少于 20 笔'));
      expect(report.result.healthLabel, '复盘样本不足');
    });
  });

  group('T-F011-2: 策略版本回测比较', () {
    test('同股票、行情指纹和配置的足量样本可以比较', () {
      final comparison = BacktestComparison.compare(
        _report(),
        _report(id: 'report-2', versionId: 'version-2', versionNumber: 2),
      );

      expect(comparison.status, BacktestComparisonStatus.comparable);
      expect(comparison.returnDeltaPct, 2);
      expect(comparison.message, contains('相同股票、行情'));
    });

    test('输入一致但任一版本样本不足时不判断优劣', () {
      final comparison = BacktestComparison.compare(
        _report(trades: 8),
        _report(id: 'report-2', versionId: 'version-2', versionNumber: 2),
      );

      expect(comparison.status, BacktestComparisonStatus.insufficientSample);
      expect(comparison.message, contains('不宜判断版本优劣'));
    });

    test('行情指纹或配置不同则拒绝归因到版本变化', () {
      final comparison = BacktestComparison.compare(
        _report(),
        _report(
          id: 'report-2',
          versionId: 'version-2',
          versionNumber: 2,
          fingerprint: 'different-data',
        ),
      );

      expect(comparison.status, BacktestComparisonStatus.incompatibleInputs);
      expect(comparison.message, contains('不能把差异归因于策略版本'));
    });
  });
}
