import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/screens/rankings/rankings_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';
import 'package:mma_promoter/presentation/theme/app_theme.dart';

import '../support/fighter_fixtures.dart';

Fighter _ranked(
  String name, {
  required int elo,
  WeightClass division = WeightClass.lightweight,
  Set<WeightClass> belts = const {},
  Set<WeightClass> interimBelts = const {},
}) {
  return testFighter(name.toLowerCase().replaceAll(' ', '-')).copyWith(
    name: name,
    weightClass: division,
    eloRating: elo,
    isRanked: true,
    belts: belts,
    interimBelts: interimBelts,
    contract: Contract(
      id: '$name-c',
      fighterId: name,
      fightsRemaining: 3,
      showMoney: 1000,
      winBonus: 1000,
      exclusive: true,
      signedOn: DateTime(2026, 1, 1),
    ),
  );
}

void main() {
  Future<GameController> controllerWith(List<Fighter> fighters) async {
    final controller = GameController.inMemory(random: Random(11));
    await controller.startNewGame(
      orgName: 'Rank FC',
      tier: ReputationTier.regional,
    );
    for (final fighter in fighters) {
      await controller.saveFighter(fighter);
    }
    return controller;
  }

  Widget wrap(GameController controller) => MaterialApp(
        theme: AppTheme.dark(),
        home: ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: const RankingsScreen(),
        ),
      );

    // The avatar falls back to a fighter's initial when they have no
  // headshot, which is also a Text — so fighters here are named to keep
  // their initials clear of 'C' and 'i'.
  Color? colorOfText(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  testWidgets('the divisional C is gold, and the interim C is its own gold',
      (tester) async {
    final controller = await controllerWith([
      _ranked('Gold Holder', elo: 1600, belts: {WeightClass.lightweight}),
      _ranked('Placeholder Man', elo: 1580,
          interimBelts: {WeightClass.lightweight}),
      _ranked('Ranked Guy', elo: 1560),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Lightweight'));
    await tester.pumpAndSettle();

    expect(colorOfText(tester, 'C'), AppColors.belt);
    expect(colorOfText(tester, 'iC'), AppColors.beltInterim);
    expect(colorOfText(tester, 'C'), isNot(AppColors.accent),
        reason: 'the belt should not share the danger red');

    controller.dispose();
  });

  testWidgets('pound-for-pound marks who the champions are', (tester) async {
    final controller = await controllerWith([
      _ranked('Gold Holder', elo: 1600, belts: {WeightClass.lightweight}),
      _ranked('Ranked Guy', elo: 1560),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    // P4P is the default tab.
    expect(find.text('CHAMP'), findsOneWidget);
    expect(colorOfText(tester, 'CHAMP'), AppColors.belt);
    expect(find.textContaining('Lightweight champion'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a champion outranks his own contender pound-for-pound',
      (tester) async {
    // The contender is ahead on Elo but the champion holds the belt over
    // him, so he should still be listed first.
    final controller = await controllerWith([
      _ranked('Gold Holder', elo: 1600, belts: {WeightClass.lightweight}),
      _ranked('Sharper Rating', elo: 1660),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .where((t) => t == 'Gold Holder' || t == 'Sharper Rating')
        .toList();
    expect(names.first, 'Gold Holder');

    controller.dispose();
  });

  testWidgets('a double champ is called out as one', (tester) async {
    final controller = await controllerWith([
      _ranked('Pair Of Belts', elo: 1700, belts: {
        WeightClass.lightweight,
        WeightClass.welterweight,
      }),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('DOUBLE CHAMP'), findsOneWidget);
    expect(
      find.textContaining('Lightweight & Welterweight champion'),
      findsOneWidget,
    );

    controller.dispose();
  });
}
