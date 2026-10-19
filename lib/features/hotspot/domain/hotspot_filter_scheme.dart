import 'hotspot_models.dart';

enum HotspotFilterMetric {
  amountPercentile('板块成交额百分位', '%'),
  amount('成交额', '元'),
  volume('成交量', '手'),
  turnover('换手率', '%'),
  volumeRatio('量比', ''),
  changePct('涨跌幅', '%'),
  absoluteChangePct('涨跌幅绝对值', '%'),
  amplitude('振幅', '%'),
  return5d('近5日涨跌幅', '%'),
  relativeStrength5d('近5日相对板块强度', '%'),
  activeTradingDays5d('近5日有效交易天数', '天'),
  strategyMatch('策略匹配分', '分');

  final String label;
  final String unit;
  const HotspotFilterMetric(this.label, this.unit);

  bool get isCommon => const {
    HotspotFilterMetric.amount,
    HotspotFilterMetric.volume,
    HotspotFilterMetric.turnover,
    HotspotFilterMetric.volumeRatio,
    HotspotFilterMetric.changePct,
    HotspotFilterMetric.amplitude,
    HotspotFilterMetric.return5d,
    HotspotFilterMetric.strategyMatch,
  }.contains(this);
}

enum HotspotFilterOperator {
  greaterThanOrEqual('不低于'),
  lessThanOrEqual('不高于'),
  greaterThan('大于'),
  lessThan('小于'),
  between('区间内');

  final String label;
  const HotspotFilterOperator(this.label);
}

enum HotspotConditionLogic {
  all('全部满足（AND）'),
  anyGroup('任一条件组满足（组间 OR）');

  final String label;
  const HotspotConditionLogic(this.label);
}

enum HotspotSortDirection {
  highFirst('数值高优先'),
  lowFirst('数值低优先');

  final String label;
  const HotspotSortDirection(this.label);
}

class HotspotFilterCondition {
  final HotspotFilterMetric metric;
  final HotspotFilterOperator operator;
  final double value;
  final double? upperValue;
  final int group;

  const HotspotFilterCondition({
    required this.metric,
    required this.operator,
    required this.value,
    this.upperValue,
    this.group = 1,
  });

  List<String> validate() {
    final errors = <String>[];
    if (!value.isFinite) errors.add('${metric.label}阈值无效');
    if (operator == HotspotFilterOperator.between) {
      if (upperValue == null || !upperValue!.isFinite) {
        errors.add('${metric.label}需要填写区间上限');
      } else if (upperValue! < value) {
        errors.add('${metric.label}区间上限不能小于下限');
      }
    }
    if (group < 1) errors.add('条件组编号必须从 1 开始');
    return errors;
  }

  HotspotFilterCondition copyWith({
    HotspotFilterMetric? metric,
    HotspotFilterOperator? operator,
    double? value,
    Object? upperValue = _unchanged,
    int? group,
  }) => HotspotFilterCondition(
    metric: metric ?? this.metric,
    operator: operator ?? this.operator,
    value: value ?? this.value,
    upperValue: identical(upperValue, _unchanged)
        ? this.upperValue
        : (upperValue as num?)?.toDouble(),
    group: group ?? this.group,
  );

  Map<String, dynamic> toJson() => {
    'metric': metric.name,
    'operator': operator.name,
    'value': value,
    'upperValue': upperValue,
    'group': group,
  };

  factory HotspotFilterCondition.fromJson(Map<String, dynamic> json) =>
      HotspotFilterCondition(
        metric: HotspotFilterMetric.values.byName(json['metric'] as String),
        operator: HotspotFilterOperator.values.byName(
          json['operator'] as String,
        ),
        value: (json['value'] as num).toDouble(),
        upperValue: (json['upperValue'] as num?)?.toDouble(),
        group: (json['group'] as num?)?.toInt() ?? 1,
      );

  static const _unchanged = Object();
}

class HotspotSortWeight {
  final HotspotFilterMetric metric;
  final double weight;
  final HotspotSortDirection direction;

