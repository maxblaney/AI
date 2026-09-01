import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';
import 'save_scope.dart';

/// Reads and writes [MmaEvent]s and their booked [Fight] cards.
class EventRepository implements EventRepositoryContract {
  final AppDatabase _db;
  final SaveScope _scope;

  EventRepository(this._db, this._scope);

  @override
  Stream<List<MmaEvent>> watchAll() {
    return _db
        .watchAllEvents(_scope.key)
        .map((rows) => rows.map(eventFromRow).toList());
  }

  @override
  Future<MmaEvent?> getById(String id) async {
    final row = await _db.getEventById(id);
    return row == null ? null : eventFromRow(row);
  }

  @override
  Future<void> saveEvent(MmaEvent event) {
    return _db.upsertEvent(eventToCompanion(event, _scope.key));
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
  Future<void> deleteFight(String fightId) => _db.deleteFightById(fightId);

  @override
  Future<void> saveCard(List<Fight> fights) async {
    for (final fight in fights) {
      await saveFight(fight);
    }
  }

  @override
  Future<List<Fight>> getAllResolvedFights() async {
    final rows = await _db.getResolvedFightsForSave(_scope.key);
    return rows.map(fightFromRow).toList();
  }

  @override
  Future<List<Fight>> getFightsForFighter(String fighterId) async {
    final rows = await _db.getFightsForFighter(fighterId);
    return rows.map(fightFromRow).toList();
  }
}
