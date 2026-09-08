import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/domain/finance/payroll_health.dart';
import 'package:mma_promoter/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mma_promoter/presentation/screens/roster/fighter_profile_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// A promotion can sit at 40% of takings for years, upgrade its roster,
/// and be paying out more than its shows bring in before anything says
/// so. These cover the two places it now says so.
void main() {
  Fighter signed(String id, String name, {int showMoney = 1000}) =>
      testFighter(id, stat: 70).copyWith(
        name: name,
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: 5,
          showMoney: showMoney,
          winBonus: showMoney,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      );

  Future<GameController> controllerWith(List<Fighter> roster) async {
    final c = GameController.inMemory(random: Random(4));
    await c.startNewGame(
        orgName: 'Payroll FC', tier: ReputationTier.regional);
    for (final s in [...c.signedRoster]) {
      await c.releaseFighter(s.id);
    }
    for (final f in roster) {
      await c.saveFighter(f);
    }
    return c;
  }

  Future<void> runOneCard(GameController c) async {
    final week = c.organization!.currentWeek;
    final error = await c.bookEvent(
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
    await c.advanceWeek();
    await c.simulateEvent(c.scheduledEvents.single.id,
        promotionBudgetSpent: 0);
  }

  testWidgets('the dashboard reports fighter pay against takings',
      (tester) async {
    final c = await controllerWith([
      signed('a', 'Fighter A'),
      signed('b', 'Fighter B'),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<GameController>.value(
        value: c,
        child: const DashboardScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    // Nothing to report before a show has run — there are no takings to
    // take a share of.
    expect(find.text('Fighter Pay'), findsNothing);

    await runOneCard(c);
    await tester.pumpAndSettle();

    expect(find.text('Fighter Pay'), findsOneWidget);
    expect(find.textContaining('% of takings'), findsOneWidget);
    expect(c.payrollHealth, isNotNull);

    c.dispose();
  });

  testWidgets('a ruinous roster is called overcommitted', (tester) async {
    // Two fighters on more per night than a regional gate takes.
    final c = await controllerWith([
      signed('a', 'Costly One', showMoney: 90000),
      signed('b', 'Costly Two', showMoney: 90000),
    ]);
    await runOneCard(c);

    expect(c.payrollHealth!.pressure, PayrollPressure.overcommitted);

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<GameController>.value(
        value: c,
        child: const DashboardScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('more than they take in'), findsOneWidget);

    c.dispose();
  });

  testWidgets('the sign dialog weighs the deal against a night',
      (tester) async {
    final c = await controllerWith([
      signed('a', 'Fighter A'),
      signed('b', 'Fighter B'),
    ]);
    await runOneCard(c);

    // Somebody in the pool to go and sign.
    final target = c.talentPool.first;

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<GameController>.value(
        value: c,
        child: FighterProfileScreen(fighterId: target.id),
      ),
    ));
    await tester.pumpAndSettle();

    // The button sits below the profile's stat blocks.
    await tester.dragUntilVisible(
      find.text('Sign Fighter'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Fighter'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Market rate for this fighter'), findsOneWidget);
    // The line that was missing: what this one contract is worth against
    // what a night actually takes.
    expect(find.textContaining('of a night on its own'), findsOneWidget);

    c.dispose();
  });
}
