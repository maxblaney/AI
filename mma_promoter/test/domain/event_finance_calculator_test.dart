import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/finance/event_finance_calculator.dart';

import '../support/fighter_fixtures.dart';

Fighter _fighter(String id, {required int popularity, int payPerFight = 2000}) {
  return testFighter(
    id,
    stat: 70,
    popularity: popularity,
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

Organization _organization({
  int fanbaseSize = 5000,
  int cashBalance = 250000,
  ReputationTier tier = ReputationTier.regional,
}) {
  return Organization(
    id: 'org',
    name: 'Test Org',
    reputationTier: tier,
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
        venue: Venue.regionalUsa,
        ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 500000,
      );

      expect(result.attendance, lessThanOrEqualTo(Venue.regionalUsa.capacity));
    });

    test('higher promotion spend increases revenue, all else equal', () {
      final a = _fighter('a', popularity: 40);
      final b = _fighter('b', popularity: 40);
      final fight = _mainEventFight('a', 'b');
      final org = _organization(tier: ReputationTier.national);

      final lowSpend = EventFinanceCalculator(random: Random(5)).calculate(
        venue: Venue.newYorkNy,
        ticketPrice: Venue.newYorkNy.suggestedTicketPrice,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );
      final highSpend = EventFinanceCalculator(random: Random(5)).calculate(
        venue: Venue.newYorkNy,
        ticketPrice: Venue.newYorkNy.suggestedTicketPrice,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 50000,
      );

      expect(highSpend.revenue, greaterThan(lowSpend.revenue));
    });

    test('pricing tickets well above suggested reduces attendance', () {
      final a = _fighter('a', popularity: 60);
      final b = _fighter('b', popularity: 60);
      final fight = _mainEventFight('a', 'b');
      final org = _organization();

      final cheap = EventFinanceCalculator(random: Random(6)).calculate(
        venue: Venue.hartfordCt,
        ticketPrice: Venue.hartfordCt.suggestedTicketPrice,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );
      final expensive = EventFinanceCalculator(random: Random(6)).calculate(
        venue: Venue.hartfordCt,
        ticketPrice: Venue.hartfordCt.suggestedTicketPrice * 5,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );

      expect(expensive.attendance, lessThan(cheap.attendance));
    });

    test('a tiny venue with expensive stars runs at a loss', () {
      final calculator = EventFinanceCalculator(random: Random(2));
      final a = _fighter('a', popularity: 90, payPerFight: 100000);
      final b = _fighter('b', popularity: 90, payPerFight: 100000);
      final fight = _mainEventFight('a', 'b');
      final org = _organization(fanbaseSize: 100);

      final result = calculator.calculate(
        venue: Venue.regionalUsa,
        ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
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
      final org = _organization(tier: ReputationTier.international);

      final result = calculator.calculate(
        venue: Venue.newYorkNy,
        ticketPrice: Venue.newYorkNy.suggestedTicketPrice,
        organization: org,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 100000,
      );

      expect(result.reputationChange, inInclusiveRange(-5, 5));
    });

    test('only national/international orgs sell PPV', () {
      final a = _fighter('a', popularity: 90);
      final b = _fighter('b', popularity: 90);
      final fight = _mainEventFight('a', 'b');

      final localOrg = _organization(tier: ReputationTier.local);
      final nationalOrg = _organization(tier: ReputationTier.national);

      final localResult = EventFinanceCalculator(random: Random(4)).calculate(
        venue: Venue.newYorkNy,
        ticketPrice: Venue.newYorkNy.suggestedTicketPrice,
        organization: localOrg,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );
      final nationalResult = EventFinanceCalculator(random: Random(4)).calculate(
        venue: Venue.newYorkNy,
        ticketPrice: Venue.newYorkNy.suggestedTicketPrice,
        organization: nationalOrg,
        card: [fight],
        fighterLookup: {'a': a, 'b': b},
        promotionBudgetSpent: 0,
      );

      expect(localResult.ppvBuys, 0);
      expect(nationalResult.ppvBuys, greaterThan(0));
    });
  });
}
