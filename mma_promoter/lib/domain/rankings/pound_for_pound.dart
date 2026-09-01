import '../../data/models/models.dart';
import 'ladder.dart';

/// Orders the pound-for-pound list.
///
/// P4P is a cross-division list, so it can't just be "champions first" —
/// there are eight of them and they can't all be number one. But a
/// champion being ranked below someone he holds the belt over reads as
/// broken, because it is: if the contender were really better, he'd have
/// the belt.
///
/// So the belt is worth exactly as much as it needs to be. A champion is
/// lifted just past the best contender in the division he holds, and no
/// further — his position against fighters from *other* divisions is
/// still earned on Elo. The lift is capped at [maxBeltCredit]: a
/// contender further clear of his own champion than that stays above him,
/// which is the extreme case the rule leaves room for.
class PoundForPound {
  PoundForPound._();

  /// The most a belt can be worth, in Elo. Roughly a two-fight gap — past
  /// that a contender is so far clear of his champion that the ranking
  /// should say so.
  static const int maxBeltCredit = 150;

  /// An interim belt is worth less: it's a placeholder, not the title.
  static const int maxInterimBeltCredit = 60;

  /// [fighters] should be the ranked pool. Returns a new list, highest
  /// first, leaving the input untouched.
  static List<Fighter> rank(List<Fighter> fighters) {
    final scores = scoresFor(fighters);
    final sorted = [...fighters]..sort((a, b) {
        final byScore = (scores[b.id] ?? b.eloRating)
            .compareTo(scores[a.id] ?? a.eloRating);
        if (byScore != 0) return byScore;
        // Ties break on raw Elo, then name, so the order is stable rather
        // than whatever the database happened to hand back.
        final byElo = b.eloRating.compareTo(a.eloRating);
        return byElo != 0 ? byElo : a.name.compareTo(b.name);
      });
    // A top fifteen, like every other ladder in the game.
    return Ladder.top(sorted);
  }

  /// The P4P score for every fighter in [fighters], keyed by id: their
  /// Elo plus whatever their belts are worth against their own division.
  static Map<String, int> scoresFor(List<Fighter> fighters) {
    // The best non-champion in each division — the bar a champion has to
    // clear to sit above his own contenders.
    final topContender = <WeightClass, int>{};
    for (final division in WeightClass.values) {
      for (final fighter in fighters) {
        if (fighter.weightClass != division) continue;
        if (fighter.championOf(division)) continue;
        final current = topContender[division];
        if (current == null || fighter.eloRating > current) {
          topContender[division] = fighter.eloRating;
        }
      }
    }

    return {
      for (final fighter in fighters)
        fighter.id: fighter.eloRating + _beltCredit(fighter, topContender),
    };
  }

  /// How much lift [fighter]'s belts are worth. A double champion takes
  /// the larger of the two, not both — holding a second belt shouldn't
  /// stack credit on top of the first.
  static int _beltCredit(Fighter fighter, Map<WeightClass, int> topContender) {
    var credit = 0;
    for (final division in fighter.belts) {
      credit = _larger(credit, fighter, topContender[division], maxBeltCredit);
    }
    for (final division in fighter.interimBelts) {
      credit =
          _larger(credit, fighter, topContender[division], maxInterimBeltCredit);
    }
    return credit;
  }

  static int _larger(
    int credit,
    Fighter fighter,
    int? contenderElo,
    int cap,
  ) {
    // Nobody to clear — an empty division asks nothing of the champion.
    if (contenderElo == null) return credit;
    // One point past the best contender, capped. A champion already ahead
    // of his division needs no help at all.
    final needed = (contenderElo - fighter.eloRating + 1).clamp(0, cap);
    return needed > credit ? needed : credit;
  }
}
