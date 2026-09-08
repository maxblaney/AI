import 'dart:math';

import '../../data/models/models.dart';

/// A priced-up fight: each corner's implied chance of winning, and the
/// American moneyline that goes with it.
class FightOdds {
  /// Probability fighter A wins, 0-1, before the book's margin.
  final double probabilityA;
  final int moneylineA;
  final int moneylineB;

  const FightOdds({
    required this.probabilityA,
    required this.moneylineA,
    required this.moneylineB,
  });

  double get probabilityB => 1 - probabilityA;

  /// Negative prices are favourites, so the smaller number is the favourite.
  bool get aIsFavourite => moneylineA < moneylineB;

  static String format(int moneyline) =>
      moneyline > 0 ? '+$moneyline' : '$moneyline';

  String get displayA => format(moneylineA);
  String get displayB => format(moneylineB);
}

/// Prices a fight the way a sportsbook would: work out who's likely to
/// win, then quote both sides with a margin baked in so the two prices
/// imply slightly more than 100%.
class OddsCalculator {
  OddsCalculator._();

  /// The book's cut. 5% is a realistic-ish hold for a two-way market and
  /// keeps a pick'em looking like the -110/-110 a bettor would expect.
  static const double vigorish = 0.05;

  /// How sharply a skill gap moves the line. Tuned so a ~10-point overall
  /// edge lands around -200/+170, which is a normal "clear favourite"
  /// price rather than a formality.
  static const double _skillScale = 11.0;

  /// Odds for [a] vs [b]. Driven mainly by overall skill, with smaller
  /// nudges for current form and durability — the same broad factors the
  /// simulation weighs, so the favourite usually is the one who wins.
  static FightOdds forFight({required Fighter a, required Fighter b}) {
    final edge = _rating(a) - _rating(b);

    // Logistic curve: big gaps saturate instead of running to certainty,
    // because in MMA they don't — anyone can get caught.
    var probabilityA = 1 / (1 + exp(-edge / _skillScale));
    // Nobody is ever a lock. Clamping keeps prices inside what a book
    // would actually put up.
    probabilityA = probabilityA.clamp(0.08, 0.92);

    return FightOdds(
      probabilityA: probabilityA,
      moneylineA: _toMoneyline(probabilityA),
      moneylineB: _toMoneyline(1 - probabilityA),
    );
  }

  /// A single number for how good a fighter is *right now* — overall,
  /// plus a little for a hot streak and for being healthy.
  static double _rating(Fighter fighter) {
    var rating = fighter.overall;
    rating += (fighter.winStreak.clamp(0, 5)) * 0.6;
    rating -= (fighter.lossStreak.clamp(0, 5)) * 0.6;
    if (fighter.injuryStatus != InjuryStatus.healthy) rating -= 3;
    return rating;
  }

  /// Public entry point for pricing a bare probability — the record book
  /// uses it to quote the line an upset winner went off at.
  static int moneylineFor(double probability) => _toMoneyline(probability);

  /// Converts a win probability into an American moneyline, with the
  /// book's margin applied so both sides are a touch worse than fair.
  static int _toMoneyline(double probability) {
    final priced = (probability * (1 + vigorish)).clamp(0.01, 0.99);
    final line = priced >= 0.5
        ? -100 * priced / (1 - priced) // favourite: negative
        : 100 * (1 - priced) / priced; // underdog: positive
    return _round(line);
  }

  /// Books quote in fives, and never inside +/-100 (which isn't a real
  /// price — even money is -105/-105 once the margin is in).
  static int _round(double line) {
    final rounded = (line / 5).round() * 5;
    if (rounded > -100 && rounded < 0) return -100;
    if (rounded >= 0 && rounded < 100) return 100;
    return rounded;
  }
}
