import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/history/record_book.dart';

import '../support/fighter_fixtures.dart';

FightStatline _stats({
  int sigStrikes = 0,
  int takedownsLanded = 0,
  int takedownsAttempted = 0,
  int knockdowns = 0,
  int controlSeconds = 0,
}) =>
    FightStatline(
      significantStrikesLanded: sigStrikes,
      takedownsLanded: takedownsLanded,
      takedownsAttempted: takedownsAttempted,
      knockdowns: knockdowns,
      controlSeconds: controlSeconds,
    );

Fight _fight({
  required String id,
  required String a,
  required String b,
  required String winnerId,
  FightMethod method = FightMethod.decision,
  int round = 3,
  int timeSeconds = 300,
  bool titleFight = false,
  bool mainEvent = false,
  FightStatline statsA = const FightStatline(),
  FightStatline statsB = const FightStatline(),
  bool draw = false,
  double? preFightProbabilityA,
  WeightClass weightClass = WeightClass.lightweight,
}) {
  return Fight(
    id: id,
    eventId: 'event-$id',
    fighterAId: a,
    fighterBId: b,
    preFightProbabilityA: preFightProbabilityA,
    weightClass: weightClass,
    cardOrder: 0,
    rounds: 3,
    isMainEvent: mainEvent,
    titleFightType:
        titleFight ? TitleFightType.championship : TitleFightType.none,
    result: FightResult(
      winnerId: draw ? '' : winnerId,
      method: draw ? FightMethod.drawOrNc : method,
      round: round,
      timeSeconds: timeSeconds,
      winnerPerformanceRating: 80,
      loserPerformanceRating: 60,
      statsA: statsA,
      statsB: statsB,
    ),
  );
}

Map<String, Fighter> _roster(List<String> ids) => {
      for (final id in ids) id: testFighter(id).copyWith(name: 'Fighter $id'),
    };

/// Finds a leaderboard by name, failing loudly if it isn't there.
RecordCategory _category(List<RecordCategory> all, String title) =>
    all.firstWhere((c) => c.title == title,
        orElse: () => fail('no category "$title" in ${all.map((c) => c.title)}'));

