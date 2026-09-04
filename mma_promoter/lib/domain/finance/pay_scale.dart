import 'dart:math';

/// Suggested contract terms for a fighter: guaranteed show money plus a
/// win bonus only paid out if they win the fight. `total` is what they
/// actually earn on a win (show + winBonus); a loss or draw pays only
/// [showMoney].
class SuggestedPay {
  final int showMoney;
  final int winBonus;

  const SuggestedPay({required this.showMoney, required this.winBonus});

  int get total => showMoney + winBonus;
}

/// Turns a fighter's skill into a market-rate contract offer. Pure Dart so
/// it's independently testable from the signing UI.
///
/// The shape is a fighter's [overall] setting a baseline "before
/// popularity" purse — journeymen fight for four figures, true legends
/// command six — and [popularity] then scaling that baseline up, since a
/// mediocre fighter with a big following draws money a similarly-skilled
/// unknown doesn't. The baseline is a piecewise-linear curve through a
/// handful of anchor points (overall -> dollars); anything between two
/// anchors is interpolated so pay never jumps at a division boundary.
class PayScale {
  PayScale._();

  /// (overall, base pay at 0 popularity) control points, strictly
  /// increasing in both fields.
  ///
  /// The curve climbs geometrically — roughly a third more per five
  /// points of overall through the middle, then far steeper past 75 where
  /// genuine stars live. What it deliberately no longer has is a **cliff**
  /// at a single point of overall: the old table jumped 55 -> 56 by
  /// double, 65 -> 66 by 60%, and 75 -> 76 by more than four times, which
  /// made one point of overall worth more than the ten before it and put
  /// a wall between a regional promotion and the fighters just above its
  /// budget. A 60-overall card used to lose money that a 55-overall card
  /// made, for no reason a player could see.
  static const List<(double, double)> _anchors = [
    (25, 800),
    (45, 1100),
    (55, 1600),
    (65, 3200),
    (75, 9000),
    (85, 100000),
    (90, 180000),
    (95, 300000),
    (99, 450000),
  ];

  /// Interpolates between anchors **geometrically**, not linearly.
  ///
  /// Fighter pay spans three orders of magnitude, and a straight line
  /// between two anchors that far apart has a slope that jumps at every
  /// anchor — so a single point of overall could cost more than the ten
  /// before it, purely as an artefact of where a control point happened
  /// to sit. In log space each segment grows by a constant *ratio* per
  /// point instead, which is how pay actually scales and leaves no cliffs
  /// anywhere on the curve. The steepest stretch is 75-85, at about
  /// +27% per point — that's the climb into genuine star money, and it's
  /// smooth all the way up.
  static double _basePay(double overall) {
    final ovr = overall.clamp(_anchors.first.$1, _anchors.last.$1);
    for (var i = 0; i < _anchors.length - 1; i++) {
      final (lowOvr, lowPay) = _anchors[i];
      final (highOvr, highPay) = _anchors[i + 1];
      if (ovr <= highOvr) {
        if (highOvr == lowOvr) return lowPay;
        final t = (ovr - lowOvr) / (highOvr - lowOvr);
        return lowPay * pow(highPay / lowPay, t);
      }
    }
    return _anchors.last.$2;
  }

  /// A popular fighter draws real money even at the same skill level as an
  /// anonymous one — max popularity (100) is worth +67% over the same
  /// fighter with none.
  static double _popularityMultiplier(int popularity) =>
      1 + popularity.clamp(0, 100) / 150;

  /// Suggested show money / win bonus for a fighter of this [overall] and
  /// [popularity], split evenly — a fighter who wins takes home
  /// [SuggestedPay.total], one who loses or draws takes home just the
  /// show money. Rounded to the nearest $50 for a clean number to show
  /// the player.
  static SuggestedPay suggest({required double overall, required int popularity}) {
    final total = _basePay(overall) * _popularityMultiplier(popularity);
    final show = _roundTo50(total / 2);
    final win = _roundTo50(total) - show;
    return SuggestedPay(showMoney: show, winBonus: win);
  }

  static int _roundTo50(double value) => (value / 50).round() * 50;
}
