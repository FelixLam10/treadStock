// Data models for stock quotes, klines, and search results.

class StockMarket {
  StockMarket._();

  static const sh = 'SH';
  static const sz = 'SZ';
  static const hk = 'HK';
  static const usNasdaq = 'US_NASDAQ';
  static const usNyse = 'US_NYSE';
  static const usAmex = 'US_AMEX';
  static const us = 'US';
  static const aShare = 'A_SHARE';

  static bool isAShare(String market) => market == sh || market == sz;

  static bool isUS(String market) =>
      market == us ||
      market == usNasdaq ||
      market == usNyse ||
      market == usAmex;

  static bool isSupportedEastMoneySearch(Map<String, dynamic> json) {
    final prefix = json['QuoteID']?.toString().split('.').first;
    return const {'0', '1', '105', '106', '107', '116'}.contains(prefix);
  }

  static String displayLabel(String market) {
    if (isUS(market)) return 'US';
    return market;
  }

  static String currencySymbol(String market) {
    if (market == hk) return 'HK\$';
    if (isUS(market)) return '\$';
    return '¥';
  }

  static String fromCode(String code) {
    if (code.startsWith('6') || code.startsWith('9')) return sh;
    return sz;
  }

  static String fromEastMoneySearch(Map<String, dynamic> json) {
    final quoteId = json['QuoteID']?.toString();
    final prefix = quoteId?.split('.').first;
    switch (prefix) {
      case '1':
        return sh;
      case '0':
        return sz;
      case '116':
        return hk;
      case '105':
        return usNasdaq;
      case '106':
        return usNyse;
      case '107':
        return usAmex;
    }

    final marketType = json['MarketType']?.toString();
    final jys = json['JYS']?.toString().toUpperCase();
    final classify = json['Classify']?.toString();
    if (marketType == '5' || jys == 'HK' || classify == 'HK') return hk;
    if (marketType == '7' || classify == 'UsStock') {
      switch (jys) {
        case 'NASDAQ':
          return usNasdaq;
        case 'NYSE':
          return usNyse;
        case 'AMEX':
          return usAmex;
      }
      return us;
    }

    return fromCode(json['Code']?.toString() ?? '');
  }

  static String fromEastMoneyQuote(Map<String, dynamic> json) {
    final marketNum = json['f13']?.toString();
    switch (marketNum) {
      case '1':
        return sh;
      case '0':
        return sz;
      case '116':
        return hk;
      case '105':
        return usNasdaq;
      case '106':
        return usNyse;
      case '107':
        return usAmex;
    }
    return fromCode(json['f12']?.toString() ?? '');
  }

  static int eastMoneySecidPrefix(String market) {
    switch (market) {
      case sh:
        return 1;
      case hk:
        return 116;
      case usNasdaq:
        return 105;
      case usNyse:
      case us:
        return 106;
      case usAmex:
        return 107;
      case sz:
      default:
        return 0;
    }
  }
}

class StockQuote {
  final String code;
  final String name;
  final String market; // SH, SZ, HK, US_NASDAQ, US_NYSE, US_AMEX
  final double price;
  final double changePct; // percentage
  final double changeAmt;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double preClose;
  final double volume; // in lots (手)
  final double turnover; // percentage
  final double amount; // total traded amount in source currency
  final double amplitude; // percentage
  final double volumeRatio;
  // Total market cap in 亿元 (hundred-million CNY). Null when the quote source
  // does not provide it (e.g. Sina fallback). Used by StockFilter.marketCapRange.
  final double? marketCap;
  // Eastmoney industry classification string (e.g. '电子', '银行'). Null on
  // fallback sources. Used by StockFilter.industries.
  final String? industry;

  const StockQuote({
    required this.code,
    required this.name,
    required this.market,
    required this.price,
    required this.changePct,
    required this.changeAmt,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.preClose,
    required this.volume,
    required this.turnover,
    this.amount = 0,
    this.amplitude = 0,
    this.volumeRatio = 0,
    this.marketCap,
    this.industry,
  });

