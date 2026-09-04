import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/rankings/division_rankings.dart';
import 'package:mma_promoter/domain/rankings/ladder.dart';

import '../support/fighter_fixtures.dart';

Fighter _ranked(
  String id, {
  required int elo,
  WeightClass division = WeightClass.lightweight,
  Set<WeightClass> belts = const {},
  Set<WeightClass> interimBelts = const {},
}) =>
    testFighter(id).copyWith(
      weightClass: division,
      eloRating: elo,
      isRanked: true,
      belts: belts,
      interimBelts: interimBelts,
    );

void main() {
  const lw = WeightClass.lightweight;
  const ww = WeightClass.welterweight;

  group('order', () {
    test('contenders run on Elo, highest first', () {
      final ordered = DivisionRankings.order([
        _ranked('low', elo: 1400),
        _ranked('high', elo: 1700),
        _ranked('mid', elo: 1550),
      ], lw);

      expect(ordered.map((f) => f.id), ['high', 'mid', 'low']);
    });

    test('the champion sits on top whatever his Elo', () {
      final ordered = DivisionRankings.order([
        _ranked('contender', elo: 1900),
        _ranked('champ', elo: 1500, belts: {lw}),
      ], lw);

      expect(ordered.first.id, 'champ');
    });

    test('an interim champion slots in below the real one', () {
      final ordered = DivisionRankings.order([
        _ranked('contender', elo: 1900),
        _ranked('interim', elo: 1600, interimBelts: {lw}),
        _ranked('champ', elo: 1500, belts: {lw}),
      ], lw);

      expect(ordered.map((f) => f.id), ['champ', 'interim', 'contender']);
    });

    test('a visiting champion appears in the division he holds', () {
      final ordered = DivisionRankings.order([
        _ranked('local', elo: 1800),
        _ranked('visitor', elo: 1500, division: ww, belts: {lw}),
      ], lw);

      expect(ordered.map((f) => f.id), ['visitor', 'local']);
    });

    test('fighters from other divisions stay out of the ladder', () {
      final ordered = DivisionRankings.order([
        _ranked('here', elo: 1500),
        _ranked('elsewhere', elo: 1900, division: ww),
      ], lw);

      expect(ordered.map((f) => f.id), ['here']);
    });
  });

  group('labels', () {
    test('belts take letters and contenders are numbered from one', () {
      final ordered = DivisionRankings.order([
        _ranked('champ', elo: 1500, belts: {lw}),
        _ranked('interim', elo: 1600, interimBelts: {lw}),
        _ranked('first', elo: 1900),
        _ranked('second', elo: 1800),
      ], lw);

      expect(DivisionRankings.labels(ordered, lw),
          ['C', 'iC', '1', '2']);
    });
  });

  group('labelFor', () {
    test('names one fighter rung without callers redoing the sort', () {
      final pool = [
        _ranked('champ', elo: 1500, belts: {lw}),
        _ranked('first', elo: 1900),
        _ranked('second', elo: 1800),
      ];

      expect(DivisionRankings.labelFor(pool[0], pool, lw), 'C');
      expect(DivisionRankings.labelFor(pool[1], pool, lw), '1');
      expect(DivisionRankings.labelFor(pool[2], pool, lw), '2');
    });

    test('someone who has not fought here yet has no rung', () {
      final unranked = testFighter('rookie');

      expect(
        DivisionRankings.labelFor(unranked, [_ranked('a', elo: 1500)], lw),
        isNull,
      );
    });
  });

  group('ladder length', () {
    test('a division ranks only its top fifteen', () {
      final crowd = [
        for (var i = 0; i < 30; i++) _ranked('f$i', elo: 2000 - i),
      ];

      final ordered = DivisionRankings.order(crowd, lw);

      expect(ordered, hasLength(Ladder.size));
      expect(ordered.first.id, 'f0');
      expect(ordered.last.id, 'f14');
    });

    test('a fighter off the bottom of the ladder is unranked', () {
      final crowd = [
        for (var i = 0; i < 30; i++) _ranked('f$i', elo: 2000 - i),
      ];

      // Fifteenth is the last rung; sixteenth has no number at all, and
      // reads that way in the booking screen too.
      expect(DivisionRankings.labelFor(crowd[14], crowd, lw), '15');
      expect(DivisionRankings.labelFor(crowd[15], crowd, lw), isNull);
    });

    test('the champion takes a rung, so only fourteen are numbered', () {
      final crowd = [
        _ranked('champ', elo: 1200, belts: {lw}),
        for (var i = 0; i < 30; i++) _ranked('f$i', elo: 2000 - i),
      ];

      final ordered = DivisionRankings.order(crowd, lw);
      final labels = DivisionRankings.labels(ordered, lw);

      expect(ordered, hasLength(Ladder.size));
      expect(labels.first, 'C');
      expect(labels.last, '14');
    });
  });
}
