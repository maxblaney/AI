import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/simulation/fight_resolver.dart';

Fighter _fighter(String id, {required int stat}) {
  return Fighter(
    id: id,
    name: id,
    age: 27,
    nationality: 'USA',
    weightClass: WeightClass.lightweight,
    heightInches: 70,
    weightLbs: 155,
    record: const FightRecord(wins: 10, losses: 2),
    fightingStats: FightingStats(
      punching: stat,
      kicking: stat,
      power: stat,
      speed: stat,
      accuracy: stat,
      defense: stat,
      takedowns: stat,
      takedownDefense: stat,
      wrestling: stat,
      groundAndPound: stat,
      submissionOffense: stat,
      submissionDefense: stat,
      grappling: stat,
    ),
    physicalStats: PhysicalStats(
      cardio: stat,
      durability: stat,
      chin: stat,
      bodyToughness: stat,
      legToughness: stat,
      strength: stat,
      athleticism: stat,
      recovery: stat,
    ),
    mentalStats: MentalStats(
      fightIq: stat,
      composure: stat,
      aggression: stat,
      discipline: stat,
      confidence: stat,
      heart: stat,
      adaptability: stat,
    ),
    style: FightingStyle.wellRounded,
    tendencies: const Tendencies(
      strikingFrequency: 50,
      takedownFrequency: 50,
      kickFrequency: 50,
      clinchFrequency: 50,
      submissionAttempts: 50,
      groundAndPound: 50,
      aggression: 50,
      counterStriking: 50,
      headHunting: 50,
      bodyAttacks: 50,
      legAttacks: 50,
    ),
    potential: stat.clamp(30, 99),
    popularity: 40,
    morale: 80,
    injuryStatus: InjuryStatus.healthy,
    winStreak: 2,
  );
}

void main() {
  group('FightResolver', () {
    test('winner is always one of the two fighters, or a draw', () {
      final resolver = FightResolver(random: Random(1));
      final a = _fighter('a', stat: 70);
      final b = _fighter('b', stat: 65);

      for (var i = 0; i < 200; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b);
        expect(
          result.winnerId == a.id || result.winnerId == b.id || result.isDraw,
          isTrue,
        );
      }
    });

    test('a much stronger fighter wins the clear majority of the time', () {
      final resolver = FightResolver(random: Random(42));
      final strong = _fighter('strong', stat: 90);
      final weak = _fighter('weak', stat: 25);

      var strongWins = 0;
      const trials = 500;
      for (var i = 0; i < trials; i++) {
        final result = resolver.resolve(fighterA: strong, fighterB: weak);
        if (result.winnerId == strong.id) strongWins++;
      }

      expect(strongWins / trials, greaterThan(0.85));
    });

    test('same seed produces the same outcome (deterministic)', () {
      final a = _fighter('a', stat: 60);
      final b = _fighter('b', stat: 55);

      final resultOne =
          FightResolver(random: Random(7)).resolve(fighterA: a, fighterB: b);
      final resultTwo =
          FightResolver(random: Random(7)).resolve(fighterA: a, fighterB: b);

      expect(resultOne.winnerId, resultTwo.winnerId);
      expect(resultOne.method, resultTwo.method);
      expect(resultOne.round, resultTwo.round);
    });

    test('round never exceeds the 3-round limit for a non-main-event fight',
        () {
      final resolver = FightResolver(random: Random(3));
      final a = _fighter('a', stat: 60);
      final b = _fighter('b', stat: 60);

      for (var i = 0; i < 200; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b);
        expect(result.round, inInclusiveRange(1, 3));
      }
    });

    test('round never exceeds the 5-round limit for a 5-round fight', () {
      final resolver = FightResolver(random: Random(9));
      final a = _fighter('a', stat: 60);
      final b = _fighter('b', stat: 60);

      for (var i = 0; i < 200; i++) {
        final result = resolver.resolve(
          fighterA: a,
          fighterB: b,
          rounds: 5,
        );
        expect(result.round, inInclusiveRange(1, 5));
      }
    });

    test('performance ratings stay within 0-100', () {
      final resolver = FightResolver(random: Random(11));
      final a = _fighter('a', stat: 80);
      final b = _fighter('b', stat: 30);

      for (var i = 0; i < 200; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b);
        expect(result.winnerPerformanceRating, inInclusiveRange(0, 100));
        expect(result.loserPerformanceRating, inInclusiveRange(0, 100));
      }
    });

    test('momentum ticks never exceed the scheduled round count', () {
      final resolver = FightResolver(random: Random(13));
      final a = _fighter('a', stat: 60);
      final b = _fighter('b', stat: 60);

      for (var i = 0; i < 200; i++) {
        final result = resolver.resolve(fighterA: a, fighterB: b, rounds: 3);
        expect(
          result.momentumTicks.length,
          inInclusiveRange(1, 3 * FightResolver.ticksPerRound),
        );
        expect(result.momentumTicks.last.round, lessThanOrEqualTo(3));
        for (final tick in result.momentumTicks) {
          expect(tick.fighterAShare, inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('a finish ends the fight before the scheduled round count', () {
      // Wildly mismatched fighters should finish well before 5 rounds most
      // of the time.
      final resolver = FightResolver(random: Random(21));
      final strong = _fighter('strong', stat: 95);
      final weak = _fighter('weak', stat: 15);

      var finishedEarly = 0;
      const trials = 200;
      for (var i = 0; i < trials; i++) {
        final result = resolver.resolve(fighterA: strong, fighterB: weak, rounds: 5);
        if (result.method != FightMethod.decision &&
            result.method != FightMethod.drawOrNc) {
          finishedEarly++;
        }
      }

      expect(finishedEarly / trials, greaterThan(0.3));
    });
  });
}
