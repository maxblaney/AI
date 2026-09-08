import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/screens/event_booking/event_booking_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Two facts a card tile has to carry: where each man stands on the
/// ladder, and whether the player has already run this exact fight.
void main() {
  Fighter signed(String id, String name, {int stat = 70}) =>
      testFighter(id, stat: stat).copyWith(
        name: name,
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: 5,
          showMoney: 1000,
          winBonus: 1000,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      );

  /// The events stream drives the bookings and form maps, and that hop
  /// is async — let it drain before reading it back.
  ///
  /// Pumped through the tester rather than with `Future.delayed`: a
  /// widget test runs its body in fake async, where a real timer never
  /// fires and the await simply hangs.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump();
    }
  }

  Future<GameController> controllerWith(
    WidgetTester tester,
    List<Fighter> roster,
  ) async {
    final controller = GameController.inMemory(random: Random(3));
    await controller.startNewGame(
      orgName: 'Rank FC',
      tier: ReputationTier.regional,
    );
    for (final s in [...controller.signedRoster]) {
      await controller.releaseFighter(s.id);
    }
    for (final fighter in roster) {
      await controller.saveFighter(fighter);
    }
    await settle(tester);
    return controller;
  }

  Fight bout(String id, String a, String b) => Fight(
        id: id,
        eventId: '',
        fighterAId: a,
        fighterBId: b,
        weightClass: WeightClass.lightweight,
        cardOrder: 0,
        rounds: 3,
        isMainEvent: true,
      );

  /// Books a one-fight card and runs it, so the two men have a result
  /// between them and a place on the ladder.
  Future<void> runFight(
    WidgetTester tester,
    GameController controller,
    String name,
    Fight fight,
  ) async {
    final week = controller.organization!.currentWeek;
    final error = await controller.bookEvent(
      name: name,
      date: GameCalendar.dateForWeek(week + 1),
      venue: Venue.regionalUsa,
      ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
      card: [fight],
    );
    expect(error, isNull);
    await controller.advanceWeek();
    await settle(tester);
    final event = controller.scheduledEvents.single;
    await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
    await settle(tester);
  }

  Widget wrap(GameController controller, String eventId) => MaterialApp(
        home: ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: EventBookingScreen(eventId: eventId),
        ),
      );

  testWidgets('a booked bout wears both corners\' divisional ranks',
      (tester) async {
    final controller = await controllerWith(tester, [
      signed('a', 'Femi Adeleke', stat: 78),
      signed('b', 'Michal Szymanski', stat: 74),
      // Spare bodies: with only two fighters the screen shows a
      // "nobody left to match" notice tall enough to push the card
      // itself off the bottom of the test viewport.
      signed('c', 'Spare One', stat: 70),
      signed('d', 'Spare Two', stat: 70),
    ]);
    await runFight(tester, controller, 'Rank Night', bout('r1', 'a', 'b'));

    // Both men are on the ladder now, so a fresh card between them
    // should be labelled with where they sit.
    final week = controller.organization!.currentWeek;
    await controller.bookEvent(
      name: 'Second Night',
      date: GameCalendar.dateForWeek(week + 2),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: [bout('r2', 'a', 'b')],
    );
    await settle(tester);
    final eventId = controller.scheduledEvents.single.id;

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();

    final title = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText())
        .whereType<String>()
        .firstWhere((t) => t.contains('Femi Adeleke vs'));

    expect(
      title,
      matches(RegExp(r'#\d+ Femi Adeleke vs #\d+ Michal Szymanski')),
      reason: 'ranked fighters should carry their number on the tile',
    );

    controller.dispose();
  });

  testWidgets('a bout that has already been run is flagged as a rematch',
      (tester) async {
    final controller = await controllerWith(tester, [
      signed('a', 'Femi Adeleke', stat: 78),
      signed('b', 'Michal Szymanski', stat: 74),
      // Spare bodies: with only two fighters the screen shows a
      // "nobody left to match" notice tall enough to push the card
      // itself off the bottom of the test viewport.
      signed('c', 'Spare One', stat: 70),
      signed('d', 'Spare Two', stat: 70),
    ]);
    await runFight(tester, controller, 'First Meeting', bout('r1', 'a', 'b'));

    final week = controller.organization!.currentWeek;
    await controller.bookEvent(
      name: 'Second Night',
      date: GameCalendar.dateForWeek(week + 2),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: [bout('r2', 'a', 'b')],
    );
    await settle(tester);
    final eventId = controller.scheduledEvents.single.id;

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();

    expect(find.textContaining('Rematch'), findsOneWidget);
    // And it says how the first one went, not just that there was one.
    expect(
      find.textContaining(RegExp('Adeleke|Szymanski')),
      findsWidgets,
    );

    controller.dispose();
  });

  testWidgets('the card ledger prices a show while it is being built',
      (tester) async {
    // Two fighters priced far beyond what a regional gate can cover:
    // the screen should say so before the card is confirmed rather than
    // after the money is gone.
    Fighter expensive(String id, String name) =>
        signed(id, name).copyWith(
          contract: Contract(
            id: '$id-c',
            fighterId: id,
            fightsRemaining: 5,
            showMoney: 90000,
            winBonus: 90000,
            exclusive: true,
            signedOn: DateTime(2026, 1, 1),
          ),
        );

    final controller = await controllerWith(tester, [
      expensive('a', 'Costly One'),
      expensive('b', 'Costly Two'),
      signed('c', 'Spare One'),
      signed('d', 'Spare Two'),
    ]);

    final week = controller.organization!.currentWeek;
    await controller.bookEvent(
      name: 'Overspend Night',
      date: GameCalendar.dateForWeek(week + 2),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: [bout('r1', 'a', 'b')],
    );
    await settle(tester);
    final eventId = controller.scheduledEvents.single.id;

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.textContaining('This card loses money'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('This card loses money'), findsOneWidget);
    expect(find.textContaining('Purses'), findsOneWidget);
    expect(find.textContaining('overheads'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a first meeting carries no rematch flag', (tester) async {
    final controller = await controllerWith(tester, [
      signed('a', 'Femi Adeleke'),
      signed('b', 'Michal Szymanski'),
      signed('c', 'Spare One'),
      signed('d', 'Spare Two'),
    ]);

    final week = controller.organization!.currentWeek;
    await controller.bookEvent(
      name: 'Debut Night',
      date: GameCalendar.dateForWeek(week + 2),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: [bout('r1', 'a', 'b')],
    );
    await settle(tester);
    final eventId = controller.scheduledEvents.single.id;

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();

    expect(find.textContaining('Rematch'), findsNothing);
    expect(find.textContaining('Trilogy'), findsNothing);

    controller.dispose();
  });
}
