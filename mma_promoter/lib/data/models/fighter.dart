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

  /// Physical freshness, 0-100. Falls with hard fights and recovers with
  /// rest — distinct from [injuryStatus], since a fighter can be
  /// uninjured and still worn down.
  final int condition;

  /// Game week of their last bout for the org, or null if they haven't
  /// fought here yet.
  final int? lastFoughtWeek;

  /// Every division whose undisputed belt this fighter currently holds.
  /// A set rather than a flag because a fighter can move up (or down) and
  /// win a second belt without giving up the first — that's what makes a
  /// double champ possible at all.
  final Set<WeightClass> belts;

  /// Interim belts held, tracked separately: an interim champion doesn't
  /// displace the undisputed one.
  final Set<WeightClass> interimBelts;

  /// Absolute game week a suspension (a failed drug test, say) runs
  /// through. Null when the fighter is free to compete. They can't be
  /// booked until [Organization.currentWeek] passes it.
  final int? suspendedUntilWeek;

  /// The game week this fighter first appeared in the world.
  ///
  /// Everyone who came with the save has week 1; the monthly intake is
  /// stamped with the week it arrived. Exists so "who is new" is a fact
  /// rather than a guess — with a talent pool well past a thousand, the
  /// question a matchmaker actually asks is who has turned up since they
  /// last looked.
  final int arrivedWeek;

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
    this.condition = 100,
    this.lastFoughtWeek,
    this.belts = const {},
    this.interimBelts = const {},
    this.suspendedUntilWeek,
    this.arrivedWeek = 1,
  });

  bool get isSigned => contract != null;

  /// Serving a suspension as of [currentWeek].
  bool isSuspendedOn(int currentWeek) =>
      suspendedUntilWeek != null && suspendedUntilWeek! > currentWeek;

  /// Whether they're fit to fight — ignores suspensions, which are a
  /// booking restriction rather than a physical one. Call
  /// [isBookableOn] when the game week is known.
  bool get isAvailableToFight => injuryStatus == InjuryStatus.healthy && !retired;

  /// Fit *and* eligible: healthy, not retired, not serving a ban.
  bool isBookableOn(int currentWeek) =>
      isAvailableToFight && !isSuspendedOn(currentWeek);

  /// Holds any undisputed belt.
  bool get isChampion => belts.isNotEmpty;

  /// Holds any interim belt.
  bool get isInterimChampion => interimBelts.isNotEmpty;

  /// Simultaneous holder of two or more undisputed belts.
  bool get isDoubleChampion => belts.length >= 2;

  bool championOf(WeightClass division) => belts.contains(division);

  bool interimChampionOf(WeightClass division) =>
      interimBelts.contains(division);

  /// Belt-holder in [division] under either banner — what the rankings
  /// list needs to decide who sits above #1.
  bool holdsAnyBeltIn(WeightClass division) =>
      championOf(division) || interimChampionOf(division);

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
    /// Set to give a fighter no portrait at all. Without it the `??`
    /// below would read a deliberate null as "leave it alone", and the
    /// editor could add a face but never take one away.
    bool clearHeadshotAsset = false,
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
    int? condition,
    int? lastFoughtWeek,
    Set<WeightClass>? belts,
    Set<WeightClass>? interimBelts,
    int? suspendedUntilWeek,
    int? arrivedWeek,
    bool clearSuspension = false,
  }) {
    return Fighter(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      headshotAsset:
          clearHeadshotAsset ? null : (headshotAsset ?? this.headshotAsset),
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
      condition: condition ?? this.condition,
      lastFoughtWeek: lastFoughtWeek ?? this.lastFoughtWeek,
      belts: belts ?? this.belts,
      interimBelts: interimBelts ?? this.interimBelts,
      suspendedUntilWeek: clearSuspension
          ? null
          : (suspendedUntilWeek ?? this.suspendedUntilWeek),
      arrivedWeek: arrivedWeek ?? this.arrivedWeek,
    );
  }
}
