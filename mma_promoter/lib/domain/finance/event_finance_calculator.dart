import 'dart:math';

import '../../data/models/models.dart';
import 'pay_scale.dart';

/// Where a night's attendance and money actually came from.
///
/// The calculator was a black box: four numbers out, no way for a player
/// to tell whether they drew badly because the room was too big, the
/// ticket too dear or the card too thin. Every term it already computes
/// is reported here so the results page can show its working, and so the
/// pricing and venue decisions become something you can learn rather
/// than guess at.
///
/// The demand terms are in "expected heads" before the price response,
/// the depth multiplier and the capacity of the room are applied — the
/// multipliers are reported alongside so the arithmetic reads straight
/// down.
class EventFinanceBreakdown {
  /// Heads from the promotion's own following.
  final int fromFanbase;

  /// Heads the headliners are worth.
  final int fromMainEvent;

  /// Heads the rest of the card is worth, including the flat value of
  /// simply having another bout on it.
  final int fromCard;

  /// Heads bought with promotion spend.
  final int fromPromotion;

  /// Locals who turn up because there's a fight on, whoever is on it.
  /// Additive, and the one term the room itself provides.
  final int fromWalkUp;

  /// How much of a full night's demand a card this long earns — a thin
  /// card suppresses everything above it. 1.0 is a full show.
  final double depthMultiplier;

  /// What share of the reference-price crowd turned out at this ticket
  /// price. Above 1 means the ticket was cheap for this market.
  final double priceMultiplier;

  /// The +/-15% roll on the night.
  final double luckMultiplier;

  /// What the model wanted before the building's capacity was applied.
  final int uncappedAttendance;

  /// True when the room sold out and turned people away.
  final bool soldOut;

  /// How many venue sizes bigger than it needed the show was staged in.
  final int venueOvershoot;

  final int ticketRevenue;
  final int ppvRevenue;
  final int venueCost;
  final int purses;
  final int promotionSpend;

  const EventFinanceBreakdown({
    required this.fromFanbase,
    required this.fromMainEvent,
    required this.fromCard,
    required this.fromPromotion,
    required this.fromWalkUp,
    required this.depthMultiplier,
    required this.priceMultiplier,
    required this.luckMultiplier,
    required this.uncappedAttendance,
    required this.soldOut,
    required this.venueOvershoot,
    required this.ticketRevenue,
    required this.ppvRevenue,
    required this.venueCost,
    required this.purses,
    required this.promotionSpend,
  });

  /// The demand terms before any multiplier, which is what the shares
  /// below are taken against.
  int get rawDemand =>
      fromFanbase + fromMainEvent + fromCard + fromPromotion + fromWalkUp;

  Map<String, dynamic> toJson() => {
        'fan': fromFanbase,
        'me': fromMainEvent,
        'card': fromCard,
        'promo': fromPromotion,
        'walk': fromWalkUp,
        'depth': depthMultiplier,
        'price': priceMultiplier,
        'luck': luckMultiplier,
        'uncapped': uncappedAttendance,
        'soldOut': soldOut,
        'overshoot': venueOvershoot,
        'tickets': ticketRevenue,
        'ppv': ppvRevenue,
        'venue': venueCost,
        'purses': purses,
        'promoSpend': promotionSpend,
      };

  static EventFinanceBreakdown? fromJson(Map<String, dynamic> json) {
    int i(String k) => (json[k] as num?)?.round() ?? 0;
    double d(String k, double fallback) =>
        (json[k] as num?)?.toDouble() ?? fallback;
    return EventFinanceBreakdown(
      fromFanbase: i('fan'),
      fromMainEvent: i('me'),
      fromCard: i('card'),
      fromPromotion: i('promo'),
      fromWalkUp: i('walk'),
      depthMultiplier: d('depth', 1),
      priceMultiplier: d('price', 1),
      luckMultiplier: d('luck', 1),
      uncappedAttendance: i('uncapped'),
      soldOut: json['soldOut'] == true,
      venueOvershoot: i('overshoot'),
      ticketRevenue: i('tickets'),
      ppvRevenue: i('ppv'),
      venueCost: i('venue'),
      purses: i('purses'),
      promotionSpend: i('promoSpend'),
    );
  }
}

