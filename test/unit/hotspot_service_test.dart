import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_service.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';
import 'package:stockpilot/features/stock/domain/stock_models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('板块网络成功后写入缓存，后续失败返回带时间的缓存', () async {
    final now = DateTime(2026, 10, 8, 10, 30);
    final source = _FakeSource();
    final service = HotspotService(source: source, now: () => now);

    final fresh = await service.loadBoards(HotspotBoardType.industry);
    expect(fresh.fromCache, isFalse);
    expect(fresh.data.single.name, '电子');

    source.failBoards = true;
    final cached = await service.loadBoards(HotspotBoardType.industry);
    expect(cached.fromCache, isTrue);
    expect(cached.updatedAt, now);
    expect(cached.warning, contains('缓存'));
  });

  test('缓存超过七天后不再作为降级数据返回', () async {
    var now = DateTime(2026, 10, 1);
    final source = _FakeSource();
    final service = HotspotService(source: source, now: () => now);
    await service.loadBoards(HotspotBoardType.industry);

    now = DateTime(2026, 10, 9);
    source.failBoards = true;
    expect(
      () => service.loadBoards(HotspotBoardType.industry),
      throwsA(isA<HotspotSourceException>()),
    );
  });

  test('成分股只补取候选历史数据并计算相对板块强度', () async {
    final source = _FakeSource(
      constituents: [
        _stock('600001', amount: 200),
        _stock('600002', amount: 100),
      ],
      returns: {'600001': 10, '600002': 0},
    );
    final service = HotspotService(source: source);

    final result = await service.loadCandidates('BK0001');

    expect(result.data, hasLength(2));
    expect(
      result.data.firstWhere((e) => e.code == '600001').relativeStrength5d,
      closeTo(5, 0.01),
    );
    expect(
      result.data.firstWhere((e) => e.code == '600002').relativeStrength5d,
      closeTo(-5, 0.01),
    );
    expect(source.klineCalls, 2);
  });

  test('板块存在但接口返回空成分股时保留独立空状态', () async {
    final source = _FakeSource(constituents: const []);
    final service = HotspotService(source: source);

    final result = await service.loadCandidates('BK0001');

    expect(result.data, isEmpty);
    expect(result.fromCache, isFalse);
  });

  test('行情缺少量比时使用当前成交量与历史均量补算', () async {
    final source = _FakeSource(
      constituents: [
        _stock('600001', amount: 200, volume: 300, volumeRatio: 0),
      ],
    );
    final service = HotspotService(source: source);

    final result = await service.loadCandidates('BSI_TEST');

    expect(result.data.single.volumeRatio, closeTo(3, 0.01));
  });
}

class _FakeSource implements HotspotRemoteSource {
  bool failBoards = false;
  int klineCalls = 0;
  final List<SectorStockQuote> constituents;
  final Map<String, double> returns;

  _FakeSource({this.constituents = const [], this.returns = const {}});

  @override
  Future<List<MarketSectorQuote>> fetchSectors({required bool concept}) async {
    if (failBoards) throw Exception('offline');
    return const [
      MarketSectorQuote(
        code: 'BK0001',
        name: '电子',
        price: 100,
        changePct: 2,
        volume: 100,
        amount: 1000,
        amplitude: 3,
        turnover: 4,
        volumeRatio: 2,
      ),
    ];
  }

  @override
  Future<List<SectorStockQuote>> fetchConstituents(String sectorCode) async {
    return constituents;
  }

  @override
  Future<List<DailyKline>> fetchKlines(String code, String market) async {
    klineCalls++;
    final returnPct = returns[code] ?? 0;
    return List.generate(6, (index) {
      final close = index == 5 ? 10.0 * (1 + returnPct / 100) : 10.0;
      return DailyKline(
        date: DateTime(2026, 10, index + 1),
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

SectorStockQuote _stock(
  String code, {
  required double amount,
  double volume = 100,
  double volumeRatio = 2,
}) => SectorStockQuote(
  code: code,
  name: '测试股票',
  market: 'SH',
  price: 10,
  changePct: 2,
  volume: volume,
  amount: amount,
  amplitude: 4,
  turnover: 5,
  volumeRatio: volumeRatio,
  openPrice: 9.9,
  highPrice: 10.2,
  lowPrice: 9.8,
  preClose: 9.8,
);
