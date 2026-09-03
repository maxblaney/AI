import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/utils/id_generator.dart';
import '../../data/db/database.dart';
import '../../data/models/models.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/fighter_pack_repository.dart';
import '../../data/repositories/fighter_repository.dart';
import '../../data/repositories/in_memory/in_memory_repositories.dart';
import '../../data/repositories/inbox_item_repository.dart';
import '../../data/repositories/organization_repository.dart';
import '../../data/repositories/random_event_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/repositories/save_scope.dart';
import '../../data/seed/roster_seed.dart';
import '../../domain/betting/fight_odds.dart';
import '../../domain/booking/card_matchmaker.dart';
import '../../domain/calendar/game_calendar.dart';
import '../../domain/condition/fighter_condition.dart';
import '../../domain/career/career_progression_engine.dart';
import '../../domain/events/random_event_engine.dart';
import '../../domain/packs/fighter_pack.dart';
import '../../domain/growth/fanbase_growth.dart';
import '../../domain/simulation/fight_excitement.dart';
import '../../domain/finance/event_finance_calculator.dart';
import '../../domain/finance/pay_scale.dart';
import '../../domain/finance/payroll_health.dart';
import '../../domain/finance/running_costs.dart';
import '../../domain/history/head_to_head.dart';
import '../../domain/history/recent_form.dart';
import '../../domain/history/record_book.dart';
import '../../domain/rankings/division_rankings.dart';
import '../../domain/incidents/roster_incidents.dart';
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

/// A fighter's next booked bout, for showing "who am I matched with" on
/// the roster without every row hitting the database.
class FighterBooking {
  final String eventId;
  final String eventName;
  final DateTime date;
  final String opponentId;
  final bool isTitleFight;
  final bool isMainEvent;

  const FighterBooking({
    required this.eventId,
    required this.eventName,
    required this.date,
    required this.opponentId,
    required this.isTitleFight,
    required this.isMainEvent,
  });
}

/// The single app-wide source of truth for game state. Owns the DB,
/// repositories and domain engines, exposes plain data to widgets via
/// [ChangeNotifier], and is the only place UI code should mutate game
/// state through.
class GameController extends ChangeNotifier {
  /// Which save every repository reads and writes. Mutating this is how
  /// switching saves works — see [loadSave].
  final SaveScope _scope;

  final FighterRepositoryContract _fighterRepo;
  final OrganizationRepositoryContract _orgRepo;
  final EventRepositoryContract _eventRepo;
  final RandomEventRepositoryContract _randomEventRepo;
  final InboxItemRepositoryContract _inboxRepo;
  final FighterPackRepositoryContract _packRepo;

  // Every source of chance in the game hangs off one generator, so a
  // test can seed the whole controller and get the same save twice.
  // Left unseeded in the app, where the point is that no two playthroughs
  // are alike.
  final FightResolver _fightResolver;
  final EventFinanceCalculator _financeCalculator;
  final RandomEventEngine _randomEventEngine;
  final RosterIncidentEngine _incidentEngine;
  final CareerProgressionEngine _careerEngine = CareerProgressionEngine();
  final Random _rng;

  StreamSubscription<List<Fighter>>? _fighterSub;
  StreamSubscription<Organization?>? _orgSub;
  StreamSubscription<List<MmaEvent>>? _eventSub;
  StreamSubscription<List<RandomEvent>>? _randomEventSub;
  StreamSubscription<List<InboxItem>>? _inboxSub;

  /// Persists to on-device SQLite via Drift. This is the real, shipping
  /// backend — not available on Flutter web (no `dart:io`), which is why
  /// [GameController.inMemory] exists separately.
  /// [random] seeds every roll the controller makes — fight outcomes,
  /// gate noise, roster incidents. Tests pass one so a run is repeatable;
  /// the app leaves it null.
  factory GameController({AppDatabase? database, Random? random}) {
    final db = database ?? AppDatabase();
    final scope = SaveScope();
    return GameController._(
      scope: scope,
      fighterRepo: FighterRepository(db, scope),
      orgRepo: OrganizationRepository(db, scope),
      eventRepo: EventRepository(db, scope),
      randomEventRepo: RandomEventRepository(db, scope),
      inboxRepo: InboxItemRepository(db, scope),
      // Not scoped: a pack belongs to the player, not to one promotion.
      packRepo: FighterPackRepository(db),
      random: random,
    );
  }

  GameController._({
    required SaveScope scope,
    required FighterRepositoryContract fighterRepo,
    required OrganizationRepositoryContract orgRepo,
    required EventRepositoryContract eventRepo,
    required RandomEventRepositoryContract randomEventRepo,
    required InboxItemRepositoryContract inboxRepo,
    required FighterPackRepositoryContract packRepo,
    Random? random,
  })  : _scope = scope,
        _fighterRepo = fighterRepo,
        _orgRepo = orgRepo,
        _eventRepo = eventRepo,
        _randomEventRepo = randomEventRepo,
        _inboxRepo = inboxRepo,
        _packRepo = packRepo,
        _rng = random ?? Random(),
        _fightResolver = FightResolver(random: random),
        _financeCalculator = EventFinanceCalculator(random: random),
        _randomEventEngine = RandomEventEngine(random: random),
        _incidentEngine = RosterIncidentEngine(random: random);

  /// Volatile, non-persistent mode used for the Flutter-web preview build.
  /// Game state resets on every page reload.
  GameController.inMemory({Random? random})
      : _scope = SaveScope(),
        _fighterRepo = InMemoryFighterRepository(),
        _orgRepo = InMemoryOrganizationRepository(),
        _eventRepo = InMemoryEventRepository(),
        _randomEventRepo = InMemoryRandomEventRepository(),
        _inboxRepo = InMemoryInboxItemRepository(),
        _packRepo = InMemoryFighterPackRepository(),
        _rng = random ?? Random(),
        _fightResolver = FightResolver(random: random),
        _financeCalculator = EventFinanceCalculator(random: random),
        _randomEventEngine = RandomEventEngine(random: random),
        _incidentEngine = RosterIncidentEngine(random: random);

