import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/features/strategy/data/strategy_service.dart';
import 'package:stockpilot/features/strategy/domain/backtest_models.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';

BacktestReport _report({
  required String strategyId,
  required String versionId,
  required int versionNumber,
  required DateTime createdAt,
}) {
  return BacktestReport(
    id: 'report-$versionNumber',
    strategyId: strategyId,
    strategyVersionId: versionId,
    strategyVersionNumber: versionNumber,
    stockName: '浦发银行',
    market: 'SH',
    config: const BacktestConfig(
      initialCapital: 120000,
      positionSize: 0.6,
      slippage: 0.01,
    ),
    adjustmentMode: BacktestAdjustmentMode.forward,
    dataFingerprint: 'fingerprint-v$versionNumber',
    dataAsOf: DateTime(2026, 10, 8),
    createdAt: createdAt,
    result: BacktestResult(
      strategyName: '版本策略 v$versionNumber',
      stockCode: '600000',
      trades: const [],
      totalTrades: versionNumber + 3,
      totalReturnPct: versionNumber * 1.5,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2026, 10, 8),
      barsProcessed: 400,
    ),
  );
}

void main() {
  late AppDatabase db;
  late StrategyService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = StrategyService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('T-F011-1: 回测报告绑定不可变策略版本并完整恢复快照', () async {
    await service.init();
    final strategy = await service.createStrategy(
      StrategyFormData(name: '版本策略'),
    );
    final version = (await service.getStrategyVersions(strategy.id)).first;
    final report = _report(
      strategyId: strategy.id,
      versionId: version.id,
      versionNumber: version.versionNumber,
      createdAt: DateTime(2026, 10, 8, 10),
    );

    await service.saveBacktestReport(report);
    final restored = (await service.getBacktestReports(strategy.id)).single;

    expect(restored.strategyVersionId, version.id);
    expect(restored.strategyVersionNumber, 1);
    expect(restored.config.initialCapital, 120000);
    expect(restored.config.slippage, 0.01);
    expect(restored.adjustmentMode, BacktestAdjustmentMode.forward);
    expect(restored.dataFingerprint, 'fingerprint-v1');
    expect(restored.result.strategyName, '版本策略 v1');
    expect(restored.result.barsProcessed, 400);
  });

  test('T-F011-2: 历史报告按时间倒序且不会被后续版本覆盖', () async {
    await service.init();
    final strategy = await service.createStrategy(
      StrategyFormData(name: '版本策略'),
    );
    final v1 = (await service.getStrategyVersions(strategy.id)).first;
    await service.saveBacktestReport(
      _report(
        strategyId: strategy.id,
        versionId: v1.id,
        versionNumber: v1.versionNumber,
        createdAt: DateTime(2026, 10, 8, 9),
      ),
    );

    final form = StrategyFormData.fromStrategy(strategy)..name = '版本策略修订';
    await service.updateStrategy(strategy.id, form);
    final versions = await service.getStrategyVersions(strategy.id);
    final v2 = versions.first;
    await service.saveBacktestReport(
      _report(
        strategyId: strategy.id,
        versionId: v2.id,
        versionNumber: v2.versionNumber,
        createdAt: DateTime(2026, 10, 8, 11),
      ),
    );

    final reports = await service.getBacktestReports(
      strategy.id,
      stockCode: '600000',
    );

    expect(reports.map((item) => item.strategyVersionNumber), [2, 1]);
    expect(reports.last.result.strategyName, '版本策略 v1');
    expect(reports.first.result.strategyName, '版本策略 v2');
  });
}
