import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/utils/background_compute.dart';
import '../domain/strategy_models.dart';
import '../domain/strategy_knowledge_package.dart';
import '../domain/strategy_version_diff.dart';
import '../domain/signal_rule.dart';
import '../domain/stock_filter.dart';
import '../domain/backtest_models.dart';
import '../../stock/data/kline_cache.dart';
import 'database.dart';

class StrategyVersionActivationException implements Exception {
  final String message;

  const StrategyVersionActivationException(this.message);

  @override
  String toString() => message;
}

/// Service layer for strategy CRUD, hit records, and reviews.
/// All operations go through Drift (SQLite).
class StrategyService {
  final AppDatabase _db;
  final KlineCacheDatabase? _klineCache;
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  /// In-memory cache of strategies with their stats.
  List<Strategy> _cache = [];

  StrategyService({AppDatabase? db, KlineCacheDatabase? klineCache})
    : _db = db ?? AppDatabase(),
      _klineCache = klineCache;

  /// Initialize: load all strategies and compute stats.
  Future<void> init() async {
    return _initFuture ??= _init();
  }

  Future<void> _init() async {
    await _db.ensureDefaultStrategy();
    await reloadCache();
    await _ensureVersionBaselines();
    // Fire-and-forget: backfill from local K-line cache without blocking startup.
    backfillFromLocalData();
  }

  /// Reload all strategies from DB into cache with stats.
  /// Uses batch DB fetch + single Isolate call to avoid blocking UI.
  Future<void> reloadCache() async {
    final rows = await _db.select(_db.strategies).get();
    if (rows.isEmpty) {
      _cache = [];
      return;
    }

    // Batch fetch all hit records in one query (main thread)
    final allHitRecords = await _db.select(_db.strategyHitRecords).get();
    final now = DateTime.now();

    // Prepare serializable input for each strategy
    final inputs = <List<dynamic>>[];
    for (final row in rows) {
      final records = allHitRecords
          .where((r) => r.strategyId == row.id)
          .toList();
      inputs.add([
        records.map((r) => r.actualChange5d).toList(),
        records.map((r) => r.isHit).toList(),
        records.length,
        now.difference(row.createdAt).inDays,
      ]);
    }

    // Compute all stats in a single Isolate call (off main thread)
    final allStats = await _runBatchStatsInIsolate(inputs);

    final strategies = List<Strategy>.generate(rows.length, (i) {
      return _rowToDomain(rows[i], stats: allStats[i]);
    });

    // Sort: enabled first, then by hit rate descending
    strategies.sort((a, b) {
      if (a.isEnabled != b.isEnabled) return a.isEnabled ? -1 : 1;
      final rateA = a.stats?.hitRate ?? 0;
      final rateB = b.stats?.hitRate ?? 0;
      return rateB.compareTo(rateA);
    });
    _cache = strategies;
  }

  /// Get all strategies from cache.
  List<Strategy> getStrategies() => List.unmodifiable(_cache);

