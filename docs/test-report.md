# 测试报告 — 股势 TrendStock 2.1

> 2026-10-19 发布补充：本次 v0.1.7 验证与分批提测以 [发布说明](releases/v0.1.7.md) 和 [提测清单](releases/v0.1.7-qa.md) 为准。下文保留历史阶段记录。

执行日期：2026-10-09

测试环境：macOS、Flutter 3.41.5、Dart 3.11.3

本次范围：第一至第六阶段回归 + 第七阶段候选策略版本治理

---

## 1. 执行结论

第七阶段“候选策略版本治理”已经完成。策略详情可进入版本页，查看相对前一版本的新增、删除、修改、冲突和待确认差异；阻塞项会禁止启用，相反规则需用户二次确认。正式启用会事务化归档原活跃版本、更新当前策略快照，并保留旧版本及其回测归属。任意版本均可带入回测配置页。第六阶段行业热点与自定义筛选同时完成回归，新增热点数据源仍不影响原有推荐、搜索、详情和 K 线链路。

| 检查项 | 结果 | 结论 |
|---|---|---|
| `flutter analyze` | No issues found | 通过 |
| 第一阶段聚焦测试 | 16 项通过，0 失败 | 通过 |
| 第二阶段新增测试 | 15 项通过，0 失败 | 通过 |
| 第三阶段新增测试 | 19 项通过，0 失败 | 通过 |
| 第四阶段新增测试 | 13 项通过，0 失败 | 通过 |
| 第四阶段聚焦回归 | 48 项通过，0 失败 | 通过 |
| 第五阶段新增/扩展测试 | 19 项通过，0 失败 | 通过 |
| 第六阶段热点聚焦回归 | 31 项通过，0 失败 | 通过 |
| 行业热点数据源聚焦回归 | 63 项通过，0 失败 | 通过 |
| 候选版本治理聚焦回归 | 16 项通过，0 失败 | 通过 |
| 临时真实网络冒烟（仓库外） | 5,223 只行情、83 个行业、6 根日 K | 通过 |
| `flutter test --coverage` | 530 项通过，0 失败 | 通过 |
| 非生成代码行覆盖率 | 54.1%（7,356 / 13,590） | 达到 50% 基础线，尚未达到 60% 全局目标 |
| `git diff --check` | 无空白错误 | 通过 |

覆盖率排除了 `*.g.dart`。测试项总数以 Flutter 测试运行器本次输出为准。

## 2. 本次功能验证

