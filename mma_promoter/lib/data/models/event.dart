import '../../domain/finance/event_finance_calculator.dart';
import 'enums.dart';

enum EventStatus { scheduled, completed }

/// A promoted show: a date, a venue, and a card of fights.
class MmaEvent {
  final String id;
  final String name;
  final DateTime date;
  final Venue venue;
  final int ticketPrice;

  /// Game week the card was confirmed. The gap to the event's own week is
  /// the camp length the fighters got, which is what sharpness reads.
  final int bookedAtWeek;
  final EventStatus status;
  final int promotionBudgetSpent;
  final int attendance;
  final int ppvBuys;
  final int revenue;
  final int expenses;
  final int reputationChange;
  final String? fightOfTheNightFightId;
  final String? performanceOfTheNightFighterId;

  /// Where this night's crowd and money came from, as the finance
  /// calculator's own working. Stored rather than recomputed: the
  /// fighters it was derived from keep fighting, so their popularity and
  /// purses drift, and a breakdown recomputed a year later would not be
  /// the one that produced these numbers. Null for events that ran
  /// before the breakdown existed.
  final EventFinanceBreakdown? financeBreakdown;

  const MmaEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.venue,
    required this.ticketPrice,
    this.bookedAtWeek = 1,
    this.status = EventStatus.scheduled,
    this.promotionBudgetSpent = 0,
    this.attendance = 0,
    this.ppvBuys = 0,
    this.revenue = 0,
    this.expenses = 0,
    this.reputationChange = 0,
    this.fightOfTheNightFightId,
    this.performanceOfTheNightFighterId,
    this.financeBreakdown,
  });

  bool get isCompleted => status == EventStatus.completed;
  int get netProfit => revenue - expenses;

  MmaEvent copyWith({
    String? id,
    String? name,
    DateTime? date,
    Venue? venue,
    int? ticketPrice,
    int? bookedAtWeek,
    EventStatus? status,
    int? promotionBudgetSpent,
    int? attendance,
    int? ppvBuys,
    int? revenue,
    int? expenses,
    int? reputationChange,
    String? fightOfTheNightFightId,
    String? performanceOfTheNightFighterId,
    EventFinanceBreakdown? financeBreakdown,
  }) {
    return MmaEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      bookedAtWeek: bookedAtWeek ?? this.bookedAtWeek,
      status: status ?? this.status,
      promotionBudgetSpent: promotionBudgetSpent ?? this.promotionBudgetSpent,
      attendance: attendance ?? this.attendance,
      ppvBuys: ppvBuys ?? this.ppvBuys,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      reputationChange: reputationChange ?? this.reputationChange,
      fightOfTheNightFightId:
          fightOfTheNightFightId ?? this.fightOfTheNightFightId,
      performanceOfTheNightFighterId: performanceOfTheNightFighterId ??
          this.performanceOfTheNightFighterId,
      financeBreakdown: financeBreakdown ?? this.financeBreakdown,
    );
  }
}
