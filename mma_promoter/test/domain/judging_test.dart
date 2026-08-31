import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/simulation/fight_resolver.dart';
import 'package:mma_promoter/domain/simulation/judging.dart';

import '../support/fighter_fixtures.dart';

RoundTally _tally({
  double damage = 0,
  int significantStrikes = 0,
  int knockdowns = 0,
  int takedowns = 0,
  int submissionAttempts = 0,
  double controlValue = 0,
  double nearFinishes = 0,
}) {
  return RoundTally()
    ..damage = damage
    ..significantStrikes = significantStrikes
    ..knockdowns = knockdowns
    ..takedowns = takedowns
    ..submissionAttempts = submissionAttempts
    ..controlValue = controlValue
    ..nearFinishes = nearFinishes;
}

/// Scores one round on every judge and reports how many made it 10-8.
int _tenEights(RoundTally a, RoundTally b, {int seed = 5}) {
  final cards = JudgePanel(random: Random(seed)).score([(a, b)]);
  return cards
      .where((c) => c.rounds.single.fighterAScore == 8 ||
          c.rounds.single.fighterBScore == 8)
      .length;
}

void main() {
  group('the panel', () {
    test('is drawn from the commission pool, three of the four', () {
      const pool = {
        'Kyle Gates',
        'Eric Parsons',
        'Lucas Craft',
        'Pablo Llorente',
      };

      for (var seed = 0; seed < 40; seed++) {
        final names = JudgePanel(random: Random(seed))
            .score([(_tally(significantStrikes: 5), _tally())])
            .map((c) => c.judgeName)
            .toList();

        expect(names, hasLength(3));
        expect(names.toSet(), hasLength(3), reason: 'no judge sits twice');
        for (final name in names) {
          expect(pool, contains(name));
        }
      }
    });

    test('the seat that sits out varies', () {
      final absentees = <String>{};
      for (var seed = 0; seed < 40; seed++) {
        final names = JudgePanel(random: Random(seed))
            .score([(_tally(significantStrikes: 5), _tally())])
            .map((c) => c.judgeName)
            .toSet();
        absentees.addAll({
          'Kyle Gates',
          'Eric Parsons',
          'Lucas Craft',
          'Pablo Llorente',
        }.difference(names));
      }
      expect(absentees.length, greaterThan(1),
          reason: 'the same judge should not always be the one left off');
    });
  });

  group('10-8 rounds', () {
    test('a round that is merely clear is 10-9', () {
      // Winning the round comfortably on volume, with the other man still
      // in it. This is the round type that used to score 10-8.
      final winner = _tally(damage: 22, significantStrikes: 30, takedowns: 2);
      final loser = _tally(damage: 6, significantStrikes: 11);

      expect(_tenEights(winner, loser), 0);
    });

    test('control with nothing behind it is 10-9, however long', () {
      // Five minutes of top position and no damage: a shut-out on the
      // clock, but nobody was ever in trouble.
      final winner = _tally(controlValue: 280, takedowns: 3, damage: 4);
      final loser = _tally();

      expect(_tenEights(winner, loser), 0,
          reason: 'a grinding round is not a 10-8');
    });

    test('one knockdown in a competitive round is 10-9', () {
      final winner = _tally(damage: 26, significantStrikes: 20, knockdowns: 1);
      final loser = _tally(damage: 14, significantStrikes: 15, takedowns: 1);

      expect(_tenEights(winner, loser), 0);
    });

    test('two knockdowns is a 10-8 on every card', () {
      final winner = _tally(damage: 45, significantStrikes: 26, knockdowns: 2);
      final loser = _tally(damage: 3, significantStrikes: 2);

      expect(_tenEights(winner, loser), 3);
    });

    test('a one-way beating that lasts is a 10-8', () {
      // Dropped, never got going, and it went on for the whole round.
      final winner = _tally(
        damage: 60,
        significantStrikes: 40,
        knockdowns: 1,
        controlValue: 250,
        nearFinishes: 2,
      );
      final loser = _tally(damage: 2, significantStrikes: 1);

      expect(_tenEights(winner, loser), 3);
    });

    test('stay rare across a lot of real fights', () {
      final rng = Random(42);
      final resolver = FightResolver(random: Random(7));
      var rounds = 0;
      var tenEights = 0;

      for (var i = 0; i < 600; i++) {
        final result = resolver.resolve(
          fighterA: testFighter('a', stat: 60 + rng.nextInt(35)),
          fighterB: testFighter('b', stat: 60 + rng.nextInt(35)),
          rounds: rng.nextBool() ? 3 : 5,
        );
        for (final card in result.scorecards) {
          for (final round in card.rounds) {
            rounds++;
            if (round.fighterAScore == 8 || round.fighterBScore == 8) {
              tenEights++;
            }
          }
        }
      }

      expect(rounds, greaterThan(1000));
      final rate = tenEights / rounds;
      // Real MMA scores roughly 3-6% of rounds 10-8. This used to be 68%,
      // which made the score meaningless.
      expect(rate, lessThan(0.09),
          reason: 'a 10-8 has to mean something when it shows up');
      expect(rate, greaterThan(0.005),
          reason: 'they should still happen — a shut-out round exists');
    });
  });
}
