import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../domain/packs/fighter_codec.dart';
import '../../domain/packs/fighter_pack.dart';
import '../db/database.dart';
import 'repository_contracts.dart';

/// Reads and writes saved [FighterPack]s.
///
/// No [SaveScope] here, unlike every other repository: packs are the one
/// thing in the database that belongs to the player rather than to one
/// promotion.
class FighterPackRepository implements FighterPackRepositoryContract {
  final AppDatabase _db;

  FighterPackRepository(this._db);

  @override
  Future<List<FighterPack>> getAll() async {
    final rows = await _db.getAllFighterPacks();
    return [for (final row in rows) _fromRow(row)];
  }

  @override
  Future<FighterPack?> getById(String id) async {
    final row = await _db.getFighterPackById(id);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> save(FighterPack pack) {
    return _db.upsertFighterPack(FighterPacksCompanion.insert(
      id: pack.id,
      name: pack.name,
      description: Value(pack.description),
      author: Value(pack.author),
      createdAtMs: pack.createdAt.millisecondsSinceEpoch,
      fightersJson: jsonEncode(
        [for (final f in pack.fighters) FighterCodec.toJson(f)],
      ),
    ));
  }

  @override
  Future<void> delete(String id) => _db.deleteFighterPackById(id);

  /// Fighters come back with the ids they were stored under. Callers
  /// importing a pack into a save mint fresh ones — see
  /// `GameController.importPack`.
  FighterPack _fromRow(FighterPackRow row) {
    final decoded = jsonDecode(row.fightersJson);
    final fighters = decoded is List ? decoded : const [];
    var index = 0;
    return FighterPack(
      id: row.id,
      name: row.name,
      description: row.description,
      author: row.author,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
      fighters: [
        for (final entry in fighters)
          if (entry is Map<String, dynamic>)
            FighterCodec.fromJson(entry, id: '${row.id}-${index++}'),
      ],
    );
  }
}
