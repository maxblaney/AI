import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/repositories/fighter_repository.dart';
import 'package:mma_promoter/data/repositories/organization_repository.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/data/models/models.dart';

/// Saves are load-bearing on every platform now, so the schema and the
/// mappers have to agree. These go through a real SQLite database rather
/// than the in-memory repositories the other tests use — an added model
/// field that never made it into `tables.dart` or `mappers.dart` shows up
/// here as a value that doesn't survive the round trip.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('the schema builds from scratch and stores an organization', () async {
    final repo = OrganizationRepository(db);
    expect(await repo.get(), isNull);

    final org = generateStartingOrganization(
      name: 'Apex FC',
      tier: ReputationTier.regional,
    );
    await repo.save(org);

    final loaded = await repo.get();
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Apex FC');
    expect(loaded.cashBalance, org.cashBalance);
    expect(loaded.currentWeek, org.currentWeek);
  });

  test('a generated fighter survives a save/load round trip intact',
      () async {
    final repo = FighterRepository(db);
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
    final repo = FighterRepository(db);
    final roster = generateStartingRoster(fightersPerWeightClass: 3);

    for (final fighter in roster) {
      await repo.save(fighter);
    }

    final loaded = await repo.getAll();
    expect(loaded, hasLength(roster.length));
    expect(loaded.where((f) => f.headshotAsset == null), isEmpty);
  });
}
