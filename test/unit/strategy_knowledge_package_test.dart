import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/domain/strategy_knowledge_package.dart';

Map<String, dynamic> _validPackage({
  List<String> pendingQuestions = const ['站上均线是否按收盘价判断？'],
  List<Map<String, dynamic>> compatibilityIssues = const [
    {
      'code': 'multi_day_confirmation',
      'message': '当前规则引擎不能完整表达穿越后次日确认',
      'blocking': true,
    },
  ],
}) {
  return {
    'packageVersion': 1,
    'strategy': {
      'name': 'money call - 五日均线',
      'type': 'personal',
      'description': '趋势环境中的五日均线两日确认观察策略',
      'parameters': {
        'maShortPeriod': 5,
        'maLongPeriod': 60,
        'bollPeriod': 20,
        'bollStdDev': 2.0,
        'weightMA': 0.5,
        'weightBoll': 0.1,
        'weightVol': 0.1,
        'weightTrend': 0.3,
        'recommendThreshold': 7,
      },
    },
    'sources': [
      {
        'sourceId': 'source-1',
        'type': 'chat',
        'speaker': 'money call',
        'summary': '聊天记录强调趋势环境、五日均线和次日确认，横盘时失效。',
        'sanitizedText': '横盘无效；站上五日均线后等待下一交易日确认。',
      },
    ],
    'rules': [
      {
        'id': 'rule-1',
        'title': '趋势过滤',
        'statement': '仅在可识别的上升趋势中进入观察，横盘震荡时暂停信号。',
        'status': 'explicit',
        'engineSupport': 'partial',
        'sourceRefs': ['source-1'],
      },
      {
        'id': 'rule-2',
        'title': '次日确认',
        'statement': '首次站上五日均线后，下一交易日未跌破时生成入场观察信号。',
        'status': 'pending',
        'engineSupport': 'unsupported',
        'sourceRefs': ['source-1'],
      },
    ],
    'applicability': {
      'markets': ['沪深股票'],
      'environments': ['上升趋势'],
      'invalidEnvironments': ['横盘震荡'],
    },
    'riskNotes': ['来源没有给出仓位、费用和止损细节。'],
    'pendingQuestions': pendingQuestions,
    'compatibilityIssues': compatibilityIssues,
  };
}

void main() {
  group('T-F012-1: 策略知识包解析与校验', () {
    test('解析聊天策略并保留来源、失效环境和待确认项', () {
      final package = StrategyKnowledgePackageCodec.parse(
        jsonEncode(_validPackage()),
      );

      expect(package.form.name, 'money call - 五日均线');
      expect(package.strategyType, StrategyKnowledgeType.personal);
      expect(package.sources.single.speaker, 'money call');
      expect(package.rules, hasLength(2));
      expect(package.applicability.invalidEnvironments, ['横盘震荡']);
      expect(package.pendingQuestions, isNotEmpty);
      expect(package.hasBlockingIssue, isTrue);
      expect(package.canEnable, isFalse);
      expect(package.sources.single.fingerprint, isNotEmpty);
    });

    test('规则引用不存在的来源时拒绝导入', () {
      final json = _validPackage();
      (json['rules'] as List).first['sourceRefs'] = ['missing-source'];

      expect(
        () => StrategyKnowledgePackageCodec.parse(jsonEncode(json)),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('不存在的来源'),
          ),
        ),
      );
    });

    test('可执行规则包含直接操作或收益承诺时拒绝导入', () {
      final json = _validPackage();
      (json['rules'] as List).first['statement'] = '站上均线后立即买入，保证收益。';

      expect(
        StrategyKnowledgePackageCodec.validate(jsonEncode(json)),
        contains('观察式表述'),
      );
    });

    test('人物经验策略缺少说话人时拒绝导入', () {
      final json = _validPackage();
      (json['sources'] as List).first.remove('speaker');

      expect(
        StrategyKnowledgePackageCodec.validate(jsonEncode(json)),
        contains('说话人'),
      );
    });

    test('未来格式版本不会被静默接受', () {
      final json = _validPackage()..['packageVersion'] = 2;

      expect(
        StrategyKnowledgePackageCodec.validate(jsonEncode(json)),
        contains('暂不支持策略包版本 2'),
      );
    });

    test('没有待确认和阻塞项的策略包可进入后续启用流程', () {
      final json = _validPackage(
        pendingQuestions: const [],
        compatibilityIssues: const [],
      );
      final rules = json['rules'] as List;
      rules[1]['status'] = 'explicit';
      rules[1]['engineSupport'] = 'supported';
      final strategy = json['strategy'] as Map<String, dynamic>;
      strategy['execution'] = {
        'entryRules': [
          {
            'indicator': 'price_ma_short',
            'condition': 'cross_up_confirmed',
            'value': 0,
            'confirmationDays': 2,
          },
        ],
        'exitRules': [
          {
            'indicator': 'price_ma_short',
            'condition': 'cross_down_confirmed',
            'value': 0,
            'confirmationDays': 2,
          },
        ],
      };

      final package = StrategyKnowledgePackageCodec.parse(jsonEncode(json));

      expect(package.canEnable, isTrue);
      expect(package.form.entryRules.single.confirmationDays, 2);
    });

    test('标记为当前可执行但没有 execution 时拒绝导入', () {
      final json = _validPackage(
        pendingQuestions: const [],
        compatibilityIssues: const [],
      );
      final rules = json['rules'] as List;
      rules[1]['status'] = 'explicit';
      rules[1]['engineSupport'] = 'supported';

      expect(
        StrategyKnowledgePackageCodec.validate(jsonEncode(json)),
        contains('strategy.execution'),
      );
    });
  });
}
