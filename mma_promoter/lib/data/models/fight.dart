import 'enums.dart';

/// Outcome of a resolved fight.
class FightResult {
  final String winnerId; // empty string if draw/no-contest.
  final FightMethod method;
  final int round;
  final int winnerPerformanceRating; // 0-100, "fight of the night"-style score.
  final int loserPerformanceRating;

  const FightResult({
    required this.winnerId,
    required this.method,
    required this.round,
    required this.winnerPerformanceRating,
    required this.loserPerformanceRating,
  });

  bool get isDraw => method == FightMethod.drawOrNc;
}

/// A single booked matchup, optionally already resolved.
class Fight {
  final String id;
  final String eventId;
  final String fighterAId;
  final String fighterBId;
  final WeightClass weightClass;
  final bool isTitleFight;
  final bool isMainEvent;
  final int cardOrder; // 0 = opener, higher = later on the card.
  final FightResult? result;

  const Fight({
    required this.id,
    required this.eventId,
    required this.fighterAId,
    required this.fighterBId,
    required this.weightClass,
    required this.isTitleFight,
    required this.isMainEvent,
    required this.cardOrder,
    this.result,
  });

  bool get isResolved => result != null;

  Fight copyWith({
    String? id,
    String? eventId,
    String? fighterAId,
    String? fighterBId,
    WeightClass? weightClass,
    bool? isTitleFight,
    bool? isMainEvent,
    int? cardOrder,
    FightResult? result,
  }) {
    return Fight(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      fighterAId: fighterAId ?? this.fighterAId,
      fighterBId: fighterBId ?? this.fighterBId,
      weightClass: weightClass ?? this.weightClass,
      isTitleFight: isTitleFight ?? this.isTitleFight,
      isMainEvent: isMainEvent ?? this.isMainEvent,
      cardOrder: cardOrder ?? this.cardOrder,
      result: result ?? this.result,
    );
  }
}
