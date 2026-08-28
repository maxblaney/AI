/// Striking, wrestling and grappling ability. Each stat is 1-100.
///
/// Grouped conceptually as striking (offense + defense), wrestling
/// (takedowns + clinch) and ground (top game, bottom game, submissions) —
/// [FightResolver] reads almost all of these individually rather than
/// collapsing them into one number, so a fighter who is elite at holding
/// top position but bad at passing genuinely fights that way.
class FightingStats {
  // -- Striking offense --
  final int punching;
  final int kicking;
  final int power;
  final int speed;
  final int accuracy;

  // -- Striking defense --
  final int defense; // general defensive awareness / reading shots.
  final int headMovement; // slipping, rolling, making people miss.
  final int blocking; // shell, parries, checking kicks.
  final int footwork; // range management, cutting the cage, circling out.

  // -- Wrestling / clinch --
  final int takedowns;
  final int takedownDefense;
  final int wrestling; // chain wrestling, scrambling for the takedown.
  final int clinchStriking; // dirty boxing, knees and elbows on the inside.
  final int clinchControl; // pummelling, wall control, breaking posture.
  final int clinchDefense; // stuffing entries, framing, breaking away.

  // -- Ground: top --
  final int topControl; // staying heavy, holding position, passing.
  final int groundAndPound;

  // -- Ground: bottom --
  final int guardRetention; // stopping passes, re-guarding.
  final int sweeps; // reversing to top.
  final int scrambling; // winning transitions, getting back to the feet.

  // -- Submissions --
  final int submissionOffense;
  final int submissionDefense;
  final int grappling; // general mat awareness, positional grappling IQ.

  const FightingStats({
    required this.punching,
    required this.kicking,
    required this.power,
    required this.speed,
    required this.accuracy,
    required this.defense,
    required this.headMovement,
    required this.blocking,
    required this.footwork,
    required this.takedowns,
    required this.takedownDefense,
    required this.wrestling,
    required this.clinchStriking,
    required this.clinchControl,
    required this.clinchDefense,
    required this.topControl,
    required this.groundAndPound,
    required this.guardRetention,
    required this.sweeps,
    required this.scrambling,
    required this.submissionOffense,
    required this.submissionDefense,
    required this.grappling,
  });

  /// Rough "how good is their striking" summary, for display only.
  double get strikingAverage =>
      (punching + kicking + power + speed + accuracy + defense + headMovement + blocking + footwork) /
      9;

  /// Rough "how good is their grappling" summary, for display only.
  double get grapplingAverage =>
      (takedowns +
          takedownDefense +
          wrestling +
          clinchStriking +
          clinchControl +
          clinchDefense +
          topControl +
          groundAndPound +
          guardRetention +
          sweeps +
          scrambling +
          submissionOffense +
          submissionDefense +
          grappling) /
      14;

  double get average =>
      (punching +
          kicking +
          power +
          speed +
          accuracy +
          defense +
          headMovement +
          blocking +
          footwork +
          takedowns +
          takedownDefense +
          wrestling +
          clinchStriking +
          clinchControl +
          clinchDefense +
          topControl +
          groundAndPound +
          guardRetention +
          sweeps +
          scrambling +
          submissionOffense +
          submissionDefense +
          grappling) /
      23;

  FightingStats copyWith({
    int? punching,
    int? kicking,
    int? power,
    int? speed,
    int? accuracy,
    int? defense,
    int? headMovement,
    int? blocking,
    int? footwork,
    int? takedowns,
    int? takedownDefense,
    int? wrestling,
    int? clinchStriking,
    int? clinchControl,
    int? clinchDefense,
    int? topControl,
    int? groundAndPound,
    int? guardRetention,
    int? sweeps,
    int? scrambling,
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
      headMovement: headMovement ?? this.headMovement,
      blocking: blocking ?? this.blocking,
      footwork: footwork ?? this.footwork,
      takedowns: takedowns ?? this.takedowns,
      takedownDefense: takedownDefense ?? this.takedownDefense,
      wrestling: wrestling ?? this.wrestling,
      clinchStriking: clinchStriking ?? this.clinchStriking,
      clinchControl: clinchControl ?? this.clinchControl,
      clinchDefense: clinchDefense ?? this.clinchDefense,
      topControl: topControl ?? this.topControl,
      groundAndPound: groundAndPound ?? this.groundAndPound,
      guardRetention: guardRetention ?? this.guardRetention,
      sweeps: sweeps ?? this.sweeps,
      scrambling: scrambling ?? this.scrambling,
      submissionOffense: submissionOffense ?? this.submissionOffense,
      submissionDefense: submissionDefense ?? this.submissionDefense,
      grappling: grappling ?? this.grappling,
    );
  }
}

