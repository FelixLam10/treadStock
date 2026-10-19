import 'dart:convert';

import 'signal_rule.dart';
import 'strategy_models.dart';

const int strategyKnowledgePackageVersion = 1;

enum StrategyKnowledgeType { general, personal, custom }

extension StrategyKnowledgeTypeX on StrategyKnowledgeType {
  String get code => switch (this) {
    StrategyKnowledgeType.general => 'general',
    StrategyKnowledgeType.personal => 'personal',
    StrategyKnowledgeType.custom => 'custom',
  };

  String get label => switch (this) {
    StrategyKnowledgeType.general => '通用策略',
    StrategyKnowledgeType.personal => '人物经验策略',
    StrategyKnowledgeType.custom => '自定义策略',
  };

  static StrategyKnowledgeType parse(String value) {
    return switch (value) {
      'general' => StrategyKnowledgeType.general,
      'personal' => StrategyKnowledgeType.personal,
      'custom' => StrategyKnowledgeType.custom,
      _ => throw FormatException('不支持的策略类型：$value'),
    };
  }
}

enum StrategySourceKind { book, article, chat, note, other }

extension StrategySourceKindX on StrategySourceKind {
  String get code => switch (this) {
    StrategySourceKind.book => 'book',
    StrategySourceKind.article => 'article',
    StrategySourceKind.chat => 'chat',
    StrategySourceKind.note => 'note',
    StrategySourceKind.other => 'other',
  };

  String get label => switch (this) {
    StrategySourceKind.book => '书籍资料',
    StrategySourceKind.article => '市场文章',
    StrategySourceKind.chat => '聊天记录',
    StrategySourceKind.note => '个人笔记',
    StrategySourceKind.other => '其他来源',
  };

  static StrategySourceKind parse(String value) {
    return switch (value) {
      'book' => StrategySourceKind.book,
      'article' => StrategySourceKind.article,
      'chat' => StrategySourceKind.chat,
      'note' => StrategySourceKind.note,
      'other' => StrategySourceKind.other,
      _ => throw FormatException('不支持的来源类型：$value'),
    };
  }
}

enum StrategyRuleStatus { explicit, inferred, pending, unsupported }

extension StrategyRuleStatusX on StrategyRuleStatus {
  String get code => name;

  String get label => switch (this) {
    StrategyRuleStatus.explicit => '原文明确',
    StrategyRuleStatus.inferred => '智能助手推断',
    StrategyRuleStatus.pending => '待确认',
    StrategyRuleStatus.unsupported => '当前不支持',
  };

  static StrategyRuleStatus parse(String value) {
    return StrategyRuleStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => throw FormatException('不支持的规则状态：$value'),
    );
  }
}

enum StrategyEngineSupport { supported, partial, unsupported }

extension StrategyEngineSupportX on StrategyEngineSupport {
  String get code => name;

  String get label => switch (this) {
    StrategyEngineSupport.supported => '当前可执行',
    StrategyEngineSupport.partial => '部分支持',
    StrategyEngineSupport.unsupported => '当前不可执行',
  };

  static StrategyEngineSupport parse(String value) {
    return StrategyEngineSupport.values.firstWhere(
      (item) => item.name == value,
      orElse: () => throw FormatException('不支持的引擎兼容状态：$value'),
    );
  }
}

class StrategyKnowledgeSource {
  final String externalRef;
  final StrategySourceKind kind;
  final String? speaker;
  final DateTime? capturedAt;
  final String summary;
  final String? sanitizedText;
  final String fingerprint;

  const StrategyKnowledgeSource({
    required this.externalRef,
    required this.kind,
    this.speaker,
    this.capturedAt,
    required this.summary,
    this.sanitizedText,
    required this.fingerprint,
  });

  Map<String, dynamic> toJson() => {
    'sourceId': externalRef,
    'type': kind.code,
    if (speaker != null) 'speaker': speaker,
    if (capturedAt != null) 'capturedAt': capturedAt!.toIso8601String(),
    'summary': summary,
    if (sanitizedText != null) 'sanitizedText': sanitizedText,
    'fingerprint': fingerprint,
  };
}

class StrategyKnowledgeRule {
  final String id;
  final String title;
  final String statement;
  final StrategyRuleStatus status;
  final StrategyEngineSupport engineSupport;
  final List<String> sourceRefs;

  const StrategyKnowledgeRule({
    required this.id,
    required this.title,
    required this.statement,
    required this.status,
    required this.engineSupport,
    required this.sourceRefs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'statement': statement,
    'status': status.code,
    'engineSupport': engineSupport.code,
    'sourceRefs': sourceRefs,
  };
}

class StrategyCompatibilityIssue {
  final String code;
  final String message;
  final bool blocking;

