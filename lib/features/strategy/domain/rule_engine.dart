import '../../analysis/domain/indicator_calculator.dart';
import '../../stock/domain/stock_models.dart';
import 'signal_rule.dart';
import 'strategy_models.dart';
import 'strategy_pattern_indicators.dart';

enum RuleProgressState {
  matched,
  notMatched,
  waitingConfirmation,
  triggered,
  invalidated,
  waitingRetrigger,
  environmentBlocked,
  insufficientData,
}

class RuleEvaluationDetail {
  final SignalRule rule;
  final bool passed;
  final RuleProgressState state;
  final String message;

  const RuleEvaluationDetail({
    required this.rule,
    required this.passed,
    required this.state,
    required this.message,
  });
}

class RuleEvaluationResult {
  final bool entryTriggered;
  final bool exitTriggered;
  final List<bool> entryResults;
  final List<bool> exitResults;
  final List<RuleEvaluationDetail> entryDetails;
  final List<RuleEvaluationDetail> exitDetails;
  final Map<String, double> indicatorValues;
  final Map<String, double> prevIndicatorValues;

  const RuleEvaluationResult({
    required this.entryTriggered,
    required this.exitTriggered,
    required this.entryResults,
    required this.exitResults,
    required this.entryDetails,
    required this.exitDetails,
    required this.indicatorValues,
    required this.prevIndicatorValues,
  });

  RuleEvaluationDetail? get primaryProgress {
    const priority = [
      RuleProgressState.environmentBlocked,
      RuleProgressState.waitingConfirmation,
      RuleProgressState.invalidated,
      RuleProgressState.triggered,
      RuleProgressState.insufficientData,
      RuleProgressState.waitingRetrigger,
    ];
    final details = [...entryDetails, ...exitDetails];
    for (final state in priority) {
      for (final detail in details) {
        if (detail.state == state) return detail;
      }
    }
    return null;
  }
}

class RuleEngine {
  /// Unified strategy entry point shared by recommendation, detail and
  /// backtest, so strategy-specific MA periods cannot drift between surfaces.
  static RuleEvaluationResult evaluateStrategy({
    required List<DailyKline> klines,
    required Strategy strategy,
    List<SignalRule>? entryRules,
    List<SignalRule>? exitRules,
    List<RuleGroup>? entryGroups,
    List<RuleGroup>? exitGroups,
  }) {
    return evaluate(
      klines: klines,
      entryRules: entryRules ?? strategy.entryRules ?? const [],
      exitRules: exitRules ?? strategy.exitRules ?? const [],
      entryGroups: entryGroups ?? strategy.entryGroups,
      exitGroups: exitGroups ?? strategy.exitGroups,
      maShortPeriod: strategy.maShortPeriod,
      maLongPeriod: strategy.maLongPeriod,
    );
  }

