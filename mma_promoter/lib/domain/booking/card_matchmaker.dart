import '../../core/utils/id_generator.dart';
import '../../data/models/models.dart';
import 'fight_hype.dart';
import 'title_fight_rules.dart';

/// Builds a card out of whoever is available.
///
/// Booking ten fights by hand is ten trips through the same dialog, and
/// most of those bouts are prelims nobody agonises over. This picks a
/// sensible card in one go; the player still reorders, edits and
/// replaces whatever they don't like, which is the part worth their
/// time.
class CardMatchmaker {
  CardMatchmaker._();

  /// How far apart two fighters can sit on their division's ladder and
  /// still be matched. Adjacent pairings make competitive fights, which
  /// is what a matchmaker is for — a 1-vs-14 squash helps nobody.
  static const int maxLadderGap = 3;

  /// Picks up to [bouts] fights from [roster].
  ///
  /// [roster] should already be the fighters who *can* be booked —
  /// healthy, unsuspended, not on someone else's card. Anyone in
  /// [unavailable] is skipped on top of that, which is how a
  /// part-built card keeps its existing fighters out of the new bouts.
  ///
  /// Returns fewer than [bouts] when there aren't enough fighters, and an
  /// empty list when no division has a pair. Fights come back in running
  /// order, best first: index 0 is the main event.
  /// The most of a card's purse budget one fight may take. The main
  /// event is worth overpaying for, but a bout that eats half the gate
  /// on its own is how a promotion goes under.
  static const double maxMainEventShare = 0.45;

  /// How much hype a bout notionally loses for each time these two have
  /// already fought here.
  ///
  /// A penalty rather than a ban: a rematch of a war, or a title fight
  /// somebody is owed, is real matchmaking and should still be able to
  /// headline. What this stops is the auto-filler running the same bout
  /// month after month simply because it is the highest-rated pairing
  /// the ladder allows — which, left alone, it would.
  static const int rematchHypePenalty = 10;

  /// The key [priorMeetings] is read with. Order-independent, because a
  /// rematch is the same fight whichever corner is listed first.
  static String pairKey(String aId, String bId) =>
      (aId.compareTo(bId) <= 0) ? '$aId|$bId' : '$bId|$aId';

