import 'dart:math';

import '../../data/models/models.dart';

/// Everything one fighter did in one round that a judge could see.
class RoundTally {
  double damage = 0;
  int significantStrikes = 0;
  int knockdowns = 0;
  int takedowns = 0;
  int submissionAttempts = 0;
  int reversals = 0;

  /// Position-weighted control seconds — three minutes of mount counts for
  /// a lot more than three minutes stalled in closed guard.
  double controlValue = 0;

  /// How many times this fighter had the other in genuine trouble (a deep
  /// submission, a hurt opponent they were teeing off on).
  double nearFinishes = 0;

  RoundTally();
}

/// One judge, with their own slight leaning. Real panels disagree because
/// judges genuinely weight striking and grappling differently, which is
/// what produces split decisions — so each judge here gets a bias drawn
/// once per fight and applied to every round.
class _Judge {
  final String name;
  final double strikingBias;
  final double grapplingBias;
  final double noise;

  /// How dominant a round has to be before *this* judge writes a 10-8.
  /// Drawn per fight, because in the real sport a marginal 10-8 shows up
  /// on one card and not the other two — judges disagree about them more
  /// than about anything else. Without this every 10-8 was unanimous.
  final double tenEightBar;

  const _Judge({
    required this.name,
    required this.strikingBias,
    required this.grapplingBias,
    required this.noise,
    required this.tenEightBar,
  });
}

/// The commission's pool of officials. Four names, three seats — so the
/// panel changes fight to fight and one judge always sits out.
const _judgeNames = [
  'Kyle Gates',
  'Eric Parsons',
  'Lucas Craft',
  'Pablo Llorente',
];

/// Scores a completed fight the way a three-judge panel would.
class JudgePanel {
  final Random _random;
  late final List<_Judge> _judges;

  JudgePanel({Random? random}) : _random = random ?? Random() {
    final names = [..._judgeNames]..shuffle(_random);
    _judges = [
      for (var i = 0; i < 3; i++)
        _Judge(
          name: names[i],
          strikingBias: 0.62 + _random.nextDouble() * 0.76,
          grapplingBias: 0.62 + _random.nextDouble() * 0.76,
          noise: 0.88 + _random.nextDouble() * 0.24,
          tenEightBar: JudgePanel.tenEightBar +
              _random.nextDouble() * JudgePanel.tenEightBarSpread,
        ),
    ];
  }

  /// [rounds] is one (fighterA, fighterB) tally pair per completed round.
  List<Scorecard> score(List<(RoundTally, RoundTally)> rounds) {
    return [
      for (final judge in _judges)
        Scorecard(
          judgeName: judge.name,
          rounds: [
            for (var i = 0; i < rounds.length; i++)
              _scoreRound(judge, i + 1, rounds[i].$1, rounds[i].$2),
          ],
        ),
    ];
  }

  RoundScore _scoreRound(_Judge judge, int round, RoundTally a, RoundTally b) {
    final scoreA = _impression(judge, a);
    final scoreB = _impression(judge, b);

    const winnerPoints = 10;
    final loserPoints = _isTenEight(judge, a, b, scoreA, scoreB) ? 8 : 9;

    if (scoreA > scoreB) {
      return RoundScore(round: round, fighterAScore: winnerPoints, fighterBScore: loserPoints);
    }
    if (scoreB > scoreA) {
      return RoundScore(round: round, fighterAScore: loserPoints, fighterBScore: winnerPoints);
    }
    // Dead-even rounds essentially never get scored 10-10; a judge picks.
    return _random.nextBool()
        ? RoundScore(round: round, fighterAScore: 10, fighterBScore: 9)
        : RoundScore(round: round, fighterAScore: 9, fighterBScore: 10);
  }

  /// The lowest bar any judge will write a 10-8 on, on the 0-100 scale
  /// [dominanceOf] produces. Deliberately high: a 10-8 is a round the
  /// loser survived rather than competed in, and it has to be rare enough
  /// that seeing one on a card means something.
  static const double tenEightBar = 84;

  /// How far the strictest judge sits above the most lenient. This is
  /// what makes a marginal round show up as 10-8 on one card and 10-9 on
  /// the other two, the way it does in the sport.
  static const double tenEightBarSpread = 26;

