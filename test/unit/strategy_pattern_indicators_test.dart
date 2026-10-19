import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/features/strategy/domain/rule_engine.dart';
import 'package:stockpilot/features/strategy/domain/strategy_pattern_indicators.dart';
import 'package:stockpilot/features/strategy/domain/strategy_presets.dart';

DailyKline _bar(
  int index,
  double close, {
  double? high,
  double? low,
  double volume = 100000,
}) {
  return DailyKline(
    date: DateTime(2025, 1, 1).add(Duration(days: index)),
    open: close,
    close: close,
    high: high ?? close + 0.1,
    low: low ?? close - 0.1,
    volume: volume,
    amount: close * volume,
  );
}

List<DailyKline> _ladderBars({bool breakSupport = false}) {
  final closes = <double>[
    ...List.generate(10, (i) => 10 + (i.isEven ? -0.1 : 0.1)),
    ...List.generate(10, (i) => 10.4 + i * 0.12),
    ...List.generate(10, (i) => 12 + (i.isEven ? -0.1 : 0.1)),
    breakSupport ? 11.5 : 12.5,
  ];
  return List.generate(
    closes.length,
    (index) => _bar(
      index,
      closes[index],
      volume: index == closes.length - 1 ? 180000 : 100000,
    ),
  );
}

List<DailyKline> _chanBars({bool reentersCentre = false}) {
  final bars = <DailyKline>[];
  for (var i = 0; i < 24; i++) {
    bars.add(_bar(i, i.isEven ? 10.2 : 11.8));
  }
  for (var i = 0; i < 10; i++) {
    bars.add(_bar(24 + i, 12.6 + i * 0.15));
  }
  bars.add(_bar(34, 13.2, low: 12.6));
  bars.add(_bar(35, 13.0, low: 12.4));
  bars.add(
    _bar(36, reentersCentre ? 11.7 : 12.8, low: reentersCentre ? 11.6 : 12.3),
  );
  return bars;
}

void main() {
  group('StrategyPatternIndicators ladder', () {
    test('recognises a compact higher platform breakout', () {
      final snapshot = StrategyPatternIndicators.ladder(_ladderBars());

      expect(snapshot, isNotNull);
      expect(snapshot!.breakout, 1);
      expect(snapshot.supportGapPct, greaterThan(0));
      expect(snapshot.latestPlatformWidthPct, lessThanOrEqualTo(10));
    });

    test('marks a close below the latest platform as support failure', () {
      final snapshot = StrategyPatternIndicators.ladder(
        _ladderBars(breakSupport: true),
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.breakout, 0);
      expect(snapshot.supportGapPct, lessThan(0));
    });

    test('returns null before the full structural window exists', () {
      expect(
        StrategyPatternIndicators.ladder(_ladderBars().take(30).toList()),
        isNull,
      );
    });
  });

  group('StrategyPatternIndicators simplified Chan structure', () {
    test('recognises upward departure followed by pullback above centre', () {
      final snapshot = StrategyPatternIndicators.simplifiedChanThirdBuy(
        _chanBars(),
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.thirdBuy, 1);
      expect(snapshot.centreUpper, greaterThan(snapshot.centreLower));
      expect(snapshot.centreSupportGapPct, greaterThan(0));
    });

    test('rejects a pullback that re-enters the centre', () {
      final snapshot = StrategyPatternIndicators.simplifiedChanThirdBuy(
        _chanBars(reentersCentre: true),
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.thirdBuy, 0);
      expect(snapshot.centreSupportGapPct, lessThan(0));
    });

    test('returns null before the full structural window exists', () {
      expect(
        StrategyPatternIndicators.simplifiedChanThirdBuy(
          _chanBars().take(36).toList(),
        ),
        isNull,
      );
    });
  });

  test(
    'built-in structural presets evaluate through the shared rule engine',
    () {
      final now = DateTime(2026, 1, 1);
      final ladder = StrategyPresets.ladderPlatformBreakout(
        id: 'ladder',
        now: now,
      );
      final chan = StrategyPresets.simplifiedChanThirdBuy(id: 'chan', now: now);

      final ladderResult = RuleEngine.evaluateStrategy(
        klines: _ladderBars(),
        strategy: ladder,
      );
      final chanResult = RuleEngine.evaluateStrategy(
        klines: _chanBars(),
        strategy: chan,
      );

      expect(ladderResult.indicatorValues['ladder_breakout'], 1);
      expect(ladderResult.entryTriggered, isTrue);
      expect(chanResult.indicatorValues['chan_third_buy'], 1);
      expect(chanResult.entryTriggered, isTrue);
    },
  );
}
