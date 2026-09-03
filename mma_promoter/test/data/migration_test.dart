import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/repositories/organization_repository.dart';
import 'package:mma_promoter/data/repositories/save_scope.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// Old databases exist in the wild — anyone already playing has one. The
/// upgrade path adds save scoping (v2), persisted box scores plus
/// championship flags (v3), condition (v4), per-division belts (v5) and
/// Light Heavyweight's corrected 205 lb limit (v6).
/// Two risks are worth testing: that an in-progress v1 game ends up
/// tagged with no save and becomes invisible behind a saves list that
/// can't see it, and that a champion crowned before v5 keeps their belt
/// once belts became a set.
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
    // weight_class has always been on fighters, and the v5 step reads it
    // to work out which belt a pre-v5 champion held.
    raw.execute('CREATE TABLE fighters (id TEXT NOT NULL PRIMARY KEY, '
        "weight_class TEXT NOT NULL DEFAULT 'lightweight', "
        'weight_lbs INTEGER NOT NULL DEFAULT 155)');
    for (final table in [
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
    raw.execute("INSERT INTO fighters (id, weight_class) VALUES "
        "('legacy-fighter', 'welterweight')");

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

  test('a champion crowned before v5 keeps the belt for their division',
      () async {
    final raw = sql.sqlite3.openInMemory();
    raw.execute('PRAGMA user_version = 4');
    // Only what the v5 step touches: it ALTERs both tables and reads the
    // two old championship flags off fighters.
    raw.execute('''
      CREATE TABLE fighters (
        id TEXT NOT NULL PRIMARY KEY,
        weight_class TEXT NOT NULL,
        weight_lbs INTEGER NOT NULL DEFAULT 155,
        is_champion INTEGER NOT NULL DEFAULT 0,
        is_interim_champion INTEGER NOT NULL DEFAULT 0
      )''');
    raw.execute('CREATE TABLE fights (id TEXT NOT NULL PRIMARY KEY)');
    // v7 adds a column to organizations and v9 one to events, so both
    // tables have to exist even though this fixture is about fighters.
    raw.execute('CREATE TABLE organizations (id TEXT NOT NULL PRIMARY KEY)');
    raw.execute('CREATE TABLE events (id TEXT NOT NULL PRIMARY KEY)');

    raw.execute(
        "INSERT INTO fighters VALUES ('champ', 'lightweight', 155, 1, 0)");
    raw.execute(
        "INSERT INTO fighters VALUES ('interim', 'heavyweight', 250, 0, 1)");
    raw.execute(
        "INSERT INTO fighters VALUES ('nobody', 'flyweight', 125, 0, 0)");

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    // Any query forces the migration to run.
    await db.customSelect('SELECT 1').get();

    String beltsOf(String id) => raw
        .select('SELECT belts_json FROM fighters WHERE id = ?', [id])
        .single['belts_json'] as String;
    String interimOf(String id) => raw
        .select('SELECT interim_belts_json FROM fighters WHERE id = ?', [id])
        .single['interim_belts_json'] as String;

    expect(beltsOf('champ'), '["lightweight"]');
    expect(interimOf('champ'), '[]');
    expect(beltsOf('interim'), '[]',
        reason: 'an interim belt is not an undisputed one');
    expect(interimOf('interim'), '["heavyweight"]');
    expect(beltsOf('nobody'), '[]');

    await db.close();
  });

  test('light heavyweights from before v6 are moved onto the 205 limit',
      () async {
    final raw = sql.sqlite3.openInMemory();
    raw.execute('PRAGMA user_version = 5');
    // Only what the v6 step touches: it rewrites weight_lbs for one
    // division and nothing else.
    raw.execute('''
      CREATE TABLE fighters (
        id TEXT NOT NULL PRIMARY KEY,
        weight_class TEXT NOT NULL,
        weight_lbs INTEGER NOT NULL
      )''');

    // A light heavyweight generated under the old 200 lb limit walked
    // around at 206; the same fighter generated today would be 211.
    // v7 adds a column to organizations and v9 one to events.
    raw.execute('CREATE TABLE organizations (id TEXT NOT NULL PRIMARY KEY)');
    raw.execute('CREATE TABLE events (id TEXT NOT NULL PRIMARY KEY)');

    raw.execute("INSERT INTO fighters VALUES ('lhw', 'lightHeavyweight', 206)");
    raw.execute("INSERT INTO fighters VALUES ('mw', 'middleweight', 189)");
    raw.execute("INSERT INTO fighters VALUES ('hw', 'heavyweight', 250)");

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    await db.customSelect('SELECT 1').get();

    int weightOf(String id) => raw
        .select('SELECT weight_lbs FROM fighters WHERE id = ?', [id])
        .single['weight_lbs'] as int;

    expect(weightOf('lhw'), 211,
        reason: 'the division moved with its limit, keeping how far over '
            'the fighter was');
    expect(weightOf('mw'), 189, reason: 'no other division changed');
    expect(weightOf('hw'), 250);

    await db.close();
  });

  test('an upgraded database gets the fighter packs table', () async {
    final raw = sql.sqlite3.openInMemory();
    raw.execute('PRAGMA user_version = 7');
    raw.execute('CREATE TABLE fighters (id TEXT NOT NULL PRIMARY KEY, '
        "weight_class TEXT NOT NULL DEFAULT 'lightweight', "
        'weight_lbs INTEGER NOT NULL DEFAULT 155)');
    raw.execute('CREATE TABLE organizations (id TEXT NOT NULL PRIMARY KEY)');
    raw.execute('CREATE TABLE events (id TEXT NOT NULL PRIMARY KEY)');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    // Packs live outside any save, so an existing game gaining the
    // feature means gaining an empty table, not migrating any data.
    expect(await db.getAllFighterPacks(), isEmpty);

    await db.close();
  });
}
