import 'dart:convert';

import '../../stock/domain/stock_models.dart';

// Data models for the strategy backtest engine.
//
// Backtest runs a strategy over historical kline data, simulating entry/exit
// signals on each bar and tracking PnL for every completed trade.

/// Configuration for a backtest run.
class BacktestConfig {
  /// Initial capital in yuan.
  final double initialCapital;

  /// Position size per trade as a fraction (0 < size <= 1.0).
  final double positionSize;

  /// Commission rate per trade (single-sided).
  final double commissionRate;

  /// Stamp tax rate (sell side only, A-share convention).
  final double stampTaxRate;

  /// Slippage in yuan per share.
  final double slippage;

  /// Number of bars used as the warm-up window before signals are evaluated.
  final int warmupBars;

  /// Maximum number of trades to keep (0 = unlimited).
  final int maxTrades;

  /// Stop-loss threshold as a fraction (e.g. -0.05 = -5%). null = no stop-loss.
  final double? stopLossPct;

  /// Take-profit threshold as a fraction (e.g. 0.10 = +10%). null = no take-profit.
  final double? takeProfitPct;

  /// Trailing stop activation threshold as a fraction (e.g. 0.05 = +5%).
  /// Once profit reaches this level, the trailing stop is activated.
  /// null = no trailing stop.
  final double? trailingStopActivationPct;

  /// Trailing stop distance as a fraction from peak (e.g. 0.03 = 3%).
  /// Once activated, exit when price drops this % from the peak.
  final double? trailingStopDistancePct;

  const BacktestConfig({
    this.initialCapital = 100000,
    this.positionSize = 1.0,
    this.commissionRate = 0.0003,
    this.stampTaxRate = 0.001,
    this.slippage = 0.0,
    this.warmupBars = 60,
    this.maxTrades = 0,
    this.stopLossPct,
    this.takeProfitPct,
    this.trailingStopActivationPct,
    this.trailingStopDistancePct,
  });

  /// Whether trailing stop is configured.
  bool get hasTrailingStop =>
      trailingStopActivationPct != null && trailingStopDistancePct != null;

  Map<String, dynamic> toJson() => {
    'initialCapital': initialCapital,
    'positionSize': positionSize,
    'commissionRate': commissionRate,
    'stampTaxRate': stampTaxRate,
    'slippage': slippage,
    'warmupBars': warmupBars,
    'maxTrades': maxTrades,
    'stopLossPct': stopLossPct,
    'takeProfitPct': takeProfitPct,
    'trailingStopActivationPct': trailingStopActivationPct,
    'trailingStopDistancePct': trailingStopDistancePct,
  };

  factory BacktestConfig.fromJson(Map<String, dynamic> json) {
    return BacktestConfig(
      initialCapital: (json['initialCapital'] as num?)?.toDouble() ?? 100000,
      positionSize: (json['positionSize'] as num?)?.toDouble() ?? 1.0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.0003,
      stampTaxRate: (json['stampTaxRate'] as num?)?.toDouble() ?? 0.001,
      slippage: (json['slippage'] as num?)?.toDouble() ?? 0.0,
      warmupBars: json['warmupBars'] as int? ?? 60,
      maxTrades: json['maxTrades'] as int? ?? 0,
      stopLossPct: (json['stopLossPct'] as num?)?.toDouble(),
      takeProfitPct: (json['takeProfitPct'] as num?)?.toDouble(),
      trailingStopActivationPct: (json['trailingStopActivationPct'] as num?)
          ?.toDouble(),
      trailingStopDistancePct: (json['trailingStopDistancePct'] as num?)
          ?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BacktestConfig &&
        initialCapital == other.initialCapital &&
        positionSize == other.positionSize &&
        commissionRate == other.commissionRate &&
        stampTaxRate == other.stampTaxRate &&
        slippage == other.slippage &&
        warmupBars == other.warmupBars &&
        maxTrades == other.maxTrades &&
        stopLossPct == other.stopLossPct &&
        takeProfitPct == other.takeProfitPct &&
        trailingStopActivationPct == other.trailingStopActivationPct &&
        trailingStopDistancePct == other.trailingStopDistancePct;
  }

  @override
  int get hashCode => Object.hash(
    initialCapital,
    positionSize,
    commissionRate,
    stampTaxRate,
    slippage,
    warmupBars,
    maxTrades,
    stopLossPct,
    takeProfitPct,
    trailingStopActivationPct,
    trailingStopDistancePct,
  );
}

/// Represents a single simulated trade within a backtest.
class BacktestTrade {
  /// Trade direction.
  final TradeDirection direction;

