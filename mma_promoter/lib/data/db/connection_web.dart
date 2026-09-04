import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Flutter web has no `dart:io`, so the on-device SQLite backend
/// ([connection_native.dart]) can't compile here. Instead the web build
/// runs the same schema on sqlite3 compiled to WebAssembly, with drift
/// persisting the database file through the browser (OPFS where the
/// browser supports it, IndexedDB otherwise).
///
/// This means the web build saves for real: the same tables, mappers and
/// repositories as native, so a game survives a refresh or closing the
/// tab. `web/sqlite3.wasm` and `web/drift_worker.js` must be served
/// alongside the app — they're committed in `web/` and Flutter copies
/// them into the build output.
///
/// The URIs are relative so they resolve against the page's `<base href>`,
/// which is `/AI/` on the GitHub Pages deploy and `/` locally.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'mma_promoter',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // Not fatal — drift falls back to the best storage the browser does
      // support — but it's the difference between a save that survives and
      // one that doesn't, so make it visible in the console rather than
      // letting a player lose a run silently.
      // ignore: avoid_print
      print(
        'drift: using ${result.chosenImplementation}; '
        'browser is missing ${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  });
}
