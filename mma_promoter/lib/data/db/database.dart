import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Fighters,
    Contracts,
    Organizations,
    Events,
    Fights,
    RandomEvents,
    InboxItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Lets tests drive the real schema against an in-memory SQLite database
  /// instead of the platform connection.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  /// Games persist on every platform now (web included), so a schema
  /// change without a matching migration step here would silently break
  /// saves that are already on disk. The convention: any change to
  /// `tables.dart` bumps [schemaVersion] and adds its step here —
  /// `m.addColumn(...)` for a new column, which is what nearly every
  /// change to a game this shape turns out to be.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2 introduced multiple saves. Everything that was game state
            // gained a saveId, and organizations gained a last-played
            // stamp so the saves list can be ordered.
            await m.addColumn(fighters, fighters.saveId);
            await m.addColumn(events, events.saveId);
            await m.addColumn(randomEvents, randomEvents.saveId);
            await m.addColumn(inboxItems, inboxItems.saveId);
            await m.addColumn(organizations, organizations.lastPlayedAtMs);

            // A v1 database held exactly one playthrough, and its rows have
            // no saveId. Adopt them into the existing organization so an
            // in-progress game survives the upgrade instead of being
            // orphaned behind a save nothing points at.
            // Raw SQL, not `select(organizations)`: a drift select maps
            // every column the *current* Dart schema declares, and at
            // this point in the upgrade the table only has the columns
            // v1 shipped. Reading whole rows here breaks the moment a
            // later version adds a non-nullable column.
            final existing =
                await customSelect('SELECT id FROM organizations').get();
            if (existing.length == 1) {
              final saveId = existing.single.read<String>('id');
              for (final table in ['fighters', 'events', 'random_events',
                'inbox_items']) {
                await customStatement(
                  "UPDATE $table SET save_id = ? WHERE save_id = ''",
                  [saveId],
                );
              }
            }
          }
          if (from < 3) {
            // v3 persists per-fight box scores (the record book aggregates
            // them) and tracks who holds each division's belt. Fights
            // resolved before this keep empty statlines — they predate the
            // data, and inventing numbers for them would put phantom
            // entries in the record book.
            await m.addColumn(fights, fights.statsAJson);
            await m.addColumn(fights, fights.statsBJson);
            // Raw SQL rather than m.addColumn: v5 replaced these two
            // flags with a set of belts, so they no longer exist in the
            // Dart schema. A database coming from v2 still needs the
            // columns created here, because the v5 step below reads them
            // to work out who was champion of what.
            await customStatement('ALTER TABLE fighters ADD COLUMN '
                'is_champion INTEGER NOT NULL DEFAULT 0');
            await customStatement('ALTER TABLE fighters ADD COLUMN '
                'is_interim_champion INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 4) {
            // v4 adds the condition/sharpness indicators. Existing
            // fighters default to full condition and no recorded last
            // fight, which reads as a rested roster — the alternative
            // would be inventing wear that never happened.
            await m.addColumn(fighters, fighters.condition);
            await m.addColumn(fighters, fighters.lastFoughtWeek);
            await m.addColumn(events, events.bookedAtWeek);
          }
          if (from < 5) {
            // v5 lets one fighter hold belts in more than one division —
            // the single is_champion flag couldn't express a double champ
            // — adds drug-test suspensions, and records the pre-fight
            // betting line so "biggest upset" is answerable after the
            // fact.
            await m.addColumn(fighters, fighters.beltsJson);
            await m.addColumn(fighters, fighters.interimBeltsJson);
            await m.addColumn(fighters, fighters.suspendedUntilWeek);
            await m.addColumn(fights, fights.preFightProbabilityA);

            // Carry existing champions over: whatever division they sit
            // in is the belt they hold. The old columns are left in place
            // on upgraded databases (SQLite makes dropping one a table
            // rebuild, and they're harmless with a default) — nothing
            // reads or writes them from here on, and fresh databases
            // never get them at all.
            await customStatement(
              "UPDATE fighters SET belts_json = '[\"' || weight_class || '\"]' "
              'WHERE is_champion = 1',
            );
            await customStatement(
              "UPDATE fighters SET interim_belts_json = "
              "'[\"' || weight_class || '\"]' WHERE is_interim_champion = 1",
            );
          }
          if (from < 6) {
            // Light Heavyweight's limit was wrong: 200 lbs rather than
            // the real 205. Fighting weights are generated as the limit
            // plus a few pounds, so every light heavyweight already on
            // disk was generated three to fifteen pounds over 200 and now
            // reads under the division's own limit. Shift them by the
            // five pounds the limit moved, which preserves how far over
            // each fighter walks around and puts the whole division back
            // where it belongs relative to the cap.
            await customStatement(
              'UPDATE fighters SET weight_lbs = weight_lbs + 5 '
              "WHERE weight_class = 'lightHeavyweight'",
            );
          }
          if (from < 7) {
            // v7 adds the auto-re-sign setting. Existing saves default to
            // off, which is how they have been behaving.
            await m.addColumn(organizations, organizations.autoResignFighters);
          }
        },
      );

  // ---- Fighters -----------------------------------------------------

  Future<List<FighterRow>> getAllFighters(String saveId) =>
      (select(fighters)..where((f) => f.saveId.equals(saveId))).get();

  Stream<List<FighterRow>> watchAllFighters(String saveId) =>
      (select(fighters)..where((f) => f.saveId.equals(saveId))).watch();

  Future<FighterRow?> getFighterById(String id) =>
      (select(fighters)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<void> upsertFighter(FightersCompanion entry) =>
      into(fighters).insertOnConflictUpdate(entry);

  Future<void> deleteFighterById(String id) =>
      (delete(fighters)..where((f) => f.id.equals(id))).go();

  // ---- Contracts ------------------------------------------------------

  Future<ContractRow?> getContractForFighter(String fighterId) =>
      (select(contracts)..where((c) => c.fighterId.equals(fighterId)))
          .getSingleOrNull();

  Future<void> upsertContract(ContractsCompanion entry) =>
      into(contracts).insertOnConflictUpdate(entry);

  Future<void> deleteContractForFighter(String fighterId) =>
      (delete(contracts)..where((c) => c.fighterId.equals(fighterId))).go();

  // ---- Organization (single row) --------------------------------------

  Future<OrganizationRow?> getSave(String saveId) =>
      (select(organizations)..where((o) => o.id.equals(saveId)))
          .getSingleOrNull();

  Stream<OrganizationRow?> watchSave(String saveId) =>
      (select(organizations)..where((o) => o.id.equals(saveId)))
          .watchSingleOrNull();

  /// Every save on this device, most recently played first. Saves with no
  /// last-played stamp (pre-v2 rows) sort last rather than being dropped.
  Future<List<OrganizationRow>> listSaves() => (select(organizations)
        ..orderBy([
          (o) => OrderingTerm.desc(o.lastPlayedAtMs),
        ]))
      .get();

  Stream<List<OrganizationRow>> watchSaves() => (select(organizations)
        ..orderBy([
          (o) => OrderingTerm.desc(o.lastPlayedAtMs),
        ]))
      .watch();

  /// Deletes a save and everything belonging to it. Fights and contracts
  /// hang off events and fighters rather than carrying a saveId of their
  /// own, so they're cleared via their parents' ids.
  Future<void> deleteSave(String saveId) async {
    await transaction(() async {
      final eventIds = await (select(events)
            ..where((e) => e.saveId.equals(saveId)))
          .map((e) => e.id)
          .get();
      final fighterIds = await (select(fighters)
            ..where((f) => f.saveId.equals(saveId)))
          .map((f) => f.id)
          .get();

      if (eventIds.isNotEmpty) {
        await (delete(fights)..where((f) => f.eventId.isIn(eventIds))).go();
      }
      if (fighterIds.isNotEmpty) {
        await (delete(contracts)..where((c) => c.fighterId.isIn(fighterIds)))
            .go();
      }
      await (delete(events)..where((e) => e.saveId.equals(saveId))).go();
      await (delete(fighters)..where((f) => f.saveId.equals(saveId))).go();
      await (delete(randomEvents)..where((r) => r.saveId.equals(saveId))).go();
      await (delete(inboxItems)..where((i) => i.saveId.equals(saveId))).go();
      await (delete(organizations)..where((o) => o.id.equals(saveId))).go();
    });
  }

  Future<void> upsertSave(OrganizationsCompanion entry) =>
      into(organizations).insertOnConflictUpdate(entry);

  /// Records that a save was just opened. A targeted UPDATE rather than an
  /// upsert of the whole row, so it can't race with a game-state write and
  /// clobber it.
  Future<void> touchSave(String saveId, DateTime at) =>
      (update(organizations)..where((o) => o.id.equals(saveId))).write(
        OrganizationsCompanion(
          lastPlayedAtMs: Value(at.millisecondsSinceEpoch),
        ),
      );

  /// How many fighters exist in a save, for the saves list. Counted in SQL
  /// rather than by loading rosters — the picker would otherwise pull every
  /// fighter of every save just to render a subtitle.
  Future<int> countFighters(String saveId) async {
    final count = fighters.id.count();
    final query = selectOnly(fighters)
      ..addColumns([count])
      ..where(fighters.saveId.equals(saveId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// How many of a save's fighters are actually under contract.
  Future<int> countSignedFighters(String saveId) async {
    final count = fighters.id.count();
    final query = selectOnly(fighters).join([
      innerJoin(contracts, contracts.fighterId.equalsExp(fighters.id)),
    ])
      ..addColumns([count])
      ..where(fighters.saveId.equals(saveId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  // ---- Events -----------------------------------------------------------

  Stream<List<EventRow>> watchAllEvents(String saveId) => (select(events)
        ..where((e) => e.saveId.equals(saveId))
        ..orderBy([(e) => OrderingTerm.asc(e.date)]))
      .watch();

  Future<EventRow?> getEventById(String id) =>
      (select(events)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> upsertEvent(EventsCompanion entry) =>
      into(events).insertOnConflictUpdate(entry);

  // ---- Fights -----------------------------------------------------------

  Future<List<FightRow>> getFightsForEvent(String eventId) =>
      (select(fights)
            ..where((f) => f.eventId.equals(eventId))
            ..orderBy([(f) => OrderingTerm.asc(f.cardOrder)]))
          .get();

  Future<void> deleteFightById(String id) =>
      (delete(fights)..where((f) => f.id.equals(id))).go();

  Future<void> upsertFight(FightsCompanion entry) =>
      into(fights).insertOnConflictUpdate(entry);

  /// Every resolved fight in a save, oldest event first. Backs the record
  /// book, which needs chronological order to work out win streaks.
  Future<List<FightRow>> getResolvedFightsForSave(String saveId) {
    final query = select(fights).join([
      innerJoin(events, events.id.equalsExp(fights.eventId)),
    ])
      ..where(events.saveId.equals(saveId) & fights.resultMethod.isNotNull())
      ..orderBy([
        OrderingTerm.asc(events.date),
        OrderingTerm.asc(fights.cardOrder),
      ]);
    return query.map((row) => row.readTable(fights)).get();
  }

  /// All resolved fights involving [fighterId], most recent event first —
  /// powers the fighter profile's fight history list.
  Future<List<FightRow>> getFightsForFighter(String fighterId) {
    final query = select(fights).join([
      innerJoin(events, events.id.equalsExp(fights.eventId)),
    ])
      ..where(
        fights.fighterAId.equals(fighterId) |
            fights.fighterBId.equals(fighterId),
      )
      ..where(fights.resultMethod.isNotNull())
      ..orderBy([OrderingTerm.desc(events.date)]);
    return query.map((row) => row.readTable(fights)).get();
  }

  // ---- Random events ------------------------------------------------------

  Stream<List<RandomEventRow>> watchUnresolvedRandomEvents(String saveId) =>
      (select(randomEvents)
            ..where((r) => r.saveId.equals(saveId) & r.chosenChoiceId.isNull()))
          .watch();

  Future<void> upsertRandomEvent(RandomEventsCompanion entry) =>
      into(randomEvents).insertOnConflictUpdate(entry);

  // ---- Inbox items ------------------------------------------------------

  Stream<List<InboxItemRow>> watchAllInboxItems(String saveId) =>
      (select(inboxItems)
            ..where((i) => i.saveId.equals(saveId))
            ..orderBy([(i) => OrderingTerm.desc(i.week)]))
          .watch();

  Future<void> upsertInboxItem(InboxItemsCompanion entry) =>
      into(inboxItems).insertOnConflictUpdate(entry);

  Future<void> markInboxItemRead(String id) =>
      (update(inboxItems)..where((i) => i.id.equals(id)))
          .write(const InboxItemsCompanion(read: Value(true)));
}
