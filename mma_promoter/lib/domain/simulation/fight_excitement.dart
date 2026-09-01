import 'dart:math';

import '../../data/models/models.dart';

/// How good a fight was to watch, on the 1-10 scale a crowd would use.
class FightExcitement {
  /// 1 (nobody will remember this) to 10 (they'll be replaying it for
  /// years).
  final int rating;

  const FightExcitement._(this.rating);

  /// The band the rating falls in, for a word beside the number.
  String get label {
    if (rating >= 9) return 'Instant Classic';
    if (rating >= 7) return 'Barnburner';
    if (rating >= 5) return 'Good Scrap';
    if (rating >= 3) return 'Flat';
    return 'Forgettable';
  }

  /// Roughly how many minutes a fight ending in [round] at [timeSeconds]
  /// actually lasted. Rounds are five minutes.
  static double _minutesFought(int round, int timeSeconds) {
    final seconds = (round - 1) * 300 + timeSeconds;
    return seconds <= 0 ? 1 / 60 : seconds / 60;
  }

  /// Combined significant strikes per minute at which a fight counts as
  /// flat out. Both men's output together — a real barnburner sits
  /// around here and everything past it is already maxed.
  static const double _blisteringPace = 14;

  /// Rates the fight [result] of a bout scheduled for [scheduledRounds].
  ///
  /// Reads the box score rather than the play-by-play, so a fight loaded
  /// back from a save rates the same as one just watched — the momentum
  /// ticks and commentary aren't persisted, the statlines are.
  static FightExcitement rate({
    required FightResult result,
    required int scheduledRounds,
  }) {
    final a = result.statsA;
    final b = result.statsB;
    final minutes = _minutesFought(result.round, result.timeSeconds);

    // How well both men fought, which is what the resolver's own
    // performance ratings already measure. The biggest single input:
    // two men fighting well is most of what makes a fight good.
    final quality =
        (result.winnerPerformanceRating + result.loserPerformanceRating) / 2;

    // Output. Strikes landed per minute across both corners, against a
    // pace nobody exceeds for long.
    final strikes = a.significantStrikesLanded + b.significantStrikesLanded;
    final pace = min(1.0, (strikes / minutes) / _blisteringPace) * 100;

    // Somebody getting dropped is the single most memorable thing that
    // can happen short of the finish itself.
    final knockdowns = a.knockdowns + b.knockdowns;
    final damage = switch (knockdowns) {
      0 => 0.0,
      1 => 60.0,
      2 => 85.0,
      _ => 100.0,
    };

    // A fight nobody was winning is worth more than a shutout, however
    // well the winner performed.
    final gap =
        (result.winnerPerformanceRating - result.loserPerformanceRating).abs();
    final closeness = result.isDraw ? 100.0 : (100 - gap).clamp(0, 100).toDouble();

    var score = quality * 0.40 + pace * 0.25 + damage * 0.15 + closeness * 0.20;

    // The finish. A stoppage beats a decision, and a stoppage that
    // arrives after both men have been through something beats one that
    // arrives before the crowd has sat down.
    switch (result.method) {
      case FightMethod.koTko:
        score += 8;
        if (result.round >= 3 || result.round == scheduledRounds) score += 4;
      case FightMethod.submission:
        // A submission collects no knockdowns, so without a little extra
        // here the [damage] term alone would leave a slick finish rated
        // below the decision it beat.
        score += 11;
        if (result.round >= 3 || result.round == scheduledRounds) score += 4;
      case FightMethod.doctorStoppage:
        // An anticlimax by definition — the fight was stopped, not won.
        score -= 6;
      case FightMethod.drawOrNc:
        score -= 8;
      case FightMethod.decision:
        break;
    }

    // Lay-and-pray. Holding someone down for most of the fight is a way
    // to win it and a way to empty an arena — unless the holding was
    // how the fight got finished, which is a different thing entirely.
    final controlShare = (a.controlSeconds + b.controlSeconds) / (minutes * 60);
    if (controlShare > 0.55 && result.method != FightMethod.submission) {
      score -= min(15.0, (controlShare - 0.55) * 60);
    }

    return FightExcitement._(_toTen(score));
  }

  /// Where a fight has to score to earn each mark out of ten.
  ///
  /// Calibrated against the resolver rather than assumed: the raw score
  /// is a weighted blend whose components rarely go near their own
  /// extremes, so mapping 0-100 straight onto 1-10 put the average fight
  /// at 6.6. Anchoring the scale at 30 and 95 puts it at 5, which is
  /// what a middle mark is supposed to mean.
  static const double _floorScore = 30;
  static const double _ceilingScore = 95;

  static int _toTen(double score) {
    final t = (score - _floorScore) / (_ceilingScore - _floorScore);
    return (t.clamp(0, 1) * 9).round() + 1;
  }

  /// What this fight does to a fighter's standing with the fans.
  ///
  /// A win is worth something on its own, but the fight being worth
  /// watching is worth more: a man who loses a war gains fans and a man
  /// who wins a dull one loses them. Five is the neutral rating — at
  /// exactly average the winner picks up a couple of points and the
  /// loser gives one back, which is where this game sat before
  /// excitement was measured at all.
  static int popularityDelta({required int rating, required bool won,
      bool draw = false}) {
    final swing = rating - 5;
    if (draw) return swing;
    return (won ? 2 : -1) + swing;
  }
}
