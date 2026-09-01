import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// A new save opens with a full roster already under contract — twenty to
/// a division, none of them a journeyman — alongside the free-agent pool.
void main() {
  group('generateSignedRoster', () {
    final roster = generateSignedRoster(
      signedOn: DateTime(2026, 1, 5),
      random: Random(7),
    );

    test('twenty fighters in every weight class', () {
      for (final division in WeightClass.values) {
        expect(
          roster.where((f) => f.weightClass == division).length,
          20,
          reason: '${division.label} should be fully stocked',
        );
      }
      expect(roster, hasLength(WeightClass.values.length * 20));
    });

    test('every one of them is between 70 and 95 overall', () {
      for (final fighter in roster) {
        expect(
          fighter.overall,
          inInclusiveRange(
            signedRosterMinOverall.toDouble(),
            signedRosterMaxOverall.toDouble(),
          ),
          reason: '${fighter.name} is ${fighter.overall.toStringAsFixed(1)}',
        );
      }
    });

    test('every one of them is actually signed', () {
      for (final fighter in roster) {
        expect(fighter.isSigned, isTrue);
        expect(fighter.contract!.fighterId, fighter.id);
        expect(fighter.contract!.fightsRemaining, greaterThan(0));
        expect(fighter.contract!.showMoney, greaterThan(0));
      }
    });

    test('contracts do not all expire on the same night', () {
      final terms = roster.map((f) => f.contract!.fightsRemaining).toSet();
      expect(terms.length, greaterThan(1));
    });

    test('the roster spans real quality, not one flat tier', () {
      final overalls = roster.map((f) => f.overall).toList()..sort();
      expect(overalls.first, lessThan(78),
          reason: 'most of a division should be solid rather than elite');
      expect(overalls.last, greaterThan(88),
          reason: 'somewhere in there should be a genuine draw');
    });

    test('ids are unique, so nobody gets saved over', () {
      expect(roster.map((f) => f.id).toSet(), hasLength(roster.length));
    });
  });

  test('a new save opens with the signed roster and a talent pool',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final controller = GameController(database: db, random: Random(11));
    await controller.init();
    await controller.startNewGame(
      orgName: 'Stocked FC',
      tier: ReputationTier.regional,
    );
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(controller.signedRoster, hasLength(160));
    expect(controller.talentPool, isNotEmpty,
        reason: 'there should still be free agents to sign');
    for (final division in WeightClass.values) {
      expect(
        controller.signedRoster.where((f) => f.weightClass == division).length,
        20,
      );
    }
    // Signing normally charges the show money as a bonus; the opening
    // roster must not, or a new save starts broke.
    expect(controller.organization!.cashBalance,
        ReputationTier.regional.startingCash);

    controller.dispose();
    await db.close();
  });
}