void main() {
  group('org careers', () {
    test('only fights inside the promotion count', () {
      // The fighter arrives with a long record already; the book should
      // ignore it entirely and count the two fights they had here.
      final arrived = testFighter('a').copyWith(
        record: const FightRecord(wins: 10, losses: 2),
      );
      final careers = RecordBook.tally(fights: [
        _fight(id: '1', a: 'a', b: 'b', winnerId: 'a'),
        _fight(id: '2', a: 'a', b: 'c', winnerId: 'a'),
      ]);

      expect(arrived.record.wins, 10, reason: 'fixture sanity');
      expect(careers['a']!.fights, 2);
      expect(careers['a']!.wins, 2);
    });

    test('wins are split by method', () {
      final careers = RecordBook.tally(fights: [
        _fight(id: '1', a: 'a', b: 'b', winnerId: 'a', method: FightMethod.koTko),
        _fight(
            id: '2', a: 'a', b: 'c', winnerId: 'a', method: FightMethod.submission),
        _fight(
            id: '3', a: 'a', b: 'd', winnerId: 'a', method: FightMethod.decision),
      ]);

      final a = careers['a']!;
      expect(a.koWins, 1);
      expect(a.submissionWins, 1);
      expect(a.decisionWins, 1);
      expect(a.finishes, 2, reason: 'a decision is not a finish');
    });

    test('win streaks track the longest run, not the current one', () {
      final careers = RecordBook.tally(fights: [
        _fight(id: '1', a: 'a', b: 'x', winnerId: 'a'),
        _fight(id: '2', a: 'a', b: 'y', winnerId: 'a'),
        _fight(id: '3', a: 'a', b: 'z', winnerId: 'a'),
        _fight(id: '4', a: 'a', b: 'w', winnerId: 'w'), // streak broken
        _fight(id: '5', a: 'a', b: 'v', winnerId: 'a'),
      ]);

      expect(careers['a']!.longestWinStreak, 3);
      expect(careers['a']!.wins, 4);
      expect(careers['a']!.losses, 1);
    });

    test('a draw breaks a streak without counting as a win or loss', () {
      final careers = RecordBook.tally(fights: [
        _fight(id: '1', a: 'a', b: 'x', winnerId: 'a'),
        _fight(id: '2', a: 'a', b: 'y', winnerId: '', draw: true),
        _fight(id: '3', a: 'a', b: 'z', winnerId: 'a'),
      ]);

      final a = careers['a']!;
      expect(a.wins, 2);
      expect(a.draws, 1);
      expect(a.longestWinStreak, 1);
    });

    test('fight time counts completed rounds plus the final one', () {
      // Finished 2:30 into round 3 = two full rounds + 150s.
      final careers = RecordBook.tally(fights: [
        _fight(
            id: '1',
            a: 'a',
            b: 'b',
            winnerId: 'a',
            round: 3,
            timeSeconds: 150,
            method: FightMethod.koTko),
      ]);
      expect(careers['a']!.totalFightSeconds, 2 * 300 + 150);
    });

    test('takedown defense is measured against what the opponent tried', () {
      final careers = RecordBook.tally(fights: [
        _fight(
          id: '1',
          a: 'a',
          b: 'b',
          winnerId: 'a',
          statsA: _stats(takedownsLanded: 3, takedownsAttempted: 6),
          statsB: _stats(takedownsLanded: 2, takedownsAttempted: 10),
        ),
      ]);

      final a = careers['a']!;
      expect(a.takedownAccuracy, closeTo(0.5, 0.001));
      // B tried 10, landed 2 → A stopped 8 of 10.
      expect(a.takedownDefense, closeTo(0.8, 0.001));
    });
  });

  group('leaderboards', () {
    test('cover every requested category once fights exist', () {
      final fights = [
        _fight(
          id: '1',
          a: 'a',
          b: 'b',
          winnerId: 'a',
          method: FightMethod.koTko,
          mainEvent: true,
          titleFight: true,
          statsA: _stats(
              sigStrikes: 40,
              takedownsLanded: 5,
              takedownsAttempted: 8,
              knockdowns: 2,
              controlSeconds: 120),
          statsB: _stats(takedownsLanded: 1, takedownsAttempted: 9),
        ),
        _fight(
          id: '2',
          a: 'a',
          b: 'c',
          winnerId: 'a',
          method: FightMethod.submission,
          statsA: _stats(
              sigStrikes: 20,
              takedownsLanded: 4,
              takedownsAttempted: 6,
              controlSeconds: 200),
          statsB: _stats(takedownsAttempted: 4),
        ),
        _fight(
          id: '3',
          a: 'b',
          b: 'c',
          winnerId: 'b',
          statsA: _stats(sigStrikes: 15),
          statsB: _stats(sigStrikes: 10),
        ),
        // A third fight for 'a' so they clear the minimum the average-time
        // leaderboard requires — an average over one or two fights says
        // nothing, which is exactly why that floor exists.
        _fight(
          id: '4',
          a: 'a',
          b: 'd',
          winnerId: 'a',
          method: FightMethod.koTko,
          round: 1,
          timeSeconds: 60,
          statsA: _stats(sigStrikes: 12, knockdowns: 1),
        ),
      ];

      final categories = RecordBook.build(
        fights: fights,
        fighters: _roster(['a', 'b', 'c', 'd']),
      );
      final titles = categories.map((c) => c.title).toSet();

      for (final expected in [
        'Most Fights',
        'Most Wins',
        'Most Finishes',
        'Most KO/TKOs',
        'Most Submissions',
        'Most Decisions',
        'Longest Win Streak',
        'Most Title Fight Wins',
        'Shortest Average Fight Time',
        'Most Total Fight Time',
        'Most Control Time',
        'Knockdowns Landed',
        'Most Significant Strikes Landed',
        'Most Takedowns Landed',
        'Highest Takedown Accuracy',
        'Highest Takedown Defense',
        'Most Main Events',
      ]) {
        expect(titles, contains(expected));
      }

      expect(_category(categories, 'Most Wins').entries.first.fighterName,
          'Fighter a');
      expect(_category(categories, 'Most Fights').entries.first.value, '3');
      expect(_category(categories, 'Most KO/TKOs').entries.first.value, '2');
      expect(_category(categories, 'Most Control Time').entries.first.value,
          '5:20');
    });

    test('rate categories exclude fighters below the minimum', () {
      // One takedown from one attempt is 100% but means nothing.
      final fights = [
        _fight(
          id: '1',
          a: 'a',
          b: 'b',
          winnerId: 'a',
          statsA: _stats(takedownsLanded: 1, takedownsAttempted: 1),
          statsB: _stats(takedownsLanded: 3, takedownsAttempted: 10),
        ),
      ];
      final categories =
          RecordBook.build(fights: fights, fighters: _roster(['a', 'b']));

      final accuracy = categories
          .where((c) => c.title == 'Highest Takedown Accuracy')
          .toList();
      if (accuracy.isNotEmpty) {
        expect(accuracy.single.entries.map((e) => e.fighterName),
            isNot(contains('Fighter a')));
      }
    });

    test('an empty history produces no leaderboards at all', () {
      expect(RecordBook.build(fights: const [], fighters: const {}), isEmpty);
    });
  });

  group('biggest upsets', () {
    test('ranks underdog wins by how big a dog they were', () {
      final fights = [
        // A 10% shot lands: the biggest upset on the card.
        _fight(id: '1', a: 'a', b: 'b', winnerId: 'a',
            preFightProbabilityA: 0.10),
        // A 40% underdog wins: an upset, but a smaller one.
        _fight(id: '2', a: 'c', b: 'd', winnerId: 'c',
            preFightProbabilityA: 0.40),
        // The heavy favourite wins: not an upset at all.
        _fight(id: '3', a: 'e', b: 'f', winnerId: 'e',
            preFightProbabilityA: 0.90),
      ];
      final categories = RecordBook.build(
        fights: fights,
        fighters: _roster(['a', 'b', 'c', 'd', 'e', 'f']),
      );
      final upsets = _category(categories, 'Biggest Upsets');

      expect(upsets.entries, hasLength(2),
          reason: 'the favourite winning is not an upset');
      expect(upsets.entries.first.fighterId, 'a');
      expect(upsets.entries.first.fighterName, contains('bt'));
      expect(upsets.entries.first.value, startsWith('+'),
          reason: 'an underdog is priced as a plus-money line');
      expect(upsets.entries[1].fighterId, 'c');
    });

    test('fights with no recorded line simply do not qualify', () {
      final categories = RecordBook.build(
        fights: [_fight(id: '1', a: 'a', b: 'b', winnerId: 'a')],
        fighters: _roster(['a', 'b']),
      );
      expect(
        categories.where((c) => c.title == 'Biggest Upsets'),
        isEmpty,
        reason: 'scoring an old fight on a line that was never taken '
            'would be inventing history',
      );
    });
  });

  group('double champs', () {
    test('lists fighters who won titles in two divisions', () {
      final fights = [
        _fight(id: '1', a: 'a', b: 'b', winnerId: 'a', titleFight: true),
        _fight(id: '2', a: 'a', b: 'c', winnerId: 'a', titleFight: true,
            weightClass: WeightClass.welterweight),
        // One belt only — not a double champ.
        _fight(id: '3', a: 'd', b: 'e', winnerId: 'd', titleFight: true,
            weightClass: WeightClass.heavyweight),
      ];
      final categories = RecordBook.build(
        fights: fights,
        fighters: _roster(['a', 'b', 'c', 'd', 'e']),
      );
      final doubles = _category(categories, 'Double Champs');

      expect(doubles.entries, hasLength(1));
      expect(doubles.entries.single.fighterId, 'a');
      expect(doubles.entries.single.value, contains('Lightweight'));
      expect(doubles.entries.single.value, contains('Welterweight'));
    });

    test('marks a fighter still holding both belts as current', () {
      final fights = [
        _fight(id: '1', a: 'a', b: 'b', winnerId: 'a', titleFight: true),
        _fight(id: '2', a: 'a', b: 'c', winnerId: 'a', titleFight: true,
            weightClass: WeightClass.welterweight),
      ];
      final roster = _roster(['a', 'b', 'c']);
      roster['a'] = roster['a']!.copyWith(belts: {
        WeightClass.lightweight,
        WeightClass.welterweight,
      });

      final doubles = _category(
        RecordBook.build(fights: fights, fighters: roster),
        'Double Champs',
      );
      expect(doubles.entries.single.value, contains('current'));
    });
  });

  group('event records', () {
    MmaEvent event(String name, {int ppvBuys = 0, int revenue = 0}) => MmaEvent(
          id: name,
          name: name,
          date: DateTime(2026, 3, 1),
          venue: Venue.regionalUsa,
          ticketPrice: 35,
          status: EventStatus.completed,
          ppvBuys: ppvBuys,
          revenue: revenue,
        );

    test('rank the biggest nights by PPV buys and by revenue', () {
      final categories = RecordBook.build(
        fights: [_fight(id: '1', a: 'a', b: 'b', winnerId: 'a')],
        fighters: _roster(['a', 'b']),
        events: [
          event('Small Show', ppvBuys: 1200, revenue: 90000),
          event('Big Show', ppvBuys: 48000, revenue: 2400000),
          event('Scheduled Show'),
        ],
      );

      final ppv = _category(categories, 'Most PPV Buys in One Event');
      expect(ppv.entries.first.fighterName, 'Big Show');
      expect(ppv.entries.first.value, '48,000');
      expect(ppv.entries.first.fighterId, isNull,
          reason: 'an event record names a show, not a fighter');
      expect(ppv.entries, hasLength(2),
          reason: 'a show with no buys does not belong on the board');

      final revenue = _category(categories, 'Highest Revenue in One Event');
      expect(revenue.entries.first.value, r'$2,400,000');
    });

    test('show up even before anyone has fought', () {
      final categories = RecordBook.build(
        fights: const [],
        fighters: const {},
        events: [event('Opening Night', revenue: 50000)],
      );
      expect(
        _category(categories, 'Highest Revenue in One Event').entries.single
            .fighterName,
        'Opening Night',
      );
    });
  });
}
