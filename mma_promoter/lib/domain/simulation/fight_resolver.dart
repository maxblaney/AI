import 'dart:math';

import '../../data/models/models.dart';

/// Resolves a single matchup into a [FightResult] from the two fighters'
/// stats, morale and injury status, plus a controlled amount of randomness.
/// Simulates round by round (see [FightResult.roundScores]) rather than a
/// single dice roll, so the UI can replay the fight's momentum swing.
///
/// Pure Dart, no Flutter/DB dependencies, so it can be unit tested by
/// injecting a seeded [Random] for deterministic outcomes.
class FightResolver {
  final Random _random;

  FightResolver({Random? random}) : _random = random ?? Random();

  /// [rounds] is the fight's scheduled length (3 or 5) — see
  /// [Fight.rounds]. Fewer rounds appear in the result if the fight ends
  /// in an early finish.
  FightResult resolve({
    required Fighter fighterA,
    required Fighter fighterB,
    int rounds = 3,
  }) {
    final ratingA = _effectiveRating(fighterA);
    final ratingB = _effectiveRating(fighterB);

    final roundScores = <RoundScore>[];
    String? finishWinnerId;
    FightMethod? finishMethod;
    int? finishRound;

    for (var round = 1; round <= rounds; round++) {
      // How much of this specific round each fighter won, from the
      // overall rating gap plus per-round randomness (a bad round can
      // happen to anyone).
      final swing =
          (ratingA - ratingB) / 45 + (_random.nextDouble() - 0.5) * 0.55;
      final fighterAShare = (0.5 + swing).clamp(0.05, 0.95);
      roundScores.add(RoundScore(round: round, fighterAShare: fighterAShare));

      final dominantIsA = fighterAShare >= 0.5;
      final dominant = dominantIsA ? fighterA : fighterB;
      final dominated = dominantIsA ? fighterB : fighterA;
      final dominanceMagnitude = (fighterAShare - 0.5).abs() * 2; // 0..1
      final finishChance = 0.05 + dominanceMagnitude * 0.22;

      if (_random.nextDouble() < finishChance) {
        finishWinnerId = dominant.id;
        finishMethod = _rollFinishMethod(dominant, dominated);
        finishRound = round;
        break;
      }
    }

    final avgShare =
        roundScores.map((r) => r.fighterAShare).reduce((a, b) => a + b) /
            roundScores.length;

    late final String winnerId;
    late final FightMethod method;
    late final int decidedRound;

    if (finishWinnerId != null) {
      winnerId = finishWinnerId;
      method = finishMethod!;
      decidedRound = finishRound!;
    } else if ((avgShare - 0.5).abs() < 0.04 && _random.nextDouble() < 0.12) {
      winnerId = '';
      method = FightMethod.drawOrNc;
      decidedRound = rounds;
    } else {
      winnerId = avgShare >= 0.5 ? fighterA.id : fighterB.id;
      method = FightMethod.decision;
      decidedRound = rounds;
    }

    final isDraw = method == FightMethod.drawOrNc;
    final winnerShare = isDraw
        ? 0.5
        : (winnerId == fighterA.id ? avgShare : 1 - avgShare);
    final dominanceMargin = ((winnerShare - 0.5) * 100).round();

    final winnerPerformance = isDraw
        ? 50
        : _clampRating(60 +
            dominanceMargin +
            _random.nextInt(15) +
            (method != FightMethod.decision ? 8 : 0));
    final loserPerformance = isDraw
        ? 50
        : _clampRating(40 - dominanceMargin ~/ 2 + _random.nextInt(15));

    final fighterAWon = !isDraw && winnerId == fighterA.id;
    final fighterBWon = !isDraw && winnerId == fighterB.id;
    final fighterALostByKo = fighterBWon && method == FightMethod.koTko;
    final fighterBLostByKo = fighterAWon && method == FightMethod.koTko;

    return FightResult(
      winnerId: winnerId,
      method: method,
      round: decidedRound,
      winnerPerformanceRating: winnerPerformance,
      loserPerformanceRating: loserPerformance,
      fighterAInjury: _rollInjury(
        won: fighterAWon,
        draw: isDraw,
        lostByKo: fighterALostByKo,
      ),
      fighterBInjury: _rollInjury(
        won: fighterBWon,
        draw: isDraw,
        lostByKo: fighterBLostByKo,
      ),
      roundScores: roundScores,
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

  /// Only called once a round's outcome has already been decided as a
  /// finish — picks which kind, weighted by the finisher's tools against
  /// the other fighter's defense.
  FightMethod _rollFinishMethod(Fighter winner, Fighter loser) {
    final koWeight =
        (winner.stats.power + winner.stats.striking - loser.stats.chin)
            .clamp(10, 300);
    final subWeight =
        (winner.stats.grappling - loser.stats.grappling + 100).clamp(10, 300);
    final roll = _random.nextDouble() * (koWeight + subWeight);
    return roll < koWeight ? FightMethod.koTko : FightMethod.submission;
  }

  InjuryStatus _rollInjury({
    required bool won,
    required bool draw,
    required bool lostByKo,
  }) {
    double minorChance;
    double majorChance;
    if (lostByKo) {
      minorChance = 0.28;
      majorChance = 0.08;
    } else if (draw) {
      minorChance = 0.10;
      majorChance = 0.01;
    } else if (won) {
      minorChance = 0.06;
      majorChance = 0.01;
    } else {
      minorChance = 0.12;
      majorChance = 0.02;
    }

    final roll = _random.nextDouble();
    if (roll < majorChance) return InjuryStatus.major;
    if (roll < majorChance + minorChance) return InjuryStatus.minor;
    return InjuryStatus.healthy;
  }

  int _clampRating(int value) => value.clamp(0, 100);
}