| 测试 ID | 功能 | 验证结果 | 自动化证据 |
|---|---|---|---|
| T-F017-1 | 个股详情操作栏吸顶 | 返回、关注/取消关注、下跌预警位于固定的 `SliverAppBar` 中 | `test/widget/stock_detail_page_test.dart` |
| T-F017-2 | 搜索结果双向切换 | 同一股票可关注后再次取消；状态与本地服务同步 | `test/provider/watchlist_provider_test.dart` |
| T-F018-1 | 推荐指标说明气泡 | 启用策略、平均命中率、策略信号热度均存在说明文案 | `test/widget_test.dart` |
| T-F012-1 | 策略资料导入 | 策略包版本、字段、来源引用、观察式文案和预览页面通过校验 | `test/unit/strategy_knowledge_package_test.dart`、`test/widget/strategy_import_page_test.dart` |
| T-F015-1 | 不可变版本 | 新导入生成草稿，补充材料生成候选版本且不覆盖当前策略 | `test/unit/strategy_knowledge_service_test.dart` |
| T-F015-2 | 来源追溯与隐私 | 每条规则关联来源；重复来源复用；脱敏正文默认不保存 | `test/unit/strategy_knowledge_service_test.dart` |
| T-F015-3 | 数据库迁移 | schema v1、v4、v5 均可连续升级至 v6 | `test/unit/database_migration_v5_test.dart` |
| T-F015-4 | 候选版本治理 | 五类差异、冲突二次确认、阻塞拦截、事务化启用与版本回测入口均通过 | `test/unit/strategy_version_diff_test.dart`、`test/unit/strategy_knowledge_service_test.dart`、`test/widget/strategy_version_history_page_test.dart` |
| T-F016-1 | 个股策略分析状态 | 无策略、无匹配、样本不足、数据不足和计算失败分别展示 | `test/unit/strategy_analysis_state_test.dart`、`test/widget/signal_card_widget_test.dart` |
| T-F016-2 | 多日确认状态机 | 首日等待、次交易日触发、失效、重新触发及等于均线中性语义通过 | `test/unit/multi_day_rule_engine_test.dart` |
| T-F016-3 | 趋势环境过滤 | 横盘阻断、上涨趋势放行，过滤结果进入规则进度 | `test/unit/multi_day_rule_engine_test.dart` |
| T-F016-4 | 推荐与详情一致性 | 评分服务和详情分析复用统一规则结果，严格匹配不再只看分数阈值 | `test/unit/multi_day_rule_engine_test.dart` |
| T-F016-5 | 回测一致性 | 入场、退出交易日与统一规则引擎的触发位置一致 | `test/unit/multi_day_rule_engine_test.dart` |
| T-F012-3 | 可执行策略包 | 导入包可携带多日与环境规则；声明可执行但缺少映射时拒绝导入 | `test/unit/strategy_knowledge_package_test.dart`、`test/unit/strategy_knowledge_service_test.dart` |
| T-F011-1 | 版本化回测快照 | 报告绑定策略版本、配置、前复权、费用、滑点、数据截止时间和行情指纹并持久化 | `test/unit/backtest_report_test.dart`、`test/unit/strategy_backtest_service_test.dart`、`test/provider/backtest_provider_test.dart` |
| T-F011-2 | 新旧版本比较 | 同输入才比较；参数或行情不同则拒绝归因；少于 20 笔时提示样本不足 | `test/unit/backtest_report_test.dart`、`test/provider/backtest_provider_test.dart`、`test/widget/backtest_result_page_test.dart` |
| T-F011-3 | 个股一键回测 | 策略分析卡提供入口并将当前股票、市场和策略版本带入配置页 | `test/widget/signal_card_widget_test.dart`、`test/widget/backtest_config_page_test.dart` |
| T-F019-1 | 板块榜单 | 行业板块可按成交额、成交量、换手率、涨跌幅和量能异动排序，稳定破同分并截取前十；概念入口明确不可用 | `test/unit/hotspot_ranking_engine_test.dart`、`test/widget/hotspot_tab_test.dart` |
| T-F019-2 | 默认龙头方案 | 成交额前 30%、换手率、量比、近 5 日相对强度和有效交易天数均进入过滤与可解释评分 | `test/unit/hotspot_ranking_engine_test.dart`、`test/unit/hotspot_service_test.dart` |
| T-F019-3 | 默认热点方案 | 成交额前 40%、量比、换手率和振幅同时生效，并区分上涨、下跌与冲高回落 | `test/unit/hotspot_ranking_engine_test.dart` |
| T-F019-4 | 缓存与异常状态 | 七天内最后有效板块/成分股快照可降级展示；无成分股、无匹配和真实错误互不混淆 | `test/unit/hotspot_service_test.dart`、`test/provider/hotspot_provider_test.dart`、`test/widget/hotspot_tab_test.dart` |
| T-F019-5 | 板块字段解析 | 成交额、振幅、换手率、量比、市场等热点必需字段按固定响应解析 | `test/unit/stock_models_test.dart` |
| T-F019-6 | 行业热点备用数据链路 | 打包行业快照覆盖 5,000+ A 股；聚合、成分股、覆盖不足停止生成、专用 K 线缓存和概念板块不可用提示均通过 | `test/unit/industry_aggregated_hotspot_source_test.dart`、`test/unit/cached_stock_api_service_test.dart`、`test/widget/hotspot_tab_test.dart` |
| T-F020-1 | 自定义条件与排序 | AND、组内 AND/组间 OR、阈值、缺字段、权重方向和返回数量按确定性规则执行 | `test/unit/hotspot_ranking_engine_test.dart`、`test/unit/hotspot_filter_scheme_test.dart` |
| T-F020-2 | 方案持久化与版本 | 创建、编辑、启停、复制、恢复默认、运行记录和版本历史保持独立语义 | `test/unit/hotspot_scheme_repository_test.dart` |
| T-F020-3 | 热点页方案联动 | 仅可选择当前类型下已启用方案；管理与编辑页明确草稿、停用和当前板块范围 | `test/provider/hotspot_provider_test.dart`、`test/widget/hotspot_tab_test.dart`、`test/widget/hotspot_scheme_pages_test.dart` |

