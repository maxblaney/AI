import '../../data/models/models.dart';
import '../betting/fight_odds.dart';

/// One fighter's career *inside this promotion*. Every figure here is
/// accumulated from fights that happened on the org's own cards — a
/// fighter who signed with a 10-2 record and went 6-0 for you shows 6
/// fights, not 18. That's the whole point of the record book: it's the
/// promotion's history, not the sport's.
class OrgCareer {
  final String fighterId;
  int fights = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  int koWins = 0;
  int submissionWins = 0;
  int decisionWins = 0;
  int titleFightWins = 0;
  int mainEvents = 0;
  int longestWinStreak = 0;
  int totalFightSeconds = 0;
  int controlSeconds = 0;
  int knockdowns = 0;
  int significantStrikes = 0;
  int takedownsLanded = 0;
  int takedownsAttempted = 0;

  /// Takedowns the *opponent* attempted and landed against them, which is
  /// what takedown defense is measured from.
  int takedownsFaced = 0;
  int takedownsConceded = 0;

  OrgCareer(this.fighterId);

  /// KO/TKO, doctor stoppage and submission wins — anything that didn't
  /// reach the judges.
  int get finishes => koWins + submissionWins;

  double get averageFightSeconds => fights == 0 ? 0 : totalFightSeconds / fights;

  double? get takedownAccuracy =>
      takedownsAttempted == 0 ? null : takedownsLanded / takedownsAttempted;

  double? get takedownDefense =>
      takedownsFaced == 0 ? null : 1 - (takedownsConceded / takedownsFaced);
}

/// A single leaderboard: a title, and the fighters at the top of it.
class RecordCategory {
  final String title;

  /// Why a fighter qualifies, when the category has a minimum (e.g.
  /// takedown accuracy needs a few attempts before it means anything).
  final String? qualifier;
  final List<RecordEntry> entries;

  const RecordCategory({
    required this.title,
    required this.entries,
    this.qualifier,
  });
}

class RecordEntry {
  /// The fighter this row is about, or null for event-level records
  /// (biggest gate, most PPV buys) where the row is a show, not a person.
  final String? fighterId;

  /// Row label — a fighter's name, or an event's.
  final String fighterName;

  /// Preformatted, because these span counts, percentages and clock times.
  final String value;

  /// The number behind [value], used for ordering.
  final double sortValue;

  const RecordEntry({
    required this.fighterName,
    required this.value,
    required this.sortValue,
    this.fighterId,
  });
}

/// Builds the promotion's all-time leaderboards from its own fight
/// history.
class RecordBook {
  RecordBook._();

  /// How many entries each leaderboard shows.
  static const int topN = 5;

  /// Rate categories (accuracy, defense, shortest average time) need a
  /// floor, or a fighter with one lucky takedown tops the chart at 100%.
  static const int minTakedownAttempts = 5;
  static const int minTakedownsFaced = 5;
  static const int minFightsForAverages = 3;

  /// [fights] should be every *resolved* fight in the save; [fighters]
  /// maps id -> fighter for names. Fights are expected in chronological
  /// order (oldest first) so win streaks come out right — pass them
  /// ordered by event date.
  static List<RecordCategory> build({
    required List<Fight> fights,
    required Map<String, Fighter> fighters,
    List<MmaEvent> events = const [],
  }) {
    final careers = tally(fights: fights);
    final eventCategories = _eventCategories(events);
    if (careers.isEmpty) return eventCategories;

    String name(String id) => fighters[id]?.name ?? 'Unknown fighter';
    final all = careers.values.toList();

    List<RecordCategory> categories = [
      _count('Most Fights', all, name, (c) => c.fights),
      _count('Most Wins', all, name, (c) => c.wins),
      _count('Most Finishes', all, name, (c) => c.finishes),
      _count('Most KO/TKOs', all, name, (c) => c.koWins),
      _count('Most Submissions', all, name, (c) => c.submissionWins),
      _count('Most Decisions', all, name, (c) => c.decisionWins),
      _count('Longest Win Streak', all, name, (c) => c.longestWinStreak),
      _count('Most Title Fight Wins', all, name, (c) => c.titleFightWins),
      _count(
        'Most Bonuses',
        all,
        name,
        (c) => (fighters[c.fighterId]?.fightOfTheNightCount ?? 0) +
            (fighters[c.fighterId]?.performanceOfTheNightCount ?? 0),
      ),
      _clock(
        'Shortest Average Fight Time',
        all.where((c) => c.fights >= minFightsForAverages).toList(),
        name,
        (c) => c.averageFightSeconds,
        ascending: true,
        qualifier: 'min $minFightsForAverages fights',
      ),
      _clock('Most Total Fight Time', all, name, (c) => c.totalFightSeconds.toDouble()),
      _clock('Most Control Time', all, name, (c) => c.controlSeconds.toDouble()),
      _count('Knockdowns Landed', all, name, (c) => c.knockdowns),
      _count('Most Significant Strikes Landed', all, name,
          (c) => c.significantStrikes),
      _count('Most Takedowns Landed', all, name, (c) => c.takedownsLanded),
      _percent(
        'Highest Takedown Accuracy',
        all
            .where((c) => c.takedownsAttempted >= minTakedownAttempts)
            .toList(),
        name,
        (c) => c.takedownAccuracy,
        qualifier: 'min $minTakedownAttempts attempts',
      ),
      _percent(
        'Highest Takedown Defense',
        all.where((c) => c.takedownsFaced >= minTakedownsFaced).toList(),
        name,
        (c) => c.takedownDefense,
        qualifier: 'min $minTakedownsFaced faced',
      ),
      _count('Most Main Events', all, name, (c) => c.mainEvents),
      _biggestUpsets(fights, name),
      _doubleChamps(fights, fighters, name),
      ...eventCategories,
    ];

    // A leaderboard where everyone sits on zero says nothing — drop it
    // until someone has actually done the thing.
    return categories.where((c) => c.entries.isNotEmpty).toList();
  }

