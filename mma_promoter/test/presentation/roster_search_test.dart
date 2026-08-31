import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/screens/roster/roster_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// The talent pool is 400 fighters deep in one alphabetical list. Without
/// a search box, finding one man means scrolling — which is exactly what
/// made the pool feel empty. Names and nationalities here are deliberately
/// ones the seed generator can't produce, so a match is unambiguous
/// against a pool it has already filled.
void main() {
  Future<GameController> controllerWith(List<Fighter> pool) async {
    final controller = GameController.inMemory(random: Random(11));
    await controller.startNewGame(
      orgName: 'Search FC',
      tier: ReputationTier.regional,
    );
    for (final fighter in pool) {
      await controller.saveFighter(fighter);
    }
    return controller;
  }

  Widget wrap(GameController controller) => MaterialApp(
        home: ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: const RosterScreen(),
        ),
      );

  Future<void> openTalentPool(WidgetTester tester) async {
    await tester.tap(find.text('Talent Pool'));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
  }

  Fighter freeAgent(String name, {String nationality = 'Qqqland'}) =>
      testFighter(name.toLowerCase().replaceAll(' ', '-'))
          .copyWith(name: name, nationality: nationality);

  testWidgets('searching by name finds one fighter in a full pool',
      (tester) async {
    final controller = await controllerWith([freeAgent('Zzyzx Quibbleton')]);
    final total = controller.talentPool.length;
    expect(total, greaterThan(100),
        reason: 'a new game seeds a deep pool — that is the problem');

    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await openTalentPool(tester);

    expect(find.text('$total free agents'), findsOneWidget);
    expect(find.text('Zzyzx Quibbleton'), findsNothing,
        reason: 'buried at the end of an alphabetical list of hundreds');

    await search(tester, 'quibble');

    expect(find.text('Zzyzx Quibbleton'), findsOneWidget);
    expect(find.text('1 of $total free agent'), findsOneWidget,
        reason: 'the count has to show the rest are hidden, not gone');

    controller.dispose();
  });

  testWidgets('search matches nationality too', (tester) async {
    final controller = await controllerWith([
      freeAgent('Aaa Oneman', nationality: 'Qqqland'),
      freeAgent('Bbb Twoman', nationality: 'Wwwland'),
    ]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await openTalentPool(tester);

    await search(tester, 'qqqland');

    expect(find.text('Aaa Oneman'), findsOneWidget);
    expect(find.text('Bbb Twoman'), findsNothing);

    controller.dispose();
  });

  testWidgets('an empty result says it is the search, not an empty pool',
      (tester) async {
    final controller = await controllerWith([freeAgent('Aaa Oneman')]);
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await openTalentPool(tester);

    await search(tester, 'nobodynamedthis');

    expect(
        find.textContaining('match your search or filters'), findsOneWidget);
    expect(find.text('No free agents available.'), findsNothing,
        reason: 'that wording would read as a broken talent pool');

    controller.dispose();
  });

  testWidgets('clearing the search brings the whole pool back',
      (tester) async {
    final controller = await controllerWith([freeAgent('Zzyzx Quibbleton')]);
    final total = controller.talentPool.length;

    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await openTalentPool(tester);

    await search(tester, 'quibble');
    expect(find.text('1 of $total free agent'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('$total free agents'), findsOneWidget);

    controller.dispose();
  });
}
