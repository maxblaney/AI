import '../db/database.dart';
import '../models/models.dart';
import 'mappers.dart';
import 'repository_contracts.dart';
import 'save_scope.dart';

/// Reads and writes [Fighter]s (talent pool + signed roster), keeping the
/// fighter row and its optional contract row in sync.
class FighterRepository implements FighterRepositoryContract {
  final AppDatabase _db;
  final SaveScope _scope;

  FighterRepository(this._db, this._scope);

  @override
  Stream<List<Fighter>> watchAll() {
    return _db.watchAllFighters(_scope.key).asyncMap(_attachContracts);
  }

  @override
  Future<List<Fighter>> getAll() async {
    final rows = await _db.getAllFighters(_scope.key);
    return _attachContracts(rows);
  }

  Future<List<Fighter>> _attachContracts(List<FighterRow> rows) async {
    final fighters = <Fighter>[];
    for (final row in rows) {
      final contract = await _db.getContractForFighter(row.id);
      fighters.add(fighterFromRow(row, contract));
    }
    return fighters;
  }

  @override
  Future<Fighter?> getById(String id) async {
    final row = await _db.getFighterById(id);
    if (row == null) return null;
    final contract = await _db.getContractForFighter(id);
    return fighterFromRow(row, contract);
  }

  /// Persists a fighter's core attributes and, if present, their contract.
  @override
  Future<void> save(Fighter fighter) async {
    await _db.upsertFighter(fighterToCompanion(fighter, _scope.key));
    if (fighter.contract != null) {
      await _db.upsertContract(contractToCompanion(fighter.contract!));
    }
  }

  /// Signs an unsigned fighter to the roster under the given contract.
  @override
  Future<void> sign(Fighter fighter, Contract contract) async {
    await save(fighter.copyWith(contract: contract));
  }

  /// Releases a fighter back into the free-agent pool (deletes the contract
  /// but keeps their career record intact).
  @override
  Future<void> release(String fighterId) async {
    await _db.deleteContractForFighter(fighterId);
  }
}