  const StrategyCompatibilityIssue({
    required this.code,
    required this.message,
    this.blocking = false,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'blocking': blocking,
  };

  factory StrategyCompatibilityIssue.fromJson(Map<String, dynamic> json) {
    return StrategyCompatibilityIssue(
      code: _requiredString(json, 'code'),
      message: _requiredString(json, 'message'),
      blocking: json['blocking'] as bool? ?? false,
    );
  }
}

class StrategyApplicability {
  final List<String> markets;
  final List<String> environments;
  final List<String> invalidEnvironments;

  const StrategyApplicability({
    this.markets = const [],
    this.environments = const [],
    this.invalidEnvironments = const [],
  });

  Map<String, dynamic> toJson() => {
    'markets': markets,
    'environments': environments,
    'invalidEnvironments': invalidEnvironments,
  };
}

class StrategyKnowledgePackage {
  final int packageVersion;
  final StrategyKnowledgeType strategyType;
  final StrategyFormData form;
  final List<StrategyKnowledgeSource> sources;
  final List<StrategyKnowledgeRule> rules;
  final StrategyApplicability applicability;
  final List<String> riskNotes;
  final List<String> pendingQuestions;
  final List<StrategyCompatibilityIssue> compatibilityIssues;

  const StrategyKnowledgePackage({
    required this.packageVersion,
    required this.strategyType,
    required this.form,
    required this.sources,
    required this.rules,
    required this.applicability,
    required this.riskNotes,
    required this.pendingQuestions,
    required this.compatibilityIssues,
  });

  bool get hasBlockingIssue =>
      compatibilityIssues.any((issue) => issue.blocking) ||
      (rules.any(
            (rule) =>
                rule.engineSupport == StrategyEngineSupport.supported &&
                rule.status != StrategyRuleStatus.pending,
          ) &&
          form.entryRules.isEmpty &&
          form.exitRules.isEmpty) ||
      rules.any(
        (rule) =>
            rule.status == StrategyRuleStatus.unsupported ||
            rule.engineSupport == StrategyEngineSupport.unsupported,
      );

  bool get needsConfirmation =>
      pendingQuestions.isNotEmpty ||
      rules.any((rule) => rule.status == StrategyRuleStatus.pending);

  bool get canEnable => !hasBlockingIssue && !needsConfirmation;

  Map<String, dynamic> toJson() => {
    'packageVersion': packageVersion,
    'strategy': {
      'name': form.name,
      'type': strategyType.code,
      'description': form.description,
      'parameters': {
        'maShortPeriod': form.maShortPeriod,
        'maLongPeriod': form.maLongPeriod,
        'bollPeriod': form.bollPeriod,
        'bollStdDev': form.bollStdDev,
        'weightMA': form.weightMA,
        'weightBoll': form.weightBoll,
        'weightVol': form.weightVol,
        'weightTrend': form.weightTrend,
        'recommendThreshold': form.recommendThreshold,
      },
      if (form.entryRules.isNotEmpty || form.exitRules.isNotEmpty)
        'execution': {
          'entryRules': form.entryRules.map((rule) => rule.toJson()).toList(),
          'exitRules': form.exitRules.map((rule) => rule.toJson()).toList(),
        },
    },
    'sources': sources.map((source) => source.toJson()).toList(),
    'rules': rules.map((rule) => rule.toJson()).toList(),
    'applicability': applicability.toJson(),
    'riskNotes': riskNotes,
    'pendingQuestions': pendingQuestions,
    'compatibilityIssues': compatibilityIssues
        .map((issue) => issue.toJson())
        .toList(),
  };

  String toCanonicalJson() => jsonEncode(toJson());
}

/// Parser and prompt definition for an agent-produced, reviewable strategy
/// package. This parser deliberately does not attempt to turn arbitrary prose
/// into executable rules inside the app.
class StrategyKnowledgePackageCodec {
  StrategyKnowledgePackageCodec._();

