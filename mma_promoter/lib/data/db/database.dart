import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Fighters, Contracts, Organizations, Events, Fights, RandomEvents],
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

  // ---- Random events ------------------------------------------------------

  Stream<List<RandomEventRow>> watchUnresolvedRandomEvents() =>
      (select(randomEvents)..where((r) => r.chosenChoiceId.isNull())).watch();

  Future<void> upsertRandomEvent(RandomEventsCompanion entry) =>
      into(randomEvents).insertOnConflictUpdate(entry);
}
