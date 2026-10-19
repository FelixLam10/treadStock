import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_service.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('打包的 BaoStock 行业关系快照可读取且覆盖主要 A 股', () async {
    final catalog = BaoStockIndustryCatalog();

    final memberships = await catalog.load();

    expect(memberships.length, greaterThan(5000));
    expect(memberships['000001'], '货币金融服务');
    expect(memberships['600000'], '货币金融服务');
  });

  test('按 BaoStock 行业关系聚合现有全市场行情并返回成分股', () async {
    final source = IndustryAggregatedHotspotRemoteSource(
      catalog: BaoStockIndustryCatalog(
        loadSnapshot: () async =>
            '{"stocks":{"600001":"电子","600002":"电子","000001":"银行"}}',
      ),
      minimumMappedQuotes: 1,
      fetchQuotes: () async => [
        _quote('600001', '甲', amount: 300, changePct: 3),
        _quote('600002', '乙', amount: 100, changePct: -1),
        _quote(
          '000001',
          '丙',
          market: StockMarket.sz,
          amount: 200,
          changePct: 2,
        ),
      ],
      fetchKlines: (_, _) async => const [],
    );

    final boards = await source.fetchSectors(concept: false);
    final electronics = boards.singleWhere((item) => item.name == '电子');
    final constituents = await source.fetchConstituents(electronics.code);

    expect(boards, hasLength(2));
    expect(electronics.amount, 400);
    expect(electronics.changePct, closeTo(2, 0.001));
    expect(constituents.map((item) => item.code), ['600001', '600002']);
    expect(constituents.first.volumeRatio, 2);
  });

  test('行情覆盖不足时不生成可能失真的热点榜单', () async {
    final source = IndustryAggregatedHotspotRemoteSource(
      catalog: BaoStockIndustryCatalog(
        loadSnapshot: () async => '{"stocks":{"600001":"电子"}}',
      ),
      minimumMappedQuotes: 2,
      fetchQuotes: () async => [_quote('600001', '甲', amount: 100)],
      fetchKlines: (_, _) async => const [],
    );

    expect(
      () => source.fetchSectors(concept: false),
      throwsA(
        isA<HotspotSourceException>().having(
          (error) => error.message,
          'message',
          contains('覆盖不足'),
        ),
      ),
    );
  });

  test('概念板块在没有稳定来源时返回明确状态', () async {
    final source = IndustryAggregatedHotspotRemoteSource(
      catalog: BaoStockIndustryCatalog(
        loadSnapshot: () async => '{"stocks":{"600001":"电子"}}',
      ),
      minimumMappedQuotes: 1,
      fetchQuotes: () async => [_quote('600001', '甲', amount: 100)],
      fetchKlines: (_, _) async => const [],
    );

    expect(
      () => source.fetchSectors(concept: true),
      throwsA(
        isA<HotspotSourceException>().having(
          (error) => error.message,
          'message',
          contains('概念板块'),
        ),
      ),
    );
  });
}

StockQuote _quote(
  String code,
  String name, {
  String market = StockMarket.sh,
  required double amount,
  double changePct = 1,
}) {
  return StockQuote(
    code: code,
    name: name,
    market: market,
    price: 10,
    changePct: changePct,
    changeAmt: changePct / 10,
    openPrice: 9.8,
    highPrice: 10.2,
    lowPrice: 9.7,
    preClose: 9.9,
    volume: 100,
    turnover: 5,
    amount: amount,
    amplitude: 4,
    volumeRatio: 2,
  );
}
