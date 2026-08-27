import 'package:drift/drift.dart';

/// Fighters signed to the org or sitting in the free-agent talent pool.
/// Enum-like fields (weightClass, injuryStatus) are stored as their Dart
/// enum `.name` string and converted in the repository layer — this keeps
/// the schema readable in a DB browser and avoids extra TypeConverter
/// boilerplate for a v1 scaffold.
@DataClassName('FighterRow')
class Fighters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get nationality => text()();
  TextColumn get weightClass => text()();

  IntColumn get wins => integer().withDefault(const Constant(0))();
  IntColumn get losses => integer().withDefault(const Constant(0))();
  IntColumn get draws => integer().withDefault(const Constant(0))();

  IntColumn get striking => integer()();
  IntColumn get grappling => integer()();
  IntColumn get cardio => integer()();
  IntColumn get chin => integer()();
  IntColumn get power => integer()();

  IntColumn get popularity => integer().withDefault(const Constant(30))();
  IntColumn get morale => integer().withDefault(const Constant(70))();
  TextColumn get injuryStatus =>
      text().withDefault(const Constant('healthy'))();
  IntColumn get winStreak => integer().withDefault(const Constant(0))();

  /// Comma-separated [StyleTag] names, e.g. "striker,wrestler".
  TextColumn get styleTags => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ContractRow')
class Contracts extends Table {
  TextColumn get id => text()();
  TextColumn get fighterId => text()();
  IntColumn get fightsRemaining => integer()();
  IntColumn get payPerFight => integer()();
  BoolColumn get exclusive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get signedOn => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row table holding the player's promotion state.
@DataClassName('OrganizationRow')
class Organizations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get reputationTier =>
      text().withDefault(const Constant('regional'))();
  IntColumn get reputationPoints => integer().withDefault(const Constant(0))();
  IntColumn get cashBalance => integer()();
  IntColumn get fanbaseSize => integer().withDefault(const Constant(0))();
  TextColumn get homeRegion => text()();
  IntColumn get promotionBudget => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get venueTier => text()();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get promotionBudgetSpent =>
      integer().withDefault(const Constant(0))();
  IntColumn get attendance => integer().withDefault(const Constant(0))();
  IntColumn get ppvBuys => integer().withDefault(const Constant(0))();
  IntColumn get revenue => integer().withDefault(const Constant(0))();
  IntColumn get expenses => integer().withDefault(const Constant(0))();
  IntColumn get reputationChange => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FightRow')
class Fights extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text()();
  TextColumn get fighterAId => text()();
  TextColumn get fighterBId => text()();
  TextColumn get weightClass => text()();
  BoolColumn get isTitleFight => boolean().withDefault(const Constant(false))();
  BoolColumn get isMainEvent => boolean().withDefault(const Constant(false))();
  IntColumn get cardOrder => integer().withDefault(const Constant(0))();

  TextColumn get resultWinnerId => text().nullable()();
  TextColumn get resultMethod => text().nullable()();
  IntColumn get resultRound => integer().nullable()();
  IntColumn get winnerPerformanceRating => integer().nullable()();
  IntColumn get loserPerformanceRating => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RandomEventRow')
class RandomEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get affectedFighterId => text().nullable()();
  TextColumn get headline => text()();
  TextColumn get description => text()();

  /// JSON-encoded list of `{id, label, consequenceSummary}` objects.
  TextColumn get choicesJson => text()();
  TextColumn get chosenChoiceId => text().nullable()();
  DateTimeColumn get occurredOn => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
