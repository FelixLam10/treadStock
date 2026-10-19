# TrendStock PWA 部署手册

## 1. 架构

- `build/web/`：Flutter PWA 静态文件，可部署到任意 HTTPS 静态托管。
- `deploy/market-proxy/`：Cloudflare Worker 行情代理，不保存用户数据。
- Web 构建通过 `MARKET_PROXY_BASE_URL` 指向代理；macOS 客户端仍直接访问行情源。

本地开发可在项目根目录一条命令同时启动行情代理和 Flutter Web：

```bash
./dev-web.sh
```

默认访问 `http://127.0.0.1:4173`。按 `r` 热重载，按 `q` 或 `Ctrl+C`
退出；由脚本启动的行情代理也会一并关闭。

## 2. 部署行情代理

Cloudflare 免费账号即可运行当前无状态 Worker。首次部署前：

```bash
cd deploy/market-proxy
npm install
npx wrangler login
```

把 `wrangler.toml` 中的 `ALLOWED_ORIGINS` 改为最终 PWA HTTPS 域名。多个域名用
英文逗号分隔，不要在线上保留 `*`。

```bash
npm test
npm run deploy
```

部署完成后记录 Worker 地址，例如：

```text
https://trendstock-market-proxy.<account>.workers.dev
```

代理仅允许项目使用的固定 GET 路由，不接受任意上游 URL。行情快照缓存 15 秒，
搜索缓存 60 秒，K 线和资讯缓存 5 分钟。

## 3. 构建 PWA

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release --no-tree-shake-icons \
  --dart-define=MARKET_PROXY_BASE_URL=https://trendstock-market-proxy.<account>.workers.dev
```

构建产物位于 `build/web/`。不要把本地 `127.0.0.1:8787` 地址用于正式构建。

## 4. 静态托管

将 `build/web/` 作为站点根目录部署到支持 HTTPS 的静态托管。必须满足：

- 所有路径回退到 `index.html`，保证刷新深链时仍能进入 Flutter Router。
- `.wasm` 使用 `application/wasm` MIME 类型。
- `index.html` 与 `flutter_service_worker.js` 不做长期强缓存。
- 带哈希的静态资源可以长期缓存。
- 发布后用 Safari 验证风险提示、推荐、搜索、关注持久化与策略编辑。

Cloudflare Pages 可使用以下设置：

```text
Build command: flutter build web --release --no-tree-shake-icons --dart-define=MARKET_PROXY_BASE_URL=<Worker URL>
Build output directory: build/web
```

`--no-tree-shake-icons` 用于保留完整的 Material Icons 字体，避免不同版本的裁剪字体
共用同一路径后被浏览器或 Service Worker 旧缓存替换成缺字方框。

若托管环境没有 Flutter SDK，可在本机构建后上传 `build/web/`，或后续补 CI 构建。

## 5. iPhone 安装验收

1. 用 Safari 打开正式 HTTPS 地址。
2. 完成风险提示，分别检查 A 股、港股、美股推荐。
3. 搜索“澜起”和 `DRAM`，确认市场代码正确。
4. Safari 分享菜单选择“添加到主屏幕”。
5. 从主屏幕启动，确认以独立窗口打开。
6. 添加关注、修改策略后彻底关闭，再次启动确认本地数据仍存在。

PWA、Mac App 和不同 iPhone 的本地数据彼此独立，当前没有云同步。

推荐候选行情会按 A 股、港股、美股分别在设备本地保留最近一次有效快照，最长
使用 7 天。上游临时不可用时，应用会明确显示“缓存数据”和原始更新时间；缓存
不会被标记为实时行情，也不会在不同市场之间复用。

## 6. 发布与回滚

- 每次发布前运行 `flutter analyze`、`flutter test` 和 Worker 的 `npm test`。
- 保留上一次 `build/web/` 产物或托管平台部署版本。
- 若新版本异常，先回滚静态站点；代理变更独立回滚。
- 行情代理日志不得记录完整用户关注列表、策略参数或设备标识。
