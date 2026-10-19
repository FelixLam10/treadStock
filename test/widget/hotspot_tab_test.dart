import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_service.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_scheme_repository.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_filter_scheme.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_ranking_engine.dart';
import 'package:stockpilot/features/hotspot/presentation/hotspot_provider.dart';
import 'package:stockpilot/features/hotspot/presentation/hotspot_tab.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('热点页展示板块排序、双榜模式和系统默认方案', (tester) async {
    final state = HotspotState(
      boards: const [
        HotspotBoard(
          code: 'BK1',
          name: '电子',
          price: 100,
          changePct: 2,
          volume: 100,
          amount: 100000000,
          amplitude: 4,
          turnover: 5,
          volumeRatio: 2,
        ),
      ],
      selectedBoardCode: 'BK1',
      boardsUpdatedAt: DateTime(2026, 10, 8, 10, 30),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hotspotProvider.overrideWith((ref) => _FakeNotifier(state)),
        ],
        child: const MaterialApp(home: HotspotTab()),
      ),
    );
    await tester.pump();

    expect(find.text('行业板块'), findsOneWidget);
    expect(find.text('概念板块'), findsOneWidget);
    expect(find.byTooltip('概念板块待接入稳定数据源'), findsOneWidget);
    expect(find.text('板块前十'), findsOneWidget);
    expect(find.textContaining('电子'), findsOneWidget);
    expect(find.text('龙头股'), findsOneWidget);
    expect(find.text('热点股'), findsOneWidget);
    expect(find.text('系统默认方案'), findsWidgets);
    expect(find.textContaining('不是市场公认结论'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('有成分股但无命中时展示筛选空态而非接口错误', (tester) async {
    final state = HotspotState(
      boards: const [
        HotspotBoard(
          code: 'BK1',
          name: '电子',
          price: 100,
          changePct: 2,
          volume: 100,
          amount: 1000,
          amplitude: 4,
          turnover: 5,
          volumeRatio: 2,
        ),
      ],
      selectedBoardCode: 'BK1',
      candidates: const [
        HotspotCandidate(
          code: '600001',
          name: '测试',
          market: 'SH',
          price: 10,
          changePct: 1,
          volume: 100,
          amount: 1000,
          amplitude: 1,
          turnover: 1,
          volumeRatio: 1,
          openPrice: 10,
          highPrice: 10.1,
          lowPrice: 9.9,
          preClose: 9.9,
        ),
      ],
      stockMode: HotspotStockMode.active,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hotspotProvider.overrideWith((ref) => _FakeNotifier(state)),
        ],
        child: const MaterialApp(home: HotspotTab()),
      ),
    );
    await tester.pump();

    expect(find.text('当前条件下无匹配股票'), findsOneWidget);
    expect(find.text('成分股加载失败'), findsNothing);
  });

  testWidgets('热点页可显示当前模式下已启用的自定义方案', (tester) async {
    final scheme = HotspotFilterScheme.blank(
      target: HotspotStockMode.leader,
      now: DateTime(2026, 10, 9),
    ).copyWith(name: '低换手龙头', isEnabled: true);
    final state = HotspotState(
      boards: const [
        HotspotBoard(
          code: 'BK1',
          name: '电子',
          price: 100,
          changePct: 2,
          volume: 100,
          amount: 1000,
          amplitude: 4,
          turnover: 5,
          volumeRatio: 2,
        ),
      ],
      selectedBoardCode: 'BK1',
      schemes: [scheme],
      selectedSchemeId: scheme.id,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hotspotProvider.overrideWith((ref) => _FakeNotifier(state)),
        ],
        child: const MaterialApp(home: HotspotTab()),
      ),
    );
    await tester.pump();

    expect(find.text('低换手龙头'), findsWidgets);
    expect(find.byTooltip('管理筛选方案'), findsOneWidget);
    expect(find.textContaining('1 个条件'), findsOneWidget);
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

  @override
  Future<void> load() async {}
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
