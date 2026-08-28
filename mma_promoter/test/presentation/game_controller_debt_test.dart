import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

void main() {
  group('GameController debt', () {
    test('signing is allowed even when it pushes cash negative', () async {
      final controller = GameController.inMemory();
      await controller.init();
      await controller.startNewGame(orgName: 'Debtors Inc', tier: ReputationTier.local);
      await pumpEventQueue();

      expect(controller.organization!.cashBalance, 10000);

      final fighter = controller.talentPool.first;
      final error = await controller.signFighter(
        fighter,
        showMoney: 50000,
        winBonus: 50000,
        fightsInDeal: 3,
      );
      await pumpEventQueue();

      expect(error, isNull);
      expect(controller.organization!.cashBalance, 10000 - 50000);
    });

    test('advanceWeek charges weekly interest on a negative balance', () async {
      final controller = GameController.inMemory();
      await controller.init();
      await controller.startNewGame(orgName: 'Debtors Inc', tier: ReputationTier.local);
      await pumpEventQueue();

      final fighter = controller.talentPool.first;
      await controller.signFighter(
        fighter,
        showMoney: 50000,
        winBonus: 50000,
        fightsInDeal: 3,
      );
      await pumpEventQueue();

      final balanceBefore = controller.organization!.cashBalance;
      expect(balanceBefore, lessThan(0));

      await controller.advanceWeek();

      final balanceAfter = controller.organization!.cashBalance;
      final expectedInterest =
          (-balanceBefore * GameController.weeklyDebtInterestRate).round();

      expect(balanceAfter, balanceBefore - expectedInterest);
      expect(balanceAfter, lessThan(balanceBefore));
    });

    test('advanceWeek charges no interest on a positive balance', () async {
      final controller = GameController.inMemory();
      await controller.init();
      await controller.startNewGame(orgName: 'Solvent Inc', tier: ReputationTier.regional);
      await pumpEventQueue();

      final balanceBefore = controller.organization!.cashBalance;
      expect(balanceBefore, greaterThan(0));

      await controller.advanceWeek();

      expect(controller.organization!.cashBalance, balanceBefore);
    });
  });
}
