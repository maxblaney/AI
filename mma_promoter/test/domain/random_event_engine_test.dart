import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/events/random_event_engine.dart';

import '../support/fighter_fixtures.dart';

Fighter _signedFighter({
  InjuryStatus injuryStatus = InjuryStatus.healthy,
  int morale = 70,
  int payPerFight = 2000,
}) {
  return testFighter(
    'f1',
    stat: 70,
    morale: morale,
    injuryStatus: injuryStatus,
    winStreak: 1,
    record: const FightRecord(wins: 5, losses: 1),
    contract: Contract(
      id: 'c1',
      fighterId: 'f1',
      fightsRemaining: 3,
      payPerFight: payPerFight,
      exclusive: true,
      signedOn: DateTime(2026, 1, 1),
    ),
  );
}

void main() {
  group('RandomEventEngine', () {
    test('never generates events for an empty roster', () {
      final engine = RandomEventEngine(random: Random(1));
      final event = engine.maybeGenerate([], DateTime.now());
      expect(event, isNull);
    });

    test('generated events reference a fighter from the signed roster', () {
      final engine = RandomEventEngine(random: Random(2));
      final fighter = _signedFighter();
      RandomEvent? event;
      for (var i = 0; i < 50 && event == null; i++) {
        event = engine.maybeGenerate([fighter], DateTime.now());
      }
      expect(event, isNotNull);
      expect(event!.affectedFighterId, fighter.id);
      expect(event.choices, isNotEmpty);
    });

    test('rushing recovery improves injury status and costs cash', () {
      final engine = RandomEventEngine(random: Random(3));
      final fighter = _signedFighter(injuryStatus: InjuryStatus.minor);
      final event = RandomEvent(
        id: 'e1',
        type: RandomEventType.injury,
        affectedFighterId: fighter.id,
        headline: 'x',
        description: 'x',
        occurredOn: DateTime.now(),
        choices: const [
          RandomEventChoice(id: 'rush_recovery', label: 'x', consequenceSummary: 'x'),
          RandomEventChoice(id: 'let_them_rest', label: 'x', consequenceSummary: 'x'),
        ],
      );

      final outcome = engine.resolveChoice(event, 'rush_recovery', fighter);

      expect(outcome.updatedFighter.injuryStatus, InjuryStatus.healthy);
      expect(outcome.cashDelta, lessThan(0));
    });

    test('granting a raise increases the fighter\'s per-fight pay', () {
      final engine = RandomEventEngine(random: Random(4));
      final fighter = _signedFighter(payPerFight: 2000);
      final event = RandomEvent(
        id: 'e2',
        type: RandomEventType.contractDispute,
        affectedFighterId: fighter.id,
        headline: 'x',
        description: 'x',
        occurredOn: DateTime.now(),
        choices: const [
          RandomEventChoice(id: 'grant_raise', label: 'x', consequenceSummary: 'x'),
          RandomEventChoice(id: 'hold_firm', label: 'x', consequenceSummary: 'x'),
        ],
      );

      final outcome = engine.resolveChoice(event, 'grant_raise', fighter);

      expect(outcome.updatedFighter.contract!.payPerFight, greaterThan(2000));
    });

    test('holding firm drops morale and leaves pay unchanged', () {
      final engine = RandomEventEngine(random: Random(5));
      final fighter = _signedFighter(morale: 70, payPerFight: 2000);
      final event = RandomEvent(
        id: 'e3',
        type: RandomEventType.contractDispute,
        affectedFighterId: fighter.id,
        headline: 'x',
        description: 'x',
        occurredOn: DateTime.now(),
        choices: const [
          RandomEventChoice(id: 'grant_raise', label: 'x', consequenceSummary: 'x'),
          RandomEventChoice(id: 'hold_firm', label: 'x', consequenceSummary: 'x'),
        ],
      );

      final outcome = engine.resolveChoice(event, 'hold_firm', fighter);

      expect(outcome.updatedFighter.morale, lessThan(70));
      expect(outcome.updatedFighter.contract!.payPerFight, 2000);
    });
  });
}
