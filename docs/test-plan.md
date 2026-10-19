# 测试计划 — 股势 TrendStock 2.1

更新时间：2026-10-09

适用范围：现有基线能力 + 2.1 策略沉淀、策略演进、交互优化与热点观察方案

---

## 1. 测试目标

本计划用于验证：

- 推荐、关注、个股详情、策略管理、回测与复盘等既有能力不回归。
- 详情页吸顶操作栏、搜索关注双向切换、推荐指标说明气泡符合交互与金融文案要求。
- 策略导入、来源追溯、不可变版本、版本差异、冲突启用、规则状态机和版本化回测使用同一套确定性领域逻辑。
- 龙头股与热点股使用可解释、可复现的筛选条件，并正确处理空结果、数据不足、缓存和接口失败。

不以“测试数量”代替需求覆盖率；每个功能按场景、状态与风险判定是否达到发布门槛。

## 2. 当前增量测试矩阵

| 测试 ID | 功能 | 核心场景 | 测试文件 | 类型 | 状态 |
|---|---|---|---|---|---|
| T-F017-1 | 个股详情操作栏 | 返回、关注/取消关注、下跌预警所在栏吸顶 | `test/widget/stock_detail_page_test.dart` | Widget | 已实现，通过 |
| T-F017-2 | 搜索关注双向切换 | 未关注时关注，再次操作取消关注并同步状态 | `test/provider/watchlist_provider_test.dart` | Provider/服务集成 | 已实现，通过 |
| T-F018-1 | 推荐指标说明 | 启用策略、平均命中率、策略信号热度均有说明气泡 | `test/widget_test.dart` | Widget | 已实现，通过 |
| T-F012-1 | 策略包导入 | 合法策略包进入预览，不直接启用；非法引用和直接投资指令被拦截 | `test/unit/strategy_knowledge_package_test.dart`、`test/widget/strategy_import_page_test.dart` | 领域/Widget | 已实现，通过 |
| T-F012-2 | 文本沉淀 | Agent 整理规范要求去噪、脱敏、保留失效条件与待确认项；App 校验结构 | `test/unit/strategy_knowledge_package_test.dart` | 领域 | 首版完成；App 不做 NLP |
| T-F015-1 | 策略版本 | 增量材料创建候选版本，不覆盖当前策略；普通编辑也形成连续快照 | `test/unit/strategy_knowledge_service_test.dart` | 服务/数据库 | 已实现，通过 |
| T-F015-2 | 来源追溯 | 规则定位到脱敏来源摘要，重复来源复用；正文默认不保存 | `test/unit/strategy_knowledge_service_test.dart` | 服务/数据库 | 已实现，通过 |
| T-F015-3 | 数据库迁移 | schema v1、v4、v5 均可升级到 v6 来源、版本与回测表 | `test/unit/database_migration_v5_test.dart` | 数据库 | 已实现，通过 |
| T-F015-4 | 候选版本治理 | 五类差异、相反规则冲突、阻塞项拦截、二次确认启用及旧版本归档 | `test/unit/strategy_version_diff_test.dart`、`test/unit/strategy_knowledge_service_test.dart`、`test/widget/strategy_version_history_page_test.dart` | 领域/服务/Widget | 已实现，通过 |
| T-F016-1 | 个股策略分析 | 区分无启用策略、无匹配、样本不足、计算失败 | `test/unit/strategy_analysis_state_test.dart`、`test/widget/signal_card_widget_test.dart` | 领域/Widget | 已实现，通过 |
| T-F016-2 | 多日确认状态机 | 首日等待、次交易日确认、失效、重新触发、等于均线中性 | `test/unit/multi_day_rule_engine_test.dart` | 领域 | 已实现，通过 |
| T-F016-3 | 趋势环境过滤 | 横盘阻断、上涨趋势放行、缺少数据不误报 | `test/unit/multi_day_rule_engine_test.dart` | 领域 | 已实现，通过 |
| T-F016-4 | 多入口一致性 | 推荐评分、个股策略分析和统一规则引擎结果一致 | `test/unit/multi_day_rule_engine_test.dart` | 领域 | 已实现，通过 |
| T-F016-5 | 回测规则复用 | 回测入场、退出与统一规则引擎使用相同交易日语义 | `test/unit/multi_day_rule_engine_test.dart` | 领域 | 已实现，通过 |
| T-F011-1 | 版本化回测 | 报告绑定策略版本、配置、复权、费用、行情指纹和数据截止时间 | `test/unit/backtest_report_test.dart`、`test/unit/strategy_backtest_service_test.dart`、`test/provider/backtest_provider_test.dart` | 领域/服务/Provider | 已实现，通过 |
| T-F011-2 | 版本对比 | 只对相同股票、行情指纹、复权和参数比较；样本不足不判断优劣 | `test/unit/backtest_report_test.dart`、`test/provider/backtest_provider_test.dart`、`test/widget/backtest_result_page_test.dart` | 领域/Provider/Widget | 已实现，通过 |
| T-F011-3 | 个股带入回测 | 从策略分析卡进入回测时自动带入股票和当前策略版本 | `test/widget/signal_card_widget_test.dart`、`test/widget/backtest_config_page_test.dart` | Widget | 已实现，通过 |
| T-F019-1 | 默认龙头方案 | 公共过滤、阈值、加权排序和前十结果确定性 | `test/unit/hotspot_ranking_engine_test.dart` | 领域 | 已实现，通过 |
| T-F019-2 | 默认热点方案 | 上涨/下跌异动方向、排序及缺字段处理 | `test/unit/hotspot_ranking_engine_test.dart` | 领域 | 已实现，通过 |
| T-F019-3 | 热点数据降级 | 有缓存刷新失败、无缓存失败、空成分股 | `test/unit/hotspot_service_test.dart`、`test/provider/hotspot_provider_test.dart` | 服务/Provider | 已实现，通过 |
| T-F019-6 | 行业热点备用数据链路 | BaoStock 快照读取、全量行情本地聚合、覆盖不足保护、热点专用 K 线缓存和概念板块不可用提示 | `test/unit/industry_aggregated_hotspot_source_test.dart`、`test/unit/cached_stock_api_service_test.dart`、`test/widget/hotspot_tab_test.dart` | 数据/缓存/Widget | 已实现，通过 |
| T-F020-1 | 自定义筛选 | 全部满足、任意一组满足、权重方向、返回数量和缺字段 | `test/unit/hotspot_ranking_engine_test.dart`、`test/unit/hotspot_filter_scheme_test.dart` | 领域 | 当前板块版已实现，通过 |
| T-F020-2 | 方案版本 | 复制、重命名、启停、恢复默认、版本历史和运行记录 | `test/unit/hotspot_scheme_repository_test.dart` | 数据 | 已实现，通过 |
| T-F020-3 | 方案页面联动 | 热点页选择已启用方案，管理/编辑页展示范围、草稿与启用边界 | `test/provider/hotspot_provider_test.dart`、`test/widget/hotspot_tab_test.dart`、`test/widget/hotspot_scheme_pages_test.dart` | Provider/Widget | 当前板块版已实现，通过 |