  bool isLoading = true;
  Organization? organization;
  List<Fighter> allFighters = [];
  List<MmaEvent> events = [];
  List<RandomEvent> pendingRandomEvents = [];
  List<InboxItem> inboxItems = [];

  /// Who each fighter is currently matched against, keyed by fighter id.
  /// Rebuilt whenever the event list changes.
  Map<String, FighterBooking> bookingsByFighterId = {};

  /// Every fighter's last few results, newest first, keyed by id.
  ///
  /// Built in one pass over the promotion's resolved fights rather than
  /// a query per fighter: the roster screen shows a form line on every
  /// row, and four hundred separate lookups behind a scrolling list is
  /// not a thing to do.
  Map<String, List<FormEntry>> recentFormByFighterId = {};

  /// The same pass's raw material: every resolved fight each fighter has
  /// had here, newest first. Kept alongside the form lines so a caller
  /// can ask a question the five-fight summary can't answer — chiefly
  /// whether two given fighters have already met.
  Map<String, List<Fight>> _resolvedFightsByFighterId = {};

  /// How many times each pair of fighters has already met here, keyed by
  /// [CardMatchmaker.pairKey]. Handed to the auto-filler so it stops
  /// short of rebooking the same bout every month.
  Map<String, int> priorMeetingsByPair = {};

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

  /// True when there's no save open — the UI shows the saves screen
  /// instead of the dashboard. On a fresh install that means no saves
  /// exist yet; later it also covers leaving a game to pick another.
  bool needsNewGame = false;

  /// Set when startup failed — most likely the browser refusing to open
  /// the save database. Surfaced by the UI instead of leaving the player
  /// on a spinner that never resolves.
  String? initError;

  /// Which save is currently open, or null on the saves screen.
  String? get activeSaveId => _scope.saveId;

  /// Opens the most recently played save, or lands on the saves screen if
  /// there isn't one. Never auto-creates a game: with several saves on the
  /// device, silently starting a new one would bury them.
  Future<void> init() async {
    try {
      final saves = await _orgRepo.listAll();
      if (saves.isEmpty) {
        needsNewGame = true;
        isLoading = false;
        notifyListeners();
        return;
      }
      await _openSave(saves.first.organization.id);
    } catch (error, stack) {
      initError = '$error\n\n$stack';
    }
    isLoading = false;
    notifyListeners();
  }

  /// Every save on this device, most recently played first.
  Future<List<SaveSummary>> listSaves() => _orgRepo.listAll();

  /// Switches to an existing save, tearing down the current one's streams
  /// first so its rows can't leak into the newly opened game.
  Future<void> loadSave(String saveId) async {
    await _openSave(saveId);
    notifyListeners();
  }

  Future<void> _openSave(String saveId) async {
    await _cancelSubscriptions();
    _clearGameState();

    _scope.saveId = saveId;
    await _orgRepo.touch(saveId, DateTime.now());

    organization = await _orgRepo.get();
    needsNewGame = organization == null;
    if (organization != null) await _subscribeToStreams();
  }

  /// Closes the current save and returns to the saves screen without
  /// touching what's on disk.
  Future<void> closeSave() async {
    await _cancelSubscriptions();
    _clearGameState();
    _scope.saveId = null;
    needsNewGame = true;
    notifyListeners();
  }

  /// Permanently deletes a save. If it's the one currently open, the game
  /// falls back to the next most recent save, or to the saves screen when
  /// that was the last one.
  Future<void> deleteSave(String saveId) async {
    final wasActive = _scope.saveId == saveId;
    if (wasActive) {
      await _cancelSubscriptions();
      _clearGameState();
      _scope.saveId = null;
    }

    await _orgRepo.delete(saveId);

    if (wasActive) {
      final remaining = await _orgRepo.listAll();
      if (remaining.isEmpty) {
        needsNewGame = true;
      } else {
        await _openSave(remaining.first.organization.id);
      }
    }
    notifyListeners();
  }

  /// Seeds a brand-new save with the player's chosen org name and starting
  /// tier (which sets cash and fanbase — see [ReputationTierInfo]), then
  /// opens it. Existing saves are left alone.
  ///
  /// [signRoster] picks which of the two games this is. On, the
  /// promotion opens as a going concern with a full roster already under
  /// contract — you start by booking. Off, the roster is empty and every
  /// fighter is a free agent, so you start by signing, and the first
  /// card is one you built yourself.
  Future<void> startNewGame({
    required String orgName,
    required ReputationTier tier,
    bool signRoster = true,
  }) async {
    await _cancelSubscriptions();
    _clearGameState();

    final org = generateStartingOrganization(name: orgName, tier: tier);
    // Scope has to point at the new save before anything is written, or
    // the roster lands tagged with whichever save was open before.
    _scope.saveId = org.id;

    await _orgRepo.save(org);
    await _orgRepo.touch(org.id, DateTime.now());

    // The talent pool is there either way — it is the market, not the
    // roster.
    if (signRoster) {
      // A going concern: a full roster already under contract, twenty to
      // a division. The starting contracts cost nothing up front —
      // signing one normally charges its show money as a bonus, and 160
      // of those would bankrupt the save before week one.
      final openingWeek = GameCalendar.dateForWeek(org.currentWeek);
      for (final fighter in generateSignedRoster(
        tier: tier,
        signedOn: openingWeek,
        random: _rng,
      )) {
        await _fighterRepo.save(fighter);
      }
    }
    for (final fighter in generateStartingRoster(random: _rng)) {
      await _fighterRepo.save(fighter);
    }

    organization = org;
    needsNewGame = false;

    await _subscribeToStreams();
    notifyListeners();
  }

