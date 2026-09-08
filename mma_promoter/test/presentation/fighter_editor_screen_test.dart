import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/cosmetics/headshot_catalog.dart';
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
    // It sits below the fold now that the portrait picker heads the tab,
    // and a ListView only builds what it has laid out.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
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
    // Below the fold under the portrait picker, so scroll to it.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Reach: 74"'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  group('portrait picker', () {
    // The catalog memoises, and a future created inside one test's
    // runAsync zone never completes when awaited from the next test's.
    // A fresh load per test is cheap and keeps them independent.
    setUp(HeadshotCatalog.resetCache);
    tearDownAll(HeadshotCatalog.resetCache);

    Widget wrapWith(GameController c, Widget child) => MaterialApp(
          home: ChangeNotifierProvider<GameController>.value(
            value: c,
            child: child,
          ),
        );

    /// Pumps the editor and waits for its portrait catalog to arrive.
    ///
    /// Reading the asset manifest is real file I/O, which the widget
    /// binding's fake clock will not drive — [WidgetTester.runAsync] is
    /// the only thing that lets it finish, and it has to run *after* the
    /// screen is mounted so the screen's own pending load is what
    /// completes. Warming the catalog before pumping leaves the widget
    /// waiting on a callback the fake zone never delivers.
    Future<void> pumpEditor(WidgetTester tester, GameController c,
        {Fighter? existing}) async {
      await tester.pumpWidget(
          wrapWith(c, FighterEditorScreen(existingFighter: existing)));
      await tester.pump();
      await tester.runAsync(() => HeadshotCatalog.load());
      await tester.pumpAndSettle();
    }

    /// The screen's own controller, so a save can be read back.
    Future<GameController> controller() async {
      final c = GameController.inMemory();
      await c.startNewGame(
        orgName: 'Face FC',
        tier: ReputationTier.regional,
      );
      return c;
    }

    testWidgets('a new fighter opens on a rolled face that can be changed',
        (tester) async {
      final c = await controller();
      await pumpEditor(tester, c);

      expect(find.text('Portrait'), findsOneWidget);
      expect(find.text('Choose'), findsOneWidget);
      expect(find.text('Random'), findsOneWidget);

      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();

      // The grid is built from the asset manifest, so the sets this
      // build ships are the sets on offer.
      expect(find.text('Choose a portrait'), findsOneWidget);
      expect(find.textContaining('Deep'), findsWidgets);
      expect(find.byType(Image), findsWidgets);
      expect(tester.takeException(), isNull);

      c.dispose();
    });

    testWidgets('choosing a face saves it onto the fighter', (tester) async {
      final c = await controller();
      await pumpEditor(tester, c);

      await tester.enterText(
          find.widgetWithText(TextField, 'Name'), 'Custom Face');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      // Any portrait in the grid; which one does not matter, only that
      // the choice survives the save. Scoped to the dialog so the tap
      // can't land on one of the screen's own ink wells.
      await tester.tap(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Talent Pool'));
      await tester.pumpAndSettle();

      final saved =
          c.talentPool.firstWhere((f) => f.name == 'Custom Face');
      expect(saved.headshotAsset, isNotNull);
      expect(saved.headshotAsset, startsWith('assets/fighters/'));

      c.dispose();
    });

    testWidgets('an existing fighter can have their face changed',
        (tester) async {
      // This could not be done at all before: copyWith never touched
      // headshotAsset, so editing a fighter left the old face on them.
      final c = await controller();
      final existing = testFighter('a').copyWith(
        name: 'Old Face',
        headshotAsset: 'assets/fighters/deep_01.png',
      );
      await c.saveFighter(existing);
      await pumpEditor(tester, c, existing: existing);

      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      // Clearing the portrait is the sharpest version of the same test:
      // it can only work if copyWith is told to null the field.
      await tester.tap(find.text('No portrait'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(c.fighterById('a')!.headshotAsset, isNull);

      c.dispose();
    });

    testWidgets('Random re-rolls the face', (tester) async {
      final c = await controller();
      await pumpEditor(tester, c);

      // Roll until it lands on something different — with dozens of
      // portraits this takes a couple of taps at most, and asserting on
      // one tap would be a coin flip.
      await tester.enterText(
          find.widgetWithText(TextField, 'Name'), 'Roller');
      for (var i = 0; i < 20; i++) {
        await tester.tap(find.text('Random'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Add to Talent Pool'));
      await tester.pumpAndSettle();
      expect(
        c.talentPool.firstWhere((f) => f.name == 'Roller').headshotAsset,
        isNotNull,
      );

      c.dispose();
    });
  });
}
