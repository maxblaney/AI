import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

/// The sign flow had no direct coverage — it was only ever exercised by
/// hand through the UI.
void main() {
  test('signing a fighter moves them from the talent pool to the roster',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final controller = GameController(database: db);
    await controller.init();
    await controller.startNewGame(
        orgName: 'Sign FC', tier: ReputationTier.regional);
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    final target = controller.talentPool.first;
    final error = await controller.signFighter(
      target,
      showMoney: 1000,
      winBonus: 1000,
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