  Future<void> _cancelSubscriptions() async {
    await _fighterSub?.cancel();
    await _orgSub?.cancel();
    await _eventSub?.cancel();
    await _randomEventSub?.cancel();
    await _inboxSub?.cancel();
    _fighterSub = null;
    _orgSub = null;
    _eventSub = null;
    _randomEventSub = null;
    _inboxSub = null;
  }

  void _clearGameState() {
    organization = null;
    allFighters = [];
    events = [];
    pendingRandomEvents = [];
    inboxItems = [];
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
      // Cards live in a separate table, so the booking map is refreshed
      // off the back of the event list rather than watched directly.
      unawaited(_refreshBookings());
      unawaited(_refreshRecentForm());
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
  /// [fighterId]'s last few results, newest first — the form line the
  /// booking screen shows next to a fighter. A record alone hides
  /// whether a 12-4 fighter is on a run or has lost three straight.
  Future<List<FormEntry>> getRecentForm(
    String fighterId, {
    int limit = RecentForm.defaultLength,
  }) async {
    return RecentForm.from(
      fights: await _eventRepo.getFightsForFighter(fighterId),
      fighterId: fighterId,
      limit: limit,
    );
  }

  /// Where [fighter] sits on their own division's ladder — 'C', 'iC' or a
  /// contender number — or null if they have not fought here yet.
  String? divisionRankOf(Fighter fighter, {WeightClass? division}) {
    return DivisionRankings.labelFor(
      fighter,
      rankedFighters,
      division ?? fighter.weightClass,
    );
  }

  /// What [aId] and [bId] have already done to each other here. Empty
  /// (and [HeadToHead.isRematch] false) when they've never met.
  ///
  /// Synchronous on purpose: the card tiles ask this once per bout on
  /// every rebuild, and a future per tile would flicker.
  HeadToHead headToHead(String aId, String bId) => HeadToHead.from(
        fights: _resolvedFightsByFighterId[aId] ?? const [],
        aId: aId,
        bId: bId,
      );

  Future<List<Fight>> getEventCard(String id) => _eventRepo.getCard(id);

  /// How many weeks of camp a fighter got for their upcoming bout — the
  /// gap between the card being booked and the event itself. Null when
  /// they have nothing booked.
  int? campWeeksFor(String fighterId) {
    final booking = bookingsByFighterId[fighterId];
    if (booking == null) return null;
    final event = events.where((e) => e.id == booking.eventId).firstOrNull;
    if (event == null) return null;
    return (GameCalendar.weekNumberFor(event.date) - event.bookedAtWeek)
        .clamp(0, 52);
  }

  /// Rebuilds [bookingsByFighterId] from the cards of every event that
  /// hasn't been run yet.
  Future<void> _refreshBookings() async {
    final map = <String, FighterBooking>{};
    for (final event in scheduledEvents) {
      for (final fight in await _eventRepo.getCard(event.id)) {
        if (fight.isResolved) continue;
        for (final (fighterId, opponentId) in [
          (fight.fighterAId, fight.fighterBId),
          (fight.fighterBId, fight.fighterAId),
        ]) {
          map[fighterId] = FighterBooking(
            eventId: event.id,
            eventName: event.name,
            date: event.date,
            opponentId: opponentId,
            isTitleFight: fight.isTitleFight,
            isMainEvent: fight.isMainEvent,
          );
        }
      }
    }
    bookingsByFighterId = map;
    notifyListeners();
  }

  /// Rebuilds [recentFormByFighterId] from every resolved fight in the
  /// promotion.
  Future<void> _refreshRecentForm() async {
    // The repository hands these back oldest first; a form line reads
    // newest first.
    final fights = (await _eventRepo.getAllResolvedFights()).reversed.toList();
    final byFighter = <String, List<Fight>>{};
    for (final fight in fights) {
      for (final id in [fight.fighterAId, fight.fighterBId]) {
        (byFighter[id] ??= []).add(fight);
      }
    }
    _resolvedFightsByFighterId = byFighter;
    priorMeetingsByPair = {};
    for (final fight in fights) {
      if (!fight.isResolved) continue;
      final key = CardMatchmaker.pairKey(fight.fighterAId, fight.fighterBId);
      priorMeetingsByPair[key] = (priorMeetingsByPair[key] ?? 0) + 1;
    }
    recentFormByFighterId = {
      for (final entry in byFighter.entries)
        entry.key: RecentForm.from(fights: entry.value, fighterId: entry.key),
    };
    notifyListeners();
  }

  /// What share of recent takings is going to fighters, or null before
  /// the promotion has run a show.
  ///
  /// The reading that predicts a cash crisis and that nothing used to
  /// surface: a promotion can sit comfortably at 40% for years, upgrade
  /// its roster, and be paying out 145% of what its shows take before
  /// anything says so.
  PayrollHealth? get payrollHealth =>
      PayrollHealth.fromRecentEvents(completedEvents);

  /// The promotion's all-time leaderboards, built from its own fights
  /// only — a fighter's record elsewhere doesn't count toward these.
  Future<List<RecordCategory>> getRecordBook() async {
    final fights = await _eventRepo.getAllResolvedFights();
    return RecordBook.build(
      fights: fights,
      fighters: {for (final f in allFighters) f.id: f},
      events: completedEvents,
    );
  }

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
    if (RunningCosts.isOverextended(
      tier: org.reputationTier,
      cashBalance: org.cashBalance,
    )) {
      return 'The bank has cut you off — you are past '
          '\$${-RunningCosts.debtCeilingFor(org.reputationTier)} in debt. '
          'Run the events you have booked, or release fighters to cut '
          'your weekly costs, before booking anything new.';
    }
    if (GameCalendar.weekNumberFor(date) <= org.currentWeek) {
      return 'Event date must be in a future week.';
    }

    final event = MmaEvent(
      id: newId(),
      name: name,
      date: date,
      venue: venue,
      ticketPrice: ticketPrice,
      // Camp length is the gap between this and the event's own week —
      // booking short notice is what leaves fighters unprepared.
      bookedAtWeek: org.currentWeek,
    );
    await _eventRepo.saveEvent(event);
    final fightsWithEventId =
        card.map((f) => f.copyWith(eventId: event.id)).toList();
    await _eventRepo.saveCard(fightsWithEventId);
    // The events stream fires on saveEvent above, which is before the
    // card exists — so the booking map it rebuilds is empty. Rebuild it
    // once the fights are actually on disk, or the roster shows nobody
    // as booked until some later save happens to refresh it.
    await _refreshBookings();
    await _maybeTriggerRandomEvent();
    return null;
  }

