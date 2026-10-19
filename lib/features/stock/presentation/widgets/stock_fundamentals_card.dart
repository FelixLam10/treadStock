import 'package:flutter/material.dart';
import 'package:stockpilot/core/theme/app_colors.dart';
import 'package:stockpilot/core/theme/app_semantic_colors.dart';
import 'package:stockpilot/core/theme/app_text_styles.dart';
import 'package:stockpilot/core/theme/app_theme.dart';
import 'package:stockpilot/features/stock/domain/stock_fundamental_insight.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';
import 'package:stockpilot/shared/utils/formatters.dart';

class StockFundamentalsCard extends StatelessWidget {
  final StockFundamentals fundamentals;
  final List<DailyKline>? klines;

  const StockFundamentalsCard({
    super.key,
    required this.fundamentals,
    required this.klines,
  });

  @override
  Widget build(BuildContext context) {
    final marketStage = buildMarketStageInsight(klines);
    final growth = buildGrowthInsight(fundamentals);
    final fallbackIndustry = fundamentals.sector == null
        ? fundamentals.industry?.replaceAll('-', ' · ')
        : null;
    final listingTag = fundamentals.listingDate == null
        ? null
        : '${fundamentals.listingDate!.year}年上市';
    final tags = <String>[
      ?fundamentals.board,
      ?fundamentals.sector?.replaceAll('-', ' · '),
      ?fallbackIndustry,
      ?listingTag,
    ];

    return Container(
      key: const ValueKey('stock-fundamentals-card'),
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sc.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.sc.borderLight),
        boxShadow: const [
          BoxShadow(
            color: StockColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.sc.brandLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 19,
                  color: StockColors.brand,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('公司速览', style: AppTextStyles.h2)),
              if (fundamentals.reportName case final report?)
                _ReportBadge(text: report),
            ],
          ),
          if (fundamentals.companyName case final company?) ...[
            const SizedBox(height: 10),
            Text(
              company,
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) => _InfoTag(text: tag)).toList(),
            ),
          ],
          if (fundamentals.businessSummary case final summary?) ...[
            const SizedBox(height: 16),
            _SectionEyebrow(text: '主营业务'),
            const SizedBox(height: 5),
            Text(
              summary,
              style: AppTextStyles.body.copyWith(
                color: context.sc.textSecondary,
                height: 1.6,
              ),
            ),
          ],
          if (fundamentals.marketPosition case final position?) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.sc.bgInfo,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 18,
                    color: StockColors.brand,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '行业定位（公司资料）',
                          style: AppTextStyles.caption.copyWith(
                            color: StockColors.brand,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          position,
                          style: AppTextStyles.caption.copyWith(
                            color: context.sc.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (fundamentals.hasValuation || fundamentals.hasPerformance) ...[
            const SizedBox(height: 18),
            Divider(color: context.sc.divider),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(child: Text('估值与业绩', style: AppTextStyles.h3)),
                if (fundamentals.reportDate case final date?)
                  Text(
                    '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                    style: AppTextStyles.micro.copyWith(
                      color: context.sc.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricTile(
                      width: width,
                      label: '总市值',
                      value: Formatters.formatMarketCap(fundamentals.marketCap),
                    ),
                    _MetricTile(
                      width: width,
                      label: '市盈率（动）',
                      value: _formatRatio(fundamentals.peDynamic),
                      hint:
                          fundamentals.peDynamic != null &&
                              fundamentals.peDynamic! <= 0
                          ? '当前盈利为负或口径异常'
                          : null,
                    ),
                    _MetricTile(
                      width: width,
                      label: '营业收入',
                      value: _formatMoney(fundamentals.revenue),
                      change: fundamentals.revenueYoy,
                    ),
                    _MetricTile(
                      width: width,
                      label: '归母净利',
                      value: _formatMoney(fundamentals.netProfit),
                      change: fundamentals.netProfitYoy,
                    ),
                    _MetricTile(
                      width: width,
                      label: '净资产收益率',
                      value: _formatPercent(fundamentals.roe),
                    ),
                    _MetricTile(
                      width: width,
                      label: '毛利率 / 负债率',
                      value:
                          '${_formatPercent(fundamentals.grossMargin)} / ${_formatPercent(fundamentals.debtRatio)}',
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 18),
          Divider(color: context.sc.divider),
          const SizedBox(height: 14),
          const Text('阶段观察', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          _InsightTile(
            icon: Icons.show_chart_rounded,
            title: '当前阶段',
            insight: marketStage,
          ),
          const SizedBox(height: 8),
          _InsightTile(
            icon: Icons.trending_up_rounded,
            title: '增长空间',
            insight: growth,
          ),
          const SizedBox(height: 12),
          Text(
            '公司介绍与行业定位来自公开公司资料；阶段与增长观察由公开行情、财报规则化生成，仅供了解与复盘，不代表未来表现。',
            style: AppTextStyles.micro.copyWith(
              color: context.sc.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBadge extends StatelessWidget {
  final String text;

  const _ReportBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.sc.bgTertiary,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: AppTextStyles.micro.copyWith(color: context.sc.textSecondary),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String text;

  const _InfoTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.sc.bgTertiary,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: context.sc.textSecondary),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String text;

  const _SectionEyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: context.sc.textTertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final double? change;
  final String? hint;

  const _MetricTile({
    required this.width,
    required this.label,
    required this.value,
    this.change,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.micro.copyWith(color: context.sc.textTertiary),
          ),
          const SizedBox(height: 5),
          Text(value, style: AppTextStyles.numberSm),
          if (change case final value?) ...[
            const SizedBox(height: 3),
            Text(
              '同比 ${Formatters.formatChangePct(value)}',
              style: AppTextStyles.micro.copyWith(color: getPriceColor(value)),
            ),
          ] else if (hint case final value?) ...[
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.micro.copyWith(
                color: context.sc.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final StockInsight insight;

  const _InsightTile({
    required this.icon,
    required this.title,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: StockColors.brand),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.caption.copyWith(
                      color: context.sc.textSecondary,
                    ),
                    children: [
                      TextSpan(text: '$title · '),
                      TextSpan(
                        text: insight.label,
                        style: const TextStyle(
                          color: StockColors.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  insight.summary,
                  style: AppTextStyles.caption.copyWith(
                    color: context.sc.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRatio(double? value) =>
    value == null ? '--' : value.toStringAsFixed(1);

String _formatPercent(double? value) =>
    value == null ? '--' : '${value.toStringAsFixed(1)}%';

String _formatMoney(double? value) {
  if (value == null) return '--';
  if (value.abs() >= 1e8) return '${(value / 1e8).toStringAsFixed(2)}亿';
  if (value.abs() >= 1e4) return '${(value / 1e4).toStringAsFixed(0)}万';
  return value.toStringAsFixed(0);
}
