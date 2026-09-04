import '../../data/models/models.dart';
import 'ladder.dart';

/// The order a single division's ladder runs in, and what each rung is
/// called.
///
/// Lives here rather than in the Rankings screen because the booking
/// dialog needs the same answer: "what number is this man in his
/// division" is context you want while making the fight, not only when
/// browsing a list. Two copies of the rule would drift.
class DivisionRankings {
  DivisionRankings._();

  /// Everyone who belongs on [division]'s ladder: its own ranked
  /// fighters, plus anyone who came up or down and took a belt there.
  static List<Fighter> pool(
    Iterable<Fighter> rankedFighters,
    WeightClass division,
  ) {
    return [
      for (final fighter in rankedFighters)
        if (fighter.weightClass == division || fighter.holdsAnyBeltIn(division))
          fighter,
    ];
  }

  /// [pool], ordered and cut to [Ladder.size]. The champion sits above
  /// the contenders whatever his Elo — that is what holding the belt
  /// means — then the interim champion, then everyone else on rating.
  ///
  /// A division has fifty fighters in it and a ranking is a top fifteen;
  /// numbering everyone to #47 makes the number mean nothing. Cutting
  /// here rather than in the screen means [labelFor] agrees: a fighter
  /// off the bottom of the ladder reads as unranked wherever he appears.
  static List<Fighter> order(
    Iterable<Fighter> rankedFighters,
    WeightClass division,
  ) {
    int belt(Fighter f) => f.championOf(division)
        ? 0
        : (f.interimChampionOf(division) ? 1 : 2);

    final sorted = pool(rankedFighters, division)
      ..sort((a, b) {
        final byBelt = belt(a).compareTo(belt(b));
        if (byBelt != 0) return byBelt;
        final byElo = b.eloRating.compareTo(a.eloRating);
        return byElo != 0 ? byElo : a.name.compareTo(b.name);
      });
    return Ladder.top(sorted);
  }

  /// One label per entry of [ordered]: 'C' for the champion, 'iC' for an
  /// interim champion, and contenders numbered from 1 — belt holders do
  /// not take a number, so the man below the champion is #1.
  static List<String> labels(List<Fighter> ordered, WeightClass division) {
    final labels = <String>[];
    var contender = 0;
    for (final fighter in ordered) {
      if (fighter.championOf(division)) {
        labels.add('C');
      } else if (fighter.interimChampionOf(division)) {
        labels.add('iC');
      } else {
        contender++;
        labels.add('$contender');
      }
    }
    return labels;
  }

  /// What [fighter] is called on [division]'s ladder, or null when they
  /// aren't on it — which for this game means they haven't fought for
  /// the promotion yet.
  static String? labelFor(
    Fighter fighter,
    Iterable<Fighter> rankedFighters,
    WeightClass division,
  ) {
    final ordered = order(rankedFighters, division);
    final index = ordered.indexWhere((f) => f.id == fighter.id);
    if (index < 0) return null;
    return labels(ordered, division)[index];
  }
}