  /// Rewrites a scheduled event and its card in place.
  ///
  /// A card booked six weeks out is a plan, not a commitment — a fighter
  /// gets hurt, a better matchup appears, the player changes their mind
  /// about the running order. Everything [bookEvent] validates is
  /// validated again here, plus the two rules that only apply to an event
  /// that already exists: it has to still be scheduled, and it can't be
  /// moved into a week that has already been played.
  ///
  /// Bouts the player took off the card are deleted rather than left
  /// orphaned, so they stop holding their fighters hostage in
  /// [bookingsByFighterId].
  Future<String?> updateEvent({
    required String eventId,
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

    final existing = await _eventRepo.getById(eventId);
    if (existing == null) return 'That event no longer exists.';
    if (existing.isCompleted) return 'That event has already run.';
    if (GameCalendar.weekNumberFor(date) <= org.currentWeek) {
      return 'Event date must be in a future week.';
    }

    await _eventRepo.saveEvent(existing.copyWith(
      name: name,
      date: date,
      venue: venue,
      ticketPrice: ticketPrice,
    ));

    // Whatever is no longer on the card comes off the books entirely.
    final keptIds = {for (final fight in card) fight.id};
    for (final fight in await _eventRepo.getCard(eventId)) {
      if (!keptIds.contains(fight.id)) {
        await _eventRepo.deleteFight(fight.id);
      }
    }
    await _eventRepo.saveCard(
      [for (final fight in card) fight.copyWith(eventId: eventId)],
    );
    await _refreshBookings();
    notifyListeners();
    return null;
  }

  // ---- Fighter packs ------------------------------------------------------

  /// Every saved pack, newest first. Packs live outside any one save, so
  /// this is the same list whichever promotion is open.
  Future<List<FighterPack>> listPacks() => _packRepo.getAll();

  /// Builds a pack out of [fighters] — typically a hand-picked subset of
  /// a roster or talent pool — and saves it.
  ///
  /// The fighters are copied by value, so the pack is a snapshot: fights
  /// they have afterwards in this save don't change it, and importing it
  /// somewhere else doesn't reach back into here.
  Future<FighterPack> createPack({
    required String name,
    required List<Fighter> fighters,
    String description = '',
    String author = '',
  }) async {
    final pack = FighterPack(
      id: newId(),
      name: name.trim().isEmpty ? 'Untitled Pack' : name.trim(),
      description: description.trim(),
      author: author.trim(),
      createdAt: DateTime.now(),
      fighters: fighters,
    );
    await _packRepo.save(pack);
    notifyListeners();
    return pack;
  }

  Future<void> renamePack(FighterPack pack, {
    required String name,
    String? description,
  }) async {
    await _packRepo.save(pack.copyWith(
      name: name.trim().isEmpty ? pack.name : name.trim(),
      description: description?.trim(),
    ));
    notifyListeners();
  }

  Future<void> deletePack(String id) async {
    await _packRepo.delete(id);
    notifyListeners();
  }

  /// The string a player copies out to share a pack.
  String sharePackCode(FighterPack pack) => FighterPackCodec.encode(pack);

  /// Reads a share code and saves the pack it describes.
  ///
  /// Throws [FighterPackFormatException] with something worth showing the
  /// player when the code isn't one.
  Future<FighterPack> importPackCode(String code) async {
    final pack = FighterPackCodec.decode(code, idFor: newId);
    await _packRepo.save(pack);
    notifyListeners();
    return pack;
  }

  /// Drops [pack]'s fighters into the open save's talent pool, and
  /// returns how many arrived.
  ///
  /// Free agents, always: a pack says who these fighters are, not who
  /// they fight for. The player signs the ones they want like anyone
  /// else. Ids are minted fresh here too, so the same pack can be
  /// imported into several saves — or twice into one, if you want two of
  /// somebody.
  Future<int> addPackToSave(FighterPack pack) async {
    if (organization == null) return 0;
    for (final fighter in pack.fighters) {
      await _fighterRepo.save(fighter.copyWith(id: newId(), contract: null));
    }
    notifyListeners();
    return pack.fighters.length;
  }

  // ---- Settings -----------------------------------------------------------

  /// Turns automatic contract renewals on or off for the active save.
  /// See [_handleExpiredContract] for what it actually does.
  Future<void> setAutoResignFighters(bool enabled) async {
    final org = organization;
    if (org == null || org.autoResignFighters == enabled) return;
    await _orgRepo.save(org.copyWith(autoResignFighters: enabled));
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
      // Stamp the line as it stood going in. Both fighters' Elo, record
      // and condition change the moment this card is applied, so the
      // pre-fight price is unrecoverable a second later — and it's what
      // "biggest upset" in the record book is measured against.
      final odds = OddsCalculator.forFight(a: a, b: b);
      resolvedCard.add(fight.copyWith(
        result: result,
        preFightProbabilityA: odds.probabilityA,
      ));
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
    await _applyTitleChanges(resolvedCard);

    final completedEvent = event.copyWith(
      status: EventStatus.completed,
      promotionBudgetSpent: promotionBudgetSpent,
      attendance: finance.attendance,
      ppvBuys: finance.ppvBuys,
      revenue: finance.revenue,
      expenses: finance.expenses,
      reputationChange: finance.reputationChange,
      financeBreakdown: finance.breakdown,
    );
    await _eventRepo.saveEvent(completedEvent);

    // How good the night was, as the crowd would rate it — the same 1-10
    // reading the results page shows on each fight, averaged over the
    // card. It is what decides whether the promotion grew.
    final ratings = [
      for (final fight in resolvedCard)
        if (fight.result != null)
          FightExcitement.rate(
            result: fight.result!,
            scheduledRounds: fight.rounds,
          ).rating,
    ];
    final averageExcitement = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;
    final headliner = resolvedCard.firstWhere(
      (f) => f.isMainEvent,
      orElse: () => resolvedCard.first,
    );
    final mainEventPopularity = [
      fighterLookup[headliner.fighterAId]?.popularity,
      fighterLookup[headliner.fighterBId]?.popularity,
    ].whereType<int>().fold<double>(0, (a, b) => a + b) /
        2;

    final fanChange = FanbaseGrowth.forEvent(
      fanbaseSize: org.fanbaseSize,
      attendance: finance.attendance,
      venueCapacity: event.venue.capacity,
      ppvBuys: finance.ppvBuys,
      mainEventPopularity: mainEventPopularity,
      averageExcitement: averageExcitement,
    );

    await _orgRepo.save(org.copyWith(
      cashBalance: org.cashBalance + finance.netProfit,
      reputationPoints:
          (org.reputationPoints + finance.reputationChange).clamp(0, 1 << 30),
      fanbaseSize: (org.fanbaseSize + fanChange).clamp(0, 1 << 30),
    ));
    await _maybePromoteTier();

    await _maybeTriggerRandomEvent();

    return EventSimulationSummary(
      event: completedEvent,
      resolvedCard: resolvedCard,
      finance: finance,
      fighterOutcomes: fighterOutcomes,
    );
  }

  /// Sets the promotion's banked reputation outright.
  ///
  /// Only for tests: reaching a tier threshold honestly takes dozens of
  /// simulated cards, and the thing under test is what happens when the
  /// line is crossed, not how long the crossing takes.
  @visibleForTesting
  Future<void> debugSetReputationPoints(int points) async {
    final org = organization;
    if (org == null) return;
    await _orgRepo.save(org.copyWith(reputationPoints: points));
  }

  /// Moves the promotion up a tier once it has earned the reputation for
  /// it, and says so in the mailbox.
  ///
  /// The tier used to be chosen at new-game and then never change: you
  /// banked reputation for years and it bought nothing, and a Local
  /// promotion could never become a National one. That made the ladder a
  /// difficulty select rather than the progression it reads as. This is
  /// the thing reputation is *for*.
  ///
  /// Climbing is not free — a bigger operation costs more to run every
  /// week, and the roster does not improve just because the letterhead
  /// did — but it unlocks pay-per-view at National, which is where the
  /// money above a gate actually lives.
  ///
  /// Promotion only. A bad year costs reputation, and can cost the
  /// progress toward the *next* tier, but does not take back a tier
  /// already reached.
  Future<void> _maybePromoteTier() async {
    final org = organization;
    if (org == null) return;
    final next = org.reputationTier.nextTier;
    if (next == null) return;
    if (org.reputationPoints < next.reputationRequired) return;

    await _orgRepo.save(org.copyWith(reputationTier: next));
    final perks = next.promotionPerks
        .map((p) => '\u2022 $p')
        .join('\n');
    await _inboxRepo.save(_newInboxItem(
      org,
      InboxItemType.promotion,
      title: '${org.name} is now a ${next.label} promotion',
      body: 'You have built enough of a reputation to be spoken of as a '
          '${next.label.toLowerCase()} outfit.\n\n$perks\n\nRunning an '
          'operation this size costs more every week — check the '
          'dashboard before you book the next one.',
    ));

    // Recurse: a single huge night should not strand the promotion one
    // threshold below where its reputation already puts it.
    await _maybePromoteTier();
  }

  /// Moves belts after a card. Winning a championship fight takes that
  /// *division's* title off whoever held it; winning an interim fight
  /// takes the interim belt, which is tracked apart because it doesn't
  /// displace the undisputed champion. A draw leaves the belt where it
  /// is, as it does in the sport.
  ///
  /// Belts are per-division rather than per-fighter, which is what makes
  /// a double champ possible: a lightweight champion who takes the
  /// welterweight belt keeps both, and only loses the one he defends and
  /// drops.
  ///
  /// Fighters are re-read rather than taken from [allFighters], which is
  /// stream-backed and may still be a step behind the record and Elo
  /// updates written moments ago — copying from a stale one would undo
  /// them.
  Future<void> _applyTitleChanges(List<Fight> card) async {
    for (final fight in card) {
      final result = fight.result;
      if (result == null || !fight.isTitleFight || result.isDraw) continue;

      final interim = fight.titleFightType == TitleFightType.interim;
      final division = fight.weightClass;

      // Only three kinds of fighter can change hands here: the winner,
      // the loser, and whoever was holding this belt coming in (usually
      // one of the two, but not if the champ was stripped or the belt was
      // vacant).
      final affectedIds = <String>{
        fight.fighterAId,
        fight.fighterBId,
        ...allFighters
            .where((f) => interim
                ? f.interimChampionOf(division)
                : f.championOf(division))
            .map((f) => f.id),
      };

      for (final id in affectedIds) {
        final fresh = await _fighterRepo.getById(id);
        if (fresh == null) continue;
        final isWinner = id == result.winnerId;

        final belts = {...fresh.belts};
        final interimBelts = {...fresh.interimBelts};
        if (interim) {
          isWinner ? interimBelts.add(division) : interimBelts.remove(division);
        } else {
          if (isWinner) {
            belts.add(division);
            // Unifying ends your own interim claim in that division.
            interimBelts.remove(division);
          } else {
            belts.remove(division);
          }
        }
        if (setEquals(belts, fresh.belts) &&
            setEquals(interimBelts, fresh.interimBelts)) {
          continue;
        }
        await _fighterRepo.save(
          fresh.copyWith(belts: belts, interimBelts: interimBelts),
        );
      }
    }
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
    updated = _applyWeeklyOverhead(updated);
    updated = _applyDebtInterest(updated);
    await _orgRepo.save(updated);
    organization = updated;

    updated = await _maybeRefreshTalentPool(updated);
    updated = await _maybeAgeEveryone(updated);
    await _maybeWarnRosterThin(updated);
    await _healInjuries(updated);
    await _clearExpiredSuspensions(updated);
    await _maybeRollIncident(updated);
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
      // Stamped with the week they turned up, so the scouting view can
      // tell a fighter who arrived this month from one who has been on
      // the market for three years.
      final arrivedWeek = org.lastTalentRefreshWeek + (i + 1) * weeksPerRefresh;
      for (final fighter in generateMonthlyTalentPool(random: _rng)) {
        await _fighterRepo.save(fighter.copyWith(arrivedWeek: arrivedWeek));
      }
    }
    final updated = org.copyWith(
      lastTalentRefreshWeek: org.lastTalentRefreshWeek + refreshes * weeksPerRefresh,
    );
    await _orgRepo.save(updated);
    return updated;
  }

