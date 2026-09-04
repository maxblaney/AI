import 'dart:async';

import '../../models/models.dart';
import '../repository_contracts.dart';

class InMemoryInboxItemRepository implements InboxItemRepositoryContract {
  final Map<String, InboxItem> _items = {};
  final _controller = StreamController<List<InboxItem>>.broadcast();

  List<InboxItem> _snapshot() {
    final list = _items.values.toList();
    list.sort((a, b) => b.week.compareTo(a.week));
    return list;
  }

  void _emit() => _controller.add(_snapshot());

  @override
  // Stream.multi rather than an `async*` generator: a generator yields
  // the snapshot and only *then* subscribes to the broadcast stream, so
  // anything saved in between is dropped and the listener is stuck on a
  // stale snapshot forever. Here the subscription is attached before the
  // snapshot goes out, which closes that window.
  Stream<List<InboxItem>> watchAll() => Stream.multi((listener) {
        final subscription = _controller.stream.listen(
          listener.addSync,
          onError: listener.addErrorSync,
          onDone: listener.closeSync,
        );
        listener.onCancel = subscription.cancel;
        listener.addSync(_snapshot());
      });

  @override
  Future<void> save(InboxItem item) async {
    _items[item.id] = item;
    _emit();
  }

  @override
  Future<void> markRead(String id) async {
    final item = _items[id];
    if (item == null) return;
    _items[id] = item.copyWith(read: true);
    _emit();
  }
}