class EventFinanceResult {
  final int attendance;
  final int ppvBuys;
  final int revenue;
  final int expenses;
  final int reputationChange;

  /// Where all of the above came from.
  final EventFinanceBreakdown breakdown;

  const EventFinanceResult({
    required this.attendance,
    required this.ppvBuys,
    required this.revenue,
    required this.expenses,
    required this.reputationChange,
    required this.breakdown,
  });

  int get netProfit => revenue - expenses;
}

/// Turns a booked card into attendance, PPV buys, revenue, expenses and a
/// reputation delta. Pure Dart so it can be unit tested independent of the
/// database/UI.
/// What a card is expected to make, worked out while it is still being
/// built.
///
/// A card's cost is knowable the moment the fighters are picked, and its
/// gate is a decent guess from the same terms the real calculator uses —
/// but until this existed neither was shown until the night was already
/// run and the money already spent. Booking a show that could not pay
/// for itself was the easiest mistake in the game to make and the only
/// one you couldn't see coming.
class EventProjection {
  /// Expected heads, with no luck roll — the middle of the distribution
  /// rather than a promise.
  final int attendance;
  final int ticketRevenue;
  final int ppvRevenue;
  final int venueCost;

  /// Show money for everyone booked, plus one win bonus per bout.
  final int purses;

  const EventProjection({
    required this.attendance,
    required this.ticketRevenue,
    required this.ppvRevenue,
    required this.venueCost,
    required this.purses,
  });

  int get revenue => ticketRevenue + ppvRevenue;
  int get expenses => venueCost + purses;
  int get net => revenue - expenses;

  /// What share of the projected gate the fighters are taking. The
  /// number a matchmaker actually watches.
  double get purseShareOfRevenue => revenue == 0 ? 1 : purses / revenue;
}

class EventFinanceCalculator {
  /// What a booked bout is worth in demand terms before anyone's name is
  /// considered — the value of simply having another fight on the card.
  /// Set high enough that a middling prelim roughly pays for the seats it
  /// fills: a card that grows should be worth building, not just longer.
  static const double _drawPerBout = 30;

  /// Exponent applied to a fighter's popularity. Below 1 so star power
  /// has diminishing returns: two 40s draw less than one 80.
  static const double _popularityDamping = 0.8;

  /// What a card of *one* fight retains of a full show's demand. Nobody
  /// buys a ticket, books a hotel and drives to an arena for a single
  /// bout — the night has to be worth turning up for.
  static const double _shortCardFloor = 0.18;

  /// How fast the show fills out toward a full night. Higher = you need
  /// more bouts before the card stops feeling thin.
  static const double _depthScale = 3.2;

  /// Heads each fan of the promotion is worth on the night.
  ///
  /// This is the one demand term that grows as a promotion climbs, so it
  /// is what a tier is actually *for*. Set too low it stops mattering:
  /// with the card itself worth a thousand heads, a regional promotion
  /// with ten times a local one's following drew the same house for the
  /// same card while paying twice the purses — which made moving up a
  /// tier a straight downgrade.
  static const double fanbaseDrawRate = 0.045;

  /// The ticket price demand is measured against, market-wide.
  ///
  /// This used to be the venue's *own* suggested price, which meant
  /// charging a venue's suggested price was always demand-neutral — so a
  /// bigger building's higher suggestion was pure profit and moving up
  /// venues was free money. Pricing against one reference means $70 costs
  /// you customers whether you charge it in a regional hall or an arena;
  /// what the bigger arena actually buys you is [Venue.marketDraw].
  static const double referenceTicketPrice = 40;

