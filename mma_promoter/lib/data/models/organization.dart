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

  /// The absolute week number the talent pool last got its ~10-fighter
  /// refresh. Advances whenever [currentWeek] crosses into a new "month"
  /// (every 4 weeks).
  final int lastTalentRefreshWeek;

  /// The game week everyone on the books last had a birthday.
  ///
  /// Fighters used to have an age and never grow into it: the number was
  /// stamped at generation and never moved again, which quietly made the
  /// retirement engine's age rule dead code for anyone not generated at
  /// 34 or over. A twenty-two-year-old prospect stayed twenty-two for a
  /// twelve-year career and a talent pool of 1,840 never turned over.
  final int lastAgedWeek;

  /// The game's own clock — an absolute week count starting at 1. This is
  /// the single source of truth for "now"; nothing in the game reads the
  /// real wall clock. See [GameCalendar].
  final int currentWeek;

  /// When true, a fighter whose contract runs out after a fight is
  /// re-signed automatically at whatever they're now worth, rather than
  /// walking as a free agent.
  ///
  /// **On** by default. It was off, and off it quietly ended the game:
  /// every fighter leaves when their deal runs out, nothing signs
  /// replacements, and a measured three-year run went 160 signed ->
  /// 94 -> 24 -> unable to fill a card by month 29. Long before that the
  /// shrinking roster forced the same expensive twenty onto every show,
  /// so purses ran from \$52k a card to \$125k while the gate stood
  /// still and a promotion in profit turned \$56k-a-show loss-making.
  /// A default that deletes your roster over two seasons is a trap, not
  /// a difficulty setting — so the switch stays, for players who want to
  /// work their own contracts, but it now starts in the position that
  /// leaves you with a promotion.
  final bool autoResignFighters;

  const Organization({
    required this.id,
    required this.name,
    required this.reputationTier,
    required this.reputationPoints,
    required this.cashBalance,
    required this.fanbaseSize,
    required this.homeRegion,
    required this.promotionBudget,
    this.lastTalentRefreshWeek = 1,
    this.lastAgedWeek = 1,
    this.currentWeek = 1,
    this.autoResignFighters = true,
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
    int? lastTalentRefreshWeek,
    int? lastAgedWeek,
    int? currentWeek,
    bool? autoResignFighters,
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
      lastTalentRefreshWeek: lastTalentRefreshWeek ?? this.lastTalentRefreshWeek,
      lastAgedWeek: lastAgedWeek ?? this.lastAgedWeek,
      currentWeek: currentWeek ?? this.currentWeek,
      autoResignFighters: autoResignFighters ?? this.autoResignFighters,
    );
  }
}
