import 'dart:math';

/// How many people a promotion picks up — or loses — from one night.
///
/// Fanbase used to grow by `attendance ~/ 10` and nothing else, which is
/// a fixed number of bodies capped by the size of the biggest room in the
/// game. Measured: a sold-out 25,000-seat arena added 2,500 fans, so
/// 30,000 a year was the ceiling however big you got. An International
/// promotion starting on 800,000 needed 20 million before it could
/// realistically charge arena prices — over six hundred years of game
/// time at that rate. The top of the game was reachable in principle and
/// unreachable in practice.
///
/// Two things were wrong with it. Growth was **additive**, so success
/// never compounded: a promotion with a million followers got no more out
/// of a great night than one with a thousand. And it counted only the
/// gate, when the thing that actually makes a promotion national is
/// broadcast — the pay-per-view audience contributed nothing at all.
///
/// So: a share of the following you already have, scaled by how good the
/// night was, plus the people it directly reached. The proportional term
/// is what compounds; the direct term is what lets a promotion with 800
/// fans get off the ground at all, where 3% of nothing is nothing.
class FanbaseGrowth {
  FanbaseGrowth._();

  /// The most of your existing following one great night can add.
  ///
  /// Three percent a show is about 40% a year on a card a month, which
  /// takes a promotion from a regional 8,000 to arena-filling millions
  /// across a long career rather than a geological age. It is the top of
  /// the range and needs a sold-out house, a real main event and fights
  /// worth watching — an ordinary night lands well short.
  static const double maxProportionalGain = 0.03;

  /// What a night this bad costs you. Empty seats and forgettable fights
  /// should move the number the other way, or quality is only ever a
  /// bonus and never a risk.
  static const double maxProportionalLoss = -0.005;

  /// The fill rate at which a house counts as full for these purposes.
  /// Short of a literal sellout, because turning the last few hundred
  /// away is not what makes a night feel big.
  static const double _fullHouse = 0.8;

  /// One in this many people watching on pay-per-view sticks around as
  /// a follower. Lower conversion than a ticket buyer — they paid less
  /// and travelled nowhere — but there are far more of them, which is
  /// the whole point of broadcast.
  static const int _ppvPerNewFan = 20;

  /// One in this many of the people in the building.
  static const int _gatePerNewFan = 10;

  /// How good a night this was, from 0 (nobody should have come) to 1.
  ///
  /// Three things a promoter is judged on: did the room fill, was the
  /// main event worth turning up for, and were the fights any good.
  static double showQuality({
    required int attendance,
    required int venueCapacity,
    required double mainEventPopularity,
    required double averageExcitement,
  }) {
    final fill = venueCapacity <= 0
        ? 0.0
        : min(1.0, (attendance / venueCapacity) / _fullHouse);
    final star = (mainEventPopularity / 100).clamp(0.0, 1.0);
    final fights = (averageExcitement / 10).clamp(0.0, 1.0);
    return (fill * 0.35 + star * 0.20 + fights * 0.45).clamp(0.0, 1.0);
  }

  /// Net change in followers from this event. Negative for a bad night.
  ///
  /// [averageExcitement] is the mean of the card's 1-10 fight ratings.
  static int forEvent({
    required int fanbaseSize,
    required int attendance,
    required int venueCapacity,
    required int ppvBuys,
    required double mainEventPopularity,
    required double averageExcitement,
  }) {
    final quality = showQuality(
      attendance: attendance,
      venueCapacity: venueCapacity,
      mainEventPopularity: mainEventPopularity,
      averageExcitement: averageExcitement,
    );

    // Quality maps onto the growth rate with its zero somewhere in the
    // middle: a merely adequate show holds you level, and you have to be
    // good to grow.
    final rate = maxProportionalLoss +
        (maxProportionalGain - maxProportionalLoss) * quality;
    final proportional = fanbaseSize * rate;

    // The people who actually saw it. Unlike the proportional term this
    // never goes backwards — somebody who watched still watched.
    final direct =
        attendance / _gatePerNewFan + ppvBuys / _ppvPerNewFan;

    return (proportional + direct).round();
  }
}
