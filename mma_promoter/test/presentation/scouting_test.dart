import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/screens/roster/roster_screen.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// Scouting a pool that runs past a thousand names is a comparison, and
/// a comparison you have to make one profile page at a time isn't one.
void main() {
  Future<GameController> controller() async {
    final c = GameController.inMemory(random: Random(9));
    await c.startNewGame(
        orgName: 'Scout FC', tier: ReputationTier.regional);
    return c;
  }

  Widget wrap(GameController c) => MaterialApp(
        home: ChangeNotifierProvider<GameController>.value(
          value: c,
          child: const RosterScreen(),
        ),
      );

  testWidgets('the talent pool prices what it is showing you',
      (tester) async {
    final c = await controller();
    await tester.pumpWidget(wrap(c));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Talent Pool'));
    await tester.pumpAndSettle();

    // Asking price, age and overall on the row — the three things that
    // decide whether to open the profile at all.
    expect(find.textContaining('to show'), findsWidgets);
    expect(find.textContaining('Age '), findsWidgets);
    expect(find.textContaining('OVR '), findsWidgets);

    c.dispose();
  });

  testWidgets('divisions that cannot make a fight are named up front',
      (tester) async {
    final c = await controller();
    // Strip a division back to two men: enough for one fight, and the
    // same one every time.
    final lights = c.signedRoster
        .where((f) => f.weightClass == WeightClass.lightweight)
        .toList();
    for (final f in lights.skip(2)) {
      await c.releaseFighter(f.id);
    }

    await tester.pumpWidget(wrap(c));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Talent Pool'));
    await tester.pumpAndSettle();

    expect(find.text('Short of fighters here'), findsOneWidget);
    expect(find.textContaining('Lightweight · 2'), findsOneWidget);

    c.dispose();
  });

  testWidgets('an age band narrows the market', (tester) async {
    final c = await controller();
    await tester.pumpWidget(wrap(c));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Talent Pool'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_alt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Under 26'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear All').last);
    await tester.pumpAndSettle();
    // Re-apply after proving Clear All resets it, so the assertion below
    // is about the filter and not about leftover state.
    await tester.tap(find.text('Under 26'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Under 26'))).pop();
    await tester.pumpAndSettle();

    final under26 = c.talentPool.where((f) => f.age < 26).length;
    expect(under26, lessThan(c.talentPool.length),
        reason: 'the fixture needs both young and old fighters to be a test');
    expect(find.textContaining('of ${c.talentPool.length} free agents'),
        findsOneWidget);

    c.dispose();
  });

  testWidgets('your own roster is not priced like a shopping list',
      (tester) async {
    final c = await controller();
    await tester.pumpWidget(wrap(c));
    await tester.pumpAndSettle();

    // My Roster is the default tab: these men are already signed, so
    // what they would cost to sign is not a question.
    expect(find.textContaining('to show'), findsNothing);
    expect(find.text('Short of fighters here'), findsNothing);

    c.dispose();
  });
}