  String get fullCode => '$code.${StockMarket.displayLabel(market)}';

  factory StockQuote.fromJson(
    Map<String, dynamic> json, {
    String? fallbackMarket,
  }) {
    final code = json['f12'] as String? ?? '';
    final parsedMarket = StockMarket.fromEastMoneyQuote(json);
    final hasMarketNum = json['f13'] != null;
    final market = hasMarketNum || fallbackMarket == null
        ? parsedMarket
        : fallbackMarket;
    return StockQuote(
      code: code,
      name: json['f14'] as String? ?? '',
      market: market,
      price: _toDouble(json['f2']),
      changePct: _toDouble(json['f3']),
      changeAmt: _toDouble(json['f4']),
      volume: _toDouble(json['f5']),
      amount: _toDouble(json['f6']),
      amplitude: _toDouble(json['f7']),
      openPrice: _toDouble(json['f17']),
      highPrice: _toDouble(json['f15']),
      lowPrice: _toDouble(json['f16']),
      preClose: _toDouble(json['f18']),
      turnover: _toDouble(json['f8']),
      volumeRatio: _toDouble(json['f10']),
      // f20 is total market cap in CNY (元); convert to 亿元 (÷1e8).
      marketCap: (json['f20'] as num?)?.toDouble() == null
          ? null
          : (json['f20'] as num).toDouble() / 1e8,
      industry: json['f100'] as String?,
    );
  }

  factory StockQuote.fromRealtimeJson(
    Map<String, dynamic> json, {
    required String fallbackCode,
    required String fallbackMarket,
  }) {
    final code = json['f57'] as String? ?? fallbackCode;
    final priceScale = _priceScale(json['f59']);
    final market = StockMarket.isAShare(fallbackMarket)
        ? (code.isEmpty ? fallbackMarket : StockMarket.fromCode(code))
        : fallbackMarket;
    return StockQuote(
      code: code,
      name: json['f58'] as String? ?? '',
      market: market,
      price: _toScaledPrice(json['f43'], scale: priceScale),
      changePct: _toScaledPrice(json['f170']),
      changeAmt: _toScaledPrice(json['f169'], scale: priceScale),
      volume: _toDouble(json['f47']),
      openPrice: _toScaledPrice(json['f46'], scale: priceScale),
      highPrice: _toScaledPrice(json['f44'], scale: priceScale),
      lowPrice: _toScaledPrice(json['f45'], scale: priceScale),
      preClose: _toScaledPrice(json['f60'], scale: priceScale),
      turnover: _toScaledPrice(json['f168']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null || value == '-') return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _priceScale(dynamic value) {
    if (value == null || value == '-') return 2;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 2;
    return 2;
  }

  static double _toScaledPrice(dynamic value, {int scale = 2}) {
    if (value == null || value == '-') return 0.0;
    final divisor = _pow10(scale);
    if (value is int) return value / divisor;
    if (value is double) return value / divisor;
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed == null ? 0.0 : parsed / divisor;
    }
    return 0.0;
  }

  static double _pow10(int scale) {
    var result = 1.0;
    for (var i = 0; i < scale; i++) {
      result *= 10;
    }
    return result;
  }

  StockQuote copyWith({
    double? price,
    double? changePct,
    double? changeAmt,
    double? openPrice,
    double? highPrice,
    double? lowPrice,
    double? volume,
    double? turnover,
    double? amount,
    double? amplitude,
    double? volumeRatio,
    double? marketCap,
    String? industry,
  }) {
    return StockQuote(
      code: code,
      name: name,
      market: market,
      price: price ?? this.price,
      changePct: changePct ?? this.changePct,
      changeAmt: changeAmt ?? this.changeAmt,
      openPrice: openPrice ?? this.openPrice,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      preClose: preClose,
      volume: volume ?? this.volume,
      turnover: turnover ?? this.turnover,
      amount: amount ?? this.amount,
      amplitude: amplitude ?? this.amplitude,
      volumeRatio: volumeRatio ?? this.volumeRatio,
      marketCap: marketCap ?? this.marketCap,
      industry: industry ?? this.industry,
    );
  }
}

/// East Money sector snapshot used by the hotspot page.
///
/// Kept separate from [StockQuote] because sector rows use the same wire
/// fields but represent an index/board rather than a tradable stock.
class MarketSectorQuote {
  final String code;
  final String name;
  final double price;
  final double changePct;
  final double volume;
  final double amount;
  final double amplitude;
  final double turnover;
  final double volumeRatio;

