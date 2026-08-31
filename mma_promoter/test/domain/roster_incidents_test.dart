import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/incidents/roster_incidents.dart';

import '../support/fighter_fixtures.dart';

Fighter _signed(String id, {int popularity = 50, int morale = 60}) {
  return testFighter(id, popularity: popularity).copyWith(
    morale: morale,
    contract: Contract(
      id: '$id-contract',
      fighterId: id,
      fightsRemaining: 3,
      showMoney: 5000,
      winBonus: 5000,
      exclusive: true,
      signedOn: DateTime(2026, 1, 1),
    ),
  );
}

void main() {
  final engine = RosterIncidentEngine(random: Random(11));

  Incident generate(IncidentType type, List<Fighter> roster, {int week = 30}) {
    final incident =
        engine.generate(type: type, roster: roster, currentWeek: week);
    expect(incident, isNotNull);
    return incident!;
  }

  group('failed drug test', () {
    test('sits the fighter down for six months', () {
      final incident =
          generate(IncidentType.failedDrugTest, [_signed('a')], week: 30);
      final after = incident.updatedFighters.single;

      expect(after.suspendedUntilWeek,
          30 + RosterIncidentEngine.suspensionWeeks);
      expect(RosterIncidentEngine.suspensionWeeks, 26,
          reason: 'six months, in weeks');
      expect(after.isSuspendedOn(31), isTrue);
      expect(after.isSuspendedOn(55), isTrue);
      // suspendedUntilWeek is the week they're free again, so week 56 is
      // the first one they can be booked on.
      expect(after.isSuspendedOn(56), isFalse);
    });

    test('costs popularity and physical ability', () {
      final before = _signed('a', popularity: 60);
      final after =
          generate(IncidentType.failedDrugTest, [before]).updatedFighters.single;

      expect(after.popularity, lessThan(before.popularity));
      expect(after.physicalStats.strength,
          lessThan(before.physicalStats.strength));
      expect(after.physicalStats.explosiveness,
          lessThan(before.physicalStats.explosiveness));
      expect(after.fightingStats.power, lessThan(before.fightingStats.power));
    });
  });

  test('a DUI hits morale and nothing else', () {
    final before = _signed('a', morale: 70, popularity: 55);
    final after = generate(IncidentType.dui, [before]).updatedFighters.single;

    expect(after.morale, lessThan(before.morale));
    expect(after.popularity, before.popularity);
    expect(after.suspendedUntilWeek, isNull,
        reason: 'a DUI is not a commission matter');
    expect(after.injuryStatus, InjuryStatus.healthy);
  });

  test('a backstage scuffle makes both men more popular', () {
    final a = _signed('a', popularity: 40);
    final b = _signed('b', popularity: 30);
    final incident = generate(IncidentType.backstageAltercation, [a, b]);

    expect(incident.updatedFighters, hasLength(2));
    for (final after in incident.updatedFighters) {
      final before = after.id == 'a' ? a : b;
      expect(after.popularity, greaterThan(before.popularity));
      expect(after.injuryStatus, InjuryStatus.healthy,
          reason: 'nobody actually gets hurt backstage');
    }
  });

  test('a scuffle needs two fighters', () {
    expect(
      engine.generate(
        type: IncidentType.backstageAltercation,
        roster: [_signed('a')],
        currentWeek: 5,
      ),
      isNull,
    );
  });

  test('a freak injury puts them out with a recovery week', () {
    final incident =
        generate(IncidentType.freakInjury, [_signed('a')], week: 12);
    final after = incident.updatedFighters.single;

    expect(after.injuryStatus, isNot(InjuryStatus.healthy));
    expect(after.injuryClearsAtWeek, greaterThan(12));
    expect(after.isAvailableToFight, isFalse);
    expect(incident.body, contains('out for about'));
  });

  group('frequency', () {
    test('stays rare enough to be an event, not a routine', () {
      final roster = [for (var i = 0; i < 12; i++) _signed('f$i')];
      var incidents = 0;
      const weeks = 20000;
      final rolling = RosterIncidentEngine(random: Random(3));
      for (var week = 1; week <= weeks; week++) {
        if (rolling.maybeGenerate(roster: roster, currentWeek: week) != null) {
          incidents++;
        }
      }
      final rate = incidents / weeks;
      // Roughly three stories a year across the whole roster.
      expect(rate, closeTo(RosterIncidentEngine.weeklyChance, 0.01));
      expect(rate, lessThan(0.1),
          reason: 'the user asked for these not to happen too often');
    });

    test('never picks a fighter already serving a ban', () {
      final banned = _signed('banned').copyWith(suspendedUntilWeek: 100);
      final rolling = RosterIncidentEngine(random: Random(4));
      for (var week = 1; week <= 5000; week++) {
        final incident =
            rolling.maybeGenerate(roster: [banned], currentWeek: week);
        if (week < 100) {
          expect(incident, isNull,
              reason: 'a suspended fighter is out of the pool entirely');
        }
      }
    });
  });
}
