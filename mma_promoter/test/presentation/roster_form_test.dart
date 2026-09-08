import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';
import 'package:mma_promoter/presentation/widgets/fighter_list_tile.dart';

import '../support/fighter_fixtures.dart';

/// The roster row now says what a fighter has been doing lately and how
/// big a draw they are, not just what their record is.
void main() {
  Fighter signed(String id, String name, {int popularity = 40}) =>
      testFighter(id, stat: 70, popularity: popularity).copyWith(
        name: name,
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: 4,
          showMoney: 1000,
          winBonus: 1000,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      );

  Future<GameController> controllerWith(List<Fighter> roster) async {
    final controller = GameController.inMemory(random: Random(13));
    await controller.startNewGame(
      orgName: 'Form FC',
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

  Widget wrap(GameController controller, Fighter fighter) => MaterialApp(
        home: ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: Scaffold(body: FighterListTile(fighter: fighter)),
        ),
      );

  testWidgets('popularity reads as a mark out of ten', (tester) async {
    final controller = await controllerWith([
      signed('a', 'Quiet Guy', popularity: 12),
      signed('b', 'Big Draw', popularity: 91),
    ]);

    await tester.pumpWidget(wrap(controller, controller.fighterById('a')!));
    await tester.pumpAndSettle();
    expect(find.text('2/10'), findsOneWidget);

    await tester.pumpWidget(wrap(controller, controller.fighterById('b')!));
    await tester.pumpAndSettle();
    expect(find.text('10/10'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a fighter with no fights here has no form chips',
      (tester) async {
    final controller = await controllerWith([signed('a', 'New Guy')]);

    await tester.pumpWidget(wrap(controller, controller.fighterById('a')!));
    await tester.pumpAndSettle();

    expect(find.text('W'), findsNothing);
    expect(find.text('L'), findsNothing);
    expect(find.text('T'), findsNothing);

    controller.dispose();
  });

  testWidgets('one fight puts a W on the winner and an L on the loser',
      (tester) async {
    final controller = await controllerWith([
      signed('a', 'Fighter A'),
      signed('b', 'Fighter B'),
    ]);

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
    expect(summary, isNotNull);
    // The form map is rebuilt off the events stream. That hop is
    // microtasks only, so it lands on the next pump — a timer-based
    // wait here would hang under the test binding's fake clock.

    final result = summary!.resolvedCard.single.result!;
    final winnerId = result.isDraw ? null : result.winnerId;
    expect(winnerId, isNotNull, reason: 'these two should not have drawn');
    final loserId = winnerId == 'a' ? 'b' : 'a';

    await tester.pumpWidget(
        wrap(controller, controller.fighterById(winnerId!)!));
    await tester.pumpAndSettle();
    expect(find.text('W'), findsOneWidget);
    expect(find.text('L'), findsNothing);

    await tester.pumpWidget(wrap(controller, controller.fighterById(loserId)!));
    await tester.pumpAndSettle();
    expect(find.text('L'), findsOneWidget);
    expect(find.text('W'), findsNothing);

    controller.dispose();
  });
}
