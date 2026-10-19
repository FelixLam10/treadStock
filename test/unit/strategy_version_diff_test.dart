import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/signal_rule.dart';
import 'package:stockpilot/features/strategy/domain/strategy_knowledge_package.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/domain/strategy_version_diff.dart';

StrategyVersionInfo _version({
  required int number,
  required Strategy strategy,
  List<String> pending = const [],
}) {
  return StrategyVersionInfo(
    id: 'version-$number',
    strategyId: strategy.id,
    versionNumber: number,
    status: number == 1 ? 'active' : 'candidate',
    strategyType: StrategyKnowledgeType.personal,
    riskNotes: const [],
    pendingQuestions: pending,
    compatibilityIssues: const [],
    previousVersionId: number == 1 ? null : 'version-${number - 1}',
    createdAt: DateTime(2026, 10, number),
    sources: const [],
    strategySnapshot: strategy,
  );
}

Strategy _strategy({int maShort = 5, List<SignalRule>? entryRules}) {
  return Strategy(
    id: 'strategy-1',
    name: '均线观察',
    maShortPeriod: maShort,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
    entryRules: entryRules,
  );
}

void main() {
  test('版本差异区分新增、删除、修改、冲突和待确认', () {
    final baseline = _version(
      number: 1,
      strategy: _strategy(
        entryRules: const [
          SignalRule(indicator: 'rsi', condition: 'gt', value: 30),
          SignalRule(indicator: 'volume_ratio', condition: 'gt', value: 1.2),
        ],
      ),
    );
    final candidate = _version(
      number: 2,
      pending: const ['横盘的量化口径是什么？'],
      strategy: _strategy(
        maShort: 10,
        entryRules: const [
          SignalRule(indicator: 'rsi', condition: 'lt', value: 30),
          SignalRule(indicator: 'macd', condition: 'cross_up', value: 0),
        ],
      ),
    );

    final diff = StrategyVersionDiff.compare(
      baseline: baseline,
      candidate: candidate,
    );

    expect(diff.count(StrategyVersionChangeKind.added), 1);
    expect(diff.count(StrategyVersionChangeKind.removed), 1);
    expect(diff.count(StrategyVersionChangeKind.modified), 1);
    expect(diff.count(StrategyVersionChangeKind.conflict), 1);
    expect(diff.count(StrategyVersionChangeKind.pending), 1);
    expect(diff.hasConflicts, isTrue);
  });

  test('相同快照没有伪差异', () {
    final strategy = _strategy(
      entryRules: const [
        SignalRule(indicator: 'price_ma_short', condition: 'above', value: 0),
      ],
    );

    final diff = StrategyVersionDiff.compare(
      baseline: _version(number: 1, strategy: strategy),
      candidate: _version(number: 2, strategy: strategy),
    );

    expect(diff.isEmpty, isTrue);
    expect(diff.hasConflicts, isFalse);
  });
}
