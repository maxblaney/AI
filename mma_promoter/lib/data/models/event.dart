import 'enums.dart';

enum EventStatus { scheduled, completed }

/// A promoted show: a date, a venue, and a card of fights.
class MmaEvent {
  final String id;
  final String name;
  final DateTime date;
  final VenueTier venueTier;
  final EventStatus status;
  final int promotionBudgetSpent;
  final int attendance;
  final int ppvBuys;
  final int revenue;
  final int expenses;
  final int reputationChange;

  const MmaEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.venueTier,
    this.status = EventStatus.scheduled,
    this.promotionBudgetSpent = 0,
    this.attendance = 0,
    this.ppvBuys = 0,
    this.revenue = 0,
    this.expenses = 0,
    this.reputationChange = 0,
  });

  bool get isCompleted => status == EventStatus.completed;
  int get netProfit => revenue - expenses;

  MmaEvent copyWith({
    String? id,
    String? name,
    DateTime? date,
    VenueTier? venueTier,
    EventStatus? status,
    int? promotionBudgetSpent,
    int? attendance,
    int? ppvBuys,
    int? revenue,
    int? expenses,
    int? reputationChange,
  }) {
    return MmaEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      venueTier: venueTier ?? this.venueTier,
      status: status ?? this.status,
      promotionBudgetSpent: promotionBudgetSpent ?? this.promotionBudgetSpent,
      attendance: attendance ?? this.attendance,
      ppvBuys: ppvBuys ?? this.ppvBuys,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      reputationChange: reputationChange ?? this.reputationChange,
    );
  }
}