  /// How few fighters under contract counts as a roster in trouble.
  ///
  /// A full card is ten bouts, so twenty bodies — and that is before
  /// injuries, suspensions and the fact that they have to be spread
  /// across divisions to face each other at all. Forty is roughly the
  /// point where the next card starts being hard to make.
  static const int rosterThinThreshold = 40;

  /// How long to leave it before saying so again.
  static const int _rosterWarningCooldownWeeks = 26;

  /// Says something when the roster is running down.
  ///
  /// Fighters retire and nothing signs replacements — that part is the
  /// player's job and should be. What was not reasonable is that the job
  /// was invisible: the first sign of trouble was a booking screen that
  /// would not build a card, years after the drift began.
  Future<void> _maybeWarnRosterThin(Organization org) async {
    final count = signedRoster.length;
    if (count > rosterThinThreshold) return;

    final recentlyWarned = inboxItems.any((i) =>
        i.type == InboxItemType.contract &&
        i.title.contains('roster is thinning') &&
        org.currentWeek - i.week < _rosterWarningCooldownWeeks);
    if (recentlyWarned) return;

    final pool = talentPool.length;
    await _inboxRepo.save(_newInboxItem(
      org,
      InboxItemType.contract,
      title: 'Your roster is thinning',
      body: 'You have $count fighters under contract. A full card needs '
          'twenty bodies spread across the divisions, before injuries and '
          'suspensions — at this rate the next one will be hard to make.'
          '\n\nThere are $pool free agents looking for work. Sign some.',
    ));
  }

