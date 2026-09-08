import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Money used to be a scoreboard: it only ever went up, nothing was spent
/// between events, and there was no floor to fall through. These cover
/// the three things that give it teeth.
void main() {
  Fighter signed(String id, String name, {int fightsRemaining = 4}) =>
      testFighter(id, stat: 70).copyWith(
        name: name,
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: fightsRemaining,
          showMoney: 1000,
          winBonus: 1000,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      );

  Future<GameController> controllerWith(List<Fighter> roster) async {
    final controller = GameController.inMemory(random: Random(4));
    await controller.startNewGame(
      orgName: 'Pressure FC',
      tier: ReputationTier.regional,
      signRoster: false,
    );
    for (final fighter in roster) {
      await controller.saveFighter(fighter);
    }
    return controller;
  }

  group('weekly overheads', () {
    test('a week that does nothing still costs money', () async {
      final controller = await controllerWith([signed('a', 'Fighter A')]);
      final before = controller.organization!.cashBalance;
      final expected = controller.weeklyOverhead;

      await controller.advanceWeek();

      expect(expected, greaterThan(0));
      expect(controller.organization!.cashBalance, before - expected,
          reason: 'sitting still has to cost something, or a card never '
              'has to be worth putting on');
      controller.dispose();
    });

    test('a bigger roster costs more to keep', () async {
      final small = await controllerWith([signed('a', 'A')]);
      final large = await controllerWith([
        for (var i = 0; i < 20; i++) signed('f$i', 'Fighter $i'),
      ]);

      expect(large.weeklyOverhead, greaterThan(small.weeklyOverhead),
          reason: 'a roster you never book should be one you pay for');

      small.dispose();
      large.dispose();
    });

    test('releasing fighters cuts the bill', () async {
      final controller = await controllerWith([
        for (var i = 0; i < 10; i++) signed('f$i', 'Fighter $i'),
      ]);
      final before = controller.weeklyOverhead;

      for (var i = 0; i < 5; i++) {
        await controller.releaseFighter('f$i');
      }

      expect(controller.weeklyOverhead, lessThan(before));
      controller.dispose();
    });
  });

  group('the debt ceiling', () {
    /// A promotion that never runs a card, left to bleed. Local tier
    /// because its opening cash is smallest, so the slide is short
    /// enough to actually play out in a test — and this drives the real
    /// mechanism rather than poking the balance directly.
    Future<GameController> idleUntilCutOff({int maxWeeks = 200}) async {
      final controller = GameController.inMemory(random: Random(4));
      await controller.startNewGame(
        orgName: 'Bleeding FC',
        tier: ReputationTier.local,
      );
      for (var week = 0; week < maxWeeks; week++) {
        if (controller.isOverextended) break;
        await controller.advanceWeek();
      }
      return controller;
    }

    test('overheads alone will eventually get you cut off', () async {
      final controller = await idleUntilCutOff();

      expect(controller.isOverextended, isTrue,
          reason: 'doing nothing for years should end the promotion');
      expect(controller.organization!.cashBalance,
          lessThan(controller.debtCeiling));
      controller.dispose();
    });

    test('past the ceiling, nothing new can be booked', () async {
      final controller = await idleUntilCutOff();
      final roster = controller.signedRoster.take(2).toList();
      expect(roster, hasLength(2));

      final error = await controller.bookEvent(
        name: 'One More',
        date: GameCalendar.dateForWeek(controller.organization!.currentWeek + 2),
        venue: Venue.regionalUsa,
        ticketPrice: 50,
        card: [
          Fight(
            id: 'f1',
            eventId: '',
            fighterAId: roster[0].id,
            fighterBId: roster[1].id,
            weightClass: roster[0].weightClass,
            cardOrder: 0,
            isMainEvent: true,
            rounds: 3,
          ),
        ],
      );

      expect(error, isNotNull);
      expect(error, contains('bank'));
      expect(controller.scheduledEvents, isEmpty);
      controller.dispose();
    });

    test('debt is pressure, not a wall, until the ceiling', () async {
      final controller = GameController.inMemory(random: Random(4));
      await controller.startNewGame(
        orgName: 'Struggling FC',
        tier: ReputationTier.local,
      );
      // Far enough to be in the red, not far enough to be cut off.
      while (controller.organization!.cashBalance > 0) {
        await controller.advanceWeek();
      }

      expect(controller.organization!.cashBalance, lessThan(0));
      expect(controller.isOverextended, isFalse);

      final roster = controller.signedRoster.take(2).toList();
      final error = await controller.bookEvent(
        name: 'Still Going',
        date: GameCalendar.dateForWeek(controller.organization!.currentWeek + 2),
        venue: Venue.regionalUsa,
        ticketPrice: 50,
        card: [
          Fight(
            id: 'f1',
            eventId: '',
            fighterAId: roster[0].id,
            fighterBId: roster[1].id,
            weightClass: roster[0].weightClass,
            cardOrder: 0,
            isMainEvent: true,
            rounds: 3,
          ),
        ],
      );

      expect(error, isNull,
          reason: 'running a card is how you dig out — being in debt must '
              'not block the only way back');
      controller.dispose();
    });
  });

  group('contracts running out', () {
    Future<void> runOneFight(GameController controller) async {
      final week = controller.organization!.currentWeek;
      final error = await controller.bookEvent(
        name: 'Fight Night',
        date: GameCalendar.dateForWeek(week + 1),
        venue: Venue.regionalUsa,
        ticketPrice: 50,
        card: const [
          Fight(
            id: 'f1',
            eventId: '',
            fighterAId: 'a',
            fighterBId: 'b',
            weightClass: WeightClass.lightweight,
            cardOrder: 0,
            isMainEvent: true,
            rounds: 3,
          ),
        ],
      );
      expect(error, isNull);
      await controller.advanceWeek();
      final event = controller.scheduledEvents.single;
      expect(
        await controller.simulateEvent(event.id, promotionBudgetSpent: 0),
        isNotNull,
      );
    }

    test('a deal you let run out costs you the fighter', () async {
      final controller = await controllerWith([
        signed('a', 'Fighter A', fightsRemaining: 1),
        signed('b', 'Fighter B', fightsRemaining: 5),
      ]);
      // Auto-re-sign is on by default now — this is the behaviour for a
      // player who has turned it off to work their own contracts.
      await controller.setAutoResignFighters(false);

      await runOneFight(controller);

      final a = controller.fighterById('a')!;
      expect(a.contract, isNull);
      expect(a.isSigned, isFalse,
          reason: 'an expired contract used to be a note in the mailbox and '
              'nothing else, which left the whole contract system without '
              'a consequence');
      expect(controller.talentPool.any((f) => f.id == 'a'), isTrue,
          reason: 'they are a free agent, not deleted');
      expect(controller.signedRoster.any((f) => f.id == 'b'), isTrue,
          reason: 'the fighter with fights left is untouched');

      controller.dispose();
    });

    test('losing them cuts the weekly bill too', () async {
      final controller = await controllerWith([
        signed('a', 'Fighter A', fightsRemaining: 1),
        signed('b', 'Fighter B', fightsRemaining: 5),
      ]);
      await controller.setAutoResignFighters(false);
      final before = controller.weeklyOverhead;

      await runOneFight(controller);

      expect(controller.weeklyOverhead, lessThan(before));
      controller.dispose();
    });

    test('with auto re-sign on they stay, on a new deal', () async {
      final controller = await controllerWith([
        signed('a', 'Fighter A', fightsRemaining: 1),
        signed('b', 'Fighter B', fightsRemaining: 5),
      ]);
      await controller.setAutoResignFighters(true);

      await runOneFight(controller);

      final a = controller.fighterById('a')!;
      expect(a.isSigned, isTrue);
      expect(a.contract!.fightsRemaining, greaterThan(0));
      controller.dispose();
    });
  });
}