  const MarketSectorQuote({
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

  factory MarketSectorQuote.fromJson(Map<String, dynamic> json) {
    return MarketSectorQuote(
      code: json['f12']?.toString() ?? '',
      name: json['f14']?.toString() ?? '',
      price: StockQuote._toDouble(json['f2']),
      changePct: StockQuote._toDouble(json['f3']),
      volume: StockQuote._toDouble(json['f5']),
      amount: StockQuote._toDouble(json['f6']),
      amplitude: StockQuote._toDouble(json['f7']),
      turnover: StockQuote._toDouble(json['f8']),
      volumeRatio: StockQuote._toDouble(json['f10']),
    );
  }
}

/// A stock row returned by a sector-constituent query.
class SectorStockQuote {
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

  const SectorStockQuote({
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
  });

  factory SectorStockQuote.fromJson(Map<String, dynamic> json) {
    return SectorStockQuote(
      code: json['f12']?.toString() ?? '',
      name: json['f14']?.toString() ?? '',
      market: StockMarket.fromEastMoneyQuote(json),
      price: StockQuote._toDouble(json['f2']),
      changePct: StockQuote._toDouble(json['f3']),
      volume: StockQuote._toDouble(json['f5']),
      amount: StockQuote._toDouble(json['f6']),
      amplitude: StockQuote._toDouble(json['f7']),
      turnover: StockQuote._toDouble(json['f8']),
      volumeRatio: StockQuote._toDouble(json['f10']),
      openPrice: StockQuote._toDouble(json['f17']),
      highPrice: StockQuote._toDouble(json['f15']),
      lowPrice: StockQuote._toDouble(json['f16']),
      preClose: StockQuote._toDouble(json['f18']),
    );
  }
}

class DailyKline {
  final DateTime date;
  final double open;
  final double close;
  final double high;
  final double low;
  final double volume;
  final double amount;

  /// Previous day's close price. Populated from the prior kline entry.
  /// Defaults to close price when no prior data is available (first entry).
  final double preClose;

  const DailyKline({
    required this.date,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
    required this.amount,
    this.preClose = 0,
  });

  double get changePct =>
      preClose > 0 ? ((close - preClose) / preClose) * 100 : 0;

  factory DailyKline.fromEastMoney(String klineStr) {
    // Format: "2026-04-10,44.80,45.20,45.80,44.50,125400,5678000000"
    final parts = klineStr.split(',');
    return DailyKline(
      date: DateTime.parse(parts[0].trim()),
      open: double.parse(parts[1].trim()),
      close: double.parse(parts[2].trim()),
      high: double.parse(parts[3].trim()),
      low: double.parse(parts[4].trim()),
      volume: double.parse(parts[5].trim()),
      amount: double.parse(parts[6].trim()),
    );
  }

  /// Parse kline strings and populate preClose from the previous day's close.
  static List<DailyKline> parseKlines(List<String> klineStrings) {
    final klines = klineStrings.map(DailyKline.fromEastMoney).toList();
    // Populate preClose: each day's preClose = previous day's close.
    for (var i = 1; i < klines.length; i++) {
      klines[i] = DailyKline(
        date: klines[i].date,
        open: klines[i].open,
        close: klines[i].close,
        high: klines[i].high,
        low: klines[i].low,
        volume: klines[i].volume,
        amount: klines[i].amount,
        preClose: klines[i - 1].close,
      );
    }
    // For the first entry, preClose stays 0 (no prior data).
    return klines;
  }
}

class StockSearchResult {
  final String code;
  final String name;
  final String market;

  const StockSearchResult({
    required this.code,
    required this.name,
    required this.market,
  });

  String get fullCode => '$code.${StockMarket.displayLabel(market)}';
  String get displayMarket => StockMarket.displayLabel(market);

  factory StockSearchResult.fromJson(Map<String, dynamic> json) {
    // East Money search API format
    return StockSearchResult(
      code: json['Code'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      market: StockMarket.fromEastMoneySearch(json),
    );
  }
}

class StockNews {
  final String id;
  final String stockCode;
  final String title;
  final String source;
  final String sourceUrl;
  final DateTime publishedAt;
  final DateTime fetchedAt;

  const StockNews({
    required this.id,
    required this.stockCode,
    required this.title,
    required this.source,
    required this.sourceUrl,
    required this.publishedAt,
    required this.fetchedAt,
  });

  factory StockNews.fromJson(Map<String, dynamic> json, String stockCode) {
    return StockNews(
      id: json['id'] as String? ?? '',
      stockCode: stockCode,
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? '',
      sourceUrl: json['url'] as String? ?? '',
      publishedAt: json['publishTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['publishTime'] as int)
          : DateTime.now(),
      fetchedAt: DateTime.now(),
    );
  }
}

class StockInfo {
  final String code;
  final String name;
  final String? industry;
  final double? marketCap; // in billions
  final double? peRatio;
  final String? listDate;

  const StockInfo({
    required this.code,
    required this.name,
    this.industry,
    this.marketCap,
    this.peRatio,
    this.listDate,
  });
}

/// Company profile, valuation and latest reported performance used by the
/// detail page. Every field is optional because the three public upstream
/// responses can fail independently or omit fields for a specific company.
class StockFundamentals {
  final String code;
  final String name;
  final String? companyName;
  final String? board;
  final String? sector;
  final String? industry;
  final String? businessSummary;
  final String? marketPosition;
  final DateTime? listingDate;
  final double? peDynamic;
  final double? pbRatio;
  final double? marketCap;
  final String? reportName;
  final DateTime? reportDate;
  final double? revenue;
  final double? netProfit;
  final double? revenueYoy;
  final double? netProfitYoy;
  final double? grossMargin;
  final double? roe;
  final double? debtRatio;
  final double? eps;

  const StockFundamentals({
    required this.code,
    required this.name,
    this.companyName,
    this.board,
    this.sector,
    this.industry,
    this.businessSummary,
    this.marketPosition,
    this.listingDate,
    this.peDynamic,
    this.pbRatio,
    this.marketCap,
    this.reportName,
    this.reportDate,
    this.revenue,
    this.netProfit,
    this.revenueYoy,
    this.netProfitYoy,
    this.grossMargin,
    this.roe,
    this.debtRatio,
    this.eps,
  });

  bool get hasCompanyProfile =>
      companyName != null ||
      board != null ||
      sector != null ||
      industry != null ||
      businessSummary != null;

  bool get hasValuation =>
      peDynamic != null || pbRatio != null || marketCap != null;

  bool get hasPerformance =>
      revenue != null ||
      netProfit != null ||
      revenueYoy != null ||
      netProfitYoy != null;

  bool get hasAnyData => hasCompanyProfile || hasValuation || hasPerformance;

  /// Merge the independent East Money company-survey, financial-summary and
  /// quote responses into one null-tolerant model.
  factory StockFundamentals.fromEastMoney({
    required String fallbackCode,
    required String fallbackName,
    Map<String, dynamic>? survey,
    Map<String, dynamic>? finance,
    Map<String, dynamic>? valuation,
  }) {
    final profile = _firstMap(survey?['jbzl']);
    final issue = _firstMap(survey?['fxxg']);
    final report = _firstMap(finance?['data']);
    final valuationData = valuation?['data'] is Map
        ? Map<String, dynamic>.from(valuation!['data'] as Map)
        : valuation;

    final companyProfile = _cleanText(profile?['ORG_PROFILE']);
    final businessScope = _cleanText(profile?['BUSINESS_SCOPE']);
    final businessSummary = _shortDescription(
      companyProfile ?? businessScope,
      maxLength: 110,
      sentenceCount: 2,
    );

    return StockFundamentals(
      code: _stringValue(profile?['SECURITY_CODE']) ?? fallbackCode,
      name: _stringValue(profile?['SECURITY_NAME_ABBR']) ?? fallbackName,
      companyName: _stringValue(profile?['ORG_NAME']),
      board: _stringValue(profile?['SECURITY_TYPE']),
      sector: _stringValue(profile?['EM2016']),
      industry:
          _stringValue(profile?['INDUSTRYCSRC1']) ??
          _stringValue(valuationData?['f127']),
      businessSummary: businessSummary,
      marketPosition: _extractMarketPosition(companyProfile),
      listingDate: _parseDate(issue?['LISTING_DATE']),
      peDynamic: _numberValue(valuationData?['f9']),
      pbRatio: _numberValue(valuationData?['f23']),
      marketCap: _numberValue(valuationData?['f20']) == null
          ? null
          : _numberValue(valuationData?['f20'])! / 1e8,
      reportName:
          _stringValue(report?['REPORT_DATE_NAME']) ??
          _stringValue(report?['REPORT_TYPE']),
      reportDate: _parseDate(report?['REPORT_DATE']),
      revenue: _numberValue(report?['TOTALOPERATEREVE']),
      netProfit: _numberValue(report?['PARENTNETPROFIT']),
      revenueYoy: _numberValue(report?['TOTALOPERATEREVETZ']),
      netProfitYoy: _numberValue(report?['PARENTNETPROFITTZ']),
      grossMargin: _numberValue(report?['XSMLL']),
      roe: _numberValue(report?['ROEJQ']),
      debtRatio: _numberValue(report?['ZCFZL']),
      eps: _numberValue(report?['EPSJB']),
    );
  }
}

Map<String, dynamic>? _firstMap(dynamic value) {
  if (value is! List || value.isEmpty || value.first is! Map) return null;
  return Map<String, dynamic>.from(value.first as Map);
}

String? _stringValue(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == '-' || text == '--') return null;
  return text;
}

double? _numberValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _parseDate(dynamic value) {
  final text = _stringValue(value);
  if (text == null) return null;
  if (RegExp(r'^\d{8}$').hasMatch(text)) {
    return DateTime.tryParse(
      '${text.substring(0, 4)}-${text.substring(4, 6)}-${text.substring(6, 8)}',
    );
  }
  return DateTime.tryParse(text);
}

String? _cleanText(dynamic value) {
  final text = _stringValue(value);
  return text?.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String? _shortDescription(
  String? text, {
  required int maxLength,
  required int sentenceCount,
}) {
  if (text == null) return null;
  final sentences = _sentences(text).take(sentenceCount).join().trim();
  final result = sentences.isEmpty ? text : sentences;
  if (result.length <= maxLength) return result;
  return '${result.substring(0, maxLength).trim()}…';
}

String? _extractMarketPosition(String? profile) {
  if (profile == null) return null;
  final sentences = _sentences(profile);
  final matches = sentences.where(
    (item) => RegExp(r'领军|领先|龙头|单项冠军|百强|500强').hasMatch(item),
  );
  return _shortDescription(
    matches.isEmpty ? null : matches.take(2).join(),
    maxLength: 100,
    sentenceCount: 2,
  );
}

Iterable<String> _sentences(String text) => RegExp(r'[^。！？；]+[。！？；]?')
    .allMatches(text)
    .map((match) => match.group(0)?.trim() ?? '')
    .where((item) => item.isNotEmpty);
