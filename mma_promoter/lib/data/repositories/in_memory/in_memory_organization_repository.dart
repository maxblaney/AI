import 'dart:async';

import '../../models/models.dart';
import '../repository_contracts.dart';

/// Volatile, non-persistent [OrganizationRepositoryContract] used for the
/// Flutter-web preview build.
class InMemoryOrganizationRepository implements OrganizationRepositoryContract {
  Organization? _org;
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
}