  /// Bar index at which entry occurred.
  final int entryBarIndex;

  /// Entry date.
  final DateTime entryDate;

  /// Entry price (after slippage).
  final double entryPrice;

  /// Bar index at which exit occurred.
  final int exitBarIndex;

  /// Exit date.
  final DateTime exitDate;

  /// Exit price (after slippage).
  final double exitPrice;

  /// Number of shares.
  final int shares;

  /// Gross profit (exit - entry) × shares.
  final double grossProfit;

  /// Commission paid (entry + exit).
  final double commission;

  /// Stamp tax paid (sell side).
  final double stampTax;

  /// Net profit after costs.
  final double netProfit;

  /// Return percentage = netProfit / (entryPrice × shares).
  final double returnPct;

  /// Reason the trade was closed.
  final ExitReason exitReason;

  const BacktestTrade({
    required this.direction,
    required this.entryBarIndex,
    required this.entryDate,
    required this.entryPrice,
    required this.exitBarIndex,
    required this.exitDate,
    required this.exitPrice,
    required this.shares,
    required this.grossProfit,
    required this.commission,
    required this.stampTax,
    required this.netProfit,
    required this.returnPct,
    required this.exitReason,
  });

  /// Whether this trade was profitable.
  bool get isWin => netProfit > 0;

  Map<String, dynamic> toJson() => {
    'direction': direction.name,
    'entryBarIndex': entryBarIndex,
    'entryDate': entryDate.toIso8601String(),
    'entryPrice': entryPrice,
    'exitBarIndex': exitBarIndex,
    'exitDate': exitDate.toIso8601String(),
    'exitPrice': exitPrice,
    'shares': shares,
    'grossProfit': grossProfit,
    'commission': commission,
    'stampTax': stampTax,
    'netProfit': netProfit,
    'returnPct': returnPct,
    'exitReason': exitReason.name,
  };

