import 'signal_card.dart';

enum StrategyAnalysisStatus {
  noEnabledStrategy,
  noMatch,
  insufficientSample,
  matched,
  insufficientData,
  calculationError,
}

class StrategyAnalysisState {
  final StrategyAnalysisStatus status;
  final String title;
  final String message;

  const StrategyAnalysisState({
    required this.status,
    required this.title,
    required this.message,
  });

  static StrategyAnalysisState resolve({
    required int enabledStrategyCount,
    required List<SignalCard> cards,
    String? error,
  }) {
    if (error != null) {
      return StrategyAnalysisState(
        status: StrategyAnalysisStatus.calculationError,
        title: '计算失败',
        message: error,
      );
    }
    if (enabledStrategyCount == 0) {
      return const StrategyAnalysisState(
        status: StrategyAnalysisStatus.noEnabledStrategy,
        title: '暂无启用策略',
        message: '启用一条策略后，这里会展示该股票的规则进度、适用环境和复盘样本。',
      );
    }
    if (cards.isEmpty) {
      return const StrategyAnalysisState(
        status: StrategyAnalysisStatus.noMatch,
        title: '当前没有匹配策略',
        message: '策略计算正常，但当前股票没有满足完整规则；这不是系统异常。',
      );
    }
    if (cards.every(
      (card) =>
          card.resultStatus == StrategyAnalysisResultStatus.insufficientData,
    )) {
      return const StrategyAnalysisState(
        status: StrategyAnalysisStatus.insufficientData,
        title: '行情数据不足',
        message: '当前日 K 数量不足以完成规则计算，数据补齐后可重新判断。',
      );
    }

    final matched = cards.where(
      (card) => card.resultStatus == StrategyAnalysisResultStatus.matched,
    );
    if (matched.isEmpty) {
      return const StrategyAnalysisState(
        status: StrategyAnalysisStatus.noMatch,
        title: '当前没有匹配策略',
        message: '策略计算正常，但当前股票没有满足完整规则；这不是系统异常。',
      );
    }
    if (matched.any(
      (card) => card.sampleStatus != StrategySampleStatus.reviewable,
    )) {
      return const StrategyAnalysisState(
        status: StrategyAnalysisStatus.insufficientSample,
        title: '策略符合，但复盘样本不足',
        message: '当前规则已符合；历史有效样本少于 20 条，不展示策略优劣结论。',
      );
    }
    return const StrategyAnalysisState(
      status: StrategyAnalysisStatus.matched,
      title: '策略规则符合',
      message: '当前规则已符合，可结合版本、样本和风险信息继续观察。',
    );
  }
}
