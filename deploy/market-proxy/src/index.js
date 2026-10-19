const sources = {
  'eastmoney-push': {
    origin: 'https://push2delay.eastmoney.com',
    paths: ['/api/qt/clist/get', '/api/qt/stock/get'],
    ttl: 15,
  },
  'eastmoney-history': {
    origin: 'https://push2his.eastmoney.com',
    paths: ['/api/qt/stock/kline/get'],
    ttl: 300,
  },
  'eastmoney-search': {
    origin: 'https://searchapi.eastmoney.com',
    paths: ['/api/suggest/get'],
    ttl: 60,
  },
  'eastmoney-news': {
    origin: 'https://search-api-web.eastmoney.com',
    paths: ['/search/jsonp'],
    ttl: 300,
  },
  'eastmoney-f10': {
    origin: 'https://emweb.securities.eastmoney.com',
    paths: [
      '/PC_HSF10/CompanySurvey/PageAjax',
      '/PC_HSF10/NewFinanceAnalysis/ZYZBAjaxNew',
    ],
    ttl: 21600,
    referer: 'https://emweb.securities.eastmoney.com/',
  },
  'sina-market': {
    origin: 'https://vip.stock.finance.sina.com.cn',
    paths: ['/quotes_service/api/json_v2.php/Market_Center.getHQNodeData'],
    ttl: 15,
    referer: 'https://finance.sina.com.cn/',
  },
  'sina-quote': {
    origin: 'https://hq.sinajs.cn',
    pathPattern: /^\/list=(sh|sz)\d{6}$/,
    ttl: 15,
    referer: 'https://finance.sina.com.cn/',
  },
  'sina-kline': {
    origin: 'https://quotes.sina.cn',
    pathPattern:
      /^\/cn\/api\/jsonp_v2\.php\/[^/]{1,100}\/CN_MarketDataService\.getKLineData$/,
    ttl: 300,
    referer: 'https://finance.sina.com.cn/',
  },
  'tencent-quote': {
    origin: 'https://qt.gtimg.cn',
    pathPattern:
      /^\/q=(hk\d{5}|us[A-Za-z0-9.-]{1,16})(,(hk\d{5}|us[A-Za-z0-9.-]{1,16})){0,31}$/,
    ttl: 15,
  },
  'tencent-kline': {
    origin: 'https://web.ifzq.gtimg.cn',
    paths: [
      '/appstock/app/usfqkline/get',
      '/appstock/app/hkfqkline/get',
    ],
    ttl: 300,
  },
};

const corsHeaders = {
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Max-Age': '86400',
};

function jsonError(message, status, origin = '*') {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': origin,
      ...corsHeaders,
    },
  });
}

function allowedOrigin(request, configuredOrigins) {
  const origin = request.headers.get('Origin');
  if (!origin || configuredOrigins === '*') return '*';
  const allowed = configuredOrigins
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
  return allowed.includes(origin) ? origin : null;
}

function isAllowedPath(config, path) {
  return config.paths?.includes(path) || config.pathPattern?.test(path);
}

function hasSafeQuery(url) {
  if (url.toString().length > 4096 || [...url.searchParams].length > 30) {
    return false;
  }
  for (const [key, value] of url.searchParams) {
    if (!/^[A-Za-z0-9_]+$/.test(key) || value.length > 1600) return false;
  }
  return true;
}

export async function handleRequest(request, env = {}, fetchImpl = fetch) {
  const origin = allowedOrigin(request, env.ALLOWED_ORIGINS || '*');
  if (!origin) return jsonError('Origin not allowed', 403);
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: { 'Access-Control-Allow-Origin': origin, ...corsHeaders },
    });
  }
  if (request.method !== 'GET') {
    return jsonError('Method not allowed', 405, origin);
  }

  const incoming = new URL(request.url);
  const match = incoming.pathname.match(/^\/v1\/([^/]+)(\/.*)$/);
  if (!match) return jsonError('Unknown proxy route', 404, origin);

  const config = sources[match[1]];
  const upstreamPath = match[2];
  if (!config || !isAllowedPath(config, upstreamPath) || !hasSafeQuery(incoming)) {
    return jsonError('Upstream route not allowed', 400, origin);
  }

  const upstream = new URL(upstreamPath, config.origin);
  upstream.search = incoming.search;
  const headers = new Headers({
    Accept: request.headers.get('Accept') || '*/*',
    'User-Agent': 'Mozilla/5.0 (compatible; TrendStock/1.0)',
  });
  if (config.referer) headers.set('Referer', config.referer);

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10000);
  let response;
  try {
    response = await fetchImpl(upstream.toString(), {
      headers,
      signal: controller.signal,
      cf: { cacheEverything: true, cacheTtl: config.ttl },
    });
  } catch (error) {
    const timedOut = error?.name === 'AbortError';
    return jsonError(timedOut ? 'Upstream timeout' : 'Upstream unavailable', 502, origin);
  } finally {
    clearTimeout(timeout);
  }

  const responseHeaders = new Headers(response.headers);
  responseHeaders.set('Access-Control-Allow-Origin', origin);
  responseHeaders.set('Vary', 'Origin');
  responseHeaders.set('Cache-Control', `public, max-age=${config.ttl}`);
  for (const [key, value] of Object.entries(corsHeaders)) {
    responseHeaders.set(key, value);
  }
  responseHeaders.delete('Set-Cookie');

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: responseHeaders,
  });
}

export default {
  fetch(request, env) {
    return handleRequest(request, env);
  },
};