  /// Get a single strategy by ID from cache.
  Strategy? getStrategy(String id) {
    try {
      return _cache.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all enabled strategies from cache.
  List<Strategy> getEnabledStrategies() =>
      _cache.where((s) => s.isEnabled).toList();

  // ── Strategy CRUD ──────────────────────────────────────────

  /// Create a new strategy.
  Future<Strategy> createStrategy(StrategyFormData form) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    // Serialize rules and groups to JSON
    final Value<String?> entryRulesVal = form.entryRules.isNotEmpty
        ? Value(jsonEncode(form.entryRules.map((r) => r.toJson()).toList()))
        : const Value.absent();
    final Value<String?> exitRulesVal = form.exitRules.isNotEmpty
        ? Value(jsonEncode(form.exitRules.map((r) => r.toJson()).toList()))
        : const Value.absent();
    final Value<String?> entryGroupsVal = form.entryGroups.isNotEmpty
        ? Value(jsonEncode(form.entryGroups.map((g) => g.toJson()).toList()))
        : const Value.absent();
    final Value<String?> exitGroupsVal = form.exitGroups.isNotEmpty
        ? Value(jsonEncode(form.exitGroups.map((g) => g.toJson()).toList()))
        : const Value.absent();
    final Value<String?> stockFilterVal =
        (form.stockFilter != null && form.stockFilter!.isActive)
        ? Value(jsonEncode(form.stockFilter!.toJson()))
        : const Value.absent();

    await _db
        .into(_db.strategies)
        .insert(
          StrategiesCompanion.insert(
            id: id,
            name: form.name.trim(),
            description: Value(form.description.trim()),
            maShortPeriod: Value(form.maShortPeriod),
            maLongPeriod: Value(form.maLongPeriod),
            bollPeriod: Value(form.bollPeriod),
            bollStdDev: Value(form.bollStdDev),
            weightMA: Value(form.weightMA),
            weightBoll: Value(form.weightBoll),
            weightVol: Value(form.weightVol),
            weightTrend: Value(form.weightTrend),
            recommendThreshold: Value(form.recommendThreshold),
            entryRulesJson: entryRulesVal,
            exitRulesJson: exitRulesVal,
            entryGroupsJson: entryGroupsVal,
            exitGroupsJson: exitGroupsVal,
            stockFilterJson: stockFilterVal,
            isEnabled: const Value(true),
            isDefault: const Value(false),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _insertManualVersion(
      strategyId: id,
      form: form,
      createdAt: now,
      isEnabled: true,
      status: 'active',
    );

    await reloadCache();
    return _cache.firstWhere((s) => s.id == id);
  }

  /// Update an existing strategy.
  Future<Strategy> updateStrategy(String id, StrategyFormData form) async {
    final now = DateTime.now();
    final existing = getStrategy(id);
    if (existing == null) {
      throw StateError('Strategy not found: $id');
    }

    // Serialize rules and groups to JSON
    final Value<String?> entryRulesVal = form.entryRules.isNotEmpty
        ? Value(jsonEncode(form.entryRules.map((r) => r.toJson()).toList()))
        : const Value.absent();
    final Value<String?> exitRulesVal = form.exitRules.isNotEmpty
        ? Value(jsonEncode(form.exitRules.map((r) => r.toJson()).toList()))
        : const Value.absent();
    final Value<String?> entryGroupsVal = form.entryGroups.isNotEmpty
        ? Value(jsonEncode(form.entryGroups.map((g) => g.toJson()).toList()))
        : const Value.absent();
    final Value<String?> exitGroupsVal = form.exitGroups.isNotEmpty
        ? Value(jsonEncode(form.exitGroups.map((g) => g.toJson()).toList()))
        : const Value.absent();
    final Value<String?> stockFilterVal =
        (form.stockFilter != null && form.stockFilter!.isActive)
        ? Value(jsonEncode(form.stockFilter!.toJson()))
        : const Value.absent();

    await (_db.update(_db.strategies)..where((t) => t.id.equals(id))).write(
      StrategiesCompanion(
        name: Value(form.name.trim()),
        description: Value(form.description.trim()),
        maShortPeriod: Value(form.maShortPeriod),
        maLongPeriod: Value(form.maLongPeriod),
        bollPeriod: Value(form.bollPeriod),
        bollStdDev: Value(form.bollStdDev),
        weightMA: Value(form.weightMA),
        weightBoll: Value(form.weightBoll),
        weightVol: Value(form.weightVol),
        weightTrend: Value(form.weightTrend),
        recommendThreshold: Value(form.recommendThreshold),
        entryRulesJson: entryRulesVal,
        exitRulesJson: exitRulesVal,
        entryGroupsJson: entryGroupsVal,
        exitGroupsJson: exitGroupsVal,
        stockFilterJson: stockFilterVal,
        updatedAt: Value(now),
      ),
    );

    await _insertManualVersion(
      strategyId: id,
      form: form,
      createdAt: now,
      isEnabled: existing.isEnabled,
      status: existing.isEnabled ? 'active' : 'draft',
    );

    await reloadCache();
    return _cache.firstWhere((s) => s.id == id);
  }

  /// Delete a strategy (not allowed for default strategies).
  Future<void> deleteStrategy(String id) async {
    final strategy = getStrategy(id);
    if (strategy != null && strategy.isDefault) {
      throw Exception('DEFAULT_STRATEGY_CANNOT_DELETE');
    }
    // Delete associated hit records and reviews first
    await (_db.delete(
      _db.strategyHitRecords,
    )..where((t) => t.strategyId.equals(id))).go();
    await (_db.delete(
      _db.strategyReviews,
    )..where((t) => t.strategyId.equals(id))).go();
    await (_db.delete(
      _db.strategyBacktestRuns,
    )..where((t) => t.strategyId.equals(id))).go();
    final versions = await (_db.select(
      _db.strategyVersions,
    )..where((t) => t.strategyId.equals(id))).get();
    for (final version in versions) {
      await (_db.delete(
        _db.strategyVersionSources,
      )..where((t) => t.versionId.equals(version.id))).go();
    }
    await (_db.delete(
      _db.strategyVersions,
    )..where((t) => t.strategyId.equals(id))).go();
    await (_db.delete(
      _db.strategySources,
    )..where((t) => t.strategyId.equals(id))).go();
    await (_db.delete(_db.strategies)..where((t) => t.id.equals(id))).go();
    await reloadCache();
  }

  /// Toggle strategy enabled/disabled status.
  Future<bool> toggleEnabled(String id, bool isEnabled) async {
    if (isEnabled && !await canEnableStrategy(id)) {
      return false;
    }
    final now = DateTime.now();
    await (_db.update(_db.strategies)..where((t) => t.id.equals(id))).write(
      StrategiesCompanion(isEnabled: Value(isEnabled), updatedAt: Value(now)),
    );
    if (isEnabled) {
      final latestApplicable = await _latestApplicableVersion(id);
      if (latestApplicable != null && latestApplicable.status == 'draft') {
        await (_db.update(_db.strategyVersions)
              ..where((t) => t.id.equals(latestApplicable.id)))
            .write(const StrategyVersionsCompanion(status: Value('active')));
      }
    }
    await reloadCache();
    return true;
  }

  // ── Knowledge sources & immutable versions ─────────────────

  /// Imports a reviewed agent package transactionally.
  ///
  /// A new strategy is always created disabled. When [targetStrategyId] is
  /// supplied, the current strategy remains untouched and the import is saved
  /// as a candidate version for later comparison and activation.
  Future<StrategyKnowledgeImportResult> importKnowledgePackage(
    StrategyKnowledgePackage package, {
    bool retainSanitizedText = false,
    String? targetStrategyId,
  }) async {
    await init();
    final existing = targetStrategyId == null
        ? null
        : getStrategy(targetStrategyId);
    if (targetStrategyId != null && existing == null) {
      throw StateError('Strategy not found: $targetStrategyId');
    }

    final now = DateTime.now();
    final strategyId = existing?.id ?? _uuid.v4();
    final versionId = _uuid.v4();
    var versionNumber = 1;

    await _db.transaction(() async {
      if (existing == null) {
        final form = package.form;
        await _db
            .into(_db.strategies)
            .insert(
              StrategiesCompanion.insert(
                id: strategyId,
                name: form.name.trim(),
                description: Value(form.description.trim()),
                maShortPeriod: Value(form.maShortPeriod),
                maLongPeriod: Value(form.maLongPeriod),
                bollPeriod: Value(form.bollPeriod),
                bollStdDev: Value(form.bollStdDev),
                weightMA: Value(form.weightMA),
                weightBoll: Value(form.weightBoll),
                weightVol: Value(form.weightVol),
                weightTrend: Value(form.weightTrend),
                recommendThreshold: Value(form.recommendThreshold),
                entryRulesJson: _rulesValue(form.entryRules),
                exitRulesJson: _rulesValue(form.exitRules),
                entryGroupsJson: _groupsValue(form.entryGroups),
                exitGroupsJson: _groupsValue(form.exitGroups),
                stockFilterJson: _stockFilterValue(form.stockFilter),
                isEnabled: const Value(false),
                isDefault: const Value(false),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      final existingVersions = await (_db.select(
        _db.strategyVersions,
      )..where((t) => t.strategyId.equals(strategyId))).get();
      existingVersions.sort(
        (a, b) => b.versionNumber.compareTo(a.versionNumber),
      );
      versionNumber = existingVersions.isEmpty
          ? 1
          : existingVersions.first.versionNumber + 1;
      final previousVersionId = existingVersions.isEmpty
          ? null
          : existingVersions.first.id;

      final snapshot = _strategyFromForm(
        id: strategyId,
        form: package.form,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        isEnabled: false,
        isDefault: existing?.isDefault ?? false,
      );
      await _db
          .into(_db.strategyVersions)
          .insert(
            StrategyVersionsCompanion.insert(
              id: versionId,
              strategyId: strategyId,
              versionNumber: versionNumber,
              status: existing == null ? 'draft' : 'candidate',
              strategyType: package.strategyType.code,
              strategySnapshotJson: jsonEncode(snapshot.toJson()),
              packageJson: Value(
                jsonEncode(
                  _packageJsonForStorage(
                    package,
                    retainSanitizedText: retainSanitizedText,
                  ),
                ),
              ),
              applicabilityJson: jsonEncode(package.applicability.toJson()),
              riskNotesJson: jsonEncode(package.riskNotes),
              pendingQuestionsJson: jsonEncode(package.pendingQuestions),
              compatibilityIssuesJson: jsonEncode(
                package.compatibilityIssues
                    .map((issue) => issue.toJson())
                    .toList(),
              ),
              previousVersionId: Value(previousVersionId),
              createdAt: now,
            ),
          );

      final sourceIdsByExternalRef = <String, String>{};
      for (final source in package.sources) {
        final duplicate =
            await (_db.select(_db.strategySources)..where(
                  (t) =>
                      t.strategyId.equals(strategyId) &
                      t.fingerprint.equals(source.fingerprint),
                ))
                .getSingleOrNull();
        final sourceId = duplicate?.id ?? _uuid.v4();
        if (duplicate == null) {
          await _db
              .into(_db.strategySources)
              .insert(
                StrategySourcesCompanion.insert(
                  id: sourceId,
                  strategyId: strategyId,
                  externalRef: source.externalRef,
                  sourceType: source.kind.code,
                  speaker: Value(source.speaker),
                  capturedAt: Value(source.capturedAt),
                  summary: source.summary,
                  sanitizedText: Value(
                    retainSanitizedText ? source.sanitizedText : null,
                  ),
                  fingerprint: source.fingerprint,
                  createdAt: now,
                ),
              );
        }
        sourceIdsByExternalRef[source.externalRef] = sourceId;
      }

      for (final entry in sourceIdsByExternalRef.entries) {
        final ruleIds = package.rules
            .where((rule) => rule.sourceRefs.contains(entry.key))
            .map((rule) => rule.id)
            .toList();
        await _db
            .into(_db.strategyVersionSources)
            .insert(
              StrategyVersionSourcesCompanion.insert(
                versionId: versionId,
                sourceId: entry.value,
                ruleIdsJson: jsonEncode(ruleIds),
              ),
            );
      }
    });

    if (existing == null) {
      await reloadCache();
    }
    return StrategyKnowledgeImportResult(
      strategyId: strategyId,
      versionId: versionId,
      versionNumber: versionNumber,
      createdStrategy: existing == null,
    );
  }

  Future<List<StrategyVersionInfo>> getStrategyVersions(
    String strategyId,
  ) async {
    final versions =
        await (_db.select(_db.strategyVersions)
              ..where((t) => t.strategyId.equals(strategyId))
              ..orderBy([(t) => OrderingTerm.desc(t.versionNumber)]))
            .get();
    if (versions.isEmpty) return const [];

    final sourceRows = await (_db.select(
      _db.strategySources,
    )..where((t) => t.strategyId.equals(strategyId))).get();
    final sourceById = {for (final source in sourceRows) source.id: source};
    final versionIds = versions.map((version) => version.id).toSet();
    final links = await _db.select(_db.strategyVersionSources).get();

    return versions.map((version) {
      final versionLinks = links
          .where((link) => versionIds.contains(link.versionId))
          .where((link) => link.versionId == version.id)
          .toList();
      final sources = versionLinks.map((link) {
        final row = sourceById[link.sourceId]!;
        return StrategySourceInfo(
          id: row.id,
          kind: _parseSourceKind(row.sourceType),
          speaker: row.speaker,
          capturedAt: row.capturedAt,
          summary: row.summary,
          hasStoredText: row.sanitizedText?.isNotEmpty == true,
          ruleIds: _decodeStringList(link.ruleIdsJson),
        );
      }).toList();
      return StrategyVersionInfo(
        id: version.id,
        strategyId: version.strategyId,
        versionNumber: version.versionNumber,
        status: version.status,
        strategyType: _parseKnowledgeType(version.strategyType),
        riskNotes: _decodeStringList(version.riskNotesJson),
        pendingQuestions: _decodeStringList(version.pendingQuestionsJson),
        compatibilityIssues: _decodeCompatibilityIssues(
          version.compatibilityIssuesJson,
        ),
        previousVersionId: version.previousVersionId,
        createdAt: version.createdAt,
        sources: sources,
        strategySnapshot: Strategy.fromJson(
          jsonDecode(version.strategySnapshotJson) as Map<String, dynamic>,
        ),
      );
    }).toList();
  }

  Future<StrategyVersionInfo?> getStrategyVersion(
    String strategyId, {
    String? versionId,
  }) async {
    final versions = await getStrategyVersions(strategyId);
    if (versions.isEmpty) return null;
    if (versionId != null) {
      return versions.where((version) => version.id == versionId).firstOrNull;
    }
    return versions
            .where((version) => version.status == 'active')
            .firstOrNull ??
        versions.where((version) => version.status == 'draft').firstOrNull ??
        versions.first;
  }

  Future<StrategyVersionDiff> getStrategyVersionDiff(
    String strategyId,
    String versionId,
  ) async {
    final versions = await getStrategyVersions(strategyId);
    final candidate = versions
        .where((version) => version.id == versionId)
        .firstOrNull;
    if (candidate == null) {
      throw StateError('Strategy version not found: $versionId');
    }
    final baseline = candidate.previousVersionId == null
        ? null
        : versions
              .where((version) => version.id == candidate.previousVersionId)
              .firstOrNull;
    return StrategyVersionDiff.compare(
      baseline: baseline,
      candidate: candidate,
    );
  }

  /// Makes an immutable version the current strategy configuration.
  ///
  /// Existing snapshots and version-bound backtests are retained. Pending or
  /// engine-blocking versions can never be activated. A detected opposite rule
  /// requires explicit confirmation from the UI before the transaction runs.
  Future<StrategyVersionInfo> activateStrategyVersion(
    String strategyId,
    String versionId, {
    bool confirmedConflicts = false,
  }) async {
    await init();
    final versions = await getStrategyVersions(strategyId);
    final target = versions
        .where((version) => version.id == versionId)
        .firstOrNull;
    if (target == null) {
      throw const StrategyVersionActivationException('策略版本不存在');
    }
    if (target.status == 'active') return target;
    if (!target.canEnable) {
      throw const StrategyVersionActivationException(
        '仍有待确认问题或当前引擎不支持的规则，暂不能激活',
      );
    }

    final diff = await getStrategyVersionDiff(strategyId, versionId);
    if (diff.hasConflicts && !confirmedConflicts) {
      throw const StrategyVersionActivationException('检测到相反规则，请确认差异后再激活');
    }

    final current = getStrategy(strategyId);
    if (current == null) {
      throw const StrategyVersionActivationException('策略不存在');
    }
    final snapshot = target.strategySnapshot;
    final now = DateTime.now();

    await _db.transaction(() async {
      await (_db.update(_db.strategyVersions)..where(
            (table) =>
                table.strategyId.equals(strategyId) &
                table.status.equals('active'),
          ))
          .write(const StrategyVersionsCompanion(status: Value('archived')));
      await (_db.update(_db.strategyVersions)
            ..where((table) => table.id.equals(versionId)))
          .write(const StrategyVersionsCompanion(status: Value('active')));
      await (_db.update(
        _db.strategies,
      )..where((table) => table.id.equals(strategyId))).write(
        StrategiesCompanion(
          name: Value(snapshot.name),
          description: Value(snapshot.description),
          maShortPeriod: Value(snapshot.maShortPeriod),
          maLongPeriod: Value(snapshot.maLongPeriod),
          bollPeriod: Value(snapshot.bollPeriod),
          bollStdDev: Value(snapshot.bollStdDev),
          weightMA: Value(snapshot.weightMA),
          weightBoll: Value(snapshot.weightBoll),
          weightVol: Value(snapshot.weightVol),
          weightTrend: Value(snapshot.weightTrend),
          recommendThreshold: Value(snapshot.recommendThreshold),
          entryRulesJson: _nullableRulesValue(snapshot.entryRules),
          exitRulesJson: _nullableRulesValue(snapshot.exitRules),
          entryGroupsJson: _nullableGroupsValue(snapshot.entryGroups),
          exitGroupsJson: _nullableGroupsValue(snapshot.exitGroups),
          stockFilterJson: Value(
            snapshot.stockFilter?.isActive == true
                ? jsonEncode(snapshot.stockFilter!.toJson())
                : null,
          ),
          updatedAt: Value(now),
        ),
      );
    });

    await reloadCache();
    return (await getStrategyVersions(
      strategyId,
    )).firstWhere((version) => version.id == versionId);
  }

  // ── Version-bound backtest reports ─────────────────────────────

  Future<void> saveBacktestReport(BacktestReport report) async {
    await _db
        .into(_db.strategyBacktestRuns)
        .insert(
          StrategyBacktestRunsCompanion.insert(
            id: report.id,
            strategyId: report.strategyId,
            strategyVersionId: report.strategyVersionId,
            strategyVersionNumber: report.strategyVersionNumber,
            stockCode: report.result.stockCode,
            stockName: report.stockName,
            market: report.market,
            configJson: jsonEncode(report.config.toJson()),
            resultJson: jsonEncode(report.result.toJson()),
            adjustmentMode: report.adjustmentMode.name,
            dataFingerprint: report.dataFingerprint,
            dataStart: Value(report.result.startDate),
            dataEnd: Value(report.result.endDate),
            dataAsOf: report.dataAsOf,
            barsProcessed: report.result.barsProcessed,
            sampleCount: report.result.totalTrades,
            createdAt: report.createdAt,
          ),
        );
  }

  Future<List<BacktestReport>> getBacktestReports(
    String strategyId, {
    String? stockCode,
  }) async {
    final query = _db.select(_db.strategyBacktestRuns)
      ..where((row) => row.strategyId.equals(strategyId));
    if (stockCode != null) {
      query.where((row) => row.stockCode.equals(stockCode));
    }
    query.orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    final rows = await query.get();
    return rows.map(_backtestRowToDomain).toList();
  }

  BacktestReport _backtestRowToDomain(StrategyBacktestRunRow row) {
    return BacktestReport(
      id: row.id,
      strategyId: row.strategyId,
      strategyVersionId: row.strategyVersionId,
      strategyVersionNumber: row.strategyVersionNumber,
      stockName: row.stockName,
      market: row.market,
      config: BacktestConfig.fromJson(
        jsonDecode(row.configJson) as Map<String, dynamic>,
      ),
      adjustmentMode: BacktestAdjustmentMode.values.byName(row.adjustmentMode),
      dataFingerprint: row.dataFingerprint,
      dataAsOf: row.dataAsOf,
      createdAt: row.createdAt,
      result: BacktestResult.fromJson(
        jsonDecode(row.resultJson) as Map<String, dynamic>,
      ),
    );
  }

  Future<bool> canEnableStrategy(String strategyId) async {
    final latest = await _latestApplicableVersion(strategyId);
    if (latest == null) return true;
    final pending = _decodeStringList(latest.pendingQuestionsJson);
    final issues = _decodeCompatibilityIssues(latest.compatibilityIssuesJson);
    return pending.isEmpty && issues.every((issue) => !issue.blocking);
  }

  Future<void> _ensureVersionBaselines() async {
    for (final strategy in _cache) {
      final existing =
          await (_db.select(_db.strategyVersions)
                ..where((t) => t.strategyId.equals(strategy.id))
                ..limit(1))
              .getSingleOrNull();
      if (existing != null) continue;
      await _insertVersionSnapshot(
        strategy: strategy,
        status: strategy.isEnabled ? 'active' : 'draft',
        strategyType: StrategyKnowledgeType.custom,
      );
    }
  }

  Future<void> _insertManualVersion({
    required String strategyId,
    required StrategyFormData form,
    required DateTime createdAt,
    required bool isEnabled,
    required String status,
  }) async {
    final existing = getStrategy(strategyId);
    final strategy = _strategyFromForm(
      id: strategyId,
      form: form,
      createdAt: existing?.createdAt ?? createdAt,
      updatedAt: createdAt,
      isEnabled: isEnabled,
      isDefault: existing?.isDefault ?? false,
    );
    await _insertVersionSnapshot(
      strategy: strategy,
      status: status,
      strategyType: StrategyKnowledgeType.custom,
    );
  }

  Future<void> _insertVersionSnapshot({
    required Strategy strategy,
    required String status,
    required StrategyKnowledgeType strategyType,
  }) async {
    final existingVersions = await (_db.select(
      _db.strategyVersions,
    )..where((t) => t.strategyId.equals(strategy.id))).get();
    existingVersions.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    final previous = existingVersions.isEmpty ? null : existingVersions.first;
    await _db
        .into(_db.strategyVersions)
        .insert(
          StrategyVersionsCompanion.insert(
            id: _uuid.v4(),
            strategyId: strategy.id,
            versionNumber: (previous?.versionNumber ?? 0) + 1,
            status: status,
            strategyType: strategyType.code,
            strategySnapshotJson: jsonEncode(strategy.toJson()),
            applicabilityJson: '{}',
            riskNotesJson: '[]',
            pendingQuestionsJson: '[]',
            compatibilityIssuesJson: '[]',
            previousVersionId: Value(previous?.id),
            createdAt: strategy.updatedAt,
          ),
        );
  }

  Future<StrategyVersionRow?> _latestApplicableVersion(
    String strategyId,
  ) async {
    final versions = await (_db.select(
      _db.strategyVersions,
    )..where((t) => t.strategyId.equals(strategyId))).get();
    final applicable =
        versions.where((version) => version.status != 'candidate').toList()
          ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    return applicable.isEmpty ? null : applicable.first;
  }

  Strategy _strategyFromForm({
    required String id,
    required StrategyFormData form,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isEnabled,
    required bool isDefault,
  }) {
    return Strategy(
      id: id,
      name: form.name.trim(),
      description: form.description.trim(),
      maShortPeriod: form.maShortPeriod,
      maLongPeriod: form.maLongPeriod,
      bollPeriod: form.bollPeriod,
      bollStdDev: form.bollStdDev,
      weightMA: form.weightMA,
      weightBoll: form.weightBoll,
      weightVol: form.weightVol,
      weightTrend: form.weightTrend,
      recommendThreshold: form.recommendThreshold,
      isEnabled: isEnabled,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
      entryRules: form.entryRules.isEmpty ? null : form.entryRules,
      exitRules: form.exitRules.isEmpty ? null : form.exitRules,
      entryGroups: form.entryGroups.isEmpty ? null : form.entryGroups,
      exitGroups: form.exitGroups.isEmpty ? null : form.exitGroups,
      stockFilter: form.stockFilter,
    );
  }

  Value<String?> _rulesValue(List<SignalRule> rules) => rules.isEmpty
      ? const Value.absent()
      : Value(jsonEncode(rules.map((rule) => rule.toJson()).toList()));

  Value<String?> _nullableRulesValue(List<SignalRule>? rules) => Value(
    rules == null
        ? null
        : jsonEncode(rules.map((rule) => rule.toJson()).toList()),
  );

  Value<String?> _groupsValue(List<RuleGroup> groups) => groups.isEmpty
      ? const Value.absent()
      : Value(jsonEncode(groups.map((group) => group.toJson()).toList()));

  Value<String?> _nullableGroupsValue(List<RuleGroup>? groups) => Value(
    groups == null
        ? null
        : jsonEncode(groups.map((group) => group.toJson()).toList()),
  );

  Value<String?> _stockFilterValue(StockFilter? filter) =>
      filter != null && filter.isActive
      ? Value(jsonEncode(filter.toJson()))
      : const Value.absent();

  Map<String, dynamic> _packageJsonForStorage(
    StrategyKnowledgePackage package, {
    required bool retainSanitizedText,
  }) {
    final json = package.toJson();
    if (!retainSanitizedText) {
      final sources = (json['sources'] as List)
          .map((source) => Map<String, dynamic>.from(source as Map))
          .toList();
      for (final source in sources) {
        source.remove('sanitizedText');
      }
      json['sources'] = sources;
    }
    return json;
  }

  List<String> _decodeStringList(String json) {
    try {
      return (jsonDecode(json) as List).map((item) => '$item').toList();
    } catch (_) {
      return const [];
    }
  }

  List<StrategyCompatibilityIssue> _decodeCompatibilityIssues(String json) {
    try {
      return (jsonDecode(json) as List)
          .map(
            (item) => StrategyCompatibilityIssue.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  StrategyKnowledgeType _parseKnowledgeType(String value) {
    try {
      return StrategyKnowledgeTypeX.parse(value);
    } catch (_) {
      return StrategyKnowledgeType.custom;
    }
  }

  StrategySourceKind _parseSourceKind(String value) {
    try {
      return StrategySourceKindX.parse(value);
    } catch (_) {
      return StrategySourceKind.other;
    }
  }

  // ── Hit Records ────────────────────────────────────────────

  /// Record a batch of recommendations for a strategy on a given date.
  Future<void> recordRecommendations(
    String strategyId,
    List<({String code, String name, int score, double price})> recommendations,
  ) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final now = DateTime.now();

    for (final rec in recommendations) {
      final existing =
          await (_db.select(_db.strategyHitRecords)..where(
                (t) =>
                    t.strategyId.equals(strategyId) &
                    t.stockCode.equals(rec.code) &
                    t.recommendDate.equals(today),
              ))
              .getSingleOrNull();
      if (existing != null) continue;

      final id = _uuid.v4();
      await _db
          .into(_db.strategyHitRecords)
          .insert(
            StrategyHitRecordsCompanion.insert(
              id: id,
              strategyId: strategyId,
              stockCode: rec.code,
              stockName: rec.name,
              recommendDate: today,
              recommendScore: rec.score,
              recommendPrice: rec.price,
              createdAt: now,
            ),
          );
    }

    // Prune old records if exceeding 500
    await _pruneOldRecords(strategyId);
  }

  /// Get hit records for a strategy, most recent first.
  Future<List<StrategyHitRecord>> getHitRecords(
    String strategyId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final query = (_db.select(_db.strategyHitRecords)
      ..where((t) => t.strategyId.equals(strategyId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.recommendDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit, offset: offset));
    final rows = await query.get();
    return rows.map(_hitRowToDomain).toList();
  }

  /// Fill in actual 5-day changes for records that are due.
  /// Returns the number of records updated.
  Future<int> backfillActualChanges(Map<String, double> currentPrices) async {
    // Find all unfilled records
    final unfilled = await (_db.select(
      _db.strategyHitRecords,
    )..where((t) => t.isHit.isNull())).get();

    int updated = 0;
    final now = DateTime.now();

    for (final record in unfilled) {
      final recDate = DateTime.tryParse(record.recommendDate);
      if (recDate == null) continue;

      // Only backfill if at least 7 calendar days have passed (approx 5 trading days)
      final daysSince = now.difference(recDate).inDays;
      if (daysSince < 7) continue;

      final currentPrice = currentPrices[record.stockCode];
      if (currentPrice == null || currentPrice <= 0) continue;

      final changePct =
          ((currentPrice - record.recommendPrice) / record.recommendPrice) *
          100;
      // A "hit" must clear a small positive threshold (covers trading costs +
      // avoids trivially green stocks inflating the hit rate). See
      // AppConstants.hitRateThresholdPct.
      final isHit = changePct > AppConstants.hitRateThresholdPct;

      await (_db.update(
        _db.strategyHitRecords,
      )..where((t) => t.id.equals(record.id))).write(
        StrategyHitRecordsCompanion(
          actualChange5d: Value(changePct),
          isHit: Value(isHit),
        ),
      );
      updated++;
    }

    if (updated > 0) {
      await reloadCache();
    }
    return updated;
  }

  /// Backfill actual 5-day changes from local K-line cache.
  /// Automatically retrieves closing prices from cached K-line data
  /// for records that are due but haven't been filled yet.
  /// Returns the number of records updated.
  Future<int> backfillFromLocalData() async {
    if (_klineCache == null) return 0;

    // Find all unfilled records
    final unfilled = await (_db.select(
      _db.strategyHitRecords,
    )..where((t) => t.isHit.isNull())).get();

    int updated = 0;
    final now = DateTime.now();

    for (final record in unfilled) {
      final recDate = DateTime.tryParse(record.recommendDate);
      if (recDate == null) continue;

      // Only backfill if at least 7 calendar days have passed (approx 5 trading days)
      final daysSince = now.difference(recDate).inDays;
      if (daysSince < 7) continue;

      // Get K-line data from local cache
      final klines = await _klineCache.getCachedKlines(record.stockCode);
      if (klines == null || klines.isEmpty) continue;

      // Sort klines by date ascending
      final sorted = List.of(klines)..sort((a, b) => a.date.compareTo(b.date));

      // Find klines on or after the recommend date
      final afterRec = sorted.where((k) => !k.date.isBefore(recDate)).toList();
      if (afterRec.isEmpty) continue;

      // Need at least 5 trading days after the recommend date
      // The first entry is the recommend date itself, so we need index 5
      if (afterRec.length < 6) continue;

      // Use the close price on the 5th trading day after recommend date
      final day5Close = afterRec[5].close;
      if (day5Close <= 0 || record.recommendPrice <= 0) continue;

      final changePct =
          ((day5Close - record.recommendPrice) / record.recommendPrice) * 100;
      final isHit = changePct > AppConstants.hitRateThresholdPct;

      await (_db.update(
        _db.strategyHitRecords,
      )..where((t) => t.id.equals(record.id))).write(
        StrategyHitRecordsCompanion(
          actualChange5d: Value(changePct),
          isHit: Value(isHit),
        ),
      );
      updated++;
    }

    if (updated > 0) {
      await reloadCache();
    }
    return updated;
  }

  /// Prune old hit records for a strategy (keep most recent 400).
  Future<void> _pruneOldRecords(String strategyId) async {
    final count =
        await (_db.select(_db.strategyHitRecords)
              ..where((t) => t.strategyId.equals(strategyId)))
            .get()
            .then((rows) => rows.length);

    if (count > 500) {
      // Delete the 100 oldest records
      final oldest =
          await (_db.select(_db.strategyHitRecords)
                ..where((t) => t.strategyId.equals(strategyId))
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
                ..limit(100))
              .get();

      for (final record in oldest) {
        await (_db.delete(
          _db.strategyHitRecords,
        )..where((t) => t.id.equals(record.id))).go();
      }
    }
  }

  // ── Statistics ──────────────────────────────────────────────

  /// Compute statistics for a strategy from hit records.
  Future<StrategyStats> _computeStats(String strategyId) async {
    final allRecords = await (_db.select(
      _db.strategyHitRecords,
    )..where((t) => t.strategyId.equals(strategyId))).get();

    return _computeStatsForRows(strategyId, allRecords);
  }

  Future<StrategyStats> _computeStatsForRows(
    String strategyId,
    List<StrategyHitRecordRow> records,
  ) async {
    final strategy = await (_db.select(
      _db.strategies,
    )..where((t) => t.id.equals(strategyId))).getSingleOrNull();
    if (strategy == null) {
      return const StrategyStats();
    }

    // Prepare serializable data on main thread, then compute in Isolate
    final actualChanges = records.map((r) => r.actualChange5d).toList();
    final isHitFlags = records.map((r) => r.isHit).toList();
    final totalRecords = records.length;
    final tradingDaysRun = DateTime.now().difference(strategy.createdAt).inDays;

    return runInBackground(
      () => computeStatsPure(
        actualChanges,
        isHitFlags,
        totalRecords,
        tradingDaysRun,
      ),
    );
  }

  Future<_ReviewRecordSelection> _selectReviewRecords(
    String strategyId, {
    DateTime? now,
  }) async {
    final end = now ?? DateTime.now();
    final requestedStart = end.subtract(const Duration(days: 30));
    final evaluatedRows =
        await (_db.select(_db.strategyHitRecords)..where(
              (t) => t.strategyId.equals(strategyId) & t.isHit.isNotNull(),
            ))
            .get();

    final currentRows = evaluatedRows.where((row) {
      final date = DateTime.tryParse(row.recommendDate);
      return date != null &&
          !date.isBefore(requestedStart) &&
          !date.isAfter(end);
    }).toList();

    if (currentRows.isNotEmpty) {
      return _ReviewRecordSelection(
        records: currentRows,
        period: ReviewPeriodInfo(
          requestedStart: requestedStart,
          requestedEnd: end,
          dataStart: requestedStart,
          dataEnd: end,
          evaluatedCount: currentRows.length,
          sourceNote: '使用近30日已回填记录',
        ),
      );
    }

    final datedRows =
        evaluatedRows
            .map(
              (row) => (row: row, date: DateTime.tryParse(row.recommendDate)),
            )
            .where((item) => item.date != null)
            .toList()
          ..sort((a, b) => b.date!.compareTo(a.date!));

    if (datedRows.isEmpty) {
      return _ReviewRecordSelection(
        records: const [],
        period: ReviewPeriodInfo(
          requestedStart: requestedStart,
          requestedEnd: end,
          dataStart: requestedStart,
          dataEnd: end,
          evaluatedCount: 0,
          sourceNote: '近30日暂无已回填记录',
        ),
      );
    }

    final fallbackEnd = datedRows.first.date!;
    final fallbackStart = fallbackEnd.subtract(const Duration(days: 30));
    final fallbackRows = datedRows
        .where(
          (item) =>
              !item.date!.isBefore(fallbackStart) &&
              !item.date!.isAfter(fallbackEnd),
        )
        .map((item) => item.row)
        .toList();

    return _ReviewRecordSelection(
      records: fallbackRows,
      period: ReviewPeriodInfo(
        requestedStart: requestedStart,
        requestedEnd: end,
        dataStart: fallbackStart,
        dataEnd: fallbackEnd,
        evaluatedCount: fallbackRows.length,
        sourceNote: '近30日无已回填记录，改用上一可用周期',
      ),
    );
  }

  /// Compute stats and return (for external use, e.g. strategy detail page).
  Future<StrategyStats> computeStats(String strategyId) async {
    return _computeStats(strategyId);
  }

  // ── Reviews ─────────────────────────────────────────────────

  /// Create a review record for a strategy.
  Future<StrategyReview> createReview(
    String strategyId,
    List<ChecklistItem> checklistItems, {
    String? note,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final reviewData = await _selectReviewRecords(strategyId, now: now);
    final reviewRecords = reviewData.records;

    final hitRate30d = reviewRecords.isEmpty
        ? 0.0
        : reviewRecords.where((r) => r.isHit == true).length /
              reviewRecords.length;
    final avgChange30d = reviewRecords.isEmpty
        ? 0.0
        : reviewRecords
                  .map((r) => r.actualChange5d ?? 0.0)
                  .reduce((a, b) => a + b) /
              reviewRecords.length;
    final maxLoss30d = reviewRecords.isEmpty
        ? null
        : reviewRecords
              .map((r) => r.actualChange5d ?? 0.0)
              .reduce((a, b) => a < b ? a : b);

    // Determine hit rate trend (compare first half vs second half)
    final sorted = List.of(reviewRecords)
      ..sort((a, b) => a.recommendDate.compareTo(b.recommendDate));
    String hitRateTrend = 'flat';
    if (sorted.length >= 10) {
      final mid = sorted.length ~/ 2;
      final firstHalf =
          sorted.sublist(0, mid).where((r) => r.isHit == true).length / mid;
      final secondHalf =
          sorted.sublist(mid).where((r) => r.isHit == true).length /
          (sorted.length - mid);
      if (secondHalf > firstHalf + 0.1) {
        hitRateTrend = 'up';
      } else if (secondHalf < firstHalf - 0.1) {
        hitRateTrend = 'down';
      }
    }

    // Average daily count
    final uniqueDates = reviewRecords
        .map((r) => r.recommendDate)
        .toSet()
        .length;
    final avgDailyCount30d = uniqueDates > 0
        ? (reviewRecords.length / uniqueDates).round()
        : 0;

    // Health score
    final stats = await _computeStats(strategyId);

    // Serialize checklist to JSON
    final checklistJson = jsonEncode(
      checklistItems
          .map(
            (item) => {
              'title': item.title,
              'result': item.result.name,
              'detail': item.detail,
            },
          )
          .toList(),
    );

    await _db
        .into(_db.strategyReviews)
        .insert(
          StrategyReviewsCompanion.insert(
            id: id,
            strategyId: strategyId,
            reviewDate: now,
            healthScore: stats.healthScore,
            hitRate30d: hitRate30d,
            avgChange30d: avgChange30d,
            maxLoss30d: Value(maxLoss30d),
            hitRateTrend: hitRateTrend,
            avgDailyCount30d: avgDailyCount30d,
            checklistResult: checklistJson,
            note: Value(note),
            createdAt: now,
          ),
        );

    // Update lastReviewAt on strategy
    await (_db.update(
      _db.strategies,
    )..where((t) => t.id.equals(strategyId))).write(
      StrategiesCompanion(lastReviewAt: Value(now), updatedAt: Value(now)),
    );

    await reloadCache();

    return StrategyReview(
      id: id,
      strategyId: strategyId,
      reviewDate: now,
      healthScore: stats.healthScore,
      hitRate30d: hitRate30d,
      avgChange30d: avgChange30d,
      maxLoss30d: maxLoss30d,
      hitRateTrend: hitRateTrend,
      avgDailyCount30d: avgDailyCount30d,
      checklistItems: checklistItems,
      note: note,
      createdAt: now,
    );
  }

  /// Get review history for a strategy.
  Future<List<StrategyReview>> getReviewHistory(String strategyId) async {
    final rows =
        await (_db.select(_db.strategyReviews)
              ..where((t) => t.strategyId.equals(strategyId))
              ..orderBy([(t) => OrderingTerm.desc(t.reviewDate)]))
            .get();
    return rows.map(_reviewRowToDomain).toList();
  }

  // ── Review Checklist Generation ─────────────────────────────

  /// Generate a checklist for strategy review based on recent data.
  Future<List<ChecklistItem>> generateChecklist(String strategyId) async {
    final result = await generateChecklistResult(strategyId);
    return result.items;
  }

  /// Generate a checklist and the exact period used for the review.
  Future<ReviewChecklistResult> generateChecklistResult(
    String strategyId,
  ) async {
    final reviewData = await _selectReviewRecords(strategyId);
    final stats = await _computeStatsForRows(strategyId, reviewData.records);
    final items = <ChecklistItem>[];

    // 1. Hit rate > 50%?
    final hitRatePct = stats.hitRate * 100;
    items.add(
      ChecklistItem(
        title: '近30日命中率是否 > 50%',
        result: stats.evaluatedCount == 0
            ? CheckResult.warning
            : (hitRatePct > 50 ? CheckResult.pass : CheckResult.fail),
        detail: stats.evaluatedCount == 0
            ? '${reviewData.period.sourceNote}，无评估数据'
            : '命中率 ${hitRatePct.toStringAsFixed(1)}%，样本 ${stats.evaluatedCount} 条',
      ),
    );

    // 2. Average change positive?
    items.add(
      ChecklistItem(
        title: '近30日平均差是否为正',
        result: stats.evaluatedCount == 0
            ? CheckResult.warning
            : (stats.avgChange > 0 ? CheckResult.pass : CheckResult.fail),
        detail: stats.evaluatedCount == 0
            ? '${reviewData.period.sourceNote}，无评估数据'
            : '平均差 ${stats.avgChangeDisplay}',
      ),
    );

    // 3. Max loss > -10%?
    items.add(
      ChecklistItem(
        title: '极限跌幅是否超过 -10%',
        result: stats.maxLoss == null
            ? CheckResult.warning
            : (stats.maxLoss! > -10 ? CheckResult.pass : CheckResult.fail),
        detail: stats.maxLoss == null
            ? '${reviewData.period.sourceNote}，无评估数据'
            : '极限跌幅 ${stats.maxLoss!.toStringAsFixed(1)}%',
      ),
    );

    // 4. Hit rate trend
    items.add(
      ChecklistItem(
        title: '命中率趋势',
        result: CheckResult.pass,
        detail: stats.evaluatedCount < 10
            ? '数据不足，无法判断趋势'
            : '近期命中率 ${hitRatePct.toStringAsFixed(1)}%',
      ),
    );

    // 5. Recommendation frequency reasonable?
    final avgDaily = stats.tradingDaysRun > 0
        ? stats.totalRecommendations / stats.tradingDaysRun
        : 0.0;
    items.add(
      ChecklistItem(
        title: '推荐频率是否合理（日均 0-10 只）',
        result: avgDaily > 10
            ? CheckResult.warning
            : (avgDaily < 0.5 && stats.tradingDaysRun > 5
                  ? CheckResult.warning
                  : CheckResult.pass),
        detail: '日均推荐 ${avgDaily.toStringAsFixed(1)} 只',
      ),
    );

    return ReviewChecklistResult(items: items, period: reviewData.period);
  }

  /// Generate iteration suggestions based on strategy stats.
  List<StrategySuggestion> generateSuggestions(
    Strategy strategy,
    StrategyStats stats,
  ) {
    final suggestions = <StrategySuggestion>[];

    if (stats.evaluatedCount == 0) return suggestions;

    // Hit rate < 50%: suggest raising threshold
    if (stats.hitRate < 0.5) {
      suggestions.add(
        StrategySuggestion(
          condition: '命中率 ${(stats.hitRate * 100).toStringAsFixed(1)}% < 50%',
          suggestion:
              '推荐阈值偏低，建议将推荐阈值从 ${strategy.recommendThreshold} 提高到 ${strategy.recommendThreshold + 1}',
          parameterKey: 'recommendThreshold',
          suggestedValue: strategy.recommendThreshold + 1,
        ),
      );
    }

    // Average change negative: suggest checking MA weight
    if (stats.avgChange < 0) {
      suggestions.add(
        StrategySuggestion(
          condition: '平均差 ${stats.avgChangeDisplay} 为负',
          suggestion: '策略整体偏悲观，建议检查 MA 权重是否需要提高',
          parameterKey: 'weightMA',
          suggestedValue: null,
        ),
      );
    }

    // Max loss > 10%: suggest increasing Bollinger weight
    if (stats.maxLoss != null && stats.maxLoss! < -10) {
      suggestions.add(
        StrategySuggestion(
          condition: '极限跌幅 ${stats.maxLoss!.toStringAsFixed(1)}% 超过 -10%',
          suggestion: '策略选股波动过大，建议增加布林带权重以筛选更稳定的标的',
          parameterKey: 'weightBoll',
          suggestedValue: null,
        ),
      );
    }

    // Too many daily recommendations: suggest raising threshold
    if (stats.totalRecommendations > 0 && stats.tradingDaysRun > 0) {
      final avgDaily = stats.totalRecommendations / stats.tradingDaysRun;
      if (avgDaily > 10) {
        suggestions.add(
          StrategySuggestion(
            condition: '日均推荐 ${avgDaily.toStringAsFixed(1)} 只，推荐过多',
            suggestion: '推荐过多，建议提高推荐阈值',
            parameterKey: 'recommendThreshold',
            suggestedValue: strategy.recommendThreshold + 1,
          ),
        );
      }
    }

    return suggestions;
  }

  // ── Row Mappers ─────────────────────────────────────────────

  Strategy _rowToDomain(StrategyRow row, {StrategyStats? stats}) {
    // Parse entry/exit rules from JSON
    List<SignalRule>? entryRules;
    List<SignalRule>? exitRules;
    if (row.entryRulesJson != null) {
      try {
        final list = jsonDecode(row.entryRulesJson!) as List;
        entryRules = list
            .map((e) => SignalRule.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    if (row.exitRulesJson != null) {
      try {
        final list = jsonDecode(row.exitRulesJson!) as List;
        exitRules = list
            .map((e) => SignalRule.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Parse entry/exit rule groups from JSON
    List<RuleGroup>? entryGroups;
    List<RuleGroup>? exitGroups;
    if (row.entryGroupsJson != null) {
      try {
        final list = jsonDecode(row.entryGroupsJson!) as List;
        entryGroups = list
            .map((e) => RuleGroup.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    if (row.exitGroupsJson != null) {
      try {
        final list = jsonDecode(row.exitGroupsJson!) as List;
        exitGroups = list
            .map((e) => RuleGroup.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Parse stock filter from JSON
    StockFilter? stockFilter;
    if (row.stockFilterJson != null) {
      try {
        stockFilter = StockFilter.fromJson(
          jsonDecode(row.stockFilterJson!) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    return Strategy(
      id: row.id,
      name: row.name,
      description: row.description,
      maShortPeriod: row.maShortPeriod,
      maLongPeriod: row.maLongPeriod,
      bollPeriod: row.bollPeriod,
      bollStdDev: row.bollStdDev,
      weightMA: row.weightMA,
      weightBoll: row.weightBoll,
      weightVol: row.weightVol,
      weightTrend: row.weightTrend,
      recommendThreshold: row.recommendThreshold,
      entryRules: entryRules,
      exitRules: exitRules,
      entryGroups: entryGroups,
      exitGroups: exitGroups,
      stockFilter: stockFilter,
      isEnabled: row.isEnabled,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastReviewAt: row.lastReviewAt,
      stats: stats,
    );
  }

  StrategyHitRecord _hitRowToDomain(StrategyHitRecordRow row) {
    return StrategyHitRecord(
      id: row.id,
      strategyId: row.strategyId,
      stockCode: row.stockCode,
      stockName: row.stockName,
      recommendDate: row.recommendDate,
      recommendScore: row.recommendScore,
      recommendPrice: row.recommendPrice,
      actualChange5d: row.actualChange5d,
      isHit: row.isHit,
      createdAt: row.createdAt,
    );
  }

  StrategyReview _reviewRowToDomain(StrategyReviewRow row) {
    List<ChecklistItem> items = [];
    try {
      final decoded = jsonDecode(row.checklistResult) as List;
      items = decoded
          .map(
            (item) => ChecklistItem(
              title: item['title'] as String,
              result: CheckResult.values.firstWhere(
                (r) => r.name == item['result'],
                orElse: () => CheckResult.warning,
              ),
              detail: item['detail'] as String,
            ),
          )
          .toList();
    } catch (_) {
      // Fallback if JSON is malformed
    }

    return StrategyReview(
      id: row.id,
      strategyId: row.strategyId,
      reviewDate: row.reviewDate,
      healthScore: row.healthScore,
      hitRate30d: row.hitRate30d,
      avgChange30d: row.avgChange30d,
      maxLoss30d: row.maxLoss30d,
      hitRateTrend: row.hitRateTrend,
      avgDailyCount30d: row.avgDailyCount30d,
      checklistItems: items,
      note: row.note,
      createdAt: row.createdAt,
    );
  }

  // ── Isolate Helpers ──────────────────────────────────────────

  /// Run batch stats computation in a background Isolate.
  Future<List<StrategyStats>> _runBatchStatsInIsolate(
    List<List<dynamic>> inputs,
  ) async {
    return runInBackground(() => computeAllStatsPure(inputs));
  }
}

class _ReviewRecordSelection {
  final List<StrategyHitRecordRow> records;
  final ReviewPeriodInfo period;

  const _ReviewRecordSelection({required this.records, required this.period});
}

// ── Isolate Entry Points (top-level for Isolate.run) ─────────────

/// Pure stats computation for a single strategy.
/// No DB/HTTP access — only serializable input → StrategyStats output.
StrategyStats computeStatsPure(
  List<double?> actualChanges,
  List<bool?> isHitFlags,
  int totalRecords,
  int tradingDaysRun,
) {
  final evaluatedChanges = <double>[];
  int hitCount = 0;
  for (int i = 0; i < actualChanges.length; i++) {
    final change = actualChanges[i];
    if (change != null) {
      evaluatedChanges.add(change);
      if (isHitFlags[i] == true) hitCount++;
    }
  }

  double? maxGain;
  double? maxLoss;
  double avgChange = 0.0;
  double healthScore = 0.0;

  if (evaluatedChanges.isNotEmpty) {
    maxGain = evaluatedChanges.reduce((a, b) => a > b ? a : b);
    maxLoss = evaluatedChanges.reduce((a, b) => a < b ? a : b);
    avgChange =
        evaluatedChanges.reduce((a, b) => a + b) / evaluatedChanges.length;

    final hitRate = hitCount / evaluatedChanges.length;

    // Health score = hit_rate_score*0.5 + avg_change_score*0.3 + stability_score*0.2
    final hitRateScore = (hitRate * 10).clamp(0.0, 10.0);
    final avgChangeScore = ((avgChange + 10) / 2).clamp(0.0, 10.0);
    // Stability: lower standard deviation = higher score
    final mean = avgChange;
    final variance =
        evaluatedChanges
            .map((c) => (c - mean) * (c - mean))
            .reduce((a, b) => a + b) /
        evaluatedChanges.length;
    final stdDev = sqrt(variance);
    final stabilityScore = (10 - stdDev).clamp(0.0, 10.0);

    healthScore =
        hitRateScore * 0.5 + avgChangeScore * 0.3 + stabilityScore * 0.2;
  }

  return StrategyStats(
    hitRate: evaluatedChanges.isEmpty
        ? 0.0
        : hitCount / evaluatedChanges.length,
    maxGain: maxGain,
    maxLoss: maxLoss,
    avgChange: avgChange,
    totalRecommendations: totalRecords,
    hitCount: hitCount,
    evaluatedCount: evaluatedChanges.length,
    healthScore: healthScore,
    tradingDaysRun: tradingDaysRun,
  );
}

/// Pure batch stats computation for multiple strategies.
/// Input: list of [actualChanges, isHitFlags, totalRecords, tradingDaysRun].
List<StrategyStats> computeAllStatsPure(List<List<dynamic>> inputs) {
  return inputs.map((input) {
    final actualChanges = (input[0] as List).cast<double?>();
    final isHitFlags = (input[1] as List).cast<bool?>();
    final totalRecords = input[2] as int;
    final tradingDaysRun = input[3] as int;
    return computeStatsPure(
      actualChanges,
      isHitFlags,
      totalRecords,
      tradingDaysRun,
    );
  }).toList();
}
