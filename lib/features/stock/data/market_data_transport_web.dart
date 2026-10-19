import 'market_data_proxy_url.dart';

const String marketProxyBaseUrl = String.fromEnvironment(
  'MARKET_PROXY_BASE_URL',
);

String marketDataUrl(String upstreamUrl) =>
    rewriteMarketDataUrl(upstreamUrl, marketProxyBaseUrl);
