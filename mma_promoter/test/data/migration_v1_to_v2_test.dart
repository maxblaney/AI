import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/repositories/organization_repository.dart';
import 'package:mma_promoter/data/repositories/save_scope.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// v1 databases exist in the wild — anyone already playing has one. The
/// upgrade path since then adds save scoping (v2) and persisted box
/// scores plus championship flags (v3). The risk worth testing is that an
/// in-progress game ends up tagged with no save and becomes invisible
/// behind a saves list that can't see it.
///
/// The old schema is built with a raw sqlite3 handle rather than through
/// drift, because opening an [AppDatabase] runs the migration and creates
/// v2 tables before any setup could happen. Only the columns the
/// migration actually touches are recreated: organizations in full (the
/// migration reads whole rows from it) and the scoped tables minimally,
/// since all it does to those is ALTER and UPDATE them.
void main() {
  test('a v1 save and its fighters survive upgrading to the current schema',
      () async {
    final raw = sql.sqlite3.openInMemory();

    raw.execute('PRAGMA user_version = 1');
    raw.execute('''
      CREATE TABLE organizations (
        id TEXT NOT NULL,
        name TEXT NOT NULL,
        reputation_tier TEXT NOT NULL DEFAULT 'regional',
        reputation_points INTEGER NOT NULL DEFAULT 0,
        cash_balance INTEGER NOT NULL,
        fanbase_size INTEGER NOT NULL DEFAULT 0,
        home_region TEXT NOT NULL,
        promotion_budget INTEGER NOT NULL DEFAULT 0,
        last_talent_refresh_week INTEGER NOT NULL DEFAULT 1,
        current_week INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (id)
      )''');
    for (final table in [
      'fighters',
      'events',
      'random_events',
      'inbox_items',
      // Not save-scoped, but v3 adds box-score columns to it.
      'fights',
    ]) {
      raw.execute('CREATE TABLE $table (id TEXT NOT NULL PRIMARY KEY)');
    }
    // Not scoped by the migration, but the saves list joins it to count
    // signed fighters, and a real v1 database has it.
    raw.execute(
      'CREATE TABLE contracts (id TEXT NOT NULL PRIMARY KEY, '
      'fighter_id TEXT NOT NULL)',
    );

    raw.execute(
      "INSERT INTO organizations (id, name, cash_balance, home_region, "
      "current_week) VALUES ('legacy-save', 'Legacy FC', 250000, "
      "'Midwest, USA', 17)",
    );
    raw.execute("INSERT INTO fighters (id) VALUES ('legacy-fighter')");

    // Opening with the current code runs onUpgrade against that v1 database.
    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    final scope = SaveScope();
    final saves = OrganizationRepository(db, scope);

    final list = await saves.listAll();
    expect(list, hasLength(1), reason: 'the v1 save should still be there');
    expect(list.single.organization.name, 'Legacy FC');
    expect(list.single.organization.currentWeek, 17,
        reason: 'game progress should be untouched by the upgrade');

    // The whole point: the orphaned rows were adopted into the save
    // rather than left with an empty saveId that nothing can find.
    final adopted = raw.select('SELECT save_id FROM fighters');
    expect(adopted.single['save_id'], 'legacy-save');

    // And it opens like any other save.
    scope.saveId = list.single.organization.id;
    final org = await saves.get();
    expect(org?.cashBalance, 250000);

    await db.close();
  });
}