/// Conditioning and physical resilience. Each stat is 1-100.
class PhysicalStats {
  final int cardio; // how slowly the gas tank empties.
  final int durability; // resistance to accumulating damage generally.
  final int chin; // specifically resisting being rocked/knocked out.
  final int bodyToughness;
  final int legToughness;
  final int strength; // grappling muscle, clinch, holding position.
  final int athleticism; // balance, coordination, general physicality.
  final int recovery; // how much comes back between rounds, and how fast
  // a hurt fighter clears their head.
  final int explosiveness; // burst — shot entries, blitzes, scrambles.
  final int flexibility; // escaping bad positions, surviving submissions.
  final int gripStrength; // finishing chokes, holding control, wall grips.

  const PhysicalStats({
    required this.cardio,
    required this.durability,
    required this.chin,
    required this.bodyToughness,
    required this.legToughness,
    required this.strength,
    required this.athleticism,
    required this.recovery,
    required this.explosiveness,
    required this.flexibility,
    required this.gripStrength,
  });

  double get average =>
      (cardio +
          durability +
          chin +
          bodyToughness +
          legToughness +
          strength +
          athleticism +
          recovery +
          explosiveness +
          flexibility +
          gripStrength) /
      11;

  PhysicalStats copyWith({
    int? cardio,
    int? durability,
    int? chin,
    int? bodyToughness,
    int? legToughness,
    int? strength,
    int? athleticism,
    int? recovery,
    int? explosiveness,
    int? flexibility,
    int? gripStrength,
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
      explosiveness: explosiveness ?? this.explosiveness,
      flexibility: flexibility ?? this.flexibility,
      gripStrength: gripStrength ?? this.gripStrength,
    );
  }
}

/// Decision-making and composure under fire. Each stat is 1-100.
///
/// Note on [aggression]: this is the fighter's *innate* forward drive —
/// how hard they naturally push regardless of game plan. The separate
/// `Tendencies.aggression` is the tactical dial for how aggressively they
/// are choosing to fight. The resolver blends both.
class MentalStats {
  final int fightIq; // shot selection, reading openings, not making errors.
  final int composure; // performing while hurt or behind.
  final int aggression;
  final int discipline; // sticking to the game plan, defensive habits.
  final int confidence; // riding momentum, not shelling up after a bad round.
  final int heart; // surviving when hurt, refusing to break.
  final int adaptability; // adjusting between rounds when losing.
  final int killerInstinct; // pouncing on a hurt opponent to get the finish.

  const MentalStats({
    required this.fightIq,
    required this.composure,
    required this.aggression,
    required this.discipline,
    required this.confidence,
    required this.heart,
    required this.adaptability,
    required this.killerInstinct,
  });

  double get average =>
      (fightIq +
          composure +
          aggression +
          discipline +
          confidence +
          heart +
          adaptability +
          killerInstinct) /
      8;

  MentalStats copyWith({
    int? fightIq,
    int? composure,
    int? aggression,
    int? discipline,
    int? confidence,
    int? heart,
    int? adaptability,
    int? killerInstinct,
  }) {
    return MentalStats(
      fightIq: fightIq ?? this.fightIq,
      composure: composure ?? this.composure,
      aggression: aggression ?? this.aggression,
      discipline: discipline ?? this.discipline,
      confidence: confidence ?? this.confidence,
      heart: heart ?? this.heart,
      adaptability: adaptability ?? this.adaptability,
      killerInstinct: killerInstinct ?? this.killerInstinct,
    );
  }
}

/// Behavioral dials (0-100) that shape *how* a fighter fights, separate
/// from how *good* they are at it. A high `takedownFrequency` wrestler
/// with poor `wrestling` still shoots a lot of takedowns — they just don't
/// land them.
///
/// [positionControl], [groundAndPound] and [submissionAttempts] together
/// form a fighter's ground game plan: they're normalised against each
/// other every time the fighter ends up on top, so a grinder rides
/// position, a ground striker postures up and hits, and a submission
/// hunter chases finishes — from the exact same position.
class Tendencies {
  final int strikingFrequency;
  final int takedownFrequency;
  final int kickFrequency;
  final int clinchFrequency;
  final int submissionAttempts;
  final int groundAndPound;
  final int positionControl; // ride position and grind vs. gamble for more.
  final int standUpPreference; // from bottom: scramble up vs. play guard.
  final int wallWork; // in the clinch: pin on the fence vs. work in space.
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
    required this.positionControl,
    required this.standUpPreference,
    required this.wallWork,
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
    int? positionControl,
    int? standUpPreference,
    int? wallWork,
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
      positionControl: positionControl ?? this.positionControl,
      standUpPreference: standUpPreference ?? this.standUpPreference,
      wallWork: wallWork ?? this.wallWork,
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
