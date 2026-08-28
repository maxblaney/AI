import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/simulation/fight_resolver.dart';
import 'package:mma_promoter/presentation/screens/event_result/fight_breakdown_screen.dart';

import '../support/fighter_fixtures.dart';

/// Simulates a real fight and returns it wrapped in a [Fight], so the
/// screen is exercised against genuine resolver output rather than a
/// hand-built stub.
({Fight fight, Fighter a, Fighter b}) _simulate({int seed = 5, bool wantDecision = false}) {
  final a = testFighter('a-id', stat: 62, power: wantDecision ? 4 : 62);
  final b = testFighter('b-id', stat: 58, power: wantDecision ? 4 : 58);

  for (var s = seed; s < seed + 80; s++) {
    final result = FightResolver(random: Random(s)).resolve(fighterA: a, fighterB: b);
    final matches = wantDecision
        ? result.method == FightMethod.decision
        : result.method != FightMethod.decision && result.method != FightMethod.drawOrNc;
    if (!matches) continue;
    return (
      fight: Fight(
        id: 'fight-1',
        eventId: 'event-1',
        fighterAId: a.id,
        fighterBId: b.id,
        weightClass: WeightClass.lightweight,
        cardOrder: 0,
        result: result,
      ),
      a: a,
      b: b,
    );
  }
  throw StateError('no matching fight found');
}

Widget _wrap(Fight fight, Fighter a, Fighter b) => MaterialApp(
      home: FightBreakdownScreen(fight: fight, fighterA: a, fighterB: b),
    );

void main() {
  testWidgets('renders the scoreboard with both names and a clock', (tester) async {
    final sim = _simulate();
    await tester.pumpWidget(_wrap(sim.fight, sim.a, sim.b));
    await tester.pump();

    expect(find.text('a-id'), findsWidgets);
    expect(find.text('b-id'), findsWidgets);
    // Round indicator like "R1/3".
    expect(find.textContaining(RegExp(r'R\d+/3')), findsOneWidget);
  });

  testWidgets('play-by-play streams in over time and reaches the finish', (tester) async {
    final sim = _simulate();
    await tester.pumpWidget(_wrap(sim.fight, sim.a, sim.b));
    await tester.pump();

    expect(find.textContaining('Round 1 begins.'), findsOneWidget);

    // Let playback run to completion.
    for (var i = 0; i < 400; i++) {
      await tester.pump(const Duration(milliseconds: 900));
    }
    await tester.pumpAndSettle();

    // Once finished the tabs appear.
    expect(find.text('Play-by-Play'), findsOneWidget);
    expect(find.text('Box Score'), findsOneWidget);
    expect(find.text('Scorecards'), findsOneWidget);
  });

  testWidgets('Skip jumps straight to the end', (tester) async {
    final sim = _simulate();
    await tester.pumpWidget(_wrap(sim.fight, sim.a, sim.b));
    await tester.pump();

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Box Score'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('box score shows striking and grappling totals', (tester) async {
    final sim = _simulate();
    await tester.pumpWidget(_wrap(sim.fight, sim.a, sim.b));
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Box Score'));
    await tester.pumpAndSettle();

    expect(find.text('Significant strikes'), findsOneWidget);
    expect(find.text('Striking accuracy'), findsOneWidget);
    expect(find.text('Takedowns'), findsOneWidget);
    expect(find.text('Control time'), findsOneWidget);

    // Knockdowns sits below the fold on a phone-sized viewport.
    await tester.drag(find.text('Significant strikes'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Knockdowns'), findsOneWidget);
  });

  testWidgets('a decision shows three judges\' cards', (tester) async {
    final sim = _simulate(wantDecision: true);
    expect(sim.fight.result!.method, FightMethod.decision);

    await tester.pumpWidget(_wrap(sim.fight, sim.a, sim.b));
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scorecards'));
    await tester.pumpAndSettle();

    // Three cards, each with a round-by-round breakdown.
    expect(find.textContaining('Round 1'), findsNWidgets(3));
    expect(find.textContaining('Round 3'), findsNWidgets(3));
  });

  testWidgets('a fight with no play-by-play degrades gracefully', (tester) async {
    // A result reloaded from storage has no momentum ticks or events.
    final stripped = Fight(
      id: 'f',
      eventId: 'e',
      fighterAId: 'a-id',
      fighterBId: 'b-id',
      weightClass: WeightClass.lightweight,
      cardOrder: 0,
      result: const FightResult(
        winnerId: 'a-id',
        method: FightMethod.koTko,
        round: 2,
        winnerPerformanceRating: 80,
        loserPerformanceRating: 40,
      ),
    );

    await tester.pumpWidget(
      _wrap(stripped, testFighter('a-id'), testFighter('b-id')),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining("isn't available anymore"), findsOneWidget);
  });
}
