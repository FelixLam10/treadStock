import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/stock/data/market_data_proxy_url.dart';
import 'package:stockpilot/features/stock/data/stock_api_service.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  group('rewriteMarketDataUrl', () {
    test('未配置代理时保持上游地址不变', () {
      const url = 'https://push2.eastmoney.com/api/qt/stock/get';
      expect(rewriteMarketDataUrl(url, ''), url);
    });

    test('保留路径和查询参数并映射白名单源', () {
      const url =
          'https://push2his.eastmoney.com/api/qt/stock/kline/get?secid=116.06809&lmt=120';

      expect(
        rewriteMarketDataUrl(url, 'https://market.example.com/'),
        'https://market.example.com/v1/eastmoney-history/api/qt/stock/kline/get?secid=116.06809&lmt=120',
      );
    });

    test('拒绝不在白名单中的上游域名', () {
      expect(
        () => rewriteMarketDataUrl(
          'https://example.com/private',
          'https://market.example.com',
        ),
        throwsArgumentError,
      );
    });

    test('映射东方财富公司资料接口', () {
      const url =
          'https://emweb.securities.eastmoney.com/PC_HSF10/CompanySurvey/PageAjax?code=SZ002472';
      expect(
        rewriteMarketDataUrl(url, 'https://market.example.com'),
        'https://market.example.com/v1/eastmoney-f10/PC_HSF10/CompanySurvey/PageAjax?code=SZ002472',
      );
    });
  });

  test('解析腾讯批量港股行情并按涨幅排序', () {
    const body =
        'v_hk00700="100~腾讯控股~00700~600.00~590.00~592.00~1000~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~10.00~1.69~605.00~588.00";'
        'v_hk06809="100~澜起科技~06809~100.00~101.00~102.00~500~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~-1.00~-0.99~103.00~98.00";';

    final quotes = parseTencentMarketQuotes(
      body,
      market: StockMarket.hk,
      universe: const {'00700': '腾讯控股', '06809': '澜起科技'},
    );

    expect(quotes, hasLength(2));
    expect(quotes.first.code, '00700');
    expect(quotes.first.name, '腾讯控股');
    expect(quotes.first.market, StockMarket.hk);
    expect(quotes.first.changePct, 1.69);
    expect(quotes.last.code, '06809');
  });

  test('腾讯美股代码移除交易所后缀并恢复候选名称', () {
    const body =
        'v_usDRAM="200~Roundhill Memory ETF~DRAM.AM~60.01~59.52~59.80~1000~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0~0.49~0.82~60.20~59.10";';

    final quotes = parseTencentMarketQuotes(
      body,
      market: StockMarket.us,
      universe: const {'DRAM': 'Roundhill Memory ETF'},
    );

    expect(quotes.single.code, 'DRAM');
    expect(quotes.single.name, 'Roundhill Memory ETF');
    expect(quotes.single.fullCode, 'DRAM.US');
  });
}
