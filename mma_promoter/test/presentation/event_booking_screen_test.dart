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
    final controller = GameController.inMemory();
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
}
