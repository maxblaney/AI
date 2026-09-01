import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
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
  Future<GameController> controllerWith(List<Fighter> roster) async {
    final controller = GameController.inMemory(random: Random(11));
    await controller.startNewGame(
      orgName: 'Booking FC',
      tier: ReputationTier.regional,
    );
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

  testWidgets('fights can be moved up and down the card', (tester) async {
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

    // The second bout's "up" arrow promotes it.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up).last);
    await tester.pumpAndSettle();
    expect(order(), ['Fighter C vs Fighter D', 'Fighter A vs Fighter B']);

    // And back down again.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
    await tester.pumpAndSettle();
    expect(order(), ['Fighter A vs Fighter B', 'Fighter C vs Fighter D']);

    controller.dispose();
  });

  testWidgets('the ends of the card cannot be moved past', (tester) async {
    final controller = await controllerWith([
      _signed('a', 'Fighter A', WeightClass.lightweight),
      _signed('b', 'Fighter B', WeightClass.lightweight),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await addFight(tester, 'Fighter A', 'Fighter B');

    // A lone bout is both first and last, so neither arrow does anything.
    IconButton buttonFor(IconData icon) => tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(icon),
            matching: find.byType(IconButton),
          ),
        );

    expect(buttonFor(Icons.keyboard_arrow_up).onPressed, isNull);
    expect(buttonFor(Icons.keyboard_arrow_down).onPressed, isNull);

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
}
