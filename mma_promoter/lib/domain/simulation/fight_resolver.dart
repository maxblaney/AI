import 'dart:math';

import '../../data/models/models.dart';

/// Derived, ready-to-use ratings for one fighter in one resolution — keeps
/// [FightResolver.resolve] from recomputing the same composites on every
/// tick.
class _FighterProfile {
  final Fighter fighter;
  final double strikingRating;
  final double grapplingRating;
  final double overallRating; // style-weighted blend of the two above.
  final double durabilityRating;
  final double cardioRating;

  const _FighterProfile({
    required this.fighter,
    required this.strikingRating,
    required this.grapplingRating,
    required this.overallRating,
    required this.durabilityRating,
    required this.cardioRating,
  });
}

/// Resolves a single matchup into a [FightResult] from the two fighters'
/// stats, style, morale and injury status, plus a controlled amount of
/// randomness. Simulates several momentum ticks *within* every round (see
/// [FightResult.momentumTicks]) so the round-by-round view genuinely
/// fluctuates instead of jumping from one static value to the next.
///
/// Pure Dart, no Flutter/DB dependencies, so it can be unit tested by
/// injecting a seeded [Random] for deterministic outcomes.
class FightResolver {
  static const ticksPerRound = 4;

  final Random _random;

  FightResolver({Random? random}) : _random = random ?? Random();

  /// [rounds] is the fight's scheduled length (3 or 5) — see
  /// [Fight.rounds]. Fewer rounds' worth of ticks appear in the result if
  /// the fight ends in an early finish.
  FightResult resolve({
    required Fighter fighterA,
    required Fighter fighterB,
    int rounds = 3,
  }) {
    final profileA = _buildProfile(fighterA);
    final profileB = _buildProfile(fighterB);

    final ticks = <MomentumTick>[];
    String? finishWinnerId;
    FightMethod? finishMethod;
    int? finishRound;

    roundLoop:
    for (var round = 1; round <= rounds; round++) {
      // Cardio fatigue: worse gas tanks fade as the fight goes on.
      final fatigueA = _fatigueFactor(profileA.cardioRating, round);
      final fatigueB = _fatigueFactor(profileB.cardioRating, round);
      final ratingA = profileA.overallRating * fatigueA;
      final ratingB = profileB.overallRating * fatigueB;

      for (var tick = 0; tick < ticksPerRound; tick++) {
        final swing =
            (ratingA - ratingB) / 45 + (_random.nextDouble() - 0.5) * 0.7;
        final fighterAShare = (0.5 + swing).clamp(0.05, 0.95);
        ticks.add(MomentumTick(round: round, fighterAShare: fighterAShare));

        final dominantIsA = fighterAShare >= 0.5;
        final dominant = dominantIsA ? profileA : profileB;
        final dominated = dominantIsA ? profileB : profileA;
        final dominanceMagnitude = (fighterAShare - 0.5).abs() * 2; // 0..1

        // More aggressive fighters press for finishes harder when ahead.
        final aggressionBoost =
            0.85 + dominant.fighter.tendencies.aggression / 100 * 0.3;
        final finishChance = (0.05 + dominanceMagnitude * 0.22) *
            aggressionBoost /
            ticksPerRound;

        if (_random.nextDouble() < finishChance) {
          finishWinnerId = dominant.fighter.id;
          finishMethod = _rollFinishMethod(dominant, dominated);
          finishRound = round;
          break roundLoop;
        }
      }
    }

    final avgShare =
        ticks.map((t) => t.fighterAShare).reduce((a, b) => a + b) / ticks.length;

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
        durability: profileA.durabilityRating,
      ),
      fighterBInjury: _rollInjury(
        won: fighterBWon,
        draw: isDraw,
        lostByKo: fighterBLostByKo,
        durability: profileB.durabilityRating,
      ),
      momentumTicks: ticks,
    );
  }

  _FighterProfile _buildProfile(Fighter fighter) {
    final fs = fighter.fightingStats;
    final ps = fighter.physicalStats;

    final striking = (fs.punching + fs.kicking + fs.power + fs.speed + fs.accuracy) / 5;
    final grappling =
        (fs.takedowns + fs.wrestling + fs.groundAndPound + fs.submissionOffense + fs.grappling) /
            5;
    final durability = (ps.durability + ps.chin + ps.bodyToughness + ps.legToughness) / 4;
    final cardio = (ps.cardio + ps.recovery) / 2;

    final moraleFactor = 0.85 + (fighter.morale.clamp(0, 100) / 100) * 0.3;
    final injuryFactor = switch (fighter.injuryStatus) {
      InjuryStatus.healthy => 1.0,
      InjuryStatus.minor => 0.85,
      InjuryStatus.major => 0.6,
    };

    // Grapple-oriented styles lean on grapplingRating more than striking,
    // and vice versa — this is what gives FightingStyle real mechanical
    // weight rather than being cosmetic.
    final strikingWeight = switch (fighter.style) {
      FightingStyle.wrestler ||
      FightingStyle.wrestlingHeavy ||
      FightingStyle.bjj =>
        0.35,
      FightingStyle.wellRounded => 0.5,
      _ => 0.65,
    };
    final overall = striking * strikingWeight + grappling * (1 - strikingWeight);

    return _FighterProfile(
      fighter: fighter,
      strikingRating: striking * moraleFactor * injuryFactor,
      grapplingRating: grappling * moraleFactor * injuryFactor,
      overallRating: overall * moraleFactor * injuryFactor,
      durabilityRating: durability,
      cardioRating: cardio,
    );
  }

  /// Fighters with poor cardio fade in later rounds; well-conditioned
  /// fighters barely drop off.
  double _fatigueFactor(double cardioRating, int round) {
    if (round <= 1) return 1.0;
    final fatiguePerRound = (100 - cardioRating) / 100 * 0.06;
    return (1 - fatiguePerRound * (round - 1)).clamp(0.5, 1.0);
  }

  /// Only called once a tick's outcome has already been decided as a
  /// finish — picks which kind, weighted by the finisher's tools against
  /// the other fighter's specific defenses.
  FightMethod _rollFinishMethod(_FighterProfile winner, _FighterProfile loser) {
    final koWeight = (winner.fighter.fightingStats.power +
            winner.fighter.fightingStats.accuracy -
            loser.fighter.physicalStats.chin)
        .clamp(10, 300);
    final subWeight = (winner.fighter.fightingStats.submissionOffense -
            loser.fighter.fightingStats.submissionDefense +
            100)
        .clamp(10, 300);
    final roll = _random.nextDouble() * (koWeight + subWeight);
    return roll < koWeight ? FightMethod.koTko : FightMethod.submission;
  }

  InjuryStatus _rollInjury({
    required bool won,
    required bool draw,
    required bool lostByKo,
    required double durability,
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

    // Tougher fighters shrug off more of that risk; fragile ones eat more.
    final durabilityFactor = ((120 - durability) / 100).clamp(0.5, 1.5);
    minorChance *= durabilityFactor;
    majorChance *= durabilityFactor;

    final roll = _random.nextDouble();
    if (roll < majorChance) return InjuryStatus.major;
    if (roll < majorChance + minorChance) return InjuryStatus.minor;
    return InjuryStatus.healthy;
  }

  int _clampRating(int value) => value.clamp(0, 100);
}
