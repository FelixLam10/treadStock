import 'package:drift/drift.dart';
import '../../../shared/database/database_connection.dart';
import 'tables.dart';

part 'database.g.dart';

/// Drift database for StockPilot local storage.
@DriftDatabase(tables: [WatchlistItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection('watchlist'));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Create index on stockCode for faster lookups.
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_watchlist_stock_code ON watchlist_items (stock_code);',
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Additive migrations only — never drop columns, so existing
      // watchlist data is preserved across upgrades.
      if (from < 2) {
        // v2: alert price threshold + per-day de-dup marker.
        await m.addColumn(watchlistItems, watchlistItems.alertPriceThreshold);
        await m.addColumn(watchlistItems, watchlistItems.alertTriggeredDate);
      }
    },
  );
}
