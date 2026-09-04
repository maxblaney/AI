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
  // Stream.multi rather than an `async*` generator: a generator yields
  // the snapshot and only *then* subscribes to the broadcast stream, so
  // anything saved in between is dropped and the listener is stuck on a
  // stale snapshot forever. Here the subscription is attached before the
  // snapshot goes out, which closes that window.
  Stream<List<Fighter>> watchAll() => Stream.multi((listener) {
        final subscription = _controller.stream.listen(
          listener.addSync,
          onError: listener.addErrorSync,
          onDone: listener.closeSync,
        );
        listener.onCancel = subscription.cancel;
        listener.addSync(_snapshot());
      });

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
