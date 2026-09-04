import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/betting/fight_odds.dart';

import '../support/fighter_fixtures.dart';

void main() {
  group('OddsCalculator', () {
    test('an even matchup prices close to a pick\'em, both sides negative',
        () {
      final a = testFighter('a', stat: 70);
      final b = testFighter('b', stat: 70);
      final odds = OddsCalculator.forFight(a: a, b: b);

      expect(odds.probabilityA, closeTo(0.5, 0.01));
      // With the book's margin in, a coin flip is priced worse than even
      // money on both sides — that's where the house edge lives.
      expect(odds.moneylineA, lessThan(0));
      expect(odds.moneylineB, lessThan(0));
      expect(odds.moneylineA, greaterThan(-130));
    });

    test('the better fighter is the favourite', () {
      final favourite = testFighter('a', stat: 85);
      final underdog = testFighter('b', stat: 65);
      final odds = OddsCalculator.forFight(a: favourite, b: underdog);

      expect(odds.probabilityA, greaterThan(0.6));
      expect(odds.aIsFavourite, isTrue);
      expect(odds.moneylineA, lessThan(0), reason: 'favourites are negative');
      expect(odds.moneylineB, greaterThan(0), reason: 'dogs are positive');
    });

    test('the line widens as the skill gap grows', () {
      final elite = testFighter('a', stat: 95);
      final journeyman = testFighter('b', stat: 55);
      final mid = testFighter('c', stat: 75);

      final blowout = OddsCalculator.forFight(a: elite, b: journeyman);
      final closer = OddsCalculator.forFight(a: elite, b: mid);

      expect(blowout.probabilityA, greaterThan(closer.probabilityA));
      expect(blowout.moneylineA, lessThan(closer.moneylineA));
    });

    test('nobody is ever priced as a certainty', () {
      final best = testFighter('a', stat: 99);
      final worst = testFighter('b', stat: 15);
      final odds = OddsCalculator.forFight(a: best, b: worst);

      // Anyone can get caught — the book never puts up a lock.
      expect(odds.probabilityA, lessThanOrEqualTo(0.92));
      expect(odds.moneylineB, greaterThan(0));
    });

    test('form and injury nudge the line', () {
      final base = testFighter('a', stat: 75, winStreak: 0);
      final hot = testFighter('b', stat: 75, winStreak: 5);
      final hurt = testFighter('c', stat: 75, winStreak: 0)
          .copyWith(injuryStatus: InjuryStatus.minor);

      expect(
        OddsCalculator.forFight(a: hot, b: base).probabilityA,
        greaterThan(0.5),
        reason: 'a fighter on a run should be favoured over an identical one',
      );
      expect(
        OddsCalculator.forFight(a: hurt, b: base).probabilityA,
        lessThan(0.5),
        reason: 'carrying an injury should shorten your price',
      );
    });

    test('American odds format with an explicit sign', () {
      expect(FightOdds.format(150), '+150');
      expect(FightOdds.format(-200), '-200');
    });

    test('prices land on values a book would actually post', () {
      for (final gap in [0, 5, 10, 20, 30, 40]) {
        final odds = OddsCalculator.forFight(
          a: testFighter('a', stat: 55 + gap),
          b: testFighter('b', stat: 55),
        );
        for (final line in [odds.moneylineA, odds.moneylineB]) {
          expect(line % 5, 0, reason: 'books quote in fives');
          expect(line.abs(), greaterThanOrEqualTo(100),
              reason: 'nothing sits inside +/-100');
        }
      }
    });
  });
}
