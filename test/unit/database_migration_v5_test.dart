import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/strategy/data/database.dart';

void main() {
  test('T-F015-3: schema v4 可连续升级到 v6', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE watchlist_items (stock_code TEXT NOT NULL)',
        );
        database.execute('CREATE TABLE strategies (id TEXT PRIMARY KEY)');
        database.execute(
          'CREATE TABLE strategy_hit_records '
          '(strategy_id TEXT NOT NULL, recommend_date TEXT NOT NULL, is_hit INTEGER)',
        );
        database.execute(
          'CREATE TABLE strategy_reviews '
          '(strategy_id TEXT NOT NULL, review_date INTEGER NOT NULL)',
        );
        database.execute('PRAGMA user_version = 4');
      },
    );
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name IN "
          "('strategy_sources', 'strategy_versions', 'strategy_version_sources', 'strategy_backtest_runs') "
          'ORDER BY name',
        )
        .get();

    expect(rows.map((row) => row.read<String>('name')), [
      'strategy_backtest_runs',
      'strategy_sources',
      'strategy_version_sources',
      'strategy_versions',
    ]);
  });

  test('T-F015-3: schema v1 可连续升级到 v6', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE watchlist_items (stock_code TEXT NOT NULL)',
        );
        database.execute('PRAGMA user_version = 1');
      },
    );
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    final versions = await db.customSelect('PRAGMA user_version').getSingle();
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name IN ('strategies', 'strategy_backtest_runs', 'strategy_sources', 'strategy_versions') "
          'ORDER BY name',
        )
        .get();

    expect(versions.read<int>('user_version'), 6);
    expect(tables.map((row) => row.read<String>('name')), [
      'strategies',
      'strategy_backtest_runs',
      'strategy_sources',
      'strategy_versions',
    ]);
  });

  test('T-F011-1: schema v5 升级会创建版本化回测表', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE watchlist_items (stock_code TEXT NOT NULL)',
        );
        database.execute('CREATE TABLE strategies (id TEXT PRIMARY KEY)');
        database.execute(
          'CREATE TABLE strategy_hit_records '
          '(strategy_id TEXT NOT NULL, recommend_date TEXT NOT NULL, is_hit INTEGER)',
        );
        database.execute(
          'CREATE TABLE strategy_reviews '
          '(strategy_id TEXT NOT NULL, review_date INTEGER NOT NULL)',
        );
        database.execute(
          'CREATE TABLE strategy_versions '
          '(id TEXT PRIMARY KEY, strategy_id TEXT NOT NULL, version_number INTEGER NOT NULL)',
        );
        database.execute(
          'CREATE TABLE strategy_sources '
          '(strategy_id TEXT NOT NULL, created_at INTEGER NOT NULL)',
        );
        database.execute('PRAGMA user_version = 5');
      },
    );
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    final table = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'strategy_backtest_runs'",
        )
        .getSingle();

    expect(table.read<String>('name'), 'strategy_backtest_runs');
  });
}
