import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';

/// Reads and writes the single-row player [Organization].
class OrganizationRepository implements OrganizationRepositoryContract {
  final AppDatabase _db;

  OrganizationRepository(this._db);

  @override
  Stream<Organization?> watch() {
    return _db.watchOrganization().map((row) {
      if (row == null) return null;
      return organizationFromRow(row);
    });
  }

  @override
  Future<Organization?> get() async {
    final row = await _db.getOrganization();
    return row == null ? null : organizationFromRow(row);
  }

  @override
  Future<void> save(Organization org) {
    return _db.upsertOrganization(organizationToCompanion(org));
  }
}
