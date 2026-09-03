import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/screens/saves/saves_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// A contract counting down to nothing used to just sit at zero. The
/// setting decides what happens when it gets there.
void main() {
  Fighter signed(String id, String name, {required int fightsRemaining}) =>
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
    final controller = GameController.inMemory(random: Random(5));
    await controller.startNewGame(
      orgName: 'Deal FC',
      tier: ReputationTier.regional,
    );
    for (final s in [...controller.signedRoster]) {
      await controller.releaseFighter(s.id);
    }
    for (final fighter in roster) {
      await controller.saveFighter(fighter);
    }
    return controller;
  }

  /// Books a and b against each other and runs the show.
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
    final summary =
        await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
    expect(summary, isNotNull, reason: 'the event should have run');
  }

  test('on by default, so a roster survives being left alone', () async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 1),
      signed('b', 'Fighter B', fightsRemaining: 3),
    ]);

    // The old default was off, and off it quietly ended the game: a
    // measured three-year run went 160 signed to unable to fill a card.
    expect(controller.organization!.autoResignFighters, isTrue,
        reason: 'a default that empties the roster is a trap, not a '
            'difficulty setting');

    await runOneFight(controller);
    expect(controller.fighterById('a')!.isSigned, isTrue);

    controller.dispose();
  });

  test('switched off, a deal you let run out costs you the fighter',
      () async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 1),
      signed('b', 'Fighter B', fightsRemaining: 3),
    ]);
    await controller.setAutoResignFighters(false);

    await runOneFight(controller);

    final a = controller.fighterById('a')!;
    // They leave. An expired contract used to be a mailbox note and
    // nothing else, which left the contract system with no consequence
    // for neglecting it.
    expect(a.contract, isNull);
    expect(a.isSigned, isFalse);
    expect(controller.talentPool.any((f) => f.id == 'a'), isTrue,
        reason: 'a free agent, not deleted');
    expect(
      controller.inboxItems.any((i) =>
          i.type == InboxItemType.contract && i.title.contains('has left')),
      isTrue,
    );

    controller.dispose();
  });

  test('on, the fighter is put straight onto a new deal', () async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 1),
      signed('b', 'Fighter B', fightsRemaining: 3),
    ]);
    expect(controller.organization!.autoResignFighters, isTrue);

    await runOneFight(controller);

    final a = controller.fighterById('a')!;
    expect(a.contract!.isExpired, isFalse);
    expect(a.contract!.fightsRemaining, 4);
    // At market rate rather than the old one — a 70-overall fighter is
    // worth more than the $1,000 this fixture had them on.
    expect(a.contract!.showMoney, greaterThan(1000));
    expect(
      controller.inboxItems.any((i) =>
          i.type == InboxItemType.contract && i.title.contains('re-signed')),
      isTrue,
    );

    // The fighter whose deal still had fights left is untouched.
    expect(controller.fighterById('b')!.contract!.fightsRemaining, 2);

    controller.dispose();
  });

  test('with it off, the mailbox warns a fight before the deal lapses',
      () async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 2),
      signed('b', 'Fighter B', fightsRemaining: 5),
    ]);
    await controller.setAutoResignFighters(false);

    await runOneFight(controller);

    // One fight left now, and nobody has left yet — which is the whole
    // point of saying so at this moment rather than the next one.
    expect(controller.fighterById('a')!.contract!.fightsRemaining, 1);
    expect(controller.fighterById('a')!.isSigned, isTrue);
    expect(
      controller.inboxItems.any((i) =>
          i.type == InboxItemType.contract &&
          i.title.contains('one fight left')),
      isTrue,
    );

    controller.dispose();
  });

  testWidgets('the settings switch turns it off', (tester) async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 2),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: const SavesScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Auto re-sign fighters'), findsOneWidget);
    expect(controller.organization!.autoResignFighters, isTrue);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.organization!.autoResignFighters, isFalse);

    controller.dispose();
  });
}
