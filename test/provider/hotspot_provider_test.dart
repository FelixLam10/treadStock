import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_service.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_scheme_repository.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_filter_scheme.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_ranking_engine.dart';
import 'package:stockpilot/features/hotspot/presentation/hotspot_provider.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('加载板块后自动选择第一项并生成龙头观察名单', () async {
    final source = _ProviderSource();
    final notifier = HotspotNotifier(
      service: HotspotService(source: source),
      rankingEngine: const HotspotRankingEngine(),
      schemeRepository: const HotspotSchemeRepository(),
    );
    addTearDown(notifier.dispose);

    await notifier.load();

    expect(notifier.state.isLoadingBoards, isFalse);
    expect(notifier.state.selectedBoardCode, 'BK1');
    expect(notifier.state.candidates, hasLength(4));
    expect(notifier.state.rankedStocks, isNotEmpty);
    expect(notifier.state.error, isNull);
  });

  test('成分股存在但不满足规则时是无匹配，不是加载错误', () async {
    final source = _ProviderSource(volumeRatio: 1);
    final notifier = HotspotNotifier(
      service: HotspotService(source: source),
      rankingEngine: const HotspotRankingEngine(),
      schemeRepository: const HotspotSchemeRepository(),
    );
    addTearDown(notifier.dispose);

    await notifier.load();
    notifier.changeStockMode(HotspotStockMode.active);

    expect(notifier.state.candidates, isNotEmpty);
    expect(notifier.state.rankedStocks, isEmpty);
    expect(notifier.state.error, isNull);
  });

  test('没有缓存且板块接口失败时保留真实错误状态', () async {
    final notifier = HotspotNotifier(
      service: HotspotService(source: _ProviderSource(fail: true)),
      rankingEngine: const HotspotRankingEngine(),
      schemeRepository: const HotspotSchemeRepository(),
    );
    addTearDown(notifier.dispose);

    await notifier.load();

    expect(notifier.state.boards, isEmpty);
    expect(notifier.state.error, contains('暂时不可用'));
  });

  test('只允许选择已启用且目标一致的自定义方案', () async {
    final repository = HotspotSchemeRepository(
      now: () => DateTime(2026, 10, 9),
    );
    final saved = await repository.saveScheme(
      HotspotFilterScheme.blank(
        target: HotspotStockMode.leader,
        now: DateTime(2026, 10, 9),
      ).copyWith(
        name: '宽松龙头观察',
        isEnabled: true,
        conditions: const [
          HotspotFilterCondition(
            metric: HotspotFilterMetric.volumeRatio,
            operator: HotspotFilterOperator.greaterThanOrEqual,
            value: 1,
          ),
        ],
      ),
    );
    final notifier = HotspotNotifier(
      service: HotspotService(source: _ProviderSource()),
      rankingEngine: const HotspotRankingEngine(),
      schemeRepository: repository,
    );
    addTearDown(notifier.dispose);

    await notifier.load();
    notifier.selectScheme(saved.id);

    expect(notifier.state.selectedSchemeId, saved.id);
    expect(notifier.state.selectedScheme?.name, '宽松龙头观察');
    expect(notifier.state.rankedStocks, hasLength(4));
  });
}

class _ProviderSource implements HotspotRemoteSource {
  final bool fail;
  final double volumeRatio;

  _ProviderSource({this.fail = false, this.volumeRatio = 2});

  @override
  Future<List<MarketSectorQuote>> fetchSectors({required bool concept}) async {
    if (fail) throw Exception('offline');
    return const [
      MarketSectorQuote(
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
    ];
  }

  @override
  Future<List<SectorStockQuote>> fetchConstituents(String sectorCode) async {
    return List.generate(
      4,
      (index) => SectorStockQuote(
        code: '60000$index',
        name: '测试$index',
        market: 'SH',
        price: 10,
        changePct: index + 1,
        volume: 100,
        amount: (index + 1) * 100,
        amplitude: 4,
        turnover: 5,
        volumeRatio: volumeRatio,
        openPrice: 9.8,
        highPrice: 10.2,
        lowPrice: 9.7,
        preClose: 9.7,
      ),
    );
  }

  @override
  Future<List<DailyKline>> fetchKlines(String code, String market) async {
    final index = int.parse(code.substring(code.length - 1));
    return List.generate(6, (day) {
      final close = 10 + index * day * 0.1;
      return DailyKline(
        date: DateTime(2026, 10, day + 1),
        open: close,
        close: close,
        high: close,
        low: close,
        volume: 100,
        amount: 1000,
      );
    });
  }
}
