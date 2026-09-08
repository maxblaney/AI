import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// A migration that fails partway leaves a database stamped with the new
/// version but missing what the step was adding. `onUpgrade` then never
/// runs again — the version says there is nothing to do — and every read
/// of that table dies on a null the generated mapper is entitled to
/// assume cannot happen.
///
/// This shipped. It reached a player as:
///
///     Couldn't open your save
///     Null check operator used on a null value
///
/// with no way back, because the thing that would repair the save was the
/// thing that wouldn't run.
void main() {
  sql.Database organizationsMissing(String column) {
    final raw = sql.sqlite3.openInMemory();
    raw.execute('PRAGMA user_version = 12');
    final columns = {
      'id': "TEXT NOT NULL PRIMARY KEY",
      'name': "TEXT NOT NULL DEFAULT 'X'",
      'reputation_tier': "TEXT NOT NULL DEFAULT 'regional'",
      'reputation_points': 'INTEGER NOT NULL DEFAULT 0',
      'cash_balance': 'INTEGER NOT NULL DEFAULT 0',
      'fanbase_size': 'INTEGER NOT NULL DEFAULT 0',
      'home_region': "TEXT NOT NULL DEFAULT 'X'",
      'promotion_budget': 'INTEGER NOT NULL DEFAULT 0',
      'last_talent_refresh_week': 'INTEGER NOT NULL DEFAULT 1',
      'last_aged_week': 'INTEGER NOT NULL DEFAULT 1',
      'current_week': 'INTEGER NOT NULL DEFAULT 1',
      'auto_resign_fighters': 'INTEGER NOT NULL DEFAULT 1',
      'last_played_at_ms': 'INTEGER',
    }..remove(column);
    raw.execute('CREATE TABLE organizations ('
        '${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})');
    raw.execute("INSERT INTO organizations (id) VALUES ('save')");
    return raw;
  }

  test('a column missing behind an up-to-date version stamp is added back',
      () async {
    final raw = organizationsMissing('last_aged_week');
    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));

    // Before the reconciliation existed this threw
    // "Null check operator used on a null value": the generated mapper
    // reads the row as a map, and a column that isn't there reads null.
    final saves = await db.listSaves();
    expect(saves, hasLength(1));
    expect(saves.single.lastAgedWeek, 1,
        reason: 'the healed column should carry its declared default');

    await db.close();
  });

  test('it repairs whichever column is missing, not one named in advance',
      () async {
    for (final column in ['auto_resign_fighters', 'current_week']) {
      final raw = organizationsMissing(column);
      final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
      expect(await db.listSaves(), hasLength(1),
          reason: 'a save missing $column should still open');
      await db.close();
    }
  });

  test('a missing table is created rather than crashing the open', () async {
    final raw = organizationsMissing('nothing-is-missing');
    // Fighter packs live outside any save and arrived late, so a
    // database that never saw that migration has no such table.
    raw.execute('DROP TABLE IF EXISTS fighter_packs');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    expect(await db.getAllFighterPacks(), isEmpty);

    await db.close();
  });

  test('a healthy database gains nothing it did not declare', () async {
    final raw = sql.sqlite3.openInMemory();
    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    await db.customSelect('SELECT 1').get();

    // Reconciliation runs on every open, so it has to be a no-op on a
    // database that is already right — no duplicate columns, nothing
    // invented.
    for (final table in db.allTables) {
      final info = raw.select('PRAGMA table_info(${table.actualTableName})');
      final present = info.map((r) => r['name'] as String).toList();
      expect(present.toSet(), hasLength(present.length),
          reason: '${table.actualTableName} should have no duplicate columns');
      expect(
        present.toSet(),
        table.$columns.map((c) => c.name).toSet(),
        reason: '${table.actualTableName} should match its declaration',
      );
    }

    await db.close();
  });
}
