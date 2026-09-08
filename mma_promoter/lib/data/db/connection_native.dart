import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens (creating if needed) the on-device SQLite file used for all
/// persistence. Lazy so the heavy native DB isn't touched until first query.
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mma_promoter.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
