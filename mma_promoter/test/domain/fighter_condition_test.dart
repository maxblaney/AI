import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/condition/fighter_condition.dart';

import '../support/fighter_fixtures.dart';

Fighter _at({int condition = 100, InjuryStatus injury = InjuryStatus.healthy}) =>
    testFighter('f').copyWith(condition: condition, injuryStatus: injury);

void main() {
  group('condition', () {
    test('reads across all five tiers', () {
      expect(FighterConditionCalculator.conditionOf(_at(condition: 100)),
          FighterCondition.peak);
      expect(FighterConditionCalculator.conditionOf(_at(condition: 70)),
          FighterCondition.healthy);
      expect(FighterConditionCalculator.conditionOf(_at(condition: 30)),
          FighterCondition.inShape);
      expect(
        FighterConditionCalculator.conditionOf(
            _at(injury: InjuryStatus.minor)),
        FighterCondition.injured,
      );
      expect(
        FighterConditionCalculator.conditionOf(
            _at(injury: InjuryStatus.major)),
        FighterCondition.battered,
      );
    });

    test('an injury outranks freshness', () {
      // Fully rested but hurt still reads as injured, not Peak.
      final rested = _at(condition: 100, injury: InjuryStatus.minor);
      expect(FighterConditionCalculator.conditionOf(rested),
          FighterCondition.injured);
    });

    test('labels match the requested wording', () {
      expect(
        FighterCondition.values.map((c) => c.label),
        ['Peak', 'Healthy', 'In-Shape', 'Injured', 'Battered'],
      );
    });

    test('a long, finished fight costs more than a short decision', () {
      final quick = FighterConditionCalculator.conditionAfterFight(
          current: 100, roundsFought: 1, wasFinished: true);
      final war = FighterConditionCalculator.conditionAfterFight(
          current: 100, roundsFought: 5, wasFinished: false);

      expect(war, lessThan(quick));
      expect(quick, lessThan(100), reason: 'every fight costs something');
    });

    test('condition never leaves 0-100', () {
      expect(
        FighterConditionCalculator.conditionAfterFight(
            current: 5, roundsFought: 5, wasFinished: true),
        0,
      );
      expect(FighterConditionCalculator.conditionAfterRest(99), 100);
      expect(FighterConditionCalculator.conditionAfterRest(100), 100);
    });

    test('rest recovers a worn fighter over a few weeks', () {
      var condition = 40;
      for (var week = 0; week < 10; week++) {
        condition = FighterConditionCalculator.conditionAfterRest(condition);
      }
      expect(condition, 100);
    });
  });

  group('sharpness', () {
    test('labels match the requested wording', () {
      expect(
        Sharpness.values.map((s) => s.label),
        ['Sharp', 'Prepared', 'Uneasy', 'Not Prepared', 'Out of Shape'],
      );
    });

    test('camp length drives every tier', () {
      Sharpness at(int weeks) => FighterConditionCalculator.sharpnessOf(
            _at(),
            campWeeks: weeks,
          );

      expect(at(10), Sharpness.sharp);
      expect(at(8), Sharpness.sharp);
      expect(at(6), Sharpness.prepared);
      expect(at(4), Sharpness.uneasy);
      expect(at(2), Sharpness.notPrepared);
      expect(at(1), Sharpness.outOfShape);
      expect(at(0), Sharpness.outOfShape,
          reason: 'a fight booked for this week is pure short notice');
    });

    test('a shorter camp is never sharper than a longer one', () {
      final order = [
        for (var w = 0; w <= 12; w++)
          FighterConditionCalculator.sharpnessOf(_at(), campWeeks: w).index,
      ];
      for (var i = 1; i < order.length; i++) {
        expect(order[i], lessThanOrEqualTo(order[i - 1]),
            reason: 'sharpness should improve monotonically with camp time');
      }
    });

    test('an unbooked fighter goes stale the longer they sit out', () {
      Sharpness idle(int weeks) => FighterConditionCalculator.sharpnessOf(
            _at(),
            weeksSinceLastFight: weeks,
          );

      expect(idle(4), Sharpness.prepared);
      expect(idle(20), Sharpness.uneasy);
      expect(idle(40), Sharpness.notPrepared);
      expect(idle(80), Sharpness.outOfShape);
    });

    test('nobody is Sharp without an actual camp', () {
      // Sharp is earned in a full camp, not by sitting in the gym.
      for (final weeks in [0, 1, 4, 12, 30, 100]) {
        expect(
          FighterConditionCalculator.sharpnessOf(_at(),
              weeksSinceLastFight: weeks),
          isNot(Sharpness.sharp),
        );
      }
    });

    test('a fighter with no history and no booking reads as Prepared', () {
      expect(FighterConditionCalculator.sharpnessOf(_at()),
          Sharpness.prepared);
    });
  });
}