  /// Multi-day conditions use trading bars rather than calendar days. Price
  /// equality is deliberately neutral: it is neither above nor below a MA.
  static RuleEvaluationResult evaluate({
    required List<DailyKline> klines,
    required List<SignalRule> entryRules,
    List<SignalRule> exitRules = const [],
    List<RuleGroup>? entryGroups,
    List<RuleGroup>? exitGroups,
    int rsiPeriod = 14,
    int macdFast = 12,
    int macdSlow = 26,
    int macdSignal = 9,
    int kdjPeriod = 9,
    int emaPeriod = 20,
    int atrPeriod = 14,
    int maShortPeriod = 5,
    int maLongPeriod = 20,
  }) {
    final referencedIndicators = <String>{
      for (final rule in entryRules) rule.indicator,
      for (final rule in exitRules) rule.indicator,
      for (final group in entryGroups ?? const <RuleGroup>[])
        for (final rule in group.rules) rule.indicator,
      for (final group in exitGroups ?? const <RuleGroup>[])
        for (final rule in group.rules) rule.indicator,
    };
    final closes = klines.map((k) => k.close).toList();
    final rsiValues = IndicatorCalculator.calculateRSI(
      closes,
      period: rsiPeriod,
    );
    final macdResult = IndicatorCalculator.calculateMACD(
      closes,
      fastPeriod: macdFast,
      slowPeriod: macdSlow,
      signalPeriod: macdSignal,
    );
    final kdjResult = IndicatorCalculator.calculateKDJ(
      klines,
      period: kdjPeriod,
    );
    final emaValues = IndicatorCalculator.calculateEMA(
      closes,
      period: emaPeriod,
    );
    final atrValues = IndicatorCalculator.calculateATR(
      klines,
      period: atrPeriod,
    );
    final obvValues = IndicatorCalculator.calculateOBV(klines);
    final maShortValues = IndicatorCalculator.computeEMA(closes, maShortPeriod);
    final maLongValues = IndicatorCalculator.computeEMA(closes, maLongPeriod);
    final maShortSma = _simpleMovingAverageAligned(closes, maShortPeriod);
    final maLongSma = _simpleMovingAverageAligned(closes, maLongPeriod);
    final priceMaShort = _priceMaGapSeries(closes, maShortSma);
    final priceMaLong = _priceMaGapSeries(closes, maLongSma);

    final current = <String, double>{};
    final prev = <String, double>{};

    void addLatest(String key, List<double> values) {
      if (values.isEmpty) return;
      current[key] = values.last;
      if (values.length >= 2) prev[key] = values[values.length - 2];
    }

    addLatest('rsi', rsiValues);
    addLatest('macd', macdResult.macdLine);
    addLatest('macd_signal', macdResult.signalLine);
    addLatest('macd_hist', macdResult.histogram);
    if (kdjResult.kValues.isNotEmpty) {
      current['k'] = kdjResult.kValues.last;
      current['d'] = kdjResult.dValues.last;
      current['j'] = kdjResult.jValues.last;
      if (kdjResult.kValues.length >= 2) {
        prev['k'] = kdjResult.kValues[kdjResult.kValues.length - 2];
        prev['d'] = kdjResult.dValues[kdjResult.dValues.length - 2];
        prev['j'] = kdjResult.jValues[kdjResult.jValues.length - 2];
      }
    }
    addLatest('ema', emaValues);
    addLatest('atr', atrValues);
    addLatest('obv', obvValues);
    addLatest('ma_short', maShortValues);
    addLatest('ma_long', maLongValues);
    _addAlignedLatest('price_ma_short', priceMaShort, current, prev);
    _addAlignedLatest('price_ma_long', priceMaLong, current, prev);

    final boll = IndicatorCalculator.calculateBollingerBands(closes);
    if (boll != null && closes.isNotEmpty) {
      current['boll_position'] = IndicatorCalculator.calculateBollPosition(
        closes.last,
        boll.upper,
        boll.lower,
      );
    }
    current['ma_alignment'] = IndicatorCalculator.calculateMAAlignment(closes);
    current['vol_price_divergence'] =
        IndicatorCalculator.calculateVolumePriceDivergence(klines);
    current['vol_ratio'] = IndicatorCalculator.calculateVolumeRatio(klines);

    if (referencedIndicators.any((name) => name.startsWith('ladder_'))) {
      final ladder = StrategyPatternIndicators.ladder(klines);
      if (ladder != null) {
        current['ladder_breakout'] = ladder.breakout;
        current['ladder_support_gap_pct'] = ladder.supportGapPct;
        current['ladder_platform_width_pct'] = ladder.latestPlatformWidthPct;
      }
    }
    if (referencedIndicators.any((name) => name.startsWith('chan_'))) {
      final chan = StrategyPatternIndicators.simplifiedChanThirdBuy(klines);
      if (chan != null) {
        current['chan_third_buy'] = chan.thirdBuy;
        current['chan_center_support_gap_pct'] = chan.centreSupportGapPct;
        current['chan_center_upper'] = chan.centreUpper;
        current['chan_center_lower'] = chan.centreLower;
      }
    }

    final alignedSeries = <String, List<double?>>{
      'price_ma_short': priceMaShort,
      'price_ma_long': priceMaLong,
    };

    RuleEvaluationDetail evalRule(SignalRule rule) {
      if (rule.indicator == 'market_environment') {
        return _evaluateEnvironmentRule(
          rule: rule,
          closes: closes,
          maSeries: maShortSma,
          current: current,
        );
      }

      if (rule.isConfirmedCross) {
        final series = alignedSeries[rule.indicator];
        if (series == null) {
          return _detail(
            rule,
            false,
            RuleProgressState.insufficientData,
            '该指标不支持多日确认',
          );
        }
        return _evaluateConfirmedCross(rule, series);
      }

      if (rule.isIndicatorCross && rule.indicator2 != null) {
        final curA = current[rule.indicator];
        final prevA = prev[rule.indicator];
        final curB = current[rule.indicator2];
        final prevB = prev[rule.indicator2];
        if (curA == null || prevA == null || curB == null || prevB == null) {
          return _detail(
            rule,
            false,
            RuleProgressState.insufficientData,
            '指标数据不足，暂不能判断交叉',
          );
        }
        final passed = rule.evaluateIndicatorCross(
          prevA: prevA,
          curA: curA,
          prevB: prevB,
          curB: curB,
        );
        return _detail(
          rule,
          passed,
          passed ? RuleProgressState.triggered : RuleProgressState.notMatched,
          passed ? '指标交叉已触发' : '指标交叉尚未触发',
        );
      }

      final val = current[rule.indicator];
      final prevVal = prev[rule.indicator];
      if (val == null) {
        return _detail(
          rule,
          false,
          RuleProgressState.insufficientData,
          '指标数据不足',
        );
      }
      bool passed;
      if (rule.condition == 'cross_up' || rule.condition == 'cross_down') {
        if (prevVal == null) {
          return _detail(
            rule,
            false,
            RuleProgressState.insufficientData,
            '前一交易日指标不足',
          );
        }
        passed = rule.evaluateWithPrev(prevVal, val);
      } else {
        passed = rule.evaluate(val);
      }
      return _detail(
        rule,
        passed,
        passed ? RuleProgressState.matched : RuleProgressState.notMatched,
        _plainRuleMessage(rule, passed),
      );
    }

    final entryDetails = entryRules.map(evalRule).toList();
    final exitDetails = exitRules.map(evalRule).toList();
    final entryResults = entryDetails.map((detail) => detail.passed).toList();
    final exitResults = exitDetails.map((detail) => detail.passed).toList();

    bool entryFromGroups = false;
    bool exitFromGroups = false;
    if (entryGroups != null && entryGroups.isNotEmpty) {
      entryFromGroups = entryGroups.any(
        (group) =>
            group.rules.isNotEmpty &&
            group.rules.every((rule) => evalRule(rule).passed),
      );
    }
    if (exitGroups != null && exitGroups.isNotEmpty) {
      exitFromGroups = exitGroups.any(
        (group) =>
            group.rules.isNotEmpty &&
            group.rules.every((rule) => evalRule(rule).passed),
      );
    }

    final entryTriggered = entryResults.isNotEmpty
        ? entryResults.every((result) => result) || entryFromGroups
        : entryFromGroups;
    final exitTriggered = exitResults.isNotEmpty
        ? exitResults.any((result) => result) || exitFromGroups
        : exitFromGroups;

    return RuleEvaluationResult(
      entryTriggered: entryTriggered,
      exitTriggered: exitTriggered,
      entryResults: entryResults,
      exitResults: exitResults,
      entryDetails: entryDetails,
      exitDetails: exitDetails,
      indicatorValues: current,
      prevIndicatorValues: prev,
    );
  }

