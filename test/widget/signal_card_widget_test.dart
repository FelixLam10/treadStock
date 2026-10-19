import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/signal_card.dart';
import 'package:stockpilot/features/strategy/presentation/widgets/signal_card_widget.dart';

void main() {
  testWidgets('T-F016-1: 不匹配与样本不足使用独立文案', (tester) async {
    var backtestOpened = false;
    final card = SignalCard(
      stockCode: '600000',
      stockName: '示例股票',
      strategyId: 'strategy-1',
      strategyName: '五日均线确认',
      type: SignalType.neutral,
      strength: SignalStrength.none,
      headline: '示例股票 暂无信号触发',
      detail: '当前规则没有匹配。',
      highlights: const [],
      suggestion: '继续观察。',
      ruleResults: const {'entry:MA5': false},
      indicatorValues: const {},
      evaluatedAt: DateTime(2026, 1, 1),
      ruleProgress: const ['第 1 日站上均线，等待下一交易日确认'],
      resultStatus: StrategyAnalysisResultStatus.noMatch,
      sampleStatus: StrategySampleStatus.insufficient,
      sampleCount: 6,
      strategyVersion: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignalCardWidget(
            card: card,
            onTap: () => backtestOpened = true,
          ),
        ),
      ),
    );

    expect(find.textContaining('不符合'), findsOneWidget);
    expect(find.textContaining('等待下一交易日确认'), findsOneWidget);
    expect(find.textContaining('策略 v2'), findsOneWidget);
    expect(find.textContaining('复盘样本不足（6/20）'), findsOneWidget);
    expect(find.textContaining('仅供观察与复盘'), findsOneWidget);
    expect(find.text('用当前股票回测'), findsOneWidget);

    await tester.tap(find.byKey(const Key('signal-card-backtest')));
    expect(backtestOpened, isTrue);
  });
}
