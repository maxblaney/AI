import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/events/random_event_engine.dart';

Fighter _signedFighter({
  InjuryStatus injuryStatus = InjuryStatus.healthy,
  int morale = 70,
  int payPerFight = 2000,
}) {
  return Fighter(
    id: 'f1',
    name: 'Test Fighter',
    age: 27,
    nationality: 'USA',
    weightClass: WeightClass.lightweight,
    heightInches: 70,
    weightLbs: 155,
    record: const FightRecord(wins: 5, losses: 1),
    fightingStats: const FightingStats(
      punching: 70,
      kicking: 70,
      power: 70,
      speed: 70,
      accuracy: 70,
      defense: 70,
      takedowns: 70,
      takedownDefense: 70,
      wrestling: 70,
      groundAndPound: 70,
      submissionOffense: 70,
      submissionDefense: 70,
      grappling: 70,
    ),
    physicalStats: const PhysicalStats(
      cardio: 70,
      durability: 70,
      chin: 70,
      bodyToughness: 70,
      legToughness: 70,
      strength: 70,
      athleticism: 70,
      recovery: 70,
    ),
    mentalStats: const MentalStats(
      fightIq: 70,
      composure: 70,
      aggression: 70,
      discipline: 70,
      confidence: 70,
      heart: 70,
      adaptability: 70,
    ),
    style: FightingStyle.wellRounded,
    tendencies: const Tendencies(
      strikingFrequency: 50,
      takedownFrequency: 50,
      kickFrequency: 50,
      clinchFrequency: 50,
      submissionAttempts: 50,
      groundAndPound: 50,
      aggression: 50,
      counterStriking: 50,
      headHunting: 50,
      bodyAttacks: 50,
      legAttacks: 50,
    ),
    potential: 75,
    popularity: 40,
    morale: morale,
    injuryStatus: injuryStatus,
    winStreak: 1,
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