  static List<Fight> build({
    required List<Fighter> roster,
    required int bouts,
    Set<String> unavailable = const {},
    int rounds = 3,
    int mainEventRounds = 5,

    /// How many times each pair has already met, keyed by [pairKey].
    /// Pairs absent from the map are treated as first meetings.
    Map<String, int> priorMeetings = const {},

    /// Roughly what the night can afford to pay its fighters. Null means
    /// no ceiling, which is fine for a small roster and dangerous for a
    /// rich one — see [maxMainEventShare].
    int? purseBudget,
  }) {
    if (bouts <= 0) return const [];

    final used = {...unavailable};
    final candidates = <_Candidate>[];

    for (final division in WeightClass.values) {
      // Their own division only. Cross-division bookings are a
      // deliberate act — moving a fighter up to chase a second belt —
      // and not something to do to somebody automatically.
      final pool = roster
          .where((f) => f.weightClass == division && !used.contains(f.id))
          .toList()
        ..sort((a, b) {
          final byElo = b.eloRating.compareTo(a.eloRating);
          return byElo != 0 ? byElo : b.overall.compareTo(a.overall);
        });

      for (var i = 0; i < pool.length; i++) {
        for (var j = i + 1; j < pool.length && j <= i + maxLadderGap; j++) {
          final a = pool[i];
          final b = pool[j];
          final titleFightType = TitleFightRules.resolve(
            a: a,
            b: b,
            division: division,
            chosen: TitleFightType.none,
          );
          final hype = HypeCalculator.forFight(
            a: a,
            b: b,
            titleFightType: titleFightType,
          ).score;
          final met = priorMeetings[pairKey(a.id, b.id)] ?? 0;
          candidates.add(_Candidate(
            a: a,
            b: b,
            division: division,
            titleFightType: titleFightType,
            hype: (hype - met * rematchHypePenalty).clamp(0, 100),
          ));
        }
      }
    }

    if (candidates.isEmpty) return const [];

    final picked = <_Candidate>[];

    // The headline fight is the best one the night can afford. This is
    // the bout worth overpaying for — it is what sells the show — but
    // only up to a point: at the richer tiers the two best fighters on a
    // roster can cost more between them than the building can gross.
    final byHype = [...candidates]..sort((x, y) => y.hype.compareTo(x.hype));
    final mainEventCeiling = purseBudget == null
        ? null
        : (purseBudget * maxMainEventShare).round();
    final headliner = byHype.firstWhere(
      (c) => mainEventCeiling == null || c.purseCost <= mainEventCeiling,
      // Nothing fits, so the roster is priced beyond this venue
      // entirely — take the cheapest fight rather than no card at all,
      // and let the player see the loss and move to a bigger room.
      orElse: () => (
        [...candidates]..sort((x, y) => x.purseCost.compareTo(y.purseCost))
      ).first,
    );
    used
      ..add(headliner.a.id)
      ..add(headliner.b.id);
    picked.add(headliner);
    var spent = headliner.purseCost;

    // Everything under it is chosen on hype per dollar.
    //
    // Picking the whole card on hype alone is a trap, and a measurable
    // one: hype tracks popularity, popularity tracks overall, and purses
    // rise geometrically with overall — so "the ten best fights
    // available" is also "the ten most expensive fighters on the roster".
    // A year of those cards lost money at every tier above Local. A
    // matchmaker does not put its ten highest-paid fighters on one show;
    // it buys one main event and fills the undercard with value.
    final byValue = [...candidates]
      ..sort((x, y) => y.valuePerDollar.compareTo(x.valuePerDollar));
    for (final candidate in byValue) {
      if (picked.length >= bouts) break;
      if (used.contains(candidate.a.id) || used.contains(candidate.b.id)) {
        continue;
      }
      if (purseBudget != null && spent + candidate.purseCost > purseBudget) {
        continue;
      }
      used
        ..add(candidate.a.id)
        ..add(candidate.b.id);
      picked.add(candidate);
      spent += candidate.purseCost;
    }

    // The budget is a preference, not a wall. A promotion whose own
    // roster is priced beyond what it draws would otherwise get a
    // two-fight card and no explanation; better to fill the night with
    // the cheapest bouts left and let the results page show the player
    // exactly where the money went.
    if (picked.length < bouts) {
      final byCost = [...candidates]
        ..sort((x, y) => x.purseCost.compareTo(y.purseCost));
      for (final candidate in byCost) {
        if (picked.length >= bouts) break;
        if (used.contains(candidate.a.id) || used.contains(candidate.b.id)) {
          continue;
        }
        used
          ..add(candidate.a.id)
          ..add(candidate.b.id);
        picked.add(candidate);
      }
    }

    return [
      for (var i = 0; i < picked.length; i++)
        Fight(
          id: newId(),
          eventId: '',
          fighterAId: picked[i].a.id,
          fighterBId: picked[i].b.id,
          weightClass: picked[i].division,
          cardOrder: i,
          isMainEvent: i == 0,
          isCoMainEvent: picked.length > 1 && i == 1,
          // The main event goes five, the way a real one does — and a
          // title fight is a main event whether or not it opened as one.
          rounds: i == 0 || picked[i].titleFightType != TitleFightType.none
              ? mainEventRounds
              : rounds,
          titleFightType: picked[i].titleFightType,
        ),
    ];
  }
}

class _Candidate {
  final Fighter a;
  final Fighter b;
  final WeightClass division;
  final TitleFightType titleFightType;
  final int hype;

  const _Candidate({
    required this.a,
    required this.b,
    required this.division,
    required this.titleFightType,
    required this.hype,
  });

  /// What this bout costs to put on: both men's show money, plus the win
  /// bonus one of them is going to collect.
  int get purseCost {
    int payFor(Fighter f) => f.contract?.showMoney ?? 0;
    int bonusFor(Fighter f) => f.contract?.winBonus ?? 0;
    return payFor(a) +
        payFor(b) +
        ((bonusFor(a) + bonusFor(b)) / 2).round();
  }

  /// Hype bought per dollar of purse. The +1 keeps a fighter with no
  /// contract on file — which shouldn't happen mid-card, but might —
  /// from dividing by zero and swamping the ranking.
  double get valuePerDollar => hype / (purseCost + 1);
}
