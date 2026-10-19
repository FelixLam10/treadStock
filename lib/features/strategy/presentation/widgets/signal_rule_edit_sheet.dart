import 'package:flutter/material.dart';
import 'package:stockpilot/core/theme/app_semantic_colors.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/signal_rule.dart';

const _indicatorLabels = {
  'rsi': 'RSI',
  'macd': 'MACD',
  'macd_signal': 'MACD 信号线',
  'macd_hist': 'MACD 柱状图',
  'k': 'K 值',
  'd': 'D 值',
  'j': 'J 值',
  'boll_position': '布林带位置',
  'ma_alignment': '均线排列度',
  'vol_price_divergence': '量价背离',
  'vol_ratio': '量比',
  'price_ma_short': '收盘价相对短期均线（%）',
  'price_ma_long': '收盘价相对长期均线（%）',
  'market_environment': '短期均线趋势环境',
  'ladder_breakout': '梯级平台突破',
  'ladder_support_gap_pct': '梯级平台支撑距离（%）',
  'chan_third_buy': '简化缠论三买结构',
  'chan_center_support_gap_pct': '简化中枢上沿距离（%）',
};

const _conditionLabels = {
  'gt': '大于',
  'lt': '小于',
  'in_range': '区间内',
  'cross_up': '上穿',
  'cross_down': '下穿',
  'above': '高于',
  'below': '低于',
  'cross_up_confirmed': '上穿后连续确认',
  'cross_down_confirmed': '下穿后连续确认',
  'uptrend': '上升趋势',
  'downtrend': '下降趋势',
  'sideways': '横盘震荡',
  'not_sideways': '非横盘环境',
};

Map<String, String> _conditionsForIndicator(String indicator) {
  if (indicator == 'price_ma_short' || indicator == 'price_ma_long') {
    const keys = [
      'above',
      'below',
      'cross_up_confirmed',
      'cross_down_confirmed',
    ];
    return {for (final key in keys) key: _conditionLabels[key]!};
  }
  if (indicator == 'market_environment') {
    const keys = ['uptrend', 'downtrend', 'sideways', 'not_sideways'];
    return {for (final key in keys) key: _conditionLabels[key]!};
  }
  const keys = ['gt', 'lt', 'in_range', 'cross_up', 'cross_down'];
  return {for (final key in keys) key: _conditionLabels[key]!};
}

/// Bottom sheet for adding/editing a single SignalRule.
/// Returns SignalRule? when user confirms, null on cancel.
class SignalRuleEditSheet extends StatefulWidget {
  final SignalRule? initialRule; // null = add new, non-null = edit existing

  const SignalRuleEditSheet({super.key, this.initialRule});

  @override
  State<SignalRuleEditSheet> createState() => _SignalRuleEditSheetState();

  static Future<SignalRule?> show(
    BuildContext context, {
    SignalRule? initialRule,
  }) {
    return showModalBottomSheet<SignalRule>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SignalRuleEditSheet(initialRule: initialRule),
    );
  }
}

class _SignalRuleEditSheetState extends State<SignalRuleEditSheet> {
  late String _indicator;
  late String _condition;
  late TextEditingController _valueController;
  late TextEditingController _value2Controller;
  late TextEditingController _confirmationDaysController;
  late TextEditingController _lookbackDaysController;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;
    _indicator = rule?.indicator ?? 'rsi';
    _condition = rule?.condition ?? 'gt';
    _valueController = TextEditingController(
      text: rule != null ? rule.value.toString() : '',
    );
    _value2Controller = TextEditingController(
      text: rule?.value2 != null ? rule!.value2.toString() : '',
    );
    _confirmationDaysController = TextEditingController(
      text: '${rule?.confirmationDays ?? 2}',
    );
    _lookbackDaysController = TextEditingController(
      text: '${rule?.lookbackDays ?? 5}',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _value2Controller.dispose();
    _confirmationDaysController.dispose();
    _lookbackDaysController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.initialRule != null;

  void _handleConfirm() {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的阈值')));
      return;
    }

    double? value2;
    if (_condition == 'in_range') {
      value2 = double.tryParse(_value2Controller.text.trim());
      if (value2 == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请输入有效的区间上限')));
        return;
      }
    }

    final rule = SignalRule(
      indicator: _indicator,
      condition: _condition,
      value: value,
      value2: value2,
      confirmationDays: _isConfirmedCondition
          ? (int.tryParse(_confirmationDaysController.text.trim()) ?? 2).clamp(
              1,
              20,
            )
          : 1,
      lookbackDays: _indicator == 'market_environment'
          ? (int.tryParse(_lookbackDaysController.text.trim()) ?? 5).clamp(
              1,
              60,
            )
          : 5,
    );
    Navigator.of(context).pop(rule);
  }

  bool get _isConfirmedCondition =>
      _condition == 'cross_up_confirmed' ||
      _condition == 'cross_down_confirmed';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.pagePadding,
        right: AppTheme.pagePadding,
        top: AppTheme.pagePadding,
        bottom: bottomInset.bottom + AppTheme.pagePadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(_isEditMode ? '编辑规则' : '添加规则', style: AppTextStyles.h2),
          const SizedBox(height: 20),

          // Indicator selector
          Text(
            '指标',
            style: AppTextStyles.body.copyWith(color: context.sc.textSecondary),
          ),
          const SizedBox(height: 4),
          _buildDropdown(
            value: _indicator,
            items: _indicatorLabels,
            onChanged: (v) => setState(() {
              _indicator = v!;
              final conditions = _conditionsForIndicator(_indicator);
              if (!conditions.containsKey(_condition)) {
                _condition = conditions.keys.first;
              }
            }),
          ),
          const SizedBox(height: 16),

          // Condition selector
          Text(
            '条件',
            style: AppTextStyles.body.copyWith(color: context.sc.textSecondary),
          ),
          const SizedBox(height: 4),
          _buildDropdown(
            value: _condition,
            items: _conditionsForIndicator(_indicator),
            onChanged: (v) => setState(() => _condition = v!),
          ),
          const SizedBox(height: 16),

          // Threshold input
          Text(
            _condition == 'in_range'
                ? '下限值'
                : _indicator == 'market_environment'
                ? '横盘斜率阈值（%）'
                : _indicator.startsWith('price_ma_')
                ? '相对均线阈值（%）'
                : '阈值',
            style: AppTextStyles.body.copyWith(color: context.sc.textSecondary),
          ),

          if (_isConfirmedCondition) ...[
            const SizedBox(height: 16),
            Text(
              '连续确认交易日',
              style: AppTextStyles.body.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _confirmationDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '例如 2：穿越当日 + 下一交易日',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],

          if (_indicator == 'market_environment') ...[
            const SizedBox(height: 16),
            Text(
              '均线斜率观察交易日',
              style: AppTextStyles.body.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _lookbackDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '默认 5 个交易日',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
          const SizedBox(height: 4),
          TextField(
            controller: _valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '输入数值',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),

          // Second threshold for in_range
          if (_condition == 'in_range') ...[
            const SizedBox(height: 16),
            Text(
              '上限值',
              style: AppTextStyles.body.copyWith(
                color: context.sc.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _value2Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: '输入上限数值',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _handleConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: StockColors.brand,
                  ),
                  child: const Text('确定'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: context.sc.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
        ),
      ),
    );
  }
}
