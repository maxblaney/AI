import '../../data/models/models.dart';

/// How heavily fighter pay is leaning on what the shows actually take.
enum PayrollPressure {
  /// The shows comfortably cover what the roster costs.
  comfortable,

  /// Covering it, but a bad night or one big signing would not be.
  tight,

  /// Fighters are being paid more than the shows bring in.
  overcommitted,
}

extension PayrollPressureInfo on PayrollPressure {
  String get label => switch (this) {
        PayrollPressure.comfortable => 'Comfortable',
        PayrollPressure.tight => 'Tight',
        PayrollPressure.overcommitted => 'Overcommitted',
      };

  bool get needsAttention => this != PayrollPressure.comfortable;
}

/// What share of a promotion's takings is going to its fighters.
///
/// The number that predicts a cash crisis, and the one thing the game
/// never showed. Measured across a career: a promotion sat around 36-44%
/// for six comfortable years, then upgraded its roster and went to
/// **145%** in a single year — paying out half again what its shows took
/// — before recovering to 57% as revenue caught up. Every part of that
/// was invisible until the bank cut it off.
///
/// It is a share rather than an absolute because absolutes mean nothing
/// across four tiers: \$1.8M of purses is ruinous at Regional and cheap
/// at International.
class PayrollHealth {
  /// Purses paid across the sampled shows.
  final int purses;

  /// What those same shows took.
  final int revenue;

  /// How many shows the reading is drawn from.
  final int shows;

  const PayrollHealth({
    required this.purses,
    required this.revenue,
    required this.shows,
  });

  /// Fighter pay as a share of takings. 1.0 means the gate paid the
  /// fighters and nothing else — not the venue, not the staff, nothing.
  double get share => revenue <= 0 ? 0 : purses / revenue;

  int get sharePercent => (share * 100).round();

  /// Average takings per show, which is what a single signing should be
  /// measured against.
  int get revenuePerShow => shows == 0 ? 0 : revenue ~/ shows;

  /// Below this a promotion has room to grow into.
  static const double comfortableBelow = 0.55;

  /// Above this it is paying out more than it takes.
  static const double overcommittedAbove = 0.85;

  PayrollPressure get pressure {
    if (share >= overcommittedAbove) return PayrollPressure.overcommitted;
    if (share >= comfortableBelow) return PayrollPressure.tight;
    return PayrollPressure.comfortable;
  }

  /// Reads the last [sample] completed shows.
  ///
  /// Recent rather than all-time: what matters is what the promotion is
  /// paying *now*, and a run of cheap early cards would otherwise hide a
  /// roster that has since priced itself out. Null until there is a show
  /// to read — a promotion that hasn't run one has no ratio to report.
  static PayrollHealth? fromRecentEvents(
    Iterable<MmaEvent> completed, {
    int sample = 6,
  }) {
    final recent = completed
        .where((e) => e.isCompleted && e.financeBreakdown != null)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final window = recent.take(sample).toList();
    if (window.isEmpty) return null;

    return PayrollHealth(
      purses: window.fold(0, (sum, e) => sum + e.financeBreakdown!.purses),
      revenue: window.fold(0, (sum, e) => sum + e.revenue),
      shows: window.length,
    );
  }

  /// What one more fighter at [perFight] would represent against a
  /// typical night's takings.
  ///
  /// Asked at the moment of signing, where the geometric pay curve does
  /// its damage: a roster's payroll is dominated by its best few, so
  /// three good signings can multiply it while the mean barely moves.
  double shareOfOneShow(int perFight) =>
      revenuePerShow <= 0 ? 0 : perFight / revenuePerShow;
}
