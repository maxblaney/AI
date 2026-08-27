import '../models/models.dart';

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
}

abstract class EventRepositoryContract {
  Stream<List<MmaEvent>> watchAll();
  Future<MmaEvent?> getById(String id);
  Future<void> saveEvent(MmaEvent event);
  Future<List<Fight>> getCard(String eventId);
  Future<void> saveFight(Fight fight);
  Future<void> saveCard(List<Fight> fights);

  /// All resolved fights involving [fighterId], most recent first.
  Future<List<Fight>> getFightsForFighter(String fighterId);
}

abstract class RandomEventRepositoryContract {
  Stream<List<RandomEvent>> watchUnresolved();
  Future<void> save(RandomEvent event);
}
