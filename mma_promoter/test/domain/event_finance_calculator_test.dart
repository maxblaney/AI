import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/finance/event_finance_calculator.dart';

import '../support/fighter_fixtures.dart';

Fighter _fighter(
  String id, {
  required int popularity,
  int showMoney = 1000,
  int winBonus = 1000,
}) {
  return testFighter(
    id,
    stat: 70,
    popularity: popularity,
    contract: Contract(
      id: '$id-contract',
      fighterId: id,
      fightsRemaining: 3,
      showMoney: showMoney,
      winBonus: winBonus,
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

/// A card of [bouts] resolved fights between generic mid-popularity
/// fighters, for the breakdown tests below.
List<Fight> _plainCard(int bouts) => [
      for (var i = 0; i < bouts; i++)
        Fight(
          id: 'f$i',
          eventId: 'event-1',
          fighterAId: 'a$i',
          fighterBId: 'b$i',
          weightClass: WeightClass.lightweight,
          cardOrder: i,
          isMainEvent: i == 0,
          result: FightResult(
            winnerId: 'a$i',
            method: FightMethod.decision,
            round: 3,
            winnerPerformanceRating: 70,
            loserPerformanceRating: 60,
          ),
        ),
    ];

Map<String, Fighter> _plainLookup(int bouts) => {
      for (var i = 0; i < bouts; i++) ...{
        'a$i': _fighter('a$i', popularity: 40),
        'b$i': _fighter('b$i', popularity: 35),
      },
    };

void main() {
  _cardSizeAndPopularityTests();
  _venueAndPricingTests();

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
      final a = _fighter('a', popularity: 90, showMoney: 50000, winBonus: 50000);
      final b = _fighter('b', popularity: 90, showMoney: 50000, winBonus: 50000);
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

/// Card size and star power were the two levers that used to do nothing:
/// depth was averaged away, so adding a bout could actually *lower*
/// demand. These pin down that both now push revenue up.
void _cardSizeAndPopularityTests() {
  final calculator = EventFinanceCalculator(random: Random(7));

  EventFinanceResult run(List<Fight> card, Map<String, Fighter> lookup) =>
      calculator.calculate(
        venue: Venue.regionalUsa,
        ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
        organization: _organization(fanbaseSize: 20000),
        card: card,
        fighterLookup: lookup,
        promotionBudgetSpent: 0,
      );

  group('card size and popularity drive revenue', () {
    test('nobody turns out for a one-fight show', () {
      // The complaint this answers: a single bout was still drawing a
      // real crowd off the promotion's fanbase alone. A night of fights
      // is the product; one fight is not.
      final lookup = <String, Fighter>{};
      List<Fight> buildCard(int bouts) {
        final card = <Fight>[];
        for (var i = 0; i < bouts; i++) {
          lookup['a$i'] = _fighter('a$i', popularity: i == 0 ? 70 : 35);
          lookup['b$i'] = _fighter('b$i', popularity: i == 0 ? 70 : 35);
          card.add(Fight(
            id: 'f$i',
            eventId: 'e',
            fighterAId: 'a$i',
            fighterBId: 'b$i',
            weightClass: WeightClass.lightweight,
            cardOrder: i,
            isMainEvent: i == 0,
          ));
        }
        return card;
      }

      // Same headliner both times — only the depth behind them changes.
      final onlyTheMainEvent = run(buildCard(1), lookup);
      final fullCard = run(buildCard(10), lookup);

      expect(onlyTheMainEvent.attendance * 4,
          lessThan(fullCard.attendance),
          reason: 'a one-fight card should draw a small fraction of a '
              'full show, not most of it');
    });

    test('the depth multiplier climbs from a thin card to a full one', () {
      double depth(int bouts) =>
          EventFinanceCalculator.cardDepthMultiplier(bouts);

      expect(depth(0), 0, reason: 'no fights, no show');
      expect(depth(1), lessThan(0.25));
      expect(depth(5), greaterThan(0.6));
      expect(depth(12), greaterThan(0.95));
      expect(depth(30), lessThanOrEqualTo(1.0),
          reason: 'it saturates rather than running away');

      for (var bouts = 1; bouts < 20; bouts++) {
        expect(depth(bouts + 1), greaterThan(depth(bouts)),
            reason: 'another bout always helps');
      }
    });

    test('a deeper card out-earns a short one with the same headliner', () {
      final lookup = <String, Fighter>{};
      List<Fight> buildCard(int bouts) {
        final card = <Fight>[];
        for (var i = 0; i < bouts; i++) {
          final a = _fighter('a$i', popularity: 40);
          final b = _fighter('b$i', popularity: 40);
          lookup['a$i'] = a;
          lookup['b$i'] = b;
          card.add(Fight(
            id: 'f$i',
            eventId: 'e',
            fighterAId: 'a$i',
            fighterBId: 'b$i',
            weightClass: WeightClass.lightweight,
            cardOrder: i,
            isMainEvent: i == 0,
          ));
        }
        return card;
      }

      final short = run(buildCard(2), lookup);
      final deep = run(buildCard(8), lookup);

      expect(deep.revenue, greaterThan(short.revenue),
          reason: 'more fights should mean a bigger show');
    });

    test('adding a bout never makes an event worth less', () {
      final lookup = <String, Fighter>{};
      Fight bout(int i, int popularity) {
        lookup['a$i'] = _fighter('a$i', popularity: popularity);
        lookup['b$i'] = _fighter('b$i', popularity: popularity);
        return Fight(
          id: 'f$i',
          eventId: 'e',
          fighterAId: 'a$i',
          fighterBId: 'b$i',
          weightClass: WeightClass.lightweight,
          cardOrder: i,
          isMainEvent: i == 0,
        );
      }

      // A headline bout of stars, then an extra prelim between nobodies.
      final headlineOnly = [bout(0, 90)];
      final withPrelim = [bout(0, 90), bout(1, 1)];

      final before = run(headlineOnly, lookup);
      final after = run(withPrelim, lookup);

      expect(after.revenue, greaterThanOrEqualTo(before.revenue),
          reason: 'a low-profile prelim used to drag the average down');
    });

    test('a more popular card out-earns an equally deep unknown one', () {
      final lookup = <String, Fighter>{};
      List<Fight> buildCard(String prefix, int popularity) {
        final card = <Fight>[];
        for (var i = 0; i < 5; i++) {
          lookup['$prefix-a$i'] = _fighter('$prefix-a$i', popularity: popularity);
          lookup['$prefix-b$i'] = _fighter('$prefix-b$i', popularity: popularity);
          card.add(Fight(
            id: '$prefix-f$i',
            eventId: 'e',
            fighterAId: '$prefix-a$i',
            fighterBId: '$prefix-b$i',
            weightClass: WeightClass.lightweight,
            cardOrder: i,
            isMainEvent: i == 0,
          ));
        }
        return card;
      }

      final unknowns = run(buildCard('u', 10), lookup);
      final stars = run(buildCard('s', 85), lookup);

      expect(stars.revenue, greaterThan(unknowns.revenue));
    });
  });

}

void _venueAndPricingTests() {
  Fight bout(int i, Map<String, Fighter> lookup, int popularity) {
    lookup['a$i'] = _fighter('a$i', popularity: popularity);
    lookup['b$i'] = _fighter('b$i', popularity: popularity);
    return Fight(
      id: 'f$i',
      eventId: 'e',
      fighterAId: 'a$i',
      fighterBId: 'b$i',
      weightClass: WeightClass.lightweight,
      cardOrder: i,
      isMainEvent: i == 0,
      result: const FightResult(
        winnerId: 'a0',
        method: FightMethod.decision,
        round: 3,
        winnerPerformanceRating: 70,
        loserPerformanceRating: 60,
      ),
    );
  }

  EventFinanceResult run({
    required Venue venue,
    required int fanbase,
    int bouts = 8,
    int? ticketPrice,
  }) {
    final lookup = <String, Fighter>{};
    final card = [
      for (var i = 0; i < bouts; i++) bout(i, lookup, i == 0 ? 45 : 12),
    ];
    return EventFinanceCalculator(random: Random(7)).calculate(
      venue: venue,
      ticketPrice: ticketPrice ?? venue.suggestedTicketPrice,
      organization: _organization(fanbaseSize: fanbase),
      card: card,
      fighterLookup: lookup,
      promotionBudgetSpent: 0,
    );
  }

  group('venue choice', () {
    test('a bigger room does not conjure up a bigger crowd', () {
      // The bug this replaces: venues differed only by their suggested
      // ticket price, which demand was measured against — so renting an
      // arena doubled the gate off the same fanbase, for free.
      final small = run(venue: Venue.regionalUsa, fanbase: 8000);
      final huge = run(venue: Venue.bostonMa, fanbase: 8000);

      // A few hundred local walk-ups, not a multiple.
      expect(huge.attendance - small.attendance, lessThan(400));
      expect(huge.netProfit, lessThan(small.netProfit),
          reason: 'the rent on a room you cannot fill has to bite');
    });

    test('over-reaching costs reputation, filling the place earns it', () {
      final rightSized = run(venue: Venue.regionalUsa, fanbase: 8000);
      final tooBig = run(venue: Venue.atlantaGa, fanbase: 8000);

      expect(tooBig.reputationChange, lessThan(rightSized.reputationChange));
    });

    test('the smallest room in the game is never punished for being small',
        () {
      // There is nowhere smaller to go, so a thin crowd in it is a
      // circumstance, not a decision.
      expect(
        EventFinanceCalculator.venueOvershoot(
            venue: Venue.regionalUsa, attendance: 50),
        0,
      );
      expect(
        EventFinanceCalculator.venueOvershoot(
            venue: Venue.newYorkNy, attendance: 50),
        greaterThan(1),
      );
    });

    test('moving up pays once the small room caps you', () {
      // A promotion whose demand exceeds 3,500 is leaving money on the
      // floor; that, and only that, is what a bigger venue is for.
      final capped = run(venue: Venue.regionalUsa, fanbase: 600000, bouts: 11);
      final roomy = run(venue: Venue.hartfordCt, fanbase: 600000, bouts: 11);

      expect(capped.attendance, Venue.regionalUsa.capacity);
      expect(roomy.attendance, greaterThan(capped.attendance));
      expect(roomy.netProfit, greaterThan(capped.netProfit));
    });
  });

  group('ticket pricing', () {
    test('has a real optimum rather than a direction', () {
      // Both failure modes are wrong: with a weak exponent the answer was
      // always "charge more", with a strong one always "charge less". A
      // finite audience puts the best price in the middle.
      const venue = Venue.hartfordCt;
      const prices = [15, 25, 35, 45, 55, 70, 90, 120, 160];
      final revenues = [
        for (final price in prices)
          run(venue: venue, fanbase: 25000, ticketPrice: price).revenue,
      ];

      final best = revenues.reduce((a, b) => a > b ? a : b);
      final bestIndex = revenues.indexOf(best);
      expect(bestIndex, greaterThan(0),
          reason: 'giving tickets away should not be the best play');
      expect(bestIndex, lessThan(prices.length - 1),
          reason: 'nor should charging whatever you like');
    });

    test("the venue's suggested price is honest advice", () {
      for (final venue in [
        Venue.regionalUsa,
        Venue.hartfordCt,
        Venue.newYorkNy,
      ]) {
        final suggested = venue.suggestedTicketPrice;
        final atSuggested =
            run(venue: venue, fanbase: 60000, ticketPrice: suggested).revenue;
        final wayUnder =
            run(venue: venue, fanbase: 60000, ticketPrice: suggested ~/ 3)
                .revenue;
        final wayOver =
            run(venue: venue, fanbase: 60000, ticketPrice: suggested * 3)
                .revenue;

        expect(atSuggested, greaterThan(wayUnder));
        expect(atSuggested, greaterThan(wayOver));
      }
    });

    test('turnout falls as the price climbs, from a ceiling', () {
      const venue = Venue.regionalUsa;
      final reference =
          EventFinanceCalculator.referencePriceFor(venue).round();

      expect(
        EventFinanceCalculator.turnoutAt(ticketPrice: reference, venue: venue),
        closeTo(1.0, 0.02),
        reason: 'the reference price is the baseline by definition',
      );
      expect(
        EventFinanceCalculator.turnoutAt(ticketPrice: 1, venue: venue),
        lessThanOrEqualTo(1 + EventFinanceCalculator.priceCeilingBonus),
        reason: 'a free ticket still only reaches a finite audience',
      );

      var previous = double.infinity;
      for (var price = 5; price <= 200; price += 5) {
        final turnout =
            EventFinanceCalculator.turnoutAt(ticketPrice: price, venue: venue);
        expect(turnout, lessThan(previous));
        previous = turnout;
      }
    });
  });


  group('the breakdown explains the gate', () {
    test('the demand terms add up to what was actually used', () {
      final calc = EventFinanceCalculator(random: Random(3));
      final result = calc.calculate(
        venue: Venue.regionalUsa,
        ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
        organization: _organization(fanbaseSize: 8000),
        card: _plainCard(6),
        fighterLookup: _plainLookup(6),
        promotionBudgetSpent: 5000,
      );
      final b = result.breakdown;

      // Every term the model uses is reported, so the arithmetic on the
      // results page reads straight down rather than being asserted.
      expect(b.rawDemand,
          b.fromFanbase + b.fromMainEvent + b.fromCard + b.fromPromotion +
              b.fromWalkUp);
      expect(b.fromFanbase, greaterThan(0));
      expect(b.fromWalkUp, Venue.regionalUsa.localWalkUp.round());
      expect(b.fromPromotion, greaterThan(0),
          reason: 'promo spend bought something');
    });

    test('the money split matches the totals it explains', () {
      final calc = EventFinanceCalculator(random: Random(3));
      final result = calc.calculate(
        venue: Venue.regionalUsa,
        ticketPrice: 60,
        organization: _organization(fanbaseSize: 8000),
        card: _plainCard(4),
        fighterLookup: _plainLookup(4),
        promotionBudgetSpent: 2000,
      );
      final b = result.breakdown;

      expect(b.ticketRevenue + b.ppvRevenue, result.revenue);
      expect(b.venueCost + b.purses + b.promotionSpend, result.expenses);
      expect(b.ticketRevenue, result.attendance * 60);
    });

    test('a sold-out room says so, and says what it turned away', () {
      final calc = EventFinanceCalculator(random: Random(3));
      final result = calc.calculate(
        // A huge following in the smallest hall in the game.
        venue: Venue.regionalUsa,
        ticketPrice: 20,
        organization: _organization(fanbaseSize: 900000),
        card: _plainCard(10),
        fighterLookup: _plainLookup(10),
        promotionBudgetSpent: 0,
      );

      expect(result.breakdown.soldOut, isTrue);
      expect(result.attendance, Venue.regionalUsa.capacity);
      expect(result.breakdown.uncappedAttendance,
          greaterThan(Venue.regionalUsa.capacity));
    });

    test('a dear ticket and a cheap one pull the multiplier apart', () {
      EventFinanceBreakdown at(int price) => EventFinanceCalculator(
            random: Random(3),
          )
              .calculate(
                venue: Venue.regionalUsa,
                ticketPrice: price,
                organization: _organization(fanbaseSize: 8000),
                card: _plainCard(6),
                fighterLookup: _plainLookup(6),
                promotionBudgetSpent: 0,
              )
              .breakdown;

      expect(at(20).priceMultiplier, greaterThan(1.0));
      expect(at(140).priceMultiplier, lessThan(1.0));
    });

    test('it survives the round trip through storage', () {
      final calc = EventFinanceCalculator(random: Random(3));
      final original = calc
          .calculate(
            venue: Venue.regionalUsa,
            ticketPrice: 55,
            organization: _organization(fanbaseSize: 8000),
            card: _plainCard(5),
            fighterLookup: _plainLookup(5),
            promotionBudgetSpent: 1000,
          )
          .breakdown;

      final restored = EventFinanceBreakdown.fromJson(
          jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>)!;

      expect(restored.rawDemand, original.rawDemand);
      expect(restored.depthMultiplier, original.depthMultiplier);
      expect(restored.priceMultiplier, original.priceMultiplier);
      expect(restored.soldOut, original.soldOut);
      expect(restored.purses, original.purses);
      expect(restored.ticketRevenue, original.ticketRevenue);
    });
  });
}
