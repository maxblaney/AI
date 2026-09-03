import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/history/head_to_head.dart';

Fight _fight({
  required String id,
  required String a,
  required String b,
  String? winnerId,
  FightMethod method = FightMethod.decision,
  int round = 3,
  bool draw = false,
  bool unresolved = false,
}) {
  return Fight(
    id: id,
    eventId: 'event-$id',
    fighterAId: a,
    fighterBId: b,
    weightClass: WeightClass.lightweight,
    cardOrder: 0,
    rounds: 3,
    result: unresolved
        ? null
        : FightResult(
            winnerId: draw ? '' : winnerId!,
            method: draw ? FightMethod.drawOrNc : method,
            round: round,
            timeSeconds: 300,
            winnerPerformanceRating: 80,
            loserPerformanceRating: 60,
          ),
  );
}

void main() {
  group('HeadToHead.from', () {
    test('two fighters who have never met', () {
      final h = HeadToHead.from(
        fights: [_fight(id: '1', a: 'ade', b: 'other', winnerId: 'ade')],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.isRematch, isFalse);
      expect(h.meetings, 0);
      expect(h.label, '');
      expect(h.summary('Adeleke', 'Szymanski'), '');
    });

    test('one prior meeting reads as a rematch, with how it ended', () {
      final h = HeadToHead.from(
        fights: [
          _fight(
            id: '1',
            a: 'ade',
            b: 'szy',
            winnerId: 'ade',
            method: FightMethod.koTko,
            round: 2,
          ),
        ],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.meetings, 1);
      expect(h.label, 'Rematch');
      expect(h.summary('Adeleke', 'Szymanski'), 'Adeleke won by KO R2');
    });

    test('the corners can be listed either way round', () {
      final fights = [
        _fight(id: '1', a: 'szy', b: 'ade', winnerId: 'szy'),
      ];

      final fromAde = HeadToHead.from(fights: fights, aId: 'ade', bId: 'szy');
      expect(fromAde.winsA, 0);
      expect(fromAde.winsB, 1);
      expect(fromAde.summary('Adeleke', 'Szymanski'),
          'Szymanski won by Decision');

      final fromSzy = HeadToHead.from(fights: fights, aId: 'szy', bId: 'ade');
      expect(fromSzy.winsA, 1);
      expect(fromSzy.summary('Szymanski', 'Adeleke'),
          'Szymanski won by Decision');
    });

    test('a split series is a trilogy bout at level', () {
      final h = HeadToHead.from(
        fights: [
          _fight(id: '2', a: 'szy', b: 'ade', winnerId: 'szy'),
          _fight(id: '1', a: 'ade', b: 'szy', winnerId: 'ade'),
        ],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.meetings, 2);
      expect(h.label, 'Trilogy Bout');
      expect(h.summary('Adeleke', 'Szymanski'), 'Series level 1-1');
    });

    test('a lead in the series names the man holding it', () {
      final h = HeadToHead.from(
        fights: [
          _fight(id: '3', a: 'ade', b: 'szy', winnerId: 'ade'),
          _fight(id: '2', a: 'szy', b: 'ade', winnerId: 'szy'),
          _fight(id: '1', a: 'ade', b: 'szy', winnerId: 'ade'),
        ],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.label, '4th Meeting');
      expect(h.summary('Adeleke', 'Szymanski'), 'Adeleke leads 2-1');
    });

    test('draws are counted and shown alongside the series', () {
      final h = HeadToHead.from(
        fights: [
          _fight(id: '2', a: 'ade', b: 'szy', draw: true),
          _fight(id: '1', a: 'ade', b: 'szy', winnerId: 'ade'),
        ],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.draws, 1);
      expect(h.summary('Adeleke', 'Szymanski'), 'Adeleke leads 1-0-1');
    });

    test('a booked but unrun rematch is not part of the series', () {
      final h = HeadToHead.from(
        fights: [
          _fight(id: '2', a: 'ade', b: 'szy', unresolved: true),
          _fight(id: '1', a: 'ade', b: 'szy', winnerId: 'ade'),
        ],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.meetings, 1);
      expect(h.label, 'Rematch');
    });

    test('the newest meeting is the one summarised', () {
      final h = HeadToHead.from(
        fights: [
          _fight(
            id: '2',
            a: 'ade',
            b: 'szy',
            winnerId: 'szy',
            method: FightMethod.submission,
            round: 1,
          ),
          _fight(id: '1', a: 'ade', b: 'szy', winnerId: 'ade'),
        ],
        aId: 'ade',
        bId: 'szy',
      );

      expect(h.lastResult!.method, FightMethod.submission);
      expect(h.summary('Adeleke', 'Szymanski'), 'Series level 1-1');
    });
  });
}
