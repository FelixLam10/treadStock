import '../../stock/domain/stock_models.dart';

/// Deterministic, close-of-day structural indicators used by the built-in
/// ladder and simplified Chan-theory templates.
///
/// These indicators deliberately use only the current and prior completed
/// bars. That keeps recommendation, detail and backtest evaluations aligned
/// and avoids future-data leakage.
class StrategyPatternIndicators {
  StrategyPatternIndicators._();

  static const int ladderRequiredBars = 31;
  static const int chanRequiredBars = 37;

  /// Detects a conservative "higher platform + breakout" ladder structure.
  ///
  /// The two completed 10-bar platforms must step higher, the latest platform
  /// must remain reasonably compact, and the current close must clear the
  /// latest platform high by at least 0.5%.
  static LadderPatternSnapshot? ladder(List<DailyKline> klines) {
    if (klines.length < ladderRequiredBars) return null;

    final end = klines.length;
    final olderPlatform = klines.sublist(end - 31, end - 21);
    final latestPlatform = klines.sublist(end - 11, end - 1);
    final current = klines.last;

    final olderHigh = _maxHigh(olderPlatform);
    final olderLow = _minLow(olderPlatform);
    final latestHigh = _maxHigh(latestPlatform);
    final latestLow = _minLow(latestPlatform);
    final olderMid = (olderHigh + olderLow) / 2;
    final latestMid = (latestHigh + latestLow) / 2;
    final latestWidthPct = latestMid == 0
        ? double.infinity
        : (latestHigh - latestLow) / latestMid * 100;

    final higherStep =
        latestMid >= olderMid * 1.02 && latestLow >= olderLow * 1.01;
    final compactPlatform = latestWidthPct <= 10;
    final clearsPlatform = current.close > latestHigh * 1.005;
    final supportGapPct = latestLow == 0
        ? 0.0
        : (current.close - latestLow) / latestLow * 100;

    return LadderPatternSnapshot(
      breakout: higherStep && compactPlatform && clearsPlatform ? 1 : 0,
      supportGapPct: supportGapPct,
      latestPlatformWidthPct: latestWidthPct,
      latestPlatformHigh: latestHigh,
      latestPlatformLow: latestLow,
    );
  }

  /// Detects a deliberately simplified Chan-theory third-buy observation.
  ///
  /// Three completed 8-bar ranges form an overlap zone (the simplified
  /// "centre"). A later completed window must leave that zone upward, followed
  /// by a three-bar pullback that remains above the centre ceiling.
  ///
  /// This is an engineering approximation for repeatable testing; it is not a
  /// full implementation of fractals, strokes, segments or recursive levels.
  static ChanPatternSnapshot? simplifiedChanThirdBuy(List<DailyKline> klines) {
    if (klines.length < chanRequiredBars) return null;

    final end = klines.length;
    final centreBars = klines.sublist(end - 37, end - 13);
    final departureBars = klines.sublist(end - 13, end - 3);
    final pullbackBars = klines.sublist(end - 3);

    final segments = [
      centreBars.sublist(0, 8),
      centreBars.sublist(8, 16),
      centreBars.sublist(16, 24),
    ];
    final segmentHighs = segments.map(_maxHigh).toList();
    final segmentLows = segments.map(_minLow).toList();
    final centreUpper = segmentHighs.reduce((a, b) => a < b ? a : b);
    final centreLower = segmentLows.reduce((a, b) => a > b ? a : b);
    final hasCentre = centreUpper > centreLower && centreLower > 0;

    if (!hasCentre) {
      return const ChanPatternSnapshot(
        thirdBuy: 0,
        centreSupportGapPct: 0,
        centreUpper: 0,
        centreLower: 0,
      );
    }

    final departurePeak = departureBars
        .map((bar) => bar.close)
        .reduce((a, b) => a > b ? a : b);
    final leftCentreUpward = departurePeak > centreUpper * 1.01;
    final pullbackLow = _minLow(pullbackBars);
    final currentClose = klines.last.close;
    final hasPulledBack = currentClose < departurePeak * 0.995;
    final remainsAboveCentre =
        pullbackLow >= centreUpper * 0.997 && currentClose > centreUpper;
    final supportGapPct = (currentClose - centreUpper) / centreUpper * 100;

    return ChanPatternSnapshot(
      thirdBuy: leftCentreUpward && hasPulledBack && remainsAboveCentre ? 1 : 0,
      centreSupportGapPct: supportGapPct,
      centreUpper: centreUpper,
      centreLower: centreLower,
    );
  }

  static double _maxHigh(List<DailyKline> bars) =>
      bars.map((bar) => bar.high).reduce((a, b) => a > b ? a : b);

  static double _minLow(List<DailyKline> bars) =>
      bars.map((bar) => bar.low).reduce((a, b) => a < b ? a : b);
}

class LadderPatternSnapshot {
  final double breakout;
  final double supportGapPct;
  final double latestPlatformWidthPct;
  final double latestPlatformHigh;
  final double latestPlatformLow;

  const LadderPatternSnapshot({
    required this.breakout,
    required this.supportGapPct,
    required this.latestPlatformWidthPct,
    required this.latestPlatformHigh,
    required this.latestPlatformLow,
  });
}

class ChanPatternSnapshot {
  final double thirdBuy;
  final double centreSupportGapPct;
  final double centreUpper;
  final double centreLower;

  const ChanPatternSnapshot({
    required this.thirdBuy,
    required this.centreSupportGapPct,
    required this.centreUpper,
    required this.centreLower,
  });
}
