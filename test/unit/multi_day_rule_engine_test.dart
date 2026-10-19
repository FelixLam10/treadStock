import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/analysis/domain/analysis_engine.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/features/strategy/domain/decision_signal_engine.dart';
import 'package:stockpilot/features/strategy/domain/backtest_engine.dart';
import 'package:stockpilot/features/strategy/domain/backtest_models.dart';
import 'package:stockpilot/features/strategy/domain/rule_engine.dart';
import 'package:stockpilot/features/strategy/domain/signal_card.dart';
import 'package:stockpilot/features/strategy/domain/signal_rule.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/domain/strategy_scoring_service.dart';

List<DailyKline> _klines(List<double> closes) {
  return List.generate(closes.length, (index) {
    final close = closes[index];
    return DailyKline(
      date: DateTime(2026, 1, 1).add(Duration(days: index * 2)),
      open: close,
      close: close,
      high: close + 0.2,
      low: close - 0.2,
      volume: 100000,
      amount: close * 100000,
      preClose: index == 0 ? 0 : closes[index - 1],
    );
  });
}

const _confirmedUp = SignalRule(
  indicator: 'price_ma_short',
  condition: 'cross_up_confirmed',
  value: 0,
  confirmationDays: 2,
);

const _confirmedDown = SignalRule(
  indicator: 'price_ma_short',
  condition: 'cross_down_confirmed',
  value: 0,
  confirmationDays: 2,
);

Strategy _strategy({List<SignalRule>? entryRules}) {
  return Strategy(
    id: 'ma-confirm',
    name: 'MA 两日确认',
    maShortPeriod: 3,
    maLongPeriod: 3,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    entryRules: entryRules ?? const [_confirmedUp],
    exitRules: const [_confirmedDown],
  );
}

void main() {
  group('T-F016-2: 多日均线确认状态机', () {
    test('首次站上后处于等待下一交易日确认', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12]),
        strategy: _strategy(),
      );

      expect(result.entryTriggered, isFalse);
      expect(
        result.entryDetails.single.state,
        RuleProgressState.waitingConfirmation,
      );
      expect(result.entryDetails.single.message, contains('第 1 日'));
    });

    test('第二个交易日仍站上时只在确认日触发', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 12]),
        strategy: _strategy(),
      );

      expect(result.entryTriggered, isTrue);
      expect(result.entryDetails.single.state, RuleProgressState.triggered);

      final later = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 12, 12]),
        strategy: _strategy(),
      );
      expect(later.entryTriggered, isFalse);
      expect(
        later.entryDetails.single.state,
        RuleProgressState.waitingRetrigger,
      );
    });

    test('确认前跌回均线下方会失效', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 9]),
        strategy: _strategy(),
      );

      expect(result.entryTriggered, isFalse);
      expect(result.entryDetails.single.state, RuleProgressState.invalidated);
    });

    test('失效后重新穿越会开启新的确认窗口', () {
      final waiting = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 9, 12]),
        strategy: _strategy(),
      );
      final confirmed = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 9, 12, 12]),
        strategy: _strategy(),
      );

      expect(
        waiting.entryDetails.single.state,
        RuleProgressState.waitingConfirmation,
      );
      expect(confirmed.entryTriggered, isTrue);
    });

    test('连续两个交易日跌破时触发退出观察信号', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 12, 8, 8]),
        strategy: _strategy(),
      );

      expect(result.exitTriggered, isTrue);
      expect(result.exitDetails.single.state, RuleProgressState.triggered);
    });

    test('收盘价等于均线既不算站上也不算跌破', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 10, 10]),
        strategy: _strategy(),
      );

      expect(result.entryTriggered, isFalse);
      expect(result.exitTriggered, isFalse);
    });

    test('按交易日序列确认，不受自然日缺口影响', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines([10, 10, 10, 12, 12]),
        strategy: _strategy(),
      );

      expect(result.entryTriggered, isTrue);
    });
  });

  group('T-F016-3: 趋势环境过滤', () {
    const environment = SignalRule(
      indicator: 'market_environment',
      condition: 'uptrend',
      value: 0.15,
      lookbackDays: 5,
    );

    test('短期均线斜率处于阈值内时判定横盘并暂停信号', () {
      final result = RuleEngine.evaluateStrategy(
        klines: _klines(List.filled(20, 10)),
        strategy: _strategy(entryRules: const [environment]),
      );

      expect(result.entryTriggered, isFalse);
      expect(
        result.entryDetails.single.state,
        RuleProgressState.environmentBlocked,
      );
      expect(result.entryDetails.single.message, contains('横盘震荡'));
    });

    test('短期均线斜率超过阈值且价格在均线上方时通过', () {
      final closes = List.generate(20, (index) => 10 + index * 0.3);
      final result = RuleEngine.evaluateStrategy(
        klines: _klines(closes),
        strategy: _strategy(entryRules: const [environment]),
      );

      expect(result.entryTriggered, isTrue);
      expect(result.entryDetails.single.state, RuleProgressState.matched);
      expect(result.indicatorValues['market_environment'], 1);
    });
  });

  test('T-F016-4: 评分与详情信号使用同一策略执行结果', () {
    final klines = _klines([
      ...List.filled(15, 10.0),
      10.0,
      10.0,
      10.0,
      12.0,
      12.0,
    ]);
    final strategy = _strategy();
    final ruleResult = RuleEngine.evaluateStrategy(
      klines: klines,
      strategy: strategy,
    );
    final score = AnalysisEngine().calculateScoreForStrategy(klines, strategy);
    final scoreResult = StrategyScoringService(AnalysisEngine()).scoreStock(
      quote: const StockQuote(
        code: '600000',
        name: '示例股票',
        market: 'SH',
        price: 12,
        changePct: 0,
        changeAmt: 0,
        openPrice: 12,
        highPrice: 12,
        lowPrice: 12,
        preClose: 12,
        volume: 100000,
        turnover: 1,
      ),
      klines: klines,
      strategy: strategy,
    );
    final card = DecisionSignalEngine.evaluate(
      klines: klines,
      strategy: strategy,
      stockCode: '600000',
      stockName: '示例股票',
    );

    expect(ruleResult.entryTriggered, isTrue);
    expect(score.score, 9);
    expect(scoreResult.isMatched, isTrue);
    expect(card.type, SignalType.entry);
    expect(card.resultStatus, StrategyAnalysisResultStatus.matched);
  });

  test('T-F016-5: 回测使用相同的两日确认进入与退出结果', () {
    final result = BacktestEngine().run(
      klines: _klines([10, 10, 10, 12, 12, 12, 8, 8]),
      strategy: _strategy(),
      config: const BacktestConfig(warmupBars: 3),
      stockCode: '600000',
      analysisEngine: AnalysisEngine(),
    );

    expect(result.trades, hasLength(1));
    expect(result.trades.single.entryBarIndex, 4);
    expect(result.trades.single.exitBarIndex, 7);
    expect(result.trades.single.exitReason, ExitReason.signalExit);
  });
}
