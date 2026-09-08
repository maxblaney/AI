import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/packs/fighter_pack.dart';
import 'package:mma_promoter/presentation/screens/packs/fighter_packs_screen.dart';
import 'package:mma_promoter/presentation/screens/saves/saves_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Packs are the one thing in the database that belongs to the player
/// rather than to a promotion — these cover building one, moving it
/// between saves, and passing it to somebody else.
void main() {
  Fighter free(String id, String name, {WeightClass? division}) =>
      testFighter(id, stat: 70).copyWith(
        name: name,
        weightClass: division ?? WeightClass.lightweight,
      );

  /// The provider goes *above* [MaterialApp], matching `main.dart`. Below
  /// it, a route pushed onto the app's Navigator is a sibling of the
  /// provider rather than a descendant, and any screen that reads the
  /// controller throws on the way up.
  Widget app(GameController controller, Widget home) =>
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: MaterialApp(home: home),
      );

  Future<GameController> emptyController() async {
    final controller = GameController.inMemory(random: Random(21));
    await controller.startNewGame(
      orgName: 'Pack FC',
      tier: ReputationTier.regional,
    );
    for (final s in [...controller.signedRoster]) {
      await controller.releaseFighter(s.id);
    }
    return controller;
  }

  group('packs', () {
    test('a pack is saved and listed back', () async {
      final controller = await emptyController();

      final pack = await controller.createPack(
        name: 'My Guys',
        description: 'Handmade.',
        author: 'Max',
        fighters: [free('a', 'Fighter A'), free('b', 'Fighter B')],
      );

      final packs = await controller.listPacks();
      expect(packs, hasLength(1));
      expect(packs.single.id, pack.id);
      expect(packs.single.name, 'My Guys');
      expect(packs.single.description, 'Handmade.');
      expect(packs.single.author, 'Max');
      expect(packs.single.fighters, hasLength(2));

      controller.dispose();
    });

    test('an unnamed pack still gets a name', () async {
      final controller = await emptyController();
      final pack = await controller.createPack(
        name: '   ',
        fighters: [free('a', 'Fighter A')],
      );

      expect(pack.name, 'Untitled Pack');
      controller.dispose();
    });

    test('adding a pack drops its fighters into the talent pool', () async {
      final controller = await emptyController();
      final pack = await controller.createPack(
        name: 'Three',
        fighters: [
          free('a', 'Fighter A'),
          free('b', 'Fighter B', division: WeightClass.heavyweight),
          free('c', 'Fighter C'),
        ],
      );
      final poolBefore = controller.talentPool.length;

      final added = await controller.addPackToSave(pack);

      expect(added, 3);
      expect(controller.talentPool.length, poolBefore + 3);
      expect(controller.talentPool.map((f) => f.name),
          containsAll(['Fighter A', 'Fighter B', 'Fighter C']));
      // Free agents, not signings — the player decides who to sign.
      expect(
        controller.talentPool
            .where((f) => f.name.startsWith('Fighter'))
            .every((f) => f.contract == null),
        isTrue,
      );

      controller.dispose();
    });

    test('the same pack can be added twice without collisions', () async {
      final controller = await emptyController();
      final pack = await controller.createPack(
        name: 'Twice',
        fighters: [free('a', 'Fighter A')],
      );

      await controller.addPackToSave(pack);
      await controller.addPackToSave(pack);

      final copies =
          controller.talentPool.where((f) => f.name == 'Fighter A').toList();
      expect(copies, hasLength(2), reason: 'two of him, not one overwritten');
      expect(copies[0].id, isNot(copies[1].id));

      controller.dispose();
    });

    test('a pack survives the trip between two saves', () async {
      final controller = await emptyController();
      await controller.createPack(
        name: 'Travellers',
        fighters: [free('a', 'Fighter A'), free('b', 'Fighter B')],
      );

      // A second promotion, entirely separate from the first.
      await controller.startNewGame(
        orgName: 'Second FC',
        tier: ReputationTier.local,
      );

      // Packs are not save-scoped, so the new save can see it.
      final packs = await controller.listPacks();
      expect(packs, hasLength(1));

      final added = await controller.addPackToSave(packs.single);
      expect(added, 2);
      expect(controller.talentPool.map((f) => f.name),
          containsAll(['Fighter A', 'Fighter B']));

      controller.dispose();
    });

    test('a share code round-trips through another player', () async {
      final mine = await emptyController();
      final pack = await mine.createPack(
        name: 'Shared Roster',
        author: 'Max',
        fighters: [
          free('a', 'Fighter A'),
          free('b', 'Fighter B', division: WeightClass.welterweight),
        ],
      );
      final code = mine.sharePackCode(pack);

      // A completely separate game, as if on somebody else's machine.
      final theirs = GameController.inMemory(random: Random(3));
      await theirs.startNewGame(
        orgName: 'Brother FC',
        tier: ReputationTier.regional,
      );
      expect(await theirs.listPacks(), isEmpty);

      final imported = await theirs.importPackCode(code);

      expect(imported.name, 'Shared Roster');
      expect(imported.author, 'Max');
      expect(imported.fighters.map((f) => f.name),
          ['Fighter A', 'Fighter B']);
      expect(imported.fighters[1].weightClass, WeightClass.welterweight);
      expect(await theirs.listPacks(), hasLength(1));

      mine.dispose();
      theirs.dispose();
    });

    test('a bad code is rejected and nothing is saved', () async {
      final controller = await emptyController();

      await expectLater(
        controller.importPackCode('this is not a pack'),
        throwsA(isA<FighterPackFormatException>()),
      );
      expect(await controller.listPacks(), isEmpty);

      controller.dispose();
    });

    test('deleting a pack leaves imported fighters alone', () async {
      final controller = await emptyController();
      final pack = await controller.createPack(
        name: 'Doomed',
        fighters: [free('a', 'Fighter A')],
      );
      await controller.addPackToSave(pack);

      await controller.deletePack(pack.id);

      expect(await controller.listPacks(), isEmpty);
      expect(controller.talentPool.any((f) => f.name == 'Fighter A'), isTrue);

      controller.dispose();
    });
  });

  testWidgets('Settings reaches the packs screen', (tester) async {
    final controller = await emptyController();

    await tester.pumpWidget(app(controller, const SavesScreen()));
    await tester.pumpAndSettle();

    // Settings sits below the saves list, and a ListView only lays out
    // what is on screen.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Fighter Packs'), findsOneWidget);
    await tester.tap(find.text('Fighter Packs'));
    await tester.pumpAndSettle();

    expect(find.byType(FighterPacksScreen), findsOneWidget);
    expect(find.text('No packs yet.'), findsOneWidget);
    expect(find.text('Build a pack'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a saved pack lists with its contents and can be added',
      (tester) async {
    final controller = await emptyController();
    await controller.createPack(
      name: 'Lightweight Legends',
      author: 'Max',
      fighters: [
        free('a', 'Fighter A'),
        free('b', 'Fighter B', division: WeightClass.heavyweight),
      ],
    );

    await tester.pumpWidget(app(controller, const FighterPacksScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Lightweight Legends'), findsOneWidget);
    expect(find.text('2 fighters · 2 divisions · by Max'), findsOneWidget);

    final poolBefore = controller.talentPool.length;
    await tester.tap(find.text('Add to save'));
    await tester.pumpAndSettle();

    expect(controller.talentPool.length, poolBefore + 2);
    expect(find.textContaining('2 fighters added'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('a code that is not a pack shows the reason', (tester) async {
    final controller = await emptyController();

    await tester.pumpWidget(app(controller, const FighterPacksScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Paste a code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'definitely not a pack');
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.textContaining("doesn't look like a fighter pack"),
        findsOneWidget);

    controller.dispose();
  });

  testWidgets('sharing shows the code even when the clipboard refuses',
      (tester) async {
    final controller = await emptyController();
    await controller.createPack(
      name: 'Shareable',
      fighters: [free('a', 'Fighter A')],
    );

    // No clipboard handler is registered in a widget test, which is the
    // same shape as a browser refusing the permission. The dialog must
    // still open — the code is selectable in it, so there is always a
    // way to get it out.
    await tester.pumpWidget(app(controller, const FighterPacksScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share code'));
    await tester.pumpAndSettle();

    expect(find.text('Share Shareable'), findsOneWidget);
    expect(find.textContaining('characters'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('the picker builds a pack out of chosen fighters',
      (tester) async {
    final controller = await emptyController();
    await controller.saveFighter(free('a', 'Adam Alpha'));
    await controller.saveFighter(free('b', 'Bruno Bravo'));
    await controller.saveFighter(
        free('c', 'Carl Charlie', division: WeightClass.heavyweight));

    await tester.pumpWidget(app(controller, const FighterPacksScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Build a pack'));
    await tester.pumpAndSettle();
    // Everyone in the save is offered, released starters included, so
    // narrow to the three this test planted rather than counting rows.
    expect(find.byType(CheckboxListTile), findsWidgets);

    // The search box now holds the name too, so tick the row rather
    // than the text.
    Future<void> pick(String name) async {
      await tester.enterText(
          find.widgetWithText(TextField, 'Search'), name);
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsOneWidget,
          reason: 'the search should have narrowed to $name alone');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
    }

    await pick('Adam Alpha');
    await pick('Carl Charlie');

    expect(find.text('Pick fighters (2)'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Pack name'), 'Hand Picked');
    await tester.tap(find.text('Save Pack'));
    await tester.pumpAndSettle();

    final packs = await controller.listPacks();
    expect(packs, hasLength(1));
    expect(packs.single.name, 'Hand Picked');
    expect(packs.single.fighters.map((f) => f.name),
        ['Adam Alpha', 'Carl Charlie']);

    controller.dispose();
  });
}
