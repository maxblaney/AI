import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// Fighters used to have an age and never grow into it, which made the
/// retirement engine's age rule dead code and left the talent pool an
/// ever-growing reservoir of people who would never mature or leave.
void main() {
  Future<GameController> controller() async {
    final c = GameController.inMemory(random: Random(11));
    await c.startNewGame(
        orgName: 'Ageing FC', tier: ReputationTier.regional);
    return c;
  }

  Future<void> advanceWeeks(GameController c, int weeks) async {
    for (var i = 0; i < weeks; i++) {
      await c.advanceWeek();
    }
  }

  test('a year of game weeks gives everyone a birthday', () async {
    final c = await controller();
    final before = {for (final f in c.allFighters) f.id: f.age};

    await advanceWeeks(c, 52);

    var checked = 0;
    for (final f in c.allFighters) {
      final was = before[f.id];
      if (was == null || f.retired) continue; // pool top-ups, and the gone
      expect(f.age, was + 1, reason: '${f.name} should have had a birthday');
      checked++;
    }
    expect(checked, greaterThan(100), reason: 'the whole world ages');

    c.dispose();
  });

  test('half a year is not a birthday', () async {
    final c = await controller();
    final before = {for (final f in c.allFighters) f.id: f.age};

    await advanceWeeks(c, 26);

    for (final f in c.allFighters) {
      final was = before[f.id];
      if (was == null) continue;
      expect(f.age, was);
    }

    c.dispose();
  });

  test('free agents age out instead of piling up forever', () async {
    final c = await controller();
    final poolBefore = c.talentPool.length;

    // Retirement used to be rolled only after a fight, so a fighter
    // nobody booked never left — the pool grew without bound and its
    // mean age climbed past 35.
    await advanceWeeks(c, 52 * 6);

    final retiredUnsigned =
        c.retiredFighters.where((f) => !f.isSigned).length;
    expect(retiredUnsigned, greaterThan(0),
        reason: 'nobody should be stuck in the pool at 45 forever');

    final meanPoolAge = c.talentPool.isEmpty
        ? 0.0
        : c.talentPool.map((f) => f.age).reduce((a, b) => a + b) /
            c.talentPool.length;
    expect(meanPoolAge, lessThan(33),
        reason: 'fresh intake should keep the market young, not grey it');
    expect(c.talentPool.length, greaterThan(poolBefore ~/ 2),
        reason: 'and it should still be a market, not an empty room');

    c.dispose();
  });

  test('the monthly intake is prospects, not more of the same', () async {
    final rng = Random(3);
    final newcomers = generateMonthlyTalentPool(count: 200, random: rng);
    final meanAge =
        newcomers.map((f) => f.age).reduce((a, b) => a + b) / newcomers.length;

    // A sport is fed by people at the start of their careers. If the
    // intake matches the world's own age distribution it cannot replace
    // anybody, which is exactly what was happening.
    expect(meanAge, lessThan(27));
    expect(newcomers.every((f) => f.age <= 30), isTrue);
    expect(newcomers.every((f) => f.record.totalFights <= 8), isTrue,
        reason: 'somebody turning pro has not had twenty fights');
  });

  test('a thinning roster gets said out loud', () async {
    final c = await controller();
    for (final f in [...c.signedRoster].take(130)) {
      await c.releaseFighter(f.id);
    }
    expect(c.signedRoster.length,
        lessThanOrEqualTo(GameController.rosterThinThreshold));

    await c.advanceWeek();

    expect(
      c.inboxItems.any((i) => i.title.contains('roster is thinning')),
      isTrue,
      reason: 'the first sign of trouble should not be a card you cannot '
          'build',
    );

    c.dispose();
  });

  test('a healthy roster is left alone about it', () async {
    final c = await controller();
    await c.advanceWeek();

    expect(
      c.inboxItems.any((i) => i.title.contains('roster is thinning')),
      isFalse,
    );

    c.dispose();
  });
}
