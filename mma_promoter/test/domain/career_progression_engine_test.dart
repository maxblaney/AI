import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/career/career_progression_engine.dart';

import '../support/fighter_fixtures.dart';

Fighter _fighter({
  int age = 27,
  int potential = 70,
  int winStreak = 0,
  int lossStreak = 0,
  InjuryStatus injuryStatus = InjuryStatus.healthy,
  bool retired = false,
}) {
  return testFighter(
    'f1',
    stat: 60,
    age: age,
    potential: potential,
    winStreak: winStreak,
    lossStreak: lossStreak,
    injuryStatus: injuryStatus,
    retired: retired,
  );
}

void main() {
  group('CareerProgressionEngine.updateElo', () {
    test('a win raises the winner and lowers the loser, roughly symmetrically', () {
      final engine = CareerProgressionEngine();
      final (newA, newB) = engine.updateElo(1500, 1500, 1.0);

      expect(newA, greaterThan(1500));
      expect(newB, lessThan(1500));
      expect(newA - 1500, -(newB - 1500));
    });

    test('an even draw between equal Elos leaves both unchanged', () {
      final engine = CareerProgressionEngine();
      final (newA, newB) = engine.updateElo(1500, 1500, 0.5);

      expect(newA, 1500);
      expect(newB, 1500);
    });

    test('an upset (huge underdog wins) swings Elo more than a expected result', () {
      final engine = CareerProgressionEngine();
      final (upsetWinner, _) = engine.updateElo(1300, 1700, 1.0);
      final (expectedWinner, _) = engine.updateElo(1700, 1300, 1.0);

      expect(upsetWinner - 1300, greaterThan(expectedWinner - 1700));
    });

    test('beating a 90 is worth far more than beating a 60', () {
      // The whole point: everyone starts at 1500, so without skill in the
      // expectation these two wins paid identically.
      final engine = CareerProgressionEngine();
      final (afterBeatingElite, _) =
          engine.updateElo(1500, 1500, 1.0, overallA: 72, overallB: 90);
      final (afterBeatingJourneyman, _) =
          engine.updateElo(1500, 1500, 1.0, overallA: 72, overallB: 60);

      final eliteGain = afterBeatingElite - 1500;
      final journeymanGain = afterBeatingJourneyman - 1500;

      expect(eliteGain, 24);
      expect(journeymanGain, 11);
      expect(eliteGain, greaterThanOrEqualTo(journeymanGain * 2),
          reason: 'taking out an elite should not pay like a tune-up');
    });

    test('losing to someone far worse costs more than losing to an elite',
        () {
      final engine = CareerProgressionEngine();
      final (afterLosingToJourneyman, _) =
          engine.updateElo(1500, 1500, 0.0, overallA: 90, overallB: 60);
      final (afterLosingToElite, _) =
          engine.updateElo(1500, 1500, 0.0, overallA: 90, overallB: 95);

      expect(afterLosingToJourneyman, lessThan(afterLosingToElite));
    });

    test('the loser gives up what the winner takes', () {
      final engine = CareerProgressionEngine();
      final (winner, loser) =
          engine.updateElo(1500, 1500, 1.0, overallA: 60, overallB: 90);

      expect(winner - 1500, -(loser - 1500),
          reason: 'Elo is zero-sum however the expectation was set');
    });

    test('two average fighters behave like textbook Elo', () {
      final engine = CareerProgressionEngine();
      final withSkill = engine.updateElo(1500, 1500, 1.0,
          overallA: CareerProgressionEngine.baselineOverall,
          overallB: CareerProgressionEngine.baselineOverall);
      final withoutSkill = engine.updateElo(1500, 1500, 1.0);

      expect(withSkill, withoutSkill);
    });

    test('skill shifts the expectation, not the fighter\'s stored rating',
        () {
      // A 95-overall who has never fought is still on 1500 until they do.
      expect(
        CareerProgressionEngine.effectiveRating(
            1500, CareerProgressionEngine.baselineOverall),
        1500,
      );
      expect(CareerProgressionEngine.effectiveRating(1500, 90),
          greaterThan(1500));
      expect(CareerProgressionEngine.effectiveRating(1500, 50),
          lessThan(1500));
    });
  });

  group('CareerProgressionEngine.adjustPotential', () {
    test('a long win streak nudges potential up', () {
      final engine = CareerProgressionEngine();
      final fighter = _fighter(potential: 70);

      final result = engine.adjustPotential(fighter, winStreak: 4, lossStreak: 0);

      expect(result, 71);
    });

    test('a long losing streak nudges potential down, never below current overall', () {
      final engine = CareerProgressionEngine();
      final fighter = _fighter(potential: 61);

      final result = engine.adjustPotential(fighter, winStreak: 0, lossStreak: 5);

      expect(result, greaterThanOrEqualTo(fighter.overall.round()));
    });

    test('a short streak in either direction leaves potential unchanged', () {
      final engine = CareerProgressionEngine();
      final fighter = _fighter(potential: 70);

      final result = engine.adjustPotential(fighter, winStreak: 1, lossStreak: 0);

      expect(result, 70);
    });
  });

  group('CareerProgressionEngine.maybeRetire', () {
    test('a young, healthy fighter with no losing streak never retires', () {
      final engine = CareerProgressionEngine(random: Random(1));
      final fighter = _fighter(age: 25, lossStreak: 0);

      for (var i = 0; i < 50; i++) {
        expect(engine.maybeRetire(fighter).retired, isFalse);
      }
    });

    test('an old fighter on a long losing streak eventually retires', () {
      final engine = CareerProgressionEngine(random: Random(2));
      final fighter = _fighter(age: 40, lossStreak: 5);

      var retiredSomewhere = false;
      var current = fighter;
      for (var i = 0; i < 30; i++) {
        current = engine.maybeRetire(current);
        if (current.retired) {
          retiredSomewhere = true;
          break;
        }
      }

      expect(retiredSomewhere, isTrue);
    });

    test('an already-retired fighter is returned unchanged', () {
      final engine = CareerProgressionEngine(random: Random(3));
      final fighter = _fighter(age: 45, lossStreak: 10, retired: true);

      final result = engine.maybeRetire(fighter);

      expect(result, same(fighter));
    });

    test('a major injury can force retirement even for a young fighter', () {
      final engine = CareerProgressionEngine(random: Random(4));
      final fighter = _fighter(age: 24, injuryStatus: InjuryStatus.major);

      var retiredSomewhere = false;
      for (var i = 0; i < 100; i++) {
        if (engine.maybeRetire(fighter).retired) {
          retiredSomewhere = true;
          break;
        }
      }

      expect(retiredSomewhere, isTrue);
    });
  });

  group('CareerProgressionEngine.rollHealingWeeks', () {
    test('healthy never gets a countdown', () {
      final engine = CareerProgressionEngine(random: Random(5));
      expect(engine.rollHealingWeeks(InjuryStatus.healthy), 0);
    });

    test('minor injuries heal within a short window', () {
      final engine = CareerProgressionEngine(random: Random(6));
      for (var i = 0; i < 50; i++) {
        final weeks = engine.rollHealingWeeks(InjuryStatus.minor);
        expect(weeks, inInclusiveRange(2, 6));
      }
    });

    test('major injuries take much longer than minor ones', () {
      final engine = CareerProgressionEngine(random: Random(7));
      for (var i = 0; i < 50; i++) {
        final weeks = engine.rollHealingWeeks(InjuryStatus.major);
        expect(weeks, inInclusiveRange(10, 24));
      }
    });
  });
}