## 3. 既有回归范围

| 层级 | 重点 |
|---|---|
| 分析引擎 | 均线、布林带、量比、评分、波段低位、下跌预警、数据不足 |
| 策略领域 | 规则执行、回测、调参、命中统计、复盘、推荐评分 |
| 数据与缓存 | 行情解析、K 线缓存、关注列表、策略数据库及迁移 |
| Provider | 推荐、关注、策略列表/详情/回测的加载、空态、错误态和刷新 |
| Widget | 核心页面可渲染、关键状态文案、交互入口与金融免责声明 |

## 4. 分阶段测试设计

### 第一阶段：交互优化（已完成）

- 吸顶栏在页面加载成功、空日线和错误态下仍存在。
- 未关注股票开启预警时仍执行“先关注”约束。
- 搜索关注与取消关注共用同一状态源；数据库失败时不错误翻转界面状态。
- 推荐页指标说明同时适配桌面悬停和移动端长按。
- 当前算法只反映策略信号活跃度，因此界面使用“策略信号热度”，不冒充全市场情绪。

### 第二阶段：策略导入与版本（首版已完成）

- 已覆盖策略包格式版本、必填字段、枚举、数值边界、来源引用与未来版本拒绝。
- 关键歧义、当前引擎不支持项存在时只能保存草稿，不能启用。
- 新策略、来源、版本和规则关系在同一事务内写入；聊天正文默认不保存。
- 来源指纹去重、规则关联、不可变版本和候选版本不覆盖当前策略已覆盖。
- schema v1、v4、v5 → v6 已验证；候选版本已支持五类差异、冲突二次确认、阻塞项拦截和事务化正式启用。

