import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';

/// The tier ladder is meant to be a progression, not a difficulty
/// select — these are the properties that make it one.
void main() {
  group('ReputationTier ladder', () {
    test('climbs in order and stops at the top', () {
      expect(ReputationTier.local.nextTier, ReputationTier.regional);
      expect(ReputationTier.regional.nextTier, ReputationTier.national);
      expect(ReputationTier.national.nextTier, ReputationTier.international);
      expect(ReputationTier.international.nextTier, isNull);
    });

    test('every rung costs more reputation than the one below', () {
      var previous = -1;
      for (final tier in ReputationTier.values) {
        expect(tier.reputationRequired, greaterThan(previous),
            reason: '${tier.name} must sit above the tier below it');
        previous = tier.reputationRequired;
      }
      expect(ReputationTier.local.reputationRequired, 0,
          reason: 'the bottom rung is where everyone starts');
    });

    test('each step up is reachable inside a career', () {
      // A well-run card makes +2 or +3 reputation and a promotion runs
      // about twelve a year, so roughly 25-30 a year. Every gap should
      // clear inside a handful of seasons — an unreachable top rung is
      // decoration, which is what 400 turned out to be when a measured
      // twelve-year career finished on 308.
      const perYear = 25;
      for (final tier in ReputationTier.values) {
        final next = tier.nextTier;
        if (next == null) continue;
        final gap = next.reputationRequired - tier.reputationRequired;
        expect(gap / perYear, lessThan(7),
            reason: '${tier.name} -> ${next.name} should not take longer '
                'than a career');
      }
      expect(
        ReputationTier.international.reputationRequired / perYear,
        lessThan(13),
        reason: 'the top of the ladder has to be touchable',
      );
    });

    test('every tier above the bottom says what it unlocks', () {
      expect(ReputationTier.local.promotionPerks, isEmpty);
      for (final tier in [
        ReputationTier.regional,
        ReputationTier.national,
        ReputationTier.international,
      ]) {
        expect(tier.promotionPerks, isNotEmpty,
            reason: 'a promotion the player cannot read is not a reward');
      }
      // The step that matters most is the one that opens pay-per-view.
      expect(
        ReputationTier.national.promotionPerks
            .any((p) => p.toLowerCase().contains('pay-per-view')),
        isTrue,
      );
    });
  });
}
