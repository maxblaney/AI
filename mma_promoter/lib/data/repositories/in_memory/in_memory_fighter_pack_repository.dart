import '../../../domain/packs/fighter_pack.dart';
import '../repository_contracts.dart';

/// Volatile [FighterPackRepositoryContract] for the web preview build and
/// for tests.
class InMemoryFighterPackRepository implements FighterPackRepositoryContract {
  final Map<String, FighterPack> _packs = {};

  @override
  Future<List<FighterPack>> getAll() async {
    final list = _packs.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<FighterPack?> getById(String id) async => _packs[id];

  @override
  Future<void> save(FighterPack pack) async {
    _packs[pack.id] = pack;
  }

  @override
  Future<void> delete(String id) async {
    _packs.remove(id);
  }
}
