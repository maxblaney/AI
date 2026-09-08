import '../../data/models/models.dart';

/// How badly one division needs bodies.
enum DivisionNeed {
  /// Can't make a fight here at all.
  empty,

  /// One or two fighters — a fight is possible only if nobody is hurt,
  /// and it's the same fight every time.
  critical,

  /// Enough to book, not enough to book *well*.
  thin,

  /// Healthy.
  fine,
}

extension DivisionNeedInfo on DivisionNeed {
  String get label => switch (this) {
        DivisionNeed.empty => 'No fighters',
        DivisionNeed.critical => 'Critical',
        DivisionNeed.thin => 'Thin',
        DivisionNeed.fine => 'Fine',
      };

  /// Whether this is worth putting in front of the player.
  bool get needsAttention => this != DivisionNeed.fine;
}

/// Where a promotion is short of fighters, division by division.
///
/// The talent pool runs past a thousand names once a save has been going
/// a while, and "sign somebody" is useless advice against a list that
/// long. The useful question is narrower — *which* division can't make a
/// fight next month — and it's one the game can answer without the
/// player counting rows.
class DivisionNeeds {
  DivisionNeeds._();

  /// Below this a division can't put on a competitive card of its own:
  /// two fighters make one fight, and the same one every time.
  static const int criticalBelow = 4;

  /// Below this there is a division but no matchmaking in it — you can
  /// book, but you'll be repeating fights within the year.
  static const int thinBelow = 8;

  static DivisionNeed needFor(int count) {
    if (count == 0) return DivisionNeed.empty;
    if (count < criticalBelow) return DivisionNeed.critical;
    if (count < thinBelow) return DivisionNeed.thin;
    return DivisionNeed.fine;
  }

  /// Counts [roster] by division and grades each one.
  ///
  /// Every division appears, including the healthy ones — a caller that
  /// only wants the problems can filter on [DivisionNeedInfo.needsAttention].
  static Map<WeightClass, ({int count, DivisionNeed need})> assess(
    Iterable<Fighter> roster,
  ) {
    final counts = {for (final w in WeightClass.values) w: 0};
    for (final fighter in roster) {
      counts[fighter.weightClass] = (counts[fighter.weightClass] ?? 0) + 1;
    }
    return {
      for (final entry in counts.entries)
        entry.key: (count: entry.value, need: needFor(entry.value)),
    };
  }

  /// Just the divisions in trouble, worst first — what a scouting screen
  /// puts at the top.
  static List<({WeightClass division, int count, DivisionNeed need})> shortages(
    Iterable<Fighter> roster,
  ) {
    final assessed = assess(roster);
    final result = [
      for (final entry in assessed.entries)
        if (entry.value.need.needsAttention)
          (
            division: entry.key,
            count: entry.value.count,
            need: entry.value.need,
          ),
    ];
    result.sort((a, b) {
      final bySeverity = a.need.index.compareTo(b.need.index);
      return bySeverity != 0 ? bySeverity : a.count.compareTo(b.count);
    });
    return result;
  }
}
