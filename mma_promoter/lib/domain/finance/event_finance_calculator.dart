import 'dart:math';

import '../../data/models/models.dart';

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
  final Random _random;

  EventFinanceCalculator({Random? random}) : _random = random ?? Random();

  /// [card] must be resolved (have a [Fight.result]) so performance ratings
  /// can factor into reputation; [fighterLookup] maps fighter id -> Fighter
  /// as of booking time (for popularity/purse figures).
  EventFinanceResult calculate({
    required VenueTier venueTier,
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
    final cardPopularity = _averagePopularity(
      card.expand((f) => [
            fighterLookup[f.fighterAId],
            fighterLookup[f.fighterBId],
          ]).toList(),
    );

    // Diminishing returns on promo spend: sqrt curve.
    final promoEffect = sqrt(promotionBudgetSpent.clamp(0, 500000)) * 4;

    final demandScore =
        (organization.fanbaseSize * 0.015) +
        (mainEventPopularity * 8) +
        (cardPopularity * 3) +
        promoEffect;

    final noise = 0.85 + _random.nextDouble() * 0.3; // +/-15%
    final rawAttendance = (demandScore * noise).round();
    final attendance = rawAttendance.clamp(0, venueTier.capacity);

    final ticketPrice = _ticketPrice(venueTier);
    final ticketRevenue = attendance * ticketPrice;

    final canSellPpv = venueTier == VenueTier.nationalArena ||
        venueTier == VenueTier.globalStadium;
    final ppvBuys = canSellPpv
        ? ((organization.fanbaseSize * 0.01) +
                (mainEventPopularity * 15) +
                promoEffect * 2)
            .round()
        : 0;
    final ppvRevenue = ppvBuys * 40;

    final revenue = ticketRevenue + ppvRevenue;

    final purses = card.expand((f) => [f.fighterAId, f.fighterBId]).fold<int>(
      0,
      (sum, id) {
        final fighter = fighterLookup[id];
        final pay = fighter?.contract?.payPerFight ??
            (500 + (fighter?.popularity ?? 10) * 20);
        return sum + pay;
      },
    );
    final expenses = venueTier.baseCost + purses + promotionBudgetSpent;

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

  int _ticketPrice(VenueTier tier) {
    switch (tier) {
      case VenueTier.localGym:
        return 25;
      case VenueTier.regionalArena:
        return 60;
      case VenueTier.nationalArena:
        return 120;
      case VenueTier.globalStadium:
        return 200;
    }
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