  /// The nights themselves, rather than the fighters on them. Built
  /// straight off completed events — the promotion's own box office.
  static List<RecordCategory> _eventCategories(List<MmaEvent> events) {
    final completed = events.where((e) => e.isCompleted).toList();
    if (completed.isEmpty) return const [];

    List<RecordEntry> rank(num Function(MmaEvent) valueOf,
        String Function(num) format) {
      return (completed
              .map((e) => (e, valueOf(e)))
              .where((pair) => pair.$2 > 0)
              .map((pair) => RecordEntry(
                    fighterName: pair.$1.name,
                    value: format(pair.$2),
                    sortValue: pair.$2.toDouble(),
                  ))
              .toList()
            ..sort((x, y) => y.sortValue.compareTo(x.sortValue)))
          .take(topN)
          .toList();
    }

    return [
      RecordCategory(
        title: 'Most PPV Buys in One Event',
        entries: rank((e) => e.ppvBuys, _thousands),
      ),
      RecordCategory(
        title: 'Highest Revenue in One Event',
        entries: rank((e) => e.revenue, (v) => '\$${_thousands(v)}'),
      ),
    ].where((c) => c.entries.isNotEmpty).toList();
  }

  /// Fights the betting line got most wrong. Measured off the price as
  /// it stood before the bout — bouts resolved before that was recorded
  /// simply don't qualify, rather than being scored on numbers that have
  /// since moved.
  static RecordCategory _biggestUpsets(
    List<Fight> fights,
    String Function(String) name,
  ) {
    final entries = fights
        .map((f) => (f, f.upsetMagnitude))
        .where((pair) => pair.$2 != null && pair.$2! > 0.5)
        .map((pair) {
          final fight = pair.$1;
          final winnerId = fight.result!.winnerId;
          final loserId = winnerId == fight.fighterAId
              ? fight.fighterBId
              : fight.fighterAId;
          final line = OddsCalculator.moneylineFor(1 - pair.$2!);
          return RecordEntry(
            fighterId: winnerId,
            fighterName: '${name(winnerId)} bt ${name(loserId)}',
            value: FightOdds.format(line),
            sortValue: pair.$2!,
          );
        })
        .toList()
      ..sort((x, y) => y.sortValue.compareTo(x.sortValue));

    return RecordCategory(
      title: 'Biggest Upsets',
      qualifier: 'underdog wins',
      entries: entries.take(topN).toList(),
    );
  }

