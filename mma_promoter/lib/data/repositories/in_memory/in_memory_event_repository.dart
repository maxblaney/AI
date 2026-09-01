import 'dart:async';

import '../../models/models.dart';
import '../repository_contracts.dart';

/// Volatile, non-persistent [EventRepositoryContract] used for the
/// Flutter-web preview build.
class InMemoryEventRepository implements EventRepositoryContract {
  final Map<String, MmaEvent> _events = {};
  final Map<String, Fight> _fights = {};
  final _controller = StreamController<List<MmaEvent>>.broadcast();

  List<MmaEvent> _snapshot() {
    final list = _events.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  void _emit() => _controller.add(_snapshot());

  @override
  // Stream.multi rather than an `async*` generator: a generator yields
  // the snapshot and only *then* subscribes to the broadcast stream, so
  // anything saved in between is dropped and the listener is stuck on a
  // stale snapshot forever. Here the subscription is attached before the
  // snapshot goes out, which closes that window.
  Stream<List<MmaEvent>> watchAll() => Stream.multi((listener) {
        final subscription = _controller.stream.listen(
          listener.addSync,
          onError: listener.addErrorSync,
          onDone: listener.closeSync,
        );
        listener.onCancel = subscription.cancel;
        listener.addSync(_snapshot());
      });

  @override
  Future<MmaEvent?> getById(String id) async => _events[id];

  @override
  Future<void> saveEvent(MmaEvent event) async {
    _events[event.id] = event;
    _emit();
  }

  @override
  Future<List<Fight>> getCard(String eventId) async {
    final list = _fights.values.where((f) => f.eventId == eventId).toList()
      ..sort((a, b) => a.cardOrder.compareTo(b.cardOrder));
    return list;
  }

  @override
  Future<void> saveFight(Fight fight) async {
    _fights[fight.id] = fight;
  }

  @override
  Future<void> deleteFight(String fightId) async {
    _fights.remove(fightId);
  }

  @override
  Future<void> saveCard(List<Fight> fights) async {
    for (final fight in fights) {
      await saveFight(fight);
    }
  }

  @override
  Future<List<Fight>> getAllResolvedFights() async =>
      _fights.values.where((f) => f.isResolved).toList();

  @override
  Future<List<Fight>> getFightsForFighter(String fighterId) async {
    final list = _fights.values
        .where((f) =>
            f.isResolved &&
            (f.fighterAId == fighterId || f.fighterBId == fighterId))
        .toList();
    list.sort((a, b) {
      final eventA = _events[a.eventId];
      final eventB = _events[b.eventId];
      if (eventA == null || eventB == null) return 0;
      return eventB.date.compareTo(eventA.date);
    });
    return list;
  }
}
