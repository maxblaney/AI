import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/screens/new_game/new_game_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// The two openings the game offers: inherit a roster, or build one.
void main() {
  Widget wrap(GameController controller) => ChangeNotifierProvider<
          GameController>.value(
        value: controller,
        child: const MaterialApp(home: NewGameScreen()),
      );

  /// Scrolls the choice into view and taps it. The roster options sit
  /// below four tier cards, and a ListView only builds what it laid out.
  Future<void> choose(WidgetTester tester, String label) async {
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('both openings are offered, established by default',
      (tester) async {
    final controller = GameController.inMemory();
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Established promotion'), findsOneWidget);
    expect(find.text('Start from scratch'), findsOneWidget);

    final tiles = tester
        .widgetList<RadioListTile<bool>>(find.byType(RadioListTile<bool>))
        .toList();
    expect(tiles, hasLength(2));
    expect(tiles.first.groupValue, isTrue,
        reason: 'the gentler opening is the default');

    controller.dispose();
  });

  testWidgets('start from scratch leaves the roster empty', (tester) async {
    final controller = GameController.inMemory();
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    await choose(tester, 'Start from scratch');
    await tester.tap(find.text('Start Promotion'));
    await tester.pumpAndSettle();

    expect(controller.signedRoster, isEmpty);
    // Still somebody to sign, though.
    expect(controller.talentPool, isNotEmpty);

    controller.dispose();
  });

  testWidgets('the established opening still signs a full roster',
      (tester) async {
    final controller = GameController.inMemory();
    await tester.pumpWidget(wrap(controller));
    await tester.pumpAndSettle();

    // Leaving the default alone is the other half of the choice.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Promotion'));
    await tester.pumpAndSettle();

    expect(controller.signedRoster, hasLength(WeightClass.values.length * 20));

    controller.dispose();
  });
}
