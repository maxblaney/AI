// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FightersTable extends Fighters
    with TableInfo<$FightersTable, FighterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FightersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nationalityMeta =
      const VerificationMeta('nationality');
  @override
  late final GeneratedColumn<String> nationality = GeneratedColumn<String>(
      'nationality', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightClassMeta =
      const VerificationMeta('weightClass');
  @override
  late final GeneratedColumn<String> weightClass = GeneratedColumn<String>(
      'weight_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _heightInchesMeta =
      const VerificationMeta('heightInches');
  @override
  late final GeneratedColumn<int> heightInches = GeneratedColumn<int>(
      'height_inches', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(70));
  static const VerificationMeta _weightLbsMeta =
      const VerificationMeta('weightLbs');
  @override
  late final GeneratedColumn<int> weightLbs = GeneratedColumn<int>(
      'weight_lbs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(155));
  static const VerificationMeta _reachInchesMeta =
      const VerificationMeta('reachInches');
  @override
  late final GeneratedColumn<int> reachInches = GeneratedColumn<int>(
      'reach_inches', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _winsMeta = const VerificationMeta('wins');
  @override
  late final GeneratedColumn<int> wins = GeneratedColumn<int>(
      'wins', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lossesMeta = const VerificationMeta('losses');
  @override
  late final GeneratedColumn<int> losses = GeneratedColumn<int>(
      'losses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _drawsMeta = const VerificationMeta('draws');
  @override
  late final GeneratedColumn<int> draws = GeneratedColumn<int>(
      'draws', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _punchingMeta =
      const VerificationMeta('punching');
  @override
  late final GeneratedColumn<int> punching = GeneratedColumn<int>(
      'punching', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _kickingMeta =
      const VerificationMeta('kicking');
  @override
  late final GeneratedColumn<int> kicking = GeneratedColumn<int>(
      'kicking', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<int> power = GeneratedColumn<int>(
      'power', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
      'speed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<int> accuracy = GeneratedColumn<int>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _defenseMeta =
      const VerificationMeta('defense');
  @override
  late final GeneratedColumn<int> defense = GeneratedColumn<int>(
      'defense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _headMovementMeta =
      const VerificationMeta('headMovement');
  @override
  late final GeneratedColumn<int> headMovement = GeneratedColumn<int>(
      'head_movement', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _blockingMeta =
      const VerificationMeta('blocking');
  @override
  late final GeneratedColumn<int> blocking = GeneratedColumn<int>(
      'blocking', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _footworkMeta =
      const VerificationMeta('footwork');
  @override
  late final GeneratedColumn<int> footwork = GeneratedColumn<int>(
      'footwork', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _takedownsMeta =
      const VerificationMeta('takedowns');
  @override
  late final GeneratedColumn<int> takedowns = GeneratedColumn<int>(
      'takedowns', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _takedownDefenseMeta =
      const VerificationMeta('takedownDefense');
  @override
  late final GeneratedColumn<int> takedownDefense = GeneratedColumn<int>(
      'takedown_defense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wrestlingMeta =
      const VerificationMeta('wrestling');
  @override
  late final GeneratedColumn<int> wrestling = GeneratedColumn<int>(
      'wrestling', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _clinchStrikingMeta =
      const VerificationMeta('clinchStriking');
  @override
  late final GeneratedColumn<int> clinchStriking = GeneratedColumn<int>(
      'clinch_striking', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _clinchControlMeta =
      const VerificationMeta('clinchControl');
  @override
  late final GeneratedColumn<int> clinchControl = GeneratedColumn<int>(
      'clinch_control', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _clinchDefenseMeta =
      const VerificationMeta('clinchDefense');
  @override
  late final GeneratedColumn<int> clinchDefense = GeneratedColumn<int>(
      'clinch_defense', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _topControlMeta =
      const VerificationMeta('topControl');
  @override
  late final GeneratedColumn<int> topControl = GeneratedColumn<int>(
      'top_control', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _groundAndPoundMeta =
      const VerificationMeta('groundAndPound');
  @override
  late final GeneratedColumn<int> groundAndPound = GeneratedColumn<int>(
      'ground_and_pound', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _guardRetentionMeta =
      const VerificationMeta('guardRetention');
  @override
  late final GeneratedColumn<int> guardRetention = GeneratedColumn<int>(
      'guard_retention', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _sweepsMeta = const VerificationMeta('sweeps');
  @override
  late final GeneratedColumn<int> sweeps = GeneratedColumn<int>(
      'sweeps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _scramblingMeta =
      const VerificationMeta('scrambling');
  @override
  late final GeneratedColumn<int> scrambling = GeneratedColumn<int>(
      'scrambling', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _submissionOffenseMeta =
      const VerificationMeta('submissionOffense');
  @override
  late final GeneratedColumn<int> submissionOffense = GeneratedColumn<int>(
      'submission_offense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _submissionDefenseMeta =
      const VerificationMeta('submissionDefense');
  @override
  late final GeneratedColumn<int> submissionDefense = GeneratedColumn<int>(
      'submission_defense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _grapplingMeta =
      const VerificationMeta('grappling');
  @override
  late final GeneratedColumn<int> grappling = GeneratedColumn<int>(
      'grappling', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardioMeta = const VerificationMeta('cardio');
  @override
  late final GeneratedColumn<int> cardio = GeneratedColumn<int>(
      'cardio', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durabilityMeta =
      const VerificationMeta('durability');
  @override
  late final GeneratedColumn<int> durability = GeneratedColumn<int>(
      'durability', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chinMeta = const VerificationMeta('chin');
  @override
  late final GeneratedColumn<int> chin = GeneratedColumn<int>(
      'chin', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bodyToughnessMeta =
      const VerificationMeta('bodyToughness');
  @override
  late final GeneratedColumn<int> bodyToughness = GeneratedColumn<int>(
      'body_toughness', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _legToughnessMeta =
      const VerificationMeta('legToughness');
  @override
  late final GeneratedColumn<int> legToughness = GeneratedColumn<int>(
      'leg_toughness', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _strengthMeta =
      const VerificationMeta('strength');
  @override
  late final GeneratedColumn<int> strength = GeneratedColumn<int>(
      'strength', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _athleticismMeta =
      const VerificationMeta('athleticism');
  @override
  late final GeneratedColumn<int> athleticism = GeneratedColumn<int>(
      'athleticism', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recoveryMeta =
      const VerificationMeta('recovery');
  @override
  late final GeneratedColumn<int> recovery = GeneratedColumn<int>(
      'recovery', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _explosivenessMeta =
      const VerificationMeta('explosiveness');
  @override
  late final GeneratedColumn<int> explosiveness = GeneratedColumn<int>(
      'explosiveness', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _flexibilityMeta =
      const VerificationMeta('flexibility');
  @override
  late final GeneratedColumn<int> flexibility = GeneratedColumn<int>(
      'flexibility', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _gripStrengthMeta =
      const VerificationMeta('gripStrength');
  @override
  late final GeneratedColumn<int> gripStrength = GeneratedColumn<int>(
      'grip_strength', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _fightIqMeta =
      const VerificationMeta('fightIq');
  @override
  late final GeneratedColumn<int> fightIq = GeneratedColumn<int>(
      'fight_iq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _composureMeta =
      const VerificationMeta('composure');
  @override
  late final GeneratedColumn<int> composure = GeneratedColumn<int>(
      'composure', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _aggressionMeta =
      const VerificationMeta('aggression');
  @override
  late final GeneratedColumn<int> aggression = GeneratedColumn<int>(
      'aggression', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _disciplineMeta =
      const VerificationMeta('discipline');
  @override
  late final GeneratedColumn<int> discipline = GeneratedColumn<int>(
      'discipline', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
      'confidence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heartMeta = const VerificationMeta('heart');
  @override
  late final GeneratedColumn<int> heart = GeneratedColumn<int>(
      'heart', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _adaptabilityMeta =
      const VerificationMeta('adaptability');
  @override
  late final GeneratedColumn<int> adaptability = GeneratedColumn<int>(
      'adaptability', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _killerInstinctMeta =
      const VerificationMeta('killerInstinct');
  @override
  late final GeneratedColumn<int> killerInstinct = GeneratedColumn<int>(
      'killer_instinct', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _tendStrikingFrequencyMeta =
      const VerificationMeta('tendStrikingFrequency');
  @override
  late final GeneratedColumn<int> tendStrikingFrequency = GeneratedColumn<int>(
      'tend_striking_frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendTakedownFrequencyMeta =
      const VerificationMeta('tendTakedownFrequency');
  @override
  late final GeneratedColumn<int> tendTakedownFrequency = GeneratedColumn<int>(
      'tend_takedown_frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendKickFrequencyMeta =
      const VerificationMeta('tendKickFrequency');
  @override
  late final GeneratedColumn<int> tendKickFrequency = GeneratedColumn<int>(
      'tend_kick_frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendClinchFrequencyMeta =
      const VerificationMeta('tendClinchFrequency');
  @override
  late final GeneratedColumn<int> tendClinchFrequency = GeneratedColumn<int>(
      'tend_clinch_frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendSubmissionAttemptsMeta =
      const VerificationMeta('tendSubmissionAttempts');
  @override
  late final GeneratedColumn<int> tendSubmissionAttempts = GeneratedColumn<int>(
      'tend_submission_attempts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendGroundAndPoundMeta =
      const VerificationMeta('tendGroundAndPound');
  @override
  late final GeneratedColumn<int> tendGroundAndPound = GeneratedColumn<int>(
      'tend_ground_and_pound', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendPositionControlMeta =
      const VerificationMeta('tendPositionControl');
  @override
  late final GeneratedColumn<int> tendPositionControl = GeneratedColumn<int>(
      'tend_position_control', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _tendStandUpPreferenceMeta =
      const VerificationMeta('tendStandUpPreference');
  @override
  late final GeneratedColumn<int> tendStandUpPreference = GeneratedColumn<int>(
      'tend_stand_up_preference', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _tendWallWorkMeta =
      const VerificationMeta('tendWallWork');
  @override
  late final GeneratedColumn<int> tendWallWork = GeneratedColumn<int>(
      'tend_wall_work', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _tendAggressionMeta =
      const VerificationMeta('tendAggression');
  @override
  late final GeneratedColumn<int> tendAggression = GeneratedColumn<int>(
      'tend_aggression', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendCounterStrikingMeta =
      const VerificationMeta('tendCounterStriking');
  @override
  late final GeneratedColumn<int> tendCounterStriking = GeneratedColumn<int>(
      'tend_counter_striking', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendHeadHuntingMeta =
      const VerificationMeta('tendHeadHunting');
  @override
  late final GeneratedColumn<int> tendHeadHunting = GeneratedColumn<int>(
      'tend_head_hunting', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendBodyAttacksMeta =
      const VerificationMeta('tendBodyAttacks');
  @override
  late final GeneratedColumn<int> tendBodyAttacks = GeneratedColumn<int>(
      'tend_body_attacks', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tendLegAttacksMeta =
      const VerificationMeta('tendLegAttacks');
  @override
  late final GeneratedColumn<int> tendLegAttacks = GeneratedColumn<int>(
      'tend_leg_attacks', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
      'style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('wellRounded'));
  static const VerificationMeta _potentialMeta =
      const VerificationMeta('potential');
  @override
  late final GeneratedColumn<int> potential = GeneratedColumn<int>(
      'potential', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  static const VerificationMeta _popularityMeta =
      const VerificationMeta('popularity');
  @override
  late final GeneratedColumn<int> popularity = GeneratedColumn<int>(
      'popularity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _moraleMeta = const VerificationMeta('morale');
  @override
  late final GeneratedColumn<int> morale = GeneratedColumn<int>(
      'morale', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(70));
  static const VerificationMeta _injuryStatusMeta =
      const VerificationMeta('injuryStatus');
  @override
  late final GeneratedColumn<String> injuryStatus = GeneratedColumn<String>(
      'injury_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('healthy'));
  static const VerificationMeta _winStreakMeta =
      const VerificationMeta('winStreak');
  @override
  late final GeneratedColumn<int> winStreak = GeneratedColumn<int>(
      'win_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lossStreakMeta =
      const VerificationMeta('lossStreak');
  @override
  late final GeneratedColumn<int> lossStreak = GeneratedColumn<int>(
      'loss_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _eloRatingMeta =
      const VerificationMeta('eloRating');
  @override
  late final GeneratedColumn<int> eloRating = GeneratedColumn<int>(
      'elo_rating', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1500));
  static const VerificationMeta _isRankedMeta =
      const VerificationMeta('isRanked');
  @override
  late final GeneratedColumn<bool> isRanked = GeneratedColumn<bool>(
      'is_ranked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_ranked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _retiredMeta =
      const VerificationMeta('retired');
  @override
  late final GeneratedColumn<bool> retired = GeneratedColumn<bool>(
      'retired', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("retired" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _retirementReasonMeta =
      const VerificationMeta('retirementReason');
  @override
  late final GeneratedColumn<String> retirementReason = GeneratedColumn<String>(
      'retirement_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fightOfTheNightCountMeta =
      const VerificationMeta('fightOfTheNightCount');
  @override
  late final GeneratedColumn<int> fightOfTheNightCount = GeneratedColumn<int>(
      'fight_of_the_night_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _performanceOfTheNightCountMeta =
      const VerificationMeta('performanceOfTheNightCount');
  @override
  late final GeneratedColumn<int> performanceOfTheNightCount =
      GeneratedColumn<int>('performance_of_the_night_count', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        nationality,
        weightClass,
        heightInches,
        weightLbs,
        reachInches,
        wins,
        losses,
        draws,
        punching,
        kicking,
        power,
        speed,
        accuracy,
        defense,
        headMovement,
        blocking,
        footwork,
        takedowns,
        takedownDefense,
        wrestling,
        clinchStriking,
        clinchControl,
        clinchDefense,
        topControl,
        groundAndPound,
        guardRetention,
        sweeps,
        scrambling,
        submissionOffense,
        submissionDefense,
        grappling,
        cardio,
        durability,
        chin,
        bodyToughness,
        legToughness,
        strength,
        athleticism,
        recovery,
        explosiveness,
        flexibility,
        gripStrength,
        fightIq,
        composure,
        aggression,
        discipline,
        confidence,
        heart,
        adaptability,
        killerInstinct,
        tendStrikingFrequency,
        tendTakedownFrequency,
        tendKickFrequency,
        tendClinchFrequency,
        tendSubmissionAttempts,
        tendGroundAndPound,
        tendPositionControl,
        tendStandUpPreference,
        tendWallWork,
        tendAggression,
        tendCounterStriking,
        tendHeadHunting,
        tendBodyAttacks,
        tendLegAttacks,
        style,
        potential,
        popularity,
        morale,
        injuryStatus,
        winStreak,
        lossStreak,
        eloRating,
        isRanked,
        retired,
        retirementReason,
        fightOfTheNightCount,
        performanceOfTheNightCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fighters';
  @override
  VerificationContext validateIntegrity(Insertable<FighterRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('nationality')) {
      context.handle(
          _nationalityMeta,
          nationality.isAcceptableOrUnknown(
              data['nationality']!, _nationalityMeta));
    } else if (isInserting) {
      context.missing(_nationalityMeta);
    }
    if (data.containsKey('weight_class')) {
      context.handle(
          _weightClassMeta,
          weightClass.isAcceptableOrUnknown(
              data['weight_class']!, _weightClassMeta));
    } else if (isInserting) {
      context.missing(_weightClassMeta);
    }
    if (data.containsKey('height_inches')) {
      context.handle(
          _heightInchesMeta,
          heightInches.isAcceptableOrUnknown(
              data['height_inches']!, _heightInchesMeta));
    }
    if (data.containsKey('weight_lbs')) {
      context.handle(_weightLbsMeta,
          weightLbs.isAcceptableOrUnknown(data['weight_lbs']!, _weightLbsMeta));
    }
    if (data.containsKey('reach_inches')) {
      context.handle(
          _reachInchesMeta,
          reachInches.isAcceptableOrUnknown(
              data['reach_inches']!, _reachInchesMeta));
    }
    if (data.containsKey('wins')) {
      context.handle(
          _winsMeta, wins.isAcceptableOrUnknown(data['wins']!, _winsMeta));
    }
    if (data.containsKey('losses')) {
      context.handle(_lossesMeta,
          losses.isAcceptableOrUnknown(data['losses']!, _lossesMeta));
    }
    if (data.containsKey('draws')) {
      context.handle(
          _drawsMeta, draws.isAcceptableOrUnknown(data['draws']!, _drawsMeta));
    }
    if (data.containsKey('punching')) {
      context.handle(_punchingMeta,
          punching.isAcceptableOrUnknown(data['punching']!, _punchingMeta));
    } else if (isInserting) {
      context.missing(_punchingMeta);
    }
    if (data.containsKey('kicking')) {
      context.handle(_kickingMeta,
          kicking.isAcceptableOrUnknown(data['kicking']!, _kickingMeta));
    } else if (isInserting) {
      context.missing(_kickingMeta);
    }
    if (data.containsKey('power')) {
      context.handle(
          _powerMeta, power.isAcceptableOrUnknown(data['power']!, _powerMeta));
    } else if (isInserting) {
      context.missing(_powerMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('defense')) {
      context.handle(_defenseMeta,
          defense.isAcceptableOrUnknown(data['defense']!, _defenseMeta));
    } else if (isInserting) {
      context.missing(_defenseMeta);
    }
    if (data.containsKey('head_movement')) {
      context.handle(
          _headMovementMeta,
          headMovement.isAcceptableOrUnknown(
              data['head_movement']!, _headMovementMeta));
    }
    if (data.containsKey('blocking')) {
      context.handle(_blockingMeta,
          blocking.isAcceptableOrUnknown(data['blocking']!, _blockingMeta));
    }
    if (data.containsKey('footwork')) {
      context.handle(_footworkMeta,
          footwork.isAcceptableOrUnknown(data['footwork']!, _footworkMeta));
    }
    if (data.containsKey('takedowns')) {
      context.handle(_takedownsMeta,
          takedowns.isAcceptableOrUnknown(data['takedowns']!, _takedownsMeta));
    } else if (isInserting) {
      context.missing(_takedownsMeta);
    }
    if (data.containsKey('takedown_defense')) {
      context.handle(
          _takedownDefenseMeta,
          takedownDefense.isAcceptableOrUnknown(
              data['takedown_defense']!, _takedownDefenseMeta));
    } else if (isInserting) {
      context.missing(_takedownDefenseMeta);
    }
    if (data.containsKey('wrestling')) {
      context.handle(_wrestlingMeta,
          wrestling.isAcceptableOrUnknown(data['wrestling']!, _wrestlingMeta));
    } else if (isInserting) {
      context.missing(_wrestlingMeta);
    }
    if (data.containsKey('clinch_striking')) {
      context.handle(
          _clinchStrikingMeta,
          clinchStriking.isAcceptableOrUnknown(
              data['clinch_striking']!, _clinchStrikingMeta));
    }
    if (data.containsKey('clinch_control')) {
      context.handle(
          _clinchControlMeta,
          clinchControl.isAcceptableOrUnknown(
              data['clinch_control']!, _clinchControlMeta));
    }
    if (data.containsKey('clinch_defense')) {
      context.handle(
          _clinchDefenseMeta,
          clinchDefense.isAcceptableOrUnknown(
              data['clinch_defense']!, _clinchDefenseMeta));
    }
    if (data.containsKey('top_control')) {
      context.handle(
          _topControlMeta,
          topControl.isAcceptableOrUnknown(
              data['top_control']!, _topControlMeta));
    }
    if (data.containsKey('ground_and_pound')) {
      context.handle(
          _groundAndPoundMeta,
          groundAndPound.isAcceptableOrUnknown(
              data['ground_and_pound']!, _groundAndPoundMeta));
    } else if (isInserting) {
      context.missing(_groundAndPoundMeta);
    }
    if (data.containsKey('guard_retention')) {
      context.handle(
          _guardRetentionMeta,
          guardRetention.isAcceptableOrUnknown(
              data['guard_retention']!, _guardRetentionMeta));
    }
    if (data.containsKey('sweeps')) {
      context.handle(_sweepsMeta,
          sweeps.isAcceptableOrUnknown(data['sweeps']!, _sweepsMeta));
    }
    if (data.containsKey('scrambling')) {
      context.handle(
          _scramblingMeta,
          scrambling.isAcceptableOrUnknown(
              data['scrambling']!, _scramblingMeta));
    }
    if (data.containsKey('submission_offense')) {
      context.handle(
          _submissionOffenseMeta,
          submissionOffense.isAcceptableOrUnknown(
              data['submission_offense']!, _submissionOffenseMeta));
    } else if (isInserting) {
      context.missing(_submissionOffenseMeta);
    }
    if (data.containsKey('submission_defense')) {
      context.handle(
          _submissionDefenseMeta,
          submissionDefense.isAcceptableOrUnknown(
              data['submission_defense']!, _submissionDefenseMeta));
    } else if (isInserting) {
      context.missing(_submissionDefenseMeta);
    }
    if (data.containsKey('grappling')) {
      context.handle(_grapplingMeta,
          grappling.isAcceptableOrUnknown(data['grappling']!, _grapplingMeta));
    } else if (isInserting) {
      context.missing(_grapplingMeta);
    }
    if (data.containsKey('cardio')) {
      context.handle(_cardioMeta,
          cardio.isAcceptableOrUnknown(data['cardio']!, _cardioMeta));
    } else if (isInserting) {
      context.missing(_cardioMeta);
    }
    if (data.containsKey('durability')) {
      context.handle(
          _durabilityMeta,
          durability.isAcceptableOrUnknown(
              data['durability']!, _durabilityMeta));
    } else if (isInserting) {
      context.missing(_durabilityMeta);
    }
    if (data.containsKey('chin')) {
      context.handle(
          _chinMeta, chin.isAcceptableOrUnknown(data['chin']!, _chinMeta));
    } else if (isInserting) {
      context.missing(_chinMeta);
    }
    if (data.containsKey('body_toughness')) {
      context.handle(
          _bodyToughnessMeta,
          bodyToughness.isAcceptableOrUnknown(
              data['body_toughness']!, _bodyToughnessMeta));
    } else if (isInserting) {
      context.missing(_bodyToughnessMeta);
    }
    if (data.containsKey('leg_toughness')) {
      context.handle(
          _legToughnessMeta,
          legToughness.isAcceptableOrUnknown(
              data['leg_toughness']!, _legToughnessMeta));
    } else if (isInserting) {
      context.missing(_legToughnessMeta);
    }
    if (data.containsKey('strength')) {
      context.handle(_strengthMeta,
          strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta));
    } else if (isInserting) {
      context.missing(_strengthMeta);
    }
    if (data.containsKey('athleticism')) {
      context.handle(
          _athleticismMeta,
          athleticism.isAcceptableOrUnknown(
              data['athleticism']!, _athleticismMeta));
    } else if (isInserting) {
      context.missing(_athleticismMeta);
    }
    if (data.containsKey('recovery')) {
      context.handle(_recoveryMeta,
          recovery.isAcceptableOrUnknown(data['recovery']!, _recoveryMeta));
    } else if (isInserting) {
      context.missing(_recoveryMeta);
    }
    if (data.containsKey('explosiveness')) {
      context.handle(
          _explosivenessMeta,
          explosiveness.isAcceptableOrUnknown(
              data['explosiveness']!, _explosivenessMeta));
    }
    if (data.containsKey('flexibility')) {
      context.handle(
          _flexibilityMeta,
          flexibility.isAcceptableOrUnknown(
              data['flexibility']!, _flexibilityMeta));
    }
    if (data.containsKey('grip_strength')) {
      context.handle(
          _gripStrengthMeta,
          gripStrength.isAcceptableOrUnknown(
              data['grip_strength']!, _gripStrengthMeta));
    }
    if (data.containsKey('fight_iq')) {
      context.handle(_fightIqMeta,
          fightIq.isAcceptableOrUnknown(data['fight_iq']!, _fightIqMeta));
    } else if (isInserting) {
      context.missing(_fightIqMeta);
    }
    if (data.containsKey('composure')) {
      context.handle(_composureMeta,
          composure.isAcceptableOrUnknown(data['composure']!, _composureMeta));
    } else if (isInserting) {
      context.missing(_composureMeta);
    }
    if (data.containsKey('aggression')) {
      context.handle(
          _aggressionMeta,
          aggression.isAcceptableOrUnknown(
              data['aggression']!, _aggressionMeta));
    } else if (isInserting) {
      context.missing(_aggressionMeta);
    }
    if (data.containsKey('discipline')) {
      context.handle(
          _disciplineMeta,
          discipline.isAcceptableOrUnknown(
              data['discipline']!, _disciplineMeta));
    } else if (isInserting) {
      context.missing(_disciplineMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('heart')) {
      context.handle(
          _heartMeta, heart.isAcceptableOrUnknown(data['heart']!, _heartMeta));
    } else if (isInserting) {
      context.missing(_heartMeta);
    }
    if (data.containsKey('adaptability')) {
      context.handle(
          _adaptabilityMeta,
          adaptability.isAcceptableOrUnknown(
              data['adaptability']!, _adaptabilityMeta));
    } else if (isInserting) {
      context.missing(_adaptabilityMeta);
    }
    if (data.containsKey('killer_instinct')) {
      context.handle(
          _killerInstinctMeta,
          killerInstinct.isAcceptableOrUnknown(
              data['killer_instinct']!, _killerInstinctMeta));
    }
    if (data.containsKey('tend_striking_frequency')) {
      context.handle(
          _tendStrikingFrequencyMeta,
          tendStrikingFrequency.isAcceptableOrUnknown(
              data['tend_striking_frequency']!, _tendStrikingFrequencyMeta));
    } else if (isInserting) {
      context.missing(_tendStrikingFrequencyMeta);
    }
    if (data.containsKey('tend_takedown_frequency')) {
      context.handle(
          _tendTakedownFrequencyMeta,
          tendTakedownFrequency.isAcceptableOrUnknown(
              data['tend_takedown_frequency']!, _tendTakedownFrequencyMeta));
    } else if (isInserting) {
      context.missing(_tendTakedownFrequencyMeta);
    }
    if (data.containsKey('tend_kick_frequency')) {
      context.handle(
          _tendKickFrequencyMeta,
          tendKickFrequency.isAcceptableOrUnknown(
              data['tend_kick_frequency']!, _tendKickFrequencyMeta));
    } else if (isInserting) {
      context.missing(_tendKickFrequencyMeta);
    }
    if (data.containsKey('tend_clinch_frequency')) {
      context.handle(
          _tendClinchFrequencyMeta,
          tendClinchFrequency.isAcceptableOrUnknown(
              data['tend_clinch_frequency']!, _tendClinchFrequencyMeta));
    } else if (isInserting) {
      context.missing(_tendClinchFrequencyMeta);
    }
    if (data.containsKey('tend_submission_attempts')) {
      context.handle(
          _tendSubmissionAttemptsMeta,
          tendSubmissionAttempts.isAcceptableOrUnknown(
              data['tend_submission_attempts']!, _tendSubmissionAttemptsMeta));
    } else if (isInserting) {
      context.missing(_tendSubmissionAttemptsMeta);
    }
    if (data.containsKey('tend_ground_and_pound')) {
      context.handle(
          _tendGroundAndPoundMeta,
          tendGroundAndPound.isAcceptableOrUnknown(
              data['tend_ground_and_pound']!, _tendGroundAndPoundMeta));
    } else if (isInserting) {
      context.missing(_tendGroundAndPoundMeta);
    }
    if (data.containsKey('tend_position_control')) {
      context.handle(
          _tendPositionControlMeta,
          tendPositionControl.isAcceptableOrUnknown(
              data['tend_position_control']!, _tendPositionControlMeta));
    }
    if (data.containsKey('tend_stand_up_preference')) {
      context.handle(
          _tendStandUpPreferenceMeta,
          tendStandUpPreference.isAcceptableOrUnknown(
              data['tend_stand_up_preference']!, _tendStandUpPreferenceMeta));
    }
    if (data.containsKey('tend_wall_work')) {
      context.handle(
          _tendWallWorkMeta,
          tendWallWork.isAcceptableOrUnknown(
              data['tend_wall_work']!, _tendWallWorkMeta));
    }
    if (data.containsKey('tend_aggression')) {
      context.handle(
          _tendAggressionMeta,
          tendAggression.isAcceptableOrUnknown(
              data['tend_aggression']!, _tendAggressionMeta));
    } else if (isInserting) {
      context.missing(_tendAggressionMeta);
    }
    if (data.containsKey('tend_counter_striking')) {
      context.handle(
          _tendCounterStrikingMeta,
          tendCounterStriking.isAcceptableOrUnknown(
              data['tend_counter_striking']!, _tendCounterStrikingMeta));
    } else if (isInserting) {
      context.missing(_tendCounterStrikingMeta);
    }
    if (data.containsKey('tend_head_hunting')) {
      context.handle(
          _tendHeadHuntingMeta,
          tendHeadHunting.isAcceptableOrUnknown(
              data['tend_head_hunting']!, _tendHeadHuntingMeta));
    } else if (isInserting) {
      context.missing(_tendHeadHuntingMeta);
    }
    if (data.containsKey('tend_body_attacks')) {
      context.handle(
          _tendBodyAttacksMeta,
          tendBodyAttacks.isAcceptableOrUnknown(
              data['tend_body_attacks']!, _tendBodyAttacksMeta));
    } else if (isInserting) {
      context.missing(_tendBodyAttacksMeta);
    }
    if (data.containsKey('tend_leg_attacks')) {
      context.handle(
          _tendLegAttacksMeta,
          tendLegAttacks.isAcceptableOrUnknown(
              data['tend_leg_attacks']!, _tendLegAttacksMeta));
    } else if (isInserting) {
      context.missing(_tendLegAttacksMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
          _styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    }
    if (data.containsKey('potential')) {
      context.handle(_potentialMeta,
          potential.isAcceptableOrUnknown(data['potential']!, _potentialMeta));
    }
    if (data.containsKey('popularity')) {
      context.handle(
          _popularityMeta,
          popularity.isAcceptableOrUnknown(
              data['popularity']!, _popularityMeta));
    }
    if (data.containsKey('morale')) {
      context.handle(_moraleMeta,
          morale.isAcceptableOrUnknown(data['morale']!, _moraleMeta));
    }
    if (data.containsKey('injury_status')) {
      context.handle(
          _injuryStatusMeta,
          injuryStatus.isAcceptableOrUnknown(
              data['injury_status']!, _injuryStatusMeta));
    }
    if (data.containsKey('win_streak')) {
      context.handle(_winStreakMeta,
          winStreak.isAcceptableOrUnknown(data['win_streak']!, _winStreakMeta));
    }
    if (data.containsKey('loss_streak')) {
      context.handle(
          _lossStreakMeta,
          lossStreak.isAcceptableOrUnknown(
              data['loss_streak']!, _lossStreakMeta));
    }
    if (data.containsKey('elo_rating')) {
      context.handle(_eloRatingMeta,
          eloRating.isAcceptableOrUnknown(data['elo_rating']!, _eloRatingMeta));
    }
    if (data.containsKey('is_ranked')) {
      context.handle(_isRankedMeta,
          isRanked.isAcceptableOrUnknown(data['is_ranked']!, _isRankedMeta));
    }
    if (data.containsKey('retired')) {
      context.handle(_retiredMeta,
          retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta));
    }
    if (data.containsKey('retirement_reason')) {
      context.handle(
          _retirementReasonMeta,
          retirementReason.isAcceptableOrUnknown(
              data['retirement_reason']!, _retirementReasonMeta));
    }
    if (data.containsKey('fight_of_the_night_count')) {
      context.handle(
          _fightOfTheNightCountMeta,
          fightOfTheNightCount.isAcceptableOrUnknown(
              data['fight_of_the_night_count']!, _fightOfTheNightCountMeta));
    }
    if (data.containsKey('performance_of_the_night_count')) {
      context.handle(
          _performanceOfTheNightCountMeta,
          performanceOfTheNightCount.isAcceptableOrUnknown(
              data['performance_of_the_night_count']!,
              _performanceOfTheNightCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FighterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FighterRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      nationality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nationality'])!,
      weightClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_class'])!,
      heightInches: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height_inches'])!,
      weightLbs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight_lbs'])!,
      reachInches: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reach_inches'])!,
      wins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wins'])!,
      losses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}losses'])!,
      draws: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}draws'])!,
      punching: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}punching'])!,
      kicking: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kicking'])!,
      power: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}power'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speed'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}accuracy'])!,
      defense: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}defense'])!,
      headMovement: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}head_movement'])!,
      blocking: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}blocking'])!,
      footwork: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}footwork'])!,
      takedowns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}takedowns'])!,
      takedownDefense: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}takedown_defense'])!,
      wrestling: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wrestling'])!,
      clinchStriking: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clinch_striking'])!,
      clinchControl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clinch_control'])!,
      clinchDefense: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clinch_defense'])!,
      topControl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}top_control'])!,
      groundAndPound: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ground_and_pound'])!,
      guardRetention: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}guard_retention'])!,
      sweeps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sweeps'])!,
      scrambling: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scrambling'])!,
      submissionOffense: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}submission_offense'])!,
      submissionDefense: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}submission_defense'])!,
      grappling: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grappling'])!,
      cardio: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cardio'])!,
      durability: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}durability'])!,
      chin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chin'])!,
      bodyToughness: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}body_toughness'])!,
      legToughness: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leg_toughness'])!,
      strength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}strength'])!,
      athleticism: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}athleticism'])!,
      recovery: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recovery'])!,
      explosiveness: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}explosiveness'])!,
      flexibility: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flexibility'])!,
      gripStrength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grip_strength'])!,
      fightIq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fight_iq'])!,
      composure: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}composure'])!,
      aggression: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aggression'])!,
      discipline: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discipline'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}confidence'])!,
      heart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}heart'])!,
      adaptability: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}adaptability'])!,
      killerInstinct: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}killer_instinct'])!,
      tendStrikingFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_striking_frequency'])!,
      tendTakedownFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_takedown_frequency'])!,
      tendKickFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_kick_frequency'])!,
      tendClinchFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_clinch_frequency'])!,
      tendSubmissionAttempts: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tend_submission_attempts'])!,
      tendGroundAndPound: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_ground_and_pound'])!,
      tendPositionControl: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_position_control'])!,
      tendStandUpPreference: attachedDatabase.typeMapping.read(DriftSqlType.int,
          data['${effectivePrefix}tend_stand_up_preference'])!,
      tendWallWork: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tend_wall_work'])!,
      tendAggression: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tend_aggression'])!,
      tendCounterStriking: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tend_counter_striking'])!,
      tendHeadHunting: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tend_head_hunting'])!,
      tendBodyAttacks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tend_body_attacks'])!,
      tendLegAttacks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tend_leg_attacks'])!,
      style: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}style'])!,
      potential: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}potential'])!,
      popularity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}popularity'])!,
      morale: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}morale'])!,
      injuryStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}injury_status'])!,
      winStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}win_streak'])!,
      lossStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loss_streak'])!,
      eloRating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elo_rating'])!,
      isRanked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_ranked'])!,
      retired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}retired'])!,
      retirementReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}retirement_reason']),
      fightOfTheNightCount: attachedDatabase.typeMapping.read(DriftSqlType.int,
          data['${effectivePrefix}fight_of_the_night_count'])!,
      performanceOfTheNightCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}performance_of_the_night_count'])!,
    );
  }

  @override
  $FightersTable createAlias(String alias) {
    return $FightersTable(attachedDatabase, alias);
  }
}

class FighterRow extends DataClass implements Insertable<FighterRow> {
  final String id;
  final String name;
  final int age;
  final String nationality;
  final String weightClass;
  final int heightInches;
  final int weightLbs;

  /// 0 means "not recorded" — the model falls back to height.
  final int reachInches;
  final int wins;
  final int losses;
  final int draws;
  final int punching;
  final int kicking;
  final int power;
  final int speed;
  final int accuracy;
  final int defense;
  final int headMovement;
  final int blocking;
  final int footwork;
  final int takedowns;
  final int takedownDefense;
  final int wrestling;
  final int clinchStriking;
  final int clinchControl;
  final int clinchDefense;
  final int topControl;
  final int groundAndPound;
  final int guardRetention;
  final int sweeps;
  final int scrambling;
  final int submissionOffense;
  final int submissionDefense;
  final int grappling;
  final int cardio;
  final int durability;
  final int chin;
  final int bodyToughness;
  final int legToughness;
  final int strength;
  final int athleticism;
  final int recovery;
  final int explosiveness;
  final int flexibility;
  final int gripStrength;
  final int fightIq;
  final int composure;
  final int aggression;
  final int discipline;
  final int confidence;
  final int heart;
  final int adaptability;
  final int killerInstinct;
  final int tendStrikingFrequency;
  final int tendTakedownFrequency;
  final int tendKickFrequency;
  final int tendClinchFrequency;
  final int tendSubmissionAttempts;
  final int tendGroundAndPound;
  final int tendPositionControl;
  final int tendStandUpPreference;
  final int tendWallWork;
  final int tendAggression;
  final int tendCounterStriking;
  final int tendHeadHunting;
  final int tendBodyAttacks;
  final int tendLegAttacks;
  final String style;
  final int potential;
  final int popularity;
  final int morale;
  final String injuryStatus;
  final int winStreak;
  final int lossStreak;
  final int eloRating;
  final bool isRanked;
  final bool retired;
  final String? retirementReason;
  final int fightOfTheNightCount;
  final int performanceOfTheNightCount;
  const FighterRow(
      {required this.id,
      required this.name,
      required this.age,
      required this.nationality,
      required this.weightClass,
      required this.heightInches,
      required this.weightLbs,
      required this.reachInches,
      required this.wins,
      required this.losses,
      required this.draws,
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
      required this.fightIq,
      required this.composure,
      required this.aggression,
      required this.discipline,
      required this.confidence,
      required this.heart,
      required this.adaptability,
      required this.killerInstinct,
      required this.tendStrikingFrequency,
      required this.tendTakedownFrequency,
      required this.tendKickFrequency,
      required this.tendClinchFrequency,
      required this.tendSubmissionAttempts,
      required this.tendGroundAndPound,
      required this.tendPositionControl,
      required this.tendStandUpPreference,
      required this.tendWallWork,
      required this.tendAggression,
      required this.tendCounterStriking,
      required this.tendHeadHunting,
      required this.tendBodyAttacks,
      required this.tendLegAttacks,
      required this.style,
      required this.potential,
      required this.popularity,
      required this.morale,
      required this.injuryStatus,
      required this.winStreak,
      required this.lossStreak,
      required this.eloRating,
      required this.isRanked,
      required this.retired,
      this.retirementReason,
      required this.fightOfTheNightCount,
      required this.performanceOfTheNightCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    map['nationality'] = Variable<String>(nationality);
    map['weight_class'] = Variable<String>(weightClass);
    map['height_inches'] = Variable<int>(heightInches);
    map['weight_lbs'] = Variable<int>(weightLbs);
    map['reach_inches'] = Variable<int>(reachInches);
    map['wins'] = Variable<int>(wins);
    map['losses'] = Variable<int>(losses);
    map['draws'] = Variable<int>(draws);
    map['punching'] = Variable<int>(punching);
    map['kicking'] = Variable<int>(kicking);
    map['power'] = Variable<int>(power);
    map['speed'] = Variable<int>(speed);
    map['accuracy'] = Variable<int>(accuracy);
    map['defense'] = Variable<int>(defense);
    map['head_movement'] = Variable<int>(headMovement);
    map['blocking'] = Variable<int>(blocking);
    map['footwork'] = Variable<int>(footwork);
    map['takedowns'] = Variable<int>(takedowns);
    map['takedown_defense'] = Variable<int>(takedownDefense);
    map['wrestling'] = Variable<int>(wrestling);
    map['clinch_striking'] = Variable<int>(clinchStriking);
    map['clinch_control'] = Variable<int>(clinchControl);
    map['clinch_defense'] = Variable<int>(clinchDefense);
    map['top_control'] = Variable<int>(topControl);
    map['ground_and_pound'] = Variable<int>(groundAndPound);
    map['guard_retention'] = Variable<int>(guardRetention);
    map['sweeps'] = Variable<int>(sweeps);
    map['scrambling'] = Variable<int>(scrambling);
    map['submission_offense'] = Variable<int>(submissionOffense);
    map['submission_defense'] = Variable<int>(submissionDefense);
    map['grappling'] = Variable<int>(grappling);
    map['cardio'] = Variable<int>(cardio);
    map['durability'] = Variable<int>(durability);
    map['chin'] = Variable<int>(chin);
    map['body_toughness'] = Variable<int>(bodyToughness);
    map['leg_toughness'] = Variable<int>(legToughness);
    map['strength'] = Variable<int>(strength);
    map['athleticism'] = Variable<int>(athleticism);
    map['recovery'] = Variable<int>(recovery);
    map['explosiveness'] = Variable<int>(explosiveness);
    map['flexibility'] = Variable<int>(flexibility);
    map['grip_strength'] = Variable<int>(gripStrength);
    map['fight_iq'] = Variable<int>(fightIq);
    map['composure'] = Variable<int>(composure);
    map['aggression'] = Variable<int>(aggression);
    map['discipline'] = Variable<int>(discipline);
    map['confidence'] = Variable<int>(confidence);
    map['heart'] = Variable<int>(heart);
    map['adaptability'] = Variable<int>(adaptability);
    map['killer_instinct'] = Variable<int>(killerInstinct);
    map['tend_striking_frequency'] = Variable<int>(tendStrikingFrequency);
    map['tend_takedown_frequency'] = Variable<int>(tendTakedownFrequency);
    map['tend_kick_frequency'] = Variable<int>(tendKickFrequency);
    map['tend_clinch_frequency'] = Variable<int>(tendClinchFrequency);
    map['tend_submission_attempts'] = Variable<int>(tendSubmissionAttempts);
    map['tend_ground_and_pound'] = Variable<int>(tendGroundAndPound);
    map['tend_position_control'] = Variable<int>(tendPositionControl);
    map['tend_stand_up_preference'] = Variable<int>(tendStandUpPreference);
    map['tend_wall_work'] = Variable<int>(tendWallWork);
    map['tend_aggression'] = Variable<int>(tendAggression);
    map['tend_counter_striking'] = Variable<int>(tendCounterStriking);
    map['tend_head_hunting'] = Variable<int>(tendHeadHunting);
    map['tend_body_attacks'] = Variable<int>(tendBodyAttacks);
    map['tend_leg_attacks'] = Variable<int>(tendLegAttacks);
    map['style'] = Variable<String>(style);
    map['potential'] = Variable<int>(potential);
    map['popularity'] = Variable<int>(popularity);
    map['morale'] = Variable<int>(morale);
    map['injury_status'] = Variable<String>(injuryStatus);
    map['win_streak'] = Variable<int>(winStreak);
    map['loss_streak'] = Variable<int>(lossStreak);
    map['elo_rating'] = Variable<int>(eloRating);
    map['is_ranked'] = Variable<bool>(isRanked);
    map['retired'] = Variable<bool>(retired);
    if (!nullToAbsent || retirementReason != null) {
      map['retirement_reason'] = Variable<String>(retirementReason);
    }
    map['fight_of_the_night_count'] = Variable<int>(fightOfTheNightCount);
    map['performance_of_the_night_count'] =
        Variable<int>(performanceOfTheNightCount);
    return map;
  }

  FightersCompanion toCompanion(bool nullToAbsent) {
    return FightersCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      nationality: Value(nationality),
      weightClass: Value(weightClass),
      heightInches: Value(heightInches),
      weightLbs: Value(weightLbs),
      reachInches: Value(reachInches),
      wins: Value(wins),
      losses: Value(losses),
      draws: Value(draws),
      punching: Value(punching),
      kicking: Value(kicking),
      power: Value(power),
      speed: Value(speed),
      accuracy: Value(accuracy),
      defense: Value(defense),
      headMovement: Value(headMovement),
      blocking: Value(blocking),
      footwork: Value(footwork),
      takedowns: Value(takedowns),
      takedownDefense: Value(takedownDefense),
      wrestling: Value(wrestling),
      clinchStriking: Value(clinchStriking),
      clinchControl: Value(clinchControl),
      clinchDefense: Value(clinchDefense),
      topControl: Value(topControl),
      groundAndPound: Value(groundAndPound),
      guardRetention: Value(guardRetention),
      sweeps: Value(sweeps),
      scrambling: Value(scrambling),
      submissionOffense: Value(submissionOffense),
      submissionDefense: Value(submissionDefense),
      grappling: Value(grappling),
      cardio: Value(cardio),
      durability: Value(durability),
      chin: Value(chin),
      bodyToughness: Value(bodyToughness),
      legToughness: Value(legToughness),
      strength: Value(strength),
      athleticism: Value(athleticism),
      recovery: Value(recovery),
      explosiveness: Value(explosiveness),
      flexibility: Value(flexibility),
      gripStrength: Value(gripStrength),
      fightIq: Value(fightIq),
      composure: Value(composure),
      aggression: Value(aggression),
      discipline: Value(discipline),
      confidence: Value(confidence),
      heart: Value(heart),
      adaptability: Value(adaptability),
      killerInstinct: Value(killerInstinct),
      tendStrikingFrequency: Value(tendStrikingFrequency),
      tendTakedownFrequency: Value(tendTakedownFrequency),
      tendKickFrequency: Value(tendKickFrequency),
      tendClinchFrequency: Value(tendClinchFrequency),
      tendSubmissionAttempts: Value(tendSubmissionAttempts),
      tendGroundAndPound: Value(tendGroundAndPound),
      tendPositionControl: Value(tendPositionControl),
      tendStandUpPreference: Value(tendStandUpPreference),
      tendWallWork: Value(tendWallWork),
      tendAggression: Value(tendAggression),
      tendCounterStriking: Value(tendCounterStriking),
      tendHeadHunting: Value(tendHeadHunting),
      tendBodyAttacks: Value(tendBodyAttacks),
      tendLegAttacks: Value(tendLegAttacks),
      style: Value(style),
      potential: Value(potential),
      popularity: Value(popularity),
      morale: Value(morale),
      injuryStatus: Value(injuryStatus),
      winStreak: Value(winStreak),
      lossStreak: Value(lossStreak),
      eloRating: Value(eloRating),
      isRanked: Value(isRanked),
      retired: Value(retired),
      retirementReason: retirementReason == null && nullToAbsent
          ? const Value.absent()
          : Value(retirementReason),
      fightOfTheNightCount: Value(fightOfTheNightCount),
      performanceOfTheNightCount: Value(performanceOfTheNightCount),
    );
  }

  factory FighterRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FighterRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      nationality: serializer.fromJson<String>(json['nationality']),
      weightClass: serializer.fromJson<String>(json['weightClass']),
      heightInches: serializer.fromJson<int>(json['heightInches']),
      weightLbs: serializer.fromJson<int>(json['weightLbs']),
      reachInches: serializer.fromJson<int>(json['reachInches']),
      wins: serializer.fromJson<int>(json['wins']),
      losses: serializer.fromJson<int>(json['losses']),
      draws: serializer.fromJson<int>(json['draws']),
      punching: serializer.fromJson<int>(json['punching']),
      kicking: serializer.fromJson<int>(json['kicking']),
      power: serializer.fromJson<int>(json['power']),
      speed: serializer.fromJson<int>(json['speed']),
      accuracy: serializer.fromJson<int>(json['accuracy']),
      defense: serializer.fromJson<int>(json['defense']),
      headMovement: serializer.fromJson<int>(json['headMovement']),
      blocking: serializer.fromJson<int>(json['blocking']),
      footwork: serializer.fromJson<int>(json['footwork']),
      takedowns: serializer.fromJson<int>(json['takedowns']),
      takedownDefense: serializer.fromJson<int>(json['takedownDefense']),
      wrestling: serializer.fromJson<int>(json['wrestling']),
      clinchStriking: serializer.fromJson<int>(json['clinchStriking']),
      clinchControl: serializer.fromJson<int>(json['clinchControl']),
      clinchDefense: serializer.fromJson<int>(json['clinchDefense']),
      topControl: serializer.fromJson<int>(json['topControl']),
      groundAndPound: serializer.fromJson<int>(json['groundAndPound']),
      guardRetention: serializer.fromJson<int>(json['guardRetention']),
      sweeps: serializer.fromJson<int>(json['sweeps']),
      scrambling: serializer.fromJson<int>(json['scrambling']),
      submissionOffense: serializer.fromJson<int>(json['submissionOffense']),
      submissionDefense: serializer.fromJson<int>(json['submissionDefense']),
      grappling: serializer.fromJson<int>(json['grappling']),
      cardio: serializer.fromJson<int>(json['cardio']),
      durability: serializer.fromJson<int>(json['durability']),
      chin: serializer.fromJson<int>(json['chin']),
      bodyToughness: serializer.fromJson<int>(json['bodyToughness']),
      legToughness: serializer.fromJson<int>(json['legToughness']),
      strength: serializer.fromJson<int>(json['strength']),
      athleticism: serializer.fromJson<int>(json['athleticism']),
      recovery: serializer.fromJson<int>(json['recovery']),
      explosiveness: serializer.fromJson<int>(json['explosiveness']),
      flexibility: serializer.fromJson<int>(json['flexibility']),
      gripStrength: serializer.fromJson<int>(json['gripStrength']),
      fightIq: serializer.fromJson<int>(json['fightIq']),
      composure: serializer.fromJson<int>(json['composure']),
      aggression: serializer.fromJson<int>(json['aggression']),
      discipline: serializer.fromJson<int>(json['discipline']),
      confidence: serializer.fromJson<int>(json['confidence']),
      heart: serializer.fromJson<int>(json['heart']),
      adaptability: serializer.fromJson<int>(json['adaptability']),
      killerInstinct: serializer.fromJson<int>(json['killerInstinct']),
      tendStrikingFrequency:
          serializer.fromJson<int>(json['tendStrikingFrequency']),
      tendTakedownFrequency:
          serializer.fromJson<int>(json['tendTakedownFrequency']),
      tendKickFrequency: serializer.fromJson<int>(json['tendKickFrequency']),
      tendClinchFrequency:
          serializer.fromJson<int>(json['tendClinchFrequency']),
      tendSubmissionAttempts:
          serializer.fromJson<int>(json['tendSubmissionAttempts']),
      tendGroundAndPound: serializer.fromJson<int>(json['tendGroundAndPound']),
      tendPositionControl:
          serializer.fromJson<int>(json['tendPositionControl']),
      tendStandUpPreference:
          serializer.fromJson<int>(json['tendStandUpPreference']),
      tendWallWork: serializer.fromJson<int>(json['tendWallWork']),
      tendAggression: serializer.fromJson<int>(json['tendAggression']),
      tendCounterStriking:
          serializer.fromJson<int>(json['tendCounterStriking']),
      tendHeadHunting: serializer.fromJson<int>(json['tendHeadHunting']),
      tendBodyAttacks: serializer.fromJson<int>(json['tendBodyAttacks']),
      tendLegAttacks: serializer.fromJson<int>(json['tendLegAttacks']),
      style: serializer.fromJson<String>(json['style']),
      potential: serializer.fromJson<int>(json['potential']),
      popularity: serializer.fromJson<int>(json['popularity']),
      morale: serializer.fromJson<int>(json['morale']),
      injuryStatus: serializer.fromJson<String>(json['injuryStatus']),
      winStreak: serializer.fromJson<int>(json['winStreak']),
      lossStreak: serializer.fromJson<int>(json['lossStreak']),
      eloRating: serializer.fromJson<int>(json['eloRating']),
      isRanked: serializer.fromJson<bool>(json['isRanked']),
      retired: serializer.fromJson<bool>(json['retired']),
      retirementReason: serializer.fromJson<String?>(json['retirementReason']),
      fightOfTheNightCount:
          serializer.fromJson<int>(json['fightOfTheNightCount']),
      performanceOfTheNightCount:
          serializer.fromJson<int>(json['performanceOfTheNightCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'nationality': serializer.toJson<String>(nationality),
      'weightClass': serializer.toJson<String>(weightClass),
      'heightInches': serializer.toJson<int>(heightInches),
      'weightLbs': serializer.toJson<int>(weightLbs),
      'reachInches': serializer.toJson<int>(reachInches),
      'wins': serializer.toJson<int>(wins),
      'losses': serializer.toJson<int>(losses),
      'draws': serializer.toJson<int>(draws),
      'punching': serializer.toJson<int>(punching),
      'kicking': serializer.toJson<int>(kicking),
      'power': serializer.toJson<int>(power),
      'speed': serializer.toJson<int>(speed),
      'accuracy': serializer.toJson<int>(accuracy),
      'defense': serializer.toJson<int>(defense),
      'headMovement': serializer.toJson<int>(headMovement),
      'blocking': serializer.toJson<int>(blocking),
      'footwork': serializer.toJson<int>(footwork),
      'takedowns': serializer.toJson<int>(takedowns),
      'takedownDefense': serializer.toJson<int>(takedownDefense),
      'wrestling': serializer.toJson<int>(wrestling),
      'clinchStriking': serializer.toJson<int>(clinchStriking),
      'clinchControl': serializer.toJson<int>(clinchControl),
      'clinchDefense': serializer.toJson<int>(clinchDefense),
      'topControl': serializer.toJson<int>(topControl),
      'groundAndPound': serializer.toJson<int>(groundAndPound),
      'guardRetention': serializer.toJson<int>(guardRetention),
      'sweeps': serializer.toJson<int>(sweeps),
      'scrambling': serializer.toJson<int>(scrambling),
      'submissionOffense': serializer.toJson<int>(submissionOffense),
      'submissionDefense': serializer.toJson<int>(submissionDefense),
      'grappling': serializer.toJson<int>(grappling),
      'cardio': serializer.toJson<int>(cardio),
      'durability': serializer.toJson<int>(durability),
      'chin': serializer.toJson<int>(chin),
      'bodyToughness': serializer.toJson<int>(bodyToughness),
      'legToughness': serializer.toJson<int>(legToughness),
      'strength': serializer.toJson<int>(strength),
      'athleticism': serializer.toJson<int>(athleticism),
      'recovery': serializer.toJson<int>(recovery),
      'explosiveness': serializer.toJson<int>(explosiveness),
      'flexibility': serializer.toJson<int>(flexibility),
      'gripStrength': serializer.toJson<int>(gripStrength),
      'fightIq': serializer.toJson<int>(fightIq),
      'composure': serializer.toJson<int>(composure),
      'aggression': serializer.toJson<int>(aggression),
      'discipline': serializer.toJson<int>(discipline),
      'confidence': serializer.toJson<int>(confidence),
      'heart': serializer.toJson<int>(heart),
      'adaptability': serializer.toJson<int>(adaptability),
      'killerInstinct': serializer.toJson<int>(killerInstinct),
      'tendStrikingFrequency': serializer.toJson<int>(tendStrikingFrequency),
      'tendTakedownFrequency': serializer.toJson<int>(tendTakedownFrequency),
      'tendKickFrequency': serializer.toJson<int>(tendKickFrequency),
      'tendClinchFrequency': serializer.toJson<int>(tendClinchFrequency),
      'tendSubmissionAttempts': serializer.toJson<int>(tendSubmissionAttempts),
      'tendGroundAndPound': serializer.toJson<int>(tendGroundAndPound),
      'tendPositionControl': serializer.toJson<int>(tendPositionControl),
      'tendStandUpPreference': serializer.toJson<int>(tendStandUpPreference),
      'tendWallWork': serializer.toJson<int>(tendWallWork),
      'tendAggression': serializer.toJson<int>(tendAggression),
      'tendCounterStriking': serializer.toJson<int>(tendCounterStriking),
      'tendHeadHunting': serializer.toJson<int>(tendHeadHunting),
      'tendBodyAttacks': serializer.toJson<int>(tendBodyAttacks),
      'tendLegAttacks': serializer.toJson<int>(tendLegAttacks),
      'style': serializer.toJson<String>(style),
      'potential': serializer.toJson<int>(potential),
      'popularity': serializer.toJson<int>(popularity),
      'morale': serializer.toJson<int>(morale),
      'injuryStatus': serializer.toJson<String>(injuryStatus),
      'winStreak': serializer.toJson<int>(winStreak),
      'lossStreak': serializer.toJson<int>(lossStreak),
      'eloRating': serializer.toJson<int>(eloRating),
      'isRanked': serializer.toJson<bool>(isRanked),
      'retired': serializer.toJson<bool>(retired),
      'retirementReason': serializer.toJson<String?>(retirementReason),
      'fightOfTheNightCount': serializer.toJson<int>(fightOfTheNightCount),
      'performanceOfTheNightCount':
          serializer.toJson<int>(performanceOfTheNightCount),
    };
  }

  FighterRow copyWith(
          {String? id,
          String? name,
          int? age,
          String? nationality,
          String? weightClass,
          int? heightInches,
          int? weightLbs,
          int? reachInches,
          int? wins,
          int? losses,
          int? draws,
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
          int? fightIq,
          int? composure,
          int? aggression,
          int? discipline,
          int? confidence,
          int? heart,
          int? adaptability,
          int? killerInstinct,
          int? tendStrikingFrequency,
          int? tendTakedownFrequency,
          int? tendKickFrequency,
          int? tendClinchFrequency,
          int? tendSubmissionAttempts,
          int? tendGroundAndPound,
          int? tendPositionControl,
          int? tendStandUpPreference,
          int? tendWallWork,
          int? tendAggression,
          int? tendCounterStriking,
          int? tendHeadHunting,
          int? tendBodyAttacks,
          int? tendLegAttacks,
          String? style,
          int? potential,
          int? popularity,
          int? morale,
          String? injuryStatus,
          int? winStreak,
          int? lossStreak,
          int? eloRating,
          bool? isRanked,
          bool? retired,
          Value<String?> retirementReason = const Value.absent(),
          int? fightOfTheNightCount,
          int? performanceOfTheNightCount}) =>
      FighterRow(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        nationality: nationality ?? this.nationality,
        weightClass: weightClass ?? this.weightClass,
        heightInches: heightInches ?? this.heightInches,
        weightLbs: weightLbs ?? this.weightLbs,
        reachInches: reachInches ?? this.reachInches,
        wins: wins ?? this.wins,
        losses: losses ?? this.losses,
        draws: draws ?? this.draws,
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
        fightIq: fightIq ?? this.fightIq,
        composure: composure ?? this.composure,
        aggression: aggression ?? this.aggression,
        discipline: discipline ?? this.discipline,
        confidence: confidence ?? this.confidence,
        heart: heart ?? this.heart,
        adaptability: adaptability ?? this.adaptability,
        killerInstinct: killerInstinct ?? this.killerInstinct,
        tendStrikingFrequency:
            tendStrikingFrequency ?? this.tendStrikingFrequency,
        tendTakedownFrequency:
            tendTakedownFrequency ?? this.tendTakedownFrequency,
        tendKickFrequency: tendKickFrequency ?? this.tendKickFrequency,
        tendClinchFrequency: tendClinchFrequency ?? this.tendClinchFrequency,
        tendSubmissionAttempts:
            tendSubmissionAttempts ?? this.tendSubmissionAttempts,
        tendGroundAndPound: tendGroundAndPound ?? this.tendGroundAndPound,
        tendPositionControl: tendPositionControl ?? this.tendPositionControl,
        tendStandUpPreference:
            tendStandUpPreference ?? this.tendStandUpPreference,
        tendWallWork: tendWallWork ?? this.tendWallWork,
        tendAggression: tendAggression ?? this.tendAggression,
        tendCounterStriking: tendCounterStriking ?? this.tendCounterStriking,
        tendHeadHunting: tendHeadHunting ?? this.tendHeadHunting,
        tendBodyAttacks: tendBodyAttacks ?? this.tendBodyAttacks,
        tendLegAttacks: tendLegAttacks ?? this.tendLegAttacks,
        style: style ?? this.style,
        potential: potential ?? this.potential,
        popularity: popularity ?? this.popularity,
        morale: morale ?? this.morale,
        injuryStatus: injuryStatus ?? this.injuryStatus,
        winStreak: winStreak ?? this.winStreak,
        lossStreak: lossStreak ?? this.lossStreak,
        eloRating: eloRating ?? this.eloRating,
        isRanked: isRanked ?? this.isRanked,
        retired: retired ?? this.retired,
        retirementReason: retirementReason.present
            ? retirementReason.value
            : this.retirementReason,
        fightOfTheNightCount: fightOfTheNightCount ?? this.fightOfTheNightCount,
        performanceOfTheNightCount:
            performanceOfTheNightCount ?? this.performanceOfTheNightCount,
      );
  FighterRow copyWithCompanion(FightersCompanion data) {
    return FighterRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      nationality:
          data.nationality.present ? data.nationality.value : this.nationality,
      weightClass:
          data.weightClass.present ? data.weightClass.value : this.weightClass,
      heightInches: data.heightInches.present
          ? data.heightInches.value
          : this.heightInches,
      weightLbs: data.weightLbs.present ? data.weightLbs.value : this.weightLbs,
      reachInches:
          data.reachInches.present ? data.reachInches.value : this.reachInches,
      wins: data.wins.present ? data.wins.value : this.wins,
      losses: data.losses.present ? data.losses.value : this.losses,
      draws: data.draws.present ? data.draws.value : this.draws,
      punching: data.punching.present ? data.punching.value : this.punching,
      kicking: data.kicking.present ? data.kicking.value : this.kicking,
      power: data.power.present ? data.power.value : this.power,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      defense: data.defense.present ? data.defense.value : this.defense,
      headMovement: data.headMovement.present
          ? data.headMovement.value
          : this.headMovement,
      blocking: data.blocking.present ? data.blocking.value : this.blocking,
      footwork: data.footwork.present ? data.footwork.value : this.footwork,
      takedowns: data.takedowns.present ? data.takedowns.value : this.takedowns,
      takedownDefense: data.takedownDefense.present
          ? data.takedownDefense.value
          : this.takedownDefense,
      wrestling: data.wrestling.present ? data.wrestling.value : this.wrestling,
      clinchStriking: data.clinchStriking.present
          ? data.clinchStriking.value
          : this.clinchStriking,
      clinchControl: data.clinchControl.present
          ? data.clinchControl.value
          : this.clinchControl,
      clinchDefense: data.clinchDefense.present
          ? data.clinchDefense.value
          : this.clinchDefense,
      topControl:
          data.topControl.present ? data.topControl.value : this.topControl,
      groundAndPound: data.groundAndPound.present
          ? data.groundAndPound.value
          : this.groundAndPound,
      guardRetention: data.guardRetention.present
          ? data.guardRetention.value
          : this.guardRetention,
      sweeps: data.sweeps.present ? data.sweeps.value : this.sweeps,
      scrambling:
          data.scrambling.present ? data.scrambling.value : this.scrambling,
      submissionOffense: data.submissionOffense.present
          ? data.submissionOffense.value
          : this.submissionOffense,
      submissionDefense: data.submissionDefense.present
          ? data.submissionDefense.value
          : this.submissionDefense,
      grappling: data.grappling.present ? data.grappling.value : this.grappling,
      cardio: data.cardio.present ? data.cardio.value : this.cardio,
      durability:
          data.durability.present ? data.durability.value : this.durability,
      chin: data.chin.present ? data.chin.value : this.chin,
      bodyToughness: data.bodyToughness.present
          ? data.bodyToughness.value
          : this.bodyToughness,
      legToughness: data.legToughness.present
          ? data.legToughness.value
          : this.legToughness,
      strength: data.strength.present ? data.strength.value : this.strength,
      athleticism:
          data.athleticism.present ? data.athleticism.value : this.athleticism,
      recovery: data.recovery.present ? data.recovery.value : this.recovery,
      explosiveness: data.explosiveness.present
          ? data.explosiveness.value
          : this.explosiveness,
      flexibility:
          data.flexibility.present ? data.flexibility.value : this.flexibility,
      gripStrength: data.gripStrength.present
          ? data.gripStrength.value
          : this.gripStrength,
      fightIq: data.fightIq.present ? data.fightIq.value : this.fightIq,
      composure: data.composure.present ? data.composure.value : this.composure,
      aggression:
          data.aggression.present ? data.aggression.value : this.aggression,
      discipline:
          data.discipline.present ? data.discipline.value : this.discipline,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      heart: data.heart.present ? data.heart.value : this.heart,
      adaptability: data.adaptability.present
          ? data.adaptability.value
          : this.adaptability,
      killerInstinct: data.killerInstinct.present
          ? data.killerInstinct.value
          : this.killerInstinct,
      tendStrikingFrequency: data.tendStrikingFrequency.present
          ? data.tendStrikingFrequency.value
          : this.tendStrikingFrequency,
      tendTakedownFrequency: data.tendTakedownFrequency.present
          ? data.tendTakedownFrequency.value
          : this.tendTakedownFrequency,
      tendKickFrequency: data.tendKickFrequency.present
          ? data.tendKickFrequency.value
          : this.tendKickFrequency,
      tendClinchFrequency: data.tendClinchFrequency.present
          ? data.tendClinchFrequency.value
          : this.tendClinchFrequency,
      tendSubmissionAttempts: data.tendSubmissionAttempts.present
          ? data.tendSubmissionAttempts.value
          : this.tendSubmissionAttempts,
      tendGroundAndPound: data.tendGroundAndPound.present
          ? data.tendGroundAndPound.value
          : this.tendGroundAndPound,
      tendPositionControl: data.tendPositionControl.present
          ? data.tendPositionControl.value
          : this.tendPositionControl,
      tendStandUpPreference: data.tendStandUpPreference.present
          ? data.tendStandUpPreference.value
          : this.tendStandUpPreference,
      tendWallWork: data.tendWallWork.present
          ? data.tendWallWork.value
          : this.tendWallWork,
      tendAggression: data.tendAggression.present
          ? data.tendAggression.value
          : this.tendAggression,
      tendCounterStriking: data.tendCounterStriking.present
          ? data.tendCounterStriking.value
          : this.tendCounterStriking,
      tendHeadHunting: data.tendHeadHunting.present
          ? data.tendHeadHunting.value
          : this.tendHeadHunting,
      tendBodyAttacks: data.tendBodyAttacks.present
          ? data.tendBodyAttacks.value
          : this.tendBodyAttacks,
      tendLegAttacks: data.tendLegAttacks.present
          ? data.tendLegAttacks.value
          : this.tendLegAttacks,
      style: data.style.present ? data.style.value : this.style,
      potential: data.potential.present ? data.potential.value : this.potential,
      popularity:
          data.popularity.present ? data.popularity.value : this.popularity,
      morale: data.morale.present ? data.morale.value : this.morale,
      injuryStatus: data.injuryStatus.present
          ? data.injuryStatus.value
          : this.injuryStatus,
      winStreak: data.winStreak.present ? data.winStreak.value : this.winStreak,
      lossStreak:
          data.lossStreak.present ? data.lossStreak.value : this.lossStreak,
      eloRating: data.eloRating.present ? data.eloRating.value : this.eloRating,
      isRanked: data.isRanked.present ? data.isRanked.value : this.isRanked,
      retired: data.retired.present ? data.retired.value : this.retired,
      retirementReason: data.retirementReason.present
          ? data.retirementReason.value
          : this.retirementReason,
      fightOfTheNightCount: data.fightOfTheNightCount.present
          ? data.fightOfTheNightCount.value
          : this.fightOfTheNightCount,
      performanceOfTheNightCount: data.performanceOfTheNightCount.present
          ? data.performanceOfTheNightCount.value
          : this.performanceOfTheNightCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FighterRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('nationality: $nationality, ')
          ..write('weightClass: $weightClass, ')
          ..write('heightInches: $heightInches, ')
          ..write('weightLbs: $weightLbs, ')
          ..write('reachInches: $reachInches, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('draws: $draws, ')
          ..write('punching: $punching, ')
          ..write('kicking: $kicking, ')
          ..write('power: $power, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('defense: $defense, ')
          ..write('headMovement: $headMovement, ')
          ..write('blocking: $blocking, ')
          ..write('footwork: $footwork, ')
          ..write('takedowns: $takedowns, ')
          ..write('takedownDefense: $takedownDefense, ')
          ..write('wrestling: $wrestling, ')
          ..write('clinchStriking: $clinchStriking, ')
          ..write('clinchControl: $clinchControl, ')
          ..write('clinchDefense: $clinchDefense, ')
          ..write('topControl: $topControl, ')
          ..write('groundAndPound: $groundAndPound, ')
          ..write('guardRetention: $guardRetention, ')
          ..write('sweeps: $sweeps, ')
          ..write('scrambling: $scrambling, ')
          ..write('submissionOffense: $submissionOffense, ')
          ..write('submissionDefense: $submissionDefense, ')
          ..write('grappling: $grappling, ')
          ..write('cardio: $cardio, ')
          ..write('durability: $durability, ')
          ..write('chin: $chin, ')
          ..write('bodyToughness: $bodyToughness, ')
          ..write('legToughness: $legToughness, ')
          ..write('strength: $strength, ')
          ..write('athleticism: $athleticism, ')
          ..write('recovery: $recovery, ')
          ..write('explosiveness: $explosiveness, ')
          ..write('flexibility: $flexibility, ')
          ..write('gripStrength: $gripStrength, ')
          ..write('fightIq: $fightIq, ')
          ..write('composure: $composure, ')
          ..write('aggression: $aggression, ')
          ..write('discipline: $discipline, ')
          ..write('confidence: $confidence, ')
          ..write('heart: $heart, ')
          ..write('adaptability: $adaptability, ')
          ..write('killerInstinct: $killerInstinct, ')
          ..write('tendStrikingFrequency: $tendStrikingFrequency, ')
          ..write('tendTakedownFrequency: $tendTakedownFrequency, ')
          ..write('tendKickFrequency: $tendKickFrequency, ')
          ..write('tendClinchFrequency: $tendClinchFrequency, ')
          ..write('tendSubmissionAttempts: $tendSubmissionAttempts, ')
          ..write('tendGroundAndPound: $tendGroundAndPound, ')
          ..write('tendPositionControl: $tendPositionControl, ')
          ..write('tendStandUpPreference: $tendStandUpPreference, ')
          ..write('tendWallWork: $tendWallWork, ')
          ..write('tendAggression: $tendAggression, ')
          ..write('tendCounterStriking: $tendCounterStriking, ')
          ..write('tendHeadHunting: $tendHeadHunting, ')
          ..write('tendBodyAttacks: $tendBodyAttacks, ')
          ..write('tendLegAttacks: $tendLegAttacks, ')
          ..write('style: $style, ')
          ..write('potential: $potential, ')
          ..write('popularity: $popularity, ')
          ..write('morale: $morale, ')
          ..write('injuryStatus: $injuryStatus, ')
          ..write('winStreak: $winStreak, ')
          ..write('lossStreak: $lossStreak, ')
          ..write('eloRating: $eloRating, ')
          ..write('isRanked: $isRanked, ')
          ..write('retired: $retired, ')
          ..write('retirementReason: $retirementReason, ')
          ..write('fightOfTheNightCount: $fightOfTheNightCount, ')
          ..write('performanceOfTheNightCount: $performanceOfTheNightCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        age,
        nationality,
        weightClass,
        heightInches,
        weightLbs,
        reachInches,
        wins,
        losses,
        draws,
        punching,
        kicking,
        power,
        speed,
        accuracy,
        defense,
        headMovement,
        blocking,
        footwork,
        takedowns,
        takedownDefense,
        wrestling,
        clinchStriking,
        clinchControl,
        clinchDefense,
        topControl,
        groundAndPound,
        guardRetention,
        sweeps,
        scrambling,
        submissionOffense,
        submissionDefense,
        grappling,
        cardio,
        durability,
        chin,
        bodyToughness,
        legToughness,
        strength,
        athleticism,
        recovery,
        explosiveness,
        flexibility,
        gripStrength,
        fightIq,
        composure,
        aggression,
        discipline,
        confidence,
        heart,
        adaptability,
        killerInstinct,
        tendStrikingFrequency,
        tendTakedownFrequency,
        tendKickFrequency,
        tendClinchFrequency,
        tendSubmissionAttempts,
        tendGroundAndPound,
        tendPositionControl,
        tendStandUpPreference,
        tendWallWork,
        tendAggression,
        tendCounterStriking,
        tendHeadHunting,
        tendBodyAttacks,
        tendLegAttacks,
        style,
        potential,
        popularity,
        morale,
        injuryStatus,
        winStreak,
        lossStreak,
        eloRating,
        isRanked,
        retired,
        retirementReason,
        fightOfTheNightCount,
        performanceOfTheNightCount
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FighterRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.nationality == this.nationality &&
          other.weightClass == this.weightClass &&
          other.heightInches == this.heightInches &&
          other.weightLbs == this.weightLbs &&
          other.reachInches == this.reachInches &&
          other.wins == this.wins &&
          other.losses == this.losses &&
          other.draws == this.draws &&
          other.punching == this.punching &&
          other.kicking == this.kicking &&
          other.power == this.power &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy &&
          other.defense == this.defense &&
          other.headMovement == this.headMovement &&
          other.blocking == this.blocking &&
          other.footwork == this.footwork &&
          other.takedowns == this.takedowns &&
          other.takedownDefense == this.takedownDefense &&
          other.wrestling == this.wrestling &&
          other.clinchStriking == this.clinchStriking &&
          other.clinchControl == this.clinchControl &&
          other.clinchDefense == this.clinchDefense &&
          other.topControl == this.topControl &&
          other.groundAndPound == this.groundAndPound &&
          other.guardRetention == this.guardRetention &&
          other.sweeps == this.sweeps &&
          other.scrambling == this.scrambling &&
          other.submissionOffense == this.submissionOffense &&
          other.submissionDefense == this.submissionDefense &&
          other.grappling == this.grappling &&
          other.cardio == this.cardio &&
          other.durability == this.durability &&
          other.chin == this.chin &&
          other.bodyToughness == this.bodyToughness &&
          other.legToughness == this.legToughness &&
          other.strength == this.strength &&
          other.athleticism == this.athleticism &&
          other.recovery == this.recovery &&
          other.explosiveness == this.explosiveness &&
          other.flexibility == this.flexibility &&
          other.gripStrength == this.gripStrength &&
          other.fightIq == this.fightIq &&
          other.composure == this.composure &&
          other.aggression == this.aggression &&
          other.discipline == this.discipline &&
          other.confidence == this.confidence &&
          other.heart == this.heart &&
          other.adaptability == this.adaptability &&
          other.killerInstinct == this.killerInstinct &&
          other.tendStrikingFrequency == this.tendStrikingFrequency &&
          other.tendTakedownFrequency == this.tendTakedownFrequency &&
          other.tendKickFrequency == this.tendKickFrequency &&
          other.tendClinchFrequency == this.tendClinchFrequency &&
          other.tendSubmissionAttempts == this.tendSubmissionAttempts &&
          other.tendGroundAndPound == this.tendGroundAndPound &&
          other.tendPositionControl == this.tendPositionControl &&
          other.tendStandUpPreference == this.tendStandUpPreference &&
          other.tendWallWork == this.tendWallWork &&
          other.tendAggression == this.tendAggression &&
          other.tendCounterStriking == this.tendCounterStriking &&
          other.tendHeadHunting == this.tendHeadHunting &&
          other.tendBodyAttacks == this.tendBodyAttacks &&
          other.tendLegAttacks == this.tendLegAttacks &&
          other.style == this.style &&
          other.potential == this.potential &&
          other.popularity == this.popularity &&
          other.morale == this.morale &&
          other.injuryStatus == this.injuryStatus &&
          other.winStreak == this.winStreak &&
          other.lossStreak == this.lossStreak &&
          other.eloRating == this.eloRating &&
          other.isRanked == this.isRanked &&
          other.retired == this.retired &&
          other.retirementReason == this.retirementReason &&
          other.fightOfTheNightCount == this.fightOfTheNightCount &&
          other.performanceOfTheNightCount == this.performanceOfTheNightCount);
}

class FightersCompanion extends UpdateCompanion<FighterRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String> nationality;
  final Value<String> weightClass;
  final Value<int> heightInches;
  final Value<int> weightLbs;
  final Value<int> reachInches;
  final Value<int> wins;
  final Value<int> losses;
  final Value<int> draws;
  final Value<int> punching;
  final Value<int> kicking;
  final Value<int> power;
  final Value<int> speed;
  final Value<int> accuracy;
  final Value<int> defense;
  final Value<int> headMovement;
  final Value<int> blocking;
  final Value<int> footwork;
  final Value<int> takedowns;
  final Value<int> takedownDefense;
  final Value<int> wrestling;
  final Value<int> clinchStriking;
  final Value<int> clinchControl;
  final Value<int> clinchDefense;
  final Value<int> topControl;
  final Value<int> groundAndPound;
  final Value<int> guardRetention;
  final Value<int> sweeps;
  final Value<int> scrambling;
  final Value<int> submissionOffense;
  final Value<int> submissionDefense;
  final Value<int> grappling;
  final Value<int> cardio;
  final Value<int> durability;
  final Value<int> chin;
  final Value<int> bodyToughness;
  final Value<int> legToughness;
  final Value<int> strength;
  final Value<int> athleticism;
  final Value<int> recovery;
  final Value<int> explosiveness;
  final Value<int> flexibility;
  final Value<int> gripStrength;
  final Value<int> fightIq;
  final Value<int> composure;
  final Value<int> aggression;
  final Value<int> discipline;
  final Value<int> confidence;
  final Value<int> heart;
  final Value<int> adaptability;
  final Value<int> killerInstinct;
  final Value<int> tendStrikingFrequency;
  final Value<int> tendTakedownFrequency;
  final Value<int> tendKickFrequency;
  final Value<int> tendClinchFrequency;
  final Value<int> tendSubmissionAttempts;
  final Value<int> tendGroundAndPound;
  final Value<int> tendPositionControl;
  final Value<int> tendStandUpPreference;
  final Value<int> tendWallWork;
  final Value<int> tendAggression;
  final Value<int> tendCounterStriking;
  final Value<int> tendHeadHunting;
  final Value<int> tendBodyAttacks;
  final Value<int> tendLegAttacks;
  final Value<String> style;
  final Value<int> potential;
  final Value<int> popularity;
  final Value<int> morale;
  final Value<String> injuryStatus;
  final Value<int> winStreak;
  final Value<int> lossStreak;
  final Value<int> eloRating;
  final Value<bool> isRanked;
  final Value<bool> retired;
  final Value<String?> retirementReason;
  final Value<int> fightOfTheNightCount;
  final Value<int> performanceOfTheNightCount;
  final Value<int> rowid;
  const FightersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.nationality = const Value.absent(),
    this.weightClass = const Value.absent(),
    this.heightInches = const Value.absent(),
    this.weightLbs = const Value.absent(),
    this.reachInches = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.draws = const Value.absent(),
    this.punching = const Value.absent(),
    this.kicking = const Value.absent(),
    this.power = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.defense = const Value.absent(),
    this.headMovement = const Value.absent(),
    this.blocking = const Value.absent(),
    this.footwork = const Value.absent(),
    this.takedowns = const Value.absent(),
    this.takedownDefense = const Value.absent(),
    this.wrestling = const Value.absent(),
    this.clinchStriking = const Value.absent(),
    this.clinchControl = const Value.absent(),
    this.clinchDefense = const Value.absent(),
    this.topControl = const Value.absent(),
    this.groundAndPound = const Value.absent(),
    this.guardRetention = const Value.absent(),
    this.sweeps = const Value.absent(),
    this.scrambling = const Value.absent(),
    this.submissionOffense = const Value.absent(),
    this.submissionDefense = const Value.absent(),
    this.grappling = const Value.absent(),
    this.cardio = const Value.absent(),
    this.durability = const Value.absent(),
    this.chin = const Value.absent(),
    this.bodyToughness = const Value.absent(),
    this.legToughness = const Value.absent(),
    this.strength = const Value.absent(),
    this.athleticism = const Value.absent(),
    this.recovery = const Value.absent(),
    this.explosiveness = const Value.absent(),
    this.flexibility = const Value.absent(),
    this.gripStrength = const Value.absent(),
    this.fightIq = const Value.absent(),
    this.composure = const Value.absent(),
    this.aggression = const Value.absent(),
    this.discipline = const Value.absent(),
    this.confidence = const Value.absent(),
    this.heart = const Value.absent(),
    this.adaptability = const Value.absent(),
    this.killerInstinct = const Value.absent(),
    this.tendStrikingFrequency = const Value.absent(),
    this.tendTakedownFrequency = const Value.absent(),
    this.tendKickFrequency = const Value.absent(),
    this.tendClinchFrequency = const Value.absent(),
    this.tendSubmissionAttempts = const Value.absent(),
    this.tendGroundAndPound = const Value.absent(),
    this.tendPositionControl = const Value.absent(),
    this.tendStandUpPreference = const Value.absent(),
    this.tendWallWork = const Value.absent(),
    this.tendAggression = const Value.absent(),
    this.tendCounterStriking = const Value.absent(),
    this.tendHeadHunting = const Value.absent(),
    this.tendBodyAttacks = const Value.absent(),
    this.tendLegAttacks = const Value.absent(),
    this.style = const Value.absent(),
    this.potential = const Value.absent(),
    this.popularity = const Value.absent(),
    this.morale = const Value.absent(),
    this.injuryStatus = const Value.absent(),
    this.winStreak = const Value.absent(),
    this.lossStreak = const Value.absent(),
    this.eloRating = const Value.absent(),
    this.isRanked = const Value.absent(),
    this.retired = const Value.absent(),
    this.retirementReason = const Value.absent(),
    this.fightOfTheNightCount = const Value.absent(),
    this.performanceOfTheNightCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FightersCompanion.insert({
    required String id,
    required String name,
    required int age,
    required String nationality,
    required String weightClass,
    this.heightInches = const Value.absent(),
    this.weightLbs = const Value.absent(),
    this.reachInches = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.draws = const Value.absent(),
    required int punching,
    required int kicking,
    required int power,
    required int speed,
    required int accuracy,
    required int defense,
    this.headMovement = const Value.absent(),
    this.blocking = const Value.absent(),
    this.footwork = const Value.absent(),
    required int takedowns,
    required int takedownDefense,
    required int wrestling,
    this.clinchStriking = const Value.absent(),
    this.clinchControl = const Value.absent(),
    this.clinchDefense = const Value.absent(),
    this.topControl = const Value.absent(),
    required int groundAndPound,
    this.guardRetention = const Value.absent(),
    this.sweeps = const Value.absent(),
    this.scrambling = const Value.absent(),
    required int submissionOffense,
    required int submissionDefense,
    required int grappling,
    required int cardio,
    required int durability,
    required int chin,
    required int bodyToughness,
    required int legToughness,
    required int strength,
    required int athleticism,
    required int recovery,
    this.explosiveness = const Value.absent(),
    this.flexibility = const Value.absent(),
    this.gripStrength = const Value.absent(),
    required int fightIq,
    required int composure,
    required int aggression,
    required int discipline,
    required int confidence,
    required int heart,
    required int adaptability,
    this.killerInstinct = const Value.absent(),
    required int tendStrikingFrequency,
    required int tendTakedownFrequency,
    required int tendKickFrequency,
    required int tendClinchFrequency,
    required int tendSubmissionAttempts,
    required int tendGroundAndPound,
    this.tendPositionControl = const Value.absent(),
    this.tendStandUpPreference = const Value.absent(),
    this.tendWallWork = const Value.absent(),
    required int tendAggression,
    required int tendCounterStriking,
    required int tendHeadHunting,
    required int tendBodyAttacks,
    required int tendLegAttacks,
    this.style = const Value.absent(),
    this.potential = const Value.absent(),
    this.popularity = const Value.absent(),
    this.morale = const Value.absent(),
    this.injuryStatus = const Value.absent(),
    this.winStreak = const Value.absent(),
    this.lossStreak = const Value.absent(),
    this.eloRating = const Value.absent(),
    this.isRanked = const Value.absent(),
    this.retired = const Value.absent(),
    this.retirementReason = const Value.absent(),
    this.fightOfTheNightCount = const Value.absent(),
    this.performanceOfTheNightCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        age = Value(age),
        nationality = Value(nationality),
        weightClass = Value(weightClass),
        punching = Value(punching),
        kicking = Value(kicking),
        power = Value(power),
        speed = Value(speed),
        accuracy = Value(accuracy),
        defense = Value(defense),
        takedowns = Value(takedowns),
        takedownDefense = Value(takedownDefense),
        wrestling = Value(wrestling),
        groundAndPound = Value(groundAndPound),
        submissionOffense = Value(submissionOffense),
        submissionDefense = Value(submissionDefense),
        grappling = Value(grappling),
        cardio = Value(cardio),
        durability = Value(durability),
        chin = Value(chin),
        bodyToughness = Value(bodyToughness),
        legToughness = Value(legToughness),
        strength = Value(strength),
        athleticism = Value(athleticism),
        recovery = Value(recovery),
        fightIq = Value(fightIq),
        composure = Value(composure),
        aggression = Value(aggression),
        discipline = Value(discipline),
        confidence = Value(confidence),
        heart = Value(heart),
        adaptability = Value(adaptability),
        tendStrikingFrequency = Value(tendStrikingFrequency),
        tendTakedownFrequency = Value(tendTakedownFrequency),
        tendKickFrequency = Value(tendKickFrequency),
        tendClinchFrequency = Value(tendClinchFrequency),
        tendSubmissionAttempts = Value(tendSubmissionAttempts),
        tendGroundAndPound = Value(tendGroundAndPound),
        tendAggression = Value(tendAggression),
        tendCounterStriking = Value(tendCounterStriking),
        tendHeadHunting = Value(tendHeadHunting),
        tendBodyAttacks = Value(tendBodyAttacks),
        tendLegAttacks = Value(tendLegAttacks);
  static Insertable<FighterRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? nationality,
    Expression<String>? weightClass,
    Expression<int>? heightInches,
    Expression<int>? weightLbs,
    Expression<int>? reachInches,
    Expression<int>? wins,
    Expression<int>? losses,
    Expression<int>? draws,
    Expression<int>? punching,
    Expression<int>? kicking,
    Expression<int>? power,
    Expression<int>? speed,
    Expression<int>? accuracy,
    Expression<int>? defense,
    Expression<int>? headMovement,
    Expression<int>? blocking,
    Expression<int>? footwork,
    Expression<int>? takedowns,
    Expression<int>? takedownDefense,
    Expression<int>? wrestling,
    Expression<int>? clinchStriking,
    Expression<int>? clinchControl,
    Expression<int>? clinchDefense,
    Expression<int>? topControl,
    Expression<int>? groundAndPound,
    Expression<int>? guardRetention,
    Expression<int>? sweeps,
    Expression<int>? scrambling,
    Expression<int>? submissionOffense,
    Expression<int>? submissionDefense,
    Expression<int>? grappling,
    Expression<int>? cardio,
    Expression<int>? durability,
    Expression<int>? chin,
    Expression<int>? bodyToughness,
    Expression<int>? legToughness,
    Expression<int>? strength,
    Expression<int>? athleticism,
    Expression<int>? recovery,
    Expression<int>? explosiveness,
    Expression<int>? flexibility,
    Expression<int>? gripStrength,
    Expression<int>? fightIq,
    Expression<int>? composure,
    Expression<int>? aggression,
    Expression<int>? discipline,
    Expression<int>? confidence,
    Expression<int>? heart,
    Expression<int>? adaptability,
    Expression<int>? killerInstinct,
    Expression<int>? tendStrikingFrequency,
    Expression<int>? tendTakedownFrequency,
    Expression<int>? tendKickFrequency,
    Expression<int>? tendClinchFrequency,
    Expression<int>? tendSubmissionAttempts,
    Expression<int>? tendGroundAndPound,
    Expression<int>? tendPositionControl,
    Expression<int>? tendStandUpPreference,
    Expression<int>? tendWallWork,
    Expression<int>? tendAggression,
    Expression<int>? tendCounterStriking,
    Expression<int>? tendHeadHunting,
    Expression<int>? tendBodyAttacks,
    Expression<int>? tendLegAttacks,
    Expression<String>? style,
    Expression<int>? potential,
    Expression<int>? popularity,
    Expression<int>? morale,
    Expression<String>? injuryStatus,
    Expression<int>? winStreak,
    Expression<int>? lossStreak,
    Expression<int>? eloRating,
    Expression<bool>? isRanked,
    Expression<bool>? retired,
    Expression<String>? retirementReason,
    Expression<int>? fightOfTheNightCount,
    Expression<int>? performanceOfTheNightCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (weightClass != null) 'weight_class': weightClass,
      if (heightInches != null) 'height_inches': heightInches,
      if (weightLbs != null) 'weight_lbs': weightLbs,
      if (reachInches != null) 'reach_inches': reachInches,
      if (wins != null) 'wins': wins,
      if (losses != null) 'losses': losses,
      if (draws != null) 'draws': draws,
      if (punching != null) 'punching': punching,
      if (kicking != null) 'kicking': kicking,
      if (power != null) 'power': power,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (defense != null) 'defense': defense,
      if (headMovement != null) 'head_movement': headMovement,
      if (blocking != null) 'blocking': blocking,
      if (footwork != null) 'footwork': footwork,
      if (takedowns != null) 'takedowns': takedowns,
      if (takedownDefense != null) 'takedown_defense': takedownDefense,
      if (wrestling != null) 'wrestling': wrestling,
      if (clinchStriking != null) 'clinch_striking': clinchStriking,
      if (clinchControl != null) 'clinch_control': clinchControl,
      if (clinchDefense != null) 'clinch_defense': clinchDefense,
      if (topControl != null) 'top_control': topControl,
      if (groundAndPound != null) 'ground_and_pound': groundAndPound,
      if (guardRetention != null) 'guard_retention': guardRetention,
      if (sweeps != null) 'sweeps': sweeps,
      if (scrambling != null) 'scrambling': scrambling,
      if (submissionOffense != null) 'submission_offense': submissionOffense,
      if (submissionDefense != null) 'submission_defense': submissionDefense,
      if (grappling != null) 'grappling': grappling,
      if (cardio != null) 'cardio': cardio,
      if (durability != null) 'durability': durability,
      if (chin != null) 'chin': chin,
      if (bodyToughness != null) 'body_toughness': bodyToughness,
      if (legToughness != null) 'leg_toughness': legToughness,
      if (strength != null) 'strength': strength,
      if (athleticism != null) 'athleticism': athleticism,
      if (recovery != null) 'recovery': recovery,
      if (explosiveness != null) 'explosiveness': explosiveness,
      if (flexibility != null) 'flexibility': flexibility,
      if (gripStrength != null) 'grip_strength': gripStrength,
      if (fightIq != null) 'fight_iq': fightIq,
      if (composure != null) 'composure': composure,
      if (aggression != null) 'aggression': aggression,
      if (discipline != null) 'discipline': discipline,
      if (confidence != null) 'confidence': confidence,
      if (heart != null) 'heart': heart,
      if (adaptability != null) 'adaptability': adaptability,
      if (killerInstinct != null) 'killer_instinct': killerInstinct,
      if (tendStrikingFrequency != null)
        'tend_striking_frequency': tendStrikingFrequency,
      if (tendTakedownFrequency != null)
        'tend_takedown_frequency': tendTakedownFrequency,
      if (tendKickFrequency != null) 'tend_kick_frequency': tendKickFrequency,
      if (tendClinchFrequency != null)
        'tend_clinch_frequency': tendClinchFrequency,
      if (tendSubmissionAttempts != null)
        'tend_submission_attempts': tendSubmissionAttempts,
      if (tendGroundAndPound != null)
        'tend_ground_and_pound': tendGroundAndPound,
      if (tendPositionControl != null)
        'tend_position_control': tendPositionControl,
      if (tendStandUpPreference != null)
        'tend_stand_up_preference': tendStandUpPreference,
      if (tendWallWork != null) 'tend_wall_work': tendWallWork,
      if (tendAggression != null) 'tend_aggression': tendAggression,
      if (tendCounterStriking != null)
        'tend_counter_striking': tendCounterStriking,
      if (tendHeadHunting != null) 'tend_head_hunting': tendHeadHunting,
      if (tendBodyAttacks != null) 'tend_body_attacks': tendBodyAttacks,
      if (tendLegAttacks != null) 'tend_leg_attacks': tendLegAttacks,
      if (style != null) 'style': style,
      if (potential != null) 'potential': potential,
      if (popularity != null) 'popularity': popularity,
      if (morale != null) 'morale': morale,
      if (injuryStatus != null) 'injury_status': injuryStatus,
      if (winStreak != null) 'win_streak': winStreak,
      if (lossStreak != null) 'loss_streak': lossStreak,
      if (eloRating != null) 'elo_rating': eloRating,
      if (isRanked != null) 'is_ranked': isRanked,
      if (retired != null) 'retired': retired,
      if (retirementReason != null) 'retirement_reason': retirementReason,
      if (fightOfTheNightCount != null)
        'fight_of_the_night_count': fightOfTheNightCount,
      if (performanceOfTheNightCount != null)
        'performance_of_the_night_count': performanceOfTheNightCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FightersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? age,
      Value<String>? nationality,
      Value<String>? weightClass,
      Value<int>? heightInches,
      Value<int>? weightLbs,
      Value<int>? reachInches,
      Value<int>? wins,
      Value<int>? losses,
      Value<int>? draws,
      Value<int>? punching,
      Value<int>? kicking,
      Value<int>? power,
      Value<int>? speed,
      Value<int>? accuracy,
      Value<int>? defense,
      Value<int>? headMovement,
      Value<int>? blocking,
      Value<int>? footwork,
      Value<int>? takedowns,
      Value<int>? takedownDefense,
      Value<int>? wrestling,
      Value<int>? clinchStriking,
      Value<int>? clinchControl,
      Value<int>? clinchDefense,
      Value<int>? topControl,
      Value<int>? groundAndPound,
      Value<int>? guardRetention,
      Value<int>? sweeps,
      Value<int>? scrambling,
      Value<int>? submissionOffense,
      Value<int>? submissionDefense,
      Value<int>? grappling,
      Value<int>? cardio,
      Value<int>? durability,
      Value<int>? chin,
      Value<int>? bodyToughness,
      Value<int>? legToughness,
      Value<int>? strength,
      Value<int>? athleticism,
      Value<int>? recovery,
      Value<int>? explosiveness,
      Value<int>? flexibility,
      Value<int>? gripStrength,
      Value<int>? fightIq,
      Value<int>? composure,
      Value<int>? aggression,
      Value<int>? discipline,
      Value<int>? confidence,
      Value<int>? heart,
      Value<int>? adaptability,
      Value<int>? killerInstinct,
      Value<int>? tendStrikingFrequency,
      Value<int>? tendTakedownFrequency,
      Value<int>? tendKickFrequency,
      Value<int>? tendClinchFrequency,
      Value<int>? tendSubmissionAttempts,
      Value<int>? tendGroundAndPound,
      Value<int>? tendPositionControl,
      Value<int>? tendStandUpPreference,
      Value<int>? tendWallWork,
      Value<int>? tendAggression,
      Value<int>? tendCounterStriking,
      Value<int>? tendHeadHunting,
      Value<int>? tendBodyAttacks,
      Value<int>? tendLegAttacks,
      Value<String>? style,
      Value<int>? potential,
      Value<int>? popularity,
      Value<int>? morale,
      Value<String>? injuryStatus,
      Value<int>? winStreak,
      Value<int>? lossStreak,
      Value<int>? eloRating,
      Value<bool>? isRanked,
      Value<bool>? retired,
      Value<String?>? retirementReason,
      Value<int>? fightOfTheNightCount,
      Value<int>? performanceOfTheNightCount,
      Value<int>? rowid}) {
    return FightersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      weightClass: weightClass ?? this.weightClass,
      heightInches: heightInches ?? this.heightInches,
      weightLbs: weightLbs ?? this.weightLbs,
      reachInches: reachInches ?? this.reachInches,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
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
      fightIq: fightIq ?? this.fightIq,
      composure: composure ?? this.composure,
      aggression: aggression ?? this.aggression,
      discipline: discipline ?? this.discipline,
      confidence: confidence ?? this.confidence,
      heart: heart ?? this.heart,
      adaptability: adaptability ?? this.adaptability,
      killerInstinct: killerInstinct ?? this.killerInstinct,
      tendStrikingFrequency:
          tendStrikingFrequency ?? this.tendStrikingFrequency,
      tendTakedownFrequency:
          tendTakedownFrequency ?? this.tendTakedownFrequency,
      tendKickFrequency: tendKickFrequency ?? this.tendKickFrequency,
      tendClinchFrequency: tendClinchFrequency ?? this.tendClinchFrequency,
      tendSubmissionAttempts:
          tendSubmissionAttempts ?? this.tendSubmissionAttempts,
      tendGroundAndPound: tendGroundAndPound ?? this.tendGroundAndPound,
      tendPositionControl: tendPositionControl ?? this.tendPositionControl,
      tendStandUpPreference:
          tendStandUpPreference ?? this.tendStandUpPreference,
      tendWallWork: tendWallWork ?? this.tendWallWork,
      tendAggression: tendAggression ?? this.tendAggression,
      tendCounterStriking: tendCounterStriking ?? this.tendCounterStriking,
      tendHeadHunting: tendHeadHunting ?? this.tendHeadHunting,
      tendBodyAttacks: tendBodyAttacks ?? this.tendBodyAttacks,
      tendLegAttacks: tendLegAttacks ?? this.tendLegAttacks,
      style: style ?? this.style,
      potential: potential ?? this.potential,
      popularity: popularity ?? this.popularity,
      morale: morale ?? this.morale,
      injuryStatus: injuryStatus ?? this.injuryStatus,
      winStreak: winStreak ?? this.winStreak,
      lossStreak: lossStreak ?? this.lossStreak,
      eloRating: eloRating ?? this.eloRating,
      isRanked: isRanked ?? this.isRanked,
      retired: retired ?? this.retired,
      retirementReason: retirementReason ?? this.retirementReason,
      fightOfTheNightCount: fightOfTheNightCount ?? this.fightOfTheNightCount,
      performanceOfTheNightCount:
          performanceOfTheNightCount ?? this.performanceOfTheNightCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (nationality.present) {
      map['nationality'] = Variable<String>(nationality.value);
    }
    if (weightClass.present) {
      map['weight_class'] = Variable<String>(weightClass.value);
    }
    if (heightInches.present) {
      map['height_inches'] = Variable<int>(heightInches.value);
    }
    if (weightLbs.present) {
      map['weight_lbs'] = Variable<int>(weightLbs.value);
    }
    if (reachInches.present) {
      map['reach_inches'] = Variable<int>(reachInches.value);
    }
    if (wins.present) {
      map['wins'] = Variable<int>(wins.value);
    }
    if (losses.present) {
      map['losses'] = Variable<int>(losses.value);
    }
    if (draws.present) {
      map['draws'] = Variable<int>(draws.value);
    }
    if (punching.present) {
      map['punching'] = Variable<int>(punching.value);
    }
    if (kicking.present) {
      map['kicking'] = Variable<int>(kicking.value);
    }
    if (power.present) {
      map['power'] = Variable<int>(power.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<int>(accuracy.value);
    }
    if (defense.present) {
      map['defense'] = Variable<int>(defense.value);
    }
    if (headMovement.present) {
      map['head_movement'] = Variable<int>(headMovement.value);
    }
    if (blocking.present) {
      map['blocking'] = Variable<int>(blocking.value);
    }
    if (footwork.present) {
      map['footwork'] = Variable<int>(footwork.value);
    }
    if (takedowns.present) {
      map['takedowns'] = Variable<int>(takedowns.value);
    }
    if (takedownDefense.present) {
      map['takedown_defense'] = Variable<int>(takedownDefense.value);
    }
    if (wrestling.present) {
      map['wrestling'] = Variable<int>(wrestling.value);
    }
    if (clinchStriking.present) {
      map['clinch_striking'] = Variable<int>(clinchStriking.value);
    }
    if (clinchControl.present) {
      map['clinch_control'] = Variable<int>(clinchControl.value);
    }
    if (clinchDefense.present) {
      map['clinch_defense'] = Variable<int>(clinchDefense.value);
    }
    if (topControl.present) {
      map['top_control'] = Variable<int>(topControl.value);
    }
    if (groundAndPound.present) {
      map['ground_and_pound'] = Variable<int>(groundAndPound.value);
    }
    if (guardRetention.present) {
      map['guard_retention'] = Variable<int>(guardRetention.value);
    }
    if (sweeps.present) {
      map['sweeps'] = Variable<int>(sweeps.value);
    }
    if (scrambling.present) {
      map['scrambling'] = Variable<int>(scrambling.value);
    }
    if (submissionOffense.present) {
      map['submission_offense'] = Variable<int>(submissionOffense.value);
    }
    if (submissionDefense.present) {
      map['submission_defense'] = Variable<int>(submissionDefense.value);
    }
    if (grappling.present) {
      map['grappling'] = Variable<int>(grappling.value);
    }
    if (cardio.present) {
      map['cardio'] = Variable<int>(cardio.value);
    }
    if (durability.present) {
      map['durability'] = Variable<int>(durability.value);
    }
    if (chin.present) {
      map['chin'] = Variable<int>(chin.value);
    }
    if (bodyToughness.present) {
      map['body_toughness'] = Variable<int>(bodyToughness.value);
    }
    if (legToughness.present) {
      map['leg_toughness'] = Variable<int>(legToughness.value);
    }
    if (strength.present) {
      map['strength'] = Variable<int>(strength.value);
    }
    if (athleticism.present) {
      map['athleticism'] = Variable<int>(athleticism.value);
    }
    if (recovery.present) {
      map['recovery'] = Variable<int>(recovery.value);
    }
    if (explosiveness.present) {
      map['explosiveness'] = Variable<int>(explosiveness.value);
    }
    if (flexibility.present) {
      map['flexibility'] = Variable<int>(flexibility.value);
    }
    if (gripStrength.present) {
      map['grip_strength'] = Variable<int>(gripStrength.value);
    }
    if (fightIq.present) {
      map['fight_iq'] = Variable<int>(fightIq.value);
    }
    if (composure.present) {
      map['composure'] = Variable<int>(composure.value);
    }
    if (aggression.present) {
      map['aggression'] = Variable<int>(aggression.value);
    }
    if (discipline.present) {
      map['discipline'] = Variable<int>(discipline.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (heart.present) {
      map['heart'] = Variable<int>(heart.value);
    }
    if (adaptability.present) {
      map['adaptability'] = Variable<int>(adaptability.value);
    }
    if (killerInstinct.present) {
      map['killer_instinct'] = Variable<int>(killerInstinct.value);
    }
    if (tendStrikingFrequency.present) {
      map['tend_striking_frequency'] =
          Variable<int>(tendStrikingFrequency.value);
    }
    if (tendTakedownFrequency.present) {
      map['tend_takedown_frequency'] =
          Variable<int>(tendTakedownFrequency.value);
    }
    if (tendKickFrequency.present) {
      map['tend_kick_frequency'] = Variable<int>(tendKickFrequency.value);
    }
    if (tendClinchFrequency.present) {
      map['tend_clinch_frequency'] = Variable<int>(tendClinchFrequency.value);
    }
    if (tendSubmissionAttempts.present) {
      map['tend_submission_attempts'] =
          Variable<int>(tendSubmissionAttempts.value);
    }
    if (tendGroundAndPound.present) {
      map['tend_ground_and_pound'] = Variable<int>(tendGroundAndPound.value);
    }
    if (tendPositionControl.present) {
      map['tend_position_control'] = Variable<int>(tendPositionControl.value);
    }
    if (tendStandUpPreference.present) {
      map['tend_stand_up_preference'] =
          Variable<int>(tendStandUpPreference.value);
    }
    if (tendWallWork.present) {
      map['tend_wall_work'] = Variable<int>(tendWallWork.value);
    }
    if (tendAggression.present) {
      map['tend_aggression'] = Variable<int>(tendAggression.value);
    }
    if (tendCounterStriking.present) {
      map['tend_counter_striking'] = Variable<int>(tendCounterStriking.value);
    }
    if (tendHeadHunting.present) {
      map['tend_head_hunting'] = Variable<int>(tendHeadHunting.value);
    }
    if (tendBodyAttacks.present) {
      map['tend_body_attacks'] = Variable<int>(tendBodyAttacks.value);
    }
    if (tendLegAttacks.present) {
      map['tend_leg_attacks'] = Variable<int>(tendLegAttacks.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (potential.present) {
      map['potential'] = Variable<int>(potential.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<int>(popularity.value);
    }
    if (morale.present) {
      map['morale'] = Variable<int>(morale.value);
    }
    if (injuryStatus.present) {
      map['injury_status'] = Variable<String>(injuryStatus.value);
    }
    if (winStreak.present) {
      map['win_streak'] = Variable<int>(winStreak.value);
    }
    if (lossStreak.present) {
      map['loss_streak'] = Variable<int>(lossStreak.value);
    }
    if (eloRating.present) {
      map['elo_rating'] = Variable<int>(eloRating.value);
    }
    if (isRanked.present) {
      map['is_ranked'] = Variable<bool>(isRanked.value);
    }
    if (retired.present) {
      map['retired'] = Variable<bool>(retired.value);
    }
    if (retirementReason.present) {
      map['retirement_reason'] = Variable<String>(retirementReason.value);
    }
    if (fightOfTheNightCount.present) {
      map['fight_of_the_night_count'] =
          Variable<int>(fightOfTheNightCount.value);
    }
    if (performanceOfTheNightCount.present) {
      map['performance_of_the_night_count'] =
          Variable<int>(performanceOfTheNightCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FightersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('nationality: $nationality, ')
          ..write('weightClass: $weightClass, ')
          ..write('heightInches: $heightInches, ')
          ..write('weightLbs: $weightLbs, ')
          ..write('reachInches: $reachInches, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('draws: $draws, ')
          ..write('punching: $punching, ')
          ..write('kicking: $kicking, ')
          ..write('power: $power, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('defense: $defense, ')
          ..write('headMovement: $headMovement, ')
          ..write('blocking: $blocking, ')
          ..write('footwork: $footwork, ')
          ..write('takedowns: $takedowns, ')
          ..write('takedownDefense: $takedownDefense, ')
          ..write('wrestling: $wrestling, ')
          ..write('clinchStriking: $clinchStriking, ')
          ..write('clinchControl: $clinchControl, ')
          ..write('clinchDefense: $clinchDefense, ')
          ..write('topControl: $topControl, ')
          ..write('groundAndPound: $groundAndPound, ')
          ..write('guardRetention: $guardRetention, ')
          ..write('sweeps: $sweeps, ')
          ..write('scrambling: $scrambling, ')
          ..write('submissionOffense: $submissionOffense, ')
          ..write('submissionDefense: $submissionDefense, ')
          ..write('grappling: $grappling, ')
          ..write('cardio: $cardio, ')
          ..write('durability: $durability, ')
          ..write('chin: $chin, ')
          ..write('bodyToughness: $bodyToughness, ')
          ..write('legToughness: $legToughness, ')
          ..write('strength: $strength, ')
          ..write('athleticism: $athleticism, ')
          ..write('recovery: $recovery, ')
          ..write('explosiveness: $explosiveness, ')
          ..write('flexibility: $flexibility, ')
          ..write('gripStrength: $gripStrength, ')
          ..write('fightIq: $fightIq, ')
          ..write('composure: $composure, ')
          ..write('aggression: $aggression, ')
          ..write('discipline: $discipline, ')
          ..write('confidence: $confidence, ')
          ..write('heart: $heart, ')
          ..write('adaptability: $adaptability, ')
          ..write('killerInstinct: $killerInstinct, ')
          ..write('tendStrikingFrequency: $tendStrikingFrequency, ')
          ..write('tendTakedownFrequency: $tendTakedownFrequency, ')
          ..write('tendKickFrequency: $tendKickFrequency, ')
          ..write('tendClinchFrequency: $tendClinchFrequency, ')
          ..write('tendSubmissionAttempts: $tendSubmissionAttempts, ')
          ..write('tendGroundAndPound: $tendGroundAndPound, ')
          ..write('tendPositionControl: $tendPositionControl, ')
          ..write('tendStandUpPreference: $tendStandUpPreference, ')
          ..write('tendWallWork: $tendWallWork, ')
          ..write('tendAggression: $tendAggression, ')
          ..write('tendCounterStriking: $tendCounterStriking, ')
          ..write('tendHeadHunting: $tendHeadHunting, ')
          ..write('tendBodyAttacks: $tendBodyAttacks, ')
          ..write('tendLegAttacks: $tendLegAttacks, ')
          ..write('style: $style, ')
          ..write('potential: $potential, ')
          ..write('popularity: $popularity, ')
          ..write('morale: $morale, ')
          ..write('injuryStatus: $injuryStatus, ')
          ..write('winStreak: $winStreak, ')
          ..write('lossStreak: $lossStreak, ')
          ..write('eloRating: $eloRating, ')
          ..write('isRanked: $isRanked, ')
          ..write('retired: $retired, ')
          ..write('retirementReason: $retirementReason, ')
          ..write('fightOfTheNightCount: $fightOfTheNightCount, ')
          ..write('performanceOfTheNightCount: $performanceOfTheNightCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, ContractRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fighterIdMeta =
      const VerificationMeta('fighterId');
  @override
  late final GeneratedColumn<String> fighterId = GeneratedColumn<String>(
      'fighter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fightsRemainingMeta =
      const VerificationMeta('fightsRemaining');
  @override
  late final GeneratedColumn<int> fightsRemaining = GeneratedColumn<int>(
      'fights_remaining', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payPerFightMeta =
      const VerificationMeta('payPerFight');
  @override
  late final GeneratedColumn<int> payPerFight = GeneratedColumn<int>(
      'pay_per_fight', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exclusiveMeta =
      const VerificationMeta('exclusive');
  @override
  late final GeneratedColumn<bool> exclusive = GeneratedColumn<bool>(
      'exclusive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("exclusive" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _signedOnMeta =
      const VerificationMeta('signedOn');
  @override
  late final GeneratedColumn<DateTime> signedOn = GeneratedColumn<DateTime>(
      'signed_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fighterId, fightsRemaining, payPerFight, exclusive, signedOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(Insertable<ContractRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fighter_id')) {
      context.handle(_fighterIdMeta,
          fighterId.isAcceptableOrUnknown(data['fighter_id']!, _fighterIdMeta));
    } else if (isInserting) {
      context.missing(_fighterIdMeta);
    }
    if (data.containsKey('fights_remaining')) {
      context.handle(
          _fightsRemainingMeta,
          fightsRemaining.isAcceptableOrUnknown(
              data['fights_remaining']!, _fightsRemainingMeta));
    } else if (isInserting) {
      context.missing(_fightsRemainingMeta);
    }
    if (data.containsKey('pay_per_fight')) {
      context.handle(
          _payPerFightMeta,
          payPerFight.isAcceptableOrUnknown(
              data['pay_per_fight']!, _payPerFightMeta));
    } else if (isInserting) {
      context.missing(_payPerFightMeta);
    }
    if (data.containsKey('exclusive')) {
      context.handle(_exclusiveMeta,
          exclusive.isAcceptableOrUnknown(data['exclusive']!, _exclusiveMeta));
    }
    if (data.containsKey('signed_on')) {
      context.handle(_signedOnMeta,
          signedOn.isAcceptableOrUnknown(data['signed_on']!, _signedOnMeta));
    } else if (isInserting) {
      context.missing(_signedOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContractRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fighterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fighter_id'])!,
      fightsRemaining: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fights_remaining'])!,
      payPerFight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pay_per_fight'])!,
      exclusive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}exclusive'])!,
      signedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}signed_on'])!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }
}

class ContractRow extends DataClass implements Insertable<ContractRow> {
  final String id;
  final String fighterId;
  final int fightsRemaining;
  final int payPerFight;
  final bool exclusive;
  final DateTime signedOn;
  const ContractRow(
      {required this.id,
      required this.fighterId,
      required this.fightsRemaining,
      required this.payPerFight,
      required this.exclusive,
      required this.signedOn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fighter_id'] = Variable<String>(fighterId);
    map['fights_remaining'] = Variable<int>(fightsRemaining);
    map['pay_per_fight'] = Variable<int>(payPerFight);
    map['exclusive'] = Variable<bool>(exclusive);
    map['signed_on'] = Variable<DateTime>(signedOn);
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(id),
      fighterId: Value(fighterId),
      fightsRemaining: Value(fightsRemaining),
      payPerFight: Value(payPerFight),
      exclusive: Value(exclusive),
      signedOn: Value(signedOn),
    );
  }

  factory ContractRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractRow(
      id: serializer.fromJson<String>(json['id']),
      fighterId: serializer.fromJson<String>(json['fighterId']),
      fightsRemaining: serializer.fromJson<int>(json['fightsRemaining']),
      payPerFight: serializer.fromJson<int>(json['payPerFight']),
      exclusive: serializer.fromJson<bool>(json['exclusive']),
      signedOn: serializer.fromJson<DateTime>(json['signedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fighterId': serializer.toJson<String>(fighterId),
      'fightsRemaining': serializer.toJson<int>(fightsRemaining),
      'payPerFight': serializer.toJson<int>(payPerFight),
      'exclusive': serializer.toJson<bool>(exclusive),
      'signedOn': serializer.toJson<DateTime>(signedOn),
    };
  }

  ContractRow copyWith(
          {String? id,
          String? fighterId,
          int? fightsRemaining,
          int? payPerFight,
          bool? exclusive,
          DateTime? signedOn}) =>
      ContractRow(
        id: id ?? this.id,
        fighterId: fighterId ?? this.fighterId,
        fightsRemaining: fightsRemaining ?? this.fightsRemaining,
        payPerFight: payPerFight ?? this.payPerFight,
        exclusive: exclusive ?? this.exclusive,
        signedOn: signedOn ?? this.signedOn,
      );
  ContractRow copyWithCompanion(ContractsCompanion data) {
    return ContractRow(
      id: data.id.present ? data.id.value : this.id,
      fighterId: data.fighterId.present ? data.fighterId.value : this.fighterId,
      fightsRemaining: data.fightsRemaining.present
          ? data.fightsRemaining.value
          : this.fightsRemaining,
      payPerFight:
          data.payPerFight.present ? data.payPerFight.value : this.payPerFight,
      exclusive: data.exclusive.present ? data.exclusive.value : this.exclusive,
      signedOn: data.signedOn.present ? data.signedOn.value : this.signedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContractRow(')
          ..write('id: $id, ')
          ..write('fighterId: $fighterId, ')
          ..write('fightsRemaining: $fightsRemaining, ')
          ..write('payPerFight: $payPerFight, ')
          ..write('exclusive: $exclusive, ')
          ..write('signedOn: $signedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, fighterId, fightsRemaining, payPerFight, exclusive, signedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractRow &&
          other.id == this.id &&
          other.fighterId == this.fighterId &&
          other.fightsRemaining == this.fightsRemaining &&
          other.payPerFight == this.payPerFight &&
          other.exclusive == this.exclusive &&
          other.signedOn == this.signedOn);
}

class ContractsCompanion extends UpdateCompanion<ContractRow> {
  final Value<String> id;
  final Value<String> fighterId;
  final Value<int> fightsRemaining;
  final Value<int> payPerFight;
  final Value<bool> exclusive;
  final Value<DateTime> signedOn;
  final Value<int> rowid;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.fighterId = const Value.absent(),
    this.fightsRemaining = const Value.absent(),
    this.payPerFight = const Value.absent(),
    this.exclusive = const Value.absent(),
    this.signedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractsCompanion.insert({
    required String id,
    required String fighterId,
    required int fightsRemaining,
    required int payPerFight,
    this.exclusive = const Value.absent(),
    required DateTime signedOn,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fighterId = Value(fighterId),
        fightsRemaining = Value(fightsRemaining),
        payPerFight = Value(payPerFight),
        signedOn = Value(signedOn);
  static Insertable<ContractRow> custom({
    Expression<String>? id,
    Expression<String>? fighterId,
    Expression<int>? fightsRemaining,
    Expression<int>? payPerFight,
    Expression<bool>? exclusive,
    Expression<DateTime>? signedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fighterId != null) 'fighter_id': fighterId,
      if (fightsRemaining != null) 'fights_remaining': fightsRemaining,
      if (payPerFight != null) 'pay_per_fight': payPerFight,
      if (exclusive != null) 'exclusive': exclusive,
      if (signedOn != null) 'signed_on': signedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractsCompanion copyWith(
      {Value<String>? id,
      Value<String>? fighterId,
      Value<int>? fightsRemaining,
      Value<int>? payPerFight,
      Value<bool>? exclusive,
      Value<DateTime>? signedOn,
      Value<int>? rowid}) {
    return ContractsCompanion(
      id: id ?? this.id,
      fighterId: fighterId ?? this.fighterId,
      fightsRemaining: fightsRemaining ?? this.fightsRemaining,
      payPerFight: payPerFight ?? this.payPerFight,
      exclusive: exclusive ?? this.exclusive,
      signedOn: signedOn ?? this.signedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fighterId.present) {
      map['fighter_id'] = Variable<String>(fighterId.value);
    }
    if (fightsRemaining.present) {
      map['fights_remaining'] = Variable<int>(fightsRemaining.value);
    }
    if (payPerFight.present) {
      map['pay_per_fight'] = Variable<int>(payPerFight.value);
    }
    if (exclusive.present) {
      map['exclusive'] = Variable<bool>(exclusive.value);
    }
    if (signedOn.present) {
      map['signed_on'] = Variable<DateTime>(signedOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('fighterId: $fighterId, ')
          ..write('fightsRemaining: $fightsRemaining, ')
          ..write('payPerFight: $payPerFight, ')
          ..write('exclusive: $exclusive, ')
          ..write('signedOn: $signedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, OrganizationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reputationTierMeta =
      const VerificationMeta('reputationTier');
  @override
  late final GeneratedColumn<String> reputationTier = GeneratedColumn<String>(
      'reputation_tier', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('regional'));
  static const VerificationMeta _reputationPointsMeta =
      const VerificationMeta('reputationPoints');
  @override
  late final GeneratedColumn<int> reputationPoints = GeneratedColumn<int>(
      'reputation_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cashBalanceMeta =
      const VerificationMeta('cashBalance');
  @override
  late final GeneratedColumn<int> cashBalance = GeneratedColumn<int>(
      'cash_balance', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fanbaseSizeMeta =
      const VerificationMeta('fanbaseSize');
  @override
  late final GeneratedColumn<int> fanbaseSize = GeneratedColumn<int>(
      'fanbase_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _homeRegionMeta =
      const VerificationMeta('homeRegion');
  @override
  late final GeneratedColumn<String> homeRegion = GeneratedColumn<String>(
      'home_region', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promotionBudgetMeta =
      const VerificationMeta('promotionBudget');
  @override
  late final GeneratedColumn<int> promotionBudget = GeneratedColumn<int>(
      'promotion_budget', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastTalentRefreshMeta =
      const VerificationMeta('lastTalentRefresh');
  @override
  late final GeneratedColumn<DateTime> lastTalentRefresh =
      GeneratedColumn<DateTime>('last_talent_refresh', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        reputationTier,
        reputationPoints,
        cashBalance,
        fanbaseSize,
        homeRegion,
        promotionBudget,
        lastTalentRefresh
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(Insertable<OrganizationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reputation_tier')) {
      context.handle(
          _reputationTierMeta,
          reputationTier.isAcceptableOrUnknown(
              data['reputation_tier']!, _reputationTierMeta));
    }
    if (data.containsKey('reputation_points')) {
      context.handle(
          _reputationPointsMeta,
          reputationPoints.isAcceptableOrUnknown(
              data['reputation_points']!, _reputationPointsMeta));
    }
    if (data.containsKey('cash_balance')) {
      context.handle(
          _cashBalanceMeta,
          cashBalance.isAcceptableOrUnknown(
              data['cash_balance']!, _cashBalanceMeta));
    } else if (isInserting) {
      context.missing(_cashBalanceMeta);
    }
    if (data.containsKey('fanbase_size')) {
      context.handle(
          _fanbaseSizeMeta,
          fanbaseSize.isAcceptableOrUnknown(
              data['fanbase_size']!, _fanbaseSizeMeta));
    }
    if (data.containsKey('home_region')) {
      context.handle(
          _homeRegionMeta,
          homeRegion.isAcceptableOrUnknown(
              data['home_region']!, _homeRegionMeta));
    } else if (isInserting) {
      context.missing(_homeRegionMeta);
    }
    if (data.containsKey('promotion_budget')) {
      context.handle(
          _promotionBudgetMeta,
          promotionBudget.isAcceptableOrUnknown(
              data['promotion_budget']!, _promotionBudgetMeta));
    }
    if (data.containsKey('last_talent_refresh')) {
      context.handle(
          _lastTalentRefreshMeta,
          lastTalentRefresh.isAcceptableOrUnknown(
              data['last_talent_refresh']!, _lastTalentRefreshMeta));
    } else if (isInserting) {
      context.missing(_lastTalentRefreshMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrganizationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrganizationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      reputationTier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reputation_tier'])!,
      reputationPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reputation_points'])!,
      cashBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cash_balance'])!,
      fanbaseSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fanbase_size'])!,
      homeRegion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}home_region'])!,
      promotionBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}promotion_budget'])!,
      lastTalentRefresh: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_talent_refresh'])!,
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class OrganizationRow extends DataClass implements Insertable<OrganizationRow> {
  final String id;
  final String name;
  final String reputationTier;
  final int reputationPoints;
  final int cashBalance;
  final int fanbaseSize;
  final String homeRegion;
  final int promotionBudget;
  final DateTime lastTalentRefresh;
  const OrganizationRow(
      {required this.id,
      required this.name,
      required this.reputationTier,
      required this.reputationPoints,
      required this.cashBalance,
      required this.fanbaseSize,
      required this.homeRegion,
      required this.promotionBudget,
      required this.lastTalentRefresh});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['reputation_tier'] = Variable<String>(reputationTier);
    map['reputation_points'] = Variable<int>(reputationPoints);
    map['cash_balance'] = Variable<int>(cashBalance);
    map['fanbase_size'] = Variable<int>(fanbaseSize);
    map['home_region'] = Variable<String>(homeRegion);
    map['promotion_budget'] = Variable<int>(promotionBudget);
    map['last_talent_refresh'] = Variable<DateTime>(lastTalentRefresh);
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      name: Value(name),
      reputationTier: Value(reputationTier),
      reputationPoints: Value(reputationPoints),
      cashBalance: Value(cashBalance),
      fanbaseSize: Value(fanbaseSize),
      homeRegion: Value(homeRegion),
      promotionBudget: Value(promotionBudget),
      lastTalentRefresh: Value(lastTalentRefresh),
    );
  }

  factory OrganizationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrganizationRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      reputationTier: serializer.fromJson<String>(json['reputationTier']),
      reputationPoints: serializer.fromJson<int>(json['reputationPoints']),
      cashBalance: serializer.fromJson<int>(json['cashBalance']),
      fanbaseSize: serializer.fromJson<int>(json['fanbaseSize']),
      homeRegion: serializer.fromJson<String>(json['homeRegion']),
      promotionBudget: serializer.fromJson<int>(json['promotionBudget']),
      lastTalentRefresh:
          serializer.fromJson<DateTime>(json['lastTalentRefresh']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'reputationTier': serializer.toJson<String>(reputationTier),
      'reputationPoints': serializer.toJson<int>(reputationPoints),
      'cashBalance': serializer.toJson<int>(cashBalance),
      'fanbaseSize': serializer.toJson<int>(fanbaseSize),
      'homeRegion': serializer.toJson<String>(homeRegion),
      'promotionBudget': serializer.toJson<int>(promotionBudget),
      'lastTalentRefresh': serializer.toJson<DateTime>(lastTalentRefresh),
    };
  }

  OrganizationRow copyWith(
          {String? id,
          String? name,
          String? reputationTier,
          int? reputationPoints,
          int? cashBalance,
          int? fanbaseSize,
          String? homeRegion,
          int? promotionBudget,
          DateTime? lastTalentRefresh}) =>
      OrganizationRow(
        id: id ?? this.id,
        name: name ?? this.name,
        reputationTier: reputationTier ?? this.reputationTier,
        reputationPoints: reputationPoints ?? this.reputationPoints,
        cashBalance: cashBalance ?? this.cashBalance,
        fanbaseSize: fanbaseSize ?? this.fanbaseSize,
        homeRegion: homeRegion ?? this.homeRegion,
        promotionBudget: promotionBudget ?? this.promotionBudget,
        lastTalentRefresh: lastTalentRefresh ?? this.lastTalentRefresh,
      );
  OrganizationRow copyWithCompanion(OrganizationsCompanion data) {
    return OrganizationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      reputationTier: data.reputationTier.present
          ? data.reputationTier.value
          : this.reputationTier,
      reputationPoints: data.reputationPoints.present
          ? data.reputationPoints.value
          : this.reputationPoints,
      cashBalance:
          data.cashBalance.present ? data.cashBalance.value : this.cashBalance,
      fanbaseSize:
          data.fanbaseSize.present ? data.fanbaseSize.value : this.fanbaseSize,
      homeRegion:
          data.homeRegion.present ? data.homeRegion.value : this.homeRegion,
      promotionBudget: data.promotionBudget.present
          ? data.promotionBudget.value
          : this.promotionBudget,
      lastTalentRefresh: data.lastTalentRefresh.present
          ? data.lastTalentRefresh.value
          : this.lastTalentRefresh,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reputationTier: $reputationTier, ')
          ..write('reputationPoints: $reputationPoints, ')
          ..write('cashBalance: $cashBalance, ')
          ..write('fanbaseSize: $fanbaseSize, ')
          ..write('homeRegion: $homeRegion, ')
          ..write('promotionBudget: $promotionBudget, ')
          ..write('lastTalentRefresh: $lastTalentRefresh')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, reputationTier, reputationPoints,
      cashBalance, fanbaseSize, homeRegion, promotionBudget, lastTalentRefresh);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.reputationTier == this.reputationTier &&
          other.reputationPoints == this.reputationPoints &&
          other.cashBalance == this.cashBalance &&
          other.fanbaseSize == this.fanbaseSize &&
          other.homeRegion == this.homeRegion &&
          other.promotionBudget == this.promotionBudget &&
          other.lastTalentRefresh == this.lastTalentRefresh);
}

class OrganizationsCompanion extends UpdateCompanion<OrganizationRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> reputationTier;
  final Value<int> reputationPoints;
  final Value<int> cashBalance;
  final Value<int> fanbaseSize;
  final Value<String> homeRegion;
  final Value<int> promotionBudget;
  final Value<DateTime> lastTalentRefresh;
  final Value<int> rowid;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.reputationTier = const Value.absent(),
    this.reputationPoints = const Value.absent(),
    this.cashBalance = const Value.absent(),
    this.fanbaseSize = const Value.absent(),
    this.homeRegion = const Value.absent(),
    this.promotionBudget = const Value.absent(),
    this.lastTalentRefresh = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    required String id,
    required String name,
    this.reputationTier = const Value.absent(),
    this.reputationPoints = const Value.absent(),
    required int cashBalance,
    this.fanbaseSize = const Value.absent(),
    required String homeRegion,
    this.promotionBudget = const Value.absent(),
    required DateTime lastTalentRefresh,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        cashBalance = Value(cashBalance),
        homeRegion = Value(homeRegion),
        lastTalentRefresh = Value(lastTalentRefresh);
  static Insertable<OrganizationRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? reputationTier,
    Expression<int>? reputationPoints,
    Expression<int>? cashBalance,
    Expression<int>? fanbaseSize,
    Expression<String>? homeRegion,
    Expression<int>? promotionBudget,
    Expression<DateTime>? lastTalentRefresh,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (reputationTier != null) 'reputation_tier': reputationTier,
      if (reputationPoints != null) 'reputation_points': reputationPoints,
      if (cashBalance != null) 'cash_balance': cashBalance,
      if (fanbaseSize != null) 'fanbase_size': fanbaseSize,
      if (homeRegion != null) 'home_region': homeRegion,
      if (promotionBudget != null) 'promotion_budget': promotionBudget,
      if (lastTalentRefresh != null) 'last_talent_refresh': lastTalentRefresh,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrganizationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? reputationTier,
      Value<int>? reputationPoints,
      Value<int>? cashBalance,
      Value<int>? fanbaseSize,
      Value<String>? homeRegion,
      Value<int>? promotionBudget,
      Value<DateTime>? lastTalentRefresh,
      Value<int>? rowid}) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      reputationTier: reputationTier ?? this.reputationTier,
      reputationPoints: reputationPoints ?? this.reputationPoints,
      cashBalance: cashBalance ?? this.cashBalance,
      fanbaseSize: fanbaseSize ?? this.fanbaseSize,
      homeRegion: homeRegion ?? this.homeRegion,
      promotionBudget: promotionBudget ?? this.promotionBudget,
      lastTalentRefresh: lastTalentRefresh ?? this.lastTalentRefresh,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reputationTier.present) {
      map['reputation_tier'] = Variable<String>(reputationTier.value);
    }
    if (reputationPoints.present) {
      map['reputation_points'] = Variable<int>(reputationPoints.value);
    }
    if (cashBalance.present) {
      map['cash_balance'] = Variable<int>(cashBalance.value);
    }
    if (fanbaseSize.present) {
      map['fanbase_size'] = Variable<int>(fanbaseSize.value);
    }
    if (homeRegion.present) {
      map['home_region'] = Variable<String>(homeRegion.value);
    }
    if (promotionBudget.present) {
      map['promotion_budget'] = Variable<int>(promotionBudget.value);
    }
    if (lastTalentRefresh.present) {
      map['last_talent_refresh'] = Variable<DateTime>(lastTalentRefresh.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reputationTier: $reputationTier, ')
          ..write('reputationPoints: $reputationPoints, ')
          ..write('cashBalance: $cashBalance, ')
          ..write('fanbaseSize: $fanbaseSize, ')
          ..write('homeRegion: $homeRegion, ')
          ..write('promotionBudget: $promotionBudget, ')
          ..write('lastTalentRefresh: $lastTalentRefresh, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ticketPriceMeta =
      const VerificationMeta('ticketPrice');
  @override
  late final GeneratedColumn<int> ticketPrice = GeneratedColumn<int>(
      'ticket_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scheduled'));
  static const VerificationMeta _promotionBudgetSpentMeta =
      const VerificationMeta('promotionBudgetSpent');
  @override
  late final GeneratedColumn<int> promotionBudgetSpent = GeneratedColumn<int>(
      'promotion_budget_spent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _attendanceMeta =
      const VerificationMeta('attendance');
  @override
  late final GeneratedColumn<int> attendance = GeneratedColumn<int>(
      'attendance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ppvBuysMeta =
      const VerificationMeta('ppvBuys');
  @override
  late final GeneratedColumn<int> ppvBuys = GeneratedColumn<int>(
      'ppv_buys', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _revenueMeta =
      const VerificationMeta('revenue');
  @override
  late final GeneratedColumn<int> revenue = GeneratedColumn<int>(
      'revenue', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _expensesMeta =
      const VerificationMeta('expenses');
  @override
  late final GeneratedColumn<int> expenses = GeneratedColumn<int>(
      'expenses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reputationChangeMeta =
      const VerificationMeta('reputationChange');
  @override
  late final GeneratedColumn<int> reputationChange = GeneratedColumn<int>(
      'reputation_change', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fightOfTheNightFightIdMeta =
      const VerificationMeta('fightOfTheNightFightId');
  @override
  late final GeneratedColumn<String> fightOfTheNightFightId =
      GeneratedColumn<String>('fight_of_the_night_fight_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _performanceOfTheNightFighterIdMeta =
      const VerificationMeta('performanceOfTheNightFighterId');
  @override
  late final GeneratedColumn<String> performanceOfTheNightFighterId =
      GeneratedColumn<String>(
          'performance_of_the_night_fighter_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        date,
        venue,
        ticketPrice,
        status,
        promotionBudgetSpent,
        attendance,
        ppvBuys,
        revenue,
        expenses,
        reputationChange,
        fightOfTheNightFightId,
        performanceOfTheNightFighterId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<EventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
          _venueMeta, venue.isAcceptableOrUnknown(data['venue']!, _venueMeta));
    } else if (isInserting) {
      context.missing(_venueMeta);
    }
    if (data.containsKey('ticket_price')) {
      context.handle(
          _ticketPriceMeta,
          ticketPrice.isAcceptableOrUnknown(
              data['ticket_price']!, _ticketPriceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('promotion_budget_spent')) {
      context.handle(
          _promotionBudgetSpentMeta,
          promotionBudgetSpent.isAcceptableOrUnknown(
              data['promotion_budget_spent']!, _promotionBudgetSpentMeta));
    }
    if (data.containsKey('attendance')) {
      context.handle(
          _attendanceMeta,
          attendance.isAcceptableOrUnknown(
              data['attendance']!, _attendanceMeta));
    }
    if (data.containsKey('ppv_buys')) {
      context.handle(_ppvBuysMeta,
          ppvBuys.isAcceptableOrUnknown(data['ppv_buys']!, _ppvBuysMeta));
    }
    if (data.containsKey('revenue')) {
      context.handle(_revenueMeta,
          revenue.isAcceptableOrUnknown(data['revenue']!, _revenueMeta));
    }
    if (data.containsKey('expenses')) {
      context.handle(_expensesMeta,
          expenses.isAcceptableOrUnknown(data['expenses']!, _expensesMeta));
    }
    if (data.containsKey('reputation_change')) {
      context.handle(
          _reputationChangeMeta,
          reputationChange.isAcceptableOrUnknown(
              data['reputation_change']!, _reputationChangeMeta));
    }
    if (data.containsKey('fight_of_the_night_fight_id')) {
      context.handle(
          _fightOfTheNightFightIdMeta,
          fightOfTheNightFightId.isAcceptableOrUnknown(
              data['fight_of_the_night_fight_id']!,
              _fightOfTheNightFightIdMeta));
    }
    if (data.containsKey('performance_of_the_night_fighter_id')) {
      context.handle(
          _performanceOfTheNightFighterIdMeta,
          performanceOfTheNightFighterId.isAcceptableOrUnknown(
              data['performance_of_the_night_fighter_id']!,
              _performanceOfTheNightFighterIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      venue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue'])!,
      ticketPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_price'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      promotionBudgetSpent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}promotion_budget_spent'])!,
      attendance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attendance'])!,
      ppvBuys: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ppv_buys'])!,
      revenue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revenue'])!,
      expenses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expenses'])!,
      reputationChange: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reputation_change'])!,
      fightOfTheNightFightId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fight_of_the_night_fight_id']),
      performanceOfTheNightFighterId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}performance_of_the_night_fighter_id']),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String name;
  final DateTime date;
  final String venue;
  final int ticketPrice;
  final String status;
  final int promotionBudgetSpent;
  final int attendance;
  final int ppvBuys;
  final int revenue;
  final int expenses;
  final int reputationChange;
  final String? fightOfTheNightFightId;
  final String? performanceOfTheNightFighterId;
  const EventRow(
      {required this.id,
      required this.name,
      required this.date,
      required this.venue,
      required this.ticketPrice,
      required this.status,
      required this.promotionBudgetSpent,
      required this.attendance,
      required this.ppvBuys,
      required this.revenue,
      required this.expenses,
      required this.reputationChange,
      this.fightOfTheNightFightId,
      this.performanceOfTheNightFighterId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['venue'] = Variable<String>(venue);
    map['ticket_price'] = Variable<int>(ticketPrice);
    map['status'] = Variable<String>(status);
    map['promotion_budget_spent'] = Variable<int>(promotionBudgetSpent);
    map['attendance'] = Variable<int>(attendance);
    map['ppv_buys'] = Variable<int>(ppvBuys);
    map['revenue'] = Variable<int>(revenue);
    map['expenses'] = Variable<int>(expenses);
    map['reputation_change'] = Variable<int>(reputationChange);
    if (!nullToAbsent || fightOfTheNightFightId != null) {
      map['fight_of_the_night_fight_id'] =
          Variable<String>(fightOfTheNightFightId);
    }
    if (!nullToAbsent || performanceOfTheNightFighterId != null) {
      map['performance_of_the_night_fighter_id'] =
          Variable<String>(performanceOfTheNightFighterId);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      name: Value(name),
      date: Value(date),
      venue: Value(venue),
      ticketPrice: Value(ticketPrice),
      status: Value(status),
      promotionBudgetSpent: Value(promotionBudgetSpent),
      attendance: Value(attendance),
      ppvBuys: Value(ppvBuys),
      revenue: Value(revenue),
      expenses: Value(expenses),
      reputationChange: Value(reputationChange),
      fightOfTheNightFightId: fightOfTheNightFightId == null && nullToAbsent
          ? const Value.absent()
          : Value(fightOfTheNightFightId),
      performanceOfTheNightFighterId:
          performanceOfTheNightFighterId == null && nullToAbsent
              ? const Value.absent()
              : Value(performanceOfTheNightFighterId),
    );
  }

  factory EventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      venue: serializer.fromJson<String>(json['venue']),
      ticketPrice: serializer.fromJson<int>(json['ticketPrice']),
      status: serializer.fromJson<String>(json['status']),
      promotionBudgetSpent:
          serializer.fromJson<int>(json['promotionBudgetSpent']),
      attendance: serializer.fromJson<int>(json['attendance']),
      ppvBuys: serializer.fromJson<int>(json['ppvBuys']),
      revenue: serializer.fromJson<int>(json['revenue']),
      expenses: serializer.fromJson<int>(json['expenses']),
      reputationChange: serializer.fromJson<int>(json['reputationChange']),
      fightOfTheNightFightId:
          serializer.fromJson<String?>(json['fightOfTheNightFightId']),
      performanceOfTheNightFighterId:
          serializer.fromJson<String?>(json['performanceOfTheNightFighterId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'venue': serializer.toJson<String>(venue),
      'ticketPrice': serializer.toJson<int>(ticketPrice),
      'status': serializer.toJson<String>(status),
      'promotionBudgetSpent': serializer.toJson<int>(promotionBudgetSpent),
      'attendance': serializer.toJson<int>(attendance),
      'ppvBuys': serializer.toJson<int>(ppvBuys),
      'revenue': serializer.toJson<int>(revenue),
      'expenses': serializer.toJson<int>(expenses),
      'reputationChange': serializer.toJson<int>(reputationChange),
      'fightOfTheNightFightId':
          serializer.toJson<String?>(fightOfTheNightFightId),
      'performanceOfTheNightFighterId':
          serializer.toJson<String?>(performanceOfTheNightFighterId),
    };
  }

  EventRow copyWith(
          {String? id,
          String? name,
          DateTime? date,
          String? venue,
          int? ticketPrice,
          String? status,
          int? promotionBudgetSpent,
          int? attendance,
          int? ppvBuys,
          int? revenue,
          int? expenses,
          int? reputationChange,
          Value<String?> fightOfTheNightFightId = const Value.absent(),
          Value<String?> performanceOfTheNightFighterId =
              const Value.absent()}) =>
      EventRow(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        venue: venue ?? this.venue,
        ticketPrice: ticketPrice ?? this.ticketPrice,
        status: status ?? this.status,
        promotionBudgetSpent: promotionBudgetSpent ?? this.promotionBudgetSpent,
        attendance: attendance ?? this.attendance,
        ppvBuys: ppvBuys ?? this.ppvBuys,
        revenue: revenue ?? this.revenue,
        expenses: expenses ?? this.expenses,
        reputationChange: reputationChange ?? this.reputationChange,
        fightOfTheNightFightId: fightOfTheNightFightId.present
            ? fightOfTheNightFightId.value
            : this.fightOfTheNightFightId,
        performanceOfTheNightFighterId: performanceOfTheNightFighterId.present
            ? performanceOfTheNightFighterId.value
            : this.performanceOfTheNightFighterId,
      );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      venue: data.venue.present ? data.venue.value : this.venue,
      ticketPrice:
          data.ticketPrice.present ? data.ticketPrice.value : this.ticketPrice,
      status: data.status.present ? data.status.value : this.status,
      promotionBudgetSpent: data.promotionBudgetSpent.present
          ? data.promotionBudgetSpent.value
          : this.promotionBudgetSpent,
      attendance:
          data.attendance.present ? data.attendance.value : this.attendance,
      ppvBuys: data.ppvBuys.present ? data.ppvBuys.value : this.ppvBuys,
      revenue: data.revenue.present ? data.revenue.value : this.revenue,
      expenses: data.expenses.present ? data.expenses.value : this.expenses,
      reputationChange: data.reputationChange.present
          ? data.reputationChange.value
          : this.reputationChange,
      fightOfTheNightFightId: data.fightOfTheNightFightId.present
          ? data.fightOfTheNightFightId.value
          : this.fightOfTheNightFightId,
      performanceOfTheNightFighterId:
          data.performanceOfTheNightFighterId.present
              ? data.performanceOfTheNightFighterId.value
              : this.performanceOfTheNightFighterId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('venue: $venue, ')
          ..write('ticketPrice: $ticketPrice, ')
          ..write('status: $status, ')
          ..write('promotionBudgetSpent: $promotionBudgetSpent, ')
          ..write('attendance: $attendance, ')
          ..write('ppvBuys: $ppvBuys, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('reputationChange: $reputationChange, ')
          ..write('fightOfTheNightFightId: $fightOfTheNightFightId, ')
          ..write(
              'performanceOfTheNightFighterId: $performanceOfTheNightFighterId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      date,
      venue,
      ticketPrice,
      status,
      promotionBudgetSpent,
      attendance,
      ppvBuys,
      revenue,
      expenses,
      reputationChange,
      fightOfTheNightFightId,
      performanceOfTheNightFighterId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.date == this.date &&
          other.venue == this.venue &&
          other.ticketPrice == this.ticketPrice &&
          other.status == this.status &&
          other.promotionBudgetSpent == this.promotionBudgetSpent &&
          other.attendance == this.attendance &&
          other.ppvBuys == this.ppvBuys &&
          other.revenue == this.revenue &&
          other.expenses == this.expenses &&
          other.reputationChange == this.reputationChange &&
          other.fightOfTheNightFightId == this.fightOfTheNightFightId &&
          other.performanceOfTheNightFighterId ==
              this.performanceOfTheNightFighterId);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<String> venue;
  final Value<int> ticketPrice;
  final Value<String> status;
  final Value<int> promotionBudgetSpent;
  final Value<int> attendance;
  final Value<int> ppvBuys;
  final Value<int> revenue;
  final Value<int> expenses;
  final Value<int> reputationChange;
  final Value<String?> fightOfTheNightFightId;
  final Value<String?> performanceOfTheNightFighterId;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.venue = const Value.absent(),
    this.ticketPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.promotionBudgetSpent = const Value.absent(),
    this.attendance = const Value.absent(),
    this.ppvBuys = const Value.absent(),
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.reputationChange = const Value.absent(),
    this.fightOfTheNightFightId = const Value.absent(),
    this.performanceOfTheNightFighterId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String name,
    required DateTime date,
    required String venue,
    this.ticketPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.promotionBudgetSpent = const Value.absent(),
    this.attendance = const Value.absent(),
    this.ppvBuys = const Value.absent(),
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.reputationChange = const Value.absent(),
    this.fightOfTheNightFightId = const Value.absent(),
    this.performanceOfTheNightFighterId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        date = Value(date),
        venue = Value(venue);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? venue,
    Expression<int>? ticketPrice,
    Expression<String>? status,
    Expression<int>? promotionBudgetSpent,
    Expression<int>? attendance,
    Expression<int>? ppvBuys,
    Expression<int>? revenue,
    Expression<int>? expenses,
    Expression<int>? reputationChange,
    Expression<String>? fightOfTheNightFightId,
    Expression<String>? performanceOfTheNightFighterId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (venue != null) 'venue': venue,
      if (ticketPrice != null) 'ticket_price': ticketPrice,
      if (status != null) 'status': status,
      if (promotionBudgetSpent != null)
        'promotion_budget_spent': promotionBudgetSpent,
      if (attendance != null) 'attendance': attendance,
      if (ppvBuys != null) 'ppv_buys': ppvBuys,
      if (revenue != null) 'revenue': revenue,
      if (expenses != null) 'expenses': expenses,
      if (reputationChange != null) 'reputation_change': reputationChange,
      if (fightOfTheNightFightId != null)
        'fight_of_the_night_fight_id': fightOfTheNightFightId,
      if (performanceOfTheNightFighterId != null)
        'performance_of_the_night_fighter_id': performanceOfTheNightFighterId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? date,
      Value<String>? venue,
      Value<int>? ticketPrice,
      Value<String>? status,
      Value<int>? promotionBudgetSpent,
      Value<int>? attendance,
      Value<int>? ppvBuys,
      Value<int>? revenue,
      Value<int>? expenses,
      Value<int>? reputationChange,
      Value<String?>? fightOfTheNightFightId,
      Value<String?>? performanceOfTheNightFighterId,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      status: status ?? this.status,
      promotionBudgetSpent: promotionBudgetSpent ?? this.promotionBudgetSpent,
      attendance: attendance ?? this.attendance,
      ppvBuys: ppvBuys ?? this.ppvBuys,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      reputationChange: reputationChange ?? this.reputationChange,
      fightOfTheNightFightId:
          fightOfTheNightFightId ?? this.fightOfTheNightFightId,
      performanceOfTheNightFighterId:
          performanceOfTheNightFighterId ?? this.performanceOfTheNightFighterId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (ticketPrice.present) {
      map['ticket_price'] = Variable<int>(ticketPrice.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (promotionBudgetSpent.present) {
      map['promotion_budget_spent'] = Variable<int>(promotionBudgetSpent.value);
    }
    if (attendance.present) {
      map['attendance'] = Variable<int>(attendance.value);
    }
    if (ppvBuys.present) {
      map['ppv_buys'] = Variable<int>(ppvBuys.value);
    }
    if (revenue.present) {
      map['revenue'] = Variable<int>(revenue.value);
    }
    if (expenses.present) {
      map['expenses'] = Variable<int>(expenses.value);
    }
    if (reputationChange.present) {
      map['reputation_change'] = Variable<int>(reputationChange.value);
    }
    if (fightOfTheNightFightId.present) {
      map['fight_of_the_night_fight_id'] =
          Variable<String>(fightOfTheNightFightId.value);
    }
    if (performanceOfTheNightFighterId.present) {
      map['performance_of_the_night_fighter_id'] =
          Variable<String>(performanceOfTheNightFighterId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('venue: $venue, ')
          ..write('ticketPrice: $ticketPrice, ')
          ..write('status: $status, ')
          ..write('promotionBudgetSpent: $promotionBudgetSpent, ')
          ..write('attendance: $attendance, ')
          ..write('ppvBuys: $ppvBuys, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('reputationChange: $reputationChange, ')
          ..write('fightOfTheNightFightId: $fightOfTheNightFightId, ')
          ..write(
              'performanceOfTheNightFighterId: $performanceOfTheNightFighterId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FightsTable extends Fights with TableInfo<$FightsTable, FightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fighterAIdMeta =
      const VerificationMeta('fighterAId');
  @override
  late final GeneratedColumn<String> fighterAId = GeneratedColumn<String>(
      'fighter_a_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fighterBIdMeta =
      const VerificationMeta('fighterBId');
  @override
  late final GeneratedColumn<String> fighterBId = GeneratedColumn<String>(
      'fighter_b_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightClassMeta =
      const VerificationMeta('weightClass');
  @override
  late final GeneratedColumn<String> weightClass = GeneratedColumn<String>(
      'weight_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleFightTypeMeta =
      const VerificationMeta('titleFightType');
  @override
  late final GeneratedColumn<String> titleFightType = GeneratedColumn<String>(
      'title_fight_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _isMainEventMeta =
      const VerificationMeta('isMainEvent');
  @override
  late final GeneratedColumn<bool> isMainEvent = GeneratedColumn<bool>(
      'is_main_event', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_main_event" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isCoMainEventMeta =
      const VerificationMeta('isCoMainEvent');
  @override
  late final GeneratedColumn<bool> isCoMainEvent = GeneratedColumn<bool>(
      'is_co_main_event', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_co_main_event" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
      'rounds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _cardOrderMeta =
      const VerificationMeta('cardOrder');
  @override
  late final GeneratedColumn<int> cardOrder = GeneratedColumn<int>(
      'card_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _resultWinnerIdMeta =
      const VerificationMeta('resultWinnerId');
  @override
  late final GeneratedColumn<String> resultWinnerId = GeneratedColumn<String>(
      'result_winner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMethodMeta =
      const VerificationMeta('resultMethod');
  @override
  late final GeneratedColumn<String> resultMethod = GeneratedColumn<String>(
      'result_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultRoundMeta =
      const VerificationMeta('resultRound');
  @override
  late final GeneratedColumn<int> resultRound = GeneratedColumn<int>(
      'result_round', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _resultTimeSecondsMeta =
      const VerificationMeta('resultTimeSeconds');
  @override
  late final GeneratedColumn<int> resultTimeSeconds = GeneratedColumn<int>(
      'result_time_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(300));
  static const VerificationMeta _resultDecisionTypeMeta =
      const VerificationMeta('resultDecisionType');
  @override
  late final GeneratedColumn<String> resultDecisionType =
      GeneratedColumn<String>('result_decision_type', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('none'));
  static const VerificationMeta _resultMethodDetailMeta =
      const VerificationMeta('resultMethodDetail');
  @override
  late final GeneratedColumn<String> resultMethodDetail =
      GeneratedColumn<String>('result_method_detail', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _winnerPerformanceRatingMeta =
      const VerificationMeta('winnerPerformanceRating');
  @override
  late final GeneratedColumn<int> winnerPerformanceRating =
      GeneratedColumn<int>('winner_performance_rating', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _loserPerformanceRatingMeta =
      const VerificationMeta('loserPerformanceRating');
  @override
  late final GeneratedColumn<int> loserPerformanceRating = GeneratedColumn<int>(
      'loser_performance_rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _resultFighterAInjuryMeta =
      const VerificationMeta('resultFighterAInjury');
  @override
  late final GeneratedColumn<String> resultFighterAInjury =
      GeneratedColumn<String>('result_fighter_a_injury', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultFighterBInjuryMeta =
      const VerificationMeta('resultFighterBInjury');
  @override
  late final GeneratedColumn<String> resultFighterBInjury =
      GeneratedColumn<String>('result_fighter_b_injury', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eventId,
        fighterAId,
        fighterBId,
        weightClass,
        titleFightType,
        isMainEvent,
        isCoMainEvent,
        rounds,
        cardOrder,
        resultWinnerId,
        resultMethod,
        resultRound,
        resultTimeSeconds,
        resultDecisionType,
        resultMethodDetail,
        winnerPerformanceRating,
        loserPerformanceRating,
        resultFighterAInjury,
        resultFighterBInjury
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fights';
  @override
  VerificationContext validateIntegrity(Insertable<FightRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('fighter_a_id')) {
      context.handle(
          _fighterAIdMeta,
          fighterAId.isAcceptableOrUnknown(
              data['fighter_a_id']!, _fighterAIdMeta));
    } else if (isInserting) {
      context.missing(_fighterAIdMeta);
    }
    if (data.containsKey('fighter_b_id')) {
      context.handle(
          _fighterBIdMeta,
          fighterBId.isAcceptableOrUnknown(
              data['fighter_b_id']!, _fighterBIdMeta));
    } else if (isInserting) {
      context.missing(_fighterBIdMeta);
    }
    if (data.containsKey('weight_class')) {
      context.handle(
          _weightClassMeta,
          weightClass.isAcceptableOrUnknown(
              data['weight_class']!, _weightClassMeta));
    } else if (isInserting) {
      context.missing(_weightClassMeta);
    }
    if (data.containsKey('title_fight_type')) {
      context.handle(
          _titleFightTypeMeta,
          titleFightType.isAcceptableOrUnknown(
              data['title_fight_type']!, _titleFightTypeMeta));
    }
    if (data.containsKey('is_main_event')) {
      context.handle(
          _isMainEventMeta,
          isMainEvent.isAcceptableOrUnknown(
              data['is_main_event']!, _isMainEventMeta));
    }
    if (data.containsKey('is_co_main_event')) {
      context.handle(
          _isCoMainEventMeta,
          isCoMainEvent.isAcceptableOrUnknown(
              data['is_co_main_event']!, _isCoMainEventMeta));
    }
    if (data.containsKey('rounds')) {
      context.handle(_roundsMeta,
          rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta));
    }
    if (data.containsKey('card_order')) {
      context.handle(_cardOrderMeta,
          cardOrder.isAcceptableOrUnknown(data['card_order']!, _cardOrderMeta));
    }
    if (data.containsKey('result_winner_id')) {
      context.handle(
          _resultWinnerIdMeta,
          resultWinnerId.isAcceptableOrUnknown(
              data['result_winner_id']!, _resultWinnerIdMeta));
    }
    if (data.containsKey('result_method')) {
      context.handle(
          _resultMethodMeta,
          resultMethod.isAcceptableOrUnknown(
              data['result_method']!, _resultMethodMeta));
    }
    if (data.containsKey('result_round')) {
      context.handle(
          _resultRoundMeta,
          resultRound.isAcceptableOrUnknown(
              data['result_round']!, _resultRoundMeta));
    }
    if (data.containsKey('result_time_seconds')) {
      context.handle(
          _resultTimeSecondsMeta,
          resultTimeSeconds.isAcceptableOrUnknown(
              data['result_time_seconds']!, _resultTimeSecondsMeta));
    }
    if (data.containsKey('result_decision_type')) {
      context.handle(
          _resultDecisionTypeMeta,
          resultDecisionType.isAcceptableOrUnknown(
              data['result_decision_type']!, _resultDecisionTypeMeta));
    }
    if (data.containsKey('result_method_detail')) {
      context.handle(
          _resultMethodDetailMeta,
          resultMethodDetail.isAcceptableOrUnknown(
              data['result_method_detail']!, _resultMethodDetailMeta));
    }
    if (data.containsKey('winner_performance_rating')) {
      context.handle(
          _winnerPerformanceRatingMeta,
          winnerPerformanceRating.isAcceptableOrUnknown(
              data['winner_performance_rating']!,
              _winnerPerformanceRatingMeta));
    }
    if (data.containsKey('loser_performance_rating')) {
      context.handle(
          _loserPerformanceRatingMeta,
          loserPerformanceRating.isAcceptableOrUnknown(
              data['loser_performance_rating']!, _loserPerformanceRatingMeta));
    }
    if (data.containsKey('result_fighter_a_injury')) {
      context.handle(
          _resultFighterAInjuryMeta,
          resultFighterAInjury.isAcceptableOrUnknown(
              data['result_fighter_a_injury']!, _resultFighterAInjuryMeta));
    }
    if (data.containsKey('result_fighter_b_injury')) {
      context.handle(
          _resultFighterBInjuryMeta,
          resultFighterBInjury.isAcceptableOrUnknown(
              data['result_fighter_b_injury']!, _resultFighterBInjuryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FightRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      fighterAId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fighter_a_id'])!,
      fighterBId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fighter_b_id'])!,
      weightClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_class'])!,
      titleFightType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}title_fight_type'])!,
      isMainEvent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_main_event'])!,
      isCoMainEvent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_co_main_event'])!,
      rounds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rounds'])!,
      cardOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_order'])!,
      resultWinnerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_winner_id']),
      resultMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_method']),
      resultRound: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}result_round']),
      resultTimeSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}result_time_seconds'])!,
      resultDecisionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_decision_type'])!,
      resultMethodDetail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_method_detail'])!,
      winnerPerformanceRating: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}winner_performance_rating']),
      loserPerformanceRating: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}loser_performance_rating']),
      resultFighterAInjury: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}result_fighter_a_injury']),
      resultFighterBInjury: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}result_fighter_b_injury']),
    );
  }

  @override
  $FightsTable createAlias(String alias) {
    return $FightsTable(attachedDatabase, alias);
  }
}

class FightRow extends DataClass implements Insertable<FightRow> {
  final String id;
  final String eventId;
  final String fighterAId;
  final String fighterBId;
  final String weightClass;
  final String titleFightType;
  final bool isMainEvent;
  final bool isCoMainEvent;
  final int rounds;
  final int cardOrder;
  final String? resultWinnerId;
  final String? resultMethod;
  final int? resultRound;
  final int resultTimeSeconds;
  final String resultDecisionType;
  final String resultMethodDetail;
  final int? winnerPerformanceRating;
  final int? loserPerformanceRating;
  final String? resultFighterAInjury;
  final String? resultFighterBInjury;
  const FightRow(
      {required this.id,
      required this.eventId,
      required this.fighterAId,
      required this.fighterBId,
      required this.weightClass,
      required this.titleFightType,
      required this.isMainEvent,
      required this.isCoMainEvent,
      required this.rounds,
      required this.cardOrder,
      this.resultWinnerId,
      this.resultMethod,
      this.resultRound,
      required this.resultTimeSeconds,
      required this.resultDecisionType,
      required this.resultMethodDetail,
      this.winnerPerformanceRating,
      this.loserPerformanceRating,
      this.resultFighterAInjury,
      this.resultFighterBInjury});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['fighter_a_id'] = Variable<String>(fighterAId);
    map['fighter_b_id'] = Variable<String>(fighterBId);
    map['weight_class'] = Variable<String>(weightClass);
    map['title_fight_type'] = Variable<String>(titleFightType);
    map['is_main_event'] = Variable<bool>(isMainEvent);
    map['is_co_main_event'] = Variable<bool>(isCoMainEvent);
    map['rounds'] = Variable<int>(rounds);
    map['card_order'] = Variable<int>(cardOrder);
    if (!nullToAbsent || resultWinnerId != null) {
      map['result_winner_id'] = Variable<String>(resultWinnerId);
    }
    if (!nullToAbsent || resultMethod != null) {
      map['result_method'] = Variable<String>(resultMethod);
    }
    if (!nullToAbsent || resultRound != null) {
      map['result_round'] = Variable<int>(resultRound);
    }
    map['result_time_seconds'] = Variable<int>(resultTimeSeconds);
    map['result_decision_type'] = Variable<String>(resultDecisionType);
    map['result_method_detail'] = Variable<String>(resultMethodDetail);
    if (!nullToAbsent || winnerPerformanceRating != null) {
      map['winner_performance_rating'] = Variable<int>(winnerPerformanceRating);
    }
    if (!nullToAbsent || loserPerformanceRating != null) {
      map['loser_performance_rating'] = Variable<int>(loserPerformanceRating);
    }
    if (!nullToAbsent || resultFighterAInjury != null) {
      map['result_fighter_a_injury'] = Variable<String>(resultFighterAInjury);
    }
    if (!nullToAbsent || resultFighterBInjury != null) {
      map['result_fighter_b_injury'] = Variable<String>(resultFighterBInjury);
    }
    return map;
  }

  FightsCompanion toCompanion(bool nullToAbsent) {
    return FightsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      fighterAId: Value(fighterAId),
      fighterBId: Value(fighterBId),
      weightClass: Value(weightClass),
      titleFightType: Value(titleFightType),
      isMainEvent: Value(isMainEvent),
      isCoMainEvent: Value(isCoMainEvent),
      rounds: Value(rounds),
      cardOrder: Value(cardOrder),
      resultWinnerId: resultWinnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(resultWinnerId),
      resultMethod: resultMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(resultMethod),
      resultRound: resultRound == null && nullToAbsent
          ? const Value.absent()
          : Value(resultRound),
      resultTimeSeconds: Value(resultTimeSeconds),
      resultDecisionType: Value(resultDecisionType),
      resultMethodDetail: Value(resultMethodDetail),
      winnerPerformanceRating: winnerPerformanceRating == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerPerformanceRating),
      loserPerformanceRating: loserPerformanceRating == null && nullToAbsent
          ? const Value.absent()
          : Value(loserPerformanceRating),
      resultFighterAInjury: resultFighterAInjury == null && nullToAbsent
          ? const Value.absent()
          : Value(resultFighterAInjury),
      resultFighterBInjury: resultFighterBInjury == null && nullToAbsent
          ? const Value.absent()
          : Value(resultFighterBInjury),
    );
  }

  factory FightRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FightRow(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      fighterAId: serializer.fromJson<String>(json['fighterAId']),
      fighterBId: serializer.fromJson<String>(json['fighterBId']),
      weightClass: serializer.fromJson<String>(json['weightClass']),
      titleFightType: serializer.fromJson<String>(json['titleFightType']),
      isMainEvent: serializer.fromJson<bool>(json['isMainEvent']),
      isCoMainEvent: serializer.fromJson<bool>(json['isCoMainEvent']),
      rounds: serializer.fromJson<int>(json['rounds']),
      cardOrder: serializer.fromJson<int>(json['cardOrder']),
      resultWinnerId: serializer.fromJson<String?>(json['resultWinnerId']),
      resultMethod: serializer.fromJson<String?>(json['resultMethod']),
      resultRound: serializer.fromJson<int?>(json['resultRound']),
      resultTimeSeconds: serializer.fromJson<int>(json['resultTimeSeconds']),
      resultDecisionType:
          serializer.fromJson<String>(json['resultDecisionType']),
      resultMethodDetail:
          serializer.fromJson<String>(json['resultMethodDetail']),
      winnerPerformanceRating:
          serializer.fromJson<int?>(json['winnerPerformanceRating']),
      loserPerformanceRating:
          serializer.fromJson<int?>(json['loserPerformanceRating']),
      resultFighterAInjury:
          serializer.fromJson<String?>(json['resultFighterAInjury']),
      resultFighterBInjury:
          serializer.fromJson<String?>(json['resultFighterBInjury']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'fighterAId': serializer.toJson<String>(fighterAId),
      'fighterBId': serializer.toJson<String>(fighterBId),
      'weightClass': serializer.toJson<String>(weightClass),
      'titleFightType': serializer.toJson<String>(titleFightType),
      'isMainEvent': serializer.toJson<bool>(isMainEvent),
      'isCoMainEvent': serializer.toJson<bool>(isCoMainEvent),
      'rounds': serializer.toJson<int>(rounds),
      'cardOrder': serializer.toJson<int>(cardOrder),
      'resultWinnerId': serializer.toJson<String?>(resultWinnerId),
      'resultMethod': serializer.toJson<String?>(resultMethod),
      'resultRound': serializer.toJson<int?>(resultRound),
      'resultTimeSeconds': serializer.toJson<int>(resultTimeSeconds),
      'resultDecisionType': serializer.toJson<String>(resultDecisionType),
      'resultMethodDetail': serializer.toJson<String>(resultMethodDetail),
      'winnerPerformanceRating':
          serializer.toJson<int?>(winnerPerformanceRating),
      'loserPerformanceRating': serializer.toJson<int?>(loserPerformanceRating),
      'resultFighterAInjury': serializer.toJson<String?>(resultFighterAInjury),
      'resultFighterBInjury': serializer.toJson<String?>(resultFighterBInjury),
    };
  }

  FightRow copyWith(
          {String? id,
          String? eventId,
          String? fighterAId,
          String? fighterBId,
          String? weightClass,
          String? titleFightType,
          bool? isMainEvent,
          bool? isCoMainEvent,
          int? rounds,
          int? cardOrder,
          Value<String?> resultWinnerId = const Value.absent(),
          Value<String?> resultMethod = const Value.absent(),
          Value<int?> resultRound = const Value.absent(),
          int? resultTimeSeconds,
          String? resultDecisionType,
          String? resultMethodDetail,
          Value<int?> winnerPerformanceRating = const Value.absent(),
          Value<int?> loserPerformanceRating = const Value.absent(),
          Value<String?> resultFighterAInjury = const Value.absent(),
          Value<String?> resultFighterBInjury = const Value.absent()}) =>
      FightRow(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        fighterAId: fighterAId ?? this.fighterAId,
        fighterBId: fighterBId ?? this.fighterBId,
        weightClass: weightClass ?? this.weightClass,
        titleFightType: titleFightType ?? this.titleFightType,
        isMainEvent: isMainEvent ?? this.isMainEvent,
        isCoMainEvent: isCoMainEvent ?? this.isCoMainEvent,
        rounds: rounds ?? this.rounds,
        cardOrder: cardOrder ?? this.cardOrder,
        resultWinnerId:
            resultWinnerId.present ? resultWinnerId.value : this.resultWinnerId,
        resultMethod:
            resultMethod.present ? resultMethod.value : this.resultMethod,
        resultRound: resultRound.present ? resultRound.value : this.resultRound,
        resultTimeSeconds: resultTimeSeconds ?? this.resultTimeSeconds,
        resultDecisionType: resultDecisionType ?? this.resultDecisionType,
        resultMethodDetail: resultMethodDetail ?? this.resultMethodDetail,
        winnerPerformanceRating: winnerPerformanceRating.present
            ? winnerPerformanceRating.value
            : this.winnerPerformanceRating,
        loserPerformanceRating: loserPerformanceRating.present
            ? loserPerformanceRating.value
            : this.loserPerformanceRating,
        resultFighterAInjury: resultFighterAInjury.present
            ? resultFighterAInjury.value
            : this.resultFighterAInjury,
        resultFighterBInjury: resultFighterBInjury.present
            ? resultFighterBInjury.value
            : this.resultFighterBInjury,
      );
  FightRow copyWithCompanion(FightsCompanion data) {
    return FightRow(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      fighterAId:
          data.fighterAId.present ? data.fighterAId.value : this.fighterAId,
      fighterBId:
          data.fighterBId.present ? data.fighterBId.value : this.fighterBId,
      weightClass:
          data.weightClass.present ? data.weightClass.value : this.weightClass,
      titleFightType: data.titleFightType.present
          ? data.titleFightType.value
          : this.titleFightType,
      isMainEvent:
          data.isMainEvent.present ? data.isMainEvent.value : this.isMainEvent,
      isCoMainEvent: data.isCoMainEvent.present
          ? data.isCoMainEvent.value
          : this.isCoMainEvent,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      cardOrder: data.cardOrder.present ? data.cardOrder.value : this.cardOrder,
      resultWinnerId: data.resultWinnerId.present
          ? data.resultWinnerId.value
          : this.resultWinnerId,
      resultMethod: data.resultMethod.present
          ? data.resultMethod.value
          : this.resultMethod,
      resultRound:
          data.resultRound.present ? data.resultRound.value : this.resultRound,
      resultTimeSeconds: data.resultTimeSeconds.present
          ? data.resultTimeSeconds.value
          : this.resultTimeSeconds,
      resultDecisionType: data.resultDecisionType.present
          ? data.resultDecisionType.value
          : this.resultDecisionType,
      resultMethodDetail: data.resultMethodDetail.present
          ? data.resultMethodDetail.value
          : this.resultMethodDetail,
      winnerPerformanceRating: data.winnerPerformanceRating.present
          ? data.winnerPerformanceRating.value
          : this.winnerPerformanceRating,
      loserPerformanceRating: data.loserPerformanceRating.present
          ? data.loserPerformanceRating.value
          : this.loserPerformanceRating,
      resultFighterAInjury: data.resultFighterAInjury.present
          ? data.resultFighterAInjury.value
          : this.resultFighterAInjury,
      resultFighterBInjury: data.resultFighterBInjury.present
          ? data.resultFighterBInjury.value
          : this.resultFighterBInjury,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FightRow(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('fighterAId: $fighterAId, ')
          ..write('fighterBId: $fighterBId, ')
          ..write('weightClass: $weightClass, ')
          ..write('titleFightType: $titleFightType, ')
          ..write('isMainEvent: $isMainEvent, ')
          ..write('isCoMainEvent: $isCoMainEvent, ')
          ..write('rounds: $rounds, ')
          ..write('cardOrder: $cardOrder, ')
          ..write('resultWinnerId: $resultWinnerId, ')
          ..write('resultMethod: $resultMethod, ')
          ..write('resultRound: $resultRound, ')
          ..write('resultTimeSeconds: $resultTimeSeconds, ')
          ..write('resultDecisionType: $resultDecisionType, ')
          ..write('resultMethodDetail: $resultMethodDetail, ')
          ..write('winnerPerformanceRating: $winnerPerformanceRating, ')
          ..write('loserPerformanceRating: $loserPerformanceRating, ')
          ..write('resultFighterAInjury: $resultFighterAInjury, ')
          ..write('resultFighterBInjury: $resultFighterBInjury')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      eventId,
      fighterAId,
      fighterBId,
      weightClass,
      titleFightType,
      isMainEvent,
      isCoMainEvent,
      rounds,
      cardOrder,
      resultWinnerId,
      resultMethod,
      resultRound,
      resultTimeSeconds,
      resultDecisionType,
      resultMethodDetail,
      winnerPerformanceRating,
      loserPerformanceRating,
      resultFighterAInjury,
      resultFighterBInjury);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FightRow &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.fighterAId == this.fighterAId &&
          other.fighterBId == this.fighterBId &&
          other.weightClass == this.weightClass &&
          other.titleFightType == this.titleFightType &&
          other.isMainEvent == this.isMainEvent &&
          other.isCoMainEvent == this.isCoMainEvent &&
          other.rounds == this.rounds &&
          other.cardOrder == this.cardOrder &&
          other.resultWinnerId == this.resultWinnerId &&
          other.resultMethod == this.resultMethod &&
          other.resultRound == this.resultRound &&
          other.resultTimeSeconds == this.resultTimeSeconds &&
          other.resultDecisionType == this.resultDecisionType &&
          other.resultMethodDetail == this.resultMethodDetail &&
          other.winnerPerformanceRating == this.winnerPerformanceRating &&
          other.loserPerformanceRating == this.loserPerformanceRating &&
          other.resultFighterAInjury == this.resultFighterAInjury &&
          other.resultFighterBInjury == this.resultFighterBInjury);
}

class FightsCompanion extends UpdateCompanion<FightRow> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> fighterAId;
  final Value<String> fighterBId;
  final Value<String> weightClass;
  final Value<String> titleFightType;
  final Value<bool> isMainEvent;
  final Value<bool> isCoMainEvent;
  final Value<int> rounds;
  final Value<int> cardOrder;
  final Value<String?> resultWinnerId;
  final Value<String?> resultMethod;
  final Value<int?> resultRound;
  final Value<int> resultTimeSeconds;
  final Value<String> resultDecisionType;
  final Value<String> resultMethodDetail;
  final Value<int?> winnerPerformanceRating;
  final Value<int?> loserPerformanceRating;
  final Value<String?> resultFighterAInjury;
  final Value<String?> resultFighterBInjury;
  final Value<int> rowid;
  const FightsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.fighterAId = const Value.absent(),
    this.fighterBId = const Value.absent(),
    this.weightClass = const Value.absent(),
    this.titleFightType = const Value.absent(),
    this.isMainEvent = const Value.absent(),
    this.isCoMainEvent = const Value.absent(),
    this.rounds = const Value.absent(),
    this.cardOrder = const Value.absent(),
    this.resultWinnerId = const Value.absent(),
    this.resultMethod = const Value.absent(),
    this.resultRound = const Value.absent(),
    this.resultTimeSeconds = const Value.absent(),
    this.resultDecisionType = const Value.absent(),
    this.resultMethodDetail = const Value.absent(),
    this.winnerPerformanceRating = const Value.absent(),
    this.loserPerformanceRating = const Value.absent(),
    this.resultFighterAInjury = const Value.absent(),
    this.resultFighterBInjury = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FightsCompanion.insert({
    required String id,
    required String eventId,
    required String fighterAId,
    required String fighterBId,
    required String weightClass,
    this.titleFightType = const Value.absent(),
    this.isMainEvent = const Value.absent(),
    this.isCoMainEvent = const Value.absent(),
    this.rounds = const Value.absent(),
    this.cardOrder = const Value.absent(),
    this.resultWinnerId = const Value.absent(),
    this.resultMethod = const Value.absent(),
    this.resultRound = const Value.absent(),
    this.resultTimeSeconds = const Value.absent(),
    this.resultDecisionType = const Value.absent(),
    this.resultMethodDetail = const Value.absent(),
    this.winnerPerformanceRating = const Value.absent(),
    this.loserPerformanceRating = const Value.absent(),
    this.resultFighterAInjury = const Value.absent(),
    this.resultFighterBInjury = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eventId = Value(eventId),
        fighterAId = Value(fighterAId),
        fighterBId = Value(fighterBId),
        weightClass = Value(weightClass);
  static Insertable<FightRow> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? fighterAId,
    Expression<String>? fighterBId,
    Expression<String>? weightClass,
    Expression<String>? titleFightType,
    Expression<bool>? isMainEvent,
    Expression<bool>? isCoMainEvent,
    Expression<int>? rounds,
    Expression<int>? cardOrder,
    Expression<String>? resultWinnerId,
    Expression<String>? resultMethod,
    Expression<int>? resultRound,
    Expression<int>? resultTimeSeconds,
    Expression<String>? resultDecisionType,
    Expression<String>? resultMethodDetail,
    Expression<int>? winnerPerformanceRating,
    Expression<int>? loserPerformanceRating,
    Expression<String>? resultFighterAInjury,
    Expression<String>? resultFighterBInjury,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (fighterAId != null) 'fighter_a_id': fighterAId,
      if (fighterBId != null) 'fighter_b_id': fighterBId,
      if (weightClass != null) 'weight_class': weightClass,
      if (titleFightType != null) 'title_fight_type': titleFightType,
      if (isMainEvent != null) 'is_main_event': isMainEvent,
      if (isCoMainEvent != null) 'is_co_main_event': isCoMainEvent,
      if (rounds != null) 'rounds': rounds,
      if (cardOrder != null) 'card_order': cardOrder,
      if (resultWinnerId != null) 'result_winner_id': resultWinnerId,
      if (resultMethod != null) 'result_method': resultMethod,
      if (resultRound != null) 'result_round': resultRound,
      if (resultTimeSeconds != null) 'result_time_seconds': resultTimeSeconds,
      if (resultDecisionType != null)
        'result_decision_type': resultDecisionType,
      if (resultMethodDetail != null)
        'result_method_detail': resultMethodDetail,
      if (winnerPerformanceRating != null)
        'winner_performance_rating': winnerPerformanceRating,
      if (loserPerformanceRating != null)
        'loser_performance_rating': loserPerformanceRating,
      if (resultFighterAInjury != null)
        'result_fighter_a_injury': resultFighterAInjury,
      if (resultFighterBInjury != null)
        'result_fighter_b_injury': resultFighterBInjury,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FightsCompanion copyWith(
      {Value<String>? id,
      Value<String>? eventId,
      Value<String>? fighterAId,
      Value<String>? fighterBId,
      Value<String>? weightClass,
      Value<String>? titleFightType,
      Value<bool>? isMainEvent,
      Value<bool>? isCoMainEvent,
      Value<int>? rounds,
      Value<int>? cardOrder,
      Value<String?>? resultWinnerId,
      Value<String?>? resultMethod,
      Value<int?>? resultRound,
      Value<int>? resultTimeSeconds,
      Value<String>? resultDecisionType,
      Value<String>? resultMethodDetail,
      Value<int?>? winnerPerformanceRating,
      Value<int?>? loserPerformanceRating,
      Value<String?>? resultFighterAInjury,
      Value<String?>? resultFighterBInjury,
      Value<int>? rowid}) {
    return FightsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      fighterAId: fighterAId ?? this.fighterAId,
      fighterBId: fighterBId ?? this.fighterBId,
      weightClass: weightClass ?? this.weightClass,
      titleFightType: titleFightType ?? this.titleFightType,
      isMainEvent: isMainEvent ?? this.isMainEvent,
      isCoMainEvent: isCoMainEvent ?? this.isCoMainEvent,
      rounds: rounds ?? this.rounds,
      cardOrder: cardOrder ?? this.cardOrder,
      resultWinnerId: resultWinnerId ?? this.resultWinnerId,
      resultMethod: resultMethod ?? this.resultMethod,
      resultRound: resultRound ?? this.resultRound,
      resultTimeSeconds: resultTimeSeconds ?? this.resultTimeSeconds,
      resultDecisionType: resultDecisionType ?? this.resultDecisionType,
      resultMethodDetail: resultMethodDetail ?? this.resultMethodDetail,
      winnerPerformanceRating:
          winnerPerformanceRating ?? this.winnerPerformanceRating,
      loserPerformanceRating:
          loserPerformanceRating ?? this.loserPerformanceRating,
      resultFighterAInjury: resultFighterAInjury ?? this.resultFighterAInjury,
      resultFighterBInjury: resultFighterBInjury ?? this.resultFighterBInjury,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (fighterAId.present) {
      map['fighter_a_id'] = Variable<String>(fighterAId.value);
    }
    if (fighterBId.present) {
      map['fighter_b_id'] = Variable<String>(fighterBId.value);
    }
    if (weightClass.present) {
      map['weight_class'] = Variable<String>(weightClass.value);
    }
    if (titleFightType.present) {
      map['title_fight_type'] = Variable<String>(titleFightType.value);
    }
    if (isMainEvent.present) {
      map['is_main_event'] = Variable<bool>(isMainEvent.value);
    }
    if (isCoMainEvent.present) {
      map['is_co_main_event'] = Variable<bool>(isCoMainEvent.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (cardOrder.present) {
      map['card_order'] = Variable<int>(cardOrder.value);
    }
    if (resultWinnerId.present) {
      map['result_winner_id'] = Variable<String>(resultWinnerId.value);
    }
    if (resultMethod.present) {
      map['result_method'] = Variable<String>(resultMethod.value);
    }
    if (resultRound.present) {
      map['result_round'] = Variable<int>(resultRound.value);
    }
    if (resultTimeSeconds.present) {
      map['result_time_seconds'] = Variable<int>(resultTimeSeconds.value);
    }
    if (resultDecisionType.present) {
      map['result_decision_type'] = Variable<String>(resultDecisionType.value);
    }
    if (resultMethodDetail.present) {
      map['result_method_detail'] = Variable<String>(resultMethodDetail.value);
    }
    if (winnerPerformanceRating.present) {
      map['winner_performance_rating'] =
          Variable<int>(winnerPerformanceRating.value);
    }
    if (loserPerformanceRating.present) {
      map['loser_performance_rating'] =
          Variable<int>(loserPerformanceRating.value);
    }
    if (resultFighterAInjury.present) {
      map['result_fighter_a_injury'] =
          Variable<String>(resultFighterAInjury.value);
    }
    if (resultFighterBInjury.present) {
      map['result_fighter_b_injury'] =
          Variable<String>(resultFighterBInjury.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FightsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('fighterAId: $fighterAId, ')
          ..write('fighterBId: $fighterBId, ')
          ..write('weightClass: $weightClass, ')
          ..write('titleFightType: $titleFightType, ')
          ..write('isMainEvent: $isMainEvent, ')
          ..write('isCoMainEvent: $isCoMainEvent, ')
          ..write('rounds: $rounds, ')
          ..write('cardOrder: $cardOrder, ')
          ..write('resultWinnerId: $resultWinnerId, ')
          ..write('resultMethod: $resultMethod, ')
          ..write('resultRound: $resultRound, ')
          ..write('resultTimeSeconds: $resultTimeSeconds, ')
          ..write('resultDecisionType: $resultDecisionType, ')
          ..write('resultMethodDetail: $resultMethodDetail, ')
          ..write('winnerPerformanceRating: $winnerPerformanceRating, ')
          ..write('loserPerformanceRating: $loserPerformanceRating, ')
          ..write('resultFighterAInjury: $resultFighterAInjury, ')
          ..write('resultFighterBInjury: $resultFighterBInjury, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RandomEventsTable extends RandomEvents
    with TableInfo<$RandomEventsTable, RandomEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RandomEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _affectedFighterIdMeta =
      const VerificationMeta('affectedFighterId');
  @override
  late final GeneratedColumn<String> affectedFighterId =
      GeneratedColumn<String>('affected_fighter_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _headlineMeta =
      const VerificationMeta('headline');
  @override
  late final GeneratedColumn<String> headline = GeneratedColumn<String>(
      'headline', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _choicesJsonMeta =
      const VerificationMeta('choicesJson');
  @override
  late final GeneratedColumn<String> choicesJson = GeneratedColumn<String>(
      'choices_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chosenChoiceIdMeta =
      const VerificationMeta('chosenChoiceId');
  @override
  late final GeneratedColumn<String> chosenChoiceId = GeneratedColumn<String>(
      'chosen_choice_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _occurredOnMeta =
      const VerificationMeta('occurredOn');
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
      'occurred_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        affectedFighterId,
        headline,
        description,
        choicesJson,
        chosenChoiceId,
        occurredOn
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'random_events';
  @override
  VerificationContext validateIntegrity(Insertable<RandomEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('affected_fighter_id')) {
      context.handle(
          _affectedFighterIdMeta,
          affectedFighterId.isAcceptableOrUnknown(
              data['affected_fighter_id']!, _affectedFighterIdMeta));
    }
    if (data.containsKey('headline')) {
      context.handle(_headlineMeta,
          headline.isAcceptableOrUnknown(data['headline']!, _headlineMeta));
    } else if (isInserting) {
      context.missing(_headlineMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('choices_json')) {
      context.handle(
          _choicesJsonMeta,
          choicesJson.isAcceptableOrUnknown(
              data['choices_json']!, _choicesJsonMeta));
    } else if (isInserting) {
      context.missing(_choicesJsonMeta);
    }
    if (data.containsKey('chosen_choice_id')) {
      context.handle(
          _chosenChoiceIdMeta,
          chosenChoiceId.isAcceptableOrUnknown(
              data['chosen_choice_id']!, _chosenChoiceIdMeta));
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
          _occurredOnMeta,
          occurredOn.isAcceptableOrUnknown(
              data['occurred_on']!, _occurredOnMeta));
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RandomEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RandomEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      affectedFighterId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}affected_fighter_id']),
      headline: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headline'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      choicesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}choices_json'])!,
      chosenChoiceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}chosen_choice_id']),
      occurredOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_on'])!,
    );
  }

  @override
  $RandomEventsTable createAlias(String alias) {
    return $RandomEventsTable(attachedDatabase, alias);
  }
}

class RandomEventRow extends DataClass implements Insertable<RandomEventRow> {
  final String id;
  final String type;
  final String? affectedFighterId;
  final String headline;
  final String description;

  /// JSON-encoded list of `{id, label, consequenceSummary}` objects.
  final String choicesJson;
  final String? chosenChoiceId;
  final DateTime occurredOn;
  const RandomEventRow(
      {required this.id,
      required this.type,
      this.affectedFighterId,
      required this.headline,
      required this.description,
      required this.choicesJson,
      this.chosenChoiceId,
      required this.occurredOn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || affectedFighterId != null) {
      map['affected_fighter_id'] = Variable<String>(affectedFighterId);
    }
    map['headline'] = Variable<String>(headline);
    map['description'] = Variable<String>(description);
    map['choices_json'] = Variable<String>(choicesJson);
    if (!nullToAbsent || chosenChoiceId != null) {
      map['chosen_choice_id'] = Variable<String>(chosenChoiceId);
    }
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    return map;
  }

  RandomEventsCompanion toCompanion(bool nullToAbsent) {
    return RandomEventsCompanion(
      id: Value(id),
      type: Value(type),
      affectedFighterId: affectedFighterId == null && nullToAbsent
          ? const Value.absent()
          : Value(affectedFighterId),
      headline: Value(headline),
      description: Value(description),
      choicesJson: Value(choicesJson),
      chosenChoiceId: chosenChoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(chosenChoiceId),
      occurredOn: Value(occurredOn),
    );
  }

  factory RandomEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RandomEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      affectedFighterId:
          serializer.fromJson<String?>(json['affectedFighterId']),
      headline: serializer.fromJson<String>(json['headline']),
      description: serializer.fromJson<String>(json['description']),
      choicesJson: serializer.fromJson<String>(json['choicesJson']),
      chosenChoiceId: serializer.fromJson<String?>(json['chosenChoiceId']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'affectedFighterId': serializer.toJson<String?>(affectedFighterId),
      'headline': serializer.toJson<String>(headline),
      'description': serializer.toJson<String>(description),
      'choicesJson': serializer.toJson<String>(choicesJson),
      'chosenChoiceId': serializer.toJson<String?>(chosenChoiceId),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
    };
  }

  RandomEventRow copyWith(
          {String? id,
          String? type,
          Value<String?> affectedFighterId = const Value.absent(),
          String? headline,
          String? description,
          String? choicesJson,
          Value<String?> chosenChoiceId = const Value.absent(),
          DateTime? occurredOn}) =>
      RandomEventRow(
        id: id ?? this.id,
        type: type ?? this.type,
        affectedFighterId: affectedFighterId.present
            ? affectedFighterId.value
            : this.affectedFighterId,
        headline: headline ?? this.headline,
        description: description ?? this.description,
        choicesJson: choicesJson ?? this.choicesJson,
        chosenChoiceId:
            chosenChoiceId.present ? chosenChoiceId.value : this.chosenChoiceId,
        occurredOn: occurredOn ?? this.occurredOn,
      );
  RandomEventRow copyWithCompanion(RandomEventsCompanion data) {
    return RandomEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      affectedFighterId: data.affectedFighterId.present
          ? data.affectedFighterId.value
          : this.affectedFighterId,
      headline: data.headline.present ? data.headline.value : this.headline,
      description:
          data.description.present ? data.description.value : this.description,
      choicesJson:
          data.choicesJson.present ? data.choicesJson.value : this.choicesJson,
      chosenChoiceId: data.chosenChoiceId.present
          ? data.chosenChoiceId.value
          : this.chosenChoiceId,
      occurredOn:
          data.occurredOn.present ? data.occurredOn.value : this.occurredOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RandomEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('affectedFighterId: $affectedFighterId, ')
          ..write('headline: $headline, ')
          ..write('description: $description, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('chosenChoiceId: $chosenChoiceId, ')
          ..write('occurredOn: $occurredOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, affectedFighterId, headline,
      description, choicesJson, chosenChoiceId, occurredOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RandomEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.affectedFighterId == this.affectedFighterId &&
          other.headline == this.headline &&
          other.description == this.description &&
          other.choicesJson == this.choicesJson &&
          other.chosenChoiceId == this.chosenChoiceId &&
          other.occurredOn == this.occurredOn);
}

class RandomEventsCompanion extends UpdateCompanion<RandomEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> affectedFighterId;
  final Value<String> headline;
  final Value<String> description;
  final Value<String> choicesJson;
  final Value<String?> chosenChoiceId;
  final Value<DateTime> occurredOn;
  final Value<int> rowid;
  const RandomEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.affectedFighterId = const Value.absent(),
    this.headline = const Value.absent(),
    this.description = const Value.absent(),
    this.choicesJson = const Value.absent(),
    this.chosenChoiceId = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RandomEventsCompanion.insert({
    required String id,
    required String type,
    this.affectedFighterId = const Value.absent(),
    required String headline,
    required String description,
    required String choicesJson,
    this.chosenChoiceId = const Value.absent(),
    required DateTime occurredOn,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        headline = Value(headline),
        description = Value(description),
        choicesJson = Value(choicesJson),
        occurredOn = Value(occurredOn);
  static Insertable<RandomEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? affectedFighterId,
    Expression<String>? headline,
    Expression<String>? description,
    Expression<String>? choicesJson,
    Expression<String>? chosenChoiceId,
    Expression<DateTime>? occurredOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (affectedFighterId != null) 'affected_fighter_id': affectedFighterId,
      if (headline != null) 'headline': headline,
      if (description != null) 'description': description,
      if (choicesJson != null) 'choices_json': choicesJson,
      if (chosenChoiceId != null) 'chosen_choice_id': chosenChoiceId,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RandomEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String?>? affectedFighterId,
      Value<String>? headline,
      Value<String>? description,
      Value<String>? choicesJson,
      Value<String?>? chosenChoiceId,
      Value<DateTime>? occurredOn,
      Value<int>? rowid}) {
    return RandomEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      affectedFighterId: affectedFighterId ?? this.affectedFighterId,
      headline: headline ?? this.headline,
      description: description ?? this.description,
      choicesJson: choicesJson ?? this.choicesJson,
      chosenChoiceId: chosenChoiceId ?? this.chosenChoiceId,
      occurredOn: occurredOn ?? this.occurredOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (affectedFighterId.present) {
      map['affected_fighter_id'] = Variable<String>(affectedFighterId.value);
    }
    if (headline.present) {
      map['headline'] = Variable<String>(headline.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (choicesJson.present) {
      map['choices_json'] = Variable<String>(choicesJson.value);
    }
    if (chosenChoiceId.present) {
      map['chosen_choice_id'] = Variable<String>(chosenChoiceId.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RandomEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('affectedFighterId: $affectedFighterId, ')
          ..write('headline: $headline, ')
          ..write('description: $description, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('chosenChoiceId: $chosenChoiceId, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FightersTable fighters = $FightersTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $FightsTable fights = $FightsTable(this);
  late final $RandomEventsTable randomEvents = $RandomEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [fighters, contracts, organizations, events, fights, randomEvents];
}

typedef $$FightersTableCreateCompanionBuilder = FightersCompanion Function({
  required String id,
  required String name,
  required int age,
  required String nationality,
  required String weightClass,
  Value<int> heightInches,
  Value<int> weightLbs,
  Value<int> reachInches,
  Value<int> wins,
  Value<int> losses,
  Value<int> draws,
  required int punching,
  required int kicking,
  required int power,
  required int speed,
  required int accuracy,
  required int defense,
  Value<int> headMovement,
  Value<int> blocking,
  Value<int> footwork,
  required int takedowns,
  required int takedownDefense,
  required int wrestling,
  Value<int> clinchStriking,
  Value<int> clinchControl,
  Value<int> clinchDefense,
  Value<int> topControl,
  required int groundAndPound,
  Value<int> guardRetention,
  Value<int> sweeps,
  Value<int> scrambling,
  required int submissionOffense,
  required int submissionDefense,
  required int grappling,
  required int cardio,
  required int durability,
  required int chin,
  required int bodyToughness,
  required int legToughness,
  required int strength,
  required int athleticism,
  required int recovery,
  Value<int> explosiveness,
  Value<int> flexibility,
  Value<int> gripStrength,
  required int fightIq,
  required int composure,
  required int aggression,
  required int discipline,
  required int confidence,
  required int heart,
  required int adaptability,
  Value<int> killerInstinct,
  required int tendStrikingFrequency,
  required int tendTakedownFrequency,
  required int tendKickFrequency,
  required int tendClinchFrequency,
  required int tendSubmissionAttempts,
  required int tendGroundAndPound,
  Value<int> tendPositionControl,
  Value<int> tendStandUpPreference,
  Value<int> tendWallWork,
  required int tendAggression,
  required int tendCounterStriking,
  required int tendHeadHunting,
  required int tendBodyAttacks,
  required int tendLegAttacks,
  Value<String> style,
  Value<int> potential,
  Value<int> popularity,
  Value<int> morale,
  Value<String> injuryStatus,
  Value<int> winStreak,
  Value<int> lossStreak,
  Value<int> eloRating,
  Value<bool> isRanked,
  Value<bool> retired,
  Value<String?> retirementReason,
  Value<int> fightOfTheNightCount,
  Value<int> performanceOfTheNightCount,
  Value<int> rowid,
});
typedef $$FightersTableUpdateCompanionBuilder = FightersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> age,
  Value<String> nationality,
  Value<String> weightClass,
  Value<int> heightInches,
  Value<int> weightLbs,
  Value<int> reachInches,
  Value<int> wins,
  Value<int> losses,
  Value<int> draws,
  Value<int> punching,
  Value<int> kicking,
  Value<int> power,
  Value<int> speed,
  Value<int> accuracy,
  Value<int> defense,
  Value<int> headMovement,
  Value<int> blocking,
  Value<int> footwork,
  Value<int> takedowns,
  Value<int> takedownDefense,
  Value<int> wrestling,
  Value<int> clinchStriking,
  Value<int> clinchControl,
  Value<int> clinchDefense,
  Value<int> topControl,
  Value<int> groundAndPound,
  Value<int> guardRetention,
  Value<int> sweeps,
  Value<int> scrambling,
  Value<int> submissionOffense,
  Value<int> submissionDefense,
  Value<int> grappling,
  Value<int> cardio,
  Value<int> durability,
  Value<int> chin,
  Value<int> bodyToughness,
  Value<int> legToughness,
  Value<int> strength,
  Value<int> athleticism,
  Value<int> recovery,
  Value<int> explosiveness,
  Value<int> flexibility,
  Value<int> gripStrength,
  Value<int> fightIq,
  Value<int> composure,
  Value<int> aggression,
  Value<int> discipline,
  Value<int> confidence,
  Value<int> heart,
  Value<int> adaptability,
  Value<int> killerInstinct,
  Value<int> tendStrikingFrequency,
  Value<int> tendTakedownFrequency,
  Value<int> tendKickFrequency,
  Value<int> tendClinchFrequency,
  Value<int> tendSubmissionAttempts,
  Value<int> tendGroundAndPound,
  Value<int> tendPositionControl,
  Value<int> tendStandUpPreference,
  Value<int> tendWallWork,
  Value<int> tendAggression,
  Value<int> tendCounterStriking,
  Value<int> tendHeadHunting,
  Value<int> tendBodyAttacks,
  Value<int> tendLegAttacks,
  Value<String> style,
  Value<int> potential,
  Value<int> popularity,
  Value<int> morale,
  Value<String> injuryStatus,
  Value<int> winStreak,
  Value<int> lossStreak,
  Value<int> eloRating,
  Value<bool> isRanked,
  Value<bool> retired,
  Value<String?> retirementReason,
  Value<int> fightOfTheNightCount,
  Value<int> performanceOfTheNightCount,
  Value<int> rowid,
});

class $$FightersTableFilterComposer
    extends Composer<_$AppDatabase, $FightersTable> {
  $$FightersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heightInches => $composableBuilder(
      column: $table.heightInches, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weightLbs => $composableBuilder(
      column: $table.weightLbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reachInches => $composableBuilder(
      column: $table.reachInches, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wins => $composableBuilder(
      column: $table.wins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get losses => $composableBuilder(
      column: $table.losses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get draws => $composableBuilder(
      column: $table.draws, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get punching => $composableBuilder(
      column: $table.punching, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kicking => $composableBuilder(
      column: $table.kicking, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get power => $composableBuilder(
      column: $table.power, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defense => $composableBuilder(
      column: $table.defense, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get headMovement => $composableBuilder(
      column: $table.headMovement, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get blocking => $composableBuilder(
      column: $table.blocking, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get footwork => $composableBuilder(
      column: $table.footwork, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get takedowns => $composableBuilder(
      column: $table.takedowns, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get takedownDefense => $composableBuilder(
      column: $table.takedownDefense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wrestling => $composableBuilder(
      column: $table.wrestling, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clinchStriking => $composableBuilder(
      column: $table.clinchStriking,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clinchControl => $composableBuilder(
      column: $table.clinchControl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clinchDefense => $composableBuilder(
      column: $table.clinchDefense, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get topControl => $composableBuilder(
      column: $table.topControl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groundAndPound => $composableBuilder(
      column: $table.groundAndPound,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get guardRetention => $composableBuilder(
      column: $table.guardRetention,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sweeps => $composableBuilder(
      column: $table.sweeps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scrambling => $composableBuilder(
      column: $table.scrambling, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get submissionOffense => $composableBuilder(
      column: $table.submissionOffense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get submissionDefense => $composableBuilder(
      column: $table.submissionDefense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grappling => $composableBuilder(
      column: $table.grappling, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardio => $composableBuilder(
      column: $table.cardio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durability => $composableBuilder(
      column: $table.durability, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chin => $composableBuilder(
      column: $table.chin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bodyToughness => $composableBuilder(
      column: $table.bodyToughness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get legToughness => $composableBuilder(
      column: $table.legToughness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get athleticism => $composableBuilder(
      column: $table.athleticism, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recovery => $composableBuilder(
      column: $table.recovery, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get explosiveness => $composableBuilder(
      column: $table.explosiveness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flexibility => $composableBuilder(
      column: $table.flexibility, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gripStrength => $composableBuilder(
      column: $table.gripStrength, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fightIq => $composableBuilder(
      column: $table.fightIq, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get composure => $composableBuilder(
      column: $table.composure, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aggression => $composableBuilder(
      column: $table.aggression, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discipline => $composableBuilder(
      column: $table.discipline, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heart => $composableBuilder(
      column: $table.heart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get adaptability => $composableBuilder(
      column: $table.adaptability, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get killerInstinct => $composableBuilder(
      column: $table.killerInstinct,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendStrikingFrequency => $composableBuilder(
      column: $table.tendStrikingFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendTakedownFrequency => $composableBuilder(
      column: $table.tendTakedownFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendKickFrequency => $composableBuilder(
      column: $table.tendKickFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendClinchFrequency => $composableBuilder(
      column: $table.tendClinchFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendSubmissionAttempts => $composableBuilder(
      column: $table.tendSubmissionAttempts,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendGroundAndPound => $composableBuilder(
      column: $table.tendGroundAndPound,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendPositionControl => $composableBuilder(
      column: $table.tendPositionControl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendStandUpPreference => $composableBuilder(
      column: $table.tendStandUpPreference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendWallWork => $composableBuilder(
      column: $table.tendWallWork, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendAggression => $composableBuilder(
      column: $table.tendAggression,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendCounterStriking => $composableBuilder(
      column: $table.tendCounterStriking,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendHeadHunting => $composableBuilder(
      column: $table.tendHeadHunting,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendBodyAttacks => $composableBuilder(
      column: $table.tendBodyAttacks,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tendLegAttacks => $composableBuilder(
      column: $table.tendLegAttacks,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get style => $composableBuilder(
      column: $table.style, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get potential => $composableBuilder(
      column: $table.potential, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get morale => $composableBuilder(
      column: $table.morale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get injuryStatus => $composableBuilder(
      column: $table.injuryStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get winStreak => $composableBuilder(
      column: $table.winStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lossStreak => $composableBuilder(
      column: $table.lossStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get eloRating => $composableBuilder(
      column: $table.eloRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRanked => $composableBuilder(
      column: $table.isRanked, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get retired => $composableBuilder(
      column: $table.retired, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get retirementReason => $composableBuilder(
      column: $table.retirementReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fightOfTheNightCount => $composableBuilder(
      column: $table.fightOfTheNightCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get performanceOfTheNightCount => $composableBuilder(
      column: $table.performanceOfTheNightCount,
      builder: (column) => ColumnFilters(column));
}

class $$FightersTableOrderingComposer
    extends Composer<_$AppDatabase, $FightersTable> {
  $$FightersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heightInches => $composableBuilder(
      column: $table.heightInches,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weightLbs => $composableBuilder(
      column: $table.weightLbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reachInches => $composableBuilder(
      column: $table.reachInches, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wins => $composableBuilder(
      column: $table.wins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get losses => $composableBuilder(
      column: $table.losses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get draws => $composableBuilder(
      column: $table.draws, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get punching => $composableBuilder(
      column: $table.punching, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kicking => $composableBuilder(
      column: $table.kicking, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get power => $composableBuilder(
      column: $table.power, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defense => $composableBuilder(
      column: $table.defense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get headMovement => $composableBuilder(
      column: $table.headMovement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get blocking => $composableBuilder(
      column: $table.blocking, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get footwork => $composableBuilder(
      column: $table.footwork, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get takedowns => $composableBuilder(
      column: $table.takedowns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get takedownDefense => $composableBuilder(
      column: $table.takedownDefense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wrestling => $composableBuilder(
      column: $table.wrestling, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clinchStriking => $composableBuilder(
      column: $table.clinchStriking,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clinchControl => $composableBuilder(
      column: $table.clinchControl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clinchDefense => $composableBuilder(
      column: $table.clinchDefense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get topControl => $composableBuilder(
      column: $table.topControl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groundAndPound => $composableBuilder(
      column: $table.groundAndPound,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get guardRetention => $composableBuilder(
      column: $table.guardRetention,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sweeps => $composableBuilder(
      column: $table.sweeps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scrambling => $composableBuilder(
      column: $table.scrambling, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get submissionOffense => $composableBuilder(
      column: $table.submissionOffense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get submissionDefense => $composableBuilder(
      column: $table.submissionDefense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grappling => $composableBuilder(
      column: $table.grappling, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardio => $composableBuilder(
      column: $table.cardio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durability => $composableBuilder(
      column: $table.durability, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chin => $composableBuilder(
      column: $table.chin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bodyToughness => $composableBuilder(
      column: $table.bodyToughness,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get legToughness => $composableBuilder(
      column: $table.legToughness,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get athleticism => $composableBuilder(
      column: $table.athleticism, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recovery => $composableBuilder(
      column: $table.recovery, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get explosiveness => $composableBuilder(
      column: $table.explosiveness,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flexibility => $composableBuilder(
      column: $table.flexibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gripStrength => $composableBuilder(
      column: $table.gripStrength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fightIq => $composableBuilder(
      column: $table.fightIq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get composure => $composableBuilder(
      column: $table.composure, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aggression => $composableBuilder(
      column: $table.aggression, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discipline => $composableBuilder(
      column: $table.discipline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heart => $composableBuilder(
      column: $table.heart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get adaptability => $composableBuilder(
      column: $table.adaptability,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get killerInstinct => $composableBuilder(
      column: $table.killerInstinct,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendStrikingFrequency => $composableBuilder(
      column: $table.tendStrikingFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendTakedownFrequency => $composableBuilder(
      column: $table.tendTakedownFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendKickFrequency => $composableBuilder(
      column: $table.tendKickFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendClinchFrequency => $composableBuilder(
      column: $table.tendClinchFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendSubmissionAttempts => $composableBuilder(
      column: $table.tendSubmissionAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendGroundAndPound => $composableBuilder(
      column: $table.tendGroundAndPound,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendPositionControl => $composableBuilder(
      column: $table.tendPositionControl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendStandUpPreference => $composableBuilder(
      column: $table.tendStandUpPreference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendWallWork => $composableBuilder(
      column: $table.tendWallWork,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendAggression => $composableBuilder(
      column: $table.tendAggression,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendCounterStriking => $composableBuilder(
      column: $table.tendCounterStriking,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendHeadHunting => $composableBuilder(
      column: $table.tendHeadHunting,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendBodyAttacks => $composableBuilder(
      column: $table.tendBodyAttacks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tendLegAttacks => $composableBuilder(
      column: $table.tendLegAttacks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get style => $composableBuilder(
      column: $table.style, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get potential => $composableBuilder(
      column: $table.potential, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get morale => $composableBuilder(
      column: $table.morale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get injuryStatus => $composableBuilder(
      column: $table.injuryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get winStreak => $composableBuilder(
      column: $table.winStreak, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lossStreak => $composableBuilder(
      column: $table.lossStreak, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get eloRating => $composableBuilder(
      column: $table.eloRating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRanked => $composableBuilder(
      column: $table.isRanked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get retired => $composableBuilder(
      column: $table.retired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get retirementReason => $composableBuilder(
      column: $table.retirementReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fightOfTheNightCount => $composableBuilder(
      column: $table.fightOfTheNightCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get performanceOfTheNightCount => $composableBuilder(
      column: $table.performanceOfTheNightCount,
      builder: (column) => ColumnOrderings(column));
}

class $$FightersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FightersTable> {
  $$FightersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => column);

  GeneratedColumn<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => column);

  GeneratedColumn<int> get heightInches => $composableBuilder(
      column: $table.heightInches, builder: (column) => column);

  GeneratedColumn<int> get weightLbs =>
      $composableBuilder(column: $table.weightLbs, builder: (column) => column);

  GeneratedColumn<int> get reachInches => $composableBuilder(
      column: $table.reachInches, builder: (column) => column);

  GeneratedColumn<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => column);

  GeneratedColumn<int> get losses =>
      $composableBuilder(column: $table.losses, builder: (column) => column);

  GeneratedColumn<int> get draws =>
      $composableBuilder(column: $table.draws, builder: (column) => column);

  GeneratedColumn<int> get punching =>
      $composableBuilder(column: $table.punching, builder: (column) => column);

  GeneratedColumn<int> get kicking =>
      $composableBuilder(column: $table.kicking, builder: (column) => column);

  GeneratedColumn<int> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<int> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get defense =>
      $composableBuilder(column: $table.defense, builder: (column) => column);

  GeneratedColumn<int> get headMovement => $composableBuilder(
      column: $table.headMovement, builder: (column) => column);

  GeneratedColumn<int> get blocking =>
      $composableBuilder(column: $table.blocking, builder: (column) => column);

  GeneratedColumn<int> get footwork =>
      $composableBuilder(column: $table.footwork, builder: (column) => column);

  GeneratedColumn<int> get takedowns =>
      $composableBuilder(column: $table.takedowns, builder: (column) => column);

  GeneratedColumn<int> get takedownDefense => $composableBuilder(
      column: $table.takedownDefense, builder: (column) => column);

  GeneratedColumn<int> get wrestling =>
      $composableBuilder(column: $table.wrestling, builder: (column) => column);

  GeneratedColumn<int> get clinchStriking => $composableBuilder(
      column: $table.clinchStriking, builder: (column) => column);

  GeneratedColumn<int> get clinchControl => $composableBuilder(
      column: $table.clinchControl, builder: (column) => column);

  GeneratedColumn<int> get clinchDefense => $composableBuilder(
      column: $table.clinchDefense, builder: (column) => column);

  GeneratedColumn<int> get topControl => $composableBuilder(
      column: $table.topControl, builder: (column) => column);

  GeneratedColumn<int> get groundAndPound => $composableBuilder(
      column: $table.groundAndPound, builder: (column) => column);

  GeneratedColumn<int> get guardRetention => $composableBuilder(
      column: $table.guardRetention, builder: (column) => column);

  GeneratedColumn<int> get sweeps =>
      $composableBuilder(column: $table.sweeps, builder: (column) => column);

  GeneratedColumn<int> get scrambling => $composableBuilder(
      column: $table.scrambling, builder: (column) => column);

  GeneratedColumn<int> get submissionOffense => $composableBuilder(
      column: $table.submissionOffense, builder: (column) => column);

  GeneratedColumn<int> get submissionDefense => $composableBuilder(
      column: $table.submissionDefense, builder: (column) => column);

  GeneratedColumn<int> get grappling =>
      $composableBuilder(column: $table.grappling, builder: (column) => column);

  GeneratedColumn<int> get cardio =>
      $composableBuilder(column: $table.cardio, builder: (column) => column);

  GeneratedColumn<int> get durability => $composableBuilder(
      column: $table.durability, builder: (column) => column);

  GeneratedColumn<int> get chin =>
      $composableBuilder(column: $table.chin, builder: (column) => column);

  GeneratedColumn<int> get bodyToughness => $composableBuilder(
      column: $table.bodyToughness, builder: (column) => column);

  GeneratedColumn<int> get legToughness => $composableBuilder(
      column: $table.legToughness, builder: (column) => column);

  GeneratedColumn<int> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<int> get athleticism => $composableBuilder(
      column: $table.athleticism, builder: (column) => column);

  GeneratedColumn<int> get recovery =>
      $composableBuilder(column: $table.recovery, builder: (column) => column);

  GeneratedColumn<int> get explosiveness => $composableBuilder(
      column: $table.explosiveness, builder: (column) => column);

  GeneratedColumn<int> get flexibility => $composableBuilder(
      column: $table.flexibility, builder: (column) => column);

  GeneratedColumn<int> get gripStrength => $composableBuilder(
      column: $table.gripStrength, builder: (column) => column);

  GeneratedColumn<int> get fightIq =>
      $composableBuilder(column: $table.fightIq, builder: (column) => column);

  GeneratedColumn<int> get composure =>
      $composableBuilder(column: $table.composure, builder: (column) => column);

  GeneratedColumn<int> get aggression => $composableBuilder(
      column: $table.aggression, builder: (column) => column);

  GeneratedColumn<int> get discipline => $composableBuilder(
      column: $table.discipline, builder: (column) => column);

  GeneratedColumn<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<int> get heart =>
      $composableBuilder(column: $table.heart, builder: (column) => column);

  GeneratedColumn<int> get adaptability => $composableBuilder(
      column: $table.adaptability, builder: (column) => column);

  GeneratedColumn<int> get killerInstinct => $composableBuilder(
      column: $table.killerInstinct, builder: (column) => column);

  GeneratedColumn<int> get tendStrikingFrequency => $composableBuilder(
      column: $table.tendStrikingFrequency, builder: (column) => column);

  GeneratedColumn<int> get tendTakedownFrequency => $composableBuilder(
      column: $table.tendTakedownFrequency, builder: (column) => column);

  GeneratedColumn<int> get tendKickFrequency => $composableBuilder(
      column: $table.tendKickFrequency, builder: (column) => column);

  GeneratedColumn<int> get tendClinchFrequency => $composableBuilder(
      column: $table.tendClinchFrequency, builder: (column) => column);

  GeneratedColumn<int> get tendSubmissionAttempts => $composableBuilder(
      column: $table.tendSubmissionAttempts, builder: (column) => column);

  GeneratedColumn<int> get tendGroundAndPound => $composableBuilder(
      column: $table.tendGroundAndPound, builder: (column) => column);

  GeneratedColumn<int> get tendPositionControl => $composableBuilder(
      column: $table.tendPositionControl, builder: (column) => column);

  GeneratedColumn<int> get tendStandUpPreference => $composableBuilder(
      column: $table.tendStandUpPreference, builder: (column) => column);

  GeneratedColumn<int> get tendWallWork => $composableBuilder(
      column: $table.tendWallWork, builder: (column) => column);

  GeneratedColumn<int> get tendAggression => $composableBuilder(
      column: $table.tendAggression, builder: (column) => column);

  GeneratedColumn<int> get tendCounterStriking => $composableBuilder(
      column: $table.tendCounterStriking, builder: (column) => column);

  GeneratedColumn<int> get tendHeadHunting => $composableBuilder(
      column: $table.tendHeadHunting, builder: (column) => column);

  GeneratedColumn<int> get tendBodyAttacks => $composableBuilder(
      column: $table.tendBodyAttacks, builder: (column) => column);

  GeneratedColumn<int> get tendLegAttacks => $composableBuilder(
      column: $table.tendLegAttacks, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<int> get potential =>
      $composableBuilder(column: $table.potential, builder: (column) => column);

  GeneratedColumn<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => column);

  GeneratedColumn<int> get morale =>
      $composableBuilder(column: $table.morale, builder: (column) => column);

  GeneratedColumn<String> get injuryStatus => $composableBuilder(
      column: $table.injuryStatus, builder: (column) => column);

  GeneratedColumn<int> get winStreak =>
      $composableBuilder(column: $table.winStreak, builder: (column) => column);

  GeneratedColumn<int> get lossStreak => $composableBuilder(
      column: $table.lossStreak, builder: (column) => column);

  GeneratedColumn<int> get eloRating =>
      $composableBuilder(column: $table.eloRating, builder: (column) => column);

  GeneratedColumn<bool> get isRanked =>
      $composableBuilder(column: $table.isRanked, builder: (column) => column);

  GeneratedColumn<bool> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<String> get retirementReason => $composableBuilder(
      column: $table.retirementReason, builder: (column) => column);

  GeneratedColumn<int> get fightOfTheNightCount => $composableBuilder(
      column: $table.fightOfTheNightCount, builder: (column) => column);

  GeneratedColumn<int> get performanceOfTheNightCount => $composableBuilder(
      column: $table.performanceOfTheNightCount, builder: (column) => column);
}

class $$FightersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FightersTable,
    FighterRow,
    $$FightersTableFilterComposer,
    $$FightersTableOrderingComposer,
    $$FightersTableAnnotationComposer,
    $$FightersTableCreateCompanionBuilder,
    $$FightersTableUpdateCompanionBuilder,
    (FighterRow, BaseReferences<_$AppDatabase, $FightersTable, FighterRow>),
    FighterRow,
    PrefetchHooks Function()> {
  $$FightersTableTableManager(_$AppDatabase db, $FightersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FightersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FightersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FightersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<String> nationality = const Value.absent(),
            Value<String> weightClass = const Value.absent(),
            Value<int> heightInches = const Value.absent(),
            Value<int> weightLbs = const Value.absent(),
            Value<int> reachInches = const Value.absent(),
            Value<int> wins = const Value.absent(),
            Value<int> losses = const Value.absent(),
            Value<int> draws = const Value.absent(),
            Value<int> punching = const Value.absent(),
            Value<int> kicking = const Value.absent(),
            Value<int> power = const Value.absent(),
            Value<int> speed = const Value.absent(),
            Value<int> accuracy = const Value.absent(),
            Value<int> defense = const Value.absent(),
            Value<int> headMovement = const Value.absent(),
            Value<int> blocking = const Value.absent(),
            Value<int> footwork = const Value.absent(),
            Value<int> takedowns = const Value.absent(),
            Value<int> takedownDefense = const Value.absent(),
            Value<int> wrestling = const Value.absent(),
            Value<int> clinchStriking = const Value.absent(),
            Value<int> clinchControl = const Value.absent(),
            Value<int> clinchDefense = const Value.absent(),
            Value<int> topControl = const Value.absent(),
            Value<int> groundAndPound = const Value.absent(),
            Value<int> guardRetention = const Value.absent(),
            Value<int> sweeps = const Value.absent(),
            Value<int> scrambling = const Value.absent(),
            Value<int> submissionOffense = const Value.absent(),
            Value<int> submissionDefense = const Value.absent(),
            Value<int> grappling = const Value.absent(),
            Value<int> cardio = const Value.absent(),
            Value<int> durability = const Value.absent(),
            Value<int> chin = const Value.absent(),
            Value<int> bodyToughness = const Value.absent(),
            Value<int> legToughness = const Value.absent(),
            Value<int> strength = const Value.absent(),
            Value<int> athleticism = const Value.absent(),
            Value<int> recovery = const Value.absent(),
            Value<int> explosiveness = const Value.absent(),
            Value<int> flexibility = const Value.absent(),
            Value<int> gripStrength = const Value.absent(),
            Value<int> fightIq = const Value.absent(),
            Value<int> composure = const Value.absent(),
            Value<int> aggression = const Value.absent(),
            Value<int> discipline = const Value.absent(),
            Value<int> confidence = const Value.absent(),
            Value<int> heart = const Value.absent(),
            Value<int> adaptability = const Value.absent(),
            Value<int> killerInstinct = const Value.absent(),
            Value<int> tendStrikingFrequency = const Value.absent(),
            Value<int> tendTakedownFrequency = const Value.absent(),
            Value<int> tendKickFrequency = const Value.absent(),
            Value<int> tendClinchFrequency = const Value.absent(),
            Value<int> tendSubmissionAttempts = const Value.absent(),
            Value<int> tendGroundAndPound = const Value.absent(),
            Value<int> tendPositionControl = const Value.absent(),
            Value<int> tendStandUpPreference = const Value.absent(),
            Value<int> tendWallWork = const Value.absent(),
            Value<int> tendAggression = const Value.absent(),
            Value<int> tendCounterStriking = const Value.absent(),
            Value<int> tendHeadHunting = const Value.absent(),
            Value<int> tendBodyAttacks = const Value.absent(),
            Value<int> tendLegAttacks = const Value.absent(),
            Value<String> style = const Value.absent(),
            Value<int> potential = const Value.absent(),
            Value<int> popularity = const Value.absent(),
            Value<int> morale = const Value.absent(),
            Value<String> injuryStatus = const Value.absent(),
            Value<int> winStreak = const Value.absent(),
            Value<int> lossStreak = const Value.absent(),
            Value<int> eloRating = const Value.absent(),
            Value<bool> isRanked = const Value.absent(),
            Value<bool> retired = const Value.absent(),
            Value<String?> retirementReason = const Value.absent(),
            Value<int> fightOfTheNightCount = const Value.absent(),
            Value<int> performanceOfTheNightCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightersCompanion(
            id: id,
            name: name,
            age: age,
            nationality: nationality,
            weightClass: weightClass,
            heightInches: heightInches,
            weightLbs: weightLbs,
            reachInches: reachInches,
            wins: wins,
            losses: losses,
            draws: draws,
            punching: punching,
            kicking: kicking,
            power: power,
            speed: speed,
            accuracy: accuracy,
            defense: defense,
            headMovement: headMovement,
            blocking: blocking,
            footwork: footwork,
            takedowns: takedowns,
            takedownDefense: takedownDefense,
            wrestling: wrestling,
            clinchStriking: clinchStriking,
            clinchControl: clinchControl,
            clinchDefense: clinchDefense,
            topControl: topControl,
            groundAndPound: groundAndPound,
            guardRetention: guardRetention,
            sweeps: sweeps,
            scrambling: scrambling,
            submissionOffense: submissionOffense,
            submissionDefense: submissionDefense,
            grappling: grappling,
            cardio: cardio,
            durability: durability,
            chin: chin,
            bodyToughness: bodyToughness,
            legToughness: legToughness,
            strength: strength,
            athleticism: athleticism,
            recovery: recovery,
            explosiveness: explosiveness,
            flexibility: flexibility,
            gripStrength: gripStrength,
            fightIq: fightIq,
            composure: composure,
            aggression: aggression,
            discipline: discipline,
            confidence: confidence,
            heart: heart,
            adaptability: adaptability,
            killerInstinct: killerInstinct,
            tendStrikingFrequency: tendStrikingFrequency,
            tendTakedownFrequency: tendTakedownFrequency,
            tendKickFrequency: tendKickFrequency,
            tendClinchFrequency: tendClinchFrequency,
            tendSubmissionAttempts: tendSubmissionAttempts,
            tendGroundAndPound: tendGroundAndPound,
            tendPositionControl: tendPositionControl,
            tendStandUpPreference: tendStandUpPreference,
            tendWallWork: tendWallWork,
            tendAggression: tendAggression,
            tendCounterStriking: tendCounterStriking,
            tendHeadHunting: tendHeadHunting,
            tendBodyAttacks: tendBodyAttacks,
            tendLegAttacks: tendLegAttacks,
            style: style,
            potential: potential,
            popularity: popularity,
            morale: morale,
            injuryStatus: injuryStatus,
            winStreak: winStreak,
            lossStreak: lossStreak,
            eloRating: eloRating,
            isRanked: isRanked,
            retired: retired,
            retirementReason: retirementReason,
            fightOfTheNightCount: fightOfTheNightCount,
            performanceOfTheNightCount: performanceOfTheNightCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int age,
            required String nationality,
            required String weightClass,
            Value<int> heightInches = const Value.absent(),
            Value<int> weightLbs = const Value.absent(),
            Value<int> reachInches = const Value.absent(),
            Value<int> wins = const Value.absent(),
            Value<int> losses = const Value.absent(),
            Value<int> draws = const Value.absent(),
            required int punching,
            required int kicking,
            required int power,
            required int speed,
            required int accuracy,
            required int defense,
            Value<int> headMovement = const Value.absent(),
            Value<int> blocking = const Value.absent(),
            Value<int> footwork = const Value.absent(),
            required int takedowns,
            required int takedownDefense,
            required int wrestling,
            Value<int> clinchStriking = const Value.absent(),
            Value<int> clinchControl = const Value.absent(),
            Value<int> clinchDefense = const Value.absent(),
            Value<int> topControl = const Value.absent(),
            required int groundAndPound,
            Value<int> guardRetention = const Value.absent(),
            Value<int> sweeps = const Value.absent(),
            Value<int> scrambling = const Value.absent(),
            required int submissionOffense,
            required int submissionDefense,
            required int grappling,
            required int cardio,
            required int durability,
            required int chin,
            required int bodyToughness,
            required int legToughness,
            required int strength,
            required int athleticism,
            required int recovery,
            Value<int> explosiveness = const Value.absent(),
            Value<int> flexibility = const Value.absent(),
            Value<int> gripStrength = const Value.absent(),
            required int fightIq,
            required int composure,
            required int aggression,
            required int discipline,
            required int confidence,
            required int heart,
            required int adaptability,
            Value<int> killerInstinct = const Value.absent(),
            required int tendStrikingFrequency,
            required int tendTakedownFrequency,
            required int tendKickFrequency,
            required int tendClinchFrequency,
            required int tendSubmissionAttempts,
            required int tendGroundAndPound,
            Value<int> tendPositionControl = const Value.absent(),
            Value<int> tendStandUpPreference = const Value.absent(),
            Value<int> tendWallWork = const Value.absent(),
            required int tendAggression,
            required int tendCounterStriking,
            required int tendHeadHunting,
            required int tendBodyAttacks,
            required int tendLegAttacks,
            Value<String> style = const Value.absent(),
            Value<int> potential = const Value.absent(),
            Value<int> popularity = const Value.absent(),
            Value<int> morale = const Value.absent(),
            Value<String> injuryStatus = const Value.absent(),
            Value<int> winStreak = const Value.absent(),
            Value<int> lossStreak = const Value.absent(),
            Value<int> eloRating = const Value.absent(),
            Value<bool> isRanked = const Value.absent(),
            Value<bool> retired = const Value.absent(),
            Value<String?> retirementReason = const Value.absent(),
            Value<int> fightOfTheNightCount = const Value.absent(),
            Value<int> performanceOfTheNightCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightersCompanion.insert(
            id: id,
            name: name,
            age: age,
            nationality: nationality,
            weightClass: weightClass,
            heightInches: heightInches,
            weightLbs: weightLbs,
            reachInches: reachInches,
            wins: wins,
            losses: losses,
            draws: draws,
            punching: punching,
            kicking: kicking,
            power: power,
            speed: speed,
            accuracy: accuracy,
            defense: defense,
            headMovement: headMovement,
            blocking: blocking,
            footwork: footwork,
            takedowns: takedowns,
            takedownDefense: takedownDefense,
            wrestling: wrestling,
            clinchStriking: clinchStriking,
            clinchControl: clinchControl,
            clinchDefense: clinchDefense,
            topControl: topControl,
            groundAndPound: groundAndPound,
            guardRetention: guardRetention,
            sweeps: sweeps,
            scrambling: scrambling,
            submissionOffense: submissionOffense,
            submissionDefense: submissionDefense,
            grappling: grappling,
            cardio: cardio,
            durability: durability,
            chin: chin,
            bodyToughness: bodyToughness,
            legToughness: legToughness,
            strength: strength,
            athleticism: athleticism,
            recovery: recovery,
            explosiveness: explosiveness,
            flexibility: flexibility,
            gripStrength: gripStrength,
            fightIq: fightIq,
            composure: composure,
            aggression: aggression,
            discipline: discipline,
            confidence: confidence,
            heart: heart,
            adaptability: adaptability,
            killerInstinct: killerInstinct,
            tendStrikingFrequency: tendStrikingFrequency,
            tendTakedownFrequency: tendTakedownFrequency,
            tendKickFrequency: tendKickFrequency,
            tendClinchFrequency: tendClinchFrequency,
            tendSubmissionAttempts: tendSubmissionAttempts,
            tendGroundAndPound: tendGroundAndPound,
            tendPositionControl: tendPositionControl,
            tendStandUpPreference: tendStandUpPreference,
            tendWallWork: tendWallWork,
            tendAggression: tendAggression,
            tendCounterStriking: tendCounterStriking,
            tendHeadHunting: tendHeadHunting,
            tendBodyAttacks: tendBodyAttacks,
            tendLegAttacks: tendLegAttacks,
            style: style,
            potential: potential,
            popularity: popularity,
            morale: morale,
            injuryStatus: injuryStatus,
            winStreak: winStreak,
            lossStreak: lossStreak,
            eloRating: eloRating,
            isRanked: isRanked,
            retired: retired,
            retirementReason: retirementReason,
            fightOfTheNightCount: fightOfTheNightCount,
            performanceOfTheNightCount: performanceOfTheNightCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FightersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FightersTable,
    FighterRow,
    $$FightersTableFilterComposer,
    $$FightersTableOrderingComposer,
    $$FightersTableAnnotationComposer,
    $$FightersTableCreateCompanionBuilder,
    $$FightersTableUpdateCompanionBuilder,
    (FighterRow, BaseReferences<_$AppDatabase, $FightersTable, FighterRow>),
    FighterRow,
    PrefetchHooks Function()>;
typedef $$ContractsTableCreateCompanionBuilder = ContractsCompanion Function({
  required String id,
  required String fighterId,
  required int fightsRemaining,
  required int payPerFight,
  Value<bool> exclusive,
  required DateTime signedOn,
  Value<int> rowid,
});
typedef $$ContractsTableUpdateCompanionBuilder = ContractsCompanion Function({
  Value<String> id,
  Value<String> fighterId,
  Value<int> fightsRemaining,
  Value<int> payPerFight,
  Value<bool> exclusive,
  Value<DateTime> signedOn,
  Value<int> rowid,
});

class $$ContractsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fighterId => $composableBuilder(
      column: $table.fighterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fightsRemaining => $composableBuilder(
      column: $table.fightsRemaining,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get payPerFight => $composableBuilder(
      column: $table.payPerFight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exclusive => $composableBuilder(
      column: $table.exclusive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get signedOn => $composableBuilder(
      column: $table.signedOn, builder: (column) => ColumnFilters(column));
}

class $$ContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fighterId => $composableBuilder(
      column: $table.fighterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fightsRemaining => $composableBuilder(
      column: $table.fightsRemaining,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get payPerFight => $composableBuilder(
      column: $table.payPerFight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exclusive => $composableBuilder(
      column: $table.exclusive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get signedOn => $composableBuilder(
      column: $table.signedOn, builder: (column) => ColumnOrderings(column));
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fighterId =>
      $composableBuilder(column: $table.fighterId, builder: (column) => column);

  GeneratedColumn<int> get fightsRemaining => $composableBuilder(
      column: $table.fightsRemaining, builder: (column) => column);

  GeneratedColumn<int> get payPerFight => $composableBuilder(
      column: $table.payPerFight, builder: (column) => column);

  GeneratedColumn<bool> get exclusive =>
      $composableBuilder(column: $table.exclusive, builder: (column) => column);

  GeneratedColumn<DateTime> get signedOn =>
      $composableBuilder(column: $table.signedOn, builder: (column) => column);
}

class $$ContractsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContractsTable,
    ContractRow,
    $$ContractsTableFilterComposer,
    $$ContractsTableOrderingComposer,
    $$ContractsTableAnnotationComposer,
    $$ContractsTableCreateCompanionBuilder,
    $$ContractsTableUpdateCompanionBuilder,
    (ContractRow, BaseReferences<_$AppDatabase, $ContractsTable, ContractRow>),
    ContractRow,
    PrefetchHooks Function()> {
  $$ContractsTableTableManager(_$AppDatabase db, $ContractsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fighterId = const Value.absent(),
            Value<int> fightsRemaining = const Value.absent(),
            Value<int> payPerFight = const Value.absent(),
            Value<bool> exclusive = const Value.absent(),
            Value<DateTime> signedOn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContractsCompanion(
            id: id,
            fighterId: fighterId,
            fightsRemaining: fightsRemaining,
            payPerFight: payPerFight,
            exclusive: exclusive,
            signedOn: signedOn,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fighterId,
            required int fightsRemaining,
            required int payPerFight,
            Value<bool> exclusive = const Value.absent(),
            required DateTime signedOn,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContractsCompanion.insert(
            id: id,
            fighterId: fighterId,
            fightsRemaining: fightsRemaining,
            payPerFight: payPerFight,
            exclusive: exclusive,
            signedOn: signedOn,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContractsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContractsTable,
    ContractRow,
    $$ContractsTableFilterComposer,
    $$ContractsTableOrderingComposer,
    $$ContractsTableAnnotationComposer,
    $$ContractsTableCreateCompanionBuilder,
    $$ContractsTableUpdateCompanionBuilder,
    (ContractRow, BaseReferences<_$AppDatabase, $ContractsTable, ContractRow>),
    ContractRow,
    PrefetchHooks Function()>;
typedef $$OrganizationsTableCreateCompanionBuilder = OrganizationsCompanion
    Function({
  required String id,
  required String name,
  Value<String> reputationTier,
  Value<int> reputationPoints,
  required int cashBalance,
  Value<int> fanbaseSize,
  required String homeRegion,
  Value<int> promotionBudget,
  required DateTime lastTalentRefresh,
  Value<int> rowid,
});
typedef $$OrganizationsTableUpdateCompanionBuilder = OrganizationsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> reputationTier,
  Value<int> reputationPoints,
  Value<int> cashBalance,
  Value<int> fanbaseSize,
  Value<String> homeRegion,
  Value<int> promotionBudget,
  Value<DateTime> lastTalentRefresh,
  Value<int> rowid,
});

class $$OrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reputationTier => $composableBuilder(
      column: $table.reputationTier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reputationPoints => $composableBuilder(
      column: $table.reputationPoints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fanbaseSize => $composableBuilder(
      column: $table.fanbaseSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeRegion => $composableBuilder(
      column: $table.homeRegion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promotionBudget => $composableBuilder(
      column: $table.promotionBudget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastTalentRefresh => $composableBuilder(
      column: $table.lastTalentRefresh,
      builder: (column) => ColumnFilters(column));
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reputationTier => $composableBuilder(
      column: $table.reputationTier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reputationPoints => $composableBuilder(
      column: $table.reputationPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fanbaseSize => $composableBuilder(
      column: $table.fanbaseSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeRegion => $composableBuilder(
      column: $table.homeRegion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promotionBudget => $composableBuilder(
      column: $table.promotionBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastTalentRefresh => $composableBuilder(
      column: $table.lastTalentRefresh,
      builder: (column) => ColumnOrderings(column));
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get reputationTier => $composableBuilder(
      column: $table.reputationTier, builder: (column) => column);

  GeneratedColumn<int> get reputationPoints => $composableBuilder(
      column: $table.reputationPoints, builder: (column) => column);

  GeneratedColumn<int> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => column);

  GeneratedColumn<int> get fanbaseSize => $composableBuilder(
      column: $table.fanbaseSize, builder: (column) => column);

  GeneratedColumn<String> get homeRegion => $composableBuilder(
      column: $table.homeRegion, builder: (column) => column);

  GeneratedColumn<int> get promotionBudget => $composableBuilder(
      column: $table.promotionBudget, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTalentRefresh => $composableBuilder(
      column: $table.lastTalentRefresh, builder: (column) => column);
}

class $$OrganizationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    OrganizationRow,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (
      OrganizationRow,
      BaseReferences<_$AppDatabase, $OrganizationsTable, OrganizationRow>
    ),
    OrganizationRow,
    PrefetchHooks Function()> {
  $$OrganizationsTableTableManager(_$AppDatabase db, $OrganizationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> reputationTier = const Value.absent(),
            Value<int> reputationPoints = const Value.absent(),
            Value<int> cashBalance = const Value.absent(),
            Value<int> fanbaseSize = const Value.absent(),
            Value<String> homeRegion = const Value.absent(),
            Value<int> promotionBudget = const Value.absent(),
            Value<DateTime> lastTalentRefresh = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrganizationsCompanion(
            id: id,
            name: name,
            reputationTier: reputationTier,
            reputationPoints: reputationPoints,
            cashBalance: cashBalance,
            fanbaseSize: fanbaseSize,
            homeRegion: homeRegion,
            promotionBudget: promotionBudget,
            lastTalentRefresh: lastTalentRefresh,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> reputationTier = const Value.absent(),
            Value<int> reputationPoints = const Value.absent(),
            required int cashBalance,
            Value<int> fanbaseSize = const Value.absent(),
            required String homeRegion,
            Value<int> promotionBudget = const Value.absent(),
            required DateTime lastTalentRefresh,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrganizationsCompanion.insert(
            id: id,
            name: name,
            reputationTier: reputationTier,
            reputationPoints: reputationPoints,
            cashBalance: cashBalance,
            fanbaseSize: fanbaseSize,
            homeRegion: homeRegion,
            promotionBudget: promotionBudget,
            lastTalentRefresh: lastTalentRefresh,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrganizationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    OrganizationRow,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (
      OrganizationRow,
      BaseReferences<_$AppDatabase, $OrganizationsTable, OrganizationRow>
    ),
    OrganizationRow,
    PrefetchHooks Function()>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String name,
  required DateTime date,
  required String venue,
  Value<int> ticketPrice,
  Value<String> status,
  Value<int> promotionBudgetSpent,
  Value<int> attendance,
  Value<int> ppvBuys,
  Value<int> revenue,
  Value<int> expenses,
  Value<int> reputationChange,
  Value<String?> fightOfTheNightFightId,
  Value<String?> performanceOfTheNightFighterId,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> date,
  Value<String> venue,
  Value<int> ticketPrice,
  Value<String> status,
  Value<int> promotionBudgetSpent,
  Value<int> attendance,
  Value<int> ppvBuys,
  Value<int> revenue,
  Value<int> expenses,
  Value<int> reputationChange,
  Value<String?> fightOfTheNightFightId,
  Value<String?> performanceOfTheNightFighterId,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ticketPrice => $composableBuilder(
      column: $table.ticketPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promotionBudgetSpent => $composableBuilder(
      column: $table.promotionBudgetSpent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attendance => $composableBuilder(
      column: $table.attendance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ppvBuys => $composableBuilder(
      column: $table.ppvBuys, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revenue => $composableBuilder(
      column: $table.revenue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expenses => $composableBuilder(
      column: $table.expenses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reputationChange => $composableBuilder(
      column: $table.reputationChange,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fightOfTheNightFightId => $composableBuilder(
      column: $table.fightOfTheNightFightId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get performanceOfTheNightFighterId =>
      $composableBuilder(
          column: $table.performanceOfTheNightFighterId,
          builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ticketPrice => $composableBuilder(
      column: $table.ticketPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promotionBudgetSpent => $composableBuilder(
      column: $table.promotionBudgetSpent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attendance => $composableBuilder(
      column: $table.attendance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ppvBuys => $composableBuilder(
      column: $table.ppvBuys, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revenue => $composableBuilder(
      column: $table.revenue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expenses => $composableBuilder(
      column: $table.expenses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reputationChange => $composableBuilder(
      column: $table.reputationChange,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fightOfTheNightFightId => $composableBuilder(
      column: $table.fightOfTheNightFightId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get performanceOfTheNightFighterId =>
      $composableBuilder(
          column: $table.performanceOfTheNightFighterId,
          builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<int> get ticketPrice => $composableBuilder(
      column: $table.ticketPrice, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get promotionBudgetSpent => $composableBuilder(
      column: $table.promotionBudgetSpent, builder: (column) => column);

  GeneratedColumn<int> get attendance => $composableBuilder(
      column: $table.attendance, builder: (column) => column);

  GeneratedColumn<int> get ppvBuys =>
      $composableBuilder(column: $table.ppvBuys, builder: (column) => column);

  GeneratedColumn<int> get revenue =>
      $composableBuilder(column: $table.revenue, builder: (column) => column);

  GeneratedColumn<int> get expenses =>
      $composableBuilder(column: $table.expenses, builder: (column) => column);

  GeneratedColumn<int> get reputationChange => $composableBuilder(
      column: $table.reputationChange, builder: (column) => column);

  GeneratedColumn<String> get fightOfTheNightFightId => $composableBuilder(
      column: $table.fightOfTheNightFightId, builder: (column) => column);

  GeneratedColumn<String> get performanceOfTheNightFighterId =>
      $composableBuilder(
          column: $table.performanceOfTheNightFighterId,
          builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    EventRow,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
    EventRow,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> venue = const Value.absent(),
            Value<int> ticketPrice = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> promotionBudgetSpent = const Value.absent(),
            Value<int> attendance = const Value.absent(),
            Value<int> ppvBuys = const Value.absent(),
            Value<int> revenue = const Value.absent(),
            Value<int> expenses = const Value.absent(),
            Value<int> reputationChange = const Value.absent(),
            Value<String?> fightOfTheNightFightId = const Value.absent(),
            Value<String?> performanceOfTheNightFighterId =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            name: name,
            date: date,
            venue: venue,
            ticketPrice: ticketPrice,
            status: status,
            promotionBudgetSpent: promotionBudgetSpent,
            attendance: attendance,
            ppvBuys: ppvBuys,
            revenue: revenue,
            expenses: expenses,
            reputationChange: reputationChange,
            fightOfTheNightFightId: fightOfTheNightFightId,
            performanceOfTheNightFighterId: performanceOfTheNightFighterId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime date,
            required String venue,
            Value<int> ticketPrice = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> promotionBudgetSpent = const Value.absent(),
            Value<int> attendance = const Value.absent(),
            Value<int> ppvBuys = const Value.absent(),
            Value<int> revenue = const Value.absent(),
            Value<int> expenses = const Value.absent(),
            Value<int> reputationChange = const Value.absent(),
            Value<String?> fightOfTheNightFightId = const Value.absent(),
            Value<String?> performanceOfTheNightFighterId =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            name: name,
            date: date,
            venue: venue,
            ticketPrice: ticketPrice,
            status: status,
            promotionBudgetSpent: promotionBudgetSpent,
            attendance: attendance,
            ppvBuys: ppvBuys,
            revenue: revenue,
            expenses: expenses,
            reputationChange: reputationChange,
            fightOfTheNightFightId: fightOfTheNightFightId,
            performanceOfTheNightFighterId: performanceOfTheNightFighterId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    EventRow,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
    EventRow,
    PrefetchHooks Function()>;
typedef $$FightsTableCreateCompanionBuilder = FightsCompanion Function({
  required String id,
  required String eventId,
  required String fighterAId,
  required String fighterBId,
  required String weightClass,
  Value<String> titleFightType,
  Value<bool> isMainEvent,
  Value<bool> isCoMainEvent,
  Value<int> rounds,
  Value<int> cardOrder,
  Value<String?> resultWinnerId,
  Value<String?> resultMethod,
  Value<int?> resultRound,
  Value<int> resultTimeSeconds,
  Value<String> resultDecisionType,
  Value<String> resultMethodDetail,
  Value<int?> winnerPerformanceRating,
  Value<int?> loserPerformanceRating,
  Value<String?> resultFighterAInjury,
  Value<String?> resultFighterBInjury,
  Value<int> rowid,
});
typedef $$FightsTableUpdateCompanionBuilder = FightsCompanion Function({
  Value<String> id,
  Value<String> eventId,
  Value<String> fighterAId,
  Value<String> fighterBId,
  Value<String> weightClass,
  Value<String> titleFightType,
  Value<bool> isMainEvent,
  Value<bool> isCoMainEvent,
  Value<int> rounds,
  Value<int> cardOrder,
  Value<String?> resultWinnerId,
  Value<String?> resultMethod,
  Value<int?> resultRound,
  Value<int> resultTimeSeconds,
  Value<String> resultDecisionType,
  Value<String> resultMethodDetail,
  Value<int?> winnerPerformanceRating,
  Value<int?> loserPerformanceRating,
  Value<String?> resultFighterAInjury,
  Value<String?> resultFighterBInjury,
  Value<int> rowid,
});

class $$FightsTableFilterComposer
    extends Composer<_$AppDatabase, $FightsTable> {
  $$FightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fighterAId => $composableBuilder(
      column: $table.fighterAId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fighterBId => $composableBuilder(
      column: $table.fighterBId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleFightType => $composableBuilder(
      column: $table.titleFightType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMainEvent => $composableBuilder(
      column: $table.isMainEvent, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCoMainEvent => $composableBuilder(
      column: $table.isCoMainEvent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rounds => $composableBuilder(
      column: $table.rounds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardOrder => $composableBuilder(
      column: $table.cardOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultWinnerId => $composableBuilder(
      column: $table.resultWinnerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultMethod => $composableBuilder(
      column: $table.resultMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resultRound => $composableBuilder(
      column: $table.resultRound, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resultTimeSeconds => $composableBuilder(
      column: $table.resultTimeSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultDecisionType => $composableBuilder(
      column: $table.resultDecisionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultMethodDetail => $composableBuilder(
      column: $table.resultMethodDetail,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get winnerPerformanceRating => $composableBuilder(
      column: $table.winnerPerformanceRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get loserPerformanceRating => $composableBuilder(
      column: $table.loserPerformanceRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultFighterAInjury => $composableBuilder(
      column: $table.resultFighterAInjury,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultFighterBInjury => $composableBuilder(
      column: $table.resultFighterBInjury,
      builder: (column) => ColumnFilters(column));
}

class $$FightsTableOrderingComposer
    extends Composer<_$AppDatabase, $FightsTable> {
  $$FightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fighterAId => $composableBuilder(
      column: $table.fighterAId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fighterBId => $composableBuilder(
      column: $table.fighterBId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleFightType => $composableBuilder(
      column: $table.titleFightType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMainEvent => $composableBuilder(
      column: $table.isMainEvent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCoMainEvent => $composableBuilder(
      column: $table.isCoMainEvent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rounds => $composableBuilder(
      column: $table.rounds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardOrder => $composableBuilder(
      column: $table.cardOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultWinnerId => $composableBuilder(
      column: $table.resultWinnerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultMethod => $composableBuilder(
      column: $table.resultMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resultRound => $composableBuilder(
      column: $table.resultRound, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resultTimeSeconds => $composableBuilder(
      column: $table.resultTimeSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultDecisionType => $composableBuilder(
      column: $table.resultDecisionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultMethodDetail => $composableBuilder(
      column: $table.resultMethodDetail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get winnerPerformanceRating => $composableBuilder(
      column: $table.winnerPerformanceRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get loserPerformanceRating => $composableBuilder(
      column: $table.loserPerformanceRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultFighterAInjury => $composableBuilder(
      column: $table.resultFighterAInjury,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultFighterBInjury => $composableBuilder(
      column: $table.resultFighterBInjury,
      builder: (column) => ColumnOrderings(column));
}

class $$FightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FightsTable> {
  $$FightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get fighterAId => $composableBuilder(
      column: $table.fighterAId, builder: (column) => column);

  GeneratedColumn<String> get fighterBId => $composableBuilder(
      column: $table.fighterBId, builder: (column) => column);

  GeneratedColumn<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => column);

  GeneratedColumn<String> get titleFightType => $composableBuilder(
      column: $table.titleFightType, builder: (column) => column);

  GeneratedColumn<bool> get isMainEvent => $composableBuilder(
      column: $table.isMainEvent, builder: (column) => column);

  GeneratedColumn<bool> get isCoMainEvent => $composableBuilder(
      column: $table.isCoMainEvent, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get cardOrder =>
      $composableBuilder(column: $table.cardOrder, builder: (column) => column);

  GeneratedColumn<String> get resultWinnerId => $composableBuilder(
      column: $table.resultWinnerId, builder: (column) => column);

  GeneratedColumn<String> get resultMethod => $composableBuilder(
      column: $table.resultMethod, builder: (column) => column);

  GeneratedColumn<int> get resultRound => $composableBuilder(
      column: $table.resultRound, builder: (column) => column);

  GeneratedColumn<int> get resultTimeSeconds => $composableBuilder(
      column: $table.resultTimeSeconds, builder: (column) => column);

  GeneratedColumn<String> get resultDecisionType => $composableBuilder(
      column: $table.resultDecisionType, builder: (column) => column);

  GeneratedColumn<String> get resultMethodDetail => $composableBuilder(
      column: $table.resultMethodDetail, builder: (column) => column);

  GeneratedColumn<int> get winnerPerformanceRating => $composableBuilder(
      column: $table.winnerPerformanceRating, builder: (column) => column);

  GeneratedColumn<int> get loserPerformanceRating => $composableBuilder(
      column: $table.loserPerformanceRating, builder: (column) => column);

  GeneratedColumn<String> get resultFighterAInjury => $composableBuilder(
      column: $table.resultFighterAInjury, builder: (column) => column);

  GeneratedColumn<String> get resultFighterBInjury => $composableBuilder(
      column: $table.resultFighterBInjury, builder: (column) => column);
}

class $$FightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FightsTable,
    FightRow,
    $$FightsTableFilterComposer,
    $$FightsTableOrderingComposer,
    $$FightsTableAnnotationComposer,
    $$FightsTableCreateCompanionBuilder,
    $$FightsTableUpdateCompanionBuilder,
    (FightRow, BaseReferences<_$AppDatabase, $FightsTable, FightRow>),
    FightRow,
    PrefetchHooks Function()> {
  $$FightsTableTableManager(_$AppDatabase db, $FightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> fighterAId = const Value.absent(),
            Value<String> fighterBId = const Value.absent(),
            Value<String> weightClass = const Value.absent(),
            Value<String> titleFightType = const Value.absent(),
            Value<bool> isMainEvent = const Value.absent(),
            Value<bool> isCoMainEvent = const Value.absent(),
            Value<int> rounds = const Value.absent(),
            Value<int> cardOrder = const Value.absent(),
            Value<String?> resultWinnerId = const Value.absent(),
            Value<String?> resultMethod = const Value.absent(),
            Value<int?> resultRound = const Value.absent(),
            Value<int> resultTimeSeconds = const Value.absent(),
            Value<String> resultDecisionType = const Value.absent(),
            Value<String> resultMethodDetail = const Value.absent(),
            Value<int?> winnerPerformanceRating = const Value.absent(),
            Value<int?> loserPerformanceRating = const Value.absent(),
            Value<String?> resultFighterAInjury = const Value.absent(),
            Value<String?> resultFighterBInjury = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightsCompanion(
            id: id,
            eventId: eventId,
            fighterAId: fighterAId,
            fighterBId: fighterBId,
            weightClass: weightClass,
            titleFightType: titleFightType,
            isMainEvent: isMainEvent,
            isCoMainEvent: isCoMainEvent,
            rounds: rounds,
            cardOrder: cardOrder,
            resultWinnerId: resultWinnerId,
            resultMethod: resultMethod,
            resultRound: resultRound,
            resultTimeSeconds: resultTimeSeconds,
            resultDecisionType: resultDecisionType,
            resultMethodDetail: resultMethodDetail,
            winnerPerformanceRating: winnerPerformanceRating,
            loserPerformanceRating: loserPerformanceRating,
            resultFighterAInjury: resultFighterAInjury,
            resultFighterBInjury: resultFighterBInjury,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String eventId,
            required String fighterAId,
            required String fighterBId,
            required String weightClass,
            Value<String> titleFightType = const Value.absent(),
            Value<bool> isMainEvent = const Value.absent(),
            Value<bool> isCoMainEvent = const Value.absent(),
            Value<int> rounds = const Value.absent(),
            Value<int> cardOrder = const Value.absent(),
            Value<String?> resultWinnerId = const Value.absent(),
            Value<String?> resultMethod = const Value.absent(),
            Value<int?> resultRound = const Value.absent(),
            Value<int> resultTimeSeconds = const Value.absent(),
            Value<String> resultDecisionType = const Value.absent(),
            Value<String> resultMethodDetail = const Value.absent(),
            Value<int?> winnerPerformanceRating = const Value.absent(),
            Value<int?> loserPerformanceRating = const Value.absent(),
            Value<String?> resultFighterAInjury = const Value.absent(),
            Value<String?> resultFighterBInjury = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightsCompanion.insert(
            id: id,
            eventId: eventId,
            fighterAId: fighterAId,
            fighterBId: fighterBId,
            weightClass: weightClass,
            titleFightType: titleFightType,
            isMainEvent: isMainEvent,
            isCoMainEvent: isCoMainEvent,
            rounds: rounds,
            cardOrder: cardOrder,
            resultWinnerId: resultWinnerId,
            resultMethod: resultMethod,
            resultRound: resultRound,
            resultTimeSeconds: resultTimeSeconds,
            resultDecisionType: resultDecisionType,
            resultMethodDetail: resultMethodDetail,
            winnerPerformanceRating: winnerPerformanceRating,
            loserPerformanceRating: loserPerformanceRating,
            resultFighterAInjury: resultFighterAInjury,
            resultFighterBInjury: resultFighterBInjury,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FightsTable,
    FightRow,
    $$FightsTableFilterComposer,
    $$FightsTableOrderingComposer,
    $$FightsTableAnnotationComposer,
    $$FightsTableCreateCompanionBuilder,
    $$FightsTableUpdateCompanionBuilder,
    (FightRow, BaseReferences<_$AppDatabase, $FightsTable, FightRow>),
    FightRow,
    PrefetchHooks Function()>;
typedef $$RandomEventsTableCreateCompanionBuilder = RandomEventsCompanion
    Function({
  required String id,
  required String type,
  Value<String?> affectedFighterId,
  required String headline,
  required String description,
  required String choicesJson,
  Value<String?> chosenChoiceId,
  required DateTime occurredOn,
  Value<int> rowid,
});
typedef $$RandomEventsTableUpdateCompanionBuilder = RandomEventsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String?> affectedFighterId,
  Value<String> headline,
  Value<String> description,
  Value<String> choicesJson,
  Value<String?> chosenChoiceId,
  Value<DateTime> occurredOn,
  Value<int> rowid,
});

class $$RandomEventsTableFilterComposer
    extends Composer<_$AppDatabase, $RandomEventsTable> {
  $$RandomEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affectedFighterId => $composableBuilder(
      column: $table.affectedFighterId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headline => $composableBuilder(
      column: $table.headline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get choicesJson => $composableBuilder(
      column: $table.choicesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chosenChoiceId => $composableBuilder(
      column: $table.chosenChoiceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => ColumnFilters(column));
}

class $$RandomEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $RandomEventsTable> {
  $$RandomEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affectedFighterId => $composableBuilder(
      column: $table.affectedFighterId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headline => $composableBuilder(
      column: $table.headline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get choicesJson => $composableBuilder(
      column: $table.choicesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chosenChoiceId => $composableBuilder(
      column: $table.chosenChoiceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => ColumnOrderings(column));
}

class $$RandomEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RandomEventsTable> {
  $$RandomEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get affectedFighterId => $composableBuilder(
      column: $table.affectedFighterId, builder: (column) => column);

  GeneratedColumn<String> get headline =>
      $composableBuilder(column: $table.headline, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get choicesJson => $composableBuilder(
      column: $table.choicesJson, builder: (column) => column);

  GeneratedColumn<String> get chosenChoiceId => $composableBuilder(
      column: $table.chosenChoiceId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => column);
}

class $$RandomEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RandomEventsTable,
    RandomEventRow,
    $$RandomEventsTableFilterComposer,
    $$RandomEventsTableOrderingComposer,
    $$RandomEventsTableAnnotationComposer,
    $$RandomEventsTableCreateCompanionBuilder,
    $$RandomEventsTableUpdateCompanionBuilder,
    (
      RandomEventRow,
      BaseReferences<_$AppDatabase, $RandomEventsTable, RandomEventRow>
    ),
    RandomEventRow,
    PrefetchHooks Function()> {
  $$RandomEventsTableTableManager(_$AppDatabase db, $RandomEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RandomEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RandomEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RandomEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> affectedFighterId = const Value.absent(),
            Value<String> headline = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> choicesJson = const Value.absent(),
            Value<String?> chosenChoiceId = const Value.absent(),
            Value<DateTime> occurredOn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RandomEventsCompanion(
            id: id,
            type: type,
            affectedFighterId: affectedFighterId,
            headline: headline,
            description: description,
            choicesJson: choicesJson,
            chosenChoiceId: chosenChoiceId,
            occurredOn: occurredOn,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<String?> affectedFighterId = const Value.absent(),
            required String headline,
            required String description,
            required String choicesJson,
            Value<String?> chosenChoiceId = const Value.absent(),
            required DateTime occurredOn,
            Value<int> rowid = const Value.absent(),
          }) =>
              RandomEventsCompanion.insert(
            id: id,
            type: type,
            affectedFighterId: affectedFighterId,
            headline: headline,
            description: description,
            choicesJson: choicesJson,
            chosenChoiceId: chosenChoiceId,
            occurredOn: occurredOn,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RandomEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RandomEventsTable,
    RandomEventRow,
    $$RandomEventsTableFilterComposer,
    $$RandomEventsTableOrderingComposer,
    $$RandomEventsTableAnnotationComposer,
    $$RandomEventsTableCreateCompanionBuilder,
    $$RandomEventsTableUpdateCompanionBuilder,
    (
      RandomEventRow,
      BaseReferences<_$AppDatabase, $RandomEventsTable, RandomEventRow>
    ),
    RandomEventRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FightersTableTableManager get fighters =>
      $$FightersTableTableManager(_db, _db.fighters);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$FightsTableTableManager get fights =>
      $$FightsTableTableManager(_db, _db.fights);
  $$RandomEventsTableTableManager get randomEvents =>
      $$RandomEventsTableTableManager(_db, _db.randomEvents);
}
