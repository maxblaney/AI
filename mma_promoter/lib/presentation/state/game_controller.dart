import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/utils/id_generator.dart';
import '../../data/db/database.dart';
import '../../data/models/models.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/fighter_repository.dart';
import '../../data/repositories/in_memory/in_memory_repositories.dart';
import '../../data/repositories/inbox_item_repository.dart';
import '../../data/repositories/organization_repository.dart';
import '../../data/repositories/random_event_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/seed/roster_seed.dart';
import '../../domain/calendar/game_calendar.dart';
import '../../domain/career/career_progression_engine.dart';
import '../../domain/events/random_event_engine.dart';
import '../../domain/finance/event_finance_calculator.dart';
import '../../domain/simulation/fight_resolver.dart';

/// Result of resolving one event, kept around so the results screen can
/// show a fight-by-fight breakdown without re-querying everything.
class EventSimulationSummary {
  final MmaEvent event;
  final List<Fight> resolvedCard;
  final EventFinanceResult finance;
  final List<FighterOutcomeSummary> fighterOutcomes;

  const EventSimulationSummary({
    required this.event,
    required this.resolvedCard,
    required this.finance,
    required this.fighterOutcomes,
  });
}

/// Before/after snapshot of one fighter's popularity and final injury
/// status coming out of a single event — shown on the results screen.
class FighterOutcomeSummary {
  final String fighterId;
  final String fighterName;
  final int popularityBefore;
  final int popularityAfter;
  final InjuryStatus injuryStatus;

  const FighterOutcomeSummary({
    required this.fighterId,
    required this.fighterName,
    required this.popularityBefore,
    required this.popularityAfter,
    required this.injuryStatus,
  });

  int get popularityDelta => popularityAfter - popularityBefore;
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
  final InboxItemRepositoryContract _inboxRepo;

  final FightResolver _fightResolver = FightResolver();
  final EventFinanceCalculator _financeCalculator = EventFinanceCalculator();
  final RandomEventEngine _randomEventEngine = RandomEventEngine();
  final CareerProgressionEngine _careerEngine = CareerProgressionEngine();
  final Random _rng = Random();

