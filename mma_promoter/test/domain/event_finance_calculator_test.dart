import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/finance/event_finance_calculator.dart';

Fighter _fighter(String id, {required int popularity, int payPerFight = 2000}) {
  return Fighter(
    id: id,
    name: id,
    age: 27,
    nationality: 'USA',
    weightClass: WeightClass.lightweight,
    record: const FightRecord(wins: 10, losses: 2),
    stats: const FighterStats(
      striking: 70,
      grappling: 70,
      cardio: 70,
      chin: 70,
      power: 70,
    ),
    popularity: popularity,
    morale: 80,
    injuryStatus: InjuryStatus.healthy,
    winStreak: 2,
    styleTags: const [StyleTag.allRounder],
    contract: Contract(
      id: '$id-contract',
      fighterId: id,
      fightsRemaining: 3,
      payPerFight: payPerFight,
      exclusive: true,
      signedOn: DateTime(2026, 1, 1),
    ),
  );
}

Organization _organization({int fanbaseSize = 5000, int cashBalance = 250000}) {
  return Organization(
    id: 'org',
    name: 'Test Org',
    reputationTier: ReputationTier.regional,
    reputationPoints: 0,
    cashBalance: cashBalance,
    fanbaseSize: fanbaseSize,
    homeRegion: 'Midwest, USA',
    promotionBudget: 20000,
  );
}

Fight _mainEventFight(String aId, String bId) {
  return Fight(
    id: 'fight-1',
    eventId: 'event-1',
    fighterAId: aId,
    fighterBId: bId,
    weightClass: WeightClass.lightweight,
    isTitleFight: false,
    isMainEvent: true,
    cardOrder: 0,
    result: const FightResult(
      winnerId: 'a',
      method: FightMethod.decision,
      round: 3,
      winnerPerformanceRating: 75,
      loserPerformanceRating: 60,
    ),
  );
}

void main() {
  group('EventFinanceCalculator', () {
    test('attendance never exceeds venue capacity', () {
      final calculator = EventFinanceCalculator(random: Random(1));
      final a = _fighter('a', popularity: 95);
      final b = _fighter('b', popularity: 95);
      final fight = _mainEventFight('a', 'b');
      final org = _organization(fanbaseSize: 500000);

      final result = calculator.calculate(
        venueTier: VenueTier.localGym,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 500000,
      );

      expect(result.attendance, lessThanOrEqualTo(VenueTier.localGym.capacity));
    });

    test('higher promotion spend increases revenue, all else equal', () {
      final a = _fighter('a', popularity: 40);
      final b = _fighter('b', popularity: 40);
      final fight = _mainEventFight('a', 'b');
      final org = _organization();

      final lowSpend = EventFinanceCalculator(random: Random(5)).calculate(
        venueTier: VenueTier.nationalArena,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );
      final highSpend = EventFinanceCalculator(random: Random(5)).calculate(
        venueTier: VenueTier.nationalArena,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 50000,
      );

      expect(highSpend.revenue, greaterThan(lowSpend.revenue));
    });

    test('a tiny venue with expensive stars runs at a loss', () {
      final calculator = EventFinanceCalculator(random: Random(2));
      final a = _fighter('a', popularity: 90, payPerFight: 100000);
      final b = _fighter('b', popularity: 90, payPerFight: 100000);
      final fight = _mainEventFight('a', 'b');
      final org = _organization(fanbaseSize: 100);

      final result = calculator.calculate(
        venueTier: VenueTier.localGym,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );

      expect(result.netProfit, lessThan(0));
    });

    test('reputation change stays within +/-5', () {
      final calculator = EventFinanceCalculator(random: Random(3));
      final a = _fighter('a', popularity: 90);
      final b = _fighter('b', popularity: 90);
      final fight = _mainEventFight('a', 'b');
      final org = _organization();

      final result = calculator.calculate(
        venueTier: VenueTier.globalStadium,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 100000,
      );

      expect(result.reputationChange, inInclusiveRange(-5, 5));
    });

    test('only national/global venues sell PPV', () {
      final calculator = EventFinanceCalculator(random: Random(4));
      final a = _fighter('a', popularity: 90);
      final b = _fighter('b', popularity: 90);
      final fight = _mainEventFight('a', 'b');
      final org = _organization();

      final result = calculator.calculate(
        venueTier: VenueTier.regionalArena,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );

      expect(result.ppvBuys, 0);
    });
  });
}
