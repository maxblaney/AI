import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/core/utils/id_generator.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';

Future<GameController> _newGame() async {
  final controller = GameController.inMemory();
  await controller.init();
  await controller.startNewGame(orgName: 'Test Promotion', tier: ReputationTier.regional);
  // The in-memory repos publish their initial snapshot asynchronously, so
  // let that microtask flush before reading roster/event state back.
  await pumpEventQueue();
  return controller;
}

Future<void> _signTwo(GameController controller, WeightClass weightClass) async {
  final pair = controller.talentPool.where((f) => f.weightClass == weightClass).take(2).toList();
  for (final fighter in pair) {
    await controller.signFighter(fighter, payPerFight: 1000, fightsInDeal: 3);
  }
  await pumpEventQueue();
}

Future<String?> _bookSimpleEvent(
  GameController controller, {
  required int weeksFromNow,
  WeightClass weightClass = WeightClass.lightweight,
}) async {
  final org = controller.organization!;
  final roster = controller.signedRoster.where((f) => f.weightClass == weightClass).toList();
  final fight = Fight(
    id: newId(),
    eventId: '',
    fighterAId: roster[0].id,
    fighterBId: roster[1].id,
    weightClass: weightClass,
    cardOrder: 0,
    isMainEvent: true,
  );
  final error = await controller.bookEvent(
    name: 'Fight Night $weeksFromNow',
    date: GameCalendar.dateForWeek(org.currentWeek + weeksFromNow),
    venue: Venue.regionalUsa,
    ticketPrice: 50,
    card: [fight],
  );
  await pumpEventQueue();
  return error;
}

void main() {
  group('GameController game clock', () {
    test('new game starts at week 1', () async {
      final controller = await _newGame();
      expect(controller.organization!.currentWeek, 1);
    });

    test('advanceWeek moves the clock forward when nothing is due', () async {
      final controller = await _newGame();
      final error = await controller.advanceWeek();
      expect(error, isNull);
      expect(controller.organization!.currentWeek, 2);
    });

    test('bookEvent refuses a date that is not in a future week', () async {
      final controller = await _newGame();
      await _signTwo(controller, WeightClass.lightweight);
      final error = await _bookSimpleEvent(controller, weeksFromNow: 0);
      expect(error, isNotNull);
    });
  });

  group('GameController chronological event ordering', () {
    test('events can only be resolved earliest-first, and only once due', () async {
      final controller = await _newGame();
      await _signTwo(controller, WeightClass.lightweight);
      await _signTwo(controller, WeightClass.welterweight);

      // Book a lightweight card 2 weeks out and a welterweight card 5
      // weeks out — the welterweight card is chronologically later.
      await _bookSimpleEvent(controller, weeksFromNow: 2, weightClass: WeightClass.lightweight);
      await _bookSimpleEvent(controller, weeksFromNow: 5, weightClass: WeightClass.welterweight);

      final earlyEvent = controller.nextScheduledEvent!;
      final lateEvent = controller.scheduledEvents.firstWhere((e) => e.id != earlyEvent.id);

      // The later event can't be simulated yet — it hasn't arrived, and
      // it isn't the earliest scheduled event either.
      expect(await controller.simulateEvent(lateEvent.id, promotionBudgetSpent: 0), isNull);

      // advanceWeek walks the clock forward one week at a time. It must
      // refuse to advance once the earliest event's week is reached.
      String? blocked;
      for (var i = 0; i < 10; i++) {
        final result = await controller.advanceWeek();
        if (result != null) {
          blocked = result;
          break;
        }
      }
      expect(blocked, isNotNull, reason: 'advanceWeek should eventually park on the due event');
      expect(
        GameCalendar.weekNumberFor(earlyEvent.date),
        lessThanOrEqualTo(controller.organization!.currentWeek),
      );

      // Still can't jump ahead to the later event before resolving the
      // earlier one — this is the exact bug the calendar rework fixes.
      expect(await controller.simulateEvent(lateEvent.id, promotionBudgetSpent: 0), isNull);

      final summary = await controller.simulateEvent(earlyEvent.id, promotionBudgetSpent: 0);
      expect(summary, isNotNull);
      await pumpEventQueue();

      // Now that the earlier event is resolved, advanceWeek can proceed
      // again until the later event comes due.
      String? blockedAgain;
      for (var i = 0; i < 10; i++) {
        final result = await controller.advanceWeek();
        if (result != null) {
          blockedAgain = result;
          break;
        }
      }
      expect(blockedAgain, isNotNull);

      final lateSummary = await controller.simulateEvent(lateEvent.id, promotionBudgetSpent: 0);
      expect(lateSummary, isNotNull);
    });
  });
}
