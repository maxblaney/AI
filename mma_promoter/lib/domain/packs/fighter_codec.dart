import 'dart:convert';
import 'dart:typed_data';

import '../../data/models/models.dart';

/// Turns a [Fighter] into JSON and back, for fighter packs.
///
/// Separate from the drift mappers on purpose. Those describe one
/// database schema and are free to change whenever a column does; this
/// describes a wire format that leaves the app, gets pasted into a chat
/// window, and comes back weeks later into a different build. It has to
/// survive that, which means two rules:
///
///   * **Every field read has a default.** A pack made before a stat
///     existed still imports; the missing stat lands on the same value a
///     freshly built [Fighter] would use.
///   * **Keys never change meaning.** Adding a key is fine. Renaming or
///     repurposing one silently corrupts every pack already in the wild,
///     so a retired key stays retired.
///
/// Keys are short because the encoded pack is meant to be copied and
/// pasted by hand — full field names roughly triple the size of a
/// twenty-fighter pack.
class FighterCodec {
  FighterCodec._();

  /// The 56 stats, in the order they are packed into the payload.
  ///
  /// **Append only.** A stat's position in this list *is* the format —
  /// inserting one in the middle shifts every stat after it, which
  /// silently rewrites every pack already in the wild into nonsense. New
  /// stats go on the end, where old packs simply run out of bytes and
  /// the reader defaults them.
  static const List<String> statOrder = [
    // Fighting (23)
    'punching', 'kicking', 'power', 'speed', 'accuracy', 'defense',
    'headMovement', 'blocking', 'footwork', 'takedowns', 'takedownDefense',
    'wrestling', 'clinchStriking', 'clinchControl', 'clinchDefense',
    'topControl', 'groundAndPound', 'guardRetention', 'sweeps',
    'scrambling', 'submissionOffense', 'submissionDefense', 'grappling',
    // Physical (11)
    'cardio', 'durability', 'chin', 'bodyToughness', 'legToughness',
    'strength', 'athleticism', 'recovery', 'explosiveness', 'flexibility',
    'gripStrength',
    // Mental (8)
    'fightIq', 'composure', 'mentalAggression', 'discipline', 'confidence',
    'heart', 'adaptability', 'killerInstinct',
    // Tendencies (14)
    'tendStrikingFrequency', 'tendTakedownFrequency', 'tendKickFrequency',
    'tendClinchFrequency', 'tendSubmissionAttempts', 'tendGroundAndPound',
    'tendPositionControl', 'tendStandUpPreference', 'tendWallWork',
    'tendAggression', 'tendCounterStriking', 'tendHeadHunting',
    'tendBodyAttacks', 'tendLegAttacks',
  ];

  /// The key the packed stats live under.
  static const String statsKey = 's';

  /// The value a stat lands on when a pack doesn't carry it — the middle
  /// of the scale, so an unknown stat is neither a gift nor a penalty.
  static const int _missingStat = 50;

  /// Stats go out as one base64 byte per stat rather than as 56
  /// JSON keys.
  ///
  /// This is the difference between a share code you can paste into a
  /// chat window and one you cannot: keyed JSON ran about 690 characters
  /// per fighter, so a ten-man pack was nearly 7,000. Every stat is
  /// clamped to 0-100, so a byte holds one exactly, and the whole stat
  /// block becomes 76 characters.
  static String _packStats(List<int> values) {
    final bytes = Uint8List(values.length);
    for (var i = 0; i < values.length; i++) {
      bytes[i] = values[i].clamp(0, 255);
    }
    return base64Encode(bytes);
  }

  static List<int> _unpackStats(Object? value) {
    if (value is! String) return const [];
    try {
      return base64Decode(value);
    } on FormatException {
      // A truncated or mangled paste: every stat falls back rather than
      // the whole fighter being lost.
      return const [];
    }
  }

  static Map<String, dynamic> toJson(Fighter f) {
    final fighting = f.fightingStats;
    final physical = f.physicalStats;
    final mental = f.mentalStats;
    final t = f.tendencies;

    return <String, dynamic>{
      'n': f.name,
      'ag': f.age,
      'nat': f.nationality,
      if (f.headshotAsset != null) 'hs': f.headshotAsset,
      'wc': f.weightClass.name,
      'ht': f.heightInches,
      'wt': f.weightLbs,
      if (f.reachInches != 0) 'rch': f.reachInches,
      'w': f.record.wins,
      'l': f.record.losses,
      if (f.record.draws != 0) 'd': f.record.draws,
      'sty': f.style.name,
      'pot': f.potential,
      'pop': f.popularity,
      'mor': f.morale,
      if (f.winStreak != 0) 'ws': f.winStreak,
      if (f.lossStreak != 0) 'ls': f.lossStreak,
      statsKey: _packStats([
        // Fighting (23)
        fighting.punching, fighting.kicking, fighting.power, fighting.speed,
        fighting.accuracy, fighting.defense, fighting.headMovement,
        fighting.blocking, fighting.footwork, fighting.takedowns,
        fighting.takedownDefense, fighting.wrestling, fighting.clinchStriking,
        fighting.clinchControl, fighting.clinchDefense, fighting.topControl,
        fighting.groundAndPound, fighting.guardRetention, fighting.sweeps,
        fighting.scrambling, fighting.submissionOffense,
        fighting.submissionDefense, fighting.grappling,
        // Physical (11)
        physical.cardio, physical.durability, physical.chin,
        physical.bodyToughness, physical.legToughness, physical.strength,
        physical.athleticism, physical.recovery, physical.explosiveness,
        physical.flexibility, physical.gripStrength,
        // Mental (8)
        mental.fightIq, mental.composure, mental.aggression,
        mental.discipline, mental.confidence, mental.heart,
        mental.adaptability, mental.killerInstinct,
        // Tendencies (14)
        t.strikingFrequency, t.takedownFrequency, t.kickFrequency,
        t.clinchFrequency, t.submissionAttempts, t.groundAndPound,
        t.positionControl, t.standUpPreference, t.wallWork, t.aggression,
        t.counterStriking, t.headHunting, t.bodyAttacks, t.legAttacks,
      ]),
    };
  }

