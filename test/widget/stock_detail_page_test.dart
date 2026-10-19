import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/core/theme/app_theme.dart';
import 'package:stockpilot/features/stock/data/kline_cache.dart';
import 'package:stockpilot/features/stock/data/stock_api_service.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/features/stock/presentation/stock_detail_page.dart';
import 'package:stockpilot/features/stock/presentation/widgets/stock_fundamentals_card.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/shared/providers.dart';

class _StockDetailApiService extends StockApiService {
  @override
  Future<List<DailyKline>> fetchStockKline(
    String stockCode, {
    String market = 'SH',
    int days = 120,
  }) async {
    return List.generate(80, (index) {
      final price = 20 + index * 0.1;
      return DailyKline(
        date: DateTime(2026, 1, 1).add(Duration(days: index)),
        open: price - 0.05,
        close: price,
        high: price + 0.1,
        low: price - 0.1,
        volume: 100000 + index * 1000,
        amount: 2000000 + index * 10000,
        preClose: index == 0 ? price - 0.05 : 20 + (index - 1) * 0.1,
      );
    });
  }

  @override
  Future<List<StockNews>> fetchStockNews(
    String stockCode, {
    int page = 1,
    int pageSize = 10,
  }) async => const [];

  @override
  Future<StockFundamentals?> fetchStockFundamentals(
    String stockCode, {
    required String stockName,
    String market = StockMarket.sh,
  }) async {
    return const StockFundamentals(
      code: '002472',
      name: '双环传动',
      companyName: '浙江双环传动机械股份有限公司',
      board: '深交所主板A股',
      sector: '交运设备-汽车-汽车零部件',
      industry: '制造业-汽车制造业',
      businessSummary: '专注于齿轮及其部组件的研发、制造与销售。',
      marketPosition: '公司资料称其为全球专业齿轮制造领军企业。',
      peDynamic: 31.2,
      pbRatio: 3.1,
      marketCap: 320,
      reportName: '2026中报',
      revenue: 4558950064.86,
      netProfit: 586654329.98,
      revenueYoy: 7.8,
      netProfitYoy: 1.65,
      grossMargin: 26.77,
      roe: 5.67,
      debtRatio: 46.29,
    );
  }
}

void main() {
  testWidgets('T-F017-1: 个股详情操作栏保持吸顶', (tester) async {
    final appDb = AppDatabase.forTesting(NativeDatabase.memory());
    final cacheDb = KlineCacheDatabase.forTesting(NativeDatabase.memory());
    addTearDown(appDb.close);
    addTearDown(cacheDb.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockApiServiceProvider.overrideWithValue(_StockDetailApiService()),
          appDatabaseProvider.overrideWithValue(appDb),
          klineCacheProvider.overrideWithValue(cacheDb),
        ],
        child: const MaterialApp(
          home: StockDetailPage(code: '002472', name: '双环传动', market: 'SZ'),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    final appBar = tester.widget<SliverAppBar>(
      find.byKey(const ValueKey('stock-detail-pinned-actions')),
    );
    expect(appBar.pinned, true);
    expect(find.byKey(const ValueKey('stock-detail-back')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('stock-detail-watch-toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('stock-detail-alert-toggle')),
      findsOneWidget,
    );
    expect(find.text('下跌预警'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-F017-2: 公司速览展示主营、业绩与阶段观察', (tester) async {
    final klines = List.generate(80, (index) {
      final price = 20 + index * 0.1;
      return DailyKline(
        date: DateTime(2026, 1, 1).add(Duration(days: index)),
        open: price,
        close: price,
        high: price,
        low: price,
        volume: 100000,
        amount: 2000000,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StockFundamentalsCard(
              fundamentals: const StockFundamentals(
                code: '002472',
                name: '双环传动',
                companyName: '浙江双环传动机械股份有限公司',
                board: '深交所主板A股',
                sector: '交运设备-汽车-汽车零部件',
                businessSummary: '专注于齿轮及其部组件的研发、制造与销售。',
                marketPosition: '公司资料称其为全球专业齿轮制造领军企业。',
                peDynamic: 31.2,
                marketCap: 320,
                reportName: '2026中报',
                revenue: 4558950064.86,
                netProfit: 586654329.98,
                revenueYoy: 7.8,
                netProfitYoy: 1.65,
                grossMargin: 26.77,
                roe: 5.67,
                debtRatio: 46.29,
              ),
              klines: klines,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('stock-fundamentals-card')),
      findsOneWidget,
    );
    expect(find.text('公司速览'), findsOneWidget);
    expect(find.text('主营业务'), findsOneWidget);
    expect(find.text('营业收入'), findsOneWidget);
    expect(find.textContaining('当前阶段', findRichText: true), findsOneWidget);
    expect(find.textContaining('增长空间', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
