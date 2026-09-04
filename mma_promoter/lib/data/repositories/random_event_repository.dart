import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';
import 'save_scope.dart';

/// Reads and writes [RandomEvent]s (injuries, callouts, disputes, ...).
class RandomEventRepository implements RandomEventRepositoryContract {
  final AppDatabase _db;
  final SaveScope _scope;

  RandomEventRepository(this._db, this._scope);

  @override
  Stream<List<RandomEvent>> watchUnresolved() {
    return _db
        .watchUnresolvedRandomEvents(_scope.key)
        .map((rows) => rows.map(randomEventFromRow).toList());
  }

  @override
  Future<void> save(RandomEvent event) {
    return _db.upsertRandomEvent(randomEventToCompanion(event, _scope.key));
  }
}
