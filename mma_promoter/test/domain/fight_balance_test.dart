import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/domain/simulation/fight_resolver.dart';

/// Aggregate statistics over a large sample of fights between
/// generated fighters.
class _Sample {
  int ko = 0, sub = 0, decision = 0, draw = 0, doctor = 0;
  int splitOrMajority = 0;
  int sigLanded = 0, sigThrown = 0;
  int tdLanded = 0, tdThrown = 0;
  int subAttempts = 0, knockdowns = 0, controlSeconds = 0;
  int rounds = 0;
  int fights = 0;

  double pct(int n) => n / fights * 100;
  double get perFighter => fights * 2;
}

_Sample _run({int trials = 2500, int seed = 99}) {
  final rng = Random(seed);
  final pool = generateStartingRoster(fightersPerWeightClass: 40, random: rng);
  final byClass = <WeightClass, List<Fighter>>{};
  for (final f in pool) {
    byClass.putIfAbsent(f.weightClass, () => []).add(f);
  }

  final s = _Sample();
  for (var i = 0; i < trials; i++) {
    final list = byClass[WeightClass.values[rng.nextInt(WeightClass.values.length)]]!;
    final a = list[rng.nextInt(list.length)];
    var b = list[rng.nextInt(list.length)];
    while (b.id == a.id) {
      b = list[rng.nextInt(list.length)];
    }

    final r = FightResolver(random: rng).resolve(fighterA: a, fighterB: b, rounds: 3);
    s.fights++;
    switch (r.method) {
      case FightMethod.koTko:
        s.ko++;
      case FightMethod.submission:
        s.sub++;
      case FightMethod.decision:
        s.decision++;
        if (r.decisionType == DecisionType.split ||
            r.decisionType == DecisionType.majority) {
          s.splitOrMajority++;
        }
      case FightMethod.doctorStoppage:
        s.doctor++;
      case FightMethod.drawOrNc:
        s.draw++;
    }
    s.rounds += r.round;
    s.sigLanded += r.statsA.significantStrikesLanded + r.statsB.significantStrikesLanded;
    s.sigThrown += r.statsA.significantStrikesAttempted + r.statsB.significantStrikesAttempted;
    s.tdLanded += r.statsA.takedownsLanded + r.statsB.takedownsLanded;
    s.tdThrown += r.statsA.takedownsAttempted + r.statsB.takedownsAttempted;
    s.subAttempts += r.statsA.submissionAttempts + r.statsB.submissionAttempts;
    s.knockdowns += r.statsA.knockdowns + r.statsB.knockdowns;
    s.controlSeconds += r.statsA.controlSeconds + r.statsB.controlSeconds;
  }
  return s;
}

/// Guards the *feel* of the simulation. These bounds are deliberately
/// wide enough to survive ordinary tuning but tight enough to catch a
/// change that makes every fight a first-round knockout or a 15-minute
/// stalemate. Reference figures are real UFC aggregates.
void main() {
  late _Sample sample;

  setUpAll(() => sample = _run());

  group('finish distribution resembles real MMA', () {
    test('KO/TKO rate is in a realistic band (UFC ~32%)', () {
      expect(sample.pct(sample.ko), inInclusiveRange(20, 42));
    });

    test('submission rate is in a realistic band (UFC ~20%)', () {
      expect(sample.pct(sample.sub), inInclusiveRange(12, 32));
    });

    test('a plurality of fights go to a decision (UFC ~47%)', () {
      expect(sample.pct(sample.decision), inInclusiveRange(33, 58));
    });

    test('doctor stoppages and draws stay rare', () {
      expect(sample.pct(sample.doctor), lessThan(4));
      expect(sample.pct(sample.draw), lessThan(5));
    });

    test('some decisions are split or majority, but most are unanimous', () {
      final shareOfDecisions = sample.splitOrMajority / sample.decision;
      expect(shareOfDecisions, greaterThan(0.02));
      expect(shareOfDecisions, lessThan(0.45));
    });
  });

  group('box score resembles real MMA', () {
    test('striking accuracy sits near the UFC average of ~43%', () {
      final accuracy = sample.sigLanded / sample.sigThrown * 100;
      expect(accuracy, inInclusiveRange(33, 53));
    });

    test('takedown accuracy sits near the UFC average of ~38%', () {
      final accuracy = sample.tdLanded / sample.tdThrown * 100;
      expect(accuracy, inInclusiveRange(28, 50));
    });

    test('takedowns landed per fighter is in a realistic band (UFC ~1.3)', () {
      expect(sample.tdLanded / sample.perFighter, inInclusiveRange(0.5, 2.5));
    });

    test('knockdowns per fighter is in a realistic band (UFC ~0.35)', () {
      expect(sample.knockdowns / sample.perFighter, inInclusiveRange(0.15, 0.7));
    });

    test('submission attempts stay occasional, not constant', () {
      expect(sample.subAttempts / sample.perFighter, inInclusiveRange(0.2, 1.8));
    });

    test('fighters land a meaningful volume of strikes', () {
      final perRound = sample.sigLanded / sample.perFighter / (sample.rounds / sample.fights);
      expect(perRound, greaterThan(8));
      expect(perRound, lessThan(30));
    });

    test('control time is significant but not the whole fight', () {
      final perFightPerFighter = sample.controlSeconds / sample.perFighter;
      final fightLength = (sample.rounds / sample.fights) * 300;
      expect(perFightPerFighter, greaterThan(40));
      expect(perFightPerFighter / fightLength, lessThan(0.5));
    });

    test('the average fight lasts more than a round but is not always a full three', () {
      final avgRounds = sample.rounds / sample.fights;
      expect(avgRounds, inInclusiveRange(1.8, 2.9));
    });
  });
}
