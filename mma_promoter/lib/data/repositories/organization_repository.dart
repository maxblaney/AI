import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';

/// Reads and writes the single-row player [Organization].
class OrganizationRepository {
  final AppDatabase _db;

  OrganizationRepository(this._db);

  Stream<Organization?> watch() {
    return _db.watchOrganization().map((row) {
      if (row == null) return null;
      return organizationFromRow(row);
    });
  }

  Future<Organization?> get() async {
    final row = await _db.getOrganization();
    return row == null ? null : organizationFromRow(row);
  }

  Future<void> save(Organization org) {
    return _db.upsertOrganization(organizationToCompanion(org));
  }
}
