import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/features/strategy/data/strategy_service.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/domain/strategy_knowledge_package.dart';
import 'package:stockpilot/features/strategy/presentation/backtest_config_page.dart';
import 'package:stockpilot/shared/providers.dart';

class _FakeStrategyService extends StrategyService {
  _FakeStrategyService({required super.db, required this.versions});

  final List<StrategyVersionInfo> versions;

  @override
  Future<void> init() async {}

  @override
  Future<List<StrategyVersionInfo>> getStrategyVersions(
    String strategyId,
  ) async => versions;
}

StrategyVersionInfo _version({
  required Strategy strategy,
  required int number,
  required String status,
}) => StrategyVersionInfo(
  id: 'version-$number',
  strategyId: strategy.id,
  versionNumber: number,
  status: status,
  strategyType: StrategyKnowledgeType.custom,
  riskNotes: const [],
  pendingQuestions: const [],
  compatibilityIssues: const [],
  previousVersionId: number == 1 ? null : 'version-${number - 1}',
  createdAt: DateTime(2026, 10, 8),
  sources: const [],
  strategySnapshot: strategy,
);

void main() {
  testWidgets('T-F011-3: 个股详情进入回测时自动带入股票和当前版本', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 10, 8);
    final strategy = Strategy(
      id: 'strategy-1',
      name: '五日均线确认',
      createdAt: now,
      updatedAt: now,
    );
    final service = _FakeStrategyService(
      db: db,
      versions: [_version(strategy: strategy, number: 1, status: 'active')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          strategyServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          home: BacktestConfigPage(
            strategyId: strategy.id,
            strategyName: strategy.name,
            initialStockCode: '600000',
            initialStockName: '浦发银行',
            initialMarket: 'SH',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('v1 · 当前使用'), findsOneWidget);
    expect(find.textContaining('浦发银行'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-F015-4: 从版本页进入回测时优先选中指定历史版本', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 10, 8);
    final strategy = Strategy(
      id: 'strategy-1',
      name: '五日均线确认',
      createdAt: now,
      updatedAt: now,
    );
    final service = _FakeStrategyService(
      db: db,
      versions: [
        _version(strategy: strategy, number: 2, status: 'candidate'),
        _version(strategy: strategy, number: 1, status: 'active'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          strategyServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          home: BacktestConfigPage(
            strategyId: strategy.id,
            strategyName: strategy.name,
            initialStrategyVersionId: 'version-2',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final selector = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(selector.initialValue, 'version-2');
    expect(find.textContaining('v2 · 候选版本'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
