import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/backtest_models.dart';
import 'package:stockpilot/features/strategy/presentation/backtest_result_page.dart';

BacktestReport _report({
  required String id,
  required int version,
  int trades = 8,
}) {
  return BacktestReport(
    id: id,
    strategyId: 'strategy-1',
    strategyVersionId: 'version-$version',
    strategyVersionNumber: version,
    stockName: '浦发银行',
    market: 'SH',
    config: const BacktestConfig(),
    adjustmentMode: BacktestAdjustmentMode.forward,
    dataFingerprint: '1234567890abcdef',
    dataAsOf: DateTime(2026, 10, 8),
    createdAt: DateTime(2026, 10, 8),
    result: BacktestResult(
      strategyName: '五日均线确认',
      stockCode: '600000',
      trades: const [],
      totalTrades: trades,
      winCount: trades ~/ 2,
      loseCount: trades - trades ~/ 2,
      winRate: 0.5,
      totalReturnPct: version * 2,
      maxDrawdownPct: -5,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2026, 10, 8),
      barsProcessed: 400,
    ),
  );
}

void main() {
  testWidgets('T-F011-1/2: 报告展示版本快照和样本不足的版本比较', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final baseline = _report(id: 'report-1', version: 1, trades: 10);
    final candidate = _report(id: 'report-2', version: 2, trades: 8);

    await tester.pumpWidget(
      MaterialApp(
        home: BacktestResultPage(
          report: candidate,
          comparison: BacktestComparison.compare(baseline, candidate),
        ),
      ),
    );

    expect(find.byKey(const Key('backtest-evidence')), findsOneWidget);
    expect(find.text('回测证据快照'), findsOneWidget);
    expect(find.text('前复权'), findsOneWidget);
    expect(find.text('2026-10-08'), findsOneWidget);
    expect(find.text('复盘样本不足'), findsOneWidget);
    expect(find.textContaining('少于 20 笔'), findsWidgets);

    await tester.ensureVisible(
      find.byKey(const Key('backtest-version-comparison')),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('版本对比 · v1 → v2'), findsOneWidget);
    expect(find.textContaining('不宜判断版本优劣'), findsOneWidget);
    expect(find.textContaining('仅供观察与复盘'), findsOneWidget);
  });
}