  /// How sharply turnout falls as the price climbs.
  static const double priceElasticity = 1.6;

  /// How much bigger the crowd gets if tickets were nearly free — the
  /// ceiling on turnout, as a multiple of the crowd at the reference
  /// price.
  ///
  /// This is what gives ticket pricing a real answer. A plain elasticity
  /// exponent has no interior optimum: below 1 the best move is always to
  /// charge more, above 1 it's always to charge less. A finite audience
  /// fixes that — cutting the price stops buying you bodies once everyone
  /// who might come already is, so revenue peaks somewhere sensible and
  /// falls away on both sides.
  static const double priceCeilingBonus = 1.2;

  /// The price a given market bears: the reference, nudged by the venue's
  /// [Venue.priceLevel]. Mild on purpose — the gain from moving up is the
  /// seats, not the number on the stub.
  static double referencePriceFor(Venue venue) =>
      referenceTicketPrice * venue.priceLevel;

  /// What share of the reference-price crowd turns out at [ticketPrice].
  /// 1.0 at the market's reference price, rising toward
  /// `1 + priceCeilingBonus` as the price approaches free and falling
  /// away as it climbs.
  static double turnoutAt({required int ticketPrice, required Venue venue}) {
    if (ticketPrice <= 0) return 1 + priceCeilingBonus;
    final x = ticketPrice / referencePriceFor(venue);
    return (1 + priceCeilingBonus) /
        (1 + priceCeilingBonus * pow(x, priceElasticity));
  }

  /// Roughly how many people turn up for *any* card this promotion puts
  /// on at this room and price, before the card itself is considered.
  ///
  /// Only the terms that are knowable before a single fight is booked:
  /// the promotion's own following and the venue's walk-up. Exists so
  /// the matchmaker can work out what a night can afford to pay its
  /// fighters — using the building's capacity instead would assume a
  /// sellout, and a promotion drawing 1,600 into a 20,000-seat arena
  /// would budget five times what it takes at the gate.
  static int baselineAttendance({
    required Organization organization,
    required Venue venue,
    required int ticketPrice,
  }) {
    final base = organization.fanbaseSize * fanbaseDrawRate + venue.localWalkUp;
    final turnout = turnoutAt(ticketPrice: ticketPrice, venue: venue);
    return (base * turnout).round().clamp(0, venue.capacity);
  }

  /// How many venue sizes bigger than it needed a show was staged in.
  ///
  /// Judging an empty house on raw fill rate punished being small: a
  /// promotion drawing 600 into the smallest hall in the game got the
  /// same "look at all those empty seats" hit as one drawing 600 into an
  /// arena, and there was nowhere smaller for it to go. What actually
  /// deserves punishing is *over-reaching* — booking a room when a
  /// cheaper, smaller one would have held the crowd, which is a decision
  /// rather than a circumstance.
  static int venueOvershoot({required Venue venue, required int attendance}) {
    final bySize = [...Venue.values]
      ..sort((a, b) => a.capacity.compareTo(b.capacity));
    final used = bySize.indexOf(venue);
    for (var i = 0; i < bySize.length; i++) {
      // The smallest room that would still have held them, with a little
      // headroom so a near-sellout isn't called an overshoot.
      if (bySize[i].capacity >= attendance * 1.15) {
        return (used - i).clamp(0, bySize.length);
      }
    }
    return 0;
  }

  /// How much of a full night's demand a card of [bouts] fights earns.
  /// Rises from [_shortCardFloor] at one bout toward 1.0, effectively
  /// saturating around a real 10-12 fight card:
  ///
  ///   1 -> 0.18   2 -> 0.40   3 -> 0.56   4 -> 0.67
  ///   6 -> 0.81   8 -> 0.90  10 -> 0.94  12 -> 0.97
  ///
  /// This multiplies *all* demand, including the fanbase and main-event
  /// terms, which is the whole point: a promotion with 20,000 fans still
  /// can't sell out on the strength of one fight. It's separate from
  /// [_drawPerBout] — that says another bout adds draw, this says a thin
  /// card suppresses the draw everything else generated.
  static double cardDepthMultiplier(int bouts) {
    if (bouts <= 0) return 0;
    final fill = 1 - exp(-(bouts - 1) / _depthScale);
    return _shortCardFloor + (1 - _shortCardFloor) * fill;
  }

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

