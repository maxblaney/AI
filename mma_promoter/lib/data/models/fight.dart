import 'enums.dart';

/// One instant's momentum reading within a round — how much of *that
/// moment* fighter A is winning, from 0 (fighter B) to 1 (fighter A).
/// The resolver emits one per exchange, so the round-by-round breakdown
/// genuinely fluctuates through a round instead of showing one static bar.
class MomentumTick {
  final int round;

  /// Seconds elapsed within [round] when this tick was sampled.
  final int timeSeconds;
  final double fighterAShare;

  const MomentumTick({
    required this.round,
    required this.fighterAShare,
    this.timeSeconds = 0,
  });
}

/// A single play-by-play line — "Round 2, 3:41 — Silva drops Okafor with a
/// right hand". The live breakdown screen streams these as commentary.
class FightEvent {
  final int round;
  final int timeSeconds; // elapsed within the round.
  final FightEventType type;
  final String text;

  /// Which corner the line is *about*, so the UI can colour it. Null for
  /// neutral lines like round starts.
  final String? fighterId;

  const FightEvent({
    required this.round,
    required this.timeSeconds,
    required this.type,
    required this.text,
    this.fighterId,
  });

  /// Fight clocks count *down* in MMA, so 20s elapsed reads as "4:40".
  String clockDisplay(int roundLengthSeconds) {
    final remaining = (roundLengthSeconds - timeSeconds).clamp(0, roundLengthSeconds);
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Accumulated stats for one fighter over a whole fight — the box score.
class FightStatline {
  final int significantStrikesLanded;
  final int significantStrikesAttempted;
  final int headStrikes;
  final int bodyStrikes;
  final int legStrikes;
  final int takedownsLanded;
  final int takedownsAttempted;
  final int submissionAttempts;
  final int knockdowns;
  final int controlSeconds;
  final int reversals;

  const FightStatline({
    this.significantStrikesLanded = 0,
    this.significantStrikesAttempted = 0,
    this.headStrikes = 0,
    this.bodyStrikes = 0,
    this.legStrikes = 0,
    this.takedownsLanded = 0,
    this.takedownsAttempted = 0,
    this.submissionAttempts = 0,
    this.knockdowns = 0,
    this.controlSeconds = 0,
    this.reversals = 0,
  });

  int get strikingAccuracyPercent => significantStrikesAttempted == 0
      ? 0
      : (significantStrikesLanded / significantStrikesAttempted * 100).round();

  int get takedownAccuracyPercent => takedownsAttempted == 0
      ? 0
      : (takedownsLanded / takedownsAttempted * 100).round();

  String get controlTimeDisplay {
    final minutes = controlSeconds ~/ 60;
    final seconds = controlSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// One judge's card for one round. Standard MMA scoring: the round winner
/// gets 10, the loser 9 (or 8 in a dominant round).
class RoundScore {
  final int round;
  final int fighterAScore;
  final int fighterBScore;

  const RoundScore({
    required this.round,
    required this.fighterAScore,
    required this.fighterBScore,
  });
}

/// A single judge's full card.
class Scorecard {
  final String judgeName;
  final List<RoundScore> rounds;

  const Scorecard({required this.judgeName, required this.rounds});

  int get fighterATotal =>
      rounds.fold(0, (sum, r) => sum + r.fighterAScore);
  int get fighterBTotal =>
      rounds.fold(0, (sum, r) => sum + r.fighterBScore);

  /// 1 = fighter A, -1 = fighter B, 0 = even card.
  int get winner {
    if (fighterATotal > fighterBTotal) return 1;
    if (fighterBTotal > fighterATotal) return -1;
    return 0;
  }

  String get display => '$fighterATotal-$fighterBTotal';
}

/// Outcome of a resolved fight.
class FightResult {
  final String winnerId; // empty string if draw/no-contest.
  final FightMethod method;
  final int round;

  /// Seconds into [round] that the fight ended. For a decision this is the
  /// full round length.
  final int timeSeconds;

  /// Only meaningful when [method] is [FightMethod.decision].
  final DecisionType decisionType;

  /// Free-text detail — "Rear-Naked Choke", "Right Hand", "Head Kick".
  final String methodDetail;

  final int winnerPerformanceRating; // 0-100, "fight of the night"-style score.
  final int loserPerformanceRating;
  final InjuryStatus fighterAInjury;
  final InjuryStatus fighterBInjury;

  /// One tick per exchange actually fought. Not persisted — only available
  /// on a freshly-simulated result, not after reloading from storage.
  final List<MomentumTick> momentumTicks;

  /// Play-by-play commentary. Not persisted (see [momentumTicks]).
  final List<FightEvent> events;

  /// Box score for each fighter. Not persisted.
  final FightStatline statsA;
  final FightStatline statsB;

  /// The three judges' cards, empty unless the fight went to a decision.
  /// Not persisted.
  final List<Scorecard> scorecards;

  const FightResult({
    required this.winnerId,
    required this.method,
    required this.round,
    required this.winnerPerformanceRating,
    required this.loserPerformanceRating,
    this.timeSeconds = 300,
    this.decisionType = DecisionType.none,
    this.methodDetail = '',
    this.fighterAInjury = InjuryStatus.healthy,
    this.fighterBInjury = InjuryStatus.healthy,
    this.momentumTicks = const [],
    this.events = const [],
    this.statsA = const FightStatline(),
    this.statsB = const FightStatline(),
    this.scorecards = const [],
  });

  bool get isDraw => method == FightMethod.drawOrNc;

  /// "KO/TKO (Right Hand)" / "Decision (Unanimous)" / "Submission (Armbar)".
  String get methodDisplay {
    if (method == FightMethod.decision && decisionType != DecisionType.none) {
      return '${decisionType.label} Decision';
    }
    if (methodDetail.isEmpty) return method.label;
    return '${method.label} ($methodDetail)';
  }

  String get timeDisplay {
    final minutes = timeSeconds ~/ 60;
    final seconds = timeSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// A single booked matchup, optionally already resolved.
class Fight {
  /// Fights with `cardOrder` below this are the "main card"; the rest are
  /// prelims.
  static const int mainCardSize = 5;

  /// Length of one round, in seconds.
  static const int roundLengthSeconds = 300;

  final String id;
  final String eventId;
  final String fighterAId;
  final String fighterBId;
  final WeightClass weightClass;
  final TitleFightType titleFightType;
  final bool isMainEvent;
  final bool isCoMainEvent;
  final int rounds; // 3 or 5
  final int cardOrder; // 0 = first main card bout, higher = later.
  final FightResult? result;

  const Fight({
    required this.id,
    required this.eventId,
    required this.fighterAId,
    required this.fighterBId,
    required this.weightClass,
    required this.cardOrder,
    this.titleFightType = TitleFightType.none,
    this.isMainEvent = false,
    this.isCoMainEvent = false,
    this.rounds = 3,
    this.result,
  });

  bool get isResolved => result != null;
  bool get isMainCard => cardOrder < mainCardSize;
  bool get isTitleFight => titleFightType != TitleFightType.none;

  Fight copyWith({
    String? id,
    String? eventId,
    String? fighterAId,
    String? fighterBId,
    WeightClass? weightClass,
    TitleFightType? titleFightType,
    bool? isMainEvent,
    bool? isCoMainEvent,
    int? rounds,
    int? cardOrder,
    FightResult? result,
  }) {
    return Fight(
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
      result: result ?? this.result,
    );
  }
}
