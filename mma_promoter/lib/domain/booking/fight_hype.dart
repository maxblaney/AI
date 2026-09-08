import 'dart:math';

import '../../data/models/models.dart';
import '../betting/fight_odds.dart';

/// How excited people are about a matchup, 0-100, and what that reads as
/// in words. Deliberately separate from who's likely to *win* — a squash
/// between a star and a nobody prices as a lock and sells nothing.
class FightHype {
  /// Overall hype, 0-100.
  final int score;

  /// The pieces behind [score], each 0-100, so the booking screen can
  /// explain why a fight is or isn't interesting rather than just
  /// showing a number.
  final int starPower;
  final int competitiveness;
  final int violence;
  final int stakes;

  const FightHype({
    required this.score,
    required this.starPower,
    required this.competitiveness,
    required this.violence,
    required this.stakes,
  });

  /// Five bands, matching how a matchmaker would actually talk about a
  /// fight.
  String get label {
    if (score >= 80) return 'Must-See';
    if (score >= 64) return 'Big Fight';
    if (score >= 48) return 'Solid Draw';
    if (score >= 30) return 'Decent Scrap';
    return 'Filler';
  }

  /// The single biggest thing holding this fight back, or null when
  /// nothing is. Points the player at the fix rather than leaving them
  /// to guess why the bar is short.
  String? get weakestLink {
    final parts = {
      'neither man is a draw yet': starPower,
      'it is too one-sided': competitiveness,
      'both are grinders': violence,
      'there is nothing on the line': stakes,
    };
    var worst = parts.entries.first;
    for (final entry in parts.entries) {
      if (entry.value < worst.value) worst = entry;
    }
    return worst.value >= 55 ? null : worst.key;
  }
}

/// Scores a matchup on the four things that actually sell a fight: who
/// the fighters are, whether it's competitive, whether it'll be violent,
/// and what's on the line.
class HypeCalculator {
  HypeCalculator._();

  // Weights sum to 1. Star power leads because a name sells a ticket
  // before anyone reads the tale of the tape; stakes is last because a
  // belt on a fight nobody wants to see is still a fight nobody wants
  // to see.
  static const double _starWeight = 0.34;
  static const double _competitivenessWeight = 0.24;
  static const double _violenceWeight = 0.24;
  static const double _stakesWeight = 0.18;

  static FightHype forFight({
    required Fighter a,
    required Fighter b,
    TitleFightType titleFightType = TitleFightType.none,
  }) {
    final star = _starPower(a, b);
    final competitiveness =
        _competitiveness(OddsCalculator.forFight(a: a, b: b));
    final violence = ((_violenceOf(a) + _violenceOf(b)) / 2).round();
    final stakes = _stakes(a, b, titleFightType);

    final score = star * _starWeight +
        competitiveness * _competitivenessWeight +
        violence * _violenceWeight +
        stakes * _stakesWeight;

    return FightHype(
      score: score.round().clamp(0, 100),
      starPower: star,
      competitiveness: competitiveness,
      violence: violence,
      stakes: stakes,
    );
  }

  /// One genuine star carries a card further than two mid-tier names, so
  /// the bigger draw is weighted more heavily than the average. Skill
  /// counts a little too: two unknown 90s are a better fight than two
  /// unknown 50s, even though nobody has heard of either.
  static int _starPower(Fighter a, Fighter b) {
    final top = max(a.popularity, b.popularity).toDouble();
    final other = min(a.popularity, b.popularity).toDouble();
    final draw = top * 0.65 + other * 0.35;

    // Skill maps 55 -> 0, 95 -> 100, so a division's best still register
    // as a real fight before they've built a following.
    final skill = (((a.overall + b.overall) / 2 - 55) / 0.40).clamp(0.0, 100.0);

    return (draw * 0.75 + skill * 0.25).round().clamp(0, 100);
  }

  /// A pick'em is the most interesting fight there is; a lock is the
  /// least. Straight off the betting line, so it reflects exactly what
  /// the player sees quoted next to the matchup.
  static int _competitiveness(FightOdds odds) {
    final edge = (odds.probabilityA - 0.5).abs() * 2; // 0 = even, 1 = lock.
    return ((1 - edge) * 100).round().clamp(0, 100);
  }

  /// How likely this fighter is to be in something worth watching.
  /// Power, aggression and a willingness to swing; positional control
  /// counts *against*, because a fighter whose plan is to hold someone
  /// down is the reason people leave early.
  static int _violenceOf(Fighter f) {
    final parts = [
      f.fightingStats.power,
      f.mentalStats.aggression,
      f.mentalStats.killerInstinct,
      f.tendencies.strikingFrequency,
      f.tendencies.headHunting,
      100 - f.tendencies.positionControl,
    ];
    return (parts.reduce((x, y) => x + y) / parts.length).round().clamp(0, 100);
  }

  /// What the fight is for. A belt is most of it; a champion in a
  /// non-title fight and a long streak still carry weight, because both
  /// mean the result matters to the division.
  static int _stakes(Fighter a, Fighter b, TitleFightType titleFightType) {
    var stakes = switch (titleFightType) {
      TitleFightType.championship => 82,
      TitleFightType.interim => 58,
      TitleFightType.none => 0,
    };

    if (titleFightType == TitleFightType.none) {
      // A champion taking a non-title fight is still an event.
      if (a.isChampion || b.isChampion) stakes += 26;
      if (a.isInterimChampion || b.isInterimChampion) stakes += 14;
    }
    // A run means something on its own — a 6-0 fighter is a story
    // whether or not there's a belt in the room.
    stakes += (a.winStreak.clamp(0, 6) + b.winStreak.clamp(0, 6)) * 4;
    if (a.isRanked && b.isRanked) stakes += 10;

    return stakes.clamp(0, 100);
  }
}