补充说明：原“市场情绪”数值目前只根据推荐数量和高分策略信号推导，不足以代表全市场环境。本次将显示名称校正为“策略信号热度”，说明气泡明确计算依据。待接入全市场涨跌家数、指数趋势和量能后，再评估恢复“市场情绪”。

## 3. 回归结果

全量测试覆盖了分析引擎、股票模型、行情缓存、关注服务、策略规则、策略来源与版本数据库、回测、热点筛选、Provider 和关键 Widget。所有测试通过，未发现四入口导航、热点数据模型或缓存服务导致的既有功能回归。

本次新增或强化的自动化保护：

- 关注状态新增明确的 `added / removed / failed` 结果，避免界面猜测操作结果。
- 取消关注后重新加载状态，搜索结果和关注列表使用同一数据源。
- 详情页吸顶栏具有稳定 Key，测试直接校验 `pinned` 属性和三个关键操作入口。
- 推荐摘要卡的说明文案可由语义查找验证。
- Agent 策略包含有不存在的来源引用、未来格式版本或“买入/稳赚”等直接指令时会被拒绝。
- 有待确认项或阻塞兼容项的草稿无法启用；完整草稿仍需用户手动启用。
- 候选版本已可按前一版本检视五类差异；相反规则不会静默覆盖，阻塞项无法被确认操作绕过。
- 正式启用后旧活跃版本归档，当前策略快照切换到目标版本，原有启停和默认属性不会丢失。
- 新增三张本地表保存来源、版本及二者关系；从旧 schema 跨版本升级已有自动化保护。
- 多日规则按交易日 K 线计数，不按自然日计数；缺周末或节假日不会打断确认。
- 收盘价等于均线时既不视为站上也不视为跌破，避免边界误触发。
- 推荐、详情、回测均由统一入口计算；规则型策略的推荐匹配以规则真实触发为准。
- 策略卡展示符合度、最多三条规则进度、版本号与样本状态，并保留“仅供观察与复盘”提示。
- 回测 Provider 已覆盖“选择版本 → 获取固定行情 → 运行 → 保存报告 → 查找其他版本基线 → 比较”的完整链路。
- 报告 JSON 已验证可恢复配置、指标、交易明细及无亏损时的无限盈亏比。
- 行情任一价格变化都会改变指纹，避免把不同数据批次的收益差异错误归因于策略版本。
- 龙头与热点采用不同过滤和权重；百分位、并列排序、风险警示/退市排除、前 N 截断均由纯领域测试保护。
- 热点页不会把“接口失败”“板块无成分股”“有成分股但无匹配”“近 5 日历史不足”合并为同一个空态。
- 近 5 日补数仅对选中板块高成交候选执行，并将并发限制为 4，避免首屏拉取全部板块成分股历史。
- 新增热点模块从 BaoStock 行业关系快照与新浪完整沪深 A 股行情生成行业榜单；匹配不足 1,000 只时拒绝输出可能失真的结果。
- 热点短周期 K 线直接使用专用新浪入口并复用本地缓存，没有改变其他功能的既有数据源选择和回退顺序。
- 概念板块入口保持可见但禁用，并明确提示“待接入稳定数据源”，不会把行业分类冒充概念板块。
- 自定义方案配置和运行元数据保存在本机 SharedPreferences；规则修改形成递增版本快照，单方案最多保留 30 条历史。
- 编辑保存会将方案设为停用；无效配置仍可作为草稿保存，但启用操作会再次执行完整校验。
- 热点页不会展示目标类型不一致或未启用的自定义方案；系统默认方案保持独立且只读。

## 4. 覆盖率观察