    final depth = cardDepthMultiplier(card.length);

    // Each demand term kept separately rather than summed on the spot,
    // so the results page can show where the crowd came from.
    final fanbaseDemand = organization.fanbaseSize * fanbaseDrawRate;
    final mainEventDemand = mainEventPopularity * 9;
    final cardDemand = cardDraw * 1.6;

    final baseDemand = (fanbaseDemand +
                mainEventDemand +
                cardDemand +
                promoEffect) *
            depth +
        // Locals who come because there's a fight on, whoever is on it.
        // Additive: the room does not multiply your following.
        venue.localWalkUp;

    // Price response, against what this market bears rather than against
    // whatever number the venue happens to suggest.
    final priceMultiplier = turnoutAt(ticketPrice: ticketPrice, venue: venue);
    final demandScore = baseDemand * priceMultiplier;
    final noise = 0.85 + _random.nextDouble() * 0.3; // +/-15%
    final rawAttendance = (demandScore * noise).round();
    final attendance = rawAttendance.clamp(0, venue.capacity);
    final fillRate = venue.capacity == 0 ? 1.0 : attendance / venue.capacity;

    final ticketRevenue = attendance * ticketPrice;

    // PPV deals are a function of the org's standing, not the venue itself
    // — a national/international promotion can put a small-venue prelim
    // card on PPV, a local promotion can't even in a big rented arena.
    final canSellPpv = organization.reputationTier == ReputationTier.national ||
        organization.reputationTier == ReputationTier.international;
    // PPV moves on the same two levers as the gate — who's headlining,
    // and how much show there is behind them.
    final ppvBuys = canSellPpv
        ? (((organization.fanbaseSize * 0.01) +
                    (mainEventPopularity * 15) +
                    (cardDraw * 2.2) +
                    promoEffect * 2) *
                depth)
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
    final overshoot = venueOvershoot(venue: venue, attendance: attendance);

    final reputationChange = _reputationChange(
      card: card,
      netProfit: revenue - expenses,
      mainEventPopularity: mainEventPopularity,
      fillRate: fillRate,
      overshoot: overshoot,
    );

