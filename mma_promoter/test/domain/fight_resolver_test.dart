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
    record: const FightRecord(wins: 10, losses: 2),
    stats: FighterStats(
      striking: stat,
      grappling: stat,
      cardio: stat,
      chin: stat,
      power: stat,
    ),
    popularity: 40,
    morale: 80,
    injuryStatus: InjuryStatus.healthy,
    winStreak: 2,
    styleTags: const [StyleTag.allRounder],
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

    test('round never exceeds the 5-round limit for a title fight', () {
      final resolver = FightResolver(random: Random(9));
      final a = _fighter('a', stat: 60);
      final b = _fighter('b', stat: 60);

      for (var i = 0; i < 200; i++) {
        final result = resolver.resolve(
          fighterA: a,
          fighterB: b,
          isTitleFight: true,
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
  });
}