| 范围 | 行覆盖率 | 评价 |
|---|---:|---|
| 全部非生成代码 | 54.1% | 达到 50% 基础线，未达到 60% 全局目标 |
| `features/hotspot/domain` | 92.0% | 良好；默认与自定义筛选核心均高覆盖 |
| `features/hotspot/data` | 94.2% | 良好；行业聚合、缓存与方案持久化均有保护 |
| `features/hotspot/presentation` | 57.6% | 核心状态与页面骨架已覆盖，操作分支仍可补充 |
| `features/analysis/domain` | 85.9% | 良好 |
| `features/watchlist` | 76.1% | 良好 |
| `features/recommendation` | 71.6% | 较好 |
| `features/strategy/domain` | 80.4% | 良好；版本差异 83.8%、回测引擎 96.1% |
| `features/strategy/data` | 78.8% | 较好；策略服务 88.6%、数据库 92.6% |
| `features/strategy/presentation` | 31.4% | 版本历史页 70.7%，其他大型页面仍低 |
| `features/stock/presentation` | 37.9% | 详情页分支仍需补充 |

更完整的风险与补测顺序见 `docs/test-coverage-assessment.md`。

## 5. 已知问题与未完成验证

- 聚焦 Widget 测试出现 Drift 的多数据库实例调试提示；测试均正常关闭数据库且不影响结果。后续可统一测试数据库注入，减少噪声。
- 尚未在真实设备上验证吸顶滚动的视觉阴影、安全区、鼠标悬停和移动端长按手感。
- 真实东方财富行业板块和板块成分股接口在当前验证网络仍持续返回 HTTP 502，事实已按 `KI-DATA-001` 保留。行业热点已由备用链路规避，并在 2026-10-09 的真实网络验证中拉取 5,223 只行情、聚合 83 个行业板块；概念板块仍缺少稳定来源，是该问题剩余影响。关闭条件见 [已知问题记录](known-issues.md#ki-data-001东方财富板块及成分股数据源不可用)。
- 当前测试只能证明交互结构与状态逻辑正确，不能证明策略收益或市场预测有效。
- App 本身不做聊天文字识别、OCR 或大模型推理；去噪和脱敏由外部 Agent 按复制出的规范完成。
- 候选版本差异、冲突确认和正式启用已实现；当前冲突识别聚焦可结构化判定的相反规则，人物观点语义冲突仍需外部 Agent 整理成规则或待确认项。
- 趋势环境过滤首版按单只股票短期均线斜率和收盘位置判断，不等同于指数或全市场环境。
- “首次站上”的首版语义为：只在穿越后的指定确认交易日触发；确认失败后必须先回到另一侧并再次穿越，才开启新的确认窗口。
- 当前回测固定使用前复权、最多 500 根日 K 和单只股票；尚不支持用户切换复权方式、组合级回测或更长数据区间。
- 报告会本地保存并在本次结果页自动寻找另一版本基线，但尚无独立的历史报告列表与手动选择任意两份报告的页面。
- 20 笔完成交易只是产品级样本门槛，不代表统计显著性，更不能证明未来收益。
- 板块接口不提供上市日期，默认“排除上市不足 60 个交易日”首版未应用，页面已明确提示；不能把它描述为已执行。
- 启用策略匹配分尚未接入，自定义编辑器已禁用该指标；全市场、关注列表、上市天数和市值范围也尚未实现。当前自定义方案只在所选板块成分股内运行。

## 6. 下一阶段质量要求

完成第七阶段候选版本治理后，应优先补充：

1. 全市场与关注列表范围的数据编排、限流、缓存和性能测试。
2. 策略匹配分与统一规则引擎的联动，确保推荐、详情、回测和热点语义一致。
3. 上市天数、市值等依赖新增字段的解析、缺字段和兼容性测试。
4. 真实设备上的新浪全量分页限频、字段变化、非交易日日期、缓存提示和 BaoStock 周快照更新验证。
5. 独立回测历史列表、任意同输入报告选择与失败状态测试。

结论：第一至第七阶段当前约定范围的代码、自动化质量门槛和行业热点真实数据链路已经通过。`KI-DATA-001` 不再阻塞行业热点，但概念板块仍待稳定数据源；全市场/关注列表、策略匹配和依赖额外行情字段的筛选属于后续增强，因此仍不能把全部后续规划描述为完成。
