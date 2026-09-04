import 'dart:math';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/finance/pay_scale.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// The sign flow had no direct coverage — it was only ever exercised by
/// hand through the UI.
void main() {
  test('signing a fighter moves them from the talent pool to the roster',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final controller = GameController(database: db, random: Random(11));
    await controller.init();
    await controller.startNewGame(
        orgName: 'Sign FC', tier: ReputationTier.regional);
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    final target = controller.talentPool.first;
    // At market rate: a fighter turns down a lowball now, so a fixed
    // \$1,000 no longer signs anybody worth having.
    final rate = PayScale.suggest(
      overall: target.overall,
      popularity: target.popularity,
    );
    final error = await controller.signFighter(
      target,
      showMoney: rate.showMoney,
      winBonus: rate.winBonus,
      fightsInDeal: 3,
    );
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(error, isNull, reason: 'sign returned: $error');
    expect(controller.signedRoster.map((f) => f.id), contains(target.id));
    expect(controller.fighterById(target.id)!.contract!.fightsRemaining, 3);
    expect(controller.talentPool.map((f) => f.id), isNot(contains(target.id)),
        reason: 'a signed fighter is no longer a free agent');

    controller.dispose();
    await db.close();
  });
}
