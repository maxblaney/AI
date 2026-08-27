import 'enums.dart';

/// One round's worth of scoring — how much of that round fighter A won,
/// from 0 (fighter B swept it) to 1 (fighter A swept it). Powers the
/// round-by-round blue/red breakdown view.
class RoundScore {
  final int round;
  final double fighterAShare;

  const RoundScore({required this.round, required this.fighterAShare});
}

/// Outcome of a resolved fight.
class FightResult {
  final String winnerId; // empty string if draw/no-contest.
  final FightMethod method;
  final int round;
  final int winnerPerformanceRating; // 0-100, "fight of the night"-style score.
  final int loserPerformanceRating;
  final InjuryStatus fighterAInjury;
  final InjuryStatus fighterBInjury;

  /// One entry per round actually fought (fewer than the fight's scheduled
  /// [Fight.rounds] if it ended in a finish). Not persisted — only
  /// available on a freshly-simulated result, not after reloading from
  /// storage.
  final List<RoundScore> roundScores;

  const FightResult({
    required this.winnerId,
    required this.method,
    required this.round,
    required this.winnerPerformanceRating,
    required this.loserPerformanceRating,
    this.fighterAInjury = InjuryStatus.healthy,
    this.fighterBInjury = InjuryStatus.healthy,
    this.roundScores = const [],
  });

  bool get isDraw => method == FightMethod.drawOrNc;
}

/// A single booked matchup, optionally already resolved.
class Fight {
  /// Fights with `cardOrder` below this are the "main card"; the rest are
  /// prelims.
  static const int mainCardSize = 5;

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
