import 'package:drift/drift.dart';

/// Flutter web has no `dart:io`, so the real on-device SQLite backend
/// ([connection_native.dart]) can't compile here — this file is what
/// `connection.dart`'s conditional export resolves to on web instead.
///
/// [GameController] never actually calls this on web: it detects `kIsWeb`
/// and uses the in-memory repositories instead of constructing
/// [AppDatabase]. This stub exists purely so the shared `database.dart`
/// import graph still compiles for the web target.
QueryExecutor openConnection() {
  throw UnsupportedError(
    'AppDatabase (Drift/SQLite) is not available on Flutter web. '
    'GameController should be constructed with in-memory repositories '
    'when kIsWeb is true.',
  );
}
