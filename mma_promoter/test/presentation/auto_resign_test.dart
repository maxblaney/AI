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

  test('off by default, an expired deal is only flagged', () async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 1),
      signed('b', 'Fighter B', fightsRemaining: 3),
    ]);
    expect(controller.organization!.autoResignFighters, isFalse,
        reason: 'managing contracts is the default');

    await runOneFight(controller);

    final a = controller.fighterById('a')!;
    expect(a.contract!.fightsRemaining, 0);
    expect(a.contract!.isExpired, isTrue);
    // Still on the roster — an expired deal is a thing to deal with, not
    // an eviction.
    expect(a.isSigned, isTrue);
    expect(
      controller.inboxItems.any((i) =>
          i.type == InboxItemType.contract && i.title.contains('contract is up')),
      isTrue,
    );

    controller.dispose();
  });

  test('on, the fighter is put straight onto a new deal', () async {
    final controller = await controllerWith([
      signed('a', 'Fighter A', fightsRemaining: 1),
      signed('b', 'Fighter B', fightsRemaining: 3),
    ]);
    await controller.setAutoResignFighters(true);
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

  testWidgets('the settings switch turns it on', (tester) async {
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
    expect(controller.organization!.autoResignFighters, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.organization!.autoResignFighters, isTrue);

    controller.dispose();
  });
}
