const Map<String, String> marketDataProxySources = {
  'push2.eastmoney.com': 'eastmoney-push',
  'push2delay.eastmoney.com': 'eastmoney-push',
  'push2his.eastmoney.com': 'eastmoney-history',
  'searchapi.eastmoney.com': 'eastmoney-search',
  'search-api-web.eastmoney.com': 'eastmoney-news',
  'emweb.securities.eastmoney.com': 'eastmoney-f10',
  'vip.stock.finance.sina.com.cn': 'sina-market',
  'hq.sinajs.cn': 'sina-quote',
  'quotes.sina.cn': 'sina-kline',
  'qt.gtimg.cn': 'tencent-quote',
  'web.ifzq.gtimg.cn': 'tencent-kline',
};

String rewriteMarketDataUrl(String upstreamUrl, String proxyBaseUrl) {
  final base = proxyBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  if (base.isEmpty) return upstreamUrl;

  final upstream = Uri.parse(upstreamUrl);
  final source = marketDataProxySources[upstream.host];
  if (source == null) {
    throw ArgumentError.value(upstream.host, 'upstreamUrl', '不支持的行情域名');
  }

  final proxy = Uri.parse('$base/v1/$source${upstream.path}');
  return proxy.replace(query: upstream.query).toString();
}
