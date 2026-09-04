import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/screens/event_booking/event_booking_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// A card booked weeks out is a plan, not a commitment — these cover
/// reopening one and changing it.
void main() {
  Fighter signed(String id, String name) => testFighter(id, stat: 70).copyWith(
        name: name,
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: 3,
          showMoney: 1000,
          winBonus: 1000,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      );

  Future<GameController> controllerWith(List<Fighter> roster) async {
    final controller = GameController.inMemory(random: Random(7));
    await controller.startNewGame(
      orgName: 'Edit FC',
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

  /// The events stream drives the bookings map, and that hop is async —
  /// let the microtask queue drain before reading it back.
  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Fight fight(
    String id,
    String a,
    String b, {
    bool main = false,
    bool coMain = false,
    int order = 0,
  }) =>
      Fight(
        id: id,
        eventId: '',
        fighterAId: a,
        fighterBId: b,
        weightClass: WeightClass.lightweight,
        cardOrder: order,
        isMainEvent: main,
        isCoMainEvent: coMain,
        rounds: main ? 5 : 3,
      );

  Future<String> bookThreeFightCard(GameController controller) async {
    final week = controller.organization!.currentWeek;
    final error = await controller.bookEvent(
      name: 'Original Night',
      date: GameCalendar.dateForWeek(week + 4),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: [
        fight('f1', 'a', 'b', main: true, order: 0),
        fight('f2', 'c', 'd', coMain: true, order: 1),
        fight('f3', 'e', 'f', order: 2),
      ],
    );
    expect(error, isNull);
    return controller.scheduledEvents.single.id;
  }

  group('updateEvent', () {
    late GameController controller;

    setUp(() async {
      controller = await controllerWith([
        for (final id in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
          signed(id, 'Fighter ${id.toUpperCase()}'),
      ]);
    });

    tearDown(() => controller.dispose());

    test('rewrites the card in place, keeping the same event', () async {
      final eventId = await bookThreeFightCard(controller);
      final before = await controller.getEventCard(eventId);
      expect(before, hasLength(3));

      final error = await controller.updateEvent(
        eventId: eventId,
        name: 'Renamed Night',
        date: GameCalendar.dateForWeek(
            controller.organization!.currentWeek + 6),
        venue: Venue.newYorkNy,
        ticketPrice: 90,
        card: [
          fight('f1', 'a', 'b', main: true, order: 0),
          fight('f4', 'g', 'h', order: 1),
        ],
      );

      expect(error, isNull);
      expect(controller.scheduledEvents, hasLength(1),
          reason: 'editing changes the event, it does not make a second one');

      final event = controller.scheduledEvents.single;
      expect(event.id, eventId);
      expect(event.name, 'Renamed Night');
      expect(event.venue, Venue.newYorkNy);
      expect(event.ticketPrice, 90);

      final after = await controller.getEventCard(eventId);
      expect(after.map((f) => f.id), ['f1', 'f4']);
    });

    test('a bout taken off the card stops holding its fighters', () async {
      final eventId = await bookThreeFightCard(controller);
      await settle();
      expect(controller.bookingsByFighterId.containsKey('c'), isTrue);

      await controller.updateEvent(
        eventId: eventId,
        name: 'Trimmed Night',
        date: GameCalendar.dateForWeek(
            controller.organization!.currentWeek + 4),
        venue: Venue.regionalUsa,
        ticketPrice: 50,
        card: [fight('f1', 'a', 'b', main: true, order: 0)],
      );
      await settle();

      // Dropped from the card means dropped from the database, or the
      // fighters would stay booked against a fight nobody can find.
      expect(controller.bookingsByFighterId.containsKey('c'), isFalse);
      expect(controller.bookingsByFighterId.containsKey('a'), isTrue);
    });

    test('the same rules that guard booking guard editing', () async {
      final eventId = await bookThreeFightCard(controller);
      final week = controller.organization!.currentWeek;

      expect(
        await controller.updateEvent(
          eventId: eventId,
          name: 'Empty Night',
          date: GameCalendar.dateForWeek(week + 4),
          venue: Venue.regionalUsa,
          ticketPrice: 50,
          card: const [],
        ),
        'Add at least one fight to the card.',
      );

      expect(
        await controller.updateEvent(
          eventId: eventId,
          name: 'Headless Night',
          date: GameCalendar.dateForWeek(week + 4),
          venue: Venue.regionalUsa,
          ticketPrice: 50,
          card: [fight('f1', 'a', 'b', order: 0)],
        ),
        'Pick a main event.',
      );

      // An event can't be dragged into a week that has already happened.
      expect(
        await controller.updateEvent(
          eventId: eventId,
          name: 'Yesterday Night',
          date: GameCalendar.dateForWeek(week),
          venue: Venue.regionalUsa,
          ticketPrice: 50,
          card: [fight('f1', 'a', 'b', main: true, order: 0)],
        ),
        'Event date must be in a future week.',
      );

      // None of the rejections touched the stored card.
      expect(await controller.getEventCard(eventId), hasLength(3));
    });

    test('an event that has already run cannot be rewritten', () async {
      final eventId = await bookThreeFightCard(controller);
      for (var i = 0; i < 4; i++) {
        await controller.advanceWeek();
      }
      final summary =
          await controller.simulateEvent(eventId, promotionBudgetSpent: 0);
      expect(summary, isNotNull, reason: 'the event should have run');

      expect(
        await controller.updateEvent(
          eventId: eventId,
          name: 'Do-Over',
          date: GameCalendar.dateForWeek(
              controller.organization!.currentWeek + 2),
          venue: Venue.regionalUsa,
          ticketPrice: 50,
          card: [fight('f1', 'a', 'b', main: true, order: 0)],
        ),
        'That event has already run.',
      );
    });
  });

  testWidgets('the booking screen reopens a booked card filled in',
      (tester) async {
    final controller = await controllerWith([
      for (final id in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
        signed(id, 'Fighter ${id.toUpperCase()}'),
    ]);
    final eventId = await bookThreeFightCard(controller);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: EventBookingScreen(eventId: eventId),
      ),
    ));
    await tester.pumpAndSettle();

    // The screen knows it is editing, and the card came back with it.
    expect(find.text('Edit Card'), findsOneWidget);
    expect(find.text('Fighter A vs Fighter B'), findsOneWidget);
    expect(find.text('Fighter C vs Fighter D'), findsOneWidget);
    expect(find.text('Fighter E vs Fighter F'), findsOneWidget);
    // Including which bout was the main event, and which the co-main.
    expect(find.textContaining('· Main Event'), findsOneWidget);
    expect(find.textContaining('· Co-Main Event'), findsOneWidget);

    // Drop the last bout and save. Both the card's lower tiles and the
    // save button sit below the fold, so scroll to them first.
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Fighter E vs Fighter F'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Save Card'));
    await tester.pumpAndSettle();

    final card = await controller.getEventCard(eventId);
    expect(card, hasLength(2));
    expect(controller.scheduledEvents, hasLength(1));

    controller.dispose();
  });
}