  static RuleEvaluationDetail _evaluateConfirmedCross(
    SignalRule rule,
    List<double?> series,
  ) {
    final values = series.whereType<double>().toList();
    final requiredDays = rule.confirmationDays;
    if (values.length < 2) {
      return _detail(
        rule,
        false,
        RuleProgressState.insufficientData,
        '至少需要 2 个有效交易日识别穿越',
      );
    }

    final crossesUp = rule.condition == 'cross_up_confirmed';
    bool onTargetSide(double value) =>
        crossesUp ? value > rule.value : value < rule.value;
    bool onOriginSide(double value) =>
        crossesUp ? value <= rule.value : value >= rule.value;

    var run = 0;
    for (var i = values.length - 1; i >= 0 && onTargetSide(values[i]); i--) {
      run++;
    }
    final beforeRunIndex = values.length - run - 1;
    final startedFromCross =
        run > 0 && beforeRunIndex >= 0 && onOriginSide(values[beforeRunIndex]);

    if (startedFromCross && run == requiredDays) {
      return _detail(
        rule,
        true,
        RuleProgressState.triggered,
        crossesUp
            ? '已连续 $requiredDays 个交易日站上均线，确认信号成立'
            : '已连续 $requiredDays 个交易日跌破均线，确认信号成立',
      );
    }
    if (startedFromCross && run < requiredDays) {
      return _detail(
        rule,
        false,
        RuleProgressState.waitingConfirmation,
        crossesUp
            ? '第 $run 日站上均线，等待后续交易日确认（需 $requiredDays 日）'
            : '第 $run 日跌破均线，等待后续交易日确认（需 $requiredDays 日）',
      );
    }

    if (run == 0 && values.length >= 3) {
      final previous = values.sublist(0, values.length - 1);
      var previousRun = 0;
      for (
        var i = previous.length - 1;
        i >= 0 && onTargetSide(previous[i]);
        i--
      ) {
        previousRun++;
      }
      final beforePreviousRun = previous.length - previousRun - 1;
      if (previousRun > 0 &&
          previousRun < requiredDays &&
          beforePreviousRun >= 0 &&
          onOriginSide(previous[beforePreviousRun])) {
        return _detail(
          rule,
          false,
          RuleProgressState.invalidated,
          crossesUp ? '确认前重新回到均线下方，本轮信号失效' : '确认前重新回到均线上方，本轮信号失效',
        );
      }
    }

    return _detail(
      rule,
      false,
      RuleProgressState.waitingRetrigger,
      crossesUp ? '等待重新从均线下方站上' : '等待重新从均线上方跌破',
    );
  }