### 第三阶段：多日规则与策略应用（首版已完成）

- 已实现“首次站上均线 → 次交易日确认”“跌破 → 次交易日未收回”的等待、触发、失效和重新触发状态。
- 已验证等于均线为中性、跨自然日不影响交易日计数、横盘过滤和重新触发窗口。
- 推荐评分、个股详情和回测统一调用 `RuleEngine.evaluateStrategy`，同一策略与 K 线使用相同规则语义。
- 已区分无策略、无匹配、样本不足、数据不足和真实计算错误；策略卡同时展示规则进度、版本和样本状态。
- 趋势过滤首版使用个股短期均线斜率与收盘位置；指数级市场环境和更复杂横盘口径留待后续数据能力扩展。

### 第四阶段：版本化回测与复盘（首版已完成）

- 每次回测选择并绑定不可变策略版本，报告以 schema v6 本地保存，不随策略后续编辑改变。
- 策略版本、前复权、费用、滑点、时间区间、数据截止时间、行情指纹和样本数进入报告快照。
- 版本比较要求股票、行情指纹、复权方式和全部配置一致；不一致时明确拒绝归因到版本变化。
- 任一版本少于 20 笔完成交易时只显示样本不足，不输出策略优劣结论；回测不会自动启用候选版本。
- 个股策略分析卡可一键带入股票和当前策略版本进入回测配置页。
- 首版只支持单股、最多 500 根日 K、前复权；独立历史报告浏览与组合级回测不在本阶段范围。

### 第五阶段：热点默认方案（首版已完成）

