import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/domain/booking/card_matchmaker.dart';

import '../support/fighter_fixtures.dart';

Fighter _signed(
  String id,
  WeightClass division, {
  int stat = 70,
  int elo = 1500,
  int showMoney = 1000,
  Set<WeightClass> belts = const {},
}) =>
    testFighter(id, stat: stat).copyWith(
      name: 'Fighter $id',
      weightClass: division,
      eloRating: elo,
      belts: belts,
      contract: Contract(
        id: '$id-c',
        fighterId: id,
        fightsRemaining: 3,
        showMoney: showMoney,
        winBonus: showMoney,
        exclusive: true,
        signedOn: DateTime(2026),
      ),
    );

void main() {
  const lw = WeightClass.lightweight;
  const hw = WeightClass.heavyweight;

  group('building a card', () {
    test('nobody is booked twice', () {
      final roster = [
        for (var i = 0; i < 12; i++) _signed('f$i', lw, elo: 1600 - i * 10),
      ];

      final card = CardMatchmaker.build(roster: roster, bouts: 6);

      final ids = card.expand((f) => [f.fighterAId, f.fighterBId]).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(card, hasLength(6));
    });

    test('a bout already run is passed over for one that has not been', () {
      // Four evenly-matched lightweights: without a history the top two
      // headline. Having already fought twice should push that pairing
      // down the card.
      final roster = [
        for (var i = 0; i < 4; i++) _signed('f$i', lw, elo: 1600 - i * 5),
      ];

      final fresh = CardMatchmaker.build(roster: roster, bouts: 1);
      expect(
        {fresh.first.fighterAId, fresh.first.fighterBId},
        {'f0', 'f1'},
      );

      final withHistory = CardMatchmaker.build(
        roster: roster,
        bouts: 1,
        priorMeetings: {CardMatchmaker.pairKey('f0', 'f1'): 2},
      );
      expect(
        {withHistory.first.fighterAId, withHistory.first.fighterBId},
        isNot({'f0', 'f1'}),
      );
    });

    test('pair keys read the same whichever corner is named first', () {
      expect(
        CardMatchmaker.pairKey('ade', 'szy'),
        CardMatchmaker.pairKey('szy', 'ade'),
      );
    });

    test('fighters are matched inside their own division', () {
      final roster = [
        for (var i = 0; i < 4; i++) _signed('lw$i', lw),
        for (var i = 0; i < 4; i++) _signed('hw$i', hw),
      ];

      final card = CardMatchmaker.build(roster: roster, bouts: 4);

      for (final fight in card) {
        final a = roster.firstWhere((f) => f.id == fight.fighterAId);
        final b = roster.firstWhere((f) => f.id == fight.fighterBId);
        expect(a.weightClass, b.weightClass,
            reason: 'moving a fighter up a weight is a deliberate act, '
                'not something to do to somebody automatically');
        expect(fight.weightClass, a.weightClass);
      }
    });

    test('matchups are competitive rather than squashes', () {
      // Sixteen fighters spread right across a ladder; adjacent pairings
      // are what a matchmaker is for.
      final roster = [
        for (var i = 0; i < 16; i++) _signed('f$i', lw, elo: 1900 - i * 50),
      ];

      final card = CardMatchmaker.build(roster: roster, bouts: 8);

      for (final fight in card) {
        final a = roster.firstWhere((f) => f.id == fight.fighterAId);
        final b = roster.firstWhere((f) => f.id == fight.fighterBId);
        final gap = (a.eloRating - b.eloRating).abs();
        expect(gap, lessThanOrEqualTo(CardMatchmaker.maxLadderGap * 50),
            reason: '${a.id} vs ${b.id} is $gap Elo apart');
      }
    });

    test('the first fight is the main event and goes five', () {
      final roster = [
        for (var i = 0; i < 8; i++) _signed('f$i', lw, elo: 1600 - i * 10),
      ];

      final card = CardMatchmaker.build(roster: roster, bouts: 4);

      expect(card.first.isMainEvent, isTrue);
      expect(card.first.rounds, 5);
      expect(card[1].isCoMainEvent, isTrue);
      expect(card.skip(1).every((f) => !f.isMainEvent), isTrue);
      expect(card.map((f) => f.cardOrder), [0, 1, 2, 3]);
    });

    test('a champion in his own division gets a title fight', () {
      final roster = [
        _signed('champ', lw, elo: 1800, belts: {lw}),
        _signed('challenger', lw, elo: 1780),
        for (var i = 0; i < 4; i++) _signed('f$i', lw, elo: 1400 - i * 10),
      ];

      final card = CardMatchmaker.build(roster: roster, bouts: 3);

      final titleFight = card.firstWhere(
        (f) => f.fighterAId == 'champ' || f.fighterBId == 'champ',
      );
      expect(titleFight.titleFightType, TitleFightType.championship);
      expect(titleFight.rounds, 5);
    });

    test('people already on the card are left alone', () {
      final roster = [
        for (var i = 0; i < 8; i++) _signed('f$i', lw, elo: 1600 - i * 10),
      ];

      final card = CardMatchmaker.build(
        roster: roster,
        bouts: 3,
        unavailable: {'f0', 'f1'},
      );

      final ids = card.expand((f) => [f.fighterAId, f.fighterBId]);
      expect(ids, isNot(contains('f0')));
      expect(ids, isNot(contains('f1')));
    });
  });

  group('what it can afford', () {
    test('the undercard is bought on value, not on hype alone', () {
      // Two expensive stars and plenty of cheap talent. Booking purely
      // on hype would put the stars on and blow the budget; a matchmaker
      // buys one main event and fills the rest with value.
      final roster = [
        _signed('starA', lw, stat: 90, elo: 1900, showMoney: 200000),
        _signed('starB', lw, stat: 90, elo: 1890, showMoney: 200000),
        _signed('starC', lw, stat: 88, elo: 1850, showMoney: 180000),
        _signed('starD', lw, stat: 88, elo: 1840, showMoney: 180000),
        for (var i = 0; i < 10; i++)
          _signed('cheap$i', hw, stat: 70, elo: 1500 - i * 10, showMoney: 2000),
      ];

      // Big enough that the star pair clears the main-event ceiling
      // (45% of it), which is the point — the headliner is affordable,
      // a second one would not be.
      final card = CardMatchmaker.build(
        roster: roster,
        bouts: 4,
        purseBudget: 1400000,
      );

      final headliners = {card.first.fighterAId, card.first.fighterBId};
      expect(headliners, {'starA', 'starB'},
          reason: 'the best fight available should headline');

      // The second pair of stars costs more than the budget has left,
      // so the rest of the card comes from the cheap end.
      final undercard =
          card.skip(1).expand((f) => [f.fighterAId, f.fighterBId]);
      expect(undercard.every((id) => id.startsWith('cheap')), isTrue,
          reason: 'the undercard should be affordable, not a second main '
              'event: got ${undercard.toList()}');
    });

    test('a main event that would eat the night is passed over', () {
      final roster = [
        _signed('ruinousA', lw, stat: 95, elo: 1990, showMoney: 900000),
        _signed('ruinousB', lw, stat: 95, elo: 1980, showMoney: 900000),
        for (var i = 0; i < 6; i++)
          _signed('ok$i', lw, stat: 80, elo: 1700 - i * 10, showMoney: 8000),
      ];

      final card = CardMatchmaker.build(
        roster: roster,
        bouts: 3,
        purseBudget: 100000,
      );

      final headliners = {card.first.fighterAId, card.first.fighterBId};
      expect(headliners, isNot(contains('ruinousA')),
          reason: 'one fight should not cost nine times the whole budget');
    });

    test('the budget is a wall, and a short card is the honest answer', () {
      // Everybody is unaffordable. This used to return the full six
      // regardless: the last pass checked nothing and did not even add
      // to what had been spent, so a promotion whose roster had outgrown
      // its gate got a card it could not pay for and no warning. One
      // measured example took \$235,200 and paid out about \$700,000.
      final roster = [
        for (var i = 0; i < 12; i++)
          _signed('rich$i', lw, elo: 1800 - i * 10, showMoney: 500000),
      ];

      final card = CardMatchmaker.build(
        roster: roster,
        bouts: 6,
        purseBudget: 1000,
      );

      expect(card.length, lessThan(6));
      // Still a show: the headliner is booked before the budget is
      // consulted, so there is always a fight to put on.
      expect(card, hasLength(1));
    });
  });

  group('edges', () {
    test('an empty roster makes no card', () {
      expect(CardMatchmaker.build(roster: const [], bouts: 5), isEmpty);
    });

    test('a division with one fighter makes no fight', () {
      expect(
        CardMatchmaker.build(roster: [_signed('alone', lw)], bouts: 5),
        isEmpty,
      );
    });

    test('asking for more bouts than there are fighters gives what fits', () {
      final roster = [for (var i = 0; i < 5; i++) _signed('f$i', lw)];

      expect(CardMatchmaker.build(roster: roster, bouts: 10), hasLength(2));
    });

    test('asking for no bouts makes no card', () {
      final roster = [for (var i = 0; i < 6; i++) _signed('f$i', lw)];

      expect(CardMatchmaker.build(roster: roster, bouts: 0), isEmpty);
    });

    test('it copes with a real generated roster', () {
      final roster = generateSignedRoster(
        tier: ReputationTier.regional,
        signedOn: DateTime(2026),
        random: Random(4),
      );

      final card = CardMatchmaker.build(roster: roster, bouts: 10);

      expect(card, hasLength(10));
      final ids = card.expand((f) => [f.fighterAId, f.fighterBId]).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
