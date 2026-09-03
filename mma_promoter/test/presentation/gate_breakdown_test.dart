import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/booking/card_matchmaker.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/screens/event_result/event_result_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// The results page used to report four numbers and no reasons, so a
/// player could not tell a room that was too big from a ticket that was
/// too dear. These cover the working being shown.
void main() {
  Future<(GameController, String)> runACard({
    int ticketPrice = 55,
    Venue venue = Venue.regionalUsa,
    int promoSpend = 3000,
  }) async {
    final controller = GameController.inMemory(random: Random(3));
    await controller.startNewGame(
      orgName: 'Breakdown FC',
      tier: ReputationTier.regional,
    );
    final week = controller.organization!.currentWeek;
    final card = CardMatchmaker.build(roster: controller.signedRoster, bouts: 6);
    final error = await controller.bookEvent(
      name: 'Fight Night',
      date: GameCalendar.dateForWeek(week + 1),
      venue: venue,
      ticketPrice: ticketPrice,
      card: card,
    );
    expect(error, isNull);
    await controller.advanceWeek();
    final event = controller.scheduledEvents.single;
    expect(
      await controller.simulateEvent(event.id, promotionBudgetSpent: promoSpend),
      isNotNull,
    );
    return (controller, event.id);
  }

  Widget wrap(GameController controller, String eventId) =>
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: MaterialApp(home: EventResultScreen(eventId: eventId)),
      );

  testWidgets('a finished card explains where its crowd came from',
      (tester) async {
    final (controller, eventId) = await runACard();

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();

    expect(find.text('Why this gate'), findsOneWidget);
    await tester.tap(find.text('Why this gate'));
    await tester.pumpAndSettle();

    expect(find.text('WHO CAME'), findsOneWidget);
    expect(find.text('Your following'), findsOneWidget);
    expect(find.text('Main event'), findsOneWidget);
    expect(find.text('Rest of the card'), findsOneWidget);
    expect(find.text('Local walk-up'), findsOneWidget);
    // Promotion spend was real, so it gets a line — twice over, once as
    // heads bought and once as money out.
    expect(find.text('Promotion'), findsNWidgets(2));

    expect(find.text('WHAT IT WAS MULTIPLIED BY'), findsOneWidget);
    expect(find.text('Card depth'), findsOneWidget);
    expect(find.text('Ticket price'), findsOneWidget);

    expect(find.text('THE MONEY'), findsOneWidget);
    expect(find.text('Tickets'), findsOneWidget);
    expect(find.text('Purses'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('the headline names what actually held the gate down',
      (tester) async {
    // Priced well over what this market bears.
    final (controller, eventId) = await runACard(ticketPrice: 160);

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();

    expect(find.text('The ticket was dear for this market'), findsOneWidget,
        reason: 'the point is to name the fix, not just show a number');

    controller.dispose();
  });

  testWidgets('an over-sized room is called out', (tester) async {
    final (controller, eventId) = await runACard(venue: Venue.newYorkNy);

    await tester.pumpWidget(wrap(controller, eventId));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Why this gate'));
    await tester.pumpAndSettle();

    expect(find.textContaining('too big'), findsWidgets,
        reason: 'a regional promotion in an arena should be told so');

    controller.dispose();
  });

  testWidgets('the breakdown survives being read back from storage',
      (tester) async {
    final (controller, eventId) = await runACard();

    // Straight off the stored event rather than the in-memory result —
    // this is what a player sees when they reopen an old card.
    final reloaded = await controller.getEventById(eventId);
    expect(reloaded!.financeBreakdown, isNotNull);
    expect(reloaded.financeBreakdown!.ticketRevenue, greaterThan(0));
    expect(
      reloaded.financeBreakdown!.venueCost + reloaded.financeBreakdown!.purses,
      lessThanOrEqualTo(reloaded.expenses),
    );

    controller.dispose();
  });
}
