import 'dart:math' as math;

import 'hotspot_filter_scheme.dart';
import 'hotspot_models.dart';

/// Deterministic default ranking rules for the hotspot page.
///
/// These are observation filters, not return predictions. Thresholds mirror
/// the product proposal and are intentionally kept in one pure-Dart class so
/// later market review can adjust them with regression coverage.
class HotspotRankingEngine {
  const HotspotRankingEngine();

  List<HotspotBoard> rankBoards(
    List<HotspotBoard> boards,
    HotspotBoardMetric metric, {
    int limit = 10,
  }) {
    final ranked = boards.where((item) => item.amount > 0).toList()
      ..sort((a, b) {
        final byMetric = _boardValue(
          b,
          metric,
        ).compareTo(_boardValue(a, metric));
        if (byMetric != 0) return byMetric;
        final byAmount = b.amount.compareTo(a.amount);
        return byAmount != 0 ? byAmount : a.code.compareTo(b.code);
      });
    return ranked.take(limit).toList(growable: false);
  }

  List<RankedHotspotStock> rankStocks(
    List<HotspotCandidate> candidates,
    HotspotStockMode mode, {
    int limit = 10,
  }) {
    final eligible = candidates.where(_passesCommonFilter).toList();
    if (eligible.isEmpty) return const [];

    final amountPercentiles = _percentiles(eligible, (item) => item.amount);
    final volumeRatioPercentiles = _percentiles(
      eligible,
      (item) => item.volumeRatio,
    );
    final turnoverPercentiles = _percentiles(eligible, (item) => item.turnover);
    final amplitudePercentiles = _percentiles(
      eligible,
      (item) => item.amplitude,
    );
    final absoluteChangePercentiles = _percentiles(
      eligible,
      (item) => item.changePct.abs(),
    );
    final changePercentiles = _percentiles(eligible, (item) => item.changePct);
    final strengthPercentiles = _percentiles(
      eligible,
      (item) => item.relativeStrength5d ?? -double.maxFinite,
    );

    final results = <RankedHotspotStock>[];
    for (final item in eligible) {
      final amountPct = amountPercentiles[item.code] ?? 0;
      if (mode == HotspotStockMode.leader) {
        if (amountPct < 0.70 ||
            item.turnover < 2 ||
            item.turnover > 25 ||
            item.volumeRatio < 1.2 ||
            (item.relativeStrength5d ?? 0) <= 0 ||
            (item.activeTradingDays5d ?? 0) < 4) {
          continue;
        }
        final score =
            100 *
            (amountPct * 0.30 +
                (strengthPercentiles[item.code] ?? 0) * 0.25 +
                math.min((item.activeTradingDays5d ?? 0) / 5, 1) * 0.15 +
                (turnoverPercentiles[item.code] ?? 0) * 0.15 +
                (changePercentiles[item.code] ?? 0) * 0.10 +
                (item.strategyMatchScore.clamp(0, 100) / 100) * 0.05);
        results.add(
          RankedHotspotStock(
            candidate: item,
            score: score,
            reasons: [
              '成交额位于板块前 ${_topLabel(amountPct)}',
              '近5日相对板块强度 ${_signed(item.relativeStrength5d!)}%',
              '近5日有效交易 ${item.activeTradingDays5d} 天',
              if (item.strategyMatchScore > 0)
                '启用策略匹配 ${item.strategyMatchScore.toStringAsFixed(0)} 分',
            ],
            directionLabel: _directionLabel(item),
          ),
        );
      } else {
        if (amountPct < 0.60 ||
            item.volumeRatio < 1.5 ||
            item.turnover < 3 ||
            item.amplitude < 3) {
          continue;
        }
        final score =
            100 *
            ((volumeRatioPercentiles[item.code] ?? 0) * 0.30 +
                (turnoverPercentiles[item.code] ?? 0) * 0.25 +
                amountPct * 0.20 +
                (amplitudePercentiles[item.code] ?? 0) * 0.15 +
                (absoluteChangePercentiles[item.code] ?? 0) * 0.10);
        results.add(
          RankedHotspotStock(
            candidate: item,
            score: score,
            reasons: [
              '量比 ${item.volumeRatio.toStringAsFixed(2)}',
              '换手率 ${item.turnover.toStringAsFixed(2)}%',
              '振幅 ${item.amplitude.toStringAsFixed(2)}%',
              '成交额位于板块前 ${_topLabel(amountPct)}',
            ],
            directionLabel: _directionLabel(item),
          ),
        );
      }
    }

    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byAmount = b.candidate.amount.compareTo(a.candidate.amount);
      return byAmount != 0
          ? byAmount
          : a.candidate.code.compareTo(b.candidate.code);
    });
    return results.take(limit).toList(growable: false);
  }

  List<RankedHotspotStock> rankWithScheme(
    List<HotspotCandidate> candidates,
    HotspotFilterScheme scheme,
  ) {
    final base = candidates.where((item) {
      if (item.market != 'SH' && item.market != 'SZ') return false;
      if (item.price <= 0) return false;
      final upperName = item.name.toUpperCase();
      if (scheme.excludeRiskWarnings &&
          (upperName.contains('ST') || item.name.contains('退'))) {
        return false;
      }
      if (scheme.excludeSuspended && (item.volume <= 0 || item.amount <= 0)) {
        return false;
      }
      if (scheme.minPrice != null && item.price < scheme.minPrice!) {
        return false;
      }
      if (scheme.maxPrice != null && item.price > scheme.maxPrice!) {
        return false;
      }
      return true;
    }).toList();
    if (base.isEmpty || scheme.validate().isNotEmpty) return const [];

    final amountPercentiles = _percentiles(base, (item) => item.amount);
    double? metricValue(HotspotCandidate item, HotspotFilterMetric metric) {
      return switch (metric) {
        HotspotFilterMetric.amountPercentile =>
          (amountPercentiles[item.code] ?? 0) * 100,
        HotspotFilterMetric.amount => item.amount,
        HotspotFilterMetric.volume => item.volume,
        HotspotFilterMetric.turnover => item.turnover,
        HotspotFilterMetric.volumeRatio => item.volumeRatio,
        HotspotFilterMetric.changePct => item.changePct,
        HotspotFilterMetric.absoluteChangePct => item.changePct.abs(),
        HotspotFilterMetric.amplitude => item.amplitude,
        HotspotFilterMetric.return5d => item.return5d,
        HotspotFilterMetric.relativeStrength5d => item.relativeStrength5d,
        HotspotFilterMetric.activeTradingDays5d =>
          item.activeTradingDays5d?.toDouble(),
        HotspotFilterMetric.strategyMatch => item.strategyMatchScore,
      };
    }

    bool matchesCondition(
      HotspotCandidate item,
      HotspotFilterCondition condition,
    ) {
      final actual = metricValue(item, condition.metric);
      if (actual == null || !actual.isFinite) return false;
      return switch (condition.operator) {
        HotspotFilterOperator.greaterThanOrEqual => actual >= condition.value,
        HotspotFilterOperator.lessThanOrEqual => actual <= condition.value,
        HotspotFilterOperator.greaterThan => actual > condition.value,
        HotspotFilterOperator.lessThan => actual < condition.value,
        HotspotFilterOperator.between =>
          actual >= condition.value && actual <= condition.upperValue!,
      };
    }

    bool matchesScheme(HotspotCandidate item) {
      if (scheme.logic == HotspotConditionLogic.all) {
        return scheme.conditions.every(
          (condition) => matchesCondition(item, condition),
        );
      }
      final groups = <int, List<HotspotFilterCondition>>{};
      for (final condition in scheme.conditions) {
        groups.putIfAbsent(condition.group, () => []).add(condition);
      }
      return groups.values.any(
        (group) =>
            group.every((condition) => matchesCondition(item, condition)),
      );
    }

    final matched = base.where(matchesScheme).toList();
    if (matched.isEmpty) return const [];
    final totalWeight = scheme.sortWeights.fold<double>(
      0,
      (sum, item) => sum + math.max(item.weight, 0),
    );
    final normalized = <HotspotFilterMetric, Map<String, double>>{};
    for (final weight in scheme.sortWeights) {
      normalized.putIfAbsent(weight.metric, () {
        if (weight.metric == HotspotFilterMetric.amountPercentile) {
          return amountPercentiles;
        }
        if (weight.metric == HotspotFilterMetric.activeTradingDays5d) {
          return {
            for (final item in matched)
              item.code: math.min((item.activeTradingDays5d ?? 0) / 5, 1),
          };
        }
        if (weight.metric == HotspotFilterMetric.strategyMatch) {
          return {
            for (final item in matched)
              item.code: item.strategyMatchScore.clamp(0, 100) / 100,
          };
        }
        return _percentiles(
          matched,
          (item) => metricValue(item, weight.metric) ?? -double.maxFinite,
        );
      });
    }

    final ranked =
        matched.map((item) {
          var weightedScore = 0.0;
          for (final weight in scheme.sortWeights) {
            // Missing data is always the least useful signal. In particular it
            // must not become the best score when a low-first metric is inverted.
            if (metricValue(item, weight.metric) == null) continue;
            var value = normalized[weight.metric]?[item.code] ?? 0;
            if (weight.direction == HotspotSortDirection.lowFirst) {
              value = 1 - value;
            }
            weightedScore += value * weight.weight;
          }
          final score = totalWeight <= 0
              ? 0.0
              : weightedScore / totalWeight * 100;
          return RankedHotspotStock(
            candidate: item,
            score: score,
            reasons: scheme.conditions
                .where((condition) => matchesCondition(item, condition))
                .take(3)
                .map(
                  (condition) => _conditionReason(
                    condition,
                    metricValue(item, condition.metric)!,
                  ),
                )
                .toList(),
            directionLabel: _directionLabel(item),
          );
        }).toList()..sort((a, b) {
          final byScore = b.score.compareTo(a.score);
          if (byScore != 0) return byScore;
          final byAmount = b.candidate.amount.compareTo(a.candidate.amount);
          return byAmount != 0
              ? byAmount
              : a.candidate.code.compareTo(b.candidate.code);
        });
    return ranked.take(scheme.resultLimit).toList(growable: false);
  }

  bool _passesCommonFilter(HotspotCandidate item) {
    final upperName = item.name.toUpperCase();
    return (item.market == 'SH' || item.market == 'SZ') &&
        !upperName.contains('ST') &&
        !item.name.contains('退') &&
        item.price > 0 &&
        item.volume > 0 &&
        item.amount > 0;
  }

  Map<String, double> _percentiles(
    List<HotspotCandidate> items,
    double Function(HotspotCandidate item) value,
  ) {
    if (items.length == 1) return {items.single.code: 1};
    final sortedValues = items.map(value).toList()..sort();
    return {
      for (final item in items)
        item.code:
            (sortedValues.where((entry) => entry <= value(item)).length - 1) /
            (sortedValues.length - 1),
    };
  }

  double _boardValue(HotspotBoard board, HotspotBoardMetric metric) {
    return switch (metric) {
      HotspotBoardMetric.amount => board.amount,
      HotspotBoardMetric.volume => board.volume,
      HotspotBoardMetric.turnover => board.turnover,
      HotspotBoardMetric.changePct => board.changePct,
      HotspotBoardMetric.volumeRatio => board.volumeRatio,
    };
  }

  String _topLabel(double percentile) {
    final top = ((1 - percentile) * 100).round().clamp(1, 100);
    return '$top%';
  }

  String _signed(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';

  String _conditionReason(HotspotFilterCondition condition, double actual) {
    final unit = condition.metric.unit;
    return '${condition.metric.label} ${actual.toStringAsFixed(2)}$unit，满足${condition.operator.label}条件';
  }

  String _directionLabel(HotspotCandidate item) {
    final roseThenFell =
        item.openPrice > 0 &&
        item.highPrice >= item.openPrice * 1.03 &&
        item.price < item.openPrice;
    if (roseThenFell) return '冲高回落';
    return item.changePct >= 0 ? '上涨异动' : '下跌异动';
  }
}
