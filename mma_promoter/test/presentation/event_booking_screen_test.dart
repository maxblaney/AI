import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/screens/event_booking/event_booking_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// The booking screen decides who the player is even allowed to put in a
/// fight. Two rules live only here — a fighter can cross one division,
/// and a suspended fighter can't be booked at all — so they need to be
/// exercised against the real widget, not just the controller.
Fighter _signed(String id, String name, WeightClass division,
    {int? suspendedUntilWeek}) {
  return testFighter(id, stat: 70).copyWith(
    name: name,
    weightClass: division,
    suspendedUntilWeek: suspendedUntilWeek,
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
}

void main() {
  /// Builds a controller whose signed roster is exactly [roster].
  ///
  /// A new save now opens with 160 fighters already under contract, which
  /// is right for playing but useless here — these tests are about which
  /// fighters the booking screen offers, so they need to own the roster
  /// outright. The seeded contracts are released rather than the seeding
  /// being skipped, so the tests still run against a real new save.
  Future<GameController> controllerWith(List<Fighter> roster) async {
    final controller = GameController.inMemory(random: Random(11));
    await controller.startNewGame(
      orgName: 'Booking FC',
      tier: ReputationTier.regional,
    );
    for (final signed in [...controller.signedRoster]) {
      await controller.releaseFighter(signed.id);
    }
    for (final fighter in roster) {
      await controller.saveFighter(fighter);
    }
    return controller;
  }

  Widget wrap(GameController controller) => MaterialApp(
        home: ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: const EventBookingScreen(),
        ),
      );

  testWidgets('a fighter can be booked one division up', (tester) async {
    final controller = await controllerWith([
      _signed('lw', 'Lightweight Guy', WeightClass.lightweight),
      _signed('ww', 'Welterweight Guy', WeightClass.welterweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Add Fight'), findsOneWidget);
    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();

    // Open the Fighter A picker: both men are offered even though
    // they're in different divisions.
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();

    expect(find.text('Lightweight Guy'), findsWidgets);
    expect(find.text('Welterweight Guy'), findsWidgets);
    // The one crossing over is labelled with the weight he's leaving.
    expect(find.byIcon(Icons.arrow_upward).evaluate().length +
        find.byIcon(Icons.arrow_downward).evaluate().length,
        greaterThan(0),
        reason: 'a fighter moving divisions should be flagged as such');
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('two divisions apart is not offered', (tester) async {
    final controller = await controllerWith([
      _signed('fly', 'Flyweight Guy', WeightClass.flyweight),
      _signed('lw', 'Lightweight Guy', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    // Flyweight to lightweight is two jumps — nobody sanctions that, so
    // there's no division with two available fighters and no fight to make.
    expect(
      find.textContaining('No division has two available fighters'),
      findsOneWidget,
    );

    controller.dispose();
  });

  testWidgets('a suspended fighter cannot be booked', (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Free Man', WeightClass.lightweight),
      _signed('b', 'Banned Man', WeightClass.lightweight,
          suspendedUntilWeek: 500),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('serving a suspension'), findsOneWidget);
    expect(find.text('Banned Man'), findsNothing);

    controller.dispose();
  });

  testWidgets('the matchup preview shows a hype bar once both corners are set',
      (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Fighter A', WeightClass.lightweight),
      _signed('b', 'Fighter B', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();

    // Nothing to rate until there are two corners.
    expect(find.text('HYPE'), findsNothing);

    Future<void> pick(int dropdown, String name) async {
      await tester
          .tap(find.byType(DropdownButtonFormField<String>).at(dropdown));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    await pick(0, 'Fighter A');
    await pick(1, 'Fighter B');

    expect(find.text('HYPE'), findsOneWidget);
    expect(find.text('Stars'), findsOneWidget);
    expect(find.text('Even'), findsOneWidget);
    expect(find.text('Violence'), findsOneWidget);
    expect(find.text('Stakes'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  /// Picks the fighter named [name] in the [index]-th corner dropdown of
  /// an open fight dialog.
  Future<void> pickCorner(WidgetTester tester, int index, String name) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(index));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  /// The booked card sits below the fold of the booking form, and a
  /// ListView only builds what it has laid out — so scroll to it before
  /// looking for fight tiles.
  Future<void> scrollToCard(WidgetTester tester) async {
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
  }

  /// Opens the Add Fight dialog and books [a] against [b].
  Future<void> addFight(WidgetTester tester, String a, String b) async {
    // Scroll back up so the Add Fight button is reachable.
    await tester.drag(find.byType(ListView).first, const Offset(0, 900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();
    await pickCorner(tester, 0, a);
    await pickCorner(tester, 1, b);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    await scrollToCard(tester);
  }

  testWidgets('a booked fight can be edited in place', (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Fighter A', WeightClass.lightweight),
      _signed('b', 'Fighter B', WeightClass.lightweight),
      _signed('c', 'Fighter C', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await addFight(tester, 'Fighter A', 'Fighter B');
    expect(find.text('Fighter A vs Fighter B'), findsOneWidget);

    // Reopen it and swap the second corner.
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Edit Fight'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fighter C').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Fighter A vs Fighter C'), findsOneWidget);
    expect(find.text('Fighter A vs Fighter B'), findsNothing);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('editing keeps the fighters it already had available',
      (tester) async {
    // Both corners are "used" by the fight being edited, so without
    // excluding it from the used set the dialog would offer nobody.
    final controller = await controllerWith([
      _signed('a', 'Fighter A', WeightClass.lightweight),
      _signed('b', 'Fighter B', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await addFight(tester, 'Fighter A', 'Fighter B');
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    expect(find.text('Fighter A'), findsWidgets);
    expect(find.text('Fighter B'), findsWidgets);

    controller.dispose();
  });

  testWidgets('fights can be dragged into a new running order',
      (tester) async {
    final controller = await controllerWith([
      for (final id in ['a', 'b', 'c', 'd'])
        _signed(id, 'Fighter ${id.toUpperCase()}', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await addFight(tester, 'Fighter A', 'Fighter B');
    await addFight(tester, 'Fighter C', 'Fighter D');

    List<String> order() => tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((t) => t.contains(' vs '))
        .toList();

    expect(order(), ['Fighter A vs Fighter B', 'Fighter C vs Fighter D']);

    // Drag the second bout's handle up past the first.
    final handles = find.byIcon(Icons.drag_handle);
    expect(handles, findsNWidgets(2));
    final from = tester.getCenter(handles.last);
    final to = tester.getCenter(handles.first);
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(Offset(to.dx, to.dy - 20));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(order(), ['Fighter C vs Fighter D', 'Fighter A vs Fighter B']);

    controller.dispose();
  });

  testWidgets('the main and co-main stars can be tapped back off',
      (tester) async {
    final controller = await controllerWith([
      for (final id in ['a', 'b', 'c', 'd'])
        _signed(id, 'Fighter ${id.toUpperCase()}', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await addFight(tester, 'Fighter A', 'Fighter B');
    await addFight(tester, 'Fighter C', 'Fighter D');

    // The flags live in each bout's tag line, so match the tag rather
    // than a standalone label — and mind that 'Co-Main Event' contains
    // 'Main Event', which is why both finders include the separator.
    final mainTag = find.textContaining('· Main Event');
    final coMainTag = find.textContaining('· Co-Main Event');

    expect(mainTag, findsNothing);

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();
    expect(mainTag, findsOneWidget);

    // Tapping the filled star again clears it, rather than leaving the
    // player stuck with a choice they made by accident.
    await tester.tap(find.byIcon(Icons.star));
    await tester.pumpAndSettle();
    expect(mainTag, findsNothing);

    // Same for the co-main.
    await tester.tap(find.byIcon(Icons.star_outline).first);
    await tester.pumpAndSettle();
    expect(coMainTag, findsOneWidget);
    await tester.tap(find.byIcon(Icons.star_half));
    await tester.pumpAndSettle();
    expect(coMainTag, findsNothing);

    controller.dispose();
  });

  testWidgets('each booked bout carries its hype score on the card',
      (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Fighter A', WeightClass.lightweight),
      _signed('b', 'Fighter B', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await addFight(tester, 'Fighter A', 'Fighter B');

    // The same reading the booking dialog gives, so the card can be
    // scanned without reopening every bout.
    expect(find.textContaining(RegExp(r'^Hype \d+ · ')), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a champion in his own division forces a title fight',
      (tester) async {
    final controller = await controllerWith([
      _signed('champ', 'The Champion', WeightClass.lightweight)
          .copyWith(belts: {WeightClass.lightweight}),
      _signed('b', 'Fighter B', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();

    // Before either corner is picked nothing is forced.
    expect(find.textContaining('is on the line'), findsNothing);

    await pickCorner(tester, 0, 'The Champion');
    await pickCorner(tester, 1, 'Fighter B');

    expect(find.textContaining('is on the line'), findsOneWidget);
    final titleField =
        tester.widget<DropdownButtonFormField<TitleFightType>>(
            find.byType(DropdownButtonFormField<TitleFightType>));
    expect(titleField.onChanged, isNull,
        reason: 'a champion at home is defending, so the control locks');

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    await scrollToCard(tester);
    expect(find.textContaining('Championship'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a fighter with no history reads as unranked with no form',
      (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Ace Onstreak', WeightClass.lightweight),
      _signed('b', 'Bob Onskid', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();
    await pickCorner(tester, 0, 'Ace Onstreak');
    await pickCorner(tester, 1, 'Bob Onskid');

    expect(find.text('RANK'), findsOneWidget);
    expect(find.text('LAST 5'), findsOneWidget);
    // Neither man has fought for the promotion, so there is nothing to
    // rank them on and nothing to show — and the rows say so rather than
    // sitting blank.
    expect(find.text('Unranked'), findsNWidgets(2));
    expect(find.text('No fights here yet'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('the preview shows divisional rank and the last five results',
      (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Ace Onstreak', WeightClass.lightweight),
      _signed('b', 'Bob Onskid', WeightClass.lightweight),
    ]);

    // Run a real title fight between them so one comes out a champion
    // with a win on his form line and the other a loss — the preview is
    // reading the same fight history the rest of the game does.
    final org = controller.organization!;
    final error = await controller.bookEvent(
      name: 'Fight Night',
      date: GameCalendar.dateForWeek(org.currentWeek + 1),
      venue: Venue.regionalUsa,
      ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
      card: [
        const Fight(
          id: 'f1',
          eventId: '',
          fighterAId: 'a',
          fighterBId: 'b',
          weightClass: WeightClass.lightweight,
          cardOrder: 0,
          isMainEvent: true,
          rounds: 5,
          titleFightType: TitleFightType.championship,
        ),
      ],
    );
    expect(error, isNull, reason: 'booking should succeed');
    await controller.advanceWeek();
    final event = controller.scheduledEvents.single;
    final summary =
        await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
    expect(summary, isNotNull, reason: 'the event should have run');

    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();
    await pickCorner(tester, 0, 'Ace Onstreak');
    await pickCorner(tester, 1, 'Bob Onskid');
    // The form line is loaded from the database, so give it a frame.
    await tester.pumpAndSettle();

    // One of them left with the belt; the other is the only contender.
    expect(find.text('C \u00b7 Lightweight'), findsOneWidget);
    expect(find.text('#1 Lightweight'), findsOneWidget);

    // And both carry exactly one result on the form line.
    expect(find.text('No fights here yet'), findsNothing);
    final chips = find.text('W').evaluate().length +
        find.text('L').evaluate().length +
        find.text('D').evaluate().length;
    expect(chips, 2, reason: 'one fight each, on two form lines');
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('the division being booked is listed before the crossovers',
      (tester) async {
    // Deliberately out of order: the roster comes back in generation
    // order, and a featherweight generated first used to head the list
    // when a lightweight fight was being made.
    final controller = await controllerWith([
      _signed('fw1', 'Aaron Featherweight', WeightClass.featherweight),
      _signed('ww1', 'Adam Welterweight', WeightClass.welterweight),
      _signed('lw2', 'Zeke Lightweight', WeightClass.lightweight),
      _signed('lw1', 'Mark Lightweight', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Fight'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();

    // Read the menu top to bottom by vertical position.
    final names = [
      'Mark Lightweight',
      'Zeke Lightweight',
      'Aaron Featherweight',
      'Adam Welterweight',
    ];
    final offsets = {
      for (final name in names)
        name: tester.getTopLeft(find.text(name).last).dy,
    };

    // Both lightweights sit above both crossovers...
    for (final home in ['Mark Lightweight', 'Zeke Lightweight']) {
      for (final visitor in ['Aaron Featherweight', 'Adam Welterweight']) {
        expect(offsets[home]!, lessThan(offsets[visitor]!),
            reason: '$home should be listed before $visitor');
      }
    }
    // ...alphabetically among themselves, and the lighter crossover
    // group comes before the heavier one.
    expect(offsets['Mark Lightweight']!,
        lessThan(offsets['Zeke Lightweight']!));
    expect(offsets['Aaron Featherweight']!,
        lessThan(offsets['Adam Welterweight']!));

    controller.dispose();
  });

  testWidgets('auto-fill builds a card out of who is available',
      (tester) async {
    final controller = await controllerWith([
      for (var i = 0; i < 12; i++)
        _signed('f$i', 'Fighter ${String.fromCharCode(65 + i)}',
            WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('No fights added yet.'), findsOneWidget);

    await tester.tap(find.text('Auto-fill'));
    await tester.pumpAndSettle();

    await scrollToCard(tester);
    final bouts = find
        .textContaining(' vs ')
        .evaluate()
        .length;
    expect(bouts, 6, reason: 'twelve fighters make six fights');
    // A card needs a headliner, and the auto-filler picks one.
    expect(find.textContaining('· Main Event'), findsOneWidget);
    expect(find.textContaining('· Co-Main Event'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('auto-fill leaves fights you already made alone',
      (tester) async {
    final controller = await controllerWith([
      for (var i = 0; i < 8; i++)
        _signed('f$i', 'Fighter ${String.fromCharCode(65 + i)}',
            WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    // One hand-made fight first.
    await addFight(tester, 'Fighter A', 'Fighter B');
    expect(find.text('Fighter A vs Fighter B'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fill rest'));
    await tester.pumpAndSettle();
    await scrollToCard(tester);

    // Still there, and its fighters weren't reused.
    expect(find.text('Fighter A vs Fighter B'), findsOneWidget);
    final tiles = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((t) => t.contains(' vs '))
        .toList();
    final names = tiles.expand((t) => t.split(' vs ')).toList();
    expect(names.toSet(), hasLength(names.length),
        reason: 'nobody should be booked twice');

    controller.dispose();
  });

  testWidgets('auto-fill is offered only when somebody is free',
      (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Fighter A', WeightClass.lightweight),
      _signed('b', 'Fighter B', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await addFight(tester, 'Fighter A', 'Fighter B');
    await tester.drag(find.byType(ListView).first, const Offset(0, 900));
    await tester.pumpAndSettle();

    // Both fighters are on the card, so there is nothing left to match.
    // Asserting the behaviour rather than the button's enabled flag:
    // TextButton.icon builds a private subclass that find.byType won't
    // match, and "adds nothing" is the thing that actually matters.
    await tester.tap(find.text('Fill rest'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await scrollToCard(tester);

    expect(find.textContaining(' vs '), findsOneWidget,
        reason: 'there was nobody left, so no fight should have appeared');

    controller.dispose();
  });
}
