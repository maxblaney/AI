import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';

/// Reads and writes [MmaEvent]s and their booked [Fight] cards.
class EventRepository implements EventRepositoryContract {
  final AppDatabase _db;

  EventRepository(this._db);

  @override
  Stream<List<MmaEvent>> watchAll() {
    return _db.watchAllEvents().map((rows) => rows.map(eventFromRow).toList());
  }

  @override
  Future<MmaEvent?> getById(String id) async {
    final row = await _db.getEventById(id);
    return row == null ? null : eventFromRow(row);
  }

  @override
  Future<void> saveEvent(MmaEvent event) {
    return _db.upsertEvent(eventToCompanion(event));
  }

  @override
  Future<List<Fight>> getCard(String eventId) async {
    final rows = await _db.getFightsForEvent(eventId);
    return rows.map(fightFromRow).toList();
  }

  @override
  Future<void> saveFight(Fight fight) {
    return _db.upsertFight(fightToCompanion(fight));
  }

  @override
  Future<void> saveCard(List<Fight> fights) async {
    for (final fight in fights) {
      await saveFight(fight);
    }
  }
}
