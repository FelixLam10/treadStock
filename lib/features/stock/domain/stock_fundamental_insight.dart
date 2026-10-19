import 'stock_models.dart';

class StockInsight {
  final String label;
  final String summary;

  const StockInsight({required this.label, required this.summary});
}

/// Converts latest reported year-on-year figures into a restrained growth
/// observation. This is descriptive, not a forecast or recommendation.
StockInsight buildGrowthInsight(StockFundamentals? fundamentals) {
  final revenueYoy = fundamentals?.revenueYoy;
  final profitYoy = fundamentals?.netProfitYoy;
  if (revenueYoy == null || profitYoy == null) {
    return const StockInsight(label: '待补充', summary: '公开财报样本不足，暂不判断增长空间。');
  }

  if (revenueYoy >= 15 && profitYoy >= 15) {
    return const StockInsight(
      label: '成长较快',
      summary: '营收和利润均保持较快增长，后续重点观察需求持续性与利润率。',
    );
  }
  if (revenueYoy >= 0 && profitYoy >= 0) {
    return const StockInsight(
      label: '稳步增长',
      summary: '营收和利润仍在增长，未来空间取决于行业景气与业绩兑现。',
    );
  }
  if (revenueYoy >= 0 && profitYoy < 0) {
    return const StockInsight(
      label: '增收不增利',
      summary: '收入增长但利润承压，需观察成本、费用和毛利率改善。',
    );
  }
  if (revenueYoy < 0 && profitYoy >= 0) {
    return const StockInsight(
      label: '利润改善',
      summary: '收入尚未恢复但利润改善，需确认改善是否具备持续性。',
    );
  }
  return const StockInsight(
    label: '短期承压',
    summary: '营收和利润同比回落，增长空间需等待需求或经营拐点验证。',
  );
}

/// Describes the current price/MA structure using at least 60 daily samples.
StockInsight buildMarketStageInsight(List<DailyKline>? klines) {
  if (klines == null || klines.length < 60) {
    return const StockInsight(label: '样本不足', summary: '至少需要60个交易日数据才能判断趋势阶段。');
  }

  final closes = klines.map((item) => item.close).toList();
  final price = closes.last;
  final ma20 = _average(closes.sublist(closes.length - 20));
  final ma60 = _average(closes.sublist(closes.length - 60));

  if (price > ma20 && ma20 > ma60) {
    return const StockInsight(
      label: '趋势上行',
      summary: '现价位于MA20、MA60上方，且短期均线高于中期均线。',
    );
  }
  if (price < ma20 && ma20 < ma60) {
    return const StockInsight(
      label: '调整阶段',
      summary: '现价位于MA20、MA60下方，短期走势仍偏弱。',
    );
  }
  if (price >= ma20 && ma20 <= ma60) {
    return const StockInsight(label: '修复阶段', summary: '现价重回短期均线上方，但中期趋势仍待确认。');
  }
  return const StockInsight(label: '震荡整理', summary: '短中期均线信号不一致，当前更接近区间整理。');
}

double _average(List<double> values) =>
    values.reduce((left, right) => left + right) / values.length;
