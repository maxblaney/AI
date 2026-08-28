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
}
