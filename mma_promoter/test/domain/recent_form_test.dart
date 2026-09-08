import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/history/recent_form.dart';

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
  group('RecentForm.from', () {
    test('reads results from the named fighter point of view', () {
      final form = RecentForm.from(
        fights: [
          _fight(id: '1', a: 'me', b: 'x', winnerId: 'me'),
          _fight(id: '2', a: 'y', b: 'me', winnerId: 'y'),
        ],
        fighterId: 'me',
      );

      expect(form.map((e) => e.result),
          [FormResult.win, FormResult.loss]);
      expect(form.map((e) => e.opponentId), ['x', 'y']);
    });

    test('a fight that has not been run yet is not a result', () {
      final form = RecentForm.from(
        fights: [
          _fight(id: '1', a: 'me', b: 'x', unresolved: true),
          _fight(id: '2', a: 'me', b: 'y', winnerId: 'me'),
        ],
        fighterId: 'me',
      );

      expect(form, hasLength(1));
      expect(form.single.opponentId, 'y');
    });

    test('a draw is neither a win nor a loss', () {
      final form = RecentForm.from(
        fights: [_fight(id: '1', a: 'me', b: 'x', draw: true)],
        fighterId: 'me',
      );

      expect(form.single.result, FormResult.draw);
    });

    test('keeps only the most recent fights, in the order given', () {
      final form = RecentForm.from(
        fights: [
          for (var i = 0; i < 8; i++)
            _fight(id: '$i', a: 'me', b: 'x$i', winnerId: 'me'),
        ],
        fighterId: 'me',
      );

      expect(form, hasLength(RecentForm.defaultLength));
      expect(form.first.opponentId, 'x0');
      expect(form.last.opponentId, 'x4');
    });

    test('ignores fights the fighter was not in', () {
      final form = RecentForm.from(
        fights: [
          _fight(id: '1', a: 'someone', b: 'else', winnerId: 'someone'),
          _fight(id: '2', a: 'me', b: 'x', winnerId: 'me'),
        ],
        fighterId: 'me',
      );

      expect(form, hasLength(1));
    });
  });

  group('method shorthand', () {
    test('a finish names the round it came in', () {
      final form = RecentForm.from(
        fights: [
          _fight(
            id: '1',
            a: 'me',
            b: 'x',
            winnerId: 'me',
            method: FightMethod.koTko,
            round: 2,
          ),
          _fight(
            id: '2',
            a: 'me',
            b: 'y',
            winnerId: 'me',
            method: FightMethod.submission,
            round: 1,
          ),
        ],
        fighterId: 'me',
      );

      expect(form[0].methodLabel, 'KO R2');
      expect(form[1].methodLabel, 'SUB R1');
    });

    test('a decision carries no round, because they all go the distance', () {
      final form = RecentForm.from(
        fights: [_fight(id: '1', a: 'me', b: 'x', winnerId: 'me')],
        fighterId: 'me',
      );

      expect(form.single.methodLabel, 'DEC');
    });
  });

  group('summarise', () {
    test('counts the span shown, not the career', () {
      final form = RecentForm.from(
        fights: [
          _fight(id: '1', a: 'me', b: 'a', winnerId: 'me'),
          _fight(id: '2', a: 'me', b: 'b', winnerId: 'b'),
          _fight(id: '3', a: 'me', b: 'c', winnerId: 'me'),
        ],
        fighterId: 'me',
      );

      expect(RecentForm.summarise(form), '2-1');
    });

    test('draws only show up when there are any', () {
      final form = RecentForm.from(
        fights: [
          _fight(id: '1', a: 'me', b: 'a', winnerId: 'me'),
          _fight(id: '2', a: 'me', b: 'b', draw: true),
        ],
        fighterId: 'me',
      );

      expect(RecentForm.summarise(form), '1-0-1');
    });

    test('an empty form line reads 0-0', () {
      expect(RecentForm.summarise(const []), '0-0');
    });
  });
}
