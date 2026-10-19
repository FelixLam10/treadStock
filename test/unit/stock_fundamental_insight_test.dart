import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/stock/domain/stock_fundamental_insight.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  group('buildGrowthInsight', () {
    test('营收利润同时增长时返回稳步增长', () {
      const fundamentals = StockFundamentals(
        code: '002472',
        name: '双环传动',
        revenueYoy: 7.8,
        netProfitYoy: 1.65,
      );

      expect(buildGrowthInsight(fundamentals).label, '稳步增长');
    });

    test('增收不增利时明确提示利润承压', () {
      const fundamentals = StockFundamentals(
        code: '000001',
        name: '样例',
        revenueYoy: 8,
        netProfitYoy: -3,
      );

      final insight = buildGrowthInsight(fundamentals);
      expect(insight.label, '增收不增利');
      expect(insight.summary, contains('利润承压'));
    });
  });

  group('buildMarketStageInsight', () {
    test('现价和均线多头排列时判断趋势上行', () {
      final klines = List.generate(80, (index) {
        final close = 10 + index * 0.1;
        return DailyKline(
          date: DateTime(2026, 1, 1).add(Duration(days: index)),
          open: close,
          close: close,
          high: close,
          low: close,
          volume: 1,
          amount: 1,
        );
      });

      expect(buildMarketStageInsight(klines).label, '趋势上行');
    });

    test('不足60个交易日不作阶段判断', () {
      expect(buildMarketStageInsight(const []).label, '样本不足');
    });
  });
}
