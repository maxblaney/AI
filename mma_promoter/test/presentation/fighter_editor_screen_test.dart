import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/screens/roster/fighter_editor_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Regression coverage for a real bug: a `late` field (`_reachInches`)
/// that was declared but never assigned in `initState`, which crashed the
/// screen on its very first build. `flutter analyze` can't catch a
/// `late`-but-uninitialized field — only actually building the widget
/// does, which is exactly why this needs a test, not just a compile check.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: ChangeNotifierProvider<GameController>(
          create: (_) => GameController.inMemory(),
          child: child,
        ),
      );

  testWidgets('create mode builds without throwing and shows every tab',
      (tester) async {
    await tester.pumpWidget(wrap(const FighterEditorScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Create Fighter'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(find.text('Striking'), findsOneWidget);
    expect(find.text('Grappling'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
    expect(find.text('Mental'), findsOneWidget);
    expect(find.text('Style'), findsOneWidget);
    // The reach slider specifically — this is the field that crashed.
    expect(find.textContaining('Reach:'), findsOneWidget);
  });

  testWidgets('every tab can be opened without throwing', (tester) async {
    await tester.pumpWidget(wrap(const FighterEditorScreen()));
    await tester.pumpAndSettle();

    for (final tab in ['Striking', 'Grappling', 'Physical', 'Mental', 'Style']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tapping the $tab tab threw');
    }
  });

  testWidgets('filling in a name and saving adds the fighter to the talent pool',
      (tester) async {
    final controller = GameController.inMemory();
    // Mirrors the real app: the roster/editor screens are only reachable
    // once a game exists, which is what turns on the fighter-list stream
    // subscription that `allFighters` depends on.
    await controller.startNewGame(orgName: 'Test Org', tier: ReputationTier.regional);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const FighterEditorScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Test McTesterson');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to Talent Pool'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      controller.allFighters.any((f) => f.name == 'Test McTesterson'),
      isTrue,
      reason: 'saved fighter should show up in GameController.allFighters',
    );
  });

  testWidgets('edit mode pre-fills from the existing fighter and builds without throwing',
      (tester) async {
    final existing = testFighter('existing-id', stat: 55, reachInches: 74);

    await tester.pumpWidget(
      wrap(FighterEditorScreen(existingFighter: existing)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Edit Fighter'), findsOneWidget);
    expect(find.text('Reach: 74"'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