  /// Fighters who have won an undisputed title in more than one
  /// division. Read off the fight history rather than who currently
  /// holds what, so a champion who later loses a belt keeps the record —
  /// it happened.
  static RecordCategory _doubleChamps(
    List<Fight> fights,
    Map<String, Fighter> fighters,
    String Function(String) name,
  ) {
    final divisionsWon = <String, Set<WeightClass>>{};
    for (final fight in fights) {
      final result = fight.result;
      if (result == null || result.isDraw) continue;
      if (fight.titleFightType != TitleFightType.championship) continue;
      divisionsWon
          .putIfAbsent(result.winnerId, () => <WeightClass>{})
          .add(fight.weightClass);
    }

    final entries = divisionsWon.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final divisions = WeightClass.values
              .where(e.value.contains)
              .map((w) => w.label)
              .join(' & ');
          // Holding them at the same time is the rarer thing, and worth
          // separating from winning them years apart.
          final simultaneous =
              (fighters[e.key]?.belts.length ?? 0) >= 2;
          return RecordEntry(
            fighterId: e.key,
            fighterName: name(e.key),
            value: simultaneous ? '$divisions (current)' : divisions,
            sortValue: e.value.length + (simultaneous ? 0.5 : 0),
          );
        })
        .toList()
      ..sort((x, y) => y.sortValue.compareTo(x.sortValue));

    return RecordCategory(
      title: 'Double Champs',
      qualifier: 'titles in 2+ divisions',
      entries: entries.take(topN).toList(),
    );
  }

  /// 12,400 rather than 12400 — these are numbers people read at a
  /// glance, not compare digit by digit.
  static String _thousands(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Accumulates per-fighter org careers. Exposed separately so the
  /// fighter profile can show a promotional record without rebuilding
  /// every leaderboard.
  static Map<String, OrgCareer> tally({required List<Fight> fights}) {
    final careers = <String, OrgCareer>{};
    final currentStreak = <String, int>{};

    OrgCareer careerFor(String id) =>
        careers.putIfAbsent(id, () => OrgCareer(id));

    for (final fight in fights) {
      final result = fight.result;
      if (result == null) continue;

      final a = careerFor(fight.fighterAId);
      final b = careerFor(fight.fighterBId);
      final duration = fightDurationSeconds(fight);

      for (final (career, stats, opponentStats) in [
        (a, result.statsA, result.statsB),
        (b, result.statsB, result.statsA),
      ]) {
        career.fights++;
        career.totalFightSeconds += duration;
        career.controlSeconds += stats.controlSeconds;
        career.knockdowns += stats.knockdowns;
        career.significantStrikes += stats.significantStrikesLanded;
        career.takedownsLanded += stats.takedownsLanded;
        career.takedownsAttempted += stats.takedownsAttempted;
        career.takedownsFaced += opponentStats.takedownsAttempted;
        career.takedownsConceded += opponentStats.takedownsLanded;
        if (fight.isMainEvent) career.mainEvents++;
      }

      if (result.isDraw) {
        a.draws++;
        b.draws++;
        currentStreak[a.fighterId] = 0;
        currentStreak[b.fighterId] = 0;
        continue;
      }

      final winner = result.winnerId == a.fighterId ? a : b;
      final loser = result.winnerId == a.fighterId ? b : a;

      winner.wins++;
      loser.losses++;
      switch (result.method) {
        case FightMethod.koTko:
        case FightMethod.doctorStoppage:
          winner.koWins++;
        case FightMethod.submission:
          winner.submissionWins++;
        case FightMethod.decision:
          winner.decisionWins++;
        case FightMethod.drawOrNc:
          break;
      }
      if (fight.isTitleFight) winner.titleFightWins++;

      final streak = (currentStreak[winner.fighterId] ?? 0) + 1;
      currentStreak[winner.fighterId] = streak;
      if (streak > winner.longestWinStreak) winner.longestWinStreak = streak;
      currentStreak[loser.fighterId] = 0;
    }

    return careers;
  }

  /// Total time a fight lasted: full rounds completed, plus however far
  /// into the final round it went.
  static int fightDurationSeconds(Fight fight) {
    final result = fight.result;
    if (result == null) return 0;
    final completedRounds = (result.round - 1).clamp(0, fight.rounds);
    return completedRounds * Fight.roundLengthSeconds + result.timeSeconds;
  }

  static String formatClock(num seconds) {
    final total = seconds.round();
    final minutes = total ~/ 60;
    final secs = total % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  static RecordCategory _count(
    String title,
    List<OrgCareer> careers,
    String Function(String) name,
    int Function(OrgCareer) valueOf, {
    String? qualifier,
  }) {
    final entries = careers
        .map((c) => (c, valueOf(c)))
        .where((pair) => pair.$2 > 0)
        .map((pair) => RecordEntry(
              fighterId: pair.$1.fighterId,
              fighterName: name(pair.$1.fighterId),
              value: '${pair.$2}',
              sortValue: pair.$2.toDouble(),
            ))
        .toList()
      ..sort((x, y) => y.sortValue.compareTo(x.sortValue));
    return RecordCategory(
      title: title,
      entries: entries.take(topN).toList(),
      qualifier: qualifier,
    );
  }

  static RecordCategory _clock(
    String title,
    List<OrgCareer> careers,
    String Function(String) name,
    double Function(OrgCareer) valueOf, {
    bool ascending = false,
    String? qualifier,
  }) {
    final entries = careers
        .map((c) => (c, valueOf(c)))
        .where((pair) => pair.$2 > 0)
        .map((pair) => RecordEntry(
              fighterId: pair.$1.fighterId,
              fighterName: name(pair.$1.fighterId),
              value: formatClock(pair.$2),
              sortValue: pair.$2,
            ))
        .toList()
      ..sort((x, y) => ascending
          ? x.sortValue.compareTo(y.sortValue)
          : y.sortValue.compareTo(x.sortValue));
    return RecordCategory(
      title: title,
      entries: entries.take(topN).toList(),
      qualifier: qualifier,
    );
  }

  static RecordCategory _percent(
    String title,
    List<OrgCareer> careers,
    String Function(String) name,
    double? Function(OrgCareer) valueOf, {
    String? qualifier,
  }) {
    final entries = careers
        .map((c) => (c, valueOf(c)))
        .where((pair) => pair.$2 != null)
        .map((pair) => RecordEntry(
              fighterId: pair.$1.fighterId,
              fighterName: name(pair.$1.fighterId),
              value: '${(pair.$2! * 100).round()}%',
              sortValue: pair.$2!,
            ))
        .toList()
      ..sort((x, y) => y.sortValue.compareTo(x.sortValue));
    return RecordCategory(
      title: title,
      entries: entries.take(topN).toList(),
      qualifier: qualifier,
    );
  }
}
