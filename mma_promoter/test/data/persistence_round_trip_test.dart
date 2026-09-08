import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/repositories/fighter_pack_repository.dart';
import 'package:mma_promoter/data/repositories/fighter_repository.dart';
import 'package:mma_promoter/data/repositories/organization_repository.dart';
import 'package:mma_promoter/data/repositories/save_scope.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/packs/fighter_pack.dart';

/// Saves are load-bearing on every platform now, so the schema and the
/// mappers have to agree. These go through a real SQLite database rather
/// than the in-memory repositories the other tests use — an added model
/// field that never made it into `tables.dart` or `mappers.dart` shows up
/// here as a value that doesn't survive the round trip.
void main() {
  late AppDatabase db;
  late SaveScope scope;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    scope = SaveScope('save-under-test');
  });
  tearDown(() => db.close());

  test('the schema builds from scratch and stores an organization', () async {
    final repo = OrganizationRepository(db, scope);
    expect(await repo.get(), isNull);

    final org = generateStartingOrganization(
      name: 'Apex FC',
      tier: ReputationTier.regional,
    );
    await repo.save(org);
    // An organization *is* a save, so opening it means pointing the scope
    // at its id — the same thing GameController does on load.
    scope.saveId = org.id;

    final loaded = await repo.get();
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Apex FC');
    expect(loaded.cashBalance, org.cashBalance);
    expect(loaded.currentWeek, org.currentWeek);
  });

  test('a generated fighter survives a save/load round trip intact',
      () async {
    final repo = FighterRepository(db, scope);
    final original = generateStartingRoster(fightersPerWeightClass: 1).first;

    await repo.save(original);
    final loaded = (await repo.getAll()).single;

    expect(loaded.id, original.id);
    expect(loaded.name, original.name);
    expect(loaded.nationality, original.nationality);
    expect(loaded.headshotAsset, original.headshotAsset);
    expect(loaded.weightClass, original.weightClass);
    expect(loaded.style, original.style);
    expect(loaded.age, original.age);
    expect(loaded.record.wins, original.record.wins);
    expect(loaded.record.losses, original.record.losses);
    expect(loaded.potential, original.potential);
    expect(loaded.popularity, original.popularity);
    expect(loaded.reachInches, original.reachInches);
    // The stat blocks are where a forgotten column hides most easily.
    expect(loaded.overall, closeTo(original.overall, 0.001));
    expect(loaded.fightingStats.average,
        closeTo(original.fightingStats.average, 0.001));
    expect(loaded.physicalStats.average,
        closeTo(original.physicalStats.average, 0.001));
    expect(loaded.mentalStats.average,
        closeTo(original.mentalStats.average, 0.001));
  });

  test('a whole starting roster persists and reads back', () async {
    final repo = FighterRepository(db, scope);
    final roster = generateStartingRoster(fightersPerWeightClass: 3);

    for (final fighter in roster) {
      await repo.save(fighter);
    }

    final loaded = await repo.getAll();
    expect(loaded, hasLength(roster.length));
    expect(loaded.where((f) => f.headshotAsset == null), isEmpty);
  });

  test('a fighter pack survives a real database round trip', () async {
    // Packs are the one table with no save scope, and their fighters go
    // in as a JSON blob rather than as columns — so this is the only
    // place the pack storage path is exercised against real SQLite.
    final repo = FighterPackRepository(db);
    expect(await repo.getAll(), isEmpty);

    final roster = generateStartingRoster(random: Random(17)).take(4).toList();
    final pack = FighterPack(
      id: 'pack-1',
      name: 'The Originals',
      description: 'Built by hand.',
      author: 'Max',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      fighters: roster,
    );
    await repo.save(pack);

    final loaded = (await repo.getAll()).single;
    expect(loaded.id, 'pack-1');
    expect(loaded.name, 'The Originals');
    expect(loaded.description, 'Built by hand.');
    expect(loaded.author, 'Max');
    expect(loaded.createdAt.millisecondsSinceEpoch, 1700000000000);
    expect(loaded.fighters, hasLength(4));
    for (var i = 0; i < roster.length; i++) {
      expect(loaded.fighters[i].name, roster[i].name);
      expect(loaded.fighters[i].weightClass, roster[i].weightClass);
      expect(loaded.fighters[i].overall, closeTo(roster[i].overall, 0.001));
    }

    await repo.delete('pack-1');
    expect(await repo.getAll(), isEmpty);
  });

  test('packs are visible from every save', () async {
    // The scope is deliberately not applied to packs; this is what that
    // buys, so it is worth a test rather than a comment.
    final repo = FighterPackRepository(db);
    await repo.save(FighterPack(
      id: 'p',
      name: 'Shared',
      createdAt: DateTime(2026),
      fighters: [generateStartingRoster(random: Random(2)).first],
    ));

    // A repository built for a different save reads the same packs.
    expect(await FighterPackRepository(db).getAll(), hasLength(1));
  });
}
