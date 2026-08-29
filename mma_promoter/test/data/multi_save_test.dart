import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/repositories/fighter_repository.dart';
import 'package:mma_promoter/data/repositories/organization_repository.dart';
import 'package:mma_promoter/data/repositories/save_scope.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// Save isolation is enforced in SQL, so these run against a real
/// database rather than the in-memory repositories — the bug worth
/// catching is one save's rows showing up in another, which only the
/// actual queries can prove.
void main() {
  late AppDatabase db;
  late SaveScope scope;
  late FighterRepository fighters;
  late OrganizationRepository saves;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    scope = SaveScope();
    fighters = FighterRepository(db, scope);
    saves = OrganizationRepository(db, scope);
  });
  tearDown(() => db.close());

  Future<Organization> seedSave(String name, int fightersPerClass) async {
    final org =
        generateStartingOrganization(name: name, tier: ReputationTier.regional);
    scope.saveId = org.id;
    await saves.save(org);
    await saves.touch(org.id, DateTime.now());
    for (final f
        in generateStartingRoster(fightersPerWeightClass: fightersPerClass)) {
      await fighters.save(f);
    }
    return org;
  }

  test('two saves keep entirely separate rosters', () async {
    final a = await seedSave('Alpha FC', 1); // 8 fighters
    final b = await seedSave('Bravo MMA', 2); // 16 fighters

    scope.saveId = a.id;
    final rosterA = await fighters.getAll();
    scope.saveId = b.id;
    final rosterB = await fighters.getAll();

    expect(rosterA, hasLength(8));
    expect(rosterB, hasLength(16));

    final idsA = rosterA.map((f) => f.id).toSet();
    final idsB = rosterB.map((f) => f.id).toSet();
    expect(idsA.intersection(idsB), isEmpty,
        reason: 'no fighter should appear in both saves');
  });

  test('the organization read back is the scoped save, not just any', () async {
    final a = await seedSave('Alpha FC', 1);
    final b = await seedSave('Bravo MMA', 1);

    scope.saveId = a.id;
    expect((await saves.get())!.name, 'Alpha FC');
    scope.saveId = b.id;
    expect((await saves.get())!.name, 'Bravo MMA');
  });

  test('listing saves returns both, most recently played first', () async {
    final a = await seedSave('Alpha FC', 1);
    await saves.touch(a.id, DateTime.now().subtract(const Duration(days: 2)));
    final b = await seedSave('Bravo MMA', 1);
    await saves.touch(b.id, DateTime.now());

    final list = await saves.listAll();
    expect(list.map((s) => s.organization.name), ['Bravo MMA', 'Alpha FC']);
    expect(list.first.talentPoolSize, 8);
  });

  test('deleting a save removes only its own data', () async {
    final a = await seedSave('Alpha FC', 1);
    final b = await seedSave('Bravo MMA', 1);

    await saves.delete(a.id);

    final remaining = await saves.listAll();
    expect(remaining.map((s) => s.organization.name), ['Bravo MMA']);

    scope.saveId = a.id;
    expect(await fighters.getAll(), isEmpty);
    scope.saveId = b.id;
    expect(await fighters.getAll(), hasLength(8));
  });

  test('with no save scoped, nothing leaks out of the database', () async {
    await seedSave('Alpha FC', 1);
    scope.saveId = null;
    expect(await fighters.getAll(), isEmpty);
    expect(await saves.get(), isNull);
  });

  /// Repository streams deliver asynchronously, so state that arrives via
  /// a subscription (the roster, the event list) isn't populated the
  /// instant an await returns. The UI just rebuilds when it lands; a test
  /// has to wait for it.
  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('GameController', () {
    test('starts on the saves screen when there are no saves', () async {
      final controller = GameController(database: db);
      await controller.init();
      expect(controller.needsNewGame, isTrue);
      expect(controller.activeSaveId, isNull);
      controller.dispose();
    });

    test('creates, switches between and deletes saves', () async {
      final controller = GameController(database: db);
      await controller.init();

      await controller.startNewGame(
          orgName: 'Alpha FC', tier: ReputationTier.local);
      final alphaId = controller.activeSaveId;
      await settle();
      expect(controller.organization!.name, 'Alpha FC');
      expect(controller.allFighters, isNotEmpty);
      final alphaRoster = controller.allFighters.length;

      await controller.startNewGame(
          orgName: 'Bravo MMA', tier: ReputationTier.national);
      await settle();
      final bravoId = controller.activeSaveId;
      expect(bravoId, isNot(alphaId));
      expect(controller.organization!.name, 'Bravo MMA');
      // The new save's roster replaced the old one rather than stacking
      // on top of it — the failure mode a shared database invites.
      expect(controller.allFighters, hasLength(alphaRoster));
      expect(await controller.listSaves(), hasLength(2));

      // Switching back restores the first save's own organization.
      await controller.loadSave(alphaId!);
      await settle();
      expect(controller.organization!.name, 'Alpha FC');
      expect(controller.allFighters, hasLength(alphaRoster));
      expect(controller.organization!.reputationTier, ReputationTier.local);

      // Deleting the open save falls back to the other one rather than
      // stranding the player on an empty dashboard.
      await controller.deleteSave(alphaId);
      expect(controller.needsNewGame, isFalse);
      expect(controller.activeSaveId, bravoId);
      expect(controller.organization!.name, 'Bravo MMA');

      await controller.deleteSave(bravoId!);
      expect(controller.needsNewGame, isTrue);
      expect(controller.activeSaveId, isNull);
      controller.dispose();
    });

    test('reopens the most recently played save on startup', () async {
      final first = GameController(database: db);
      await first.init();
      await first.startNewGame(
          orgName: 'Alpha FC', tier: ReputationTier.regional);
      await first.startNewGame(
          orgName: 'Bravo MMA', tier: ReputationTier.regional);
      first.dispose();

      // A fresh controller over the same database is what a relaunch is.
      final relaunched = GameController(database: db);
      await relaunched.init();
      expect(relaunched.needsNewGame, isFalse);
      expect(relaunched.organization!.name, 'Bravo MMA');
      relaunched.dispose();
    });
  });
}
