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
}) {
  return Fight(
    id: id,
    eventId: 'event-$id',
    fighterAId: a,
    fighterBId: b,
    weightClass: WeightClass.lightweight,
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
}
