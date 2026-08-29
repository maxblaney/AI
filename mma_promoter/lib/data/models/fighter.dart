import 'enums.dart';
import 'fighter_stats.dart';
import 'contract.dart';

/// A fighter available in the talent pool or signed to the player's roster.
class Fighter {
  final String id;
  final String name;
  final int age;
  final String nationality;

  /// Asset path for this fighter's headshot art, or null to fall back to
  /// the initial-letter avatar. Rolled at generation time from
  /// [nationality] via `rollHeadshot` — most nationalities have no art
  /// yet and stay null.
  final String? headshotAsset;
  final WeightClass weightClass;
  final int heightInches;
  final int weightLbs; // walk-around weight, a bit above the class limit.

  /// Arm span in inches. Usually within a couple of inches of height; a
  /// big reach advantage is a real edge at striking range. Stored as 0
  /// for fighters created before reach existed — read [reach] instead,
  /// which falls back to height.
  final int reachInches;
  final FightRecord record;
  final FightingStats fightingStats;
  final PhysicalStats physicalStats;
  final MentalStats mentalStats;
  final FightingStyle style;
  final Tendencies tendencies;

  /// Ceiling on [overall] — how good this fighter could become. Nudges up
  /// on long win streaks, down on long losing streaks.
  final int potential;

  final int popularity; // 0-100, drives ticket/PPV draw.
  final int morale; // 0-100, drifts with events, affects performance.
  final InjuryStatus injuryStatus;

  /// Absolute game week ([GameCalendar]) this fighter's current injury
  /// clears on its own. Null when healthy or the injury has no countdown.
  final int? injuryClearsAtWeek;
  final int winStreak;
  final int lossStreak;
  final Contract? contract; // null = unsigned / in the free talent pool.

  /// Elo rating within their weight class, starting at 1500. Only counts
  /// toward the Rankings screen once [isRanked] is true.
  final int eloRating;
  final bool isRanked;

  final bool retired;
  final String? retirementReason;
  final int fightOfTheNightCount;
  final int performanceOfTheNightCount;

  /// Holds their division's belt. Won by taking a championship fight,
  /// lost by dropping one.
  final bool isChampion;

  /// Holds an interim belt in their division — tracked separately, since
  /// it doesn't displace the undisputed champion.
  final bool isInterimChampion;

  const Fighter({
    required this.id,
    required this.name,
    required this.age,
    required this.nationality,
    this.headshotAsset,
    required this.weightClass,
    required this.heightInches,
    required this.weightLbs,
    required this.record,
    this.reachInches = 0,
    required this.fightingStats,
    required this.physicalStats,
    required this.mentalStats,
    required this.style,
    required this.tendencies,
    required this.potential,
    required this.popularity,
    required this.morale,
    required this.injuryStatus,
    this.injuryClearsAtWeek,
    required this.winStreak,
    this.lossStreak = 0,
    this.contract,
    this.eloRating = 1500,
    this.isRanked = false,
    this.retired = false,
    this.retirementReason,
    this.fightOfTheNightCount = 0,
    this.performanceOfTheNightCount = 0,
    this.isChampion = false,
    this.isInterimChampion = false,
  });

  bool get isSigned => contract != null;
  bool get isAvailableToFight => injuryStatus == InjuryStatus.healthy && !retired;

  /// Single-number overview across all three ability categories, used for
  /// matchmaking/scouting display and as the baseline for [potential].
  double get overall =>
      (fightingStats.average + physicalStats.average + mentalStats.average) / 3;

  String get heightDisplay {
    final feet = heightInches ~/ 12;
    final inches = heightInches % 12;
    return '$feet\'$inches"';
  }

  /// Reach to actually use in the sim — falls back to height for fighters
  /// saved before reach was tracked.
  int get reach => reachInches > 0 ? reachInches : heightInches;

  String get reachDisplay => '$reach"';

  Fighter copyWith({
    String? id,
    String? name,
    int? age,
    String? nationality,
    String? headshotAsset,
    WeightClass? weightClass,
    int? heightInches,
    int? weightLbs,
    int? reachInches,
    FightRecord? record,
    FightingStats? fightingStats,
    PhysicalStats? physicalStats,
    MentalStats? mentalStats,
    FightingStyle? style,
    Tendencies? tendencies,
    int? potential,
    int? popularity,
    int? morale,
    InjuryStatus? injuryStatus,
    int? injuryClearsAtWeek,
    bool clearInjuryClearsAtWeek = false,
    int? winStreak,
    int? lossStreak,
    Contract? contract,
    bool clearContract = false,
    int? eloRating,
    bool? isRanked,
    bool? retired,
    String? retirementReason,
    int? fightOfTheNightCount,
    int? performanceOfTheNightCount,
    bool? isChampion,
    bool? isInterimChampion,
  }) {
    return Fighter(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      headshotAsset: headshotAsset ?? this.headshotAsset,
      weightClass: weightClass ?? this.weightClass,
      heightInches: heightInches ?? this.heightInches,
      weightLbs: weightLbs ?? this.weightLbs,
      reachInches: reachInches ?? this.reachInches,
      record: record ?? this.record,
      fightingStats: fightingStats ?? this.fightingStats,
      physicalStats: physicalStats ?? this.physicalStats,
      mentalStats: mentalStats ?? this.mentalStats,
      style: style ?? this.style,
      tendencies: tendencies ?? this.tendencies,
      potential: potential ?? this.potential,
      popularity: popularity ?? this.popularity,
      morale: morale ?? this.morale,
      injuryStatus: injuryStatus ?? this.injuryStatus,
      injuryClearsAtWeek: clearInjuryClearsAtWeek
          ? null
          : (injuryClearsAtWeek ?? this.injuryClearsAtWeek),
      winStreak: winStreak ?? this.winStreak,
      lossStreak: lossStreak ?? this.lossStreak,
      contract: clearContract ? null : (contract ?? this.contract),
      eloRating: eloRating ?? this.eloRating,
      isRanked: isRanked ?? this.isRanked,
      retired: retired ?? this.retired,
      retirementReason: retirementReason ?? this.retirementReason,
      fightOfTheNightCount: fightOfTheNightCount ?? this.fightOfTheNightCount,
      performanceOfTheNightCount:
          performanceOfTheNightCount ?? this.performanceOfTheNightCount,
      isChampion: isChampion ?? this.isChampion,
      isInterimChampion: isInterimChampion ?? this.isInterimChampion,
    );
  }
}
