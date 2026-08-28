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

  @override
  int get schemaVersion => 1;

  // ---- Fighters -----------------------------------------------------

  Future<List<FighterRow>> getAllFighters() => select(fighters).get();

  Stream<List<FighterRow>> watchAllFighters() => select(fighters).watch();

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

  Future<OrganizationRow?> getOrganization() =>
      select(organizations).getSingleOrNull();

  Stream<OrganizationRow?> watchOrganization() =>
      select(organizations).watchSingleOrNull();

  Future<void> upsertOrganization(OrganizationsCompanion entry) =>
      into(organizations).insertOnConflictUpdate(entry);

  // ---- Events -----------------------------------------------------------

  Stream<List<EventRow>> watchAllEvents() =>
      (select(events)..orderBy([(e) => OrderingTerm.asc(e.date)])).watch();

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

  Future<void> upsertFight(FightsCompanion entry) =>
      into(fights).insertOnConflictUpdate(entry);

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

  Stream<List<RandomEventRow>> watchUnresolvedRandomEvents() =>
      (select(randomEvents)..where((r) => r.chosenChoiceId.isNull())).watch();

  Future<void> upsertRandomEvent(RandomEventsCompanion entry) =>
      into(randomEvents).insertOnConflictUpdate(entry);

  // ---- Inbox items ------------------------------------------------------

  Stream<List<InboxItemRow>> watchAllInboxItems() =>
      (select(inboxItems)..orderBy([(i) => OrderingTerm.desc(i.week)])).watch();

  Future<void> upsertInboxItem(InboxItemsCompanion entry) =>
      into(inboxItems).insertOnConflictUpdate(entry);

  Future<void> markInboxItemRead(String id) =>
      (update(inboxItems)..where((i) => i.id.equals(id)))
          .write(const InboxItemsCompanion(read: Value(true)));
}
