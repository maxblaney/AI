import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/scouting/division_needs.dart';

import '../support/fighter_fixtures.dart';

List<Fighter> _at(WeightClass division, int count) => [
      for (var i = 0; i < count; i++)
        testFighter('$division-$i', stat: 70).copyWith(weightClass: division),
    ];

void main() {
  group('DivisionNeeds', () {
    test('grades a division by how much matchmaking it allows', () {
      expect(DivisionNeeds.needFor(0), DivisionNeed.empty);
      expect(DivisionNeeds.needFor(2), DivisionNeed.critical);
      expect(DivisionNeeds.needFor(5), DivisionNeed.thin);
      expect(DivisionNeeds.needFor(20), DivisionNeed.fine);
    });

    test('a healthy promotion has nothing to report', () {
      final roster = [
        for (final w in WeightClass.values) ..._at(w, 12),
      ];
      expect(DivisionNeeds.shortages(roster), isEmpty);
    });

    test('shortages come back worst first', () {
      final roster = [
        ..._at(WeightClass.lightweight, 6), // thin
        ..._at(WeightClass.welterweight, 2), // critical
        ..._at(WeightClass.heavyweight, 20), // fine
        // flyweight and the rest: empty
      ];

      final shortages = DivisionNeeds.shortages(roster);
      expect(shortages.first.need, DivisionNeed.empty);
      expect(shortages.map((s) => s.division),
          isNot(contains(WeightClass.heavyweight)));

      final welter =
          shortages.firstWhere((s) => s.division == WeightClass.welterweight);
      expect(welter.need, DivisionNeed.critical);
      expect(welter.count, 2);

      final light =
          shortages.firstWhere((s) => s.division == WeightClass.lightweight);
      expect(light.need, DivisionNeed.thin);

      // Worst first: an empty division outranks a critical one, which
      // outranks a thin one.
      final severities = shortages.map((s) => s.need.index).toList();
      expect(severities, orderedEquals([...severities]..sort()));
    });

    test('every division is accounted for, healthy ones included', () {
      final assessed = DivisionNeeds.assess(_at(WeightClass.lightweight, 3));
      expect(assessed.keys.length, WeightClass.values.length);
      expect(assessed[WeightClass.lightweight]!.count, 3);
      expect(assessed[WeightClass.heavyweight]!.need, DivisionNeed.empty);
    });
  });
}
