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

  const _Judge({
    required this.name,
    required this.strikingBias,
    required this.grapplingBias,
    required this.noise,
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
    final margin = (scoreA - scoreB).abs();

    const winnerPoints = 10;
    final loserPoints = _isTenEight(a, b, scoreA, scoreB, margin) ? 8 : 9;

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

  /// Whether the round was one-sided enough to be scored 10-8.
  ///
  /// A 10-8 is not "a clear round" — it's a round the loser barely
  /// survived, and it has to be rare enough to mean something when it
  /// appears on a card. The unified rules ask a judge to weigh three
  /// things: **impact** (did the winner hurt them), **dominance** (was it
  /// one-way traffic) and **duration** (did it last, or was it one
  /// flurry). All three have to be there.
  ///
  /// Requiring all three is what keeps the number honest. A round spent
  /// grinding out control with nothing behind it is a 10-9 however wide
  /// the points gap looks, and so is a round with one knockdown in it
  /// where the other man fought back. Scoring on the points margin alone
  /// — which is what the old rule did — made two thirds of all rounds
  /// 10-8s; requiring impact alone still left a quarter of them.
  bool _isTenEight(
    RoundTally a,
    RoundTally b,
    double scoreA,
    double scoreB,
    double margin,
  ) {
    if (scoreA == scoreB) return false;
    final winner = scoreA > scoreB ? a : b;
    final loser = scoreA > scoreB ? b : a;

    // Two knockdowns is a 10-8 on its own, every time.
    if (winner.knockdowns >= 2) return true;

    // Impact: they were dropped, nearly finished, or took a beating that
    // was overwhelmingly one-way.
    final damageEdge = winner.damage - loser.damage;
    final impact = winner.knockdowns >= 1 ||
        winner.nearFinishes >= 1 ||
        (damageEdge > 20 && loser.damage < damageEdge * 0.3);
    if (!impact) return false;

    // Dominance: the loser gave almost nothing back.
    final loserOutput = loser.significantStrikes +
        loser.takedowns * 3 +
        loser.controlValue * 0.05 +
        loser.knockdowns * 10 +
        loser.submissionAttempts * 3;
    final dominance = loserOutput < 4 && margin > 30;

    // Duration: it went on, rather than being one good exchange.
    final duration = winner.controlValue > 230 || winner.significantStrikes > 34;

    return dominance && duration;
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
