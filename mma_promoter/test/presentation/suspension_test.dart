import 'dart:math';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// A suspension has to survive the round trip through the database and
/// then actually lift itself — a fighter stuck banned forever because
/// nothing clears the flag would be a quiet, save-ruining bug.
void main() {
  late AppDatabase db;
  late GameController controller;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = GameController(database: db, random: Random(11));
    await controller.init();
    await controller.startNewGame(
      orgName: 'Ban FC',
      tier: ReputationTier.regional,
    );
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('a suspension persists and then lifts on its own', () async {
    final org = controller.organization!;
    final banUntil = org.currentWeek + 2;

    final fighter = testFighter('banned').copyWith(
      name: 'Banned Fighter',
      suspendedUntilWeek: banUntil,
      contract: Contract(
        id: 'c',
        fighterId: 'banned',
        fightsRemaining: 3,
        showMoney: 1000,
        winBonus: 1000,
        exclusive: true,
        signedOn: DateTime(2026, 1, 1),
      ),
    );
    await controller.saveFighter(fighter);
    await settle();

    expect(controller.fighterById('banned')!.suspendedUntilWeek, banUntil,
        reason: 'the ban should round-trip through the database');
    expect(
      controller.fighterById('banned')!.isBookableOn(org.currentWeek),
      isFalse,
    );

    await controller.advanceWeek();
    await settle();
    expect(controller.fighterById('banned')!.suspendedUntilWeek, banUntil,
        reason: 'still serving it a week in');

    await controller.advanceWeek();
    await settle();

    final free = controller.fighterById('banned')!;
    expect(free.suspendedUntilWeek, isNull, reason: 'the ban has run out');
    expect(free.isBookableOn(controller.organization!.currentWeek), isTrue);
    expect(
      controller.inboxItems.any((i) =>
          i.type == InboxItemType.suspension &&
          i.fighterId == 'banned' &&
          i.title.contains('eligible again')),
      isTrue,
      reason: 'the player should be told their fighter is back',
    );
  });
}
