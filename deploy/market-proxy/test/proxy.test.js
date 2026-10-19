import test from 'node:test';
import assert from 'node:assert/strict';
import { handleRequest } from '../src/index.js';

test('handles CORS preflight', async () => {
  const response = await handleRequest(
    new Request('https://proxy.example/v1/eastmoney-push/api/qt/stock/get', {
      method: 'OPTIONS',
      headers: { Origin: 'https://stocks.example' },
    }),
    { ALLOWED_ORIGINS: 'https://stocks.example' },
  );

  assert.equal(response.status, 204);
  assert.equal(
    response.headers.get('Access-Control-Allow-Origin'),
    'https://stocks.example',
  );
});

test('rejects routes outside the upstream allowlist', async () => {
  const response = await handleRequest(
    new Request('https://proxy.example/v1/eastmoney-push/private'),
  );
  assert.equal(response.status, 400);
});

test('forwards an allowed route and preserves query parameters', async () => {
  let forwardedUrl;
  const response = await handleRequest(
    new Request(
      'https://proxy.example/v1/eastmoney-history/api/qt/stock/kline/get?secid=116.06809&lmt=120',
      { headers: { Origin: 'https://stocks.example' } },
    ),
    { ALLOWED_ORIGINS: '*' },
    async (url) => {
      forwardedUrl = url;
      return new Response('{"data":{}}', {
        headers: { 'Content-Type': 'application/json' },
      });
    },
  );

  assert.equal(
    forwardedUrl,
    'https://push2his.eastmoney.com/api/qt/stock/kline/get?secid=116.06809&lmt=120',
  );
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('Access-Control-Allow-Origin'), '*');
  assert.equal(response.headers.get('Cache-Control'), 'public, max-age=300');
});

test('does not allow arbitrary request methods', async () => {
  const response = await handleRequest(
    new Request('https://proxy.example/v1/eastmoney-push/api/qt/stock/get', {
      method: 'POST',
    }),
  );
  assert.equal(response.status, 405);
});

test('forwards the allowlisted company profile route', async () => {
  let forwardedUrl;
  const response = await handleRequest(
    new Request(
      'https://proxy.example/v1/eastmoney-f10/PC_HSF10/CompanySurvey/PageAjax?code=SZ002472',
    ),
    { ALLOWED_ORIGINS: '*' },
    async (url, options) => {
      forwardedUrl = url;
      assert.equal(
        options.headers.get('Referer'),
        'https://emweb.securities.eastmoney.com/',
      );
      return new Response('{"jbzl":[]}', {
        headers: { 'Content-Type': 'application/json' },
      });
    },
  );

  assert.equal(
    forwardedUrl,
    'https://emweb.securities.eastmoney.com/PC_HSF10/CompanySurvey/PageAjax?code=SZ002472',
  );
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('Cache-Control'), 'public, max-age=21600');
});
