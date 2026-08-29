import 'dart:math';

import '../../data/models/models.dart';
import 'pay_scale.dart';

class EventFinanceResult {
  final int attendance;
  final int ppvBuys;
  final int revenue;
  final int expenses;
  final int reputationChange;

  const EventFinanceResult({
    required this.attendance,
    required this.ppvBuys,
    required this.revenue,
    required this.expenses,
    required this.reputationChange,
  });

  int get netProfit => revenue - expenses;
}

/// Turns a booked card into attendance, PPV buys, revenue, expenses and a
/// reputation delta. Pure Dart so it can be unit tested independent of the
/// database/UI.
class EventFinanceCalculator {
  /// What a booked bout is worth in demand terms before anyone's name is
  /// considered — the value of simply having another fight on the card.
  static const double _drawPerBout = 6;

  /// Exponent applied to a fighter's popularity. Below 1 so star power
  /// has diminishing returns: two 40s draw less than one 80.
  static const double _popularityDamping = 0.8;

  final Random _random;

  EventFinanceCalculator({Random? random}) : _random = random ?? Random();

  /// [card] must be resolved (have a [Fight.result]) so performance ratings
  /// can factor into reputation; [fighterLookup] maps fighter id -> Fighter
  /// as of booking time (for popularity/purse figures). [ticketPrice] is
  /// whatever the player set at booking time (see [Venue.suggestedTicketPrice]
  /// for the default they started from).
  EventFinanceResult calculate({
    required Venue venue,
    required int ticketPrice,
    required Organization organization,
    required List<Fight> card,
    required Map<String, Fighter> fighterLookup,
    required int promotionBudgetSpent,
  }) {
    final mainEvent = card.firstWhere(
      (f) => f.isMainEvent,
      orElse: () => card.first,
    );
    final mainEventPopularity = _averagePopularity([
      fighterLookup[mainEvent.fighterAId],
      fighterLookup[mainEvent.fighterBId],
    ]);
    // Card draw is deliberately a *total*, not an average: a longer show
    // is worth more than a short one, and adding a bout should never make
    // an event draw worse. (It used to be an average, which meant booking
    // a prelim between two unknowns actively cut demand.) Each fighter's
    // contribution is damped so a deep card of nobodies still adds less
    // than one genuine star, and every booked bout is worth something on
    // its own — fans turn up for a full night of fights.
    final cardDraw = card.fold<double>(0, (sum, fight) {
      final a = fighterLookup[fight.fighterAId]?.popularity ?? 0;
      final b = fighterLookup[fight.fighterBId]?.popularity ?? 0;
      return sum +
          _drawPerBout +
          pow(a.toDouble(), _popularityDamping) +
          pow(b.toDouble(), _popularityDamping);
    });

    // Diminishing returns on promo spend: sqrt curve.
    final promoEffect = sqrt(promotionBudgetSpent.clamp(0, 500000)) * 4;

    final baseDemand =
        (organization.fanbaseSize * 0.015) +
        (mainEventPopularity * 9) +
        (cardDraw * 1.6) +
        promoEffect;

    // Price elasticity: pricing above the venue's suggested price softens
    // demand, pricing below it boosts demand, with diminishing effect at
    // the extremes (exponent < 1) so it never swings wildly.
    final priceRatio = ticketPrice <= 0
        ? 1.0
        : venue.suggestedTicketPrice / ticketPrice;
    final demandScore = baseDemand * pow(priceRatio, 0.6);

    final noise = 0.85 + _random.nextDouble() * 0.3; // +/-15%
    final rawAttendance = (demandScore * noise).round();
    final attendance = rawAttendance.clamp(0, venue.capacity);

    final ticketRevenue = attendance * ticketPrice;

    // PPV deals are a function of the org's standing, not the venue itself
    // — a national/international promotion can put a small-venue prelim
    // card on PPV, a local promotion can't even in a big rented arena.
    final canSellPpv = organization.reputationTier == ReputationTier.national ||
        organization.reputationTier == ReputationTier.international;
    // PPV moves on the same two levers as the gate — who's headlining,
    // and how much show there is behind them.
    final ppvBuys = canSellPpv
        ? ((organization.fanbaseSize * 0.01) +
                (mainEventPopularity * 15) +
                (cardDraw * 2.2) +
                promoEffect * 2)
            .round()
        : 0;
    final ppvRevenue = ppvBuys * 40;

    final revenue = ticketRevenue + ppvRevenue;

    // Each fighter takes home their contract's show money no matter what,
    // plus the win bonus on top if they actually won this fight.
    final purses = card.fold<int>(0, (sum, fight) {
      final result = fight.result;
      final aWon = result != null && !result.isDraw && result.winnerId == fight.fighterAId;
      final bWon = result != null && !result.isDraw && result.winnerId == fight.fighterBId;
      return sum +
          _purseFor(fighterLookup[fight.fighterAId], won: aWon) +
          _purseFor(fighterLookup[fight.fighterBId], won: bWon);
    });
    final expenses = venue.baseCost + purses + promotionBudgetSpent;

    final reputationChange = _reputationChange(
      card: card,
      netProfit: revenue - expenses,
      mainEventPopularity: mainEventPopularity,
    );

    return EventFinanceResult(
      attendance: attendance,
      ppvBuys: ppvBuys.clamp(0, 1 << 30),
      revenue: revenue,
      expenses: expenses,
      reputationChange: reputationChange,
    );
  }

  /// What [fighter] actually takes home from this fight — their contract's
  /// show money, plus the win bonus if [won]. A fighter with no contract
  /// on file (shouldn't normally happen mid-card) falls back to market
  /// rate off [PayScale].
  int _purseFor(Fighter? fighter, {required bool won}) {
    final contract = fighter?.contract;
    if (contract != null) {
      return won ? contract.payOnWin : contract.showMoney;
    }
    final suggested = PayScale.suggest(
      overall: fighter?.overall ?? 50,
      popularity: fighter?.popularity ?? 10,
    );
    return won ? suggested.total : suggested.showMoney;
  }

  double _averagePopularity(List<Fighter?> fighters) {
    final present = fighters.whereType<Fighter>().toList();
    if (present.isEmpty) return 0;
    return present.map((f) => f.popularity).reduce((a, b) => a + b) /
        present.length;
  }

  int _reputationChange({
    required List<Fight> card,
    required int netProfit,
    required double mainEventPopularity,
  }) {
    var change = 0;
    change += netProfit > 0 ? 1 : -1;
    if (mainEventPopularity >= 60) change += 1;

    final resolvedRatings = card
        .map((f) => f.result)
        .whereType<FightResult>()
        .map((r) => (r.winnerPerformanceRating + r.loserPerformanceRating) / 2)
        .toList();
    if (resolvedRatings.isNotEmpty) {
      final avgQuality =
          resolvedRatings.reduce((a, b) => a + b) / resolvedRatings.length;
      if (avgQuality >= 70) change += 1;
      if (avgQuality < 40) change -= 1;
    }
    return change.clamp(-5, 5);
  }
}
