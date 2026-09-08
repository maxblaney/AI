import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';

/// Popularity is what the gate is built on, so how it is rolled at
/// generation is a balance decision worth pinning down.
int outOfTen(int popularity) =>
    popularity <= 0 ? 0 : ((popularity + 9) ~/ 10).clamp(1, 10);

void main() {
  group('starting popularity', () {
    late List<Fighter> pool;

    setUpAll(() {
      pool = generateStartingRoster(random: Random(5));
    });

    test('nobody starts above 8 out of 10', () {
      // Becoming a 9 or a 10 is something a fighter does by winning
      // fights in your promotion, not something they walk in with.
      for (final fighter in pool) {
        expect(fighter.popularity, lessThanOrEqualTo(maxStartingPopularity),
            reason: '${fighter.name} started at ${fighter.popularity}');
        expect(outOfTen(fighter.popularity), lessThanOrEqualTo(8));
      }
    });

    test('somebody does reach 8, and it stays rare', () {
      final eights = pool.where((f) => outOfTen(f.popularity) >= 8).length;
      final sevens = pool.where((f) => outOfTen(f.popularity) >= 7).length;

      expect(eights, greaterThan(0), reason: 'the top of the scale is unused');
      // A roster where everyone is a draw is a roster where nobody is.
      expect(eights / pool.length, lessThan(0.05));
      expect(sevens / pool.length, lessThan(0.10));
    });

    test('nobody starts at zero either', () {
      for (final fighter in pool) {
        expect(fighter.popularity, greaterThanOrEqualTo(5));
      }
    });

    test('the better fighters are the bigger names', () {
      // The thing this replaced rolled popularity with no reference to
      // overall at all, so a 96-overall contender was as likely to be a
      // 2/10 draw as a 48-overall journeyman.
      final sorted = [...pool]..sort((a, b) => a.overall.compareTo(b.overall));
      final worst = sorted.take(80);
      final best = sorted.skip(sorted.length - 80);

      double meanPopularity(Iterable<Fighter> fighters) =>
          fighters.map((f) => f.popularity).reduce((a, b) => a + b) /
          fighters.length;

      expect(meanPopularity(best), greaterThan(meanPopularity(worst) + 15),
          reason: 'the top of the roster should be clearly better known');
    });

    test('a bigger promotion signs bigger names', () {
      double meanFor(ReputationTier tier) {
        final roster = generateSignedRoster(
            tier: tier, signedOn: DateTime(2026), random: Random(3));
        return roster.map((f) => f.popularity).reduce((a, b) => a + b) /
            roster.length;
      }

      // Falls straight out of tying popularity to overall, and is the
      // point: a local show's fighters are unknowns, an international
      // one's are names.
      expect(meanFor(ReputationTier.international),
          greaterThan(meanFor(ReputationTier.local) + 20));
    });

    test('two fighters of the same standard are not the same draw', () {
      // Same overall band, so any spread is the noise term doing its job.
      final mid = pool
          .where((f) => f.overall >= 70 && f.overall <= 75)
          .map((f) => f.popularity)
          .toSet();

      expect(mid.length, greaterThan(5),
          reason: 'popularity is tracking overall too tightly');
    });
  });
}
