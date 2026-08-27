/// Punching, kicking and grappling ability. Each stat is 1-100.
class FightingStats {
  final int punching;
  final int kicking;
  final int power;
  final int speed;
  final int accuracy;
  final int defense;
  final int takedowns;
  final int takedownDefense;
  final int wrestling;
  final int groundAndPound;
  final int submissionOffense;
  final int submissionDefense;
  final int grappling;

  const FightingStats({
    required this.punching,
    required this.kicking,
    required this.power,
    required this.speed,
    required this.accuracy,
    required this.defense,
    required this.takedowns,
    required this.takedownDefense,
    required this.wrestling,
    required this.groundAndPound,
    required this.submissionOffense,
    required this.submissionDefense,
    required this.grappling,
  });

  double get average =>
      (punching +
          kicking +
          power +
          speed +
          accuracy +
          defense +
          takedowns +
          takedownDefense +
          wrestling +
          groundAndPound +
          submissionOffense +
          submissionDefense +
          grappling) /
      13;

  FightingStats copyWith({
    int? punching,
    int? kicking,
    int? power,
    int? speed,
    int? accuracy,
    int? defense,
    int? takedowns,
    int? takedownDefense,
    int? wrestling,
    int? groundAndPound,
    int? submissionOffense,
    int? submissionDefense,
    int? grappling,
  }) {
    return FightingStats(
      punching: punching ?? this.punching,
      kicking: kicking ?? this.kicking,
      power: power ?? this.power,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      defense: defense ?? this.defense,
      takedowns: takedowns ?? this.takedowns,
      takedownDefense: takedownDefense ?? this.takedownDefense,
      wrestling: wrestling ?? this.wrestling,
      groundAndPound: groundAndPound ?? this.groundAndPound,
      submissionOffense: submissionOffense ?? this.submissionOffense,
      submissionDefense: submissionDefense ?? this.submissionDefense,
      grappling: grappling ?? this.grappling,
    );
  }
}

/// Conditioning and physical resilience. Each stat is 1-100.
class PhysicalStats {
  final int cardio;
  final int durability;
  final int chin;
  final int bodyToughness;
  final int legToughness;
  final int strength;
  final int athleticism;
  final int recovery;

  const PhysicalStats({
    required this.cardio,
    required this.durability,
    required this.chin,
    required this.bodyToughness,
    required this.legToughness,
    required this.strength,
    required this.athleticism,
    required this.recovery,
  });

  double get average =>
      (cardio +
          durability +
          chin +
          bodyToughness +
          legToughness +
          strength +
          athleticism +
          recovery) /
      8;

  PhysicalStats copyWith({
    int? cardio,
    int? durability,
    int? chin,
    int? bodyToughness,
    int? legToughness,
    int? strength,
    int? athleticism,
    int? recovery,
  }) {
    return PhysicalStats(
      cardio: cardio ?? this.cardio,
      durability: durability ?? this.durability,
      chin: chin ?? this.chin,
      bodyToughness: bodyToughness ?? this.bodyToughness,
      legToughness: legToughness ?? this.legToughness,
      strength: strength ?? this.strength,
      athleticism: athleticism ?? this.athleticism,
      recovery: recovery ?? this.recovery,
    );
  }
}

/// Decision-making and composure under fire. Each stat is 1-100.
class MentalStats {
  final int fightIq;
  final int composure;
  final int aggression;
  final int discipline;
  final int confidence;
  final int heart;
  final int adaptability;

  const MentalStats({
    required this.fightIq,
    required this.composure,
    required this.aggression,
    required this.discipline,
    required this.confidence,
    required this.heart,
    required this.adaptability,
  });

  double get average =>
      (fightIq + composure + aggression + discipline + confidence + heart + adaptability) /
      7;

  MentalStats copyWith({
    int? fightIq,
    int? composure,
    int? aggression,
    int? discipline,
    int? confidence,
    int? heart,
    int? adaptability,
  }) {
    return MentalStats(
      fightIq: fightIq ?? this.fightIq,
      composure: composure ?? this.composure,
      aggression: aggression ?? this.aggression,
      discipline: discipline ?? this.discipline,
      confidence: confidence ?? this.confidence,
      heart: heart ?? this.heart,
      adaptability: adaptability ?? this.adaptability,
    );
  }
}

/// Behavioral dials (0-100) that shape *how* a fighter fights, separate
/// from how *good* they are at it. A high `takedownFrequency` wrestler
/// with poor `wrestling` still shoots a lot of takedowns — they just don't
/// land them.
class Tendencies {
  final int strikingFrequency;
  final int takedownFrequency;
  final int kickFrequency;
  final int clinchFrequency;
  final int submissionAttempts;
  final int groundAndPound;
  final int aggression;
  final int counterStriking;
  final int headHunting;
  final int bodyAttacks;
  final int legAttacks;

  const Tendencies({
    required this.strikingFrequency,
    required this.takedownFrequency,
    required this.kickFrequency,
    required this.clinchFrequency,
    required this.submissionAttempts,
    required this.groundAndPound,
    required this.aggression,
    required this.counterStriking,
    required this.headHunting,
    required this.bodyAttacks,
    required this.legAttacks,
  });

  Tendencies copyWith({
    int? strikingFrequency,
    int? takedownFrequency,
    int? kickFrequency,
    int? clinchFrequency,
    int? submissionAttempts,
    int? groundAndPound,
    int? aggression,
    int? counterStriking,
    int? headHunting,
    int? bodyAttacks,
    int? legAttacks,
  }) {
    return Tendencies(
      strikingFrequency: strikingFrequency ?? this.strikingFrequency,
      takedownFrequency: takedownFrequency ?? this.takedownFrequency,
      kickFrequency: kickFrequency ?? this.kickFrequency,
      clinchFrequency: clinchFrequency ?? this.clinchFrequency,
      submissionAttempts: submissionAttempts ?? this.submissionAttempts,
      groundAndPound: groundAndPound ?? this.groundAndPound,
      aggression: aggression ?? this.aggression,
      counterStriking: counterStriking ?? this.counterStriking,
      headHunting: headHunting ?? this.headHunting,
      bodyAttacks: bodyAttacks ?? this.bodyAttacks,
      legAttacks: legAttacks ?? this.legAttacks,
    );
  }
}

/// Win-loss-draw record.
class FightRecord {
  final int wins;
  final int losses;
  final int draws;

  const FightRecord({this.wins = 0, this.losses = 0, this.draws = 0});

  int get totalFights => wins + losses + draws;

  String get display => '$wins-$losses-$draws';

  FightRecord copyWith({int? wins, int? losses, int? draws}) {
    return FightRecord(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
    );
  }

  FightRecord addWin() => copyWith(wins: wins + 1);
  FightRecord addLoss() => copyWith(losses: losses + 1);
  FightRecord addDraw() => copyWith(draws: draws + 1);

  Map<String, dynamic> toJson() => {
        'wins': wins,
        'losses': losses,
        'draws': draws,
      };

  factory FightRecord.fromJson(Map<String, dynamic> json) => FightRecord(
        wins: json['wins'] as int,
        losses: json['losses'] as int,
        draws: json['draws'] as int,
      );
}
