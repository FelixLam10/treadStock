import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_scheme_repository.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_service.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_filter_scheme.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_ranking_engine.dart';
import 'package:stockpilot/features/hotspot/presentation/hotspot_provider.dart';
import 'package:stockpilot/features/hotspot/presentation/hotspot_scheme_edit_page.dart';
import 'package:stockpilot/features/hotspot/presentation/hotspot_scheme_manage_page.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('方案管理页展示创建入口、状态、版本和范围说明', (tester) async {
    final scheme = HotspotFilterScheme.blank(
      target: HotspotStockMode.active,
      now: DateTime(2026, 10, 9),
    ).copyWith(name: '我的热点观察', isEnabled: true, version: 3);
    final state = HotspotState(schemes: [scheme]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hotspotProvider.overrideWith((ref) => _FakeNotifier(state)),
        ],
        child: const MaterialApp(home: HotspotSchemeManagePage()),
      ),
    );

    expect(find.text('我的筛选方案'), findsOneWidget);
    expect(find.text('复制系统默认'), findsOneWidget);
    expect(find.text('从空白创建'), findsOneWidget);
    expect(find.text('我的热点观察'), findsOneWidget);
    expect(find.textContaining('v3'), findsOneWidget);
    expect(find.textContaining('当前选中板块内运行'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('方案编辑页明确当前板块范围和保存后停用机制', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hotspotProvider.overrideWith(
            (ref) => _FakeNotifier(const HotspotState()),
          ),
        ],
        child: const MaterialApp(
          home: HotspotSchemeEditPage(
            initialMode: HotspotStockMode.active,
            copyDefault: true,
          ),
        ),
      ),
    );

    expect(find.text('新建筛选方案'), findsOneWidget);
    expect(find.text('龙头股'), findsOneWidget);
    expect(find.text('热点股'), findsOneWidget);
    expect(find.textContaining('当前选中板块'), findsOneWidget);
    expect(find.textContaining('全市场和关注列表'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('保存后仍保持停用'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('保存后仍保持停用'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeNotifier extends HotspotNotifier {
  _FakeNotifier(HotspotState initial)
    : super(
        service: HotspotService(source: _NoopSource()),
        rankingEngine: const HotspotRankingEngine(),
        schemeRepository: const HotspotSchemeRepository(),
      ) {
    state = initial;
  }
}

class _NoopSource implements HotspotRemoteSource {
  @override
  Future<List<SectorStockQuote>> fetchConstituents(String sectorCode) async =>
      [];

  @override
  Future<List<DailyKline>> fetchKlines(String code, String market) async => [];

  @override
  Future<List<MarketSectorQuote>> fetchSectors({required bool concept}) async =>
      [];
}
