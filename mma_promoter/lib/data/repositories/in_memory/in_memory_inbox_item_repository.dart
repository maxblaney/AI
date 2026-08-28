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
  Stream<List<InboxItem>> watchAll() async* {
    yield _snapshot();
    yield* _controller.stream;
  }

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
