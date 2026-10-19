import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';
import '../domain/hotspot_filter_scheme.dart';
import '../domain/hotspot_models.dart';
import 'hotspot_provider.dart';

class HotspotSchemeManagePage extends ConsumerWidget {
  final HotspotStockMode initialMode;

  const HotspotSchemeManagePage({
    super.key,
    this.initialMode = HotspotStockMode.leader,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hotspotProvider);
    return Scaffold(
      backgroundColor: context.sc.bgSecondary,
      appBar: AppBar(title: const Text('我的筛选方案')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          _createCard(context),
          const SizedBox(height: 14),
          if (state.schemes.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.sc.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.filter_alt_outlined, color: context.sc.gray400),
                  const SizedBox(height: 10),
                  const Text('还没有自定义方案', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    '建议先复制系统默认方案，再调整一两个条件进行复盘。',
                    style: AppTextStyles.caption.copyWith(
                      color: context.sc.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...state.schemes.map((scheme) => _schemeCard(context, ref, scheme)),
          const SizedBox(height: 16),
          Text(
            '自定义方案只在当前选中板块内运行。筛选结果是观察线索，不构成投资建议。',
            style: AppTextStyles.caption.copyWith(
              color: context.sc.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _createCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.sc.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.sc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('创建方案', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(
                    '/hotspot/scheme/new',
                    extra: {'mode': initialMode.name, 'copyDefault': true},
                  ),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('复制系统默认'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/hotspot/scheme/new',
                    extra: {'mode': initialMode.name, 'copyDefault': false},
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('从空白创建'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _schemeCard(
    BuildContext context,
    WidgetRef ref,
    HotspotFilterScheme scheme,
  ) {
    final errors = scheme.validate();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.sc.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.isEnabled ? StockColors.brand : context.sc.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scheme.name, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      '${scheme.target.label} · v${scheme.version} · ${scheme.conditions.length} 个条件',
                      style: AppTextStyles.caption.copyWith(
                        color: context.sc.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: scheme.isEnabled,
                onChanged: errors.isNotEmpty
                    ? null
                    : (value) => _run(
                        context,
                        () => ref
                            .read(hotspotProvider.notifier)
                            .setSchemeEnabled(scheme.id, value),
                      ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleAction(context, ref, scheme, action),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('编辑')),
                  PopupMenuItem(value: 'copy', child: Text('复制')),
                  PopupMenuItem(value: 'restore', child: Text('恢复系统默认')),
                  PopupMenuItem(value: 'history', child: Text('版本历史')),
                  PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tag(scheme.logic.label),
              _tag('返回前 ${scheme.resultLimit}'),
              _tag(
                scheme.isEnabled
                    ? '已启用'
                    : errors.isEmpty
                    ? '待启用'
                    : '草稿',
              ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: AppTextStyles.caption.copyWith(color: StockColors.warning),
            ),
          ],
          if (scheme.lastRunAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '最近运行 ${Formatters.formatRelativeTime(scheme.lastRunAt!)} · 命中 ${scheme.lastMatchCount ?? 0} 只',
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
          ],
        ],
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

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    HotspotFilterScheme scheme,
    String action,
  ) async {
    switch (action) {
      case 'edit':
        await context.push('/hotspot/scheme/${scheme.id}/edit');
        return;
      case 'copy':
        await _run(
          context,
          () => ref.read(hotspotProvider.notifier).duplicateScheme(scheme.id),
        );
        return;
      case 'restore':
        await _run(
          context,
          () => ref
              .read(hotspotProvider.notifier)
              .restoreSchemeDefault(scheme.id),
        );
        return;
      case 'history':
        if (!context.mounted) return;
        final history = await ref
            .read(hotspotProvider.notifier)
            .loadSchemeHistory(scheme.id);
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('${scheme.name} · 版本历史'),
            content: SizedBox(
              width: 360,
              child: history.isEmpty
                  ? const Text('暂无版本记录')
                  : ListView(
                      shrinkWrap: true,
                      children: history
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('v${item.version}'),
                              subtitle: Text(
                                '${item.snapshot.conditions.length} 个条件 · ${item.snapshot.sortWeights.length} 个排序指标',
                              ),
                              trailing: Text(
                                Formatters.formatDate(item.savedAt),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
        return;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('删除筛选方案？'),
            content: Text('“${scheme.name}”将从本机删除，历史版本不再展示。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('删除'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await _run(
            context,
            () => ref.read(hotspotProvider.notifier).deleteScheme(scheme.id),
          );
        }
        return;
    }
  }

  Future<void> _run(
    BuildContext context,
    Future<dynamic> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败：$error')));
    }
  }
}
