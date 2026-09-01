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
      // Real MMA scores a low single-digit percentage of rounds 10-8.
      // This started at 68%, which made the score meaningless.
      expect(rate, lessThan(0.045),
          reason: 'a 10-8 has to mean something when it shows up');
      expect(rate, greaterThan(0.005),
          reason: 'they should still happen — a shut-out round exists');
    });
  });

  group('the dominance curve', () {
    test('a knockdown is most of a 10-8 but not all of it on its own', () {
      final oneDrop = JudgePanel.dominanceOf(
        _tally(knockdowns: 1, damage: 20, significantStrikes: 12),
        _tally(damage: 10, significantStrikes: 10),
      );
      expect(oneDrop, lessThan(JudgePanel.tenEightBar),
          reason: 'a knockdown in a competitive round is a 10-9');

      final twoDrops = JudgePanel.dominanceOf(
        _tally(knockdowns: 2, damage: 40, significantStrikes: 20),
        _tally(damage: 3),
      );
      expect(twoDrops, greaterThan(JudgePanel.tenEightBar));
    });

    test('control alone never gets near the bar', () {
      final grind = JudgePanel.dominanceOf(
        _tally(controlValue: 300, takedowns: 4, damage: 6),
        _tally(),
      );
      expect(grind, lessThan(JudgePanel.tenEightBar));
    });

    test('trading heavily and winning scores lower than a one-way beating',
        () {
      final shootout = JudgePanel.dominanceOf(
        _tally(damage: 55, significantStrikes: 40, knockdowns: 1),
        _tally(damage: 35, significantStrikes: 30),
      );
      final beating = JudgePanel.dominanceOf(
        _tally(damage: 55, significantStrikes: 40, knockdowns: 1),
        _tally(damage: 3, significantStrikes: 2),
      );
      expect(shootout, lessThan(beating));
    });
  });

  test('judges disagree about marginal 10-8s but not obvious ones', () {
    // Two knockdowns and nothing coming back is unanimous.
    final obvious = _tenEights(
      _tally(knockdowns: 2, damage: 60, significantStrikes: 30,
          controlValue: 200, nearFinishes: 2),
      _tally(damage: 1),
    );
    expect(obvious, 3);

    // A round scoring between the most lenient and the strictest bar is
    // marginal by construction — some judges should write it 10-8 and
    // some 10-9. Sweep damage to find such rounds rather than hard-coding
    // a tally whose score would drift with the curve.
    var split = 0;
    var marginalRoundsTried = 0;
    for (var damage = 30; damage <= 70; damage += 2) {
      final winner = _tally(
        damage: damage.toDouble(),
        significantStrikes: 30,
        knockdowns: 1,
        controlValue: 140,
        nearFinishes: 1,
      );
      final loser = _tally(damage: 4, significantStrikes: 3);
      final score = JudgePanel.dominanceOf(winner, loser);
      if (score < JudgePanel.tenEightBar ||
          score > JudgePanel.tenEightBar + JudgePanel.tenEightBarSpread) {
        continue;
      }
      marginalRoundsTried++;
      for (var seed = 0; seed < 25; seed++) {
        final n = _tenEights(winner, loser, seed: seed);
        if (n > 0 && n < 3) split++;
      }
    }

    expect(marginalRoundsTried, greaterThan(0),
        reason: 'the sweep should have produced some borderline rounds');
    expect(split, greaterThan(0),
        reason: 'a marginal 10-8 should land on some cards and not others');
  });
}
