import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/domain/finance/running_costs.dart';

/// Overheads are what stop money being a scoreboard. These pin down the
/// shape they have to keep: real enough to notice, small enough to
/// survive.
void main() {
  List<Fighter> rosterFor(ReputationTier tier) => generateSignedRoster(
        tier: tier,
        signedOn: DateTime(2026),
        random: Random(8),
      );

  group('weekly overheads', () {
    test('an empty roster still costs something to run', () {
      for (final tier in ReputationTier.values) {
        final cost = RunningCosts.weekly(tier: tier, roster: const []);
        expect(cost, RunningCosts.weeklyBaseFor(tier));
        expect(cost, greaterThan(0),
            reason: 'staff and premises do not stop when nobody is signed');
      }
    });

    test('every fighter under contract adds to it', () {
      final roster = rosterFor(ReputationTier.regional);
      final full = RunningCosts.weekly(
          tier: ReputationTier.regional, roster: roster);
      final half = RunningCosts.weekly(
          tier: ReputationTier.regional,
          roster: roster.take(roster.length ~/ 2));

      expect(full, greaterThan(half),
          reason: 'a roster you never book should still be one you pay for');
    });

    test('a bigger promotion is a bigger operation', () {
      var previous = 0;
      for (final tier in ReputationTier.values) {
        final cost = RunningCosts.weekly(tier: tier, roster: rosterFor(tier));
        expect(cost, greaterThan(previous), reason: tier.name);
        previous = cost;
      }
    });

    test('a full roster is a real cost but not a ruinous one', () {
      // The guard that matters: a default save opens with 160 fighters
      // signed, and overheads that scaled hard with roster size would
      // sink it before its second card. Measured against the tier's own
      // opening cash rather than a flat number.
      for (final tier in ReputationTier.values) {
        final weekly = RunningCosts.weekly(tier: tier, roster: rosterFor(tier));
        final monthly = weekly * 4;

        expect(monthly, lessThan(tier.startingCash),
            reason: '${tier.name} burns its opening cash in under a month');
        expect(monthly, greaterThan(tier.startingCash * 0.02),
            reason: '${tier.name} overheads are too small to notice');
      }
    });
  });

  group('the debt ceiling', () {
    test('there is rope, and it runs out', () {
      for (final tier in ReputationTier.values) {
        final ceiling = RunningCosts.debtCeilingFor(tier);
        expect(ceiling, lessThan(0));

        expect(
          RunningCosts.isOverextended(tier: tier, cashBalance: 0),
          isFalse,
        );
        expect(
          RunningCosts.isOverextended(tier: tier, cashBalance: ceiling + 1),
          isFalse,
          reason: 'right at the limit is still allowed',
        );
        expect(
          RunningCosts.isOverextended(tier: tier, cashBalance: ceiling - 1),
          isTrue,
        );
      }
    });

    test('the rope is proportional to the operation', () {
      expect(
        RunningCosts.debtCeilingFor(ReputationTier.international).abs(),
        greaterThan(RunningCosts.debtCeilingFor(ReputationTier.local).abs()),
      );
    });

    test('a tier can survive several idle months before being cut off', () {
      // Being cut off should be the end of a slide the player could see
      // coming, not something that happens in a fortnight.
      for (final tier in ReputationTier.values) {
        final weekly = RunningCosts.weekly(tier: tier, roster: rosterFor(tier));
        final runway =
            (tier.startingCash - RunningCosts.debtCeilingFor(tier)) / weekly;

        expect(runway, greaterThan(8),
            reason: '${tier.name} is cut off after only '
                '${runway.toStringAsFixed(1)} idle weeks');
      }
    });
  });
}