  StreamSubscription<List<Fighter>>? _fighterSub;
  StreamSubscription<Organization?>? _orgSub;
  StreamSubscription<List<MmaEvent>>? _eventSub;
  StreamSubscription<List<RandomEvent>>? _randomEventSub;
  StreamSubscription<List<InboxItem>>? _inboxSub;

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
      inboxRepo: InboxItemRepository(db),
    );
  }

  GameController._({
    required FighterRepositoryContract fighterRepo,
    required OrganizationRepositoryContract orgRepo,
    required EventRepositoryContract eventRepo,
    required RandomEventRepositoryContract randomEventRepo,
    required InboxItemRepositoryContract inboxRepo,
  })  : _fighterRepo = fighterRepo,
        _orgRepo = orgRepo,
        _eventRepo = eventRepo,
        _randomEventRepo = randomEventRepo,
        _inboxRepo = inboxRepo;

  /// Volatile, non-persistent mode used for the Flutter-web preview build.
  /// Game state resets on every page reload.
  GameController.inMemory()
      : _fighterRepo = InMemoryFighterRepository(),
        _orgRepo = InMemoryOrganizationRepository(),
        _eventRepo = InMemoryEventRepository(),
        _randomEventRepo = InMemoryRandomEventRepository(),
        _inboxRepo = InMemoryInboxItemRepository();

  bool isLoading = true;
  Organization? organization;
  List<Fighter> allFighters = [];
  List<MmaEvent> events = [];
  List<RandomEvent> pendingRandomEvents = [];
  List<InboxItem> inboxItems = [];

  List<Fighter> get signedRoster =>
      allFighters.where((f) => f.isSigned && !f.retired).toList();
  List<Fighter> get talentPool =>
      allFighters.where((f) => !f.isSigned && !f.retired).toList();
  List<Fighter> get retiredFighters =>
      allFighters.where((f) => f.retired).toList();
  List<Fighter> get rankedFighters =>
      allFighters.where((f) => f.isRanked && !f.retired).toList();
  List<MmaEvent> get scheduledEvents =>
      events.where((e) => !e.isCompleted).toList();
  List<MmaEvent> get completedEvents =>
      events.where((e) => e.isCompleted).toList();
  int get unreadInboxCount => inboxItems.where((i) => !i.read).length;

  /// The next scheduled event in chronological order — the only one
  /// [simulateEvent] will resolve, and the one [advanceWeek] parks on.
  MmaEvent? get nextScheduledEvent {
    final scheduled = scheduledEvents;
    if (scheduled.isEmpty) return null;
    return scheduled.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
  }

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
    // Everyone starts as a free agent — nobody's signed to "My Roster" yet.
    final pool = generateStartingRoster();

    await _orgRepo.save(org);
    for (final fighter in pool) {
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
    _inboxSub = _inboxRepo.watchAll().listen((i) {
      inboxItems = i;
      notifyListeners();
    });
  }

  Future<MmaEvent?> getEventById(String id) => _eventRepo.getById(id);

  /// A fighter's past fights, most recent first, each paired with the
  /// event they happened at (for the date/name) — used by the fighter
  /// profile's fight history list.
  Future<List<({Fight fight, MmaEvent? event})>> getFightHistory(
    String fighterId,
  ) async {
    final fights = await _eventRepo.getFightsForFighter(fighterId);
    final result = <({Fight fight, MmaEvent? event})>[];
    for (final fight in fights) {
      result.add((fight: fight, event: await _eventRepo.getById(fight.eventId)));
    }
    return result;
  }
  Future<List<Fight>> getEventCard(String id) => _eventRepo.getCard(id);

  Fighter? fighterById(String id) {
    try {
      return allFighters.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---- Roster management ------------------------------------------------

  /// Signs [fighter] to the roster on a show-money/win-bonus contract.
  /// Charges a one-time signing bonus equal to [showMoney] up front — the
  /// org can go into debt over this (see [advanceWeek]'s interest charge),
  /// there's no hard cash floor blocking a signing.
  Future<String?> signFighter(
    Fighter fighter, {
    required int showMoney,
    required int winBonus,
    required int fightsInDeal,
    bool exclusive = true,
  }) async {
    final org = organization;
    if (org == null) return 'No active organization.';

    final contract = Contract(
      id: newId(),
      fighterId: fighter.id,
      fightsRemaining: fightsInDeal,
      showMoney: showMoney,
      winBonus: winBonus,
      exclusive: exclusive,
      signedOn: GameCalendar.dateForWeek(org.currentWeek),
    );
    await _fighterRepo.sign(fighter, contract);
    await _orgRepo.save(org.copyWith(cashBalance: org.cashBalance - showMoney));
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

    final org = organization;
    if (org == null) return 'No active organization.';
    if (GameCalendar.weekNumberFor(date) <= org.currentWeek) {
      return 'Event date must be in a future week.';
    }

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

  /// Resolves [eventId]'s card, but only if it's due (its week has arrived
  /// on [Organization.currentWeek]) and it's the earliest still-scheduled
  /// event. This is what makes it structurally impossible to simulate
  /// events out of chronological order — the player can only ever reach a
  /// later event's week by first resolving everything scheduled before it
  /// (see [advanceWeek]).
  Future<EventSimulationSummary?> simulateEvent(
    String eventId, {
    required int promotionBudgetSpent,
  }) async {
    final org = organization;
    final event = await _eventRepo.getById(eventId);
    if (org == null || event == null || event.isCompleted) return null;
    if (GameCalendar.weekNumberFor(event.date) > org.currentWeek) return null;

    final earliest = nextScheduledEvent;
    if (earliest == null || earliest.id != event.id) return null;

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
        rounds: fight.rounds,
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

    final fighterOutcomes = <FighterOutcomeSummary>[];
    for (final fight in resolvedCard) {
      await _eventRepo.saveFight(fight);
      fighterOutcomes.addAll(await _applyFightOutcome(fight, fighterLookup));
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
      fighterOutcomes: fighterOutcomes,
    );
  }

  // ---- Game clock ---------------------------------------------------------

  /// Advances the game's own clock ([Organization.currentWeek]) by one
  /// week, refreshing the talent pool and healing injuries as it goes.
  /// Refuses to advance past a week where a scheduled event has already
  /// come due — the player must resolve it first via [simulateEvent]. This
  /// is the single mechanism that makes booking/playing events out of
  /// chronological order impossible.
  Future<String?> advanceWeek() async {
    final org = organization;
    if (org == null) return 'No active organization.';

    final due = nextScheduledEvent;
    if (due != null && GameCalendar.weekNumberFor(due.date) <= org.currentWeek) {
      return '"${due.name}" is ready to run — resolve it before advancing further.';
    }

    var updated = org.copyWith(currentWeek: org.currentWeek + 1);
    updated = _applyDebtInterest(updated);
    await _orgRepo.save(updated);
    organization = updated;

    updated = await _maybeRefreshTalentPool(updated);
    await _healInjuries(updated);
    await _maybeGenerateFightRequests(updated);

    organization = updated;
    notifyListeners();
    return null;
  }

  /// Running a promotion in the red isn't free — a negative cash balance
  /// accrues interest every week, same as any other debt. 1%/week compounds
  /// to a real bite (~68% APR) if left unpaid, which is the point: debt is
  /// a tool for a cash crunch, not a way to permanently outspend income.
  /// Public so the Finance screen can show the player the rate they're
  /// paying.
  static const double weeklyDebtInterestRate = 0.01;

  Organization _applyDebtInterest(Organization org) {
    if (org.cashBalance >= 0) return org;
    final interest = (-org.cashBalance * weeklyDebtInterestRate).round();
    return org.copyWith(cashBalance: org.cashBalance - interest);
  }

  /// Tops up the talent pool with ~10 fresh free agents for every 4 game
  /// weeks that have passed since the last refresh.
  Future<Organization> _maybeRefreshTalentPool(Organization org) async {
    const weeksPerRefresh = 4;
    final weeksElapsed = org.currentWeek - org.lastTalentRefreshWeek;
    if (weeksElapsed < weeksPerRefresh) return org;

    final refreshes = weeksElapsed ~/ weeksPerRefresh;
    for (var i = 0; i < refreshes; i++) {
      for (final fighter in generateMonthlyTalentPool()) {
        await _fighterRepo.save(fighter);
      }
    }
    final updated = org.copyWith(
      lastTalentRefreshWeek: org.lastTalentRefreshWeek + refreshes * weeksPerRefresh,
    );
    await _orgRepo.save(updated);
    return updated;
  }

  /// Clears any injury whose countdown has reached [Organization.currentWeek].
  Future<void> _healInjuries(Organization org) async {
    for (final fighter in allFighters) {
      final clearsAt = fighter.injuryClearsAtWeek;
      if (clearsAt != null && clearsAt <= org.currentWeek) {
        await _fighterRepo.save(fighter.copyWith(
          injuryStatus: InjuryStatus.healthy,
          clearInjuryClearsAtWeek: true,
        ));
      }
    }
  }

  /// Small per-week chance for an idle, healthy, signed fighter with no
  /// upcoming booking to ask for a fight — surfaced in the Inbox.
  Future<void> _maybeGenerateFightRequests(Organization org) async {
    final bookedFighterIds = <String>{};
    for (final event in scheduledEvents) {
      final card = await _eventRepo.getCard(event.id);
      for (final fight in card) {
        bookedFighterIds.add(fight.fighterAId);
        bookedFighterIds.add(fight.fighterBId);
      }
    }

    for (final fighter in signedRoster) {
      if (bookedFighterIds.contains(fighter.id)) continue;
      if (!fighter.isAvailableToFight) continue;
      final hasPending = inboxItems.any(
        (i) =>
            i.type == InboxItemType.fightRequest &&
            i.fighterId == fighter.id &&
            !i.read,
      );
      if (hasPending) continue;
      if (_rng.nextDouble() >= 0.05) continue;

      await _inboxRepo.save(_newInboxItem(
        org,
        InboxItemType.fightRequest,
        fighterId: fighter.id,
        title: '${fighter.name} wants a fight',
        body: '${fighter.name} is healthy and idle, and is asking to be booked.',
      ));
    }
  }

  InboxItem _newInboxItem(
    Organization org,
    InboxItemType type, {
    required String title,
    required String body,
    String? fighterId,
  }) {
    return InboxItem(
      id: newId(),
      type: type,
      week: org.currentWeek,
      title: title,
      body: body,
      fighterId: fighterId,
    );
  }

  Future<void> markInboxItemRead(String id) => _inboxRepo.markRead(id);

  Future<List<FighterOutcomeSummary>> _applyFightOutcome(
    Fight fight,
    Map<String, Fighter> fighterLookup,
  ) async {
    final result = fight.result;
    if (result == null) return [];
    final a = fighterLookup[fight.fighterAId];
    final b = fighterLookup[fight.fighterBId];
    if (a == null || b == null) return [];

    final scoreA = result.isDraw ? 0.5 : (result.winnerId == a.id ? 1.0 : 0.0);
    final (newEloA, newEloB) =
        _careerEngine.updateElo(a.eloRating, b.eloRating, scoreA);

    if (result.isDraw) {
      final updatedA = await _applyPostFight(
        a,
        record: a.record.addDraw(),
        eloRating: newEloA,
        injuryFromFight: result.fighterAInjury,
      );
      final updatedB = await _applyPostFight(
        b,
        record: b.record.addDraw(),
        eloRating: newEloB,
        injuryFromFight: result.fighterBInjury,
      );
      await _fighterRepo.save(updatedA);
      await _fighterRepo.save(updatedB);
      return [_outcomeOf(a, updatedA), _outcomeOf(b, updatedB)];
    }

    final winner = result.winnerId == a.id ? a : b;
    final loser = result.winnerId == a.id ? b : a;
    final winnerNewElo = result.winnerId == a.id ? newEloA : newEloB;
    final loserNewElo = result.winnerId == a.id ? newEloB : newEloA;
    final winnerInjury =
        result.winnerId == a.id ? result.fighterAInjury : result.fighterBInjury;
    final loserInjury =
        result.winnerId == a.id ? result.fighterBInjury : result.fighterAInjury;

    final updatedWinner = await _applyPostFight(
      winner,
      record: winner.record.addWin(),
      winStreak: winner.winStreak + 1,
      lossStreak: 0,
      eloRating: winnerNewElo,
      popularityDelta: 2 + result.winnerPerformanceRating ~/ 20,
      moraleDelta: 8,
      injuryFromFight: winnerInjury,
    );
    final updatedLoser = await _applyPostFight(
      loser,
      record: loser.record.addLoss(),
      winStreak: 0,
      lossStreak: loser.lossStreak + 1,
      eloRating: loserNewElo,
      popularityDelta: 1,
      moraleDelta: -10,
      injuryFromFight: loserInjury,
    );
    await _fighterRepo.save(updatedWinner);
    await _fighterRepo.save(updatedLoser);
    return [_outcomeOf(winner, updatedWinner), _outcomeOf(loser, updatedLoser)];
  }

  FighterOutcomeSummary _outcomeOf(Fighter before, Fighter after) {
    return FighterOutcomeSummary(
      fighterId: after.id,
      fighterName: after.name,
      popularityBefore: before.popularity,
      popularityAfter: after.popularity,
      injuryStatus: after.injuryStatus,
    );
  }

  Future<Fighter> _applyPostFight(
    Fighter fighter, {
    required FightRecord record,
    int? winStreak,
    int? lossStreak,
    int? eloRating,
    int popularityDelta = 0,
    int moraleDelta = 0,
    InjuryStatus injuryFromFight = InjuryStatus.healthy,
  }) async {
    final newWinStreak = winStreak ?? fighter.winStreak;
    final newLossStreak = lossStreak ?? fighter.lossStreak;
    final newInjuryStatus = _worseInjury(fighter.injuryStatus, injuryFromFight);
    var updated = fighter.copyWith(
      record: record,
      winStreak: newWinStreak,
      lossStreak: newLossStreak,
      eloRating: eloRating ?? fighter.eloRating,
      // Ranked as soon as they've had one fight in their division.
      isRanked: true,
      popularity: (fighter.popularity + popularityDelta).clamp(0, 100),
      morale: (fighter.morale + moraleDelta).clamp(0, 100),
      // Fighting never heals a pre-existing injury, only matches or
      // worsens it with whatever this fight itself caused.
      injuryStatus: newInjuryStatus,
    );
    updated = updated.copyWith(
      potential: _careerEngine.adjustPotential(
        updated,
        winStreak: newWinStreak,
        lossStreak: newLossStreak,
      ),
    );
    if (updated.contract != null) {
      updated = updated.copyWith(contract: updated.contract!.afterFight());
    }

    // A fresh, worse-than-before injury gets a healing countdown and, if
    // this fighter is on the player's roster, an Inbox notification.
    final org = organization;
    final isNewInjury = _injurySeverity[newInjuryStatus]! >
        _injurySeverity[fighter.injuryStatus]!;
    if (isNewInjury && newInjuryStatus != InjuryStatus.healthy && org != null) {
      final healingWeeks = _careerEngine.rollHealingWeeks(newInjuryStatus);
      updated = updated.copyWith(
        injuryClearsAtWeek: org.currentWeek + healingWeeks,
      );
      if (updated.isSigned) {
        await _inboxRepo.save(_newInboxItem(
          org,
          InboxItemType.injury,
          fighterId: updated.id,
          title: '${updated.name} injured',
          body: '${updated.name} suffered a ${newInjuryStatus.name} injury '
              'and will be out for roughly $healingWeeks weeks.',
        ));
      }
    }

    final wasRetired = fighter.retired;
    final wasSigned = updated.isSigned;
    final result = _careerEngine.maybeRetire(updated);
    if (!wasRetired && result.retired && wasSigned && org != null) {
      await _inboxRepo.save(_newInboxItem(
        org,
        InboxItemType.retirement,
        fighterId: result.id,
        title: '${result.name} has retired',
        body: '${result.name} announced their retirement. '
            'Reason: ${result.retirementReason ?? 'Unknown'}.',
      ));
    }
    return result;
  }

  static const _injurySeverity = {
    InjuryStatus.healthy: 0,
    InjuryStatus.minor: 1,
    InjuryStatus.major: 2,
  };

  InjuryStatus _worseInjury(InjuryStatus a, InjuryStatus b) {
    return _injurySeverity[a]! >= _injurySeverity[b]! ? a : b;
  }

  // ---- Fight night awards -------------------------------------------------

  /// Pays a reputation-scaled bonus to both fighters in [fightId] and gives
  /// them a small popularity/morale bump. One-time per event.
  Future<String?> awardFightOfTheNight(String eventId, String fightId) async {
    final org = organization;
    if (org == null) return 'No active organization.';
    final event = await _eventRepo.getById(eventId);
    if (event == null) return 'Event not found.';
    if (event.fightOfTheNightFightId != null) return 'Already awarded.';

    final card = await _eventRepo.getCard(eventId);
    Fight? fight;
    for (final f in card) {
      if (f.id == fightId) {
        fight = f;
        break;
      }
    }
    if (fight == null) return 'Fight not found.';

    final bonus = org.reputationTier.nightlyBonusAmount;
    await _eventRepo.saveEvent(event.copyWith(fightOfTheNightFightId: fightId));
    await _orgRepo.save(org.copyWith(cashBalance: org.cashBalance - bonus));

    for (final id in [fight.fighterAId, fight.fighterBId]) {
      final fighter = fighterById(id);
      if (fighter == null) continue;
      await _fighterRepo.save(fighter.copyWith(
        popularity: (fighter.popularity + 5).clamp(0, 100),
        morale: (fighter.morale + 5).clamp(0, 100),
      ));
    }
    return null;
  }

  /// Pays a reputation-scaled bonus to [fighterId] and gives them a
  /// popularity/morale bump. One-time per event.
  Future<String?> awardPerformanceOfTheNight(
    String eventId,
    String fighterId,
  ) async {
    final org = organization;
    if (org == null) return 'No active organization.';
    final event = await _eventRepo.getById(eventId);
    if (event == null) return 'Event not found.';
    if (event.performanceOfTheNightFighterId != null) return 'Already awarded.';

    final bonus = org.reputationTier.nightlyBonusAmount;
    await _eventRepo.saveEvent(
      event.copyWith(performanceOfTheNightFighterId: fighterId),
    );
    await _orgRepo.save(org.copyWith(cashBalance: org.cashBalance - bonus));

    final fighter = fighterById(fighterId);
    if (fighter != null) {
      await _fighterRepo.save(fighter.copyWith(
        popularity: (fighter.popularity + 8).clamp(0, 100),
        morale: (fighter.morale + 8).clamp(0, 100),
      ));
    }
    return null;
  }

  // ---- Random events --------------------------------------------------

  Future<void> _maybeTriggerRandomEvent() async {
    if (pendingRandomEvents.isNotEmpty) return; // one at a time for v1.
    final asOf = organization == null
        ? DateTime.now()
        : GameCalendar.dateForWeek(organization!.currentWeek);
    final event = _randomEventEngine.maybeGenerate(signedRoster, asOf);
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
    _inboxSub?.cancel();
    super.dispose();
  }
}
