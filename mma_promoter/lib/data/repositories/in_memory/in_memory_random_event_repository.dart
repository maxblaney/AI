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
  Stream<List<RandomEvent>> watchUnresolved() async* {
    yield _unresolvedSnapshot();
    yield* _controller.stream;
  }

  @override
  Future<void> save(RandomEvent event) async {
    _events[event.id] = event;
    _emit();
  }
}