  /// Gives everyone in the game world a birthday once a year.
  ///
  /// Ages were stamped at generation and never moved, which had two
  /// consequences the game was quietly living with. The retirement
  /// engine's age rule — a rising chance from 34 — could only ever fire
  /// for a fighter *generated* old, so careers never ended of their own
  /// accord. And the talent pool never turned over: measured across
  /// twelve years it grew to 1,840 fighters, none of whom would ever
  /// mature into anything or age out of it, while the player's own
  /// roster drained 160 to 31 because retirement only ever took from the
  /// signed side.
  ///
  /// Everyone ages, not just the roster — a prospect the player has been
  /// watching should be twenty-five when they finally sign him, and the
  /// pool should retire its own veterans rather than hoarding them
  /// forever.
  Future<Organization> _maybeAgeEveryone(Organization org) async {
    const weeksPerYear = 52;
    final elapsed = org.currentWeek - org.lastAgedWeek;
    if (elapsed < weeksPerYear) return org;

    final years = elapsed ~/ weeksPerYear;
    for (final fighter in allFighters) {
      if (fighter.retired) continue;
      var aged = fighter.copyWith(age: (fighter.age + years).clamp(18, 60));

      // Retirement is rolled after a fight, so it only ever reached
      // fighters the player was booking. Free agents aged and aged and
      // never left: the pool grew to 1,530 with a mean age of 35 and
      // nobody in it would ever go away. A fighter nobody is booking
      // retires too — quietly, on their own birthday, which is closer to
      // how careers actually end than a press conference is.
      if (!aged.isSigned) {
        for (var i = 0; i < years; i++) {
          aged = _careerEngine.maybeRetire(aged);
          if (aged.retired) break;
        }
      }
      await _fighterRepo.save(aged);
    }
    final updated = org.copyWith(
      lastAgedWeek: org.lastAgedWeek + years * weeksPerYear,
    );
    await _orgRepo.save(updated);
    return updated;
  }