  static const generationPrompt = '''
你是股势 TrendStock 的策略资料整理助手。请把用户提供的书摘、文章、聊天文字或截图内容去噪、脱敏，并只输出一个严格 JSON 对象，不要输出 Markdown。

不得自行补充原文没有给出的仓位、止盈、止损、周期或收益结论。不得把宣传性陈述当成验证证据。可执行规则避免使用“买入、卖出、稳赚、保证收益”，统一改写成“进入观察、退出观察、信号、复盘”。

JSON 顶层格式：
{
  "packageVersion": 1,
  "strategy": {
    "name": "1-20 字符策略名；人物经验建议为 人名 - 交易策略",
    "type": "general | personal | custom",
    "description": "最多 100 字",
    "parameters": {
      "maShortPeriod": 5,
      "maLongPeriod": 60,
      "bollPeriod": 20,
      "bollStdDev": 2.0,
      "weightMA": 0.4,
      "weightBoll": 0.2,
      "weightVol": 0.1,
      "weightTrend": 0.3,
      "recommendThreshold": 7
    },
    "execution": {
      "entryRules": [
        {"indicator":"market_environment","condition":"uptrend","value":0.15,"lookbackDays":5},
        {"indicator":"price_ma_short","condition":"cross_up_confirmed","value":0,"confirmationDays":2}
      ],
      "exitRules": [
        {"indicator":"price_ma_short","condition":"cross_down_confirmed","value":0,"confirmationDays":2}
      ]
    }
  },
  "sources": [{
    "sourceId": "source-1",
    "type": "book | article | chat | note | other",
    "speaker": "可选，聊天说话人",
    "capturedAt": "可选 ISO-8601 时间",
    "summary": "脱敏后的来源摘要",
    "sanitizedText": "可选，只保留与策略有关的脱敏内容",
    "fingerprint": "可选；同一来源保持一致"
  }],
  "rules": [{
    "id": "rule-1",
    "title": "规则标题",
    "statement": "观察式规则陈述",
    "status": "explicit",
    "engineSupport": "supported",
    "sourceRefs": ["source-1"]
  }],
  "applicability": {
    "markets": ["沪深股票"],
    "environments": ["上升趋势"],
    "invalidEnvironments": ["横盘震荡"]
  },
  "riskNotes": ["来源未定义仓位与费用"],
  "pendingQuestions": [],
  "compatibilityIssues": [{
    "code": "multi_day_confirmation",
    "message": "横盘口径采用 5 个交易日 MA5 斜率绝对值不超过 0.15%",
    "blocking": false
  }]
}

execution 仅在原文规则已经明确且可以映射时输出。多日均线支持 price_ma_short / price_ma_long、cross_up_confirmed / cross_down_confirmed、confirmationDays；环境过滤支持 market_environment、uptrend / downtrend / sideways / not_sideways、lookbackDays，value 表示横盘斜率阈值百分比。价格等于均线不算站上或跌破。

参数约束：四个权重之和必须等于 1；其他数值范围遵循 App 现有策略配置。每条规则必须引用至少一个真实 sourceId。原文没有答案的问题必须放进 pendingQuestions，不能猜测；有关键待确认项时不要为了生成 execution 而补答案。
''';

