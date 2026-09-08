import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/simulation/fight_resolver.dart';

import '../support/fighter_fixtures.dart';

void main() {
  group('FightResolver — outcomes', () {
    test('winner is always one of the two fighters, or a draw', () {
      final resolver = FightResolver(random: Random(1));
      final a = testFighter('a', stat: 70);
      final b = testFighter('b', stat: 65);

      for (var i = 0; i < 100; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b);
        expect(
          result.winnerId == a.id || result.winnerId == b.id || result.isDraw,
          isTrue,
        );
      }
    });

    test('a much stronger fighter wins the clear majority of the time', () {
      final resolver = FightResolver(random: Random(42));
      final strong = testFighter('strong', stat: 90);
      final weak = testFighter('weak', stat: 25);

      var strongWins = 0;
      const trials = 200;
      for (var i = 0; i < trials; i++) {
        final result = resolver.resolve(fighterA: strong, fighterB: weak);
        if (result.winnerId == strong.id) strongWins++;
      }

      expect(strongWins / trials, greaterThan(0.80));
    });

    test('same seed produces the same outcome (deterministic)', () {
      final a = testFighter('a', stat: 60);
      final b = testFighter('b', stat: 55);

      final one = FightResolver(random: Random(7)).resolve(fighterA: a, fighterB: b);
      final two = FightResolver(random: Random(7)).resolve(fighterA: a, fighterB: b);

      expect(one.winnerId, two.winnerId);
      expect(one.method, two.method);
      expect(one.round, two.round);
      expect(one.timeSeconds, two.timeSeconds);
      expect(one.statsA.significantStrikesLanded, two.statsA.significantStrikesLanded);
    });

    test('round and finish time never exceed the scheduled length', () {
      final resolver = FightResolver(random: Random(3));
      final a = testFighter('a', stat: 60);
      final b = testFighter('b', stat: 60);

      for (var i = 0; i < 100; i++) {
        final three = resolver.resolve(fighterA: a, fighterB: b, rounds: 3);
        expect(three.round, inInclusiveRange(1, 3));
        expect(three.timeSeconds, inInclusiveRange(1, 300));

        final five = resolver.resolve(fighterA: a, fighterB: b, rounds: 5);
        expect(five.round, inInclusiveRange(1, 5));
        expect(five.timeSeconds, inInclusiveRange(1, 300));
      }
    });

    test('performance ratings stay within 0-100', () {
      final resolver = FightResolver(random: Random(11));
      final a = testFighter('a', stat: 80);
      final b = testFighter('b', stat: 30);

      for (var i = 0; i < 100; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b);
        expect(result.winnerPerformanceRating, inInclusiveRange(0, 100));
        expect(result.loserPerformanceRating, inInclusiveRange(0, 100));
      }
    });

    test('a wildly mismatched fight usually ends early', () {
      final resolver = FightResolver(random: Random(21));
      final strong = testFighter('strong', stat: 95);
      final weak = testFighter('weak', stat: 15);

      var finished = 0;
      const trials = 100;
      for (var i = 0; i < trials; i++) {
        final result = resolver.resolve(fighterA: strong, fighterB: weak, rounds: 5);
        if (result.method != FightMethod.decision &&
            result.method != FightMethod.drawOrNc) {
          finished++;
        }
      }

      expect(finished / trials, greaterThan(0.4));
    });
  });

  group('FightResolver — momentum and play-by-play', () {
    test('momentum ticks stay in range and never exceed the scheduled rounds', () {
      final resolver = FightResolver(random: Random(13));
      final a = testFighter('a', stat: 60);
      final b = testFighter('b', stat: 60);

      for (var i = 0; i < 50; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b, rounds: 3);
        expect(result.momentumTicks, isNotEmpty);
        for (final tick in result.momentumTicks) {
          expect(tick.fighterAShare, inInclusiveRange(0.0, 1.0));
          expect(tick.round, inInclusiveRange(1, 3));
          expect(tick.timeSeconds, inInclusiveRange(0, 300));
        }
      }
    });

    test('momentum actually fluctuates rather than sitting on one value', () {
      final result = FightResolver(random: Random(4))
          .resolve(fighterA: testFighter('a'), fighterB: testFighter('b'), rounds: 3);

      final shares = result.momentumTicks.map((t) => t.fighterAShare).toSet();
      expect(shares.length, greaterThan(5));
    });

    test('a play-by-play is produced with a round start and an end', () {
      final result = FightResolver(random: Random(5))
          .resolve(fighterA: testFighter('a'), fighterB: testFighter('b'));

      expect(result.events, isNotEmpty);
      expect(
        result.events.any((e) => e.type == FightEventType.roundStart),
        isTrue,
      );
    });
  });

  group('FightResolver — box score', () {
    test('landed strikes never exceed attempted', () {
      final resolver = FightResolver(random: Random(31));
      for (var i = 0; i < 50; i++) {
        final r = resolver.resolve(
          fighterA: testFighter('a', stat: 70),
          fighterB: testFighter('b', stat: 55),
          rounds: 3,
        );
        expect(r.statsA.significantStrikesLanded,
            lessThanOrEqualTo(r.statsA.significantStrikesAttempted));
        expect(r.statsB.significantStrikesLanded,
            lessThanOrEqualTo(r.statsB.significantStrikesAttempted));
        expect(r.statsA.takedownsLanded, lessThanOrEqualTo(r.statsA.takedownsAttempted));
        expect(r.statsB.takedownsLanded, lessThanOrEqualTo(r.statsB.takedownsAttempted));
      }
    });

    test('a striker throws far more strikes than a pure grinder', () {
      final striker = testFighter('striker', stat: 70, tendencies: pureStrikerTendencies);
      final grinder = testFighter('grinder', stat: 70, tendencies: grinderTendencies);

      var strikerVolume = 0;
      var grinderVolume = 0;
      for (var seed = 0; seed < 40; seed++) {
        final r = FightResolver(random: Random(seed))
            .resolve(fighterA: striker, fighterB: grinder, rounds: 3);
        strikerVolume += r.statsA.significantStrikesAttempted;
        grinderVolume += r.statsB.significantStrikesAttempted;
      }

      expect(strikerVolume, greaterThan(grinderVolume));
    });

    test('a wrestler shoots far more takedowns than a striker', () {
      final striker = testFighter('striker', stat: 70, tendencies: pureStrikerTendencies);
      final grinder = testFighter('grinder', stat: 70, tendencies: grinderTendencies);

      var strikerTds = 0;
      var grinderTds = 0;
      for (var seed = 0; seed < 40; seed++) {
        final r = FightResolver(random: Random(seed))
            .resolve(fighterA: striker, fighterB: grinder, rounds: 3);
        strikerTds += r.statsA.takedownsAttempted;
        grinderTds += r.statsB.takedownsAttempted;
      }

      expect(grinderTds, greaterThan(strikerTds * 3));
    });
  });

  group('FightResolver — grappling intents diverge', () {
    /// Same takedown ability, same ground skill — only the game plan
    /// differs. Each should produce a visibly different fight.
    ({int subAttempts, int control, int groundStrikes}) run(Tendencies plan, int seedBase) {
      var subAttempts = 0;
      var control = 0;
      var strikes = 0;
      for (var seed = 0; seed < 40; seed++) {
        final grappler = testFighter('g', stat: 75, tendencies: plan);
        final victim = testFighter(
          'v',
          stat: 45,
          takedownDefense: 30,
          scrambling: 30,
          tendencies: pureStrikerTendencies,
        );
        final r = FightResolver(random: Random(seedBase + seed))
            .resolve(fighterA: grappler, fighterB: victim, rounds: 3);
        subAttempts += r.statsA.submissionAttempts;
        control += r.statsA.controlSeconds;
        strikes += r.statsA.significantStrikesLanded;
      }
      return (subAttempts: subAttempts, control: control, groundStrikes: strikes);
    }

    test('a submission hunter attempts far more submissions than a grinder', () {
      final hunter = run(submissionHunterTendencies, 100);
      final grinder = run(grinderTendencies, 100);
      expect(hunter.subAttempts, greaterThan(grinder.subAttempts * 2));
    });

    test('a grinder accumulates more control time than a submission hunter', () {
      final grinder = run(grinderTendencies, 200);
      final hunter = run(submissionHunterTendencies, 200);
      expect(grinder.control, greaterThan(hunter.control));
    });

    test('a ground striker lands more strikes than a grinder', () {
      final striker = run(groundStrikerTendencies, 300);
      final grinder = run(grinderTendencies, 300);
      expect(striker.groundStrikes, greaterThan(grinder.groundStrikes));
    });
  });

  group('FightResolver — individual stats matter', () {
    /// Runs a matched pair where only one stat differs, and reports how
    /// often the buffed fighter wins.
    double winRateWithEdge(Fighter buffed, Fighter baseline, {int trials = 150}) {
      var wins = 0;
      for (var seed = 0; seed < trials; seed++) {
        final r = FightResolver(random: Random(seed))
            .resolve(fighterA: buffed, fighterB: baseline, rounds: 3);
        if (r.winnerId == buffed.id) wins++;
      }
      return wins / trials;
    }

    test('better takedown defense beats a wrestler more often', () {
      final baseline = testFighter('wrestler', stat: 65, tendencies: grinderTendencies);
      final stuffer = testFighter('stuffer', stat: 65, takedownDefense: 95, tendencies: pureStrikerTendencies);
      final sprawlless = testFighter('open', stat: 65, takedownDefense: 20, tendencies: pureStrikerTendencies);

      expect(
        winRateWithEdge(stuffer, baseline),
        greaterThan(winRateWithEdge(sprawlless, baseline)),
      );
    });

    test('a much better chin survives a puncher more often', () {
      final puncher = testFighter('puncher', stat: 70, power: 95, tendencies: pureStrikerTendencies);
      final ironChin = testFighter('iron', stat: 60, chin: 98, durability: 95, tendencies: pureStrikerTendencies);
      final glassChin = testFighter('glass', stat: 60, chin: 10, durability: 15, tendencies: pureStrikerTendencies);

      expect(
        winRateWithEdge(ironChin, puncher),
        greaterThan(winRateWithEdge(glassChin, puncher)),
      );
    });

    test('cardio decides fights that go long', () {
      final gasTank = testFighter('tank', stat: 62, cardio: 98, recovery: 95);
      final blowsUp = testFighter('gasser', stat: 62, cardio: 12, recovery: 15);
      final neutral = testFighter('neutral', stat: 62);

      expect(
        winRateWithEdge(gasTank, neutral, trials: 120),
        greaterThan(winRateWithEdge(blowsUp, neutral, trials: 120)),
      );
    });

    test('a big reach advantage helps a striker', () {
      final baseline = testFighter('baseline', stat: 62, tendencies: pureStrikerTendencies);
      final rangy = testFighter('rangy', stat: 62, reachInches: 80, tendencies: pureStrikerTendencies);
      final stubby = testFighter('stubby', stat: 62, reachInches: 62, tendencies: pureStrikerTendencies);

      expect(
        winRateWithEdge(rangy, baseline),
        greaterThan(winRateWithEdge(stubby, baseline)),
      );
    });

    test('submission defense saves you against a submission hunter', () {
      final hunter = testFighter('hunter', stat: 75, tendencies: submissionHunterTendencies);

      var tapsVsGood = 0;
      var tapsVsBad = 0;
      for (var seed = 0; seed < 120; seed++) {
        final tough = testFighter('tough', stat: 55, submissionDefense: 95, flexibility: 90);
        final easy = testFighter('easy', stat: 55, submissionDefense: 8, flexibility: 10);
        if (FightResolver(random: Random(seed))
                .resolve(fighterA: hunter, fighterB: tough, rounds: 3)
                .method ==
            FightMethod.submission) {
          tapsVsGood++;
        }
        if (FightResolver(random: Random(seed))
                .resolve(fighterA: hunter, fighterB: easy, rounds: 3)
                .method ==
            FightMethod.submission) {
          tapsVsBad++;
        }
      }
      expect(tapsVsBad, greaterThan(tapsVsGood));
    });
  });

  group('FightResolver — judging', () {
    test('a decision produces three scorecards', () {
      // Two identical low-power fighters almost always go the distance.
      final a = testFighter('a', stat: 55, power: 5, tendencies: pureStrikerTendencies);
      final b = testFighter('b', stat: 55, power: 5, tendencies: pureStrikerTendencies);

      FightResult? decision;
      for (var seed = 0; seed < 60 && decision == null; seed++) {
        final r = FightResolver(random: Random(seed)).resolve(fighterA: a, fighterB: b);
        if (r.method == FightMethod.decision) decision = r;
      }

      expect(decision, isNotNull);
      expect(decision!.scorecards.length, 3);
      for (final card in decision.scorecards) {
        expect(card.rounds.length, 3);
        expect(card.judgeName, isNotEmpty);
      }
    });

    test('every scored round is 10-9 or 10-8', () {
      final a = testFighter('a', stat: 55, power: 5);
      final b = testFighter('b', stat: 55, power: 5);

      for (var seed = 0; seed < 60; seed++) {
        final r = FightResolver(random: Random(seed)).resolve(fighterA: a, fighterB: b);
        for (final card in r.scorecards) {
          for (final round in card.rounds) {
            final high = max(round.fighterAScore, round.fighterBScore);
            final low = min(round.fighterAScore, round.fighterBScore);
            expect(high, 10);
            expect(low, anyOf(9, 8));
          }
        }
      }
    });

    test('a decision winner is the fighter most judges scored for', () {
      final a = testFighter('a', stat: 70, power: 5);
      final b = testFighter('b', stat: 45, power: 5);

      for (var seed = 0; seed < 60; seed++) {
        final r = FightResolver(random: Random(seed)).resolve(fighterA: a, fighterB: b);
        if (r.method != FightMethod.decision) continue;
        final forA = r.scorecards.where((c) => c.winner == 1).length;
        final forB = r.scorecards.where((c) => c.winner == -1).length;
        if (r.winnerId == a.id) {
          expect(forA, greaterThan(forB));
        } else {
          expect(forB, greaterThan(forA));
        }
      }
    });
  });
}
