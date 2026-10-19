import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/disclaimer_label.dart';
import '../../../shared/widgets/toast_helper.dart';
import '../domain/strategy_knowledge_package.dart';
import '../domain/signal_rule.dart';
import 'strategy_provider.dart';

class StrategyImportPage extends ConsumerStatefulWidget {
  const StrategyImportPage({super.key});

  @override
  ConsumerState<StrategyImportPage> createState() => _StrategyImportPageState();
}

class _StrategyImportPageState extends ConsumerState<StrategyImportPage> {
  final _controller = TextEditingController();
  StrategyKnowledgePackage? _preview;
  String? _error;
  String? _targetStrategyId;
  bool _retainSanitizedText = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strategies = ref.watch(strategyListProvider).strategies;
    final hasSourceText =
        _preview?.sources.any((source) => source.sanitizedText != null) ??
        false;

    return Scaffold(
      backgroundColor: context.sc.bgPrimary,
      appBar: AppBar(
        title: const Text('导入策略资料'),
        backgroundColor: context.sc.bgPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          _buildIntroCard(),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            key: const ValueKey('strategy-import-target'),
            initialValue: _targetStrategyId,
            decoration: const InputDecoration(
              labelText: '保存方式',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('创建一条新策略'),
              ),
              ...strategies
                  .where((strategy) => !strategy.isDefault)
                  .map(
                    (strategy) => DropdownMenuItem<String?>(
                      value: strategy.id,
                      child: Text('作为「${strategy.name}」的新候选版本'),
                    ),
                  ),
            ],
            onChanged: (value) => setState(() => _targetStrategyId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('strategy-package-input'),
            controller: _controller,
            minLines: 10,
            maxLines: 18,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: '策略包 JSON',
              alignLabelWithHint: true,
              hintText: '把智能助手整理出的策略包粘贴到这里',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyPrompt,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('复制整理规范'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('strategy-package-preview'),
                  onPressed: _parsePreview,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('校验并预览'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _MessageCard(
              icon: Icons.error_outline,
              color: StockColors.danger,
              title: '策略包无法导入',
              message: _error!,
            ),
          ],
          if (_preview != null) ...[
            const SizedBox(height: 16),
            _buildPreview(_preview!),
            if (hasSourceText)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _retainSanitizedText,
                onChanged: (value) =>
                    setState(() => _retainSanitizedText = value ?? false),
                title: const Text('在本机保存脱敏后的相关文字'),
                subtitle: const Text('默认不保存聊天正文，只保存来源摘要和去重指纹。原始截图不会写入数据库。'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('strategy-package-save'),
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_targetStrategyId == null ? '确认保存为草稿' : '保存候选版本'),
            ),
          ],
          const SizedBox(height: 16),
          const DisclaimerLabel(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StockColors.brandLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_outlined, color: StockColors.brand),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '先把聊天文字、书摘或截图交给智能助手整理，再把生成的策略包粘贴回来。App 只做本地校验、预览和保存，不会调用模型或上传资料。',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(StrategyKnowledgePackage package) {
    final statusColor = package.hasBlockingIssue
        ? StockColors.danger
        : package.needsConfirmation
        ? StockColors.warning
        : StockColors.success;
    final statusTitle = package.hasBlockingIssue
        ? '存在当前不可执行的规则'
        : package.needsConfirmation
        ? '保存后仍需确认'
        : '校验通过，可保存为草稿';
    final statusMessage = package.canEnable
        ? '保存后默认停用；确认规则并完成必要验证后可手动启用。'
        : '可以保存和继续完善，但在待确认项解决前不能启用。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MessageCard(
          key: const ValueKey('strategy-package-status'),
          icon: package.canEnable
              ? Icons.verified_outlined
              : Icons.rule_folder_outlined,
          color: statusColor,
          title: statusTitle,
          message: statusMessage,
        ),
        const SizedBox(height: 12),
        _PreviewSection(
          title: package.form.name,
          subtitle:
              '${package.strategyType.label} · ${package.form.description}',
          children: [
            Text(
              '参数：MA ${package.form.maShortPeriod}/${package.form.maLongPeriod} · '
              '布林 ${package.form.bollPeriod} 日 · 观察阈值 ${package.form.recommendThreshold}',
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
          ],
        ),
        _PreviewSection(
          title: '来源（${package.sources.length}）',
          children: package.sources
              .map(
                (source) => _BulletText(
                  '${source.kind.label}${source.speaker == null ? '' : ' · ${source.speaker}'}：${source.summary}',
                ),
              )
              .toList(),
        ),
        _PreviewSection(
          title: '整理后的规则（${package.rules.length}）',
          children: package.rules
              .map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.title, style: AppTextStyles.body),
                      const SizedBox(height: 2),
                      Text(
                        rule.statement,
                        style: AppTextStyles.caption.copyWith(
                          color: context.sc.textSecondary,
                        ),
                      ),
                      Text(
                        '${rule.status.label} · ${rule.engineSupport.label}',
                        style: AppTextStyles.caption.copyWith(
                          color:
                              rule.engineSupport ==
                                  StrategyEngineSupport.unsupported
                              ? StockColors.danger
                              : StockColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        if (package.form.entryRules.isNotEmpty ||
            package.form.exitRules.isNotEmpty)
          _PreviewSection(
            title: '可执行规则',
            children: [
              ...package.form.entryRules.map(
                (rule) => _BulletText('观察信号：${_executionRuleLabel(rule)}'),
              ),
              ...package.form.exitRules.map(
                (rule) => _BulletText('退出观察：${_executionRuleLabel(rule)}'),
              ),
            ],
          ),
        if (package.applicability.environments.isNotEmpty ||
            package.applicability.invalidEnvironments.isNotEmpty)
          _PreviewSection(
            title: '适用与失效环境',
            children: [
              if (package.applicability.environments.isNotEmpty)
                _BulletText(
                  '适用：${package.applicability.environments.join('、')}',
                ),
              if (package.applicability.invalidEnvironments.isNotEmpty)
                _BulletText(
                  '失效：${package.applicability.invalidEnvironments.join('、')}',
                ),
            ],
          ),
        if (package.pendingQuestions.isNotEmpty)
          _PreviewSection(
            title: '待确认（${package.pendingQuestions.length}）',
            titleColor: StockColors.warning,
            children: package.pendingQuestions
                .map((question) => _BulletText(question))
                .toList(),
          ),
        if (package.compatibilityIssues.isNotEmpty)
          _PreviewSection(
            title: '兼容性提示',
            titleColor: StockColors.danger,
            children: package.compatibilityIssues
                .map(
                  (issue) => _BulletText(
                    '${issue.blocking ? '阻塞' : '提示'}：${issue.message}',
                  ),
                )
                .toList(),
          ),
        if (package.riskNotes.isNotEmpty)
          _PreviewSection(
            title: '风险与缺失信息',
            children: package.riskNotes
                .map((note) => _BulletText(note))
                .toList(),
          ),
      ],
    );
  }

  String _executionRuleLabel(SignalRule rule) {
    final indicator = switch (rule.indicator) {
      'price_ma_short' => '收盘价相对短期均线',
      'price_ma_long' => '收盘价相对长期均线',
      'market_environment' => '短期均线趋势环境',
      'ladder_breakout' => '梯级平台突破',
      'ladder_support_gap_pct' => '梯级平台支撑距离',
      'chan_third_buy' => '简化缠论三买结构',
      'chan_center_support_gap_pct' => '简化中枢上沿距离',
      _ => rule.indicator.toUpperCase(),
    };
    final condition = switch (rule.condition) {
      'cross_up_confirmed' => '上穿后连续 ${rule.confirmationDays} 个交易日确认',
      'cross_down_confirmed' => '下穿后连续 ${rule.confirmationDays} 个交易日确认',
      'uptrend' => '上升趋势（${rule.lookbackDays} 日斜率阈值 ${rule.value}%）',
      'downtrend' => '下降趋势（${rule.lookbackDays} 日斜率阈值 ${rule.value}%）',
      'sideways' => '横盘震荡（斜率阈值 ${rule.value}%）',
      'not_sideways' => '非横盘（斜率阈值 ${rule.value}%）',
      _ => '${rule.condition} ${rule.value}',
    };
    return '$indicator · $condition';
  }

  Future<void> _copyPrompt() async {
    await Clipboard.setData(
      const ClipboardData(text: StrategyKnowledgePackageCodec.generationPrompt),
    );
    if (!mounted) return;
    ToastHelper.showSuccess(context, '已复制策略资料整理规范');
  }

  void _parsePreview() {
    try {
      final package = StrategyKnowledgePackageCodec.parse(
        _controller.text.trim(),
      );
      setState(() {
        _preview = package;
        _error = null;
        _retainSanitizedText = false;
      });
    } on FormatException catch (error) {
      setState(() {
        _preview = null;
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _preview = null;
        _error = '策略包格式不正确';
      });
    }
  }

  Future<void> _save() async {
    final package = _preview;
    if (package == null) return;
    setState(() => _isSaving = true);
    final result = await ref
        .read(strategyListProvider.notifier)
        .importKnowledgePackage(
          package,
          retainSanitizedText: _retainSanitizedText,
          targetStrategyId: _targetStrategyId,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (result == null) {
      ToastHelper.showError(context, '保存失败，请检查是否重复导入或重试');
      return;
    }
    ToastHelper.showSuccess(
      context,
      result.createdStrategy
          ? '策略草稿已保存，默认未启用'
          : '候选版本 v${result.versionNumber} 已保存',
    );
    context.go('/strategy/${result.strategyId}');
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _MessageCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 3),
                Text(
                  message,
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
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final List<Widget> children;

  const _PreviewSection({
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(color: titleColor)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
          ],
          if (children.isNotEmpty) const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: context.sc.textTertiary)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
