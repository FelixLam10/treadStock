enum HotspotBoardType {
  industry('行业板块'),
  concept('概念板块');

  final String label;
  const HotspotBoardType(this.label);
}

enum HotspotStockMode {
  leader('龙头股'),
  active('热点股');

  final String label;
  const HotspotStockMode(this.label);
}

enum HotspotBoardMetric {
  amount('成交额'),
  volume('成交量'),
  turnover('换手率'),
  changePct('涨跌幅'),
  volumeRatio('量能异动');

  final String label;
  const HotspotBoardMetric(this.label);
}

class HotspotBoard {
  final String code;
  final String name;
  final double price;
  final double changePct;
  final double volume;
  final double amount;
  final double amplitude;
  final double turnover;
  final double volumeRatio;

  const HotspotBoard({
    required this.code,
    required this.name,
    required this.price,
    required this.changePct,
    required this.volume,
    required this.amount,
    required this.amplitude,
    required this.turnover,
    required this.volumeRatio,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'price': price,
    'changePct': changePct,
    'volume': volume,
    'amount': amount,
    'amplitude': amplitude,
    'turnover': turnover,
    'volumeRatio': volumeRatio,
  };

  factory HotspotBoard.fromJson(Map<String, dynamic> json) => HotspotBoard(
    code: json['code'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    changePct: (json['changePct'] as num).toDouble(),
    volume: (json['volume'] as num).toDouble(),
    amount: (json['amount'] as num).toDouble(),
    amplitude: (json['amplitude'] as num).toDouble(),
    turnover: (json['turnover'] as num).toDouble(),
    volumeRatio: (json['volumeRatio'] as num).toDouble(),
  );
}

class HotspotCandidate {
  final String code;
  final String name;
  final String market;
  final double price;
  final double changePct;
  final double volume;
  final double amount;
  final double amplitude;
  final double turnover;
  final double volumeRatio;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double preClose;
  final double? return5d;
  final double? relativeStrength5d;
  final int? activeTradingDays5d;
  final double strategyMatchScore;

  const HotspotCandidate({
    required this.code,
    required this.name,
    required this.market,
    required this.price,
    required this.changePct,
    required this.volume,
    required this.amount,
    required this.amplitude,
    required this.turnover,
    required this.volumeRatio,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.preClose,
    this.return5d,
    this.relativeStrength5d,
    this.activeTradingDays5d,
    this.strategyMatchScore = 0,
  });

  HotspotCandidate copyWith({
    double? volumeRatio,
    double? return5d,
    double? relativeStrength5d,
    int? activeTradingDays5d,
    double? strategyMatchScore,
  }) => HotspotCandidate(
    code: code,
    name: name,
    market: market,
    price: price,
    changePct: changePct,
    volume: volume,
    amount: amount,
    amplitude: amplitude,
    turnover: turnover,
    volumeRatio: volumeRatio ?? this.volumeRatio,
    openPrice: openPrice,
    highPrice: highPrice,
    lowPrice: lowPrice,
    preClose: preClose,
    return5d: return5d ?? this.return5d,
    relativeStrength5d: relativeStrength5d ?? this.relativeStrength5d,
    activeTradingDays5d: activeTradingDays5d ?? this.activeTradingDays5d,
    strategyMatchScore: strategyMatchScore ?? this.strategyMatchScore,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'market': market,
    'price': price,
    'changePct': changePct,
    'volume': volume,
    'amount': amount,
    'amplitude': amplitude,
    'turnover': turnover,
    'volumeRatio': volumeRatio,
    'openPrice': openPrice,
    'highPrice': highPrice,
    'lowPrice': lowPrice,
    'preClose': preClose,
    'return5d': return5d,
    'relativeStrength5d': relativeStrength5d,
    'activeTradingDays5d': activeTradingDays5d,
    'strategyMatchScore': strategyMatchScore,
  };

  factory HotspotCandidate.fromJson(Map<String, dynamic> json) =>
      HotspotCandidate(
        code: json['code'] as String,
        name: json['name'] as String,
        market: json['market'] as String,
        price: (json['price'] as num).toDouble(),
        changePct: (json['changePct'] as num).toDouble(),
        volume: (json['volume'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble(),
        amplitude: (json['amplitude'] as num).toDouble(),
        turnover: (json['turnover'] as num).toDouble(),
        volumeRatio: (json['volumeRatio'] as num).toDouble(),
        openPrice: (json['openPrice'] as num).toDouble(),
        highPrice: (json['highPrice'] as num).toDouble(),
        lowPrice: (json['lowPrice'] as num).toDouble(),
        preClose: (json['preClose'] as num).toDouble(),
        return5d: (json['return5d'] as num?)?.toDouble(),
        relativeStrength5d: (json['relativeStrength5d'] as num?)?.toDouble(),
        activeTradingDays5d: (json['activeTradingDays5d'] as num?)?.toInt(),
        strategyMatchScore:
            (json['strategyMatchScore'] as num?)?.toDouble() ?? 0,
      );
}

class RankedHotspotStock {
  final HotspotCandidate candidate;
  final double score;
  final List<String> reasons;
  final String directionLabel;

  const RankedHotspotStock({
    required this.candidate,
    required this.score,
    required this.reasons,
    required this.directionLabel,
  });
}

class HotspotDataBatch<T> {
  final T data;
  final DateTime updatedAt;
  final bool fromCache;
  final String? warning;

  const HotspotDataBatch({
    required this.data,
    required this.updatedAt,
    this.fromCache = false,
    this.warning,
  });
}