  factory BacktestTrade.fromJson(Map<String, dynamic> json) {
    return BacktestTrade(
      direction: TradeDirection.values.byName(json['direction'] as String),
      entryBarIndex: json['entryBarIndex'] as int,
      entryDate: DateTime.parse(json['entryDate'] as String),
      entryPrice: (json['entryPrice'] as num).toDouble(),
      exitBarIndex: json['exitBarIndex'] as int,
      exitDate: DateTime.parse(json['exitDate'] as String),
      exitPrice: (json['exitPrice'] as num).toDouble(),
      shares: json['shares'] as int,
      grossProfit: (json['grossProfit'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      stampTax: (json['stampTax'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      returnPct: (json['returnPct'] as num).toDouble(),
      exitReason: ExitReason.values.byName(json['exitReason'] as String),
    );
  }
}

/// Aggregated performance statistics for a backtest run.
class BacktestResult {
  /// The strategy name that was backtested.
  final String strategyName;

  /// Stock code.
  final String stockCode;

  /// All completed trades.
  final List<BacktestTrade> trades;

  /// Total number of completed trades.
  final int totalTrades;

  /// Number of winning trades.
  final int winCount;

  /// Number of losing trades.
  final int loseCount;

  /// Win rate (0.0 – 1.0).
  final double winRate;

  /// Total net profit across all trades.
  final double totalNetProfit;

  /// Cumulative return percentage.
  final double totalReturnPct;

  /// Maximum drawdown percentage (always ≤ 0).
  final double maxDrawdownPct;

  /// Annualized return (0.0 if not enough data to annualize).
  final double annualizedReturn;

  /// Average holding period in trading days.
  final double avgHoldingDays;

  /// Profit factor = totalWins / |totalLosses| (inf if no losses).
  final double profitFactor;

  /// Sharpe ratio (0.0 if fewer than 2 trades).
  final double sharpeRatio;

  /// Maximum consecutive wins.
  final int maxConsecutiveWins;

  /// Maximum consecutive losses.
  final int maxConsecutiveLosses;

  /// Average win return percentage.
  final double avgWinPct;

  /// Average loss return percentage (negative number).
  final double avgLossPct;

  /// Best single-trade return percentage.
  final double bestTradePct;

  /// Worst single-trade return percentage.
  final double worstTradePct;

  /// Start date of the data window used.
  final DateTime? startDate;

  /// End date of the data window used.
  final DateTime? endDate;

  /// Number of kline bars processed.
  final int barsProcessed;

  const BacktestResult({
    required this.strategyName,
    required this.stockCode,
    required this.trades,
    this.totalTrades = 0,
    this.winCount = 0,
    this.loseCount = 0,
    this.winRate = 0.0,
    this.totalNetProfit = 0.0,
    this.totalReturnPct = 0.0,
    this.maxDrawdownPct = 0.0,
    this.annualizedReturn = 0.0,
    this.avgHoldingDays = 0.0,
    this.profitFactor = 0.0,
    this.sharpeRatio = 0.0,
    this.maxConsecutiveWins = 0,
    this.maxConsecutiveLosses = 0,
    this.avgWinPct = 0.0,
    this.avgLossPct = 0.0,
    this.bestTradePct = 0.0,
    this.worstTradePct = 0.0,
    this.startDate,
    this.endDate,
    this.barsProcessed = 0,
  });

  /// Quick health assessment string.
  String get healthLabel {
    if (totalTrades == 0) return '无交易';
    if (totalTrades < BacktestReport.minimumReviewTrades) return '复盘样本不足';
    if (winRate >= 0.6 && profitFactor >= 1.5) return '策略表现良好';
    if (winRate >= 0.45 && profitFactor >= 1.0) return '策略表现中性';
    return '策略表现偏弱';
  }

  Map<String, dynamic> toJson() => {
    'strategyName': strategyName,
    'stockCode': stockCode,
    'trades': trades.map((trade) => trade.toJson()).toList(),
    'totalTrades': totalTrades,
    'winCount': winCount,
    'loseCount': loseCount,
    'winRate': winRate,
    'totalNetProfit': totalNetProfit,
    'totalReturnPct': totalReturnPct,
    'maxDrawdownPct': maxDrawdownPct,
    'annualizedReturn': annualizedReturn,
    'avgHoldingDays': avgHoldingDays,
    'profitFactor': profitFactor.isFinite ? profitFactor : null,
    'sharpeRatio': sharpeRatio,
    'maxConsecutiveWins': maxConsecutiveWins,
    'maxConsecutiveLosses': maxConsecutiveLosses,
    'avgWinPct': avgWinPct,
    'avgLossPct': avgLossPct,
    'bestTradePct': bestTradePct,
    'worstTradePct': worstTradePct,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'barsProcessed': barsProcessed,
  };

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    return BacktestResult(
      strategyName: json['strategyName'] as String,
      stockCode: json['stockCode'] as String,
      trades: (json['trades'] as List<dynamic>? ?? const [])
          .map((item) => BacktestTrade.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalTrades: json['totalTrades'] as int? ?? 0,
      winCount: json['winCount'] as int? ?? 0,
      loseCount: json['loseCount'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      totalNetProfit: (json['totalNetProfit'] as num?)?.toDouble() ?? 0,
      totalReturnPct: (json['totalReturnPct'] as num?)?.toDouble() ?? 0,
      maxDrawdownPct: (json['maxDrawdownPct'] as num?)?.toDouble() ?? 0,
      annualizedReturn: (json['annualizedReturn'] as num?)?.toDouble() ?? 0,
      avgHoldingDays: (json['avgHoldingDays'] as num?)?.toDouble() ?? 0,
      profitFactor: json['profitFactor'] == null
          ? double.infinity
          : (json['profitFactor'] as num).toDouble(),
      sharpeRatio: (json['sharpeRatio'] as num?)?.toDouble() ?? 0,
      maxConsecutiveWins: json['maxConsecutiveWins'] as int? ?? 0,
      maxConsecutiveLosses: json['maxConsecutiveLosses'] as int? ?? 0,
      avgWinPct: (json['avgWinPct'] as num?)?.toDouble() ?? 0,
      avgLossPct: (json['avgLossPct'] as num?)?.toDouble() ?? 0,
      bestTradePct: (json['bestTradePct'] as num?)?.toDouble() ?? 0,
      worstTradePct: (json['worstTradePct'] as num?)?.toDouble() ?? 0,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      barsProcessed: json['barsProcessed'] as int? ?? 0,
    );
  }
}

enum BacktestAdjustmentMode {
  forward('前复权');

  final String label;
  const BacktestAdjustmentMode(this.label);
}

enum BacktestSampleStatus {
  noTrades('无触发样本'),
  insufficient('样本不足'),
  reviewable('可进入复盘');

  final String label;
  const BacktestSampleStatus(this.label);
}

/// Immutable evidence attached to one backtest result.
class BacktestReport {
  static const int minimumReviewTrades = 20;

  final String id;
  final String strategyId;
  final String strategyVersionId;
  final int strategyVersionNumber;
  final String stockName;
  final String market;
  final BacktestConfig config;
  final BacktestAdjustmentMode adjustmentMode;
  final String dataFingerprint;
  final DateTime dataAsOf;
  final DateTime createdAt;
  final BacktestResult result;

  const BacktestReport({
    required this.id,
    required this.strategyId,
    required this.strategyVersionId,
    required this.strategyVersionNumber,
    required this.stockName,
    required this.market,
    required this.config,
    required this.adjustmentMode,
    required this.dataFingerprint,
    required this.dataAsOf,
    required this.createdAt,
    required this.result,
  });

  BacktestSampleStatus get sampleStatus {
    if (result.totalTrades == 0) return BacktestSampleStatus.noTrades;
    if (result.totalTrades < minimumReviewTrades) {
      return BacktestSampleStatus.insufficient;
    }
    return BacktestSampleStatus.reviewable;
  }

  bool get hasEnoughSample => sampleStatus == BacktestSampleStatus.reviewable;

  String get sampleMessage => switch (sampleStatus) {
    BacktestSampleStatus.noTrades => '本次没有形成完成交易，不能据此评价策略。',
    BacktestSampleStatus.insufficient =>
      '仅 ${result.totalTrades} 笔完成交易，少于 $minimumReviewTrades 笔，仅供观察。',
    BacktestSampleStatus.reviewable =>
      '已形成 ${result.totalTrades} 笔完成交易，可作为复盘样本之一。',
  };
}

enum BacktestComparisonStatus {
  comparable,
  insufficientSample,
  incompatibleInputs,
}

/// Comparison of two immutable reports. Only identical inputs may be used to
/// attribute a delta to a strategy version change.
class BacktestComparison {
  final BacktestReport baseline;
  final BacktestReport candidate;
  final BacktestComparisonStatus status;

  const BacktestComparison({
    required this.baseline,
    required this.candidate,
    required this.status,
  });

  factory BacktestComparison.compare(
    BacktestReport baseline,
    BacktestReport candidate,
  ) {
    final sameInputs =
        baseline.result.stockCode == candidate.result.stockCode &&
        baseline.market == candidate.market &&
        baseline.adjustmentMode == candidate.adjustmentMode &&
        baseline.dataFingerprint == candidate.dataFingerprint &&
        baseline.config == candidate.config;
    final status = !sameInputs
        ? BacktestComparisonStatus.incompatibleInputs
        : (!baseline.hasEnoughSample || !candidate.hasEnoughSample)
        ? BacktestComparisonStatus.insufficientSample
        : BacktestComparisonStatus.comparable;
    return BacktestComparison(
      baseline: baseline,
      candidate: candidate,
      status: status,
    );
  }

  double get returnDeltaPct =>
      candidate.result.totalReturnPct - baseline.result.totalReturnPct;
  double get winRateDelta => candidate.result.winRate - baseline.result.winRate;
  double get drawdownDeltaPct =>
      candidate.result.maxDrawdownPct - baseline.result.maxDrawdownPct;

  String get message => switch (status) {
    BacktestComparisonStatus.comparable => '两次回测使用相同股票、行情、复权方式和参数，可观察版本差异。',
    BacktestComparisonStatus.insufficientSample =>
      '输入条件一致，但至少一个版本少于 ${BacktestReport.minimumReviewTrades} 笔完成交易，不宜判断版本优劣。',
    BacktestComparisonStatus.incompatibleInputs =>
      '股票、行情或回测参数不一致，不能把差异归因于策略版本。',
  };
}

/// Produces a stable fingerprint for the exact K-line input used by a run.
String backtestDataFingerprint(List<DailyKline> klines) {
  var hash = BigInt.parse('cbf29ce484222325', radix: 16);
  final prime = BigInt.parse('100000001b3', radix: 16);
  final mask = BigInt.parse('ffffffffffffffff', radix: 16);
  final input = klines
      .map(
        (item) =>
            '${item.date.toIso8601String()}|${item.open}|${item.close}|${item.high}|${item.low}|${item.volume}',
      )
      .join(';');
  for (final byte in utf8.encode(input)) {
    hash ^= BigInt.from(byte);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

/// Trade direction enum.
enum TradeDirection { long, short }

/// Exit reason enum.
enum ExitReason {
  /// Strategy exit signal triggered.
  signalExit,

  /// Stop-loss hit.
  stopLoss,

  /// Take-profit hit.
  takeProfit,

  /// Trailing stop hit.
  trailingStop,

  /// End of data reached; forced close.
  endOfData,
}
