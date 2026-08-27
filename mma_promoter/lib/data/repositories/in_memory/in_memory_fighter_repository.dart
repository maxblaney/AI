import 'dart:async';

import '../../models/models.dart';
import '../repository_contracts.dart';

/// Volatile, non-persistent [FighterRepositoryContract] used for the
/// Flutter-web preview build (no `dart:io`, so no real SQLite backend).
class InMemoryFighterRepository implements FighterRepositoryContract {
  final Map<String, Fighter> _fighters = {};
  final _controller = StreamController<List<Fighter>>.broadcast();

  List<Fighter> _snapshot() => _fighters.values.toList();
  void _emit() => _controller.add(_snapshot());

  @override
  Stream<List<Fighter>> watchAll() async* {
    yield _snapshot();
    yield* _controller.stream;
  }

  @override
  Future<List<Fighter>> getAll() async => _snapshot();

  @override
  Future<Fighter?> getById(String id) async => _fighters[id];

  @override
  Future<void> save(Fighter fighter) async {
    _fighters[fighter.id] = fighter;
    _emit();
  }

  @override
  Future<void> sign(Fighter fighter, Contract contract) async {
    await save(fighter.copyWith(contract: contract));
  }

  @override
  Future<void> release(String fighterId) async {
    final fighter = _fighters[fighterId];
    if (fighter == null) return;
    _fighters[fighterId] = fighter.copyWith(clearContract: true);
    _emit();
  }
}
