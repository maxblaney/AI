import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';

class InboxItemRepository implements InboxItemRepositoryContract {
  final AppDatabase _db;
  InboxItemRepository(this._db);

  @override
  Stream<List<InboxItem>> watchAll() {
    return _db.watchAllInboxItems().map(
          (rows) => rows.map(inboxItemFromRow).toList(),
        );
  }

  @override
  Future<void> save(InboxItem item) {
    return _db.upsertInboxItem(inboxItemToCompanion(item));
  }

  @override
  Future<void> markRead(String id) {
    return _db.markInboxItemRead(id);
  }
}
