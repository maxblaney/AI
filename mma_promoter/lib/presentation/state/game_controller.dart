import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/id_generator.dart';
import '../../data/db/database.dart';
import '../../data/models/models.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/fighter_repository.dart';
import '../../data/repositories/in_memory/in_memory_repositories.dart';
import '../../data/repositories/organization_repository.dart';
import '../../data/repositories/random_event_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/seed/roster_seed.dart';
import '../../domain/events/random_event_engine.dart';
import '../../domain/finance/event_finance_calculator.dart';
import '../../domain/simulation/fight_resolver.dart';

/// Result of resolving one event, kept around so the results screen can
/// show a fight-by-fight breakdown without re-querying everything.
class EventSimulationSummary {
  final MmaEvent event;
  final List<Fight> resolvedCard;
  final EventFinanceResult finance;

  const EventSimulationSummary({
    required this.event,
    required this.resolvedCard,
    required this.finance,
  });
}

/// The single app-wide source of truth for game state. Owns the DB,
/// repositories and domain engines, exposes plain data to widgets via
/// [ChangeNotifier], and is the only place UI code should mutate game
/// state through.
class GameController extends ChangeNotifier {
  final FighterRepositoryContract _fighterRepo;
  final OrganizationRepositoryContract _orgRepo;
  final EventRepositoryContract _eventRepo;
  final RandomEventRepositoryContract _randomEventRepo;

  final FightResolver _fightResolver = FightResolver();
  final EventFinanceCalculator _financeCalculator = EventFinanceCalculator();
  final RandomEventEngine _randomEventEngine = RandomEventEngine();

  StreamSubscription<List<Fighter>>? _fighterSub;
  StreamSubscription<Organization?>? _orgSub;
  StreamSubscription<List<MmaEvent>>? _eventSub;
  StreamSubscription<List<RandomEvent>>? _randomEventSub;

  /// Persists to on-device SQLite via Drift. This is the real, shipping
  /// backend — not available on Flutter web (no `dart:io`), which is why
  /// [GameController.inMemory] exists separately.
  factory GameController({AppDatabase? database}) {
    final db = database ?? AppDatabase();
    return GameController._(
      fighterRepo: FighterRepository(db),
      orgRepo: OrganizationRepository(db),
      eventRepo: EventRepository(db),
      randomEventRepo: RandomEventRepository(db),
    );
  }

  GameController._({
    required FighterRepositoryContract fighterRepo,
    required OrganizationRepositoryContract orgRepo,
    required EventRepositoryContract eventRepo,
    required RandomEventRepositoryContract randomEventRepo,
  })  : _fighterRepo = fighterRepo,
        _orgRepo = orgRepo,
        _eventRepo = eventRepo,
        _randomEventRepo = randomEventRepo;

  /// Volatile, non-persistent mode used for the Flutter-web preview build.
  /// Game state resets on every page reload.
  GameController.inMemory()
      : _fighterRepo = InMemoryFighterRepository(),
        _orgRepo = InMemoryOrganizationRepository(),
        _eventRepo = InMemoryEventRepository(),
        _randomEventRepo = InMemoryRandomEventRepository();

  bool isLoading = true;
  Organization? organization;
  List<Fighter> allFighters = [];
  List<MmaEvent> events = [];
  List<RandomEvent> pendingRandomEvents = [];

  List<Fighter> get signedRoster =>
      allFighters.where((f) => f.isSigned).toList();
  List<Fighter> get talentPool =>
      allFighters.where((f) => !f.isSigned).toList();
  List<MmaEvent> get scheduledEvents =>
      events.where((e) => !e.isCompleted).toList();
  List<MmaEvent> get completedEvents =>
      events.where((e) => e.isCompleted).toList();

  /// True once we've checked persistence and found no organization yet —
  /// the UI should show the new-game setup screen instead of the dashboard.
  bool needsNewGame = false;

  Future<void> init() async {
    final org = await _orgRepo.get();
    organization = org;

    if (org == null) {
      needsNewGame = true;
      isLoading = false;
      notifyListeners();
      return;
    }

    await _subscribeToStreams();
    isLoading = false;
    notifyListeners();
  }

