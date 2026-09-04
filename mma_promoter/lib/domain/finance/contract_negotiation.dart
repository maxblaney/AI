import 'dart:math';

import 'pay_scale.dart';

/// How a fighter answered an offer.
enum OfferVerdict {
  /// They sign.
  accepted,

  /// Below what they will take, and they say so.
  rejected,
}

/// A fighter's answer, and what it would take to change it.
class OfferResponse {
  final OfferVerdict verdict;

  /// What the offer was measured against — show plus win bonus, since a
  /// fighter reads a deal as what they take home on a good night.
  final int marketRate;

  /// What was actually offered on the same basis.
  final int offered;

  /// The least they would have said yes to. Null when they accepted.
  final int? wouldAccept;

  const OfferResponse({
    required this.verdict,
    required this.marketRate,
    required this.offered,
    this.wouldAccept,
  });

  bool get accepted => verdict == OfferVerdict.accepted;

  /// What the offer is worth as a share of the market rate. 1.0 is the
  /// going rate; 0.5 is half of it.
  double get share => marketRate <= 0 ? 1 : offered / marketRate;
}

/// Whether a fighter takes the deal in front of them.
///
/// Contracts used to be whatever the player typed. The market rate was
/// shown beside the boxes as advice and nothing more, so a 93-overall
/// could be signed for \$1,000 to show and \$1,000 to win — a fighter
/// worth roughly \$160,000 a night taking a hundred and sixtieth of it,
/// with no one to say no. That made the pay curve, the tier ladder and
/// every affordability decision in the game optional.
///
/// Fighters now have a floor. Not the market rate itself — negotiating a
/// discount is a real part of the job and should still work — but a share
/// of it, below which they walk.
class ContractNegotiation {
  ContractNegotiation._();

  /// The least a fighter will take, as a share of their market rate,
  /// before anything about them is considered.
  ///
  /// Deliberately generous: 70% leaves genuine room to haggle, and a
  /// player who reads the market rate and offers a bit under it still
  /// gets their man. What it stops is the offer that isn't an offer.
  static const double baseFloor = 0.70;

  /// How much of a premium the very best command on top of that.
  ///
  /// A journeyman will take what is going. A contender with a queue of
  /// promotions behind you knows exactly what he is worth, and the floor
  /// rises toward the full market rate as overall does.
  static const double eliteFloorPremium = 0.25;

  /// A popular fighter knows his own worth too — fame is leverage.
  static const double fameFloorPremium = 0.10;

  /// The share of market rate [overall] and [popularity] will not go
  /// below.
  static double floorFor({required double overall, required int popularity}) {
    // Ramps in across the stretch where fighters stop being replaceable:
    // 70 is a solid pro, 95 is someone every promotion wants.
    final elite = ((overall - 70) / 25).clamp(0.0, 1.0);
    final fame = (popularity / 100).clamp(0.0, 1.0);
    return (baseFloor +
            elite * eliteFloorPremium +
            fame * fameFloorPremium)
        .clamp(0.0, 1.0);
  }

  /// Puts an offer of [showMoney] and [winBonus] to a fighter.
  ///
  /// [random] is unused for now — the answer is deterministic, so a
  /// player can find the number that works and trust it rather than
  /// re-rolling the same offer until it lands.
  static OfferResponse consider({
    required double overall,
    required int popularity,
    required int showMoney,
    required int winBonus,
    Random? random,
  }) {
    final market = PayScale.suggest(overall: overall, popularity: popularity);
    final marketRate = market.total;
    final offered = showMoney + winBonus;
    final floor = floorFor(overall: overall, popularity: popularity);
    final least = (marketRate * floor).round();

    if (offered >= least) {
      return OfferResponse(
        verdict: OfferVerdict.accepted,
        marketRate: marketRate,
        offered: offered,
      );
    }
    return OfferResponse(
      verdict: OfferVerdict.rejected,
      marketRate: marketRate,
      offered: offered,
      wouldAccept: least,
    );
  }
}
