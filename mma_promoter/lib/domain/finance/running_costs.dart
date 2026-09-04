import '../../data/models/models.dart';

/// What a promotion costs to keep the lights on, and how far into the
/// red it can go before that becomes a problem.
///
/// Before this, money only ever went up. Every tier opened profitable,
/// nothing was spent between events, and there was no floor to fall
/// through — which made venue choice, ticket pricing and roster size
/// carefully modelled decisions with no consequence attached to getting
/// them wrong. Overheads are what turn the finance model from a scoreboard
/// into a constraint: sitting still costs money, so a card has to be
/// worth putting on, and a roster you never book is a roster you are
/// paying for.
class RunningCosts {
  RunningCosts._();

  /// Staff, gym, offices — what the promotion costs before a single
  /// fighter is paid. Scales with the tier, because a national outfit is
  /// a bigger operation than a regional one.
  static int weeklyBaseFor(ReputationTier tier) {
    switch (tier) {
      case ReputationTier.local:
        return 250;
      case ReputationTier.regional:
        return 600;
      case ReputationTier.national:
        return 3500;
      case ReputationTier.international:
        return 22000;
    }
  }

  /// A retainer per signed fighter per week, as a share of their show
  /// money — a fighter on the books costs something even in a week they
  /// don't fight.
  ///
  /// Small on purpose. The roster is 160 strong on a default save, so
  /// anything but a light touch here would sink a new promotion before
  /// it ran its second card. What it is big enough to do is make an
  /// unused roster worth trimming.
  static const double weeklyRetainerRate = 0.0025;

  /// Total weekly outgoings for [tier] with [roster] under contract.
  static int weekly({
    required ReputationTier tier,
    required Iterable<Fighter> roster,
  }) {
    final retainers = roster.fold<double>(
      0,
      (sum, f) => sum + (f.contract?.showMoney ?? 0) * weeklyRetainerRate,
    );
    return weeklyBaseFor(tier) + retainers.round();
  }

  /// How deep into debt a promotion may go before the bank stops it
  /// booking anything new. Scaled to the tier's own starting cash, so
  /// the rope is proportional to the operation.
  static int debtCeilingFor(ReputationTier tier) =>
      -(tier.startingCash * 0.75).round();

  /// Whether [cashBalance] has fallen past the point where new events
  /// can't be booked.
  static bool isOverextended({
    required ReputationTier tier,
    required int cashBalance,
  }) =>
      cashBalance < debtCeilingFor(tier);
}
