import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';
import 'save_scope.dart';

/// Reads and writes the player [Organization] — which, since each
/// organization *is* a save, doubles as the saves index: [listAll] backs
/// the saves screen, and [watch]/[get] read whichever save is currently
/// scoped.
class OrganizationRepository implements OrganizationRepositoryContract {
  final AppDatabase _db;
  final SaveScope _scope;

  OrganizationRepository(this._db, this._scope);

  @override
  Stream<Organization?> watch() {
    if (!_scope.hasSave) return Stream.value(null);
    return _db.watchSave(_scope.key).map(
          (row) => row == null ? null : organizationFromRow(row),
        );
  }

  @override
  Future<Organization?> get() async {
    if (!_scope.hasSave) return null;
    final row = await _db.getSave(_scope.key);
    return row == null ? null : organizationFromRow(row);
  }

  @override
  Future<void> save(Organization org) {
    return _db.upsertSave(organizationToCompanion(org));
  }

  @override
  Future<List<SaveSummary>> listAll() async {
    final rows = await _db.listSaves();
    final summaries = <SaveSummary>[];
    for (final row in rows) {
      summaries.add(SaveSummary(
        organization: organizationFromRow(row),
        lastPlayedAt: row.lastPlayedAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row.lastPlayedAtMs!),
        rosterSize: await _db.countSignedFighters(row.id),
        talentPoolSize: await _db.countFighters(row.id),
      ));
    }
    return summaries;
  }

  @override
  Future<void> touch(String saveId, DateTime at) =>
      _db.touchSave(saveId, at);

  @override
  Future<void> delete(String saveId) => _db.deleteSave(saveId);
}
