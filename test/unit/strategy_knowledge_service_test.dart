import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/features/strategy/data/strategy_service.dart';
import 'package:stockpilot/features/strategy/domain/strategy_knowledge_package.dart';
import 'package:stockpilot/features/strategy/domain/strategy_models.dart';
import 'package:stockpilot/features/strategy/domain/signal_rule.dart';

StrategyKnowledgePackage _package({
  String name = 'money call - 五日均线',
  String fingerprint = 'money-call-ma5-v1',
  List<String> pendingQuestions = const ['站上均线是否按收盘价判断？'],
  List<StrategyCompatibilityIssue> issues = const [
    StrategyCompatibilityIssue(
      code: 'multi_day_confirmation',
      message: '当前规则引擎不能完整表达次日确认',
      blocking: true,
    ),
  ],
  List<SignalRule> entryRules = const [],
  List<SignalRule> exitRules = const [],
}) {
  return StrategyKnowledgePackage(
    packageVersion: 1,
    strategyType: StrategyKnowledgeType.personal,
    form: StrategyFormData(
      name: name,
      description: '趋势环境中的五日均线观察策略',
      maShortPeriod: 5,
      maLongPeriod: 60,
      weightMA: 0.5,
      weightBoll: 0.1,
      weightVol: 0.1,
      weightTrend: 0.3,
      isRuleBased: entryRules.isNotEmpty || exitRules.isNotEmpty,
      entryRules: entryRules,
      exitRules: exitRules,
    ),
    sources: [
      StrategyKnowledgeSource(
        externalRef: 'source-1',
        kind: StrategySourceKind.chat,
        speaker: 'money call',
        summary: '趋势中使用五日均线，横盘失效。',
        sanitizedText: '横盘无效；首次站上后等待下一交易日确认。',
        fingerprint: fingerprint,
      ),
    ],
    rules: const [
      StrategyKnowledgeRule(
        id: 'rule-1',
        title: '趋势过滤',
        statement: '横盘震荡时暂停策略信号。',
        status: StrategyRuleStatus.explicit,
        engineSupport: StrategyEngineSupport.partial,
        sourceRefs: ['source-1'],
      ),
    ],
    applicability: const StrategyApplicability(
      markets: ['沪深股票'],
      environments: ['上升趋势'],
      invalidEnvironments: ['横盘震荡'],
    ),
    riskNotes: const ['来源未说明费用和仓位。'],
    pendingQuestions: pendingQuestions,
    compatibilityIssues: issues,
  );
}

