import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Belts move as a side effect of simulating a card, so these drive the
/// real controller against a real database rather than testing the rule
/// in isolation.
void main() {
  late AppDatabase db;
  late GameController controller;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = GameController(database: db);
    await controller.init();
    await controller.startNewGame(
      orgName: 'Belt FC',
      tier: ReputationTier.regional,
    );
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  /// Signs two fighters, books them in a title fight and runs the card.
  Future<(String, String)> runTitleFight({
    required int statA,
    required int statB,
    TitleFightType type = TitleFightType.championship,
  }) async {
    final a = testFighter('champ-a', stat: statA)
        .copyWith(weightClass: WeightClass.lightweight, name: 'Fighter A');
    final b = testFighter('champ-b', stat: statB)
        .copyWith(weightClass: WeightClass.lightweight, name: 'Fighter B');
    await controller.saveFighter(a);
    await controller.saveFighter(b);
    await settle();

    final org = controller.organization!;
    final date = GameCalendar.dateForWeek(org.currentWeek + 1);
    final error = await controller.bookEvent(
      name: 'Title Night',
      date: date,
      venue: Venue.regionalUsa,
      ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
      card: [
        Fight(
          id: 'title-fight',
          eventId: '',
          fighterAId: a.id,
          fighterBId: b.id,
          weightClass: WeightClass.lightweight,
          cardOrder: 0,
          isMainEvent: true,
          rounds: 5,
          titleFightType: type,
        ),
      ],
    );
    expect(error, isNull, reason: 'booking should succeed');

    await controller.advanceWeek();
    await settle();
    final event = controller.scheduledEvents.single;
    final summary =
        await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
    expect(summary, isNotNull, reason: 'the event should have run');
    await settle();

    final result = summary!.resolvedCard.single.result!;
    final loserId = result.winnerId == a.id ? b.id : a.id;
    return (result.winnerId, loserId);
  }

  test('winning a championship fight puts the belt on the winner', () async {
    final (winnerId, loserId) = await runTitleFight(statA: 90, statB: 55);

    expect(controller.fighterById(winnerId)!.isChampion, isTrue);
    expect(controller.fighterById(loserId)!.isChampion, isFalse);
  });

  test('a new champion takes the belt off the old one', () async {
    final (firstChampId, _) = await runTitleFight(statA: 90, statB: 55);
    expect(controller.fighterById(firstChampId)!.isChampion, isTrue);

    // A challenger beats the sitting champion in a second title fight.
    final challenger = testFighter('challenger', stat: 99).copyWith(
      weightClass: WeightClass.lightweight,
      name: 'Challenger',
    );
    await controller.saveFighter(challenger);
    await settle();

    final org = controller.organization!;
    await controller.bookEvent(
      name: 'Title Night II',
      date: GameCalendar.dateForWeek(org.currentWeek + 1),
      venue: Venue.regionalUsa,
      ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
      card: [
        Fight(
          id: 'title-fight-2',
          eventId: '',
          fighterAId: challenger.id,
          fighterBId: firstChampId,
          weightClass: WeightClass.lightweight,
          cardOrder: 0,
          isMainEvent: true,
          rounds: 5,
          titleFightType: TitleFightType.championship,
        ),
      ],
    );
    await controller.advanceWeek();
    await settle();
    final event = controller.scheduledEvents.single;
    final summary =
        await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
    await settle();

    final newWinner = summary!.resolvedCard.single.result!.winnerId;
    // Whoever won, exactly one lightweight holds the belt afterwards.
    final champions = controller.allFighters
        .where((f) => f.weightClass == WeightClass.lightweight && f.isChampion)
        .toList();
    expect(champions, hasLength(1));
    expect(champions.single.id, newWinner);
  });

  test('an interim belt is tracked separately from the undisputed one',
      () async {
    final (interimChampId, _) = await runTitleFight(
      statA: 90,
      statB: 55,
      type: TitleFightType.interim,
    );

    final champ = controller.fighterById(interimChampId)!;
    expect(champ.isInterimChampion, isTrue);
    expect(champ.isChampion, isFalse,
        reason: 'an interim title is not the undisputed one');
  });

  test('a non-title fight leaves belts alone', () async {
    final (winnerId, _) =
        await runTitleFight(statA: 90, statB: 55, type: TitleFightType.none);

    expect(controller.fighterById(winnerId)!.isChampion, isFalse);
    expect(
      controller.allFighters.where((f) => f.isChampion),
      isEmpty,
    );
  });
}
