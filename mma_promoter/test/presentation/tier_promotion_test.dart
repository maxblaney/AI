import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

import '../support/fighter_fixtures.dart';

/// Reputation used to accumulate to nothing and the tier never moved, so
/// a Local promotion could never become a National one. These cover the
/// ladder actually being climbed.
void main() {
  Fighter signed(String id, String name) => testFighter(id, stat: 70).copyWith(
        name: name,
        weightClass: WeightClass.lightweight,
        contract: Contract(
          id: '$id-c',
          fighterId: id,
          fightsRemaining: 20,
          showMoney: 1000,
          winBonus: 1000,
          exclusive: true,
          signedOn: DateTime(2026, 1, 1),
        ),
      );

  Future<GameController> controllerAt(ReputationTier tier) async {
    final controller = GameController.inMemory(random: Random(5));
    await controller.startNewGame(orgName: 'Ladder FC', tier: tier);
    for (final s in [...controller.signedRoster]) {
      await controller.releaseFighter(s.id);
    }
    for (final f in [signed('a', 'Fighter A'), signed('b', 'Fighter B')]) {
      await controller.saveFighter(f);
    }
    return controller;
  }

  Future<void> runOneCard(GameController controller) async {
    final week = controller.organization!.currentWeek;
    final error = await controller.bookEvent(
      name: 'Fight Night',
      date: GameCalendar.dateForWeek(week + 1),
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      card: const [
        Fight(
          id: 'f1',
          eventId: '',
          fighterAId: 'a',
          fighterBId: 'b',
          weightClass: WeightClass.lightweight,
          cardOrder: 0,
          isMainEvent: true,
          rounds: 3,
        ),
      ],
    );
    expect(error, isNull);
    await controller.advanceWeek();
    final event = controller.scheduledEvents.single;
    await controller.simulateEvent(event.id, promotionBudgetSpent: 0);
  }

  /// Puts the org one good night short of the next rung.
  Future<void> primeToThreshold(GameController controller) async {
    final org = controller.organization!;
    final next = org.reputationTier.nextTier!;
    await controller.debugSetReputationPoints(next.reputationRequired);
  }

  test('crossing the threshold moves the promotion up a tier', () async {
    final controller = await controllerAt(ReputationTier.local);
    expect(controller.organization!.reputationTier, ReputationTier.local);

    await primeToThreshold(controller);
    await runOneCard(controller);

    expect(controller.organization!.reputationTier, ReputationTier.regional);
    expect(
      controller.inboxItems.any((i) =>
          i.type == InboxItemType.promotion &&
          i.title.contains('Regional promotion')),
      isTrue,
      reason: 'a promotion nobody is told about is not a reward',
    );

    controller.dispose();
  });

  test('short of the threshold, nothing moves', () async {
    final controller = await controllerAt(ReputationTier.local);
    await controller.debugSetReputationPoints(
      ReputationTier.regional.reputationRequired - 20,
    );

    await runOneCard(controller);

    expect(controller.organization!.reputationTier, ReputationTier.local);
    expect(
      controller.inboxItems.any((i) => i.type == InboxItemType.promotion),
      isFalse,
    );

    controller.dispose();
  });

  test('a night big enough can carry you more than one rung', () async {
    final controller = await controllerAt(ReputationTier.local);
    await controller.debugSetReputationPoints(
      ReputationTier.national.reputationRequired,
    );

    await runOneCard(controller);

    // Being stranded a threshold below where your reputation already
    // puts you would be a bookkeeping artefact, not a rule.
    expect(controller.organization!.reputationTier, ReputationTier.national);
    expect(
      controller.inboxItems
          .where((i) => i.type == InboxItemType.promotion)
          .length,
      2,
    );

    controller.dispose();
  });

  test('the top of the ladder has nowhere further to go', () async {
    final controller = await controllerAt(ReputationTier.international);
    await controller.debugSetReputationPoints(100000);

    await runOneCard(controller);

    expect(
      controller.organization!.reputationTier,
      ReputationTier.international,
    );
    expect(
      controller.inboxItems.any((i) => i.type == InboxItemType.promotion),
      isFalse,
    );

    controller.dispose();
  });
}
