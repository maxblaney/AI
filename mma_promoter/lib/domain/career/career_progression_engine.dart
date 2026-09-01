import 'dart:math';

import '../../data/models/models.dart';

/// Pure-Dart engine for the "career" side of a fighter's life that isn't
/// resolved mid-fight: Elo movement, potential drift, and retirement.
/// Kept separate from [FightResolver] so each stays independently testable.
class CareerProgressionEngine {
  static const int _kFactor = 32;

  /// What one point of overall is worth, in Elo, when working out who was
  /// supposed to win.
  ///
  /// Elo on its own only knows a fighter's results, and everyone arrives
  /// at 1500 — so beating a 90-overall debutant paid exactly the same as
  /// beating a 60-overall one, which is wrong. Skill is information the
  /// ladder already has, so the expectation is set from both: a fighter's
  /// *effective* rating is their Elo shifted by how far their overall is
  /// from the divisional average.
  ///
  /// At 10 points per overall, a 90 sits 300 effective Elo above a 60 —
  /// about an 85% expected win rate, which is roughly how that fight
  /// should be priced. From 1500, beating the 90 is worth **+24** and
  /// beating the 60 **+11**; losing to the 60 costs the same way round.
  static const double skillEloPerOverallPoint = 10.0;

  /// The overall a fighter has to be at for skill to neither add to nor
  /// subtract from their effective rating. Set at the generated roster's
  /// average, so a typical fighter is rated purely on results.
  static const double baselineOverall = 72.0;

  /// Elo adjusted for how good a fighter visibly is, used only to work
  /// out the expected result — the update lands on their real Elo, which
  /// still moves purely on wins and losses.
  static double effectiveRating(int elo, double overall) =>
      elo + (overall - baselineOverall) * skillEloPerOverallPoint;

  final Random _random;

  CareerProgressionEngine({Random? random}) : _random = random ?? Random();

  /// Elo update. [scoreA] is 1.0 for a win, 0.5 for a draw, 0.0 for a
  /// loss, from fighter A's perspective. Returns the new (eloA, eloB).
  ///
  /// The expected result is computed from [effectiveRating] — Elo plus
  /// how good each fighter actually is — rather than raw Elo, so who you
  /// beat matters and not just that you won. The points still land on the
  /// stored Elo, which remains a record of results.
  ///
  /// [overallA] and [overallB] default to [baselineOverall], which makes
  /// this behave exactly like textbook Elo when skill isn't supplied.
  (int, int) updateElo(
    int eloA,
    int eloB,
    double scoreA, {
    double overallA = baselineOverall,
    double overallB = baselineOverall,
  }) {
    final ratingA = effectiveRating(eloA, overallA);
    final ratingB = effectiveRating(eloB, overallB);
    final expectedA = 1 / (1 + pow(10, (ratingB - ratingA) / 400));
    final expectedB = 1 - expectedA;
    final scoreB = 1 - scoreA;
    final newEloA = (eloA + _kFactor * (scoreA - expectedA)).round();
    final newEloB = (eloB + _kFactor * (scoreB - expectedB)).round();
    return (newEloA, newEloB);
  }

  /// Nudges [fighter]'s potential up on a long win streak, down on a long
  /// losing streak. Clamped so it never falls below the fighter's current
  /// overall (a fighter can't have "less potential" than what they already
  /// show) and never exceeds 99.
  int adjustPotential(
    Fighter fighter, {
    required int winStreak,
    required int lossStreak,
  }) {
    var potential = fighter.potential;
    if (winStreak >= 3) {
      potential += 1;
    } else if (lossStreak >= 3) {
      potential -= 1;
    }
    final floor = fighter.overall.round().clamp(30, 99);
    return potential.clamp(floor, 99);
  }

  /// Rolls for retirement based on age, losing streak, and major injury.
  /// Returns [fighter] unchanged unless retirement is triggered, in which
  /// case the returned copy has `retired: true`, a `retirementReason`, and
  /// its contract cleared.
  Fighter maybeRetire(Fighter fighter) {
    if (fighter.retired) return fighter;

    var chance = 0.0;
    String? reason;

    if (fighter.age >= 34) {
      chance += 0.03 * (fighter.age - 33);
      reason = 'Age';
    }
    if (fighter.lossStreak >= 3) {
      chance += 0.15 + 0.08 * (fighter.lossStreak - 3);
      reason = 'Losing streak';
    }
    if (fighter.injuryStatus == InjuryStatus.major) {
      chance += 0.2;
      reason = 'Career-ending injury';
    }

    if (chance <= 0) return fighter;
    chance = chance.clamp(0.0, 0.9);

    if (_random.nextDouble() < chance) {
      return fighter.copyWith(
        retired: true,
        retirementReason: reason ?? 'Retirement',
        clearContract: true,
      );
    }
    return fighter;
  }

  /// How many game weeks a fresh injury of [status] takes to heal on its
  /// own. Minor injuries are a short layoff; major injuries are a serious
  /// absence. Healthy never gets a countdown.
  int rollHealingWeeks(InjuryStatus status) {
    switch (status) {
      case InjuryStatus.minor:
        return 2 + _random.nextInt(5); // 2-6 weeks
      case InjuryStatus.major:
        return 10 + _random.nextInt(15); // 10-24 weeks
      case InjuryStatus.healthy:
        return 0;
    }
  }
}
