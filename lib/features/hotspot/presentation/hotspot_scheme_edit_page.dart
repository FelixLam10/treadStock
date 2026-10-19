import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/hotspot_filter_scheme.dart';
import '../domain/hotspot_models.dart';
import 'hotspot_provider.dart';

class HotspotSchemeEditPage extends ConsumerStatefulWidget {
  final String? schemeId;
  final HotspotStockMode initialMode;
  final bool copyDefault;

  const HotspotSchemeEditPage({
    super.key,
    this.schemeId,
    this.initialMode = HotspotStockMode.leader,
    this.copyDefault = false,
  });

  @override
  ConsumerState<HotspotSchemeEditPage> createState() =>
      _HotspotSchemeEditPageState();
}

class _HotspotSchemeEditPageState extends ConsumerState<HotspotSchemeEditPage> {
  late HotspotFilterScheme _scheme;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = ref
        .read(hotspotProvider)
        .schemes
        .where((item) => item.id == widget.schemeId)
        .firstOrNull;
    _scheme =
        existing ??
        (widget.copyDefault
            ? HotspotFilterScheme.copyOfDefault(widget.initialMode)
            : HotspotFilterScheme.blank(target: widget.initialMode));
  }

  @override
  Widget build(BuildContext context) {
    final errors = _scheme.validate();
    return Scaffold(
      backgroundColor: context.sc.bgSecondary,
      appBar: AppBar(
        title: Text(widget.schemeId == null ? '新建筛选方案' : '编辑筛选方案'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          _section(
            title: '基本信息',
            child: Column(
              children: [
                TextFormField(
                  initialValue: _scheme.name,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: '方案名称'),
                  onChanged: (value) =>
                      setState(() => _scheme = _scheme.copyWith(name: value)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<HotspotStockMode>(
                    segments: HotspotStockMode.values
                        .map(
                          (mode) => ButtonSegment(
                            value: mode,
                            label: Text(mode.label),
                          ),
                        )
                        .toList(),
                    selected: {_scheme.target},
                    onSelectionChanged: widget.schemeId != null
                        ? null
                        : (values) => setState(
                            () => _scheme = _scheme.copyWith(
                              target: values.single,
                            ),
                          ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '股票范围：当前选中板块。全市场和关注列表范围需要额外行情编排，暂未开放。',
                    style: AppTextStyles.caption.copyWith(
                      color: context.sc.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _section(
            title: '基础排除',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('排除风险警示与退市整理股票'),
                  value: _scheme.excludeRiskWarnings,
                  onChanged: (value) => setState(
                    () =>
                        _scheme = _scheme.copyWith(excludeRiskWarnings: value),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('排除停牌或无有效成交股票'),
                  value: _scheme.excludeSuspended,
                  onChanged: (value) => setState(
                    () => _scheme = _scheme.copyWith(excludeSuspended: value),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        label: '最低价格',
                        value: _scheme.minPrice,
                        onChanged: (value) => setState(
                          () => _scheme = _scheme.copyWith(minPrice: value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        label: '最高价格',
                        value: _scheme.maxPrice,
                        onChanged: (value) => setState(
                          () => _scheme = _scheme.copyWith(maxPrice: value),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '上市天数和市值当前不在板块成分股接口中，暂不提供无效开关。',
                    style: AppTextStyles.caption.copyWith(
                      color: StockColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _section(
            title: '筛选条件',
            action: DropdownButton<HotspotConditionLogic>(
              value: _scheme.logic,
              underline: const SizedBox.shrink(),
              items: HotspotConditionLogic.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _scheme = _scheme.copyWith(logic: value));
                }
              },
            ),
            child: Column(
              children: [
                ..._scheme.conditions.asMap().entries.map(
                  (entry) => _conditionCard(entry.key, entry.value),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addCondition,
                    icon: const Icon(Icons.add),
                    label: const Text('添加条件'),
                  ),
                ),
              ],
            ),
          ),
          _section(
            title: '排序权重',
            child: Column(
              children: [
                ..._scheme.sortWeights.asMap().entries.map(
                  (entry) => _weightCard(entry.key, entry.value),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addWeight,
                    icon: const Icon(Icons.add),
                    label: const Text('添加排序指标'),
                  ),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _scheme.resultLimit,
                  decoration: const InputDecoration(labelText: '返回数量'),
                  items: const [5, 10, 20, 30, 50]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('前 $value 只'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(
                        () => _scheme = _scheme.copyWith(resultLimit: value),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          if (errors.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.sc.bgWarning,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '当前将保存为草稿：${errors.join('；')}',
                style: AppTextStyles.caption.copyWith(
                  color: context.sc.cacheBannerText,
                ),
              ),
            )
          else
            Text(
              '保存后仍保持停用，请在方案管理中确认启用。',
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.sc.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.sc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h3)),
              ?action,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _conditionCard(int index, HotspotFilterCondition condition) {
    return Container(
      key: ValueKey('condition_$index'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<HotspotFilterMetric>(
                  initialValue: condition.metric,
                  decoration: const InputDecoration(labelText: '指标'),
                  items: HotspotFilterMetric.values
                      .map(
                        (metric) => DropdownMenuItem(
                          value: metric,
                          enabled: metric != HotspotFilterMetric.strategyMatch,
                          child: Text(
                            metric == HotspotFilterMetric.strategyMatch
                                ? '${metric.label}（暂未接入）'
                                : metric.label,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _replaceCondition(
                        index,
                        condition.copyWith(metric: value),
                      );
                    }
                  },
                ),
              ),
              IconButton(
                tooltip: '删除条件',
                onPressed: () => _removeCondition(index),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<HotspotFilterOperator>(
                  initialValue: condition.operator,
                  decoration: const InputDecoration(labelText: '比较方式'),
                  items: HotspotFilterOperator.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _replaceCondition(
                        index,
                        condition.copyWith(
                          operator: value,
                          upperValue: value == HotspotFilterOperator.between
                              ? condition.upperValue ?? condition.value
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numberField(
                  label: condition.operator == HotspotFilterOperator.between
                      ? '下限'
                      : '阈值 ${condition.metric.unit}',
                  value: condition.value,
                  onChanged: (value) {
                    if (value != null) {
                      _replaceCondition(
                        index,
                        condition.copyWith(value: value),
                      );
                    }
                  },
                ),
              ),
              if (condition.operator == HotspotFilterOperator.between) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _numberField(
                    label: '上限',
                    value: condition.upperValue,
                    onChanged: (value) => _replaceCondition(
                      index,
                      condition.copyWith(upperValue: value),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_scheme.logic == HotspotConditionLogic.anyGroup) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: condition.group.clamp(1, 3),
              decoration: const InputDecoration(labelText: '条件组'),
              items: const [1, 2, 3]
                  .map(
                    (group) => DropdownMenuItem(
                      value: group,
                      child: Text('第 $group 组'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _replaceCondition(index, condition.copyWith(group: value));
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _weightCard(int index, HotspotSortWeight weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<HotspotFilterMetric>(
              initialValue: weight.metric,
              decoration: const InputDecoration(labelText: '排序指标'),
              items: HotspotFilterMetric.values
                  .map(
                    (metric) => DropdownMenuItem(
                      value: metric,
                      enabled: metric != HotspotFilterMetric.strategyMatch,
                      child: Text(
                        metric == HotspotFilterMetric.strategyMatch
                            ? '${metric.label}（当前为0）'
                            : metric.label,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _replaceWeight(index, weight.copyWith(metric: value));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              label: '权重',
              value: weight.weight,
              onChanged: (value) {
                if (value != null) {
                  _replaceWeight(index, weight.copyWith(weight: value));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<HotspotSortDirection>(
              initialValue: weight.direction,
              decoration: const InputDecoration(labelText: '方向'),
              items: HotspotSortDirection.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _replaceWeight(index, weight.copyWith(direction: value));
                }
              },
            ),
          ),
          IconButton(
            tooltip: '删除排序指标',
            onPressed: () => _removeWeight(index),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required double? value,
    required ValueChanged<double?> onChanged,
  }) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value?.toStringAsFixed(
        value == value.roundToDouble() ? 0 : 2,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,4}')),
      ],
      decoration: InputDecoration(labelText: label),
      onChanged: (text) =>
          onChanged(text.trim().isEmpty ? null : double.tryParse(text.trim())),
    );
  }

  void _addCondition() {
    setState(() {
      _scheme = _scheme.copyWith(
        conditions: [
          ..._scheme.conditions,
          const HotspotFilterCondition(
            metric: HotspotFilterMetric.turnover,
            operator: HotspotFilterOperator.greaterThanOrEqual,
            value: 3,
          ),
        ],
      );
    });
  }

  void _replaceCondition(int index, HotspotFilterCondition condition) {
    final values = [..._scheme.conditions]..[index] = condition;
    setState(() => _scheme = _scheme.copyWith(conditions: values));
  }

  void _removeCondition(int index) {
    final values = [..._scheme.conditions]..removeAt(index);
    setState(() => _scheme = _scheme.copyWith(conditions: values));
  }

  void _addWeight() {
    setState(() {
      _scheme = _scheme.copyWith(
        sortWeights: [
          ..._scheme.sortWeights,
          const HotspotSortWeight(
            metric: HotspotFilterMetric.amount,
            weight: 10,
          ),
        ],
      );
    });
  }

  void _replaceWeight(int index, HotspotSortWeight weight) {
    final values = [..._scheme.sortWeights]..[index] = weight;
    setState(() => _scheme = _scheme.copyWith(sortWeights: values));
  }

  void _removeWeight(int index) {
    final values = [..._scheme.sortWeights]..removeAt(index);
    setState(() => _scheme = _scheme.copyWith(sortWeights: values));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(hotspotProvider.notifier)
          .saveScheme(_scheme.copyWith(isEnabled: false));
      if (!mounted) return;
      final errors = saved.validate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.isEmpty ? '方案已保存，请在管理页确认启用' : '方案已保存为草稿'),
        ),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
