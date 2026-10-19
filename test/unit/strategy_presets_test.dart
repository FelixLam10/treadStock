import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/domain/strategy_presets.dart';

void main() {
  final validIndicators = {
    'rsi',
    'macd',
    'macd_signal',
    'macd_hist',
    'k',
    'd',
    'j',
    'boll_position',
    'ma_alignment',
    'vol_price_divergence',
    'vol_ratio',
    'ma_short',
    'ma_long',
    'price_ma_short',
    'price_ma_long',
    'market_environment',
    'ladder_breakout',
    'ladder_support_gap_pct',
    'chan_third_buy',
    'chan_center_support_gap_pct',
  };
  final validConditions = {
    'lt',
    'gt',
    'in_range',
    'cross_up',
    'cross_down',
    'indicator_cross_up',
    'indicator_cross_down',
    'above',
    'below',
    'cross_up_confirmed',
    'cross_down_confirmed',
    'uptrend',
    'downtrend',
    'sideways',
    'not_sideways',
  };

  List<Strategy> makePresets() => StrategyPresets.all(
    idGenerator: () => 'test-id',
    now: DateTime(2026, 1, 1),
  );

  test('all() returns exactly 12 presets', () {
    expect(makePresets().length, 12);
  });

  test('all presets have non-empty name and description', () {
    for (final preset in makePresets()) {
      expect(preset.name, isNotEmpty);
      expect(preset.description, isNotEmpty);
    }
  });

  test('all presets have non-empty entryRules', () {
    for (final preset in makePresets()) {
      expect(preset.entryRules, isNotNull);
      expect(
        preset.entryRules!,
        isNotEmpty,
        reason: '${preset.name} should have entry rules',
      );
    }
  });

  test('all presets have exitRules', () {
    for (final preset in makePresets()) {
      expect(
        preset.exitRules,
        isNotNull,
        reason: '${preset.name} should have exit rules',
      );
      expect(
        preset.exitRules!,
        isNotEmpty,
        reason: '${preset.name} should have non-empty exit rules',
      );
    }
  });

  test('all rules have valid indicator and condition values', () {
    for (final preset in makePresets()) {
      final allRules = [...?preset.entryRules, ...?preset.exitRules];
      for (final rule in allRules) {
        expect(
          validIndicators,
          contains(rule.indicator),
          reason: '${preset.name}: invalid indicator "${rule.indicator}"',
        );
        expect(
          validConditions,
          contains(rule.condition),
          reason: '${preset.name}: invalid condition "${rule.condition}"',
        );
      }
    }
  });

  test('all presets have unique names', () {
    final names = makePresets().map((p) => p.name).toList();
    expect(
      names.toSet().length,
      names.length,
      reason: 'Preset names should be unique',
    );
  });

  test('three theory templates are executable rule-based strategies', () {
    final presets = makePresets();
    final names = presets.map((preset) => preset.name).toSet();

    expect(names, contains('梯级平台突破观察'));
    expect(names, contains('均线趋势确认'));
    expect(names, contains('简化缠论三买观察'));
    for (final preset in presets.where(
      (preset) =>
          const {'梯级平台突破观察', '均线趋势确认', '简化缠论三买观察'}.contains(preset.name),
    )) {
      expect(preset.isRuleBased, isTrue, reason: preset.name);
    }
  });
}
