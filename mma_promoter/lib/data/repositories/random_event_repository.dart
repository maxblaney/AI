import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';

/// Reads and writes [RandomEvent]s (injuries, callouts, disputes, ...).
class RandomEventRepository implements RandomEventRepositoryContract {
  final AppDatabase _db;

  RandomEventRepository(this._db);

  @override
  Stream<List<RandomEvent>> watchUnresolved() {
    return _db
        .watchUnresolvedRandomEvents()
        .map((rows) => rows.map(randomEventFromRow).toList());
  }

  @override
  Future<void> save(RandomEvent event) {
    return _db.upsertRandomEvent(randomEventToCompanion(event));
  }
}
