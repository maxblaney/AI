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

  const Organization({
    required this.id,
    required this.name,
    required this.reputationTier,
    required this.reputationPoints,
    required this.cashBalance,
    required this.fanbaseSize,
    required this.homeRegion,
    required this.promotionBudget,
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
    );
  }
}
