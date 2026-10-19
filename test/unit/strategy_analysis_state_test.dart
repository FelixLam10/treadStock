import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/signal_card.dart';
import 'package:stockpilot/features/strategy/domain/strategy_analysis_state.dart';

SignalCard _card({
  StrategyAnalysisResultStatus result = StrategyAnalysisResultStatus.noMatch,
  StrategySampleStatus sample = StrategySampleStatus.none,
}) {
  return SignalCard(
    stockCode: '600000',
    stockName: '示例股票',
    strategyId: 'strategy-1',
    strategyName: '示例策略',
    type: result == StrategyAnalysisResultStatus.matched
        ? SignalType.entry
        : SignalType.neutral,
    strength: result == StrategyAnalysisResultStatus.matched
        ? SignalStrength.strong
        : SignalStrength.none,
    headline: '状态测试',
    detail: '',
    highlights: const [],
    suggestion: '',
    ruleResults: const {},
    indicatorValues: const {},
    evaluatedAt: DateTime(2026, 1, 1),
    resultStatus: result,
    sampleStatus: sample,
  );
}

void main() {
  group('T-F016-1: 个股策略分析状态', () {
    test('没有启用策略', () {
      final state = StrategyAnalysisState.resolve(
        enabledStrategyCount: 0,
        cards: const [],
      );
      expect(state.status, StrategyAnalysisStatus.noEnabledStrategy);
    });

    test('有策略但当前股票无匹配', () {
      final state = StrategyAnalysisState.resolve(
        enabledStrategyCount: 1,
        cards: [_card()],
      );
      expect(state.status, StrategyAnalysisStatus.noMatch);
      expect(state.message, contains('不是系统异常'));
    });

    test('策略符合但历史复盘样本不足', () {
      final state = StrategyAnalysisState.resolve(
        enabledStrategyCount: 1,
        cards: [
          _card(
            result: StrategyAnalysisResultStatus.matched,
            sample: StrategySampleStatus.insufficient,
          ),
        ],
      );
      expect(state.status, StrategyAnalysisStatus.insufficientSample);
      expect(state.message, contains('少于 20 条'));
    });

    test('真实计算异常', () {
      final state = StrategyAnalysisState.resolve(
        enabledStrategyCount: 1,
        cards: const [],
        error: '策略计算失败，请稍后重试',
      );
      expect(state.status, StrategyAnalysisStatus.calculationError);
      expect(state.title, '计算失败');
    });

    test('数据不足与不匹配混合时不会误判为符合', () {
      final state = StrategyAnalysisState.resolve(
        enabledStrategyCount: 2,
        cards: [
          _card(),
          _card(result: StrategyAnalysisResultStatus.insufficientData),
        ],
      );
      expect(state.status, StrategyAnalysisStatus.noMatch);
    });
  });
}