- 龙头股和热点股两套默认方案分别验证过滤条件、百分位、权重、稳定排序和前 N 截断。
- 热点必须区分向上与向下异动；“交易频繁”使用换手率等明确指标表达。
- 行业板块使用 BaoStock 行业关系快照与新浪沪深 A 股完整分页行情本地聚合；已验证快照覆盖、聚合、成分股、七天缓存、缓存过期和失败降级。
- 行情与行业关系匹配不足 1,000 只时拒绝生成榜单，避免残缺分页造成失真排名。
- 热点候选的短周期 K 线使用热点专用新浪入口并复用本地缓存；原有推荐、搜索、详情和 K 线数据源保持不变。
- Provider 与 Widget 已区分加载、无成分股、有成分股但无匹配、历史不足和真实错误。
- 四个底部入口已纳入应用 Widget 冒烟；真实设备点击区域与长文案换行仍需手工验收。
- 2026-10-09 真实网络验收拉取 5,223 只沪深 A 股并聚合出 83 个行业板块；行业热点不再被东方财富 HTTP 502 阻塞。
- 概念板块缺少稳定关系源，入口明确禁用并提示待接入；东方财富接口问题仍按 [KI-DATA-001](known-issues.md#ki-data-001东方财富板块及成分股数据源不可用) 跟踪。

第五阶段聚焦回归：

```bash
flutter test test/unit/industry_aggregated_hotspot_source_test.dart test/unit/hotspot_ranking_engine_test.dart test/unit/hotspot_service_test.dart test/unit/cached_stock_api_service_test.dart test/provider/hotspot_provider_test.dart test/widget/hotspot_tab_test.dart test/unit/stock_models_test.dart
```

### 第六阶段：自定义筛选（当前板块首版已完成）

- 已验证 AND、组内 AND/组间 OR、非法阈值、权重归一化与方向、缺字段、零结果和前 5/10/20/30/50 截断。
- 已验证创建、复制、重命名、启停、恢复默认、最近运行记录和最多 30 条本地版本快照。
- 系统默认方案保持只读；用户复制后独立演进。条件不完整时可保存草稿但不能启用，编辑保存后需再次人工确认启用。
- 热点页只列出当前龙头/热点类型下已启用方案，并在所选行业板块成分股内运行；概念板块在接入稳定来源后再开放。
- 全市场、关注列表范围、自然语言自动生成条件、上市天数/市值和策略匹配尚未接入；界面明确禁用或说明，不纳入本阶段通过范围。

### 第七阶段：候选版本治理（已完成）

- 差异计算为纯领域逻辑，覆盖参数、股票池、入场/退出规则、分组规则与待确认项。
- 有待确认或引擎阻塞项时始终禁止启用；仅有相反规则冲突时，用户二次确认后才可继续。
- 启用在同一数据库事务内归档原活跃版本并更新当前快照；关联回测仍绑定原版本。
- 版本页的阻塞状态、差异摘要和指定版本进入回测已纳入 Widget 回归。

第七阶段聚焦回归：

```bash
flutter test test/unit/strategy_version_diff_test.dart test/unit/strategy_knowledge_service_test.dart test/widget/strategy_version_history_page_test.dart test/widget/backtest_config_page_test.dart test/widget/strategy_import_page_test.dart
```

第六阶段聚焦回归：

```bash
flutter test test/unit/hotspot_ranking_engine_test.dart test/unit/hotspot_filter_scheme_test.dart test/unit/hotspot_scheme_repository_test.dart test/unit/hotspot_service_test.dart test/provider/hotspot_provider_test.dart test/widget/hotspot_tab_test.dart test/widget/hotspot_scheme_pages_test.dart
```

## 5. 测试方法与仓库规则

- 领域算法优先写纯 Dart 单元测试，保持确定性，不依赖真实网络。
- 数据服务通过依赖注入使用固定响应，重点测解析、分页、失败和降级。
- Provider 测试负责状态转移；Widget 测试只验证关键可见行为，不重复领域算法。
- 数据库测试使用内存 SQLite，并显式关闭每个数据库实例。
- E2E 仅用于智能助手临时自验，新增脚本和产物放在仓库外，不提交。
- 金融文案不得暗示保证收益；推荐、详情、回测和热点页面保留“仅供参考”说明。

## 6. 执行命令

```bash
flutter analyze
flutter test
flutter test --coverage
```

第一阶段聚焦回归：

```bash
flutter test test/provider/watchlist_provider_test.dart test/widget_test.dart test/widget/stock_detail_page_test.dart
```

第二阶段聚焦回归：

```bash
flutter test test/unit/strategy_knowledge_package_test.dart test/unit/strategy_knowledge_service_test.dart test/unit/database_migration_v5_test.dart test/widget/strategy_import_page_test.dart
```

第三阶段聚焦回归：

```bash
flutter test test/unit/multi_day_rule_engine_test.dart test/unit/strategy_analysis_state_test.dart test/unit/signal_rule_test.dart test/unit/strategy_knowledge_package_test.dart test/unit/strategy_knowledge_service_test.dart test/widget/signal_card_widget_test.dart test/widget/stock_detail_page_test.dart
```

第四阶段聚焦回归：

```bash
flutter test test/unit/backtest_report_test.dart test/unit/strategy_backtest_service_test.dart test/unit/database_migration_v5_test.dart test/unit/backtest_engine_test.dart test/unit/multi_day_rule_engine_test.dart test/provider/backtest_provider_test.dart test/widget/backtest_config_page_test.dart test/widget/backtest_result_page_test.dart test/widget/signal_card_widget_test.dart
```

覆盖率口径：统计 `coverage/lcov.info` 中非生成 `.dart` 文件；排除 `*.g.dart`，不把生成代码覆盖率作为发布门槛。

## 7. 发布门槛

- `flutter analyze` 无错误、无警告。
- 全量自动化测试全部通过，无新增跳过项。
- 新增领域规则的正常、边界、空数据和错误路径都有自动化测试。
- 数据库迁移必须有旧版本升级测试。
- 高风险接口必须验证解析失败、超时、空响应和缓存降级。
- 真实设备完成关键交互与金融文案检查；网络相关功能至少验证一次弱网或失败场景。
- 已知限制写入测试报告，不能用“0% 命中率”代替样本不足，也不能把无匹配显示为系统错误。
