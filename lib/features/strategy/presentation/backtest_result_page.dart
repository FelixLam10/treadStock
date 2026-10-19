import 'package:flutter/material.dart';
import 'package:stockpilot/core/theme/app_semantic_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/disclaimer_label.dart';
import '../domain/backtest_models.dart';

/// Page to display backtest results for a strategy.
class BacktestResultPage extends StatelessWidget {
  final BacktestReport report;
  final BacktestComparison? comparison;

  const BacktestResultPage({super.key, required this.report, this.comparison});

  BacktestResult get result => report.result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.bgPrimary,
      body: ListView(
        children: [
          _buildHeader(context),
          _buildEvidence(context),
          _buildHealthBanner(context),
          _buildCoreStats(context),
          _buildPerformanceGrid(context),
          _buildComparison(context),
          if (result.trades.isNotEmpty) _buildTradeList(context),
          const DisclaimerLabel(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, AppTheme.pagePadding, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: context.sc.gray700,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('回测报告', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    '${result.strategyName} v${report.strategyVersionNumber} · ${report.stockName} ${result.stockCode}',
                    style: AppTextStyles.caption,
                  ),
                  if (result.startDate != null && result.endDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _dateRange,
                      style: AppTextStyles.caption.copyWith(
                        color: context.sc.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _dateRange {
    final start =
        '${result.startDate!.year}-${_two(result.startDate!.month)}-${_two(result.startDate!.day)}';
    final end =
        '${result.endDate!.year}-${_two(result.endDate!.month)}-${_two(result.endDate!.day)}';
    return '$start 至 $end';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Widget _buildEvidence(BuildContext context) {
    final config = report.config;
    return Container(
      key: const Key('backtest-evidence'),
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('回测证据快照', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          _gridRow(context, '策略版本', 'v${report.strategyVersionNumber}'),
          _gridRow(context, '复权方式', report.adjustmentMode.label),
          _gridRow(context, '数据截止', _fmtFullDate(report.dataAsOf)),
          _gridRow(
            context,
            '初始资金 / 仓位',
            '${config.initialCapital.toStringAsFixed(0)} 元 / ${(config.positionSize * 100).toStringAsFixed(0)}%',
          ),
          _gridRow(
            context,
            '佣金 / 印花税',
            '${(config.commissionRate * 100).toStringAsFixed(3)}% / ${(config.stampTaxRate * 100).toStringAsFixed(2)}%',
          ),
          _gridRow(context, '滑点', '${config.slippage.toStringAsFixed(2)} 元/股'),
          _gridRow(context, '数据指纹', report.dataFingerprint.substring(0, 8)),
        ],
      ),
    );
  }

  Widget _buildHealthBanner(BuildContext context) {
    final color = _healthColor(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(_healthIcon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.healthLabel, style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(
                  report.sampleMessage,
                  style: AppTextStyles.caption.copyWith(
                    color: context.sc.textSecondary,
                  ),
                ),
                Text(
                  '处理 ${result.barsProcessed} 根K线 · 仅供观察与复盘',
                  style: AppTextStyles.micro.copyWith(
                    color: context.sc.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _healthColor(BuildContext context) {
    if (!report.hasEnoughSample) return context.sc.textTertiary;
    if (result.winRate >= 0.6 && result.profitFactor >= 1.5) {
      return StockColors.success;
    }
    if (result.winRate >= 0.45 && result.profitFactor >= 1.0) {
      return StockColors.warning;
    }
    return StockColors.danger;
  }

  IconData get _healthIcon {
    if (!report.hasEnoughSample) return Icons.info_outline;
    if (result.winRate >= 0.6 && result.profitFactor >= 1.5) {
      return Icons.task_alt;
    }
    if (result.winRate >= 0.45 && result.profitFactor >= 1.0) {
      return Icons.trending_flat;
    }
    return Icons.trending_down;
  }

  Widget _buildCoreStats(BuildContext context) {
    if (result.totalTrades == 0) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Text(
          '回测期间无交易产生，策略条件未触发。',
          style: AppTextStyles.body.copyWith(color: context.sc.textSecondary),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        0,
      ),
      child: Row(
        children: [
          _statCard(context, '胜率', _pct(result.winRate), _winRateColor),
          const SizedBox(width: 8),
          _statCard(
            context,
            '总收益',
            '${result.totalReturnPct.toStringAsFixed(1)}%',
            _returnColor(context),
          ),
          const SizedBox(width: 8),
          _statCard(
            context,
            '最大回撤',
            '${result.maxDrawdownPct.toStringAsFixed(1)}%',
            StockColors.danger,
          ),
        ],
      ),
    );
  }

  Color get _winRateColor {
    if (result.winRate >= 0.6) return StockColors.success;
    if (result.winRate >= 0.4) return StockColors.warning;
    return StockColors.danger;
  }

  Color _returnColor(BuildContext context) {
    if (result.totalReturnPct > 0) return StockColors.up;
    if (result.totalReturnPct < 0) return StockColors.down;
    return context.sc.textPrimary;
  }

  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.sc.bgSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.numberSm.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceGrid(BuildContext context) {
    if (result.totalTrades == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('详细指标', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          _gridRow(context, '盈利次数', '${result.winCount}'),
          _gridRow(context, '亏损次数', '${result.loseCount}'),
          _gridRow(context, '盈亏比', result.profitFactor.toStringAsFixed(2)),
          _gridRow(
            context,
            '年均收益',
            '${result.annualizedReturn.toStringAsFixed(1)}%',
          ),
          _gridRow(
            context,
            '平均持仓',
            '${result.avgHoldingDays.toStringAsFixed(1)} 天',
          ),
          _gridRow(context, '夏普比率', result.sharpeRatio.toStringAsFixed(2)),
          _gridRow(context, '最大连赢', '${result.maxConsecutiveWins} 次'),
          _gridRow(context, '最大连亏', '${result.maxConsecutiveLosses} 次'),
          _gridRow(context, '平均盈利', '+${result.avgWinPct.toStringAsFixed(1)}%'),
          _gridRow(context, '平均亏损', '${result.avgLossPct.toStringAsFixed(1)}%'),
          _gridRow(
            context,
            '最佳交易',
            '+${result.bestTradePct.toStringAsFixed(1)}%',
          ),
          _gridRow(
            context,
            '最差交易',
            '${result.worstTradePct.toStringAsFixed(1)}%',
          ),
          _gridRow(context, '净利(元)', result.totalNetProfit.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _buildComparison(BuildContext context) {
    final value = comparison;
    if (value == null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding,
          12,
          AppTheme.pagePadding,
          0,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.sc.bgSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          '暂无其他版本的同股回测记录。本报告已保存，可在另一版本使用相同条件回测后比较。',
          style: AppTextStyles.caption.copyWith(
            color: context.sc.textSecondary,
          ),
        ),
      );
    }

    final canCompare =
        value.status != BacktestComparisonStatus.incompatibleInputs;
    return Container(
      key: const Key('backtest-version-comparison'),
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '版本对比 · v${value.baseline.strategyVersionNumber} → v${value.candidate.strategyVersionNumber}',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 6),
          Text(
            value.message,
            style: AppTextStyles.caption.copyWith(
              color: context.sc.textSecondary,
            ),
          ),
          if (canCompare) ...[
            const SizedBox(height: 8),
            _gridRow(context, '总收益变化', _signedPct(value.returnDeltaPct)),
            _gridRow(context, '胜率变化', _signedPct(value.winRateDelta * 100)),
            _gridRow(context, '最大回撤变化', _signedPct(value.drawdownDeltaPct)),
          ],
        ],
      ),
    );
  }

  String _signedPct(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';

  Widget _gridRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.sc.textSecondary,
            ),
          ),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildTradeList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding,
            16,
            AppTheme.pagePadding,
            8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('交易记录', style: AppTextStyles.h2),
              Text('共 ${result.trades.length} 笔', style: AppTextStyles.caption),
            ],
          ),
        ),
        ...result.trades.take(30).map((t) => _buildTradeItem(context, t)),
      ],
    );
  }

  Widget _buildTradeItem(BuildContext context, BacktestTrade trade) {
    final color = trade.isWin ? StockColors.up : StockColors.down;
    final icon = trade.isWin ? Icons.arrow_upward : Icons.arrow_downward;
    final exitLabel = switch (trade.exitReason) {
      ExitReason.signalExit => '信号出场',
      ExitReason.stopLoss => '止损',
      ExitReason.takeProfit => '止盈',
      ExitReason.trailingStop => '移动止损',
      ExitReason.endOfData => '期末平仓',
    };

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: 3,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_fmtDate(trade.entryDate)} → ${_fmtDate(trade.exitDate)}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${trade.shares}股 · $exitLabel · ${trade.exitBarIndex - trade.entryBarIndex}天',
                  style: AppTextStyles.caption.copyWith(
                    color: context.sc.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${trade.returnPct >= 0 ? '+' : ''}${(trade.returnPct * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.numberSm.copyWith(color: color),
              ),
              Text(
                '${trade.netProfit >= 0 ? '+' : ''}${trade.netProfit.toStringAsFixed(0)}',
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _fmtFullDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
}
