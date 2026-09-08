import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/domain/finance/pay_scale.dart';
import 'package:mma_promoter/presentation/screens/event_result/event_result_screen.dart';
import 'package:mma_promoter/presentation/screens/roster/fighter_profile_screen.dart';
import 'package:mma_promoter/presentation/screens/roster/roster_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

void main() {
  Fighter signed(String id, String name) => testFighter(id, stat: 70).copyWith(
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

  Future<GameController> ranCard() async {
    final c = GameController.inMemory(random: Random(6));
    await c.startNewGame(orgName: 'Nav FC', tier: ReputationTier.regional);
    for (final s in [...c.signedRoster]) {
      await c.releaseFighter(s.id);
    }
    for (final f in [signed('a', 'Femi Adeleke'), signed('b', 'Michal Szymanski')]) {
      await c.saveFighter(f);
    }
    final week = c.organization!.currentWeek;
    await c.bookEvent(
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
    await c.advanceWeek();
    await c.simulateEvent(c.scheduledEvents.single.id, promotionBudgetSpent: 0);
    return c;
  }

  /// Provider above MaterialApp, as `main.dart` has it: a pushed route
  /// is a sibling of `home`, so a provider inside it is invisible to
  /// anything the screen navigates to.
  Widget wrap(GameController c, Widget child) =>
      ChangeNotifierProvider<GameController>.value(
        value: c,
        child: MaterialApp(home: child),
      );

  testWidgets('a finished fight opens its stats', (tester) async {
    final c = await ranCard();
    final eventId = c.completedEvents.single.id;

    await tester.pumpWidget(wrap(c, EventResultScreen(eventId: eventId)));
    await tester.pumpAndSettle();

    // Reveal the result, which is what puts the stats link on the tile.
    // A freshly simulated fight still has its play-by-play in memory, so
    // the tile offers to replay it; skipping is the other way through.
    await tester.tap(find.text('Skip to result'));
    await tester.pumpAndSettle();

    expect(find.text('Fight stats'), findsOneWidget);
    await tester.tap(find.text('Fight stats'));
    await tester.pumpAndSettle();

    // The box score survives a save even though the play-by-play does
    // not — this is the screen that shows it.
    expect(find.text('Box Score'), findsOneWidget);
    expect(find.textContaining('Adeleke'), findsWidgets);

    c.dispose();
  });

  testWidgets('a name on the card opens that fighter', (tester) async {
    final c = await ranCard();
    final eventId = c.completedEvents.single.id;

    await tester.pumpWidget(wrap(c, EventResultScreen(eventId: eventId)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Femi Adeleke').first);
    await tester.pumpAndSettle();

    expect(find.byType(FighterProfileScreen), findsOneWidget);

    c.dispose();
  });

  testWidgets('the weight class filter is reachable without scrolling',
      (tester) async {
    final c = GameController.inMemory(random: Random(2));
    await c.startNewGame(orgName: 'Nav FC', tier: ReputationTier.regional);

    await tester.pumpWidget(wrap(c, const RosterScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Talent Pool'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.filter_alt_outlined));
    await tester.pumpAndSettle();

    // The scouting filters used to sit above the weight classes, which
    // pushed them off the bottom of a sheet that opens at 70% height —
    // so picking Lightweight meant scrolling past three things to find
    // it, and it read as the option having gone missing.
    final chip = find.widgetWithText(ChoiceChip, 'Lightweight');
    expect(chip, findsOneWidget);
    expect(tester.getCenter(chip).dy,
        lessThan(tester.view.physicalSize.height / tester.view.devicePixelRatio),
        reason: 'Lightweight should be on screen when the sheet opens');

    await tester.tap(chip);
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Filters'))).pop();
    await tester.pumpAndSettle();

    final lightweights = c.talentPool
        .where((f) => f.weightClass == WeightClass.lightweight)
        .length;
    expect(find.textContaining('$lightweights of'), findsOneWidget);

    c.dispose();
  });

  testWidgets('a lowball offer is refused, and says what would work',
      (tester) async {
    final c = GameController.inMemory(random: Random(2));
    await c.startNewGame(orgName: 'Nav FC', tier: ReputationTier.regional);
    final star = ([...c.talentPool]
          ..sort((a, b) => b.overall.compareTo(a.overall)))
        .first;

    final refused = await c.signFighter(star,
        showMoney: 1000, winBonus: 1000, fightsInDeal: 4);
    expect(refused, isNotNull, reason: 'a good fighter should say no');
    expect(refused, contains('turned it down'));
    expect(c.signedRoster.any((f) => f.id == star.id), isFalse);

    // And the going rate is always enough.
    final rate =
        PayScale.suggest(overall: star.overall, popularity: star.popularity);
    final accepted = await c.signFighter(star,
        showMoney: rate.showMoney, winBonus: rate.winBonus, fightsInDeal: 4);
    expect(accepted, isNull);

    c.dispose();
  });
}
