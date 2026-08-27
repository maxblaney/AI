import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';

/// Reads and writes [RandomEvent]s (injuries, callouts, disputes, ...).
class RandomEventRepository {
  final AppDatabase _db;

  RandomEventRepository(this._db);

  Stream<List<RandomEvent>> watchUnresolved() {
    return _db
        .watchUnresolvedRandomEvents()
        .map((rows) => rows.map(randomEventFromRow).toList());
  }

  Future<void> save(RandomEvent event) {
    return _db.upsertRandomEvent(randomEventToCompanion(event));
  }
}
