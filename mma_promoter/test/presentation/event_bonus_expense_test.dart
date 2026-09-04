import 'dart:math';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Fight of the Night and Performance of the Night money left the org's
/// cash balance but never showed up on the event that paid it, so a card
/// looked more profitable on the Finance screen than it actually was.
void main() {
  late AppDatabase db;
  late GameController controller;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = GameController(database: db, random: Random(11));
    await controller.init();
    await controller.startNewGame(
      orgName: 'Bonus FC',
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

  Future<EventSimulationSummary> runOneFightCard() async {
    for (final id in ['a', 'b']) {
      await controller.saveFighter(testFighter(id, stat: 70).copyWith(
        name: 'Fighter ${id.toUpperCase()}',
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: 3,
          showMoney: 1000,
          winBonus: 1000,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      ));
    }
    await settle();

    final org = controller.organization!;
    await controller.bookEvent(
      name: 'Bonus Night',
      date: GameCalendar.dateForWeek(org.currentWeek + 1),
      venue: Venue.regionalUsa,
      ticketPrice: Venue.regionalUsa.suggestedTicketPrice,
      card: [
        const Fight(
          id: 'bonus-fight',
          eventId: '',
          fighterAId: 'a',
          fighterBId: 'b',
          weightClass: WeightClass.lightweight,
          cardOrder: 0,
          isMainEvent: true,
        ),
      ],
    );
    await controller.advanceWeek();
    await settle();
    final event = controller.scheduledEvents.single;
    final summary =
        await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
    await settle();
    return summary!;
  }

  test('bonuses are charged to the event that paid them', () async {
    final summary = await runOneFightCard();
    final eventId = summary.event.id;
    final bonus =
        controller.organization!.reputationTier.nightlyBonusAmount;

    MmaEvent current() =>
        controller.completedEvents.firstWhere((e) => e.id == eventId);

    final expensesBefore = current().expenses;
    final profitBefore = current().netProfit;

    expect(await controller.awardFightOfTheNight(eventId, 'bonus-fight'),
        isNull);
    await settle();
    expect(current().expenses, expensesBefore + bonus);
    expect(current().netProfit, profitBefore - bonus,
        reason: 'the night is that much less profitable for paying it');

    expect(await controller.awardPerformanceOfTheNight(eventId, 'a'), isNull);
    await settle();
    expect(current().expenses, expensesBefore + bonus * 2);

    // And the org's cash still moved exactly once per award — the
    // expense line is a record of it, not a second charge.
    expect(current().revenue - current().expenses, current().netProfit);
  });

  test('an award that is refused costs nothing', () async {
    final summary = await runOneFightCard();
    final eventId = summary.event.id;

    await controller.awardFightOfTheNight(eventId, 'bonus-fight');
    await settle();
    final expensesAfterFirst = controller.completedEvents
        .firstWhere((e) => e.id == eventId)
        .expenses;

    expect(await controller.awardFightOfTheNight(eventId, 'bonus-fight'),
        'Already awarded.');
    await settle();
    expect(
      controller.completedEvents.firstWhere((e) => e.id == eventId).expenses,
      expensesAfterFirst,
      reason: 'a rejected second award must not double-charge the event',
    );
  });
}
