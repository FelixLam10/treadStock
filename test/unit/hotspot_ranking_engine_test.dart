import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_filter_scheme.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_ranking_engine.dart';

void main() {
  const engine = HotspotRankingEngine();

  group('HotspotRankingEngine', () {
    test('板块与候选缓存 JSON 往返保持排名必需字段', () {
      final board = _board('BK1', amount: 100, change: 2);
      final candidate = _candidate(1, relativeStrength: 3.2, activeDays: 4);

      final restoredBoard = HotspotBoard.fromJson(board.toJson());
      final restoredCandidate = HotspotCandidate.fromJson(candidate.toJson());

      expect(restoredBoard.code, board.code);
      expect(restoredBoard.volumeRatio, board.volumeRatio);
      expect(restoredCandidate.market, candidate.market);
      expect(restoredCandidate.relativeStrength5d, 3.2);
      expect(restoredCandidate.activeTradingDays5d, 4);
    });

    test('单只有效候选的百分位稳定为最高值', () {
      final ranked = engine.rankStocks([
        _candidate(1),
      ], HotspotStockMode.leader);

      expect(ranked, hasLength(1));
      expect(ranked.single.reasons.first, contains('前 1%'));
    });

    test('指标完全并列时采用并列最高百分位并按代码稳定排序', () {
      final ranked = engine.rankStocks([
        _candidate(2),
        _candidate(1),
        _candidate(3),
      ], HotspotStockMode.leader);

      expect(ranked.map((item) => item.candidate.code), ['001', '002', '003']);
    });

    test('板块按所选指标排序并以成交额和代码稳定破同分', () {
      final boards = [
        _board('B', amount: 100, change: 2),
        _board('A', amount: 200, change: 2),
        _board('C', amount: 300, change: 1),
      ];

      expect(
        engine
            .rankBoards(boards, HotspotBoardMetric.changePct)
            .map((e) => e.code),
        ['A', 'B', 'C'],
      );
      expect(
        engine.rankBoards(boards, HotspotBoardMetric.amount).first.code,
        'C',
      );
    });

    test('默认龙头方案只保留成交额前30%且满足持续性条件的股票', () {
      final candidates = List.generate(
        10,
        (index) => _candidate(
          index + 1,
          amount: (index + 1) * 100,
          relativeStrength: index + 1,
          activeDays: 5,
        ),
      );

      final ranked = engine.rankStocks(candidates, HotspotStockMode.leader);

      expect(ranked.map((item) => item.candidate.code), ['010', '009', '008']);
      expect(ranked.first.reasons.join(' '), contains('相对板块强度'));
      expect(ranked.first.score, greaterThan(ranked.last.score));
    });

    test('龙头方案排除风险警示、退市整理、停牌和历史不足数据', () {
      final candidates = [
        _candidate(1, name: '*ST测试', amount: 1000),
        _candidate(2, name: '测试退', amount: 900),
        _candidate(3, amount: 800, volume: 0),
        _candidate(4, amount: 700, relativeStrength: null),
      ];

      expect(engine.rankStocks(candidates, HotspotStockMode.leader), isEmpty);
    });

    test('默认热点方案识别当日异动并区分上涨、下跌和冲高回落', () {
      final candidates = [
        _candidate(1, amount: 100, change: 4),
        _candidate(2, amount: 500, change: -4),
        _candidate(3, amount: 600, change: 1, open: 10, high: 10.5, price: 9.8),
        _candidate(4, amount: 200, change: 2),
        _candidate(5, amount: 400, change: 3),
        _candidate(6, amount: 300, change: 2),
      ];

      final ranked = engine.rankStocks(candidates, HotspotStockMode.active);

      expect(ranked, hasLength(3));
      expect(
        ranked.map((item) => item.directionLabel),
        containsAll(['上涨异动', '下跌异动', '冲高回落']),
      );
      expect(ranked.map((item) => item.candidate.code), isNot(contains('001')));
    });

    test('热点方案要求量比、换手率和振幅同时达到默认阈值', () {
      final candidates = [
        _candidate(1, amount: 100, volumeRatio: 1.49),
        _candidate(2, amount: 200, turnover: 2.99),
        _candidate(3, amount: 300, amplitude: 2.99),
        _candidate(4, amount: 400),
      ];

      final ranked = engine.rankStocks(candidates, HotspotStockMode.active);
      expect(ranked.map((e) => e.candidate.code), ['004']);
    });

    test('自定义 AND 方案要求所有条件成立并遵守返回数量', () {
      final now = DateTime(2026, 10, 9);
      final scheme =
          HotspotFilterScheme.blank(
            target: HotspotStockMode.active,
            now: now,
          ).copyWith(
            conditions: const [
              HotspotFilterCondition(
                metric: HotspotFilterMetric.volumeRatio,
                operator: HotspotFilterOperator.greaterThanOrEqual,
                value: 2,
              ),
              HotspotFilterCondition(
                metric: HotspotFilterMetric.turnover,
                operator: HotspotFilterOperator.greaterThan,
                value: 4,
              ),
            ],
            sortWeights: const [
              HotspotSortWeight(
                metric: HotspotFilterMetric.amount,
                weight: 100,
              ),
            ],
            resultLimit: 1,
          );

      final ranked = engine.rankWithScheme([
        _candidate(1, amount: 100, volumeRatio: 2.1, turnover: 5),
        _candidate(2, amount: 300, volumeRatio: 2.2, turnover: 5),
        _candidate(3, amount: 500, volumeRatio: 1.9, turnover: 5),
      ], scheme);

      expect(ranked, hasLength(1));
      expect(ranked.single.candidate.code, '002');
      expect(ranked.single.reasons, hasLength(2));
    });

    test('自定义分组方案为组内 AND、组间 OR', () {
      final scheme =
          HotspotFilterScheme.blank(
            target: HotspotStockMode.active,
            now: DateTime(2026, 10, 9),
          ).copyWith(
            logic: HotspotConditionLogic.anyGroup,
            conditions: const [
              HotspotFilterCondition(
                metric: HotspotFilterMetric.volumeRatio,
                operator: HotspotFilterOperator.greaterThanOrEqual,
                value: 3,
                group: 1,
              ),
              HotspotFilterCondition(
                metric: HotspotFilterMetric.turnover,
                operator: HotspotFilterOperator.greaterThanOrEqual,
                value: 8,
                group: 1,
              ),
              HotspotFilterCondition(
                metric: HotspotFilterMetric.changePct,
                operator: HotspotFilterOperator.lessThanOrEqual,
                value: -3,
                group: 2,
              ),
            ],
          );

      final ranked = engine.rankWithScheme([
        _candidate(1, volumeRatio: 3.2, turnover: 8.2),
        _candidate(2, change: -4),
        _candidate(3, volumeRatio: 3.2, turnover: 7.9),
      ], scheme);

      expect(
        ranked.map((item) => item.candidate.code),
        containsAll(['001', '002']),
      );
      expect(ranked.map((item) => item.candidate.code), isNot(contains('003')));
    });

    test('低值优先权重会反转排序，缺失历史指标不会误命中', () {
      final scheme =
          HotspotFilterScheme.blank(
            target: HotspotStockMode.leader,
            now: DateTime(2026, 10, 9),
          ).copyWith(
            conditions: const [
              HotspotFilterCondition(
                metric: HotspotFilterMetric.return5d,
                operator: HotspotFilterOperator.greaterThan,
                value: -10,
              ),
            ],
            sortWeights: const [
              HotspotSortWeight(
                metric: HotspotFilterMetric.turnover,
                weight: 25,
                direction: HotspotSortDirection.lowFirst,
              ),
            ],
          );

      final ranked = engine.rankWithScheme([
        _candidate(1, turnover: 8, return5d: 2),
        _candidate(2, turnover: 3, return5d: 1),
        _candidate(3, turnover: 1, return5d: null),
      ], scheme);

      expect(ranked.map((item) => item.candidate.code), ['002', '001']);
    });

    test('低值优先排序不会把缺失指标当作最优值', () {
      final scheme =
          HotspotFilterScheme.blank(
            target: HotspotStockMode.leader,
            now: DateTime(2026, 10, 9),
          ).copyWith(
            conditions: const [
              HotspotFilterCondition(
                metric: HotspotFilterMetric.volumeRatio,
                operator: HotspotFilterOperator.greaterThanOrEqual,
                value: 1,
              ),
            ],
            sortWeights: const [
              HotspotSortWeight(
                metric: HotspotFilterMetric.relativeStrength5d,
                weight: 100,
                direction: HotspotSortDirection.lowFirst,
              ),
            ],
          );

      final ranked = engine.rankWithScheme([
        _candidate(1, relativeStrength: 5),
        _candidate(2, relativeStrength: 1),
        _candidate(3, relativeStrength: null),
      ], scheme);

      expect(ranked.map((item) => item.candidate.code), ['002', '001', '003']);
    });
  });
}

HotspotBoard _board(
  String code, {
  required double amount,
  required double change,
}) => HotspotBoard(
  code: code,
  name: '板块$code',
  price: 100,
  changePct: change,
  volume: amount / 10,
  amount: amount,
  amplitude: 3,
  turnover: 4,
  volumeRatio: 2,
);

HotspotCandidate _candidate(
  int index, {
  String? name,
  double amount = 100,
  double volume = 100,
  double change = 3,
  double volumeRatio = 2,
  double turnover = 5,
  double amplitude = 4,
  double? relativeStrength = 1,
  int? activeDays = 5,
  double open = 10,
  double high = 10.2,
  double price = 10.1,
  double? return5d,
}) => HotspotCandidate(
  code: index.toString().padLeft(3, '0'),
  name: name ?? '股票$index',
  market: 'SH',
  price: price,
  changePct: change,
  volume: volume,
  amount: amount,
  amplitude: amplitude,
  turnover: turnover,
  volumeRatio: volumeRatio,
  openPrice: open,
  highPrice: high,
  lowPrice: 9.8,
  preClose: 9.9,
  return5d: return5d,
  relativeStrength5d: relativeStrength,
  activeTradingDays5d: activeDays,
);