  static StrategyKnowledgePackage parse(String text) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (error) {
      throw FormatException('JSON 解析失败：${error.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('策略包必须是 JSON 对象');
    }

    final version = decoded['packageVersion'];
    if (version is! int) {
      throw const FormatException('缺少有效的 packageVersion');
    }
    if (version != strategyKnowledgePackageVersion) {
      throw FormatException(
        '暂不支持策略包版本 $version，当前仅支持 $strategyKnowledgePackageVersion',
      );
    }

    final strategy = _requiredMap(decoded, 'strategy');
    final name = _requiredString(strategy, 'name');
    final description = _optionalString(strategy, 'description');
    final strategyType = StrategyKnowledgeTypeX.parse(
      _requiredString(strategy, 'type'),
    );
    final parameters = _requiredMap(strategy, 'parameters');
    final execution = strategy['execution'] == null
        ? <String, dynamic>{}
        : _asMap(strategy['execution'], 'strategy.execution');
    final form = StrategyImportHelper.fromJson({
      'name': name,
      'description': description,
      ...parameters,
      if (execution['entryRules'] != null)
        'entryRules': execution['entryRules'],
      if (execution['exitRules'] != null) 'exitRules': execution['exitRules'],
    });
    for (final rule in [...form.entryRules, ...form.exitRules]) {
      _validateExecutableRule(rule);
    }

    final sources = _requiredList(
      decoded,
      'sources',
    ).map((item) => _parseSource(_asMap(item, 'sources 项'))).toList();
    if (sources.isEmpty) {
      throw const FormatException('策略包至少需要一个来源');
    }
    final sourceRefs = <String>{};
    for (final source in sources) {
      if (!sourceRefs.add(source.externalRef)) {
        throw FormatException('来源编号重复：${source.externalRef}');
      }
    }
    if (strategyType == StrategyKnowledgeType.personal &&
        sources.every((source) => source.speaker?.trim().isEmpty ?? true)) {
      throw const FormatException('人物经验策略至少需要一个说话人');
    }

    final rules = _requiredList(
      decoded,
      'rules',
    ).map((item) => _parseRule(_asMap(item, 'rules 项'))).toList();
    if (rules.isEmpty) {
      throw const FormatException('策略包至少需要一条整理后的规则');
    }
    final ruleIds = <String>{};
    for (final rule in rules) {
      if (!ruleIds.add(rule.id)) {
        throw FormatException('规则编号重复：${rule.id}');
      }
      if (rule.sourceRefs.isEmpty) {
        throw FormatException('规则 ${rule.id} 必须引用来源');
      }
      final missingRefs = rule.sourceRefs
          .where((ref) => !sourceRefs.contains(ref))
          .toList();
      if (missingRefs.isNotEmpty) {
        throw FormatException(
          '规则 ${rule.id} 引用了不存在的来源：${missingRefs.join('、')}',
        );
      }
      if (_containsDirectiveLanguage(rule.statement)) {
        throw FormatException('规则 ${rule.id} 含直接操作或收益承诺，请改写为观察式表述');
      }
    }
    final claimsExecutable = rules.any(
      (rule) =>
          rule.engineSupport == StrategyEngineSupport.supported &&
          rule.status != StrategyRuleStatus.pending,
    );
    if (claimsExecutable && form.entryRules.isEmpty && form.exitRules.isEmpty) {
      throw const FormatException('规则标记为当前可执行时，strategy.execution 不能为空');
    }

    final applicabilityJson = decoded['applicability'] == null
        ? <String, dynamic>{}
        : _asMap(decoded['applicability'], 'applicability');
    final applicability = StrategyApplicability(
      markets: _stringList(applicabilityJson, 'markets'),
      environments: _stringList(applicabilityJson, 'environments'),
      invalidEnvironments: _stringList(
        applicabilityJson,
        'invalidEnvironments',
      ),
    );
    final riskNotes = _stringList(decoded, 'riskNotes');
    final pendingQuestions = _stringList(decoded, 'pendingQuestions');
    final compatibilityIssues = _listOrEmpty(decoded, 'compatibilityIssues')
        .map(
          (item) => StrategyCompatibilityIssue.fromJson(
            _asMap(item, 'compatibilityIssues 项'),
          ),
        )
        .toList();

    return StrategyKnowledgePackage(
      packageVersion: version,
      strategyType: strategyType,
      form: form,
      sources: sources,
      rules: rules,
      applicability: applicability,
      riskNotes: riskNotes,
      pendingQuestions: pendingQuestions,
      compatibilityIssues: compatibilityIssues,
    );
  }

  static String? validate(String text) {
    try {
      parse(text);
      return null;
    } on FormatException catch (error) {
      return error.message;
    } catch (_) {
      return '策略包格式不正确';
    }
  }

  static StrategyKnowledgeSource _parseSource(Map<String, dynamic> json) {
    final externalRef = _requiredString(json, 'sourceId');
    final summary = _requiredString(json, 'summary');
    final sanitizedText = _nullableString(json, 'sanitizedText');
    final fingerprint =
        _nullableString(json, 'fingerprint') ??
        _fingerprint('$externalRef|$summary|${sanitizedText ?? ''}');
    final capturedAtText = _nullableString(json, 'capturedAt');
    final capturedAt = capturedAtText == null
        ? null
        : DateTime.tryParse(capturedAtText);
    if (capturedAtText != null && capturedAt == null) {
      throw FormatException('来源 $externalRef 的 capturedAt 不是有效时间');
    }
    return StrategyKnowledgeSource(
      externalRef: externalRef,
      kind: StrategySourceKindX.parse(_requiredString(json, 'type')),
      speaker: _nullableString(json, 'speaker'),
      capturedAt: capturedAt,
      summary: summary,
      sanitizedText: sanitizedText,
      fingerprint: fingerprint,
    );
  }

  static StrategyKnowledgeRule _parseRule(Map<String, dynamic> json) {
    return StrategyKnowledgeRule(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      statement: _requiredString(json, 'statement'),
      status: StrategyRuleStatusX.parse(_requiredString(json, 'status')),
      engineSupport: StrategyEngineSupportX.parse(
        _requiredString(json, 'engineSupport'),
      ),
      sourceRefs: _stringList(json, 'sourceRefs'),
    );
  }

  static bool _containsDirectiveLanguage(String text) {
    const forbidden = ['买入', '卖出', '稳赚', '保证收益', '必涨'];
    return forbidden.any(text.contains);
  }

