import 'dart:math';

import '../../data/models/models.dart';

/// Resolves a single matchup into a [FightResult] from the two fighters'
/// stats, morale and injury status, plus a controlled amount of randomness.
///
/// Pure Dart, no Flutter/DB dependencies, so it can be unit tested by
/// injecting a seeded [Random] for deterministic outcomes.
class FightResolver {
  final Random _random;

  FightResolver({Random? random}) : _random = random ?? Random();

  FightResult resolve({
    required Fighter fighterA,
    required Fighter fighterB,
    bool isTitleFight = false,
    bool isMainEvent = false,
  }) {
    final ratingA = _effectiveRating(fighterA);
    final ratingB = _effectiveRating(fighterB);

    // Elo-style win probability from the rating gap.
    final probabilityAWins =
        1 / (1 + pow(10, (ratingB - ratingA) / 20).toDouble());

    final roll = _random.nextDouble();
    const drawChance = 0.03;

    if (roll < drawChance) {
      return FightResult(
        winnerId: '',
        method: FightMethod.drawOrNc,
        round: _roundLimit(isTitleFight, isMainEvent),
        winnerPerformanceRating: 50,
        loserPerformanceRating: 50,
      );
    }

    final aWins = (roll - drawChance) / (1 - drawChance) < probabilityAWins;
    final winner = aWins ? fighterA : fighterB;
    final loser = aWins ? fighterB : fighterA;
    final winnerRating = aWins ? ratingA : ratingB;

    final method = _rollMethod(winner, loser);
    final roundLimit = _roundLimit(isTitleFight, isMainEvent);
    final round = _rollRound(method, roundLimit);

    final dominanceMargin = (winnerRating - _effectiveRating(loser))
        .clamp(-40, 40)
        .round();
    final winnerPerformance = _clampRating(
      65 + dominanceMargin + _random.nextInt(15),
    );
    final loserPerformance = _clampRating(
      45 - dominanceMargin ~/ 2 - (round == 1 ? 10 : 0) + _random.nextInt(10),
    );

    return FightResult(
      winnerId: winner.id,
      method: method,
      round: round,
      winnerPerformanceRating: winnerPerformance,
      loserPerformanceRating: loserPerformance,
    );
  }

  double _effectiveRating(Fighter fighter) {
    final moraleFactor = 0.85 + (fighter.morale.clamp(0, 100) / 100) * 0.3;
    final injuryFactor = switch (fighter.injuryStatus) {
      InjuryStatus.healthy => 1.0,
      InjuryStatus.minor => 0.85,
      InjuryStatus.major => 0.6,
    };
    return fighter.stats.overall * moraleFactor * injuryFactor;
  }

  FightMethod _rollMethod(Fighter winner, Fighter loser) {
    final koChance =
        (winner.stats.power + winner.stats.striking - loser.stats.chin) / 300;
    final subChance = (winner.stats.grappling - loser.stats.grappling + 50) /
        400;

    final roll = _random.nextDouble();
    if (roll < koChance.clamp(0.05, 0.55)) return FightMethod.koTko;
    if (roll < koChance.clamp(0.05, 0.55) + subChance.clamp(0.05, 0.4)) {
      return FightMethod.submission;
    }
    return FightMethod.decision;
  }

  int _roundLimit(bool isTitleFight, bool isMainEvent) {
    return (isTitleFight || isMainEvent) ? 5 : 3;
  }

  int _rollRound(FightMethod method, int roundLimit) {
    if (method == FightMethod.decision || method == FightMethod.drawOrNc) {
      return roundLimit;
    }
    // Finishes skew toward earlier rounds but can happen any time.
    final weightedRoll = _random.nextDouble() * _random.nextDouble();
    return 1 + (weightedRoll * roundLimit).floor().clamp(0, roundLimit - 1);
  }

  int _clampRating(int value) => value.clamp(0, 100);
}