  /// How overwhelming a round was for its winner, roughly 0-100.
  ///
  /// The unified rules ask a judge to weigh impact, dominance and
  /// duration. Rather than three hard gates — which made the answer
  /// binary, and identical on all three cards — each contributes points,
  /// and a judge writes 10-8 once the total clears their own
  /// [_Judge.tenEightBar].
  ///
  /// Public so tests can pin the shape of the curve rather than only its
  /// output.
  static double dominanceOf(RoundTally winner, RoundTally loser) {
    // Impact. A knockdown is most of a 10-8 on its own; two is all of it.
    var score = winner.knockdowns * 32.0;
    score += winner.nearFinishes * 15.0;

    // Damage, but only the part that was one-way — trading heavily and
    // coming out ahead is a 10-9.
    final damageEdge = winner.damage - loser.damage;
    score += (damageEdge - 12).clamp(0.0, 55.0) * 0.55;

    // Dominance: what the loser managed in reply. Silence is what turns a
    // clear round into a one-sided one.
    final loserOutput = loser.significantStrikes +
        loser.takedowns * 3 +
        loser.controlValue * 0.05 +
        loser.knockdowns * 12 +
        loser.submissionAttempts * 3;
    score += (12 - loserOutput).clamp(0.0, 12.0) * 1.5;

    // Duration: it has to have lasted. Capped low, because a long round
    // of control with nothing behind it must never reach the bar on its
    // own — see the impact floor in [_isTenEight].
    score += (winner.controlValue / 300 * 10).clamp(0.0, 10.0);
    score += (winner.significantStrikes - 22).clamp(0.0, 28.0) * 0.35;

    return score;
  }

  /// Whether [judge] scores this round 10-8.
  ///
  /// Two knockdowns is a 10-8 on every card, always. Otherwise the round
  /// needs real impact — a knockdown, a near finish, or a beating that
  /// was overwhelmingly one-way — *and* has to clear this judge's bar. A
  /// round won purely on control is a 10-9 however wide the points gap,
  /// because the impact floor is never met.
  bool _isTenEight(
    _Judge judge,
    RoundTally a,
    RoundTally b,
    double scoreA,
    double scoreB,
  ) {
    if (scoreA == scoreB) return false;
    final winner = scoreA > scoreB ? a : b;
    final loser = scoreA > scoreB ? b : a;

    if (winner.knockdowns >= 2) return true;

    final damageEdge = winner.damage - loser.damage;
    final hasImpact = winner.knockdowns >= 1 ||
        winner.nearFinishes >= 1 ||
        (damageEdge > 24 && loser.damage < damageEdge * 0.25);
    if (!hasImpact) return false;

    return dominanceOf(winner, loser) >= judge.tenEightBar;
  }

  /// Damage is weighted heaviest, then volume, then grappling — roughly
  /// the modern unified-rules priority order.
  double _impression(_Judge judge, RoundTally t) {
    final striking = (t.damage * 3.0 + t.significantStrikes * 0.85 + t.knockdowns * 17) *
        judge.strikingBias;
    final grappling =
        (t.takedowns * 3.5 + t.controlValue * 0.055 + t.submissionAttempts * 4.0 + t.reversals * 2.5) *
            judge.grapplingBias;
    final trouble = t.nearFinishes * 7.5;
    final jitter = 0.78 + _random.nextDouble() * 0.44;
    return (striking + grappling + trouble) * judge.noise * jitter;
  }
}

/// Reads three cards and works out who won and how the panel split.
({String winnerId, DecisionType type}) readCards(
  List<Scorecard> cards,
  String fighterAId,
  String fighterBId,
) {
  var forA = 0;
  var forB = 0;
  var even = 0;
  for (final card in cards) {
    switch (card.winner) {
      case 1:
        forA++;
      case -1:
        forB++;
      default:
        even++;
    }
  }

  if (forA > forB) {
    return (
      winnerId: fighterAId,
      type: forA == 3
          ? DecisionType.unanimous
          : (even > 0 ? DecisionType.majority : DecisionType.split),
    );
  }
  if (forB > forA) {
    return (
      winnerId: fighterBId,
      type: forB == 3
          ? DecisionType.unanimous
          : (even > 0 ? DecisionType.majority : DecisionType.split),
    );
  }
  return (winnerId: '', type: DecisionType.none); // draw
}
