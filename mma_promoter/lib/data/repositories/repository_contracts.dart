import '../models/models.dart';
import '../../domain/packs/fighter_pack.dart';

/// One row in the saves list: the save's organization plus the few
/// counts and timestamps the picker shows, gathered here so the screen
/// doesn't have to load a whole roster per save just to render a
/// subtitle.
class SaveSummary {
  final Organization organization;
  final DateTime? lastPlayedAt;

  /// Fighters under contract.
  final int rosterSize;

  /// Every fighter in the save, signed or free agent.
  final int talentPoolSize;

  const SaveSummary({
    required this.organization,
    required this.lastPlayedAt,
    required this.rosterSize,
    required this.talentPoolSize,
  });
}

/// Abstract contracts for the four repositories [GameController] depends
/// on. The Drift-backed implementations (`fighter_repository.dart` etc.)
/// are the real, persistent ones used on native platforms; `in_memory/`
/// holds volatile implementations used for the Flutter-web preview build,
/// which has no `dart:io` and therefore can't use the SQLite backend.
abstract class FighterRepositoryContract {
  Stream<List<Fighter>> watchAll();
  Future<List<Fighter>> getAll();
  Future<Fighter?> getById(String id);
  Future<void> save(Fighter fighter);
  Future<void> sign(Fighter fighter, Contract contract);
  Future<void> release(String fighterId);
}

abstract class OrganizationRepositoryContract {
  Stream<Organization?> watch();
  Future<Organization?> get();
  Future<void> save(Organization org);

  /// Every save on this device, most recently played first.
  Future<List<SaveSummary>> listAll();

  /// Stamps a save as just-opened, so the list stays ordered by use.
  Future<void> touch(String saveId, DateTime at);

  /// Permanently removes a save and everything belonging to it.
  Future<void> delete(String saveId);
}

abstract class EventRepositoryContract {
  Stream<List<MmaEvent>> watchAll();
  Future<MmaEvent?> getById(String id);
  Future<void> saveEvent(MmaEvent event);
  Future<List<Fight>> getCard(String eventId);
  Future<void> saveFight(Fight fight);
  Future<void> saveCard(List<Fight> fights);

  /// Drops a single bout. Needed because a booked card can be reopened
  /// and edited: a fight the player takes off it has to leave the
  /// database, not just the screen.
  Future<void> deleteFight(String fightId);

  /// All resolved fights involving [fighterId], most recent first.
  Future<List<Fight>> getFightsForFighter(String fighterId);

  /// Every resolved fight in the active save, oldest first — the record
  /// book's input.
  Future<List<Fight>> getAllResolvedFights();
}

abstract class RandomEventRepositoryContract {
  Stream<List<RandomEvent>> watchUnresolved();
  Future<void> save(RandomEvent event);
}

abstract class InboxItemRepositoryContract {
  Stream<List<InboxItem>> watchAll();
  Future<void> save(InboxItem item);
  Future<void> markRead(String id);
}

/// Saved fighter packs. Not save-scoped: a pack is the player's, not a
/// promotion's, which is what lets it be imported into several.
abstract class FighterPackRepositoryContract {
  Future<List<FighterPack>> getAll();
  Future<FighterPack?> getById(String id);
  Future<void> save(FighterPack pack);
  Future<void> delete(String id);
}