  /// Seeds a brand-new save with the player's chosen org name and starting
  /// tier (which sets cash and fanbase — see [ReputationTierInfo]), then
  /// starts the game normally. Called from the new-game setup screen.
  Future<void> startNewGame({
    required String orgName,
    required ReputationTier tier,
  }) async {
    final org = generateStartingOrganization(name: orgName, tier: tier);
    final pool = generateStartingRoster();
    final roster = signStartingRoster(pool);

    await _orgRepo.save(org);
    for (final fighter in roster) {
      await _fighterRepo.save(fighter);
    }
    organization = org;
    needsNewGame = false;

    await _subscribeToStreams();
    notifyListeners();
  }

  Future<void> _subscribeToStreams() async {
    _fighterSub = _fighterRepo.watchAll().listen((fighters) {
      allFighters = fighters;
      notifyListeners();
    });
    _orgSub = _orgRepo.watch().listen((o) {
      if (o != null) organization = o;
      notifyListeners();
    });
    _eventSub = _eventRepo.watchAll().listen((e) {
      events = e;
      notifyListeners();
    });
    _randomEventSub = _randomEventRepo.watchUnresolved().listen((e) {
      pendingRandomEvents = e;
      notifyListeners();
    });
  }

  Future<MmaEvent?> getEventById(String id) => _eventRepo.getById(id);
  Future<List<Fight>> getEventCard(String id) => _eventRepo.getCard(id);

