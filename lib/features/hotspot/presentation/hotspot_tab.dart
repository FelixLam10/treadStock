import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/cache_banner.dart';
import '../../../shared/widgets/disclaimer_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/hotspot_filter_scheme.dart';
import '../domain/hotspot_models.dart';
import 'hotspot_provider.dart';

class HotspotTab extends ConsumerStatefulWidget {
  const HotspotTab({super.key});

  @override
  ConsumerState<HotspotTab> createState() => _HotspotTabState();
}

class _HotspotTabState extends ConsumerState<HotspotTab> {
  bool _showWarning = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(hotspotProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hotspotProvider);
    return Scaffold(
      backgroundColor: context.sc.bgSecondary,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _titleBar(state),
            if (_showWarning && state.warning != null)
              CacheBanner(
                message: state.warning!,
                timestamp: state.stocksUpdatedAt != null
                    ? Formatters.formatTime(state.stocksUpdatedAt!)
                    : state.boardsUpdatedAt != null
                    ? Formatters.formatTime(state.boardsUpdatedAt!)
                    : null,
                onClose: () => setState(() => _showWarning = false),
              ),
            Expanded(child: _body(state)),
          ],
        ),
      ),
    );
  }

  Widget _titleBar(HotspotState state) {
    final updatedAt = state.stocksUpdatedAt ?? state.boardsUpdatedAt;
    return Container(
      color: context.sc.bgPrimary,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('热点', style: AppTextStyles.h1),
                const SizedBox(height: 2),
                Text(
                  updatedAt == null ? '按板块发现当日活跃线索' : _dataTimeLabel(updatedAt),
                  style: AppTextStyles.caption.copyWith(
                    color: context.sc.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '刷新热点数据',
            onPressed: state.isLoadingBoards || state.isLoadingStocks
                ? null
                : () {
                    setState(() => _showWarning = true);
                    ref.read(hotspotProvider.notifier).load();
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _body(HotspotState state) {
    if (state.isLoadingBoards && state.boards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.boards.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: '热点数据暂时不可用',
        subtitle: state.error!,
        actionText: '重新加载',
        onAction: () => ref.read(hotspotProvider.notifier).load(),
      );
    }
    if (state.boards.isEmpty) {
      return EmptyState(
        icon: Icons.view_module_outlined,
        title: '暂无板块数据',
        subtitle: '这不代表市场没有热点，请稍后刷新公开行情数据。',
        actionText: '刷新',
        onAction: () => ref.read(hotspotProvider.notifier).load(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(hotspotProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _boardControls(state),
          _boardList(state),
          const SizedBox(height: 10),
          _modeAndScheme(state),
          if (state.isLoadingStocks)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null)
            EmptyState(
              icon: Icons.sync_problem_outlined,
              title: '成分股加载失败',
              subtitle: state.error!,
              actionText: '重试',
              onAction: () {
                final code = state.selectedBoardCode;
                if (code != null) {
                  ref.read(hotspotProvider.notifier).selectBoard(code);
                }
              },
            )
          else if (state.candidates.isEmpty)
            const EmptyState(
              icon: Icons.list_alt_outlined,
              title: '暂无成分股数据',
              subtitle: '板块存在，但公开数据源当前未返回成分股。',
            )
          else if (state.rankedStocks.isEmpty)
            EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title:
                  state.stockMode == HotspotStockMode.leader &&
                      !state.hasHistoryData
                  ? '近 5 日数据不足'
                  : '当前条件下无匹配股票',
              subtitle:
                  state.stockMode == HotspotStockMode.leader &&
                      !state.hasHistoryData
                  ? '龙头观察需要相对强度和活跃天数；可先切换到热点股查看当日异动。'
                  : '这是筛选结果，不代表板块没有活跃股票；可进入方案管理调整条件。',
            )
          else
            ...state.rankedStocks.asMap().entries.map(
              (entry) => _stockCard(entry.key + 1, entry.value, state),
            ),
          const DisclaimerLabel(),
        ],
      ),
    );
  }

  Widget _boardControls(HotspotState state) {
    return Container(
      color: context.sc.bgPrimary,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        8,
      ),
      child: Column(
        children: [
          Row(
            children: HotspotBoardType.values.map((type) {
              final selected = state.boardType == type;
              final available = type == HotspotBoardType.industry;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: available
                      ? 'BaoStock 行业关系快照与全市场行情本地聚合'
                      : '概念板块待接入稳定数据源',
                  child: ChoiceChip(
                    label: Text(type.label),
                    selected: selected,
                    onSelected: available
                        ? (_) => ref
                              .read(hotspotProvider.notifier)
                              .changeBoardType(type)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('板块前十', style: AppTextStyles.h3),
              const Spacer(),
              Text('排序：', style: AppTextStyles.caption),
              DropdownButton<HotspotBoardMetric>(
                value: state.boardMetric,
                underline: const SizedBox.shrink(),
                items: HotspotBoardMetric.values
                    .map(
                      (metric) => DropdownMenuItem(
                        value: metric,
                        enabled: _supportsBoardMetric(state, metric),
                        child: Text(
                          _supportsBoardMetric(state, metric)
                              ? metric.label
                              : '${metric.label}（暂缺）',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (metric) {
                  if (metric != null) {
                    ref
                        .read(hotspotProvider.notifier)
                        .changeBoardMetric(metric);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boardList(HotspotState state) {
    return Container(
      color: context.sc.bgPrimary,
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding,
          0,
          AppTheme.pagePadding,
          12,
        ),
        itemCount: state.boards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final board = state.boards[index];
          final selected = board.code == state.selectedBoardCode;
          return InkWell(
            onTap: () =>
                ref.read(hotspotProvider.notifier).selectBoard(board.code),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 124,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? context.sc.brandLight : context.sc.bgCard,
                border: Border.all(
                  color: selected ? context.sc.borderActive : context.sc.border,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${board.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(
                      color: context.sc.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.formatChangePct(board.changePct),
                    style: AppTextStyles.numberSm.copyWith(
                      color: getPriceColor(board.changePct),
                    ),
                  ),
                  Text(
                    _boardMetricText(board, state.boardMetric),
                    maxLines: 1,
                    style: AppTextStyles.micro.copyWith(
                      color: context.sc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _modeAndScheme(HotspotState state) {
    final leader = state.stockMode == HotspotStockMode.leader;
    final selectedScheme = state.selectedScheme;
    final enabledSchemes = state.schemes
        .where((scheme) => scheme.isEnabled && scheme.target == state.stockMode)
        .toList();
    return Container(
      color: context.sc.bgPrimary,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: HotspotStockMode.values.map((mode) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: mode == HotspotStockMode.leader ? 6 : 0,
                    left: mode == HotspotStockMode.active ? 6 : 0,
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: state.stockMode == mode
                          ? StockColors.brandLight
                          : null,
                      side: BorderSide(
                        color: state.stockMode == mode
                            ? StockColors.brand
                            : context.sc.border,
                      ),
                    ),
                    onPressed: () => ref
                        .read(hotspotProvider.notifier)
                        .changeStockMode(mode),
                    child: Text(mode.label),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(selectedScheme?.id ?? '__system__'),
                  initialValue: selectedScheme?.id ?? '__system__',
                  decoration: const InputDecoration(
                    labelText: '当前筛选方案',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '__system__',
                      child: Text('系统默认方案'),
                    ),
                    ...enabledSchemes.map(
                      (scheme) => DropdownMenuItem(
                        value: scheme.id,
                        child: Text(
                          scheme.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => ref
                      .read(hotspotProvider.notifier)
                      .selectScheme(value == '__system__' ? null : value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: '管理筛选方案',
                onPressed: () => context.push(
                  '/hotspot/schemes',
                  extra: {'mode': state.stockMode.name},
                ),
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text(
                selectedScheme?.name ?? '系统默认方案',
                style: AppTextStyles.h3,
              ),
              subtitle: Text(
                selectedScheme == null
                    ? leader
                          ? '成交额、相对强度、持续性、换手率综合观察'
                          : '量比、换手率、成交额、振幅综合观察'
                    : 'v${selectedScheme.version} · ${selectedScheme.conditions.length} 个条件 · 返回前 ${selectedScheme.resultLimit}',
                style: AppTextStyles.caption,
              ),
              children: [
                Text(
                  selectedScheme == null
                      ? leader
                            ? '先筛选：成交额前30%、换手率2%–25%、量比≥1.2、近5日相对板块强度>0、有效交易≥4天。策略匹配暂无加分时按0计。'
                            : '先筛选：成交额前40%、量比≥1.5、换手率≥3%、振幅≥3%，并要求价格、成交量和成交额有效。'
                      : _schemeSummary(selectedScheme),
                  style: AppTextStyles.caption.copyWith(
                    color: context.sc.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedScheme == null
                      ? '上市不足60个交易日的排除条件因当前板块接口不提供上市日期，首版暂未应用。'
                      : '当前方案仅在所选板块成分股内运行；策略匹配、上市天数和市值条件暂未接入。',
                  style: AppTextStyles.caption.copyWith(
                    color: StockColors.warning,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '以下为当前规则筛选出的观察名单，不是市场公认结论。',
            style: AppTextStyles.caption.copyWith(
              color: context.sc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockCard(int rank, RankedHotspotStock item, HotspotState state) {
    final stock = item.candidate;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        10,
        AppTheme.pagePadding,
        0,
      ),
      decoration: BoxDecoration(
        color: context.sc.bgCard,
        border: Border.all(color: context.sc.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          '/stock/${stock.code}',
          extra: {'name': stock.name, 'market': stock.market},
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? StockColors.brandLight
                          : context.sc.bgTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Text('$rank', style: AppTextStyles.numberSm),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stock.name, style: AppTextStyles.h3),
                        Text(
                          '${stock.code}.${stock.market}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatPrice(stock.price),
                        style: AppTextStyles.number,
                      ),
                      Text(
                        Formatters.formatChangePct(stock.changePct),
                        style: AppTextStyles.numberSm.copyWith(
                          color: getPriceColor(stock.changePct),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _tag(
                    '${state.selectedScheme?.name ?? state.stockMode.label} ${item.score.toStringAsFixed(0)}',
                  ),
                  _tag(item.directionLabel),
                  ...item.reasons.take(3).map(_tag),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '成交额 ${_amount(stock.amount)} · 换手 ${stock.turnover.toStringAsFixed(2)}% · 量比 ${stock.volumeRatio.toStringAsFixed(2)}',
                style: AppTextStyles.caption.copyWith(
                  color: context.sc.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: StockColors.brandLight,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: AppTextStyles.micro.copyWith(color: StockColors.brandDark),
    ),
  );

  String _boardMetricText(HotspotBoard board, HotspotBoardMetric metric) {
    return switch (metric) {
      HotspotBoardMetric.amount => '成交额 ${_amount(board.amount)}',
      HotspotBoardMetric.volume => '成交量 ${_volume(board.volume)}',
      HotspotBoardMetric.turnover => '换手 ${board.turnover.toStringAsFixed(2)}%',
      HotspotBoardMetric.changePct =>
        '涨跌 ${Formatters.formatChangePct(board.changePct)}',
      HotspotBoardMetric.volumeRatio =>
        '量比 ${board.volumeRatio.toStringAsFixed(2)}',
    };
  }

  String _amount(double value) {
    if (value >= 1e8) return '${(value / 1e8).toStringAsFixed(1)}亿';
    if (value >= 1e4) return '${(value / 1e4).toStringAsFixed(0)}万';
    return value.toStringAsFixed(0);
  }

  String _volume(double value) {
    if (value >= 1e8) return '${(value / 1e8).toStringAsFixed(1)}亿';
    if (value >= 1e4) return '${(value / 1e4).toStringAsFixed(0)}万';
    return value.toStringAsFixed(0);
  }

  String _marketStatus(DateTime time) {
    if (time.weekday == DateTime.saturday || time.weekday == DateTime.sunday) {
      return '最近交易日缓存';
    }
    final minutes = time.hour * 60 + time.minute;
    if (minutes < 9 * 60 + 30) return '盘前数据';
    if (minutes < 15 * 60) return '盘中数据';
    return '收盘数据';
  }

  String _dataTimeLabel(DateTime updatedAt) {
    final tradingDate = _latestTradingDate(updatedAt);
    final isSameDate =
        tradingDate.year == updatedAt.year &&
        tradingDate.month == updatedAt.month &&
        tradingDate.day == updatedAt.day;
    if (isSameDate) {
      return '${_marketStatus(updatedAt)} · ${updatedAt.month}月${updatedAt.day}日 ${Formatters.formatTime(updatedAt)}';
    }
    return '最近交易日数据 · ${tradingDate.month}月${tradingDate.day}日（更新 ${Formatters.formatTime(updatedAt)}）';
  }

  DateTime _latestTradingDate(DateTime time) {
    var date = DateTime(time.year, time.month, time.day);
    final beforeOpen = time.hour * 60 + time.minute < 9 * 60 + 30;
    if (beforeOpen &&
        date.weekday != DateTime.saturday &&
        date.weekday != DateTime.sunday) {
      date = date.subtract(const Duration(days: 1));
    }
    while (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  bool _supportsBoardMetric(HotspotState state, HotspotBoardMetric metric) {
    if (metric == HotspotBoardMetric.amount) return true;
    return state.allBoards.any((board) {
      return switch (metric) {
        HotspotBoardMetric.amount => board.amount > 0,
        HotspotBoardMetric.volume => board.volume > 0,
        HotspotBoardMetric.turnover => board.turnover > 0,
        HotspotBoardMetric.changePct => board.changePct != 0,
        HotspotBoardMetric.volumeRatio => board.volumeRatio > 0,
      };
    });
  }

  String _schemeSummary(HotspotFilterScheme scheme) {
    return scheme.conditions
        .map(
          (condition) =>
              '${condition.metric.label}${condition.operator.label}${condition.value.toStringAsFixed(2)}${condition.metric.unit}',
        )
        .join('；');
  }
}
