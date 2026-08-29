import 'dart:async';

import '../../models/models.dart';
import '../repository_contracts.dart';

/// Volatile, non-persistent [OrganizationRepositoryContract] used by
/// tests. Unlike the Drift implementation it holds a single save — tests
/// that need multiple saves should drive the real database instead (see
/// `test/data/multi_save_test.dart`), since save isolation is a property
/// of the SQL scoping and can't be meaningfully exercised here.
class InMemoryOrganizationRepository implements OrganizationRepositoryContract {
  Organization? _org;
  DateTime? _lastPlayedAt;
  final _controller = StreamController<Organization?>.broadcast();

  @override
  Stream<Organization?> watch() async* {
    yield _org;
    yield* _controller.stream;
  }

  @override
  Future<Organization?> get() async => _org;

  @override
  Future<void> save(Organization org) async {
    _org = org;
    _controller.add(_org);
  }

  @override
  Future<List<SaveSummary>> listAll() async {
    final org = _org;
    if (org == null) return const [];
    return [
      SaveSummary(
        organization: org,
        lastPlayedAt: _lastPlayedAt,
        rosterSize: 0,
        talentPoolSize: 0,
      ),
    ];
  }

  @override
  Future<void> touch(String saveId, DateTime at) async {
    if (_org?.id == saveId) _lastPlayedAt = at;
  }

  @override
  Future<void> delete(String saveId) async {
    if (_org?.id != saveId) return;
    _org = null;
    _lastPlayedAt = null;
    _controller.add(null);
  }
}