  /// Clears any injury whose countdown has reached [Organization.currentWeek].
  /// Weekly upkeep on every fighter: injuries that have run their course
  /// clear, and everyone recovers a little condition. Only fighters who
  /// actually change are written back.
  Future<void> _healInjuries(Organization org) async {
    for (final fighter in allFighters) {
      final clearsAt = fighter.injuryClearsAtWeek;
      final injuryOver = clearsAt != null && clearsAt <= org.currentWeek;
      final recovered =
          FighterConditionCalculator.conditionAfterRest(fighter.condition);

      if (!injuryOver && recovered == fighter.condition) continue;

      await _fighterRepo.save(
        injuryOver
            ? fighter.copyWith(
                injuryStatus: InjuryStatus.healthy,
                clearInjuryClearsAtWeek: true,
                condition: recovered,
              )
            : fighter.copyWith(condition: recovered),
      );
    }
  }

  /// Charges a week of running the promotion: staff and premises, plus a
  /// retainer for everyone under contract.
  ///
  /// This is what stops money being a scoreboard. Sitting still now costs
  /// something, so a card has to be worth putting on, and a roster you
  /// never book is a roster you are paying for.
  Organization _applyWeeklyOverhead(Organization org) {
    final cost = RunningCosts.weekly(
      tier: org.reputationTier,
      roster: signedRoster,
    );
    return org.copyWith(cashBalance: org.cashBalance - cost);
  }

  /// What a week currently costs, for the dashboard to show before the
  /// player advances into it.
  int get weeklyOverhead => organization == null
      ? 0
      : RunningCosts.weekly(
          tier: organization!.reputationTier,
          roster: signedRoster,
        );

  /// True when the bank has stopped the promotion booking anything new.
  bool get isOverextended => organization != null &&
      RunningCosts.isOverextended(
        tier: organization!.reputationTier,
        cashBalance: organization!.cashBalance,
      );

  /// The debt the promotion cannot go past.
  int get debtCeiling => organization == null
      ? 0
      : RunningCosts.debtCeilingFor(organization!.reputationTier);

  /// Lifts suspensions that have run their term, and tells the player —
  /// a fighter coming off a six-month ban is bookable again, and that's
  /// news you'd otherwise have to go looking for.
  Future<void> _clearExpiredSuspensions(Organization org) async {
    for (final fighter in allFighters) {
      final until = fighter.suspendedUntilWeek;
      if (until == null || until > org.currentWeek) continue;

      await _fighterRepo.save(fighter.copyWith(clearSuspension: true));
      if (fighter.isSigned) {
        await _inboxRepo.save(_newInboxItem(
          org,
          InboxItemType.suspension,
          fighterId: fighter.id,
          title: '${fighter.name} is eligible again',
          body: '${fighter.name} has served their suspension in full and can '
              'be booked from this week.',
        ));
      }
    }
  }

  /// Says so in the mailbox when a fighter has one fight left on their
  /// deal, before it runs out rather than after.
  ///
  /// Only matters when [Organization.autoResignFighters] is off, which
  /// is the case where the player is doing the contracts themselves —
  /// and the whole problem with letting a deal lapse used to be that the
  /// first you heard of it was the note saying the man had already
  /// gone.
  Future<void> _maybeWarnContractExpiring(Fighter fighter) async {
    final contract = fighter.contract;
    final org = organization;
    if (contract == null || org == null) return;
    if (org.autoResignFighters) return;
    if (contract.fightsRemaining != 1) return;

    await _inboxRepo.save(_newInboxItem(
      org,
      InboxItemType.contract,
      fighterId: fighter.id,
      title: '${fighter.name} has one fight left',
      body: '${fighter.name} has one bout left on their deal. Fight it out '
          'without re-signing them and they leave as a free agent — '
          'getting them back then costs a signing bonus like anyone else '
          'in the pool.',
    ));
  }

  /// What happens when the fight just fought was the last one on the
  /// deal.
  ///
  /// With [Organization.autoResignFighters] on, the fighter is put on a
  /// fresh contract at what they are worth *now* — which after a good
  /// run is more than they were on — and the mailbox says what it cost.
  /// With it off nothing changes except a note that the deal is up, so
  /// the player can negotiate it themselves.
  ///
  /// An expired contract does not eject a fighter from the roster on its
  /// own; this is about keeping the deal current, not about attrition.
  Future<Fighter> _handleExpiredContract(Fighter fighter) async {
    final contract = fighter.contract;
    final org = organization;
    if (contract == null || !contract.isExpired || org == null) return fighter;

    if (!org.autoResignFighters) {
      // They leave. An expired contract used to be a note in the mailbox
      // and nothing else, which meant the whole contract system — pay
      // scale, fight counts, the auto-re-sign setting — had no
      // consequence attached to neglecting it. Now a deal you let run out
      // costs you the fighter, and getting them back costs a signing
      // bonus like anyone else in the pool.
      await _inboxRepo.save(_newInboxItem(
        org,
        InboxItemType.contract,
        fighterId: fighter.id,
        title: '${fighter.name} has left',
        body: '${fighter.name} fought out their deal and is now a free '
            'agent. They are back in the talent pool — you can re-sign '
            'them, but so can anyone, and it will cost a signing bonus.',
      ));
      return fighter.copyWith(clearContract: true);
    }

    // Market rate, not the old rate: a fighter who went 3-0 on the last
    // deal has priced himself up, and re-signing him quietly at the old
    // number would be the setting doing the player a favour it hasn't
    // earned.
    final rate = PayScale.suggest(
      overall: fighter.overall,
      popularity: fighter.popularity,
    );
    final renewed = Contract(
      id: newId(),
      fighterId: fighter.id,
      fightsRemaining: _autoResignFightCount,
      showMoney: rate.showMoney,
      winBonus: rate.winBonus,
      exclusive: contract.exclusive,
      signedOn: GameCalendar.dateForWeek(org.currentWeek),
    );
    // A renewal is not a signing. Charging a full purse up front to keep
    // somebody already yours — and then paying it again when they fight
    // — was double-counting, and it landed hardest exactly when a
    // promotion is most fragile: measured, the year a roster upgrades,
    // purses jumped from 36% of takings to 145% in one step. Retaining a
    // fighter costs a fraction of taking one off the open market.
    final renewalFee = (rate.showMoney * renewalFeeShare).round();
    await _orgRepo.save(
      org.copyWith(cashBalance: org.cashBalance - renewalFee),
    );
    await _inboxRepo.save(_newInboxItem(
      org,
      InboxItemType.contract,
      fighterId: fighter.id,
      title: '${fighter.name} re-signed',
      body: '${fighter.name} fought out their deal and has been re-signed '
          'automatically for $_autoResignFightCount more fights at '
          '\$${rate.showMoney} to show and \$${rate.winBonus} to win. The '
          'renewal fee of \$$renewalFee has come out of the bank.',
    ));
    return fighter.copyWith(contract: renewed);
  }

