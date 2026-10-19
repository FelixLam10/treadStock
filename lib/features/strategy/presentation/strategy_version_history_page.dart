import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/disclaimer_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/toast_helper.dart';
import '../data/strategy_service.dart';
import '../domain/strategy_knowledge_package.dart';
import '../domain/strategy_version_diff.dart';
import 'strategy_knowledge_provider.dart';
import 'strategy_provider.dart';

class StrategyVersionHistoryPage extends ConsumerStatefulWidget {
  final String strategyId;

  const StrategyVersionHistoryPage({super.key, required this.strategyId});

  @override
  ConsumerState<StrategyVersionHistoryPage> createState() =>
      _StrategyVersionHistoryPageState();
}

class _StrategyVersionHistoryPageState
    extends ConsumerState<StrategyVersionHistoryPage> {
  String? _activatingVersionId;

  @override
  Widget build(BuildContext context) {
    final versionsAsync = ref.watch(
      strategyVersionsProvider(widget.strategyId),
    );
    return Scaffold(
      backgroundColor: context.sc.bgSecondary,
      appBar: AppBar(title: const Text('策略版本与差异')),
      body: versionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.sync_problem_outlined,
          title: '版本记录加载失败',
          subtitle: '本地数据暂时无法读取，请稍后重试。',
          actionText: '重试',
          onAction: () =>
              ref.invalidate(strategyVersionsProvider(widget.strategyId)),
        ),
        data: (versions) {
          if (versions.isEmpty) {
            return const EmptyState(
              icon: Icons.history_toggle_off_outlined,
              title: '暂无版本记录',
              subtitle: '导入或编辑策略后会在这里保留不可变快照。',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(strategyVersionsProvider(widget.strategyId));
              await ref.read(
                strategyVersionsProvider(widget.strategyId).future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.pagePadding),
              children: [
                _introCard(),
                const SizedBox(height: 12),
                ...versions.map(
                  (version) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _versionCard(version, versions),
                  ),
                ),
                const DisclaimerLabel(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Text(
        '每个版本都是不可变快照。激活候选版本只会切换当前规则，旧版本、来源和历史回测仍会保留。检测到相反规则时需要再次确认。',
        style: AppTextStyles.caption.copyWith(color: context.sc.textSecondary),
      ),
    );
  }

  Widget _versionCard(
    StrategyVersionInfo version,
    List<StrategyVersionInfo> versions,
  ) {
    final baseline = version.previousVersionId == null
        ? null
        : versions
              .where((item) => item.id == version.previousVersionId)
              .firstOrNull;
    final diff = StrategyVersionDiff.compare(
      baseline: baseline,
      candidate: version,
    );
    final status = _status(version.status);
    final blocked = !version.canEnable;
    final isActive = version.status == 'active';
    final isActivating = _activatingVersionId == version.id;

    return Container(
      decoration: BoxDecoration(
        color: context.sc.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isActive
              ? StockColors.brand.withValues(alpha: 0.35)
              : context.sc.border,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: version == versions.first,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Text('v${version.versionNumber}', style: AppTextStyles.h3),
            const SizedBox(width: 8),
            _pill(status.label, status.color),
          ],
        ),
        subtitle: Text(
          '${version.strategyType.label} · ${_date(version.createdAt)}',
          style: AppTextStyles.caption.copyWith(
            color: context.sc.textSecondary,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              diff.fromVersionNumber == null
                  ? '初始版本'
                  : '相对 v${diff.fromVersionNumber} 的差异',
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _diffSummary(diff),
          const SizedBox(height: 8),
          if (diff.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '没有配置差异。',
                style: AppTextStyles.caption.copyWith(
                  color: context.sc.textSecondary,
                ),
              ),
            )
          else
            ...diff.changes.map(_changeRow),
          if (blocked) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '仍有待确认问题或引擎阻塞项，当前版本不能激活。',
                style: AppTextStyles.caption.copyWith(
                  color: StockColors.warning,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/strategy/${widget.strategyId}/backtest',
                  extra: {
                    'strategyName': version.strategySnapshot.name,
                    'strategyVersionId': version.id,
                  },
                ),
                icon: const Icon(Icons.query_stats_outlined, size: 18),
                label: const Text('回测此版本'),
              ),
              const Spacer(),
              if (!isActive)
                FilledButton(
                  key: ValueKey('activate-version-${version.id}'),
                  onPressed: blocked || isActivating
                      ? null
                      : () => _confirmAndActivate(version, diff),
                  child: isActivating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('激活此版本'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _diffSummary(StrategyVersionDiff diff) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: StrategyVersionChangeKind.values
            .map((kind) => MapEntry(kind, diff.count(kind)))
            .where((entry) => entry.value > 0)
            .map(
              (entry) => _pill(
                '${entry.key.label} ${entry.value}',
                _kindColor(entry.key),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _changeRow(StrategyVersionChange change) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _kindIcon(change.kind),
            size: 17,
            color: _kindColor(change.kind),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${change.area} · ${change.title}',
                  style: AppTextStyles.h3,
                ),
                if (change.before != null)
                  Text(
                    '原：${change.before}',
                    style: AppTextStyles.caption.copyWith(
                      color: context.sc.textTertiary,
                    ),
                  ),
                if (change.after != null)
                  Text(
                    '新：${change.after}',
                    style: AppTextStyles.caption.copyWith(
                      color: context.sc.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndActivate(
    StrategyVersionInfo version,
    StrategyVersionDiff diff,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          diff.hasConflicts ? '确认规则冲突' : '激活 v${version.versionNumber}？',
        ),
        content: Text(
          diff.hasConflicts
              ? '候选版本包含与上一版本方向相反的规则。确认后将以候选版本作为当前规则，旧版本和历史结果仍会保留。'
              : '当前策略将切换到这个不可变快照。建议先用相同条件完成回测；激活不会删除旧版本。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(diff.hasConflicts ? '我已核对，继续激活' : '确认激活'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _activatingVersionId = version.id);
    try {
      await ref
          .read(strategyServiceProvider)
          .activateStrategyVersion(
            widget.strategyId,
            version.id,
            confirmedConflicts: diff.hasConflicts,
          );
      ref.invalidate(strategyVersionsProvider(widget.strategyId));
      await ref
          .read(strategyDetailProvider.notifier)
          .loadDetail(widget.strategyId);
      await ref.read(strategyListProvider.notifier).loadStrategies();
      if (!mounted) return;
      ToastHelper.showSuccess(context, '已激活 v${version.versionNumber}，旧版本仍可回看');
    } on StrategyVersionActivationException catch (error) {
      if (mounted) ToastHelper.showError(context, error.message);
    } catch (_) {
      if (mounted) ToastHelper.showError(context, '版本激活失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _activatingVersionId = null);
    }
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }

  ({String label, Color color}) _status(String status) => switch (status) {
    'active' => (label: '当前版本', color: StockColors.brand),
    'candidate' => (label: '候选版本', color: StockColors.warning),
    'archived' => (label: '历史版本', color: context.sc.textTertiary),
    _ => (label: '草稿', color: context.sc.textSecondary),
  };

  Color _kindColor(StrategyVersionChangeKind kind) => switch (kind) {
    StrategyVersionChangeKind.added => StockColors.success,
    StrategyVersionChangeKind.removed => context.sc.textTertiary,
    StrategyVersionChangeKind.modified => StockColors.brand,
    StrategyVersionChangeKind.conflict => StockColors.danger,
    StrategyVersionChangeKind.pending => StockColors.warning,
  };

  IconData _kindIcon(StrategyVersionChangeKind kind) => switch (kind) {
    StrategyVersionChangeKind.added => Icons.add_circle_outline,
    StrategyVersionChangeKind.removed => Icons.remove_circle_outline,
    StrategyVersionChangeKind.modified => Icons.edit_outlined,
    StrategyVersionChangeKind.conflict => Icons.warning_amber_rounded,
    StrategyVersionChangeKind.pending => Icons.help_outline,
  };

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