  const HotspotSortWeight({
    required this.metric,
    required this.weight,
    this.direction = HotspotSortDirection.highFirst,
  });

  HotspotSortWeight copyWith({
    HotspotFilterMetric? metric,
    double? weight,
    HotspotSortDirection? direction,
  }) => HotspotSortWeight(
    metric: metric ?? this.metric,
    weight: weight ?? this.weight,
    direction: direction ?? this.direction,
  );

  Map<String, dynamic> toJson() => {
    'metric': metric.name,
    'weight': weight,
    'direction': direction.name,
  };

  factory HotspotSortWeight.fromJson(Map<String, dynamic> json) =>
      HotspotSortWeight(
        metric: HotspotFilterMetric.values.byName(json['metric'] as String),
        weight: (json['weight'] as num).toDouble(),
        direction: HotspotSortDirection.values.byName(
          json['direction'] as String? ?? HotspotSortDirection.highFirst.name,
        ),
      );
}

class HotspotFilterScheme {
  final String id;
  final String name;
  final HotspotStockMode target;
  final HotspotConditionLogic logic;
  final List<HotspotFilterCondition> conditions;
  final List<HotspotSortWeight> sortWeights;
  final int resultLimit;
  final bool excludeRiskWarnings;
  final bool excludeSuspended;
  final double? minPrice;
  final double? maxPrice;
  final bool isEnabled;
  final bool isSystem;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastRunAt;
  final int? lastMatchCount;

  const HotspotFilterScheme({
    required this.id,
    required this.name,
    required this.target,
    required this.logic,
    required this.conditions,
    required this.sortWeights,
    required this.resultLimit,
    required this.excludeRiskWarnings,
    required this.excludeSuspended,
    required this.isEnabled,
    required this.isSystem,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.minPrice,
    this.maxPrice,
    this.lastRunAt,
    this.lastMatchCount,
  });

