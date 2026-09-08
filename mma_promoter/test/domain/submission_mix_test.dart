import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/simulation/fight_resolver.dart';
import 'package:mma_promoter/domain/simulation/submissions.dart';

import '../support/fighter_fixtures.dart';

/// The mix of submissions across a save should look like the sport's:
/// rear-naked chokes everywhere, the odd calf slicer. Two things can
/// break that — someone editing the catalog, or a change to the ground
/// game that shifts how often fights reach each position — so this
/// checks the declared targets *and* the mix the simulator actually
/// produces.
void main() {
  group('catalog', () {
    test('the declared shares are the real-world distribution', () {
      double shareOf(String name) =>
          SubmissionCatalog.all.firstWhere((h) => h.name == name).share;

      expect(shareOf('Rear-Naked Choke'), 38.5);
      expect(shareOf('Guillotine Choke'), 17.4);
      expect(shareOf('Armbar'), 13.1);
      expect(shareOf('Triangle Choke'), 9.9);
      expect(shareOf("D'Arce Choke"), 8.8);
      expect(shareOf('Kimura'), 2.6);
      expect(shareOf('Anaconda Choke'), 2.0);
      expect(shareOf('Neck Crank'), 1.4);
    });

    test('the eight named holds are 93.7%, the rest 6.3%', () {
      double sum(List<SubmissionHold> holds) =>
          holds.fold<double>(0, (total, h) => total + h.share);

      expect(sum(SubmissionCatalog.common), closeTo(93.7, 0.01));
      expect(sum(SubmissionCatalog.rare), closeTo(6.3, 0.01));
      expect(sum(SubmissionCatalog.all), closeTo(100.0, 0.01));
    });

    test('every hold is reachable from somewhere', () {
      for (final hold in SubmissionCatalog.all) {
        expect(hold.topPositions.isNotEmpty || hold.fromBottom, isTrue,
            reason: '${hold.name} can never be rolled');
      }
    });

    test('position gates what can be thrown', () {
      // You cannot take someone's back from inside their guard.
      final fromGuard = [
        for (final hold in SubmissionCatalog.all)
          if (hold.availableFrom(GroundPosition.guard, fromTop: true)) hold.name,
      ];
      expect(fromGuard, isNot(contains('Rear-Naked Choke')));
      expect(fromGuard, contains('Guillotine Choke'));

      final fromBack = [
        for (final hold in SubmissionCatalog.all)
          if (hold.availableFrom(GroundPosition.backMount, fromTop: true))
            hold.name,
      ];
      expect(fromBack, contains('Rear-Naked Choke'));
      expect(fromBack, isNot(contains('Armbar')));
    });

    test('a roll only ever returns something legal for the position', () {
      final random = Random(3);
      for (final position in GroundPosition.values) {
        for (final fromTop in [true, false]) {
          for (var i = 0; i < 200; i++) {
            final hold = SubmissionCatalog.roll(random,
                position: position, fromTop: fromTop);
            expect(hold.availableFrom(position, fromTop: fromTop), isTrue,
                reason: '${hold.name} from $position (fromTop: $fromTop)');
          }
        }
      }
    });
  });

  test('the simulated mix lands on the targets', () {
    // Enough fights for the common holds to settle; the rare tail is
    // checked as a group rather than hold by hold, since a 0.2% hold
    // needs far more samples than a test should take.
    const fights = 2500;
    final rng = Random(42);
    final resolver = FightResolver(random: Random(7));
    final counts = <String, int>{};
    var submissions = 0;

    for (var i = 0; i < fights; i++) {
      final result = resolver.resolve(
        fighterA: testFighter('a', stat: 60 + rng.nextInt(35)),
        fighterB: testFighter('b', stat: 60 + rng.nextInt(35)),
        rounds: rng.nextBool() ? 3 : 5,
      );
      if (result.method != FightMethod.submission) continue;
      submissions++;
      counts[result.methodDetail] = (counts[result.methodDetail] ?? 0) + 1;
    }

    expect(submissions, greaterThan(500),
        reason: 'not enough submissions to say anything about the mix');

    double pct(String name) => (counts[name] ?? 0) / submissions * 100;

    // Generous but meaningful: a hold drifting more than 4 points off is
    // a real change to the ground game, not sampling noise.
    for (final hold in SubmissionCatalog.common) {
      expect(pct(hold.name), closeTo(hold.share, 4.0),
          reason: '${hold.name} is off its target share');
    }

    // The rear-naked choke is nearly two fifths of all taps and has to
    // stay the clear number one.
    final ranked = counts.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    expect(ranked.first.key, 'Rear-Naked Choke');
    expect(ranked[1].key, 'Guillotine Choke');

    final rareTotal = SubmissionCatalog.rare
        .fold<double>(0, (sum, hold) => sum + pct(hold.name));
    expect(rareTotal, closeTo(6.3, 4.0),
        reason: 'the long tail as a group should be about 6% of taps');
  });
}
