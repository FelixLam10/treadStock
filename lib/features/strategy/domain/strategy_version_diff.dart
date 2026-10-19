import 'dart:convert';

import 'signal_rule.dart';
import 'strategy_knowledge_package.dart';
import 'strategy_models.dart';

enum StrategyVersionChangeKind {
  added('新增'),
  removed('删除'),
  modified('修改'),
  conflict('冲突'),
  pending('待确认');

  final String label;
  const StrategyVersionChangeKind(this.label);
}

class StrategyVersionChange {
  final StrategyVersionChangeKind kind;
  final String area;
  final String title;
  final String? before;
  final String? after;

  const StrategyVersionChange({
    required this.kind,
    required this.area,
    required this.title,
    this.before,
    this.after,
  });
}

/// Deterministic comparison between two immutable strategy snapshots.
///
/// Strategy snapshots do not persist editor-only rule IDs, so rules are paired
/// by entry/exit scope and indicator identity. Opposite conditions on the same
/// indicator are surfaced as conflicts instead of silently replacing history.
class StrategyVersionDiff {
  final int? fromVersionNumber;
  final int toVersionNumber;
  final List<StrategyVersionChange> changes;

  const StrategyVersionDiff({
    required this.fromVersionNumber,
    required this.toVersionNumber,
    required this.changes,
  });

  bool get isEmpty => changes.isEmpty;
  bool get hasConflicts => changes.any(
    (change) => change.kind == StrategyVersionChangeKind.conflict,
  );

  int count(StrategyVersionChangeKind kind) =>
      changes.where((change) => change.kind == kind).length;

  static StrategyVersionDiff compare({
    StrategyVersionInfo? baseline,
    required StrategyVersionInfo candidate,
  }) {
    final changes = <StrategyVersionChange>[];
    final before = baseline?.strategySnapshot;
    final after = candidate.strategySnapshot;

    if (before == null) {
      changes.add(
        StrategyVersionChange(
          kind: StrategyVersionChangeKind.added,
          area: '策略',
          title: '初始策略版本',
          after: after.name,
        ),
      );
    } else {
      _compareParameters(before, after, changes);
      _compareRules(before, after, changes);
    }

    for (final question in candidate.pendingQuestions) {
      changes.add(
        StrategyVersionChange(
          kind: StrategyVersionChangeKind.pending,
          area: '资料确认',
          title: '待确认问题',
          after: question,
        ),
      );
    }
    for (final issue in candidate.compatibilityIssues) {
      changes.add(
        StrategyVersionChange(
          kind: issue.blocking
              ? StrategyVersionChangeKind.conflict
              : StrategyVersionChangeKind.modified,
          area: '规则兼容',
          title: issue.blocking ? '引擎兼容冲突' : '兼容提示',
          after: issue.message,
        ),
      );
    }

    return StrategyVersionDiff(
      fromVersionNumber: baseline?.versionNumber,
      toVersionNumber: candidate.versionNumber,
      changes: List.unmodifiable(changes),
    );
  }

  static void _compareParameters(
    Strategy before,
    Strategy after,
    List<StrategyVersionChange> changes,
  ) {
    void compareValue(String title, Object? oldValue, Object? newValue) {
      if (oldValue == newValue) return;
      changes.add(
        StrategyVersionChange(
          kind: StrategyVersionChangeKind.modified,
          area: '参数',
          title: title,
          before: '$oldValue',
          after: '$newValue',
        ),
      );
    }

    compareValue('策略名称', before.name, after.name);
    compareValue('策略说明', before.description, after.description);
    compareValue('短期均线周期', before.maShortPeriod, after.maShortPeriod);
    compareValue('长期均线周期', before.maLongPeriod, after.maLongPeriod);
    compareValue('布林带周期', before.bollPeriod, after.bollPeriod);
    compareValue('布林带标准差', before.bollStdDev, after.bollStdDev);
    compareValue('均线权重', before.weightMA, after.weightMA);
    compareValue('布林带权重', before.weightBoll, after.weightBoll);
    compareValue('量价权重', before.weightVol, after.weightVol);
    compareValue('趋势权重', before.weightTrend, after.weightTrend);
    compareValue('观察阈值', before.recommendThreshold, after.recommendThreshold);

    final oldFilter = _canonicalJson(before.stockFilter?.toJson());
    final newFilter = _canonicalJson(after.stockFilter?.toJson());
    if (oldFilter != newFilter) {
      changes.add(
        StrategyVersionChange(
          kind: StrategyVersionChangeKind.modified,
          area: '股票范围',
          title: '候选范围条件',
          before: before.stockFilter == null ? '未设置' : '已设置',
          after: after.stockFilter == null ? '未设置' : '条件已调整',
        ),
      );
    }

    compareValue(
      '入场条件组数量',
      before.entryGroups?.length ?? 0,
      after.entryGroups?.length ?? 0,
    );
    compareValue(
      '退出条件组数量',
      before.exitGroups?.length ?? 0,
      after.exitGroups?.length ?? 0,
    );
  }

