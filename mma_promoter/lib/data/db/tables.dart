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
  IntColumn get heightInches => integer().withDefault(const Constant(70))();
  IntColumn get weightLbs => integer().withDefault(const Constant(155))();

  /// 0 means "not recorded" — the model falls back to height.
  IntColumn get reachInches => integer().withDefault(const Constant(0))();

  IntColumn get wins => integer().withDefault(const Constant(0))();
  IntColumn get losses => integer().withDefault(const Constant(0))();
  IntColumn get draws => integer().withDefault(const Constant(0))();

  // -- Fighting stats (23) --
  IntColumn get punching => integer()();
  IntColumn get kicking => integer()();
  IntColumn get power => integer()();
  IntColumn get speed => integer()();
  IntColumn get accuracy => integer()();
  IntColumn get defense => integer()();
  IntColumn get headMovement => integer().withDefault(const Constant(50))();
  IntColumn get blocking => integer().withDefault(const Constant(50))();
  IntColumn get footwork => integer().withDefault(const Constant(50))();
  IntColumn get takedowns => integer()();
  IntColumn get takedownDefense => integer()();
  IntColumn get wrestling => integer()();
  IntColumn get clinchStriking => integer().withDefault(const Constant(50))();
  IntColumn get clinchControl => integer().withDefault(const Constant(50))();
  IntColumn get clinchDefense => integer().withDefault(const Constant(50))();
  IntColumn get topControl => integer().withDefault(const Constant(50))();
  IntColumn get groundAndPound => integer()();
  IntColumn get guardRetention => integer().withDefault(const Constant(50))();
  IntColumn get sweeps => integer().withDefault(const Constant(50))();
  IntColumn get scrambling => integer().withDefault(const Constant(50))();
  IntColumn get submissionOffense => integer()();
  IntColumn get submissionDefense => integer()();
  IntColumn get grappling => integer()();

  // -- Physical stats (11) --
  IntColumn get cardio => integer()();
  IntColumn get durability => integer()();
  IntColumn get chin => integer()();
  IntColumn get bodyToughness => integer()();
  IntColumn get legToughness => integer()();
  IntColumn get strength => integer()();
  IntColumn get athleticism => integer()();
  IntColumn get recovery => integer()();
  IntColumn get explosiveness => integer().withDefault(const Constant(50))();
  IntColumn get flexibility => integer().withDefault(const Constant(50))();
  IntColumn get gripStrength => integer().withDefault(const Constant(50))();

  // -- Mental stats (8) --
  IntColumn get fightIq => integer()();
  IntColumn get composure => integer()();
  IntColumn get aggression => integer()();
  IntColumn get discipline => integer()();
  IntColumn get confidence => integer()();
  IntColumn get heart => integer()();
  IntColumn get adaptability => integer()();
  IntColumn get killerInstinct => integer().withDefault(const Constant(50))();

  // -- Tendencies (14) --
  IntColumn get tendStrikingFrequency => integer()();
  IntColumn get tendTakedownFrequency => integer()();
  IntColumn get tendKickFrequency => integer()();
  IntColumn get tendClinchFrequency => integer()();
  IntColumn get tendSubmissionAttempts => integer()();
  IntColumn get tendGroundAndPound => integer()();
  IntColumn get tendPositionControl => integer().withDefault(const Constant(50))();
  IntColumn get tendStandUpPreference => integer().withDefault(const Constant(50))();
  IntColumn get tendWallWork => integer().withDefault(const Constant(50))();
  IntColumn get tendAggression => integer()();
  IntColumn get tendCounterStriking => integer()();
  IntColumn get tendHeadHunting => integer()();
  IntColumn get tendBodyAttacks => integer()();
  IntColumn get tendLegAttacks => integer()();

  TextColumn get style => text().withDefault(const Constant('wellRounded'))();
  IntColumn get potential => integer().withDefault(const Constant(60))();

  IntColumn get popularity => integer().withDefault(const Constant(30))();
  IntColumn get morale => integer().withDefault(const Constant(70))();
  TextColumn get injuryStatus =>
      text().withDefault(const Constant('healthy'))();
  /// Absolute game week this fighter's current injury clears on its own.
  /// Null when healthy or when the injury has no active countdown.
  IntColumn get injuryClearsAtWeek => integer().nullable()();
  IntColumn get winStreak => integer().withDefault(const Constant(0))();
  IntColumn get lossStreak => integer().withDefault(const Constant(0))();

  IntColumn get eloRating => integer().withDefault(const Constant(1500))();
  BoolColumn get isRanked => boolean().withDefault(const Constant(false))();
  BoolColumn get retired => boolean().withDefault(const Constant(false))();
  TextColumn get retirementReason => text().nullable()();
  IntColumn get fightOfTheNightCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get performanceOfTheNightCount =>
      integer().withDefault(const Constant(0))();

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
  IntColumn get lastTalentRefreshWeek => integer().withDefault(const Constant(1))();
  IntColumn get currentWeek => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get venue => text()();
  IntColumn get ticketPrice => integer().withDefault(const Constant(50))();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get promotionBudgetSpent =>
      integer().withDefault(const Constant(0))();
  IntColumn get attendance => integer().withDefault(const Constant(0))();
  IntColumn get ppvBuys => integer().withDefault(const Constant(0))();
  IntColumn get revenue => integer().withDefault(const Constant(0))();
  IntColumn get expenses => integer().withDefault(const Constant(0))();
  IntColumn get reputationChange => integer().withDefault(const Constant(0))();
  TextColumn get fightOfTheNightFightId => text().nullable()();
  TextColumn get performanceOfTheNightFighterId => text().nullable()();

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
  TextColumn get titleFightType =>
      text().withDefault(const Constant('none'))();
  BoolColumn get isMainEvent => boolean().withDefault(const Constant(false))();
  BoolColumn get isCoMainEvent =>
      boolean().withDefault(const Constant(false))();
  IntColumn get rounds => integer().withDefault(const Constant(3))();
  IntColumn get cardOrder => integer().withDefault(const Constant(0))();

  TextColumn get resultWinnerId => text().nullable()();
  TextColumn get resultMethod => text().nullable()();
  IntColumn get resultRound => integer().nullable()();
  IntColumn get resultTimeSeconds => integer().withDefault(const Constant(300))();
  TextColumn get resultDecisionType =>
      text().withDefault(const Constant('none'))();
  TextColumn get resultMethodDetail =>
      text().withDefault(const Constant(''))();
  IntColumn get winnerPerformanceRating => integer().nullable()();
  IntColumn get loserPerformanceRating => integer().nullable()();
  TextColumn get resultFighterAInjury => text().nullable()();
  TextColumn get resultFighterBInjury => text().nullable()();

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

/// Notifications about the player's own roster — injuries, retirements,
/// and fighters wanting a booking. See [InboxItem].
@DataClassName('InboxItemRow')
class InboxItems extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get week => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get fighterId => text().nullable()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
