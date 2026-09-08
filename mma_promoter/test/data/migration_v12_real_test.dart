import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/db/database.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/presentation/state/game_controller.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// A real save, made by actually playing, then migrated forward.
///
/// The fixture-based migration tests build stub tables with only the
/// columns a step touches, which is fine for checking one ALTER but
/// cannot catch a migration that breaks on a *populated* database — and
/// a migration that throws in the browser doesn't show an error, it
/// shows a white page. This one plays a save, rewinds the schema by
/// dropping the columns v11 and v12 add, stamps it back to v9, and
/// reopens it with current code.
void main() {
  /// The repositories publish through streams; let them drain before
  /// reading the controller's caches back.
  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('a played v9 save survives the upgrade to v12', () async {
    final dir = Directory.systemTemp.createTempSync('mma-migration');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = '${dir.path}/save.sqlite';

    // 1. Play a save on the current code.
    final raw = sql.sqlite3.open(file);
    var db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    var controller = GameController(database: db, random: Random(3));
    await controller.startNewGame(
        orgName: 'Legacy FC', tier: ReputationTier.regional);
    await settle();
    final orgId = controller.organization!.id;
    final fighters = controller.allFighters.length;
    expect(fighters, greaterThan(100));
    controller.dispose();
    await db.close();

    // 2. Rewind it to v9: drop what v11 and v12 added, and the flag v10
    //    rewrites, then stamp the version back.
    final rewind = sql.sqlite3.open(file);
    rewind.execute('ALTER TABLE organizations DROP COLUMN last_aged_week');
    rewind.execute('ALTER TABLE fighters DROP COLUMN arrived_week');
    rewind.execute('UPDATE organizations SET auto_resign_fighters = 0');
    rewind.execute('PRAGMA user_version = 9');
    rewind.dispose();

    // 3. Open it with current code, which runs v10, v11 and v12 against
    //    a database with real data in every table.
    final reopened = sql.sqlite3.open(file);
    db = AppDatabase.forTesting(NativeDatabase.opened(reopened));
    await db.customSelect('SELECT 1').get();

    controller = GameController(database: db, random: Random(3));
    await controller.loadSave(orgId);
    await settle();

    expect(controller.organization, isNotNull,
        reason: 'the save should still open');
    expect(controller.organization!.name, 'Legacy FC');
    expect(controller.allFighters, hasLength(fighters),
        reason: 'nobody should be lost in the upgrade');
    // v10 repairs the setting, v11 starts the ageing clock where the save
    // is rather than back-dating it, v12 defaults everyone to week 1.
    expect(controller.organization!.autoResignFighters, isTrue);
    expect(controller.organization!.lastAgedWeek,
        controller.organization!.currentWeek);
    expect(controller.allFighters.every((f) => f.arrivedWeek == 1), isTrue);

    // And the save is playable, not merely readable.
    await controller.advanceWeek();
    expect(controller.organization!.currentWeek, greaterThan(1));

    controller.dispose();
    await db.close();
  });
}
