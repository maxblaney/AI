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

const _judgeNames = [
  'Sal D\'Amato',
  'Chris Lee',
  'Derek Cleary',
  'Junichiro Kamijo',
  'Ron McCarthy',
  'Eric Colon',
  'Mike Bell',
  'Doug Crosby',
  'Glenn Trowbridge',
  'Marcos Rosales',
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
    final leader = max(scoreA, scoreB);

    // A 10-8 needs genuine domination, not just a clear round: either two
    // knockdowns, or a big margin that's also a big *share* of the round.
    final dominant = (a.knockdowns + b.knockdowns) >= 2 ||
        (margin > 22 && leader > 0 && margin / leader > 0.62) ||
        (margin > 45);

    const winnerPoints = 10;
    final loserPoints = dominant ? 8 : 9;

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