  factory HotspotFilterScheme.blank({
    required HotspotStockMode target,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return HotspotFilterScheme(
      id: 'hotspot_${timestamp.microsecondsSinceEpoch}',
      name: '${target.label}自定义方案',
      target: target,
      logic: HotspotConditionLogic.all,
      conditions: const [
        HotspotFilterCondition(
          metric: HotspotFilterMetric.volumeRatio,
          operator: HotspotFilterOperator.greaterThanOrEqual,
          value: 1.5,
        ),
      ],
      sortWeights: const [
        HotspotSortWeight(metric: HotspotFilterMetric.volumeRatio, weight: 100),
      ],
      resultLimit: 10,
      excludeRiskWarnings: true,
      excludeSuspended: true,
      isEnabled: false,
      isSystem: false,
      version: 1,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  factory HotspotFilterScheme.systemDefault(
    HotspotStockMode target, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    if (target == HotspotStockMode.leader) {
      return HotspotFilterScheme(
        id: 'system_leader',
        name: '系统默认龙头观察',
        target: target,
        logic: HotspotConditionLogic.all,
        conditions: const [
          HotspotFilterCondition(
            metric: HotspotFilterMetric.amountPercentile,
            operator: HotspotFilterOperator.greaterThanOrEqual,
            value: 70,
          ),
          HotspotFilterCondition(
            metric: HotspotFilterMetric.turnover,
            operator: HotspotFilterOperator.between,
            value: 2,
            upperValue: 25,
          ),
          HotspotFilterCondition(
            metric: HotspotFilterMetric.volumeRatio,
            operator: HotspotFilterOperator.greaterThanOrEqual,
            value: 1.2,
          ),
          HotspotFilterCondition(
            metric: HotspotFilterMetric.relativeStrength5d,
            operator: HotspotFilterOperator.greaterThan,
            value: 0,
          ),
          HotspotFilterCondition(
            metric: HotspotFilterMetric.activeTradingDays5d,
            operator: HotspotFilterOperator.greaterThanOrEqual,
            value: 4,
          ),
        ],
        sortWeights: const [
          HotspotSortWeight(
            metric: HotspotFilterMetric.amountPercentile,
            weight: 30,
          ),
          HotspotSortWeight(
            metric: HotspotFilterMetric.relativeStrength5d,
            weight: 25,
          ),
          HotspotSortWeight(
            metric: HotspotFilterMetric.activeTradingDays5d,
            weight: 15,
          ),
          HotspotSortWeight(metric: HotspotFilterMetric.turnover, weight: 15),
          HotspotSortWeight(metric: HotspotFilterMetric.changePct, weight: 10),
          HotspotSortWeight(
            metric: HotspotFilterMetric.strategyMatch,
            weight: 5,
          ),
        ],
        resultLimit: 10,
        excludeRiskWarnings: true,
        excludeSuspended: true,
        isEnabled: true,
        isSystem: true,
        version: 1,
        createdAt: timestamp,
        updatedAt: timestamp,
      );
    }
    return HotspotFilterScheme(
      id: 'system_active',
      name: '系统默认热点观察',
      target: target,
      logic: HotspotConditionLogic.all,
      conditions: const [
        HotspotFilterCondition(
          metric: HotspotFilterMetric.amountPercentile,
          operator: HotspotFilterOperator.greaterThanOrEqual,
          value: 60,
        ),
        HotspotFilterCondition(
          metric: HotspotFilterMetric.volumeRatio,
          operator: HotspotFilterOperator.greaterThanOrEqual,
          value: 1.5,
        ),
        HotspotFilterCondition(
          metric: HotspotFilterMetric.turnover,
          operator: HotspotFilterOperator.greaterThanOrEqual,
          value: 3,
        ),
        HotspotFilterCondition(
          metric: HotspotFilterMetric.amplitude,
          operator: HotspotFilterOperator.greaterThanOrEqual,
          value: 3,
        ),
      ],
      sortWeights: const [
        HotspotSortWeight(metric: HotspotFilterMetric.volumeRatio, weight: 30),
        HotspotSortWeight(metric: HotspotFilterMetric.turnover, weight: 25),
        HotspotSortWeight(
          metric: HotspotFilterMetric.amountPercentile,
          weight: 20,
        ),
        HotspotSortWeight(metric: HotspotFilterMetric.amplitude, weight: 15),
        HotspotSortWeight(
          metric: HotspotFilterMetric.absoluteChangePct,
          weight: 10,
        ),
      ],
      resultLimit: 10,
      excludeRiskWarnings: true,
      excludeSuspended: true,
      isEnabled: true,
      isSystem: true,
      version: 1,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  factory HotspotFilterScheme.copyOfDefault(
    HotspotStockMode target, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final source = HotspotFilterScheme.systemDefault(target, now: timestamp);
    return source.copyWith(
      id: 'hotspot_${timestamp.microsecondsSinceEpoch}',
      name: '${source.name}（副本）',
      isSystem: false,
      isEnabled: false,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  List<String> validate() {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('请填写方案名称');
    if (name.trim().length > 30) errors.add('方案名称不能超过30个字');
    if (conditions.isEmpty) errors.add('至少添加一个筛选条件');
    for (final condition in conditions) {
      errors.addAll(condition.validate());
    }
    if (sortWeights.isEmpty || sortWeights.every((item) => item.weight <= 0)) {
      errors.add('至少设置一个大于0的排序权重');
    }
    if (sortWeights.any((item) => !item.weight.isFinite || item.weight < 0)) {
      errors.add('排序权重不能为负数或无效数字');
    }
    if (resultLimit < 1 || resultLimit > 50) {
      errors.add('返回数量必须在1到50之间');
    }
    if (minPrice != null && maxPrice != null && maxPrice! < minPrice!) {
      errors.add('最高价格不能低于最低价格');
    }
    return errors;
  }

  bool get canEnable => validate().isEmpty && !isSystem;

  HotspotFilterScheme copyWith({
    String? id,
    String? name,
    HotspotStockMode? target,
    HotspotConditionLogic? logic,
    List<HotspotFilterCondition>? conditions,
    List<HotspotSortWeight>? sortWeights,
    int? resultLimit,
    bool? excludeRiskWarnings,
    bool? excludeSuspended,
    Object? minPrice = _unchanged,
    Object? maxPrice = _unchanged,
    bool? isEnabled,
    bool? isSystem,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastRunAt = _unchanged,
    Object? lastMatchCount = _unchanged,
  }) => HotspotFilterScheme(
    id: id ?? this.id,
    name: name ?? this.name,
    target: target ?? this.target,
    logic: logic ?? this.logic,
    conditions: conditions ?? this.conditions,
    sortWeights: sortWeights ?? this.sortWeights,
    resultLimit: resultLimit ?? this.resultLimit,
    excludeRiskWarnings: excludeRiskWarnings ?? this.excludeRiskWarnings,
    excludeSuspended: excludeSuspended ?? this.excludeSuspended,
    minPrice: identical(minPrice, _unchanged)
        ? this.minPrice
        : (minPrice as num?)?.toDouble(),
    maxPrice: identical(maxPrice, _unchanged)
        ? this.maxPrice
        : (maxPrice as num?)?.toDouble(),
    isEnabled: isEnabled ?? this.isEnabled,
    isSystem: isSystem ?? this.isSystem,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastRunAt: identical(lastRunAt, _unchanged)
        ? this.lastRunAt
        : lastRunAt as DateTime?,
    lastMatchCount: identical(lastMatchCount, _unchanged)
        ? this.lastMatchCount
        : lastMatchCount as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'target': target.name,
    'logic': logic.name,
    'conditions': conditions.map((item) => item.toJson()).toList(),
    'sortWeights': sortWeights.map((item) => item.toJson()).toList(),
    'resultLimit': resultLimit,
    'excludeRiskWarnings': excludeRiskWarnings,
    'excludeSuspended': excludeSuspended,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
    'isEnabled': isEnabled,
    'isSystem': isSystem,
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastRunAt': lastRunAt?.toIso8601String(),
    'lastMatchCount': lastMatchCount,
  };

  factory HotspotFilterScheme.fromJson(Map<String, dynamic> json) =>
      HotspotFilterScheme(
        id: json['id'] as String,
        name: json['name'] as String,
        target: HotspotStockMode.values.byName(json['target'] as String),
        logic: HotspotConditionLogic.values.byName(json['logic'] as String),
        conditions: (json['conditions'] as List<dynamic>)
            .map(
              (item) =>
                  HotspotFilterCondition.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        sortWeights: (json['sortWeights'] as List<dynamic>)
            .map(
              (item) =>
                  HotspotSortWeight.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        resultLimit: (json['resultLimit'] as num).toInt(),
        excludeRiskWarnings: json['excludeRiskWarnings'] as bool? ?? true,
        excludeSuspended: json['excludeSuspended'] as bool? ?? true,
        minPrice: (json['minPrice'] as num?)?.toDouble(),
        maxPrice: (json['maxPrice'] as num?)?.toDouble(),
        isEnabled: json['isEnabled'] as bool? ?? false,
        isSystem: json['isSystem'] as bool? ?? false,
        version: (json['version'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        lastRunAt: json['lastRunAt'] == null
            ? null
            : DateTime.parse(json['lastRunAt'] as String),
        lastMatchCount: (json['lastMatchCount'] as num?)?.toInt(),
      );

  static const _unchanged = Object();
}

class HotspotSchemeRevision {
  final int version;
  final DateTime savedAt;
  final HotspotFilterScheme snapshot;

  const HotspotSchemeRevision({
    required this.version,
    required this.savedAt,
    required this.snapshot,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'savedAt': savedAt.toIso8601String(),
    'snapshot': snapshot.toJson(),
  };

  factory HotspotSchemeRevision.fromJson(Map<String, dynamic> json) =>
      HotspotSchemeRevision(
        version: (json['version'] as num).toInt(),
        savedAt: DateTime.parse(json['savedAt'] as String),
        snapshot: HotspotFilterScheme.fromJson(
          json['snapshot'] as Map<String, dynamic>,
        ),
      );
}