  static RuleEvaluationDetail _evaluateEnvironmentRule({
    required SignalRule rule,
    required List<double> closes,
    required List<double?> maSeries,
    required Map<String, double> current,
  }) {
    if (closes.isEmpty || maSeries.isEmpty) {
      return _detail(
        rule,
        false,
        RuleProgressState.insufficientData,
        '趋势环境数据不足',
      );
    }
    final currentIndex = maSeries.length - 1;
    final previousIndex = currentIndex - rule.lookbackDays;
    final currentMa = maSeries[currentIndex];
    final previousMa = previousIndex >= 0 ? maSeries[previousIndex] : null;
    if (currentMa == null || previousMa == null || previousMa == 0) {
      return _detail(
        rule,
        false,
        RuleProgressState.insufficientData,
        '短期均线历史不足，暂不能判断趋势环境',
      );
    }

    final slopePct = (currentMa - previousMa) / previousMa * 100;
    final threshold = rule.value.abs();
    final environment = slopePct.abs() <= threshold
        ? 0.0
        : slopePct > 0 && closes.last > currentMa
        ? 1.0
        : -1.0;
    current['ma_short_slope_pct'] = slopePct;
    current['market_environment'] = environment;

    final passed = switch (rule.condition) {
      'uptrend' => environment == 1,
      'downtrend' => environment == -1,
      'sideways' => environment == 0,
      'not_sideways' => environment != 0,
      _ => false,
    };
    final label = switch (environment) {
      1.0 => '上升趋势',
      -1.0 => '下降趋势',
      _ => '横盘震荡',
    };
    return _detail(
      rule,
      passed,
      passed ? RuleProgressState.matched : RuleProgressState.environmentBlocked,
      passed
          ? '当前环境：$label（短期均线 ${rule.lookbackDays} 日斜率 ${slopePct.toStringAsFixed(2)}%）'
          : '当前环境：$label，策略环境条件不满足，暂停给出信号',
    );
  }

  static RuleEvaluationDetail _detail(
    SignalRule rule,
    bool passed,
    RuleProgressState state,
    String message,
  ) => RuleEvaluationDetail(
    rule: rule,
    passed: passed,
    state: state,
    message: message,
  );

  static String _plainRuleMessage(SignalRule rule, bool passed) {
    return switch (rule.indicator) {
      'ladder_breakout' => passed ? '较高平台与向上突破结构已出现' : '尚未同时形成平台抬高、收敛和向上突破',
      'ladder_support_gap_pct' => passed ? '收盘价已跌破近期梯级平台支撑' : '收盘价仍在近期梯级平台支撑之上',
      'chan_third_buy' =>
        passed ? '简化中枢向上离开后，回抽仍在中枢上沿之外' : '尚未形成完整的简化中枢离开与回抽确认',
      'chan_center_support_gap_pct' =>
        passed ? '收盘价已回到简化中枢上沿以内' : '收盘价仍在简化中枢上沿之外',
      _ => passed ? '当前条件已满足' : '当前条件未满足',
    };
  }

  static List<double?> _simpleMovingAverageAligned(
    List<double> values,
    int period,
  ) {
    final result = List<double?>.filled(values.length, null);
    if (period < 1 || values.length < period) return result;
    var sum = 0.0;
    for (var i = 0; i < values.length; i++) {
      sum += values[i];
      if (i >= period) sum -= values[i - period];
      if (i >= period - 1) result[i] = sum / period;
    }
    return result;
  }

  static List<double?> _priceMaGapSeries(
    List<double> closes,
    List<double?> maSeries,
  ) {
    return List<double?>.generate(closes.length, (index) {
      final ma = maSeries[index];
      if (ma == null || ma == 0) return null;
      return (closes[index] - ma) / ma * 100;
    });
  }

  static void _addAlignedLatest(
    String key,
    List<double?> values,
    Map<String, double> current,
    Map<String, double> prev,
  ) {
    if (values.isEmpty || values.last == null) return;
    current[key] = values.last!;
    if (values.length >= 2 && values[values.length - 2] != null) {
      prev[key] = values[values.length - 2]!;
    }
  }
}