    return EventFinanceResult(
      attendance: attendance,
      ppvBuys: ppvBuys.clamp(0, 1 << 30),
      revenue: revenue,
      expenses: expenses,
      reputationChange: reputationChange,
      breakdown: EventFinanceBreakdown(
        fromFanbase: fanbaseDemand.round(),
        fromMainEvent: mainEventDemand.round(),
        fromCard: cardDemand.round(),
        fromPromotion: promoEffect.round(),
        fromWalkUp: venue.localWalkUp.round(),
        depthMultiplier: depth,
        priceMultiplier: priceMultiplier,
        luckMultiplier: noise,
        uncappedAttendance: rawAttendance,
        soldOut: rawAttendance > venue.capacity,
        venueOvershoot: overshoot,
        ticketRevenue: ticketRevenue,
        ppvRevenue: ppvRevenue,
        venueCost: venue.baseCost,
        purses: purses,
        promotionSpend: promotionBudgetSpent,
      ),
    );
  }

  /// Runs the same demand model as [calculate] with the luck roll left
  /// out and results assumed, so a card can be costed while it is being
  /// built.
  ///
  /// Purses assume exactly one winner per bout, which is what happens
  /// unless a fight is drawn — so this is the honest number to plan
  /// against rather than a best case with no bonuses paid.
  static EventProjection project({
    required Venue venue,
    required int ticketPrice,
    required Organization organization,
    required List<Fight> card,
    required Map<String, Fighter> fighterLookup,
    int promotionBudgetSpent = 0,
  }) {
    if (card.isEmpty) {
      return EventProjection(
        attendance: 0,
        ticketRevenue: 0,
        ppvRevenue: 0,
        venueCost: venue.baseCost,
        purses: 0,
      );
    }

    final mainEvent = card.firstWhere(
      (f) => f.isMainEvent,
      orElse: () => card.first,
    );
    final mainEventPopularity = _averagePopularity([
      fighterLookup[mainEvent.fighterAId],
      fighterLookup[mainEvent.fighterBId],
    ]);
    final cardDraw = card.fold<double>(0, (sum, fight) {
      final a = fighterLookup[fight.fighterAId]?.popularity ?? 0;
      final b = fighterLookup[fight.fighterBId]?.popularity ?? 0;
      return sum +
          _drawPerBout +
          pow(a.toDouble(), _popularityDamping) +
          pow(b.toDouble(), _popularityDamping);
    });
    final promoEffect = sqrt(promotionBudgetSpent.clamp(0, 500000)) * 4;
    final depth = cardDepthMultiplier(card.length);

    final baseDemand = (organization.fanbaseSize * fanbaseDrawRate +
                mainEventPopularity * 9 +
                cardDraw * 1.6 +
                promoEffect) *
            depth +
        venue.localWalkUp;
    final attendance =
        (baseDemand * turnoutAt(ticketPrice: ticketPrice, venue: venue))
            .round()
            .clamp(0, venue.capacity);

    final canSellPpv = organization.reputationTier == ReputationTier.national ||
        organization.reputationTier == ReputationTier.international;
    final ppvBuys = canSellPpv
        ? (((organization.fanbaseSize * 0.01) +
                    (mainEventPopularity * 15) +
                    (cardDraw * 2.2) +
                    promoEffect * 2) *
                depth)
            .round()
        : 0;

    // One win bonus per bout, averaged across the two corners — which
    // one collects it isn't knowable yet, and the difference between
    // them is small next to the show money.
    final purses = card.fold<int>(0, (sum, fight) {
      final a = fighterLookup[fight.fighterAId];
      final b = fighterLookup[fight.fighterBId];
      final show = _purseFor(a, won: false) + _purseFor(b, won: false);
      final bonusA = (a?.contract?.winBonus ?? 0);
      final bonusB = (b?.contract?.winBonus ?? 0);
      return sum + show + ((bonusA + bonusB) / 2).round();
    });

    return EventProjection(
      attendance: attendance,
      ticketRevenue: attendance * ticketPrice,
      ppvRevenue: ppvBuys * 40,
      venueCost: venue.baseCost,
      purses: purses + promotionBudgetSpent,
    );
  }

  /// What [fighter] actually takes home from this fight — their contract's
  /// show money, plus the win bonus if [won]. A fighter with no contract
  /// on file (shouldn't normally happen mid-card) falls back to market
  /// rate off [PayScale].
  static int _purseFor(Fighter? fighter, {required bool won}) {
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

  static double _averagePopularity(List<Fighter?> fighters) {
    final present = fighters.whereType<Fighter>().toList();
    if (present.isEmpty) return 0;
    return present.map((f) => f.popularity).reduce((a, b) => a + b) /
        present.length;
  }

  int _reputationChange({
    required List<Fight> card,
    required int netProfit,
    required double mainEventPopularity,
    required double fillRate,
    required int overshoot,
  }) {
    var change = 0;
    change += netProfit > 0 ? 1 : -1;
    if (mainEventPopularity >= 60) change += 1;

    // A packed small hall is better for you than a third-full arena.
    // Rented a room two sizes bigger than the crowd needed and it shows
    // on camera; sold the place out and it does too.
    if (overshoot >= 2) {
      change -= 2;
    } else if (overshoot == 1) {
      change -= 1;
    }
    if (fillRate >= 0.9) change += 1;

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
