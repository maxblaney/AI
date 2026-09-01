import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// A new save opens with a full roster already under contract — twenty to
/// a division — and the quality of that roster is set by the tier, because
/// purses scale hard with overall and a local promotion cannot pay for
/// national-level fighters.
void main() {
  List<Fighter> rosterFor(ReputationTier tier) => generateSignedRoster(
        tier: tier,
        signedOn: DateTime(2026, 1, 5),
        random: Random(7),
      );

  group('every tier', () {
    test('fields twenty fighters in every weight class', () {
      for (final tier in ReputationTier.values) {
        final roster = rosterFor(tier);
        expect(roster, hasLength(WeightClass.values.length * 20));
        for (final division in WeightClass.values) {
          expect(roster.where((f) => f.weightClass == division).length, 20,
              reason: '${tier.label} ${division.label}');
        }
      }
    });

    test('keeps every fighter inside its own overall band', () {
      for (final tier in ReputationTier.values) {
        final band = tier.signedRosterOverall;
        for (final fighter in rosterFor(tier)) {
          expect(
            fighter.overall,
            inInclusiveRange(band.min.toDouble(), band.max.toDouble()),
            reason: '${tier.label}: ${fighter.name} is '
                '${fighter.overall.toStringAsFixed(1)}, band is '
                '${band.min}-${band.max}',
          );
        }
      }
    });

    test('signs everyone, on staggered terms', () {
      for (final tier in ReputationTier.values) {
        final roster = rosterFor(tier);
        for (final fighter in roster) {
          expect(fighter.isSigned, isTrue);
          expect(fighter.contract!.fighterId, fighter.id);
          expect(fighter.contract!.fightsRemaining, greaterThan(0));
          expect(fighter.contract!.showMoney, greaterThan(0));
        }
        expect(roster.map((f) => f.contract!.fightsRemaining).toSet().length,
            greaterThan(1),
            reason: '${tier.label} should not all expire on the same night');
        expect(roster.map((f) => f.id).toSet(), hasLength(roster.length));
      }
    });

    test('spans real quality inside its band, not one flat tier', () {
      for (final tier in ReputationTier.values) {
        final band = tier.signedRosterOverall;
        final span = band.max - band.min;
        final overalls = rosterFor(tier).map((f) => f.overall).toList()
          ..sort();

        expect(overalls.first, lessThan(band.min + span * 0.4),
            reason: '${tier.label} needs fighters near its floor');
        expect(overalls.last, greaterThan(band.max - span * 0.25),
            reason: '${tier.label} needs somebody near its ceiling');
      }
    });
  });

  test('the bands climb with the tier and never overlap backwards', () {
    // Each rung up should be a better roster than the one below it.
    const tiers = ReputationTier.values;
    for (var i = 1; i < tiers.length; i++) {
      final lower = tiers[i - 1].signedRosterOverall;
      final higher = tiers[i].signedRosterOverall;
      expect(higher.min, greaterThan(lower.min));
      expect(higher.max, greaterThan(lower.max));
      expect(higher.min, lessThan(lower.max),
          reason: 'a little overlap keeps the jump from feeling like a cliff');
    }
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

    final band = ReputationTier.regional.signedRosterOverall;
    for (final fighter in controller.signedRoster) {
      expect(fighter.overall,
          inInclusiveRange(band.min.toDouble(), band.max.toDouble()));
    }
    // Signing normally charges the show money as a bonus; the opening
    // roster must not, or a new save starts broke.
    expect(controller.organization!.cashBalance,
        ReputationTier.regional.startingCash);

    controller.dispose();
    await db.close();
  });
}
