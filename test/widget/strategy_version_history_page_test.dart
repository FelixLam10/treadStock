import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/signal_rule.dart';
import 'package:stockpilot/features/strategy/domain/strategy_knowledge_package.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/presentation/strategy_knowledge_provider.dart';
import 'package:stockpilot/features/strategy/presentation/strategy_version_history_page.dart';

StrategyVersionInfo _version({
  required int number,
  required String status,
  required String condition,
  List<String> pending = const [],
}) {
  return StrategyVersionInfo(
    id: 'version-$number',
    strategyId: 'strategy-1',
    versionNumber: number,
    status: status,
    strategyType: StrategyKnowledgeType.personal,
    riskNotes: const [],
    pendingQuestions: pending,
    compatibilityIssues: const [],
    previousVersionId: number == 1 ? null : 'version-1',
    createdAt: DateTime(2026, 10, number),
    sources: const [],
    strategySnapshot: Strategy(
      id: 'strategy-1',
      name: '均线观察',
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, number),
      entryRules: [
        SignalRule(indicator: 'price_ma_short', condition: condition, value: 0),
      ],
    ),
  );
}

void main() {
  testWidgets('候选版本展示冲突和待确认，阻塞时不能激活', (tester) async {
    final versions = [
      _version(
        number: 2,
        status: 'candidate',
        condition: 'cross_down',
        pending: const ['横盘口径待确认'],
      ),
      _version(number: 1, status: 'active', condition: 'cross_up'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          strategyVersionsProvider(
            'strategy-1',
          ).overrideWith((ref) async => versions),
        ],
        child: const MaterialApp(
          home: StrategyVersionHistoryPage(strategyId: 'strategy-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('策略版本与差异'), findsOneWidget);
    expect(find.text('候选版本'), findsOneWidget);
    expect(find.text('冲突 1'), findsOneWidget);
    expect(find.text('待确认 1'), findsOneWidget);
    expect(find.textContaining('相反'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('activate-version-version-2')),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
