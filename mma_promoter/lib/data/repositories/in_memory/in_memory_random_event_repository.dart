import 'dart:async';

import '../../models/models.dart';
import '../repository_contracts.dart';

/// Volatile, non-persistent [RandomEventRepositoryContract] used for the
/// Flutter-web preview build.
class InMemoryRandomEventRepository implements RandomEventRepositoryContract {
  final Map<String, RandomEvent> _events = {};
  final _controller = StreamController<List<RandomEvent>>.broadcast();

  List<RandomEvent> _unresolvedSnapshot() =>
      _events.values.where((e) => !e.isResolved).toList();

  void _emit() => _controller.add(_unresolvedSnapshot());

  @override
  // Stream.multi rather than an `async*` generator: a generator yields
  // the snapshot and only *then* subscribes to the broadcast stream, so
  // anything saved in between is dropped and the listener is stuck on a
  // stale snapshot forever. Here the subscription is attached before the
  // snapshot goes out, which closes that window.
  Stream<List<RandomEvent>> watchUnresolved() => Stream.multi((listener) {
        final subscription = _controller.stream.listen(
          listener.addSync,
          onError: listener.addErrorSync,
          onDone: listener.closeSync,
        );
        listener.onCancel = subscription.cancel;
        listener.addSync(_unresolvedSnapshot());
      });

  @override
  Future<void> save(RandomEvent event) async {
    _events[event.id] = event;
    _emit();
  }
}
