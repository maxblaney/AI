import 'dart:math';

import '../../data/models/models.dart';

/// One hold, with how often it shows up among all submission finishes and
/// where on the mat it can actually be applied from.
class SubmissionHold {
  final String name;

  /// Share of all submission finishes, as a percentage. Taken from the
  /// real-world distribution rather than invented — a rear-naked choke
  /// is nearly two fifths of every tap in the sport, and an omoplata is
  /// a rounding error.
  final double share;

  /// What the sampler actually uses. A hold reachable from several
  /// positions the sim visits constantly would otherwise land well above
  /// its [share], and one confined to a rare position well below it, so
  /// each weight is [share] divided through by how often this sim
  /// actually offers the hold. Calibrated by running the mix over tens of
  /// thousands of fights and re-fitting until the output matches — see
  /// `test/domain/submission_mix_test.dart`, which fails if a change to
  /// the ground game pulls the mix off the targets again.
  final double weight;

  /// Ground positions the fighter *on top* can finish this from.
  final Set<GroundPosition> topPositions;

  /// Whether this is available off your back — from guard, defending, or
  /// on the way to being passed.
  final bool fromBottom;

  const SubmissionHold({
    required this.name,
    required this.share,
    double? weight,
    this.topPositions = const {},
    this.fromBottom = false,
  }) : weight = weight ?? share;

  bool availableFrom(GroundPosition position, {required bool fromTop}) =>
      fromTop ? topPositions.contains(position) : fromBottom;
}

/// Every submission the sim can finish with, weighted so the *overall*
/// mix of taps across a save matches the sport.
///
/// Each hold carries the [SubmissionHold.share] it should end up with,
/// and the positions it can genuinely be applied from — you don't take
/// someone's back from inside their guard. Those two pull against each
/// other: a hold available from positions the sim visits often would
/// overshoot its share, one confined to a rare position would undershoot.
/// [SubmissionHold.weight] is the correction, fitted against the sim so
/// the long-run mix lands on the shares while every individual finish
/// stays plausible for where the fight was.
///
/// `test/domain/submission_mix_test.dart` measures the real output and
/// fails if it drifts, so a change to the ground game can't quietly skew
/// the mix.
class SubmissionCatalog {
  SubmissionCatalog._();

  static const rearNakedChoke = SubmissionHold(
    name: 'Rear-Naked Choke',
    share: 38.5,
    weight: 32.87,
    topPositions: {GroundPosition.backMount},
  );

  static const guillotine = SubmissionHold(
    name: 'Guillotine Choke',
    share: 17.4,
    weight: 16.29,
    // The classic counter to a bad shot: you end up in their guard, or
    // on your back with their head under your arm.
    topPositions: {GroundPosition.guard, GroundPosition.halfGuard},
    fromBottom: true,
  );

  static const armbar = SubmissionHold(
    name: 'Armbar',
    share: 13.1,
    weight: 10.74,
    topPositions: {GroundPosition.mount, GroundPosition.sideControl},
    fromBottom: true,
  );

  static const triangle = SubmissionHold(
    name: 'Triangle Choke',
    share: 9.9,
    weight: 13.07,
    topPositions: {GroundPosition.mount},
    fromBottom: true,
  );

  static const darce = SubmissionHold(
    name: "D'Arce Choke",
    share: 8.8,
    weight: 16.21,
    topPositions: {GroundPosition.halfGuard, GroundPosition.sideControl},
  );

  static const kimura = SubmissionHold(
    name: 'Kimura',
    share: 2.6,
    weight: 3.15,
    topPositions: {GroundPosition.sideControl, GroundPosition.halfGuard},
    fromBottom: true,
  );

  static const anaconda = SubmissionHold(
    name: 'Anaconda Choke',
    share: 2.0,
    weight: 4.49,
    topPositions: {GroundPosition.sideControl, GroundPosition.halfGuard},
  );

  static const neckCrank = SubmissionHold(
    name: 'Neck Crank',
    share: 1.4,
    weight: 0.91,
    topPositions: {GroundPosition.backMount, GroundPosition.sideControl},
  );

  /// The named holds, which between them are 93.7% of all taps.
  static const List<SubmissionHold> common = [
    rearNakedChoke,
    guillotine,
    armbar,
    triangle,
    darce,
    kimura,
    anaconda,
    neckCrank,
  ];

  /// The remaining 6.3%: everything else people actually get caught in,
  /// splitting that share between them. Individually rare, collectively
  /// worth having so not every tap is one of eight names.
  static const List<SubmissionHold> rare = [
    SubmissionHold(
      name: 'Arm-Triangle Choke',
      share: 1.4,
      weight: 1.46,
      topPositions: {
        GroundPosition.mount,
        GroundPosition.sideControl,
        GroundPosition.halfGuard,
      },
    ),
    SubmissionHold(
      name: 'Heel Hook',
      share: 1.1,
      weight: 1.37,
      topPositions: {GroundPosition.guard},
      fromBottom: true,
    ),
    SubmissionHold(
      name: 'Americana',
      share: 0.9,
      weight: 1.17,
      topPositions: {GroundPosition.mount, GroundPosition.sideControl},
    ),
    SubmissionHold(
      name: 'Kneebar',
      share: 0.7,
      weight: 0.95,
      topPositions: {GroundPosition.guard},
      fromBottom: true,
    ),
    SubmissionHold(
      name: 'Omoplata',
      share: 0.5,
      weight: 1.75,
      fromBottom: true,
    ),
    SubmissionHold(
      name: 'North-South Choke',
      share: 0.5,
      weight: 1.52,
      topPositions: {GroundPosition.sideControl},
    ),
    SubmissionHold(
      name: 'Peruvian Necktie',
      share: 0.4,
      weight: 1.73,
      topPositions: {GroundPosition.halfGuard},
    ),
    SubmissionHold(
      name: 'Ezekiel Choke',
      share: 0.3,
      weight: 0.74,
      topPositions: {GroundPosition.mount},
    ),
    SubmissionHold(
      name: 'Twister',
      share: 0.3,
      weight: 0.29,
      topPositions: {GroundPosition.backMount},
    ),
    SubmissionHold(
      name: 'Calf Slicer',
      share: 0.2,
      weight: 0.39,
      topPositions: {GroundPosition.halfGuard},
      fromBottom: true,
    ),
  ];

  static const List<SubmissionHold> all = [...common, ...rare];

  /// Picks a hold available from [position], weighted by global share.
  /// Falls back to the position's most likely finish if — impossibly —
  /// nothing matches, so a submission is never nameless.
  static SubmissionHold roll(
    Random random, {
    required GroundPosition position,
    required bool fromTop,
  }) {
    final candidates = [
      for (final hold in all)
        if (hold.availableFrom(position, fromTop: fromTop)) hold,
    ];
    if (candidates.isEmpty) return fromTop ? rearNakedChoke : guillotine;

    final total = candidates.fold<double>(0, (sum, h) => sum + h.weight);
    var roll = random.nextDouble() * total;
    for (final hold in candidates) {
      roll -= hold.weight;
      if (roll <= 0) return hold;
    }
    return candidates.last;
  }
}
