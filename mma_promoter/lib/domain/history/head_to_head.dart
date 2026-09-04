import '../../data/models/models.dart';

/// What two fighters have already done to each other inside this
/// promotion.
///
/// A card tile that reads "Adeleke vs Szymanski" the second time around
/// is telling the player less than it looks like it is: the interesting
/// fact about that booking is that it *has* happened before, and how it
/// went. Booking a rematch is a deliberate act — you either want to
/// settle something or you've forgotten you already ran it — and the
/// difference shouldn't depend on the player's memory.
class HeadToHead {
  /// The corner this series is counted from, so [winsA] and [winsB] can
  /// be read without guessing which way round they go.
  final String fighterAId;
  final String fighterBId;
  final int winsA;
  final int winsB;
  final int draws;

  /// The most recent meeting's outcome — null when they haven't met.
  final FightResult? lastResult;

  const HeadToHead({
    required this.fighterAId,
    required this.fighterBId,
    this.winsA = 0,
    this.winsB = 0,
    this.draws = 0,
    this.lastResult,
  });

  /// How many times they have already fought here.
  int get meetings => winsA + winsB + draws;

  bool get isRematch => meetings > 0;

  /// What the *next* bout between them would be called. A rematch is the
  /// second meeting, a trilogy bout the third; past that the sport
  /// simply counts.
  String get label => switch (meetings) {
        0 => '',
        1 => 'Rematch',
        2 => 'Trilogy Bout',
        _ => '${_ordinal(meetings + 1)} Meeting',
      };

  /// Where the series stands, written for a reader who knows the two
  /// names: "Adeleke won by KO R2" for a single prior meeting, "Adeleke
  /// leads 2-1" once there's a series to lead.
  ///
  /// [nameA] and [nameB] must line up with [fighterAId] and [fighterBId].
  String summary(String nameA, String nameB) {
    final last = lastResult;
    if (last == null) return '';

    if (meetings == 1) {
      if (last.isDraw) return 'Drew ${_shortMethod(last)}';
      final winner = last.winnerId == fighterAId ? nameA : nameB;
      return '$winner won by ${_shortMethod(last)}';
    }

    final drawPart = draws > 0 ? '-$draws' : '';
    if (winsA == winsB) return 'Series level $winsA-$winsB$drawPart';
    final leadsA = winsA > winsB;
    final leader = leadsA ? nameA : nameB;
    final high = leadsA ? winsA : winsB;
    final low = leadsA ? winsB : winsA;
    return '$leader leads $high-$low$drawPart';
  }

  /// Reads every prior meeting between [aId] and [bId] out of [fights].
  ///
  /// [fights] is expected newest first (the order the repository's
  /// resolved-fight queries come back reversed into), and unresolved
  /// bouts are skipped — a booked rematch that hasn't been run yet is
  /// not part of the series.
  static HeadToHead from({
    required Iterable<Fight> fights,
    required String aId,
    required String bId,
  }) {
    var winsA = 0, winsB = 0, draws = 0;
    FightResult? last;

    for (final fight in fights) {
      final result = fight.result;
      if (result == null) continue;
      final isThisPair =
          (fight.fighterAId == aId && fight.fighterBId == bId) ||
              (fight.fighterAId == bId && fight.fighterBId == aId);
      if (!isThisPair) continue;

      last ??= result;
      if (result.isDraw) {
        draws++;
      } else if (result.winnerId == aId) {
        winsA++;
      } else {
        winsB++;
      }
    }

    return HeadToHead(
      fighterAId: aId,
      fighterBId: bId,
      winsA: winsA,
      winsB: winsB,
      draws: draws,
      lastResult: last,
    );
  }

  /// "KO R2", "SUB R1", "Decision" — the same shorthand a form line uses,
  /// because it's the same fact being reported.
  static String _shortMethod(FightResult result) {
    final name = switch (result.method) {
      FightMethod.koTko => 'KO',
      FightMethod.submission => 'SUB',
      FightMethod.doctorStoppage => 'Doctor Stoppage',
      FightMethod.decision => 'Decision',
      FightMethod.drawOrNc => 'Draw',
    };
    if (result.method == FightMethod.decision ||
        result.method == FightMethod.drawOrNc) {
      return name;
    }
    return '$name R${result.round}';
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}
