import 'package:drift/drift.dart';

/// Drift table definition for strategies.
@DataClassName('StrategyRow')
class Strategies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  TextColumn get description =>
      text().withLength(max: 100).withDefault(const Constant(''))();

  // Analysis parameters
  IntColumn get maShortPeriod => integer().withDefault(const Constant(20))();
  IntColumn get maLongPeriod => integer().withDefault(const Constant(60))();
  IntColumn get bollPeriod => integer().withDefault(const Constant(20))();
  RealColumn get bollStdDev => real().withDefault(const Constant(2.0))();
  RealColumn get weightMA => real().withDefault(const Constant(0.30))();
  RealColumn get weightBoll => real().withDefault(const Constant(0.30))();
  RealColumn get weightVol => real().withDefault(const Constant(0.20))();
  RealColumn get weightTrend => real().withDefault(const Constant(0.20))();
  IntColumn get recommendThreshold =>
      integer().withDefault(const Constant(7))();

  // Signal rules (JSON)
  TextColumn get entryRulesJson => text().nullable()();
  TextColumn get exitRulesJson => text().nullable()();

  // Rule groups (JSON) — OR-of-ANDs condition groups
  TextColumn get entryGroupsJson => text().nullable()();
  TextColumn get exitGroupsJson => text().nullable()();

  // Stock filter (JSON) — strategy-specific candidate pool filter
  TextColumn get stockFilterJson => text().nullable()();

  // Status
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastReviewAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift table definition for strategy hit records.
/// Tracks each recommendation and its actual 5-day performance.
@DataClassName('StrategyHitRecordRow')
class StrategyHitRecords extends Table {
  TextColumn get id => text()();
  TextColumn get strategyId => text()();
  TextColumn get stockCode => text()();
  TextColumn get stockName => text()();
  TextColumn get recommendDate => text()(); // "2026-05-05" format
  IntColumn get recommendScore => integer()();
  RealColumn get recommendPrice => real()();
  RealColumn get actualChange5d => real().nullable()();
  BoolColumn get isHit => boolean().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift table definition for strategy reviews.
/// Stores periodic review checklists and health scores.
@DataClassName('StrategyReviewRow')
class StrategyReviews extends Table {
  TextColumn get id => text()();
  TextColumn get strategyId => text()();
  DateTimeColumn get reviewDate => dateTime()();
  RealColumn get healthScore => real()();

  // Check list metrics
  RealColumn get hitRate30d => real()();
  RealColumn get avgChange30d => real()();
  RealColumn get maxLoss30d => real().nullable()();
  TextColumn get hitRateTrend => text()(); // "up" / "flat" / "down"
  IntColumn get avgDailyCount30d => integer()();

  // Detailed check list results (JSON)
  TextColumn get checklistResult => text()();
  TextColumn get note => text().withLength(max: 200).nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A privacy-conscious source record attached to an imported strategy.
///
/// Raw screenshots are never persisted here. [sanitizedText] is optional and
/// is only stored when the user explicitly opts in during import.
@DataClassName('StrategySourceRow')
class StrategySources extends Table {
  TextColumn get id => text()();
  TextColumn get strategyId =>
      text().references(Strategies, #id, onDelete: KeyAction.cascade)();
  TextColumn get externalRef => text()();
  TextColumn get sourceType => text()();
  TextColumn get speaker => text().nullable()();
  DateTimeColumn get capturedAt => dateTime().nullable()();
  TextColumn get summary => text()();
  TextColumn get sanitizedText => text().nullable()();
  TextColumn get fingerprint => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {strategyId, fingerprint},
  ];
}

/// Immutable strategy configuration snapshots.
///
/// Lifecycle status may change in a later phase, but [strategySnapshotJson]
/// and the review metadata are never overwritten.
@DataClassName('StrategyVersionRow')
class StrategyVersions extends Table {
  TextColumn get id => text()();
  TextColumn get strategyId =>
      text().references(Strategies, #id, onDelete: KeyAction.cascade)();
  IntColumn get versionNumber => integer()();
  TextColumn get status => text()();
  TextColumn get strategyType => text()();
  TextColumn get strategySnapshotJson => text()();
  TextColumn get packageJson => text().nullable()();
  TextColumn get applicabilityJson => text()();
  TextColumn get riskNotesJson => text()();
  TextColumn get pendingQuestionsJson => text()();
  TextColumn get compatibilityIssuesJson => text()();
  TextColumn get previousVersionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {strategyId, versionNumber},
  ];
}

/// Links one immutable version to its source records and normalized rule IDs.
@DataClassName('StrategyVersionSourceRow')
class StrategyVersionSources extends Table {
  TextColumn get versionId =>
      text().references(StrategyVersions, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceId =>
      text().references(StrategySources, #id, onDelete: KeyAction.cascade)();
  TextColumn get ruleIdsJson => text()();

  @override
  Set<Column> get primaryKey => {versionId, sourceId};
}

/// Immutable version-bound backtest reports.
///
/// The result JSON contains calculated metrics and completed trades. Explicit
/// metadata columns allow history queries without mutating old reports when a
/// strategy or a default parameter changes later.
@DataClassName('StrategyBacktestRunRow')
class StrategyBacktestRuns extends Table {
  TextColumn get id => text()();
  TextColumn get strategyId =>
      text().references(Strategies, #id, onDelete: KeyAction.cascade)();
  TextColumn get strategyVersionId =>
      text().references(StrategyVersions, #id, onDelete: KeyAction.cascade)();
  IntColumn get strategyVersionNumber => integer()();
  TextColumn get stockCode => text()();
  TextColumn get stockName => text()();
  TextColumn get market => text()();
  TextColumn get configJson => text()();
  TextColumn get resultJson => text()();
  TextColumn get adjustmentMode => text()();
  TextColumn get dataFingerprint => text()();
  DateTimeColumn get dataStart => dateTime().nullable()();
  DateTimeColumn get dataEnd => dateTime().nullable()();
  DateTimeColumn get dataAsOf => dateTime()();
  IntColumn get barsProcessed => integer()();
  IntColumn get sampleCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