  Fighter? fighterById(String id) {
    try {
      return allFighters.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---- Roster management ------------------------------------------------

  /// Signs [fighter] to the roster. Charges a one-time signing bonus equal
  /// to [payPerFight] on top of the ongoing per-fight pay in their contract.
  Future<String?> signFighter(
    Fighter fighter, {
    required int payPerFight,
    required int fightsInDeal,
    bool exclusive = true,
  }) async {
    final org = organization;
    if (org == null) return 'No active organization.';
    if (org.cashBalance < payPerFight) {
      return 'Not enough cash for the signing bonus.';
    }

    final contract = Contract(
      id: newId(),
      fighterId: fighter.id,
      fightsRemaining: fightsInDeal,
      payPerFight: payPerFight,
      exclusive: exclusive,
      signedOn: DateTime.now(),
    );
    await _fighterRepo.sign(fighter, contract);
    await _orgRepo.save(org.copyWith(cashBalance: org.cashBalance - payPerFight));
    await _maybeTriggerRandomEvent();
    return null;
  }

  Future<void> releaseFighter(String fighterId) async {
    await _fighterRepo.release(fighterId);
  }

  /// Creates a brand-new fighter in the talent pool, or persists edits to
  /// an existing one — [FighterEditorScreen] uses this for both modes.
  /// Editing preserves whatever id/record/contract the caller passed in.
  Future<void> saveFighter(Fighter fighter) async {
    await _fighterRepo.save(fighter);
  }

  // ---- Event booking ------------------------------------------------------

  /// Books a new scheduled event with the given card. [card] entries must
  /// reference fighters currently on the signed roster; exactly one should
  /// have `isMainEvent = true`.
  Future<String?> bookEvent({
    required String name,
    required DateTime date,
    required Venue venue,
    required int ticketPrice,
    required List<Fight> card,
  }) async {
    if (card.isEmpty) return 'Add at least one fight to the card.';
    if (!card.any((f) => f.isMainEvent)) return 'Pick a main event.';

    final event = MmaEvent(
      id: newId(),
      name: name,
      date: date,
      venue: venue,
      ticketPrice: ticketPrice,
    );
    await _eventRepo.saveEvent(event);
    final fightsWithEventId =
        card.map((f) => f.copyWith(eventId: event.id)).toList();
    await _eventRepo.saveCard(fightsWithEventId);
    await _maybeTriggerRandomEvent();
    return null;
  }

  // ---- Event simulation ---------------------------------------------------

  Future<EventSimulationSummary?> simulateEvent(
    String eventId, {
    required int promotionBudgetSpent,
  }) async {
    final org = organization;
    final event = await _eventRepo.getById(eventId);
    if (org == null || event == null || event.isCompleted) return null;

    final card = await _eventRepo.getCard(eventId);
    final fighterLookup = {for (final f in allFighters) f.id: f};

    final resolvedCard = <Fight>[];
    for (final fight in card) {
      final a = fighterLookup[fight.fighterAId];
      final b = fighterLookup[fight.fighterBId];
      if (a == null || b == null) continue;
      final result = _fightResolver.resolve(
        fighterA: a,
        fighterB: b,
        isTitleFight: fight.isTitleFight,
        isMainEvent: fight.isMainEvent,
      );
      resolvedCard.add(fight.copyWith(result: result));
    }

    final finance = _financeCalculator.calculate(
      venue: event.venue,
      ticketPrice: event.ticketPrice,
      organization: org,
      card: resolvedCard,
      fighterLookup: fighterLookup,
      promotionBudgetSpent: promotionBudgetSpent,
    );

    for (final fight in resolvedCard) {
      await _eventRepo.saveFight(fight);
      await _applyFightOutcome(fight, fighterLookup);
    }

    final completedEvent = event.copyWith(
      status: EventStatus.completed,
      promotionBudgetSpent: promotionBudgetSpent,
      attendance: finance.attendance,
      ppvBuys: finance.ppvBuys,
      revenue: finance.revenue,
      expenses: finance.expenses,
      reputationChange: finance.reputationChange,
    );
    await _eventRepo.saveEvent(completedEvent);

    await _orgRepo.save(org.copyWith(
      cashBalance: org.cashBalance + finance.netProfit,
      reputationPoints:
          (org.reputationPoints + finance.reputationChange).clamp(0, 1 << 30),
      fanbaseSize:
          org.fanbaseSize + (finance.attendance ~/ 10).clamp(0, 1 << 30),
    ));

    await _maybeTriggerRandomEvent();

    return EventSimulationSummary(
      event: completedEvent,
      resolvedCard: resolvedCard,
      finance: finance,
    );
  }

  Future<void> _applyFightOutcome(
    Fight fight,
    Map<String, Fighter> fighterLookup,
  ) async {
    final result = fight.result;
    if (result == null) return;
    final a = fighterLookup[fight.fighterAId];
    final b = fighterLookup[fight.fighterBId];
    if (a == null || b == null) return;

    if (result.isDraw) {
      await _fighterRepo.save(_applyPostFight(a, record: a.record.addDraw()));
      await _fighterRepo.save(_applyPostFight(b, record: b.record.addDraw()));
      return;
    }

    final winner = result.winnerId == a.id ? a : b;
    final loser = result.winnerId == a.id ? b : a;

    await _fighterRepo.save(_applyPostFight(
      winner,
      record: winner.record.addWin(),
      winStreak: winner.winStreak + 1,
      popularityDelta: 2 + result.winnerPerformanceRating ~/ 20,
      moraleDelta: 8,
    ));
    await _fighterRepo.save(_applyPostFight(
      loser,
      record: loser.record.addLoss(),
      winStreak: 0,
      popularityDelta: 1,
      moraleDelta: -10,
    ));
  }

  Fighter _applyPostFight(
    Fighter fighter, {
    required FightRecord record,
    int? winStreak,
    int popularityDelta = 0,
    int moraleDelta = 0,
  }) {
    var updated = fighter.copyWith(
      record: record,
      winStreak: winStreak ?? fighter.winStreak,
      popularity: (fighter.popularity + popularityDelta).clamp(0, 100),
      morale: (fighter.morale + moraleDelta).clamp(0, 100),
    );
    if (updated.contract != null) {
      updated = updated.copyWith(contract: updated.contract!.afterFight());
    }
    return updated;
  }

  // ---- Random events --------------------------------------------------

  Future<void> _maybeTriggerRandomEvent() async {
    if (pendingRandomEvents.isNotEmpty) return; // one at a time for v1.
    final event = _randomEventEngine.maybeGenerate(signedRoster, DateTime.now());
    if (event != null) {
      await _randomEventRepo.save(event);
    }
  }

  Future<void> resolveRandomEvent(RandomEvent event, String choiceId) async {
    final fighter = event.affectedFighterId == null
        ? null
        : fighterById(event.affectedFighterId!);
    if (fighter == null) {
      await _randomEventRepo.save(event.copyWith(chosenChoiceId: choiceId));
      return;
    }

    final outcome = _randomEventEngine.resolveChoice(event, choiceId, fighter);
    await _fighterRepo.save(outcome.updatedFighter);

    final org = organization;
    if (org != null && outcome.cashDelta != 0) {
      await _orgRepo.save(org.copyWith(
        cashBalance: org.cashBalance + outcome.cashDelta,
      ));
    }

    await _randomEventRepo.save(event.copyWith(chosenChoiceId: choiceId));
  }

  @override
  void dispose() {
    _fighterSub?.cancel();
    _orgSub?.cancel();
    _eventSub?.cancel();
    _randomEventSub?.cancel();
    super.dispose();
  }
}
