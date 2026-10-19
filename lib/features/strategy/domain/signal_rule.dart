/// A declarative rule that evaluates a technical indicator against a condition.
class SignalRule {
  final String
  indicator; // Includes technical indicators plus price/MA, environment and structural-pattern indicators.
  final String
  condition; // Includes scalar, cross, and multi-day confirmation conditions.
  final double value;
  final double? value2; // for 'in_range' upper bound

  /// Number of consecutive trading bars required by a confirmed-cross rule.
  /// For example, 2 means the crossing bar plus the following trading bar.
  final int confirmationDays;

  /// Lookback used by derived indicators such as the short-MA slope based
  /// market environment. Calendar gaps do not affect this value.
  final int lookbackDays;

  /// Second indicator for indicator-cross conditions (e.g. 'ma_short' cross_up 'ma_long').
  /// When set, this rule evaluates whether [indicator] crosses [indicator2].
  final String? indicator2;

  const SignalRule({
    required this.indicator,
    required this.condition,
    required this.value,
    this.value2,
    this.indicator2,
    this.confirmationDays = 1,
    this.lookbackDays = 5,
  });

  /// Whether this rule requires indicator-vs-indicator cross evaluation.
  bool get isIndicatorCross =>
      condition == 'indicator_cross_up' || condition == 'indicator_cross_down';

  bool get isConfirmedCross =>
      condition == 'cross_up_confirmed' || condition == 'cross_down_confirmed';

  /// Evaluate the rule against a current value.
  bool evaluate(double current) {
    switch (condition) {
      case 'gt':
      case 'above':
        return current > value;
      case 'lt':
      case 'below':
        return current < value;
      case 'in_range':
        return current >= value && current <= (value2 ?? value);
      default:
        return false;
    }
  }

  /// Evaluate cross conditions with previous value.
  bool evaluateWithPrev(double previous, double current) {
    switch (condition) {
      case 'cross_up':
        return previous < value && current >= value;
      case 'cross_down':
        return previous > value && current <= value;
      default:
        return evaluate(current);
    }
  }

  /// Evaluate indicator-vs-indicator cross conditions.
  /// [prevA] / [curA] = previous/current values of the primary indicator.
  /// [prevB] / [curB] = previous/current values of the secondary indicator.
  bool evaluateIndicatorCross({
    required double prevA,
    required double curA,
    required double prevB,
    required double curB,
  }) {
    switch (condition) {
      case 'indicator_cross_up':
        // A was below B, now A >= B (A crosses above B)
        return prevA < prevB && curA >= curB;
      case 'indicator_cross_down':
        // A was above B, now A <= B (A crosses below B)
        return prevA > prevB && curA <= curB;
      default:
        return false;
    }
  }

  Map<String, dynamic> toJson() => {
    'indicator': indicator,
    'condition': condition,
    'value': value,
    if (value2 != null) 'value2': value2,
    if (indicator2 != null) 'indicator2': indicator2,
    if (confirmationDays != 1) 'confirmationDays': confirmationDays,
    if (lookbackDays != 5) 'lookbackDays': lookbackDays,
  };

  factory SignalRule.fromJson(Map<String, dynamic> json) {
    final confirmationDays = (json['confirmationDays'] as num?)?.toInt() ?? 1;
    final lookbackDays = (json['lookbackDays'] as num?)?.toInt() ?? 5;
    if (confirmationDays < 1 || confirmationDays > 20) {
      throw const FormatException('confirmationDays 必须在 1-20 之间');
    }
    if (lookbackDays < 1 || lookbackDays > 60) {
      throw const FormatException('lookbackDays 必须在 1-60 之间');
    }
    return SignalRule(
      indicator: json['indicator'] as String,
      condition: json['condition'] as String,
      value: (json['value'] as num).toDouble(),
      value2: json['value2'] != null
          ? (json['value2'] as num).toDouble()
          : null,
      indicator2: json['indicator2'] as String?,
      confirmationDays: confirmationDays,
      lookbackDays: lookbackDays,
    );
  }
}

/// A group of rules with AND logic within the group.
/// Multiple groups are combined with OR logic.
class RuleGroup {
  final List<SignalRule> rules;

  const RuleGroup({required this.rules});

  bool get isEmpty => rules.isEmpty;
  bool get isNotEmpty => rules.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'rules': rules.map((r) => r.toJson()).toList(),
  };

  factory RuleGroup.fromJson(Map<String, dynamic> json) => RuleGroup(
    rules: (json['rules'] as List)
        .map((r) => SignalRule.fromJson(r as Map<String, dynamic>))
        .toList(),
  );
}