  /// What a renewal costs up front, as a share of the new show money.
  ///
  /// A new signing is charged the full show money — you are buying
  /// somebody off the open market against everyone else who wants them.
  /// Keeping a fighter already under contract is not that, so it is not
  /// priced like it.
  static const double renewalFeeShare = 0.25;

  /// How many fights an automatic renewal is worth. Short enough that the
  /// player still gets a say every so often.
  static const int _autoResignFightCount = 4;

  /// Rolls the roster's off-camera trouble for the week — failed tests,
  /// DUIs, backstage scraps, and getting hurt doing something stupid.
  /// The consequences are already applied by the time the player reads
  /// about it; all they get is the mailbox item.
  Future<void> _maybeRollIncident(Organization org) async {
    final incident = _incidentEngine.maybeGenerate(
      roster: signedRoster,
      currentWeek: org.currentWeek,
    );
    if (incident == null) return;

    for (final fighter in incident.updatedFighters) {
      await _fighterRepo.save(fighter);
    }
    await _inboxRepo.save(_newInboxItem(
      org,
      _inboxTypeFor(incident.type),
      fighterId: incident.primaryFighterId,
      title: incident.headline,
      body: incident.body,
    ));
  }

  static InboxItemType _inboxTypeFor(IncidentType type) => switch (type) {
        IncidentType.failedDrugTest => InboxItemType.suspension,
        IncidentType.dui => InboxItemType.misconduct,
        IncidentType.backstageAltercation => InboxItemType.altercation,
        IncidentType.freakInjury => InboxItemType.injury,
      };

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

    // How much the fight itself took out of them: how long it lasted, and
    // whether it ended in a finish rather than going to the cards.
    final roundsFought = result.round;
    final wasFinished = result.method != FightMethod.decision && !result.isDraw;

    // What the fight was worth to the people who watched it. Fans follow
    // fights, not results — a man who loses a war picks up support and a
    // man who wins a dull one sheds it.
    final excitement = FightExcitement.rate(
      result: result,
      scheduledRounds: fight.rounds,
    );

    final scoreA = result.isDraw ? 0.5 : (result.winnerId == a.id ? 1.0 : 0.0);
    final (newEloA, newEloB) = _careerEngine.updateElo(
      a.eloRating,
      b.eloRating,
      scoreA,
      // Who they beat, not just that they won: overall feeds the expected
      // result, so taking out a 90 is worth far more than a 60.
      overallA: a.overall,
      overallB: b.overall,
    );

    if (result.isDraw) {
      final drawPopularity = FightExcitement.popularityDelta(
        rating: excitement.rating,
        won: false,
        draw: true,
      );
      final updatedA = await _applyPostFight(
        a,
        record: a.record.addDraw(),
        eloRating: newEloA,
        popularityDelta: drawPopularity,
        injuryFromFight: result.fighterAInjury,
        roundsFought: roundsFought,
        wasFinished: wasFinished,
      );
      final updatedB = await _applyPostFight(
        b,
        record: b.record.addDraw(),
        eloRating: newEloB,
        popularityDelta: drawPopularity,
        injuryFromFight: result.fighterBInjury,
        roundsFought: roundsFought,
        wasFinished: wasFinished,
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
      popularityDelta:
          FightExcitement.popularityDelta(rating: excitement.rating, won: true),
      moraleDelta: 8,
      injuryFromFight: winnerInjury,
      roundsFought: roundsFought,
      wasFinished: wasFinished,
    );
    final updatedLoser = await _applyPostFight(
      loser,
      record: loser.record.addLoss(),
      winStreak: 0,
      lossStreak: loser.lossStreak + 1,
      eloRating: loserNewElo,
      popularityDelta:
          FightExcitement.popularityDelta(rating: excitement.rating, won: false),
      moraleDelta: -10,
      injuryFromFight: loserInjury,
      roundsFought: roundsFought,
      wasFinished: wasFinished,
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
    int roundsFought = 3,
    bool wasFinished = false,
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
      // Fights take a physical toll beyond injuries — a long war leaves a
      // fighter worn even when nothing is torn.
      condition: FighterConditionCalculator.conditionAfterFight(
        current: fighter.condition,
        roundsFought: roundsFought,
        wasFinished: wasFinished,
      ),
      lastFoughtWeek: organization?.currentWeek,
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
      await _maybeWarnContractExpiring(updated);
      updated = await _handleExpiredContract(updated);
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
    await _eventRepo.saveEvent(event.copyWith(
      fightOfTheNightFightId: fightId,
      // A bonus is money this show cost you, so it belongs on this
      // show's books — not just quietly off the org's cash balance.
      // Awards land after the card is simulated, which is why this adds
      // to what the finance calculator already worked out rather than
      // being part of it.
      expenses: event.expenses + bonus,
    ));
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
    await _eventRepo.saveEvent(event.copyWith(
      performanceOfTheNightFighterId: fighterId,
      // Same as Fight of the Night: the event wears the cost.
      expenses: event.expenses + bonus,
    ));
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