  static void _compareRules(
    Strategy before,
    Strategy after,
    List<StrategyVersionChange> changes,
  ) {
    final oldRules = _flattenRules(before);
    final newRules = _flattenRules(after);
    final usedOld = <int>{};

    for (final newRule in newRules) {
      var match = -1;
      for (var index = 0; index < oldRules.length; index++) {
        if (!usedOld.contains(index) && oldRules[index].key == newRule.key) {
          match = index;
          break;
        }
      }
      if (match < 0) {
        changes.add(
          StrategyVersionChange(
            kind: StrategyVersionChangeKind.added,
            area: newRule.scopeLabel,
            title: newRule.indicatorLabel,
            after: _describeRule(newRule.rule),
          ),
        );
        continue;
      }

      usedOld.add(match);
      final oldRule = oldRules[match];
      if (_canonicalJson(oldRule.rule.toJson()) ==
          _canonicalJson(newRule.rule.toJson())) {
        continue;
      }
      changes.add(
        StrategyVersionChange(
          kind: _isOpposite(oldRule.rule.condition, newRule.rule.condition)
              ? StrategyVersionChangeKind.conflict
              : StrategyVersionChangeKind.modified,
          area: newRule.scopeLabel,
          title: newRule.indicatorLabel,
          before: _describeRule(oldRule.rule),
          after: _describeRule(newRule.rule),
        ),
      );
    }

    for (var index = 0; index < oldRules.length; index++) {
      if (usedOld.contains(index)) continue;
      final oldRule = oldRules[index];
      changes.add(
        StrategyVersionChange(
          kind: StrategyVersionChangeKind.removed,
          area: oldRule.scopeLabel,
          title: oldRule.indicatorLabel,
          before: _describeRule(oldRule.rule),
        ),
      );
    }
  }

  static List<_ScopedRule> _flattenRules(Strategy strategy) {
    final result = <_ScopedRule>[];

    void addRules(
      String scope,
      List<SignalRule>? flat,
      List<RuleGroup>? groups,
    ) {
      if (groups != null && groups.isNotEmpty) {
        for (final group in groups) {
          for (final rule in group.rules) {
            result.add(_ScopedRule(scope, rule));
          }
        }
        return;
      }
      for (final rule in flat ?? const <SignalRule>[]) {
        result.add(_ScopedRule(scope, rule));
      }
    }

    addRules('entry', strategy.entryRules, strategy.entryGroups);
    addRules('exit', strategy.exitRules, strategy.exitGroups);
    return result;
  }

  static bool _isOpposite(String before, String after) {
    const pairs = {
      'gt': 'lt',
      'lt': 'gt',
      'above': 'below',
      'below': 'above',
      'cross_up': 'cross_down',
      'cross_down': 'cross_up',
      'cross_up_confirmed': 'cross_down_confirmed',
      'cross_down_confirmed': 'cross_up_confirmed',
      'indicator_cross_up': 'indicator_cross_down',
      'indicator_cross_down': 'indicator_cross_up',
    };
    return pairs[before] == after;
  }

  static String _describeRule(SignalRule rule) {
    final condition = switch (rule.condition) {
      'gt' || 'above' => '高于',
      'lt' || 'below' => '低于',
      'cross_up' => '向上穿越',
      'cross_down' => '向下穿越',
      'cross_up_confirmed' => '向上穿越并确认',
      'cross_down_confirmed' => '向下穿越并确认',
      'indicator_cross_up' => '向上穿越另一指标',
      'indicator_cross_down' => '向下穿越另一指标',
      'in_range' => '位于区间',
      _ => rule.condition,
    };
    final range = rule.value2 == null
        ? _formatNumber(rule.value)
        : '${_formatNumber(rule.value)}～${_formatNumber(rule.value2!)}';
    final confirmation = rule.confirmationDays > 1
        ? '，连续 ${rule.confirmationDays} 个交易日确认'
        : '';
    return '$condition $range$confirmation';
  }

  static String _formatNumber(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  static String _canonicalJson(Object? value) => jsonEncode(value);
}

class _ScopedRule {
  final String scope;
  final SignalRule rule;

  const _ScopedRule(this.scope, this.rule);

  String get key => '$scope|${rule.indicator}|${rule.indicator2 ?? ''}';
  String get scopeLabel => scope == 'entry' ? '观察条件' : '退出条件';
  String get indicatorLabel => switch (rule.indicator) {
    'price_ma_short' => '价格与短期均线',
    'price_ma_long' => '价格与长期均线',
    'market_environment' => '趋势环境',
    'ladder_breakout' => '梯级平台突破',
    'ladder_support_gap_pct' => '梯级平台支撑距离',
    'chan_third_buy' => '简化缠论三买结构',
    'chan_center_support_gap_pct' => '简化中枢上沿距离',
    'ma_short' => '短期均线',
    'ma_long' => '长期均线',
    'rsi' => 'RSI',
    'macd' => 'MACD',
    'kdj' => 'KDJ',
    'volume_ratio' => '量比',
    _ => rule.indicator,
  };
}