  /// Rebuilds a fighter from [json], with [id] freshly minted by the
  /// caller.
  ///
  /// Deliberately drops everything that belongs to a *career* rather
  /// than a fighter: Elo, belts, injuries, suspensions, contracts, award
  /// counts, condition. A pack describes who someone is, not what they
  /// did in somebody else's save — importing a shared roster should not
  /// hand you another player's champion.
  static Fighter fromJson(Map<String, dynamic> json, {required String id}) {
    final packed = _unpackStats(json[statsKey]);
    // Position in [statOrder], not a key — a pack from an older build
    // simply runs out of bytes and the rest default.
    int stat(String name) {
      final index = statOrder.indexOf(name);
      if (index < 0 || index >= packed.length) return _missingStat;
      return packed[index].clamp(0, 100);
    }

    return Fighter(
      id: id,
      name: _string(json['n'], 'Unnamed Fighter'),
      age: _int(json['ag'], 27).clamp(16, 60),
      nationality: _string(json['nat'], 'USA'),
      headshotAsset: json['hs'] is String ? json['hs'] as String : null,
      weightClass: _enum(
          json['wc'], WeightClass.values, WeightClass.lightweight),
      heightInches: _int(json['ht'], 70).clamp(48, 96),
      weightLbs: _int(json['wt'], 155).clamp(90, 400),
      reachInches: _int(json['rch'], 0).clamp(0, 110),
      record: FightRecord(
        wins: _int(json['w'], 0).clamp(0, 999),
        losses: _int(json['l'], 0).clamp(0, 999),
        draws: _int(json['d'], 0).clamp(0, 999),
      ),
      style: _enum(json['sty'], FightingStyle.values,
          FightingStyle.wellRounded),
      potential: _int(json['pot'], 75).clamp(0, 100),
      popularity: _int(json['pop'], 10).clamp(0, 100),
      morale: _int(json['mor'], 75).clamp(0, 100),
      winStreak: _int(json['ws'], 0).clamp(0, 999),
      lossStreak: _int(json['ls'], 0).clamp(0, 999),
      injuryStatus: InjuryStatus.healthy,
      fightingStats: FightingStats(
        punching: stat('punching'), kicking: stat('kicking'), power: stat('power'),
        speed: stat('speed'), accuracy: stat('accuracy'), defense: stat('defense'),
        headMovement: stat('headMovement'), blocking: stat('blocking'),
        footwork: stat('footwork'), takedowns: stat('takedowns'),
        takedownDefense: stat('takedownDefense'), wrestling: stat('wrestling'),
        clinchStriking: stat('clinchStriking'), clinchControl: stat('clinchControl'),
        clinchDefense: stat('clinchDefense'), topControl: stat('topControl'),
        groundAndPound: stat('groundAndPound'), guardRetention: stat('guardRetention'),
        sweeps: stat('sweeps'), scrambling: stat('scrambling'),
        submissionOffense: stat('submissionOffense'), submissionDefense: stat('submissionDefense'),
        grappling: stat('grappling'),
      ),
      physicalStats: PhysicalStats(
        cardio: stat('cardio'), durability: stat('durability'), chin: stat('chin'),
        bodyToughness: stat('bodyToughness'), legToughness: stat('legToughness'),
        strength: stat('strength'), athleticism: stat('athleticism'),
        recovery: stat('recovery'), explosiveness: stat('explosiveness'),
        flexibility: stat('flexibility'), gripStrength: stat('gripStrength'),
      ),
      mentalStats: MentalStats(
        fightIq: stat('fightIq'), composure: stat('composure'),
        aggression: stat('mentalAggression'), discipline: stat('discipline'),
        confidence: stat('confidence'), heart: stat('heart'),
        adaptability: stat('adaptability'), killerInstinct: stat('killerInstinct'),
      ),
      tendencies: Tendencies(
        strikingFrequency: stat('tendStrikingFrequency'), takedownFrequency: stat('tendTakedownFrequency'),
        kickFrequency: stat('tendKickFrequency'), clinchFrequency: stat('tendClinchFrequency'),
        submissionAttempts: stat('tendSubmissionAttempts'), groundAndPound: stat('tendGroundAndPound'),
        positionControl: stat('tendPositionControl'), standUpPreference: stat('tendStandUpPreference'),
        wallWork: stat('tendWallWork'), aggression: stat('tendAggression'),
        counterStriking: stat('tendCounterStriking'), headHunting: stat('tendHeadHunting'),
        bodyAttacks: stat('tendBodyAttacks'), legAttacks: stat('tendLegAttacks'),
      ),
    );
  }

  static int _int(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _string(Object? value, String fallback) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  /// Enum values arrive by name. An unrecognised one — a division added
  /// after this pack was made, say — falls back rather than throwing:
  /// one odd fighter is a better outcome than a pack that won't load.
  static T _enum<T extends Enum>(Object? value, List<T> values, T fallback) {
    if (value is! String) return fallback;
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    return fallback;
  }
}
