import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/booking/card_matchmaker.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/domain/history/record_book.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// The record book took its names from [GameController.allFighters], a
/// stream cache. On a cold start the events stream can deliver before the
/// fighters stream, so the History screen fetched the book while the
/// roster cache was still empty and every row read "Unknown fighter" —
/// and stayed that way, because the screen keys its refetch on the
/// completed-event count, which does not change again.
void main() {
  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('names are real even before the roster stream has delivered',
      () async {
    final c = GameController.inMemory(random: Random(5));
    await c.startNewGame(orgName: 'Books FC', tier: ReputationTier.regional);
    await settle();
    final saveId = c.activeSaveId!;

    final org = c.organization!;
    await c.bookEvent(
      name: 'Night One',
      date: GameCalendar.dateForWeek(org.currentWeek + 1),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: CardMatchmaker.build(roster: c.signedRoster, bouts: 5),
    );
    await c.advanceWeek();
    await c.simulateEvent(c.scheduledEvents.single.id, promotionBudgetSpent: 0);
    await settle();

    // Reopening a save tears the caches down and resubscribes. Whether
    // the fighters stream has redelivered by the time the book is asked
    // for is exactly the race that broke this, so the book must not care
    // either way.
    await c.loadSave(saveId);

    final book = await c.getRecordBook();
    expect(book, isNotEmpty);

    final named = book
        .expand((category) => category.entries)
        .where((e) => e.fighterId != null)
        .toList();
    expect(named, isNotEmpty, reason: 'there should be fighter records');
    expect(
      named.every((e) => e.fighterName != 'Unknown fighter'),
      isTrue,
      reason: 'every row should name a real fighter, got '
          '${named.where((e) => e.fighterName == 'Unknown fighter').length} '
          'unknown of ${named.length}',
    );

    c.dispose();
  });

  test('an empty name map is what the failure looked like', () {
    // Documents the failure mode the fix removes: the book itself is
    // pure, and with no fighters to resolve against every row reads
    // "Unknown fighter". Nothing here should ever be handed an empty map
    // again, because getRecordBook reads the fighters itself.
    final fights = [
      const Fight(
        id: 'f1',
        eventId: 'e1',
        fighterAId: 'a',
        fighterBId: 'b',
        weightClass: WeightClass.lightweight,
        cardOrder: 0,
        result: FightResult(
          winnerId: 'a',
          method: FightMethod.koTko,
          round: 1,
          winnerPerformanceRating: 80,
          loserPerformanceRating: 50,
        ),
      ),
    ];

    final blind = RecordBook.build(fights: fights, fighters: const {});
    expect(
      blind.expand((c) => c.entries).every((e) => e.fighterName == 'Unknown fighter'),
      isTrue,
    );

    final sighted = RecordBook.build(
      fights: fights,
      fighters: {
        'a': testFighter('a', stat: 70).copyWith(name: 'Real Name'),
        'b': testFighter('b', stat: 70).copyWith(name: 'Other Name'),
      },
    );
    expect(
      sighted.expand((c) => c.entries).any((e) => e.fighterName == 'Real Name'),
      isTrue,
    );
  });

  test('and once the caches are warm too', () async {
    final c = GameController.inMemory(random: Random(5));
    await c.startNewGame(orgName: 'Books FC', tier: ReputationTier.regional);
    await settle();

    final org = c.organization!;
    await c.bookEvent(
      name: 'Night One',
      date: GameCalendar.dateForWeek(org.currentWeek + 1),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: CardMatchmaker.build(roster: c.signedRoster, bouts: 5),
    );
    await c.advanceWeek();
    await c.simulateEvent(c.scheduledEvents.single.id, promotionBudgetSpent: 0);
    await settle();

    final book = await c.getRecordBook();
    final named =
        book.expand((cat) => cat.entries).where((e) => e.fighterId != null);
    expect(named, isNotEmpty);
    expect(named.every((e) => e.fighterName != 'Unknown fighter'), isTrue);

    c.dispose();
  });
}