void main() {
  late AppDatabase db;
  late StrategyService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = StrategyService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('T-F012/T-F015: 可追溯策略导入与不可变版本', () {
    test('新策略包以停用草稿事务保存并建立规则来源关系', () async {
      final result = await service.importKnowledgePackage(_package());

      final strategy = service.getStrategy(result.strategyId);
      expect(strategy, isNotNull);
      expect(strategy!.isEnabled, isFalse);
      expect(result.createdStrategy, isTrue);
      expect(result.versionNumber, 1);

      final versions = await service.getStrategyVersions(result.strategyId);
      expect(versions, hasLength(1));
      expect(versions.single.status, 'draft');
      expect(versions.single.sources.single.speaker, 'money call');
      expect(versions.single.sources.single.ruleIds, ['rule-1']);
      expect(versions.single.sources.single.hasStoredText, isFalse);
      expect(versions.single.pendingQuestions, isNotEmpty);
      final versionRow = await (db.select(
        db.strategyVersions,
      )..where((row) => row.strategyId.equals(result.strategyId))).getSingle();
      expect(versionRow.packageJson, isNot(contains('横盘无效；首次站上')));
    });

    test('只有用户明确选择时才保存脱敏文字', () async {
      final result = await service.importKnowledgePackage(
        _package(),
        retainSanitizedText: true,
      );

      final versions = await service.getStrategyVersions(result.strategyId);
      expect(versions.single.sources.single.hasStoredText, isTrue);
      final versionRow = await (db.select(
        db.strategyVersions,
      )..where((row) => row.strategyId.equals(result.strategyId))).getSingle();
      expect(versionRow.packageJson, contains('横盘无效；首次站上'));
    });

    test('待确认或阻塞项存在时拒绝启用且不改变状态', () async {
      final result = await service.importKnowledgePackage(_package());

      final changed = await service.toggleEnabled(result.strategyId, true);

      expect(changed, isFalse);
      expect(service.getStrategy(result.strategyId)!.isEnabled, isFalse);
    });

    test('完整策略包可由用户手动启用', () async {
      final result = await service.importKnowledgePackage(
        _package(pendingQuestions: const [], issues: const []),
      );

      final changed = await service.toggleEnabled(result.strategyId, true);

      expect(changed, isTrue);
      expect(service.getStrategy(result.strategyId)!.isEnabled, isTrue);
      final versions = await service.getStrategyVersions(result.strategyId);
      expect(versions.single.status, 'active');
    });

    test('补充材料生成候选版本，不覆盖当前策略并复用相同来源', () async {
      final first = await service.importKnowledgePackage(
        _package(pendingQuestions: const [], issues: const []),
      );
      final originalName = service.getStrategy(first.strategyId)!.name;

      final second = await service.importKnowledgePackage(
        _package(name: 'money call - 修订版'),
        targetStrategyId: first.strategyId,
      );

      expect(second.createdStrategy, isFalse);
      expect(second.versionNumber, 2);
      expect(service.getStrategy(first.strategyId)!.name, originalName);
      final versions = await service.getStrategyVersions(first.strategyId);
      expect(versions.map((version) => version.versionNumber), [2, 1]);
      expect(versions.first.status, 'candidate');

      final sourceRows = await db.select(db.strategySources).get();
      expect(sourceRows, hasLength(1));
      final linkRows = await db.select(db.strategyVersionSources).get();
      expect(linkRows, hasLength(2));
    });

    test('普通创建和编辑也会形成连续不可变版本', () async {
      await service.init();
      final strategy = await service.createStrategy(
        StrategyFormData(name: '手工策略'),
      );
      await service.updateStrategy(
        strategy.id,
        StrategyFormData(name: '手工策略修订'),
      );

      final versions = await service.getStrategyVersions(strategy.id);
      expect(versions.map((version) => version.versionNumber), [2, 1]);
      final snapshots = await (db.select(
        db.strategyVersions,
      )..where((row) => row.strategyId.equals(strategy.id))).get();
      expect(
        snapshots.map((row) => row.strategySnapshotJson).toSet(),
        hasLength(2),
      );
    });

    test('候选版本激活后同步当前策略并保留旧版本', () async {
      final first = await service.importKnowledgePackage(
        _package(pendingQuestions: const [], issues: const []),
      );
      await service.toggleEnabled(first.strategyId, true);
      final second = await service.importKnowledgePackage(
        _package(
          name: 'money call - 正式修订版',
          pendingQuestions: const [],
          issues: const [],
        ),
        targetStrategyId: first.strategyId,
      );

      final activated = await service.activateStrategyVersion(
        first.strategyId,
        second.versionId,
      );

      expect(activated.status, 'active');
      expect(service.getStrategy(first.strategyId)!.name, 'money call - 正式修订版');
      expect(service.getStrategy(first.strategyId)!.isEnabled, isTrue);
      final versions = await service.getStrategyVersions(first.strategyId);
      expect(versions.first.status, 'active');
      expect(versions.last.status, 'archived');
    });

    test('相反规则必须确认冲突后才能激活', () async {
      final first = await service.importKnowledgePackage(
        _package(
          pendingQuestions: const [],
          issues: const [],
          entryRules: const [
            SignalRule(
              indicator: 'price_ma_short',
              condition: 'cross_up',
              value: 0,
            ),
          ],
        ),
      );
      await service.toggleEnabled(first.strategyId, true);
      final second = await service.importKnowledgePackage(
        _package(
          pendingQuestions: const [],
          issues: const [],
          entryRules: const [
            SignalRule(
              indicator: 'price_ma_short',
              condition: 'cross_down',
              value: 0,
            ),
          ],
        ),
        targetStrategyId: first.strategyId,
      );

      await expectLater(
        service.activateStrategyVersion(first.strategyId, second.versionId),
        throwsA(
          isA<StrategyVersionActivationException>().having(
            (error) => error.message,
            'message',
            contains('相反规则'),
          ),
        ),
      );
      expect(service.getStrategy(first.strategyId)!.name, 'money call - 五日均线');

      final activated = await service.activateStrategyVersion(
        first.strategyId,
        second.versionId,
        confirmedConflicts: true,
      );
      expect(activated.status, 'active');
    });

    test('待确认或引擎阻塞的候选版本始终拒绝激活', () async {
      final first = await service.importKnowledgePackage(
        _package(pendingQuestions: const [], issues: const []),
      );
      final second = await service.importKnowledgePackage(
        _package(),
        targetStrategyId: first.strategyId,
      );

      await expectLater(
        service.activateStrategyVersion(
          first.strategyId,
          second.versionId,
          confirmedConflicts: true,
        ),
        throwsA(isA<StrategyVersionActivationException>()),
      );
      final versions = await service.getStrategyVersions(first.strategyId);
      expect(versions.first.status, 'candidate');
    });

    test('导入的多日规则会写入策略并可重新加载', () async {
      final result = await service.importKnowledgePackage(
        _package(
          entryRules: const [
            SignalRule(
              indicator: 'price_ma_short',
              condition: 'cross_up_confirmed',
              value: 0,
              confirmationDays: 2,
            ),
          ],
          exitRules: const [
            SignalRule(
              indicator: 'price_ma_short',
              condition: 'cross_down_confirmed',
              value: 0,
              confirmationDays: 2,
            ),
          ],
        ),
      );

      await service.reloadCache();
      final strategy = service.getStrategy(result.strategyId)!;
      expect(strategy.isRuleBased, isTrue);
      expect(strategy.entryRules!.single.confirmationDays, 2);
      expect(strategy.exitRules!.single.condition, 'cross_down_confirmed');
    });
  });
}