  static void _validateExecutableRule(SignalRule rule) {
    const indicators = {
      'rsi',
      'macd',
      'macd_signal',
      'macd_hist',
      'k',
      'd',
      'j',
      'boll_position',
      'ma_alignment',
      'vol_price_divergence',
      'vol_ratio',
      'ema',
      'atr',
      'obv',
      'ma_short',
      'ma_long',
      'price_ma_short',
      'price_ma_long',
      'market_environment',
      'ladder_breakout',
      'ladder_support_gap_pct',
      'chan_third_buy',
      'chan_center_support_gap_pct',
    };
    const conditions = {
      'lt',
      'gt',
      'in_range',
      'cross_up',
      'cross_down',
      'indicator_cross_up',
      'indicator_cross_down',
      'above',
      'below',
      'cross_up_confirmed',
      'cross_down_confirmed',
      'uptrend',
      'downtrend',
      'sideways',
      'not_sideways',
    };
    if (!indicators.contains(rule.indicator)) {
      throw FormatException('execution 使用了不支持的指标：${rule.indicator}');
    }
    if (!conditions.contains(rule.condition)) {
      throw FormatException('execution 使用了不支持的条件：${rule.condition}');
    }
    if (rule.isConfirmedCross &&
        rule.indicator != 'price_ma_short' &&
        rule.indicator != 'price_ma_long') {
      throw const FormatException('多日确认目前只支持价格相对均线指标');
    }
    if (rule.indicator == 'market_environment' &&
        !{
          'uptrend',
          'downtrend',
          'sideways',
          'not_sideways',
        }.contains(rule.condition)) {
      throw const FormatException('趋势环境规则使用了不兼容的条件');
    }
  }

  static String _fingerprint(String input) {
    // BigInt keeps this FNV-1a calculation identical on native and Web.
    // JavaScript numbers cannot exactly represent the original 64-bit ints.
    var hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = BigInt.parse('7fffffffffffffff', radix: 16);
    for (final byte in utf8.encode(input.trim().toLowerCase())) {
      hash ^= BigInt.from(byte);
      hash = (hash * prime) & mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}

/// Read model used by the strategy detail page and tests.
class StrategyVersionInfo {
  final String id;
  final String strategyId;
  final int versionNumber;
  final String status;
  final StrategyKnowledgeType strategyType;
  final List<String> riskNotes;
  final List<String> pendingQuestions;
  final List<StrategyCompatibilityIssue> compatibilityIssues;
  final String? previousVersionId;
  final DateTime createdAt;
  final List<StrategySourceInfo> sources;
  final Strategy strategySnapshot;

  const StrategyVersionInfo({
    required this.id,
    required this.strategyId,
    required this.versionNumber,
    required this.status,
    required this.strategyType,
    required this.riskNotes,
    required this.pendingQuestions,
    required this.compatibilityIssues,
    this.previousVersionId,
    required this.createdAt,
    required this.sources,
    required this.strategySnapshot,
  });

  bool get canEnable =>
      pendingQuestions.isEmpty &&
      compatibilityIssues.every((issue) => !issue.blocking);
}

class StrategySourceInfo {
  final String id;
  final StrategySourceKind kind;
  final String? speaker;
  final DateTime? capturedAt;
  final String summary;
  final bool hasStoredText;
  final List<String> ruleIds;

  const StrategySourceInfo({
    required this.id,
    required this.kind,
    this.speaker,
    this.capturedAt,
    required this.summary,
    required this.hasStoredText,
    required this.ruleIds,
  });
}

class StrategyKnowledgeImportResult {
  final String strategyId;
  final String versionId;
  final int versionNumber;
  final bool createdStrategy;

  const StrategyKnowledgeImportResult({
    required this.strategyId,
    required this.versionId,
    required this.versionNumber,
    required this.createdStrategy,
  });
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map<String, dynamic>) {
    throw FormatException('字段 $key 必须是对象');
  }
  return value;
}

Map<String, dynamic> _asMap(dynamic value, String label) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$label 必须是对象');
  }
  return value;
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('字段 $key 必须是数组');
  return value;
}

List<dynamic> _listOrEmpty(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return const [];
  if (value is! List) throw FormatException('字段 $key 必须是数组');
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('字段 $key 必须是非空文本');
  }
  return value.trim();
}

String _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return '';
  if (value is! String) throw FormatException('字段 $key 必须是文本');
  return value.trim();
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) throw FormatException('字段 $key 必须是文本');
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final values = _listOrEmpty(json, key);
  return values.map((value) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('字段 $key 只能包含非空文本');
    }
    return value.trim();
  }).toList();
}
