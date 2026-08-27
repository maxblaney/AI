import 'enums.dart';

/// The player's MMA promotion.
class Organization {
  final String id;
  final String name;
  final ReputationTier reputationTier;
  final int reputationPoints; // progress within the current tier.
  final int cashBalance;
  final int fanbaseSize;
  final String homeRegion;
  final int promotionBudget; // spendable resource for hype actions.

  /// The last calendar month the talent pool got its ~10-fighter refresh.
  /// Advances whenever a simulated event's date crosses into a new month.
  final DateTime lastTalentRefresh;

  const Organization({
    required this.id,
    required this.name,
    required this.reputationTier,
    required this.reputationPoints,
    required this.cashBalance,
    required this.fanbaseSize,
    required this.homeRegion,
    required this.promotionBudget,
    required this.lastTalentRefresh,
  });

  Organization copyWith({
    String? id,
    String? name,
    ReputationTier? reputationTier,
    int? reputationPoints,
    int? cashBalance,
    int? fanbaseSize,
    String? homeRegion,
    int? promotionBudget,
    DateTime? lastTalentRefresh,
  }) {
    return Organization(
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
  }
}
