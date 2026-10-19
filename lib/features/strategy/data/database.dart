import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/database/database_connection.dart';
import '../../watchlist/data/tables.dart';
import 'tables.dart';

export '../../watchlist/data/tables.dart' show WatchlistItems;
export 'tables.dart'
    show
        Strategies,
        StrategyHitRecords,
        StrategyReviews,
        StrategySources,
        StrategyVersions,
        StrategyVersionSources,
        StrategyBacktestRuns;

part 'database.g.dart';

/// Drift database for StockPilot local storage.
/// Schema v6 adds immutable, strategy-version-bound backtest reports.
@DriftDatabase(
  tables: [
    WatchlistItems,
    Strategies,
    StrategyHitRecords,
    StrategyReviews,
    StrategySources,
    StrategyVersions,
    StrategyVersionSources,
    StrategyBacktestRuns,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection('stockpilot'));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // v1 -> v2: add strategy tables
        await m.createTable(strategies);
        await m.createTable(strategyHitRecords);
        await m.createTable(strategyReviews);
        await _createIndexes(includeKnowledge: false, includeBacktests: false);
        await _ensureDefaultStrategy();
      }
      if (from >= 2 && from < 3) {
        // v2 -> v3: add signal rules JSON columns to strategies
        await customStatement(
          'ALTER TABLE strategies ADD COLUMN entry_rules_json TEXT',
        );
        await customStatement(
          'ALTER TABLE strategies ADD COLUMN exit_rules_json TEXT',
        );
      }
      if (from >= 3 && from < 4) {
        // v3 -> v4: add rule groups JSON columns
        await customStatement(
          'ALTER TABLE strategies ADD COLUMN entry_groups_json TEXT',
        );
        await customStatement(
          'ALTER TABLE strategies ADD COLUMN exit_groups_json TEXT',
        );
      }
      if (from < 5) {
        await _addStrategyColumnIfMissing(
          'stock_filter_json',
          'ALTER TABLE strategies ADD COLUMN stock_filter_json TEXT',
        );
        // v4 -> v5: add source provenance and immutable version snapshots.
        await m.createTable(strategySources);
        await m.createTable(strategyVersions);
        await m.createTable(strategyVersionSources);
        await _createIndexes(includeBacktests: false);
      }
      if (from < 6) {
        await m.createTable(strategyBacktestRuns);
        await _createIndexes();
      }
    },
  );

  Future<void> _addStrategyColumnIfMissing(
    String columnName,
    String statement,
  ) async {
    final columns = await customSelect('PRAGMA table_info(strategies)').get();
    final exists = columns.any((row) => row.read<String>('name') == columnName);
    if (!exists) await customStatement(statement);
  }

  /// Create database indexes for performance.
  Future<void> _createIndexes({
    bool includeKnowledge = true,
    bool includeBacktests = true,
  }) async {
    // Watchlist index
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_watchlist_stock_code ON watchlist_items (stock_code);',
    );
    // Strategy hit records indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_hit_record_strategy_date ON strategy_hit_records (strategy_id, recommend_date);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_hit_record_strategy_unfilled ON strategy_hit_records (strategy_id) WHERE is_hit IS NULL;',
    );
    // Strategy reviews index
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_review_strategy_date ON strategy_reviews (strategy_id, review_date);',
    );
    if (includeKnowledge) {
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_strategy_source_strategy ON strategy_sources (strategy_id, created_at);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_strategy_version_strategy ON strategy_versions (strategy_id, version_number DESC);',
      );
      if (includeBacktests) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_backtest_strategy_stock_date ON strategy_backtest_runs (strategy_id, stock_code, created_at DESC);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_backtest_version ON strategy_backtest_runs (strategy_version_id, created_at DESC);',
        );
      }
    }
  }

  /// Ensure a default strategy exists (auto-created for v1 -> v2 migration).
  Future<void> _ensureDefaultStrategy() async {
    final existing = await select(strategies).get();
    final hasDefault = existing.any((s) => s.isDefault);
    if (!hasDefault) {
      await _insertDefaultStrategy();
    }
  }

  Future<void> _insertDefaultStrategy() async {
    final now = DateTime.now();
    await into(strategies).insert(
      StrategiesCompanion.insert(
        id: const Uuid().v4(),
        name: '默认波段策略',
        description: const Value('MA20/60 + 布林带 + 量比 + 趋势评分'),
        maShortPeriod: const Value(20),
        maLongPeriod: const Value(60),
        bollPeriod: const Value(20),
        bollStdDev: const Value(2.0),
        weightMA: const Value(0.30),
        weightBoll: const Value(0.30),
        weightVol: const Value(0.20),
        weightTrend: const Value(0.20),
        recommendThreshold: const Value(7),
        isEnabled: const Value(true),
        isDefault: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Initialize default strategy if none exists (for fresh installs).
  Future<void> ensureDefaultStrategy() async {
    await _ensureDefaultStrategy();
  }
}
