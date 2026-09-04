import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';
import 'save_scope.dart';

class InboxItemRepository implements InboxItemRepositoryContract {
  final AppDatabase _db;
  final SaveScope _scope;

  InboxItemRepository(this._db, this._scope);

  @override
  Stream<List<InboxItem>> watchAll() {
    return _db.watchAllInboxItems(_scope.key).map(
          (rows) => rows.map(inboxItemFromRow).toList(),
        );
  }

  @override
  Future<void> save(InboxItem item) {
    return _db.upsertInboxItem(inboxItemToCompanion(item, _scope.key));
  }

  @override
  Future<void> markRead(String id) {
    return _db.markInboxItemRead(id);
  }
}
