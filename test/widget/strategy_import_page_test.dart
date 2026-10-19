import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/data/database.dart';
import 'package:stockpilot/features/strategy/presentation/strategy_import_page.dart';
import 'package:stockpilot/shared/providers.dart';

void main() {
  testWidgets('T-F012-1: 策略包校验后展示来源、规则和待确认预览', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: StrategyImportPage()),
      ),
    );
    await tester.pump();

    final package = {
      'packageVersion': 1,
      'strategy': {
        'name': 'money call - 五日均线',
        'type': 'personal',
        'description': '趋势环境中的五日均线观察策略',
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
          'summary': '趋势中使用五日均线，横盘时失效。',
        },
      ],
      'rules': [
        {
          'id': 'rule-1',
          'title': '趋势过滤',
          'statement': '横盘震荡时暂停策略信号。',
          'status': 'explicit',
          'engineSupport': 'partial',
          'sourceRefs': ['source-1'],
        },
      ],
      'applicability': {
        'markets': ['沪深股票'],
        'environments': ['上升趋势'],
        'invalidEnvironments': ['横盘震荡'],
      },
      'riskNotes': ['来源未说明仓位和费用。'],
      'pendingQuestions': ['站上均线是否按收盘价判断？'],
      'compatibilityIssues': <Map<String, dynamic>>[],
    };

    await tester.enterText(
      find.byKey(const ValueKey('strategy-package-input')),
      jsonEncode(package),
    );
    tester.testTextInput.hide();
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    final previewButton = find.byKey(
      const ValueKey('strategy-package-preview'),
    );
    await tester.tap(previewButton);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('strategy-package-status')),
      findsOneWidget,
    );
    expect(find.text('保存后仍需确认'), findsOneWidget);
    expect(find.text('money call - 五日均线'), findsOneWidget);
    expect(find.textContaining('聊天记录 · money call'), findsOneWidget);
    expect(find.text('待确认（1）'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
