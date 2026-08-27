import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/models.dart';

/// Conversions between Drift row types (persistence) and plain domain
/// models (used by domain logic and UI). Keeping this in one place means
/// the DB schema can evolve without touching either layer directly.

Fighter fighterFromRow(FighterRow row, ContractRow? contractRow) {
  return Fighter(
    id: row.id,
    name: row.name,
    age: row.age,
    nationality: row.nationality,
    weightClass: WeightClass.values.byName(row.weightClass),
    heightInches: row.heightInches,
    weightLbs: row.weightLbs,
    record: FightRecord(wins: row.wins, losses: row.losses, draws: row.draws),
    stats: FighterStats(
      striking: row.striking,
      grappling: row.grappling,
      cardio: row.cardio,
      chin: row.chin,
      power: row.power,
    ),
    popularity: row.popularity,
    morale: row.morale,
    injuryStatus: InjuryStatus.values.byName(row.injuryStatus),
    winStreak: row.winStreak,
    styleTags: row.styleTags.isEmpty
        ? const []
        : row.styleTags.split(',').map(StyleTag.values.byName).toList(),
    contract: contractRow == null ? null : contractFromRow(contractRow),
  );
}

FightersCompanion fighterToCompanion(Fighter fighter) {
  return FightersCompanion.insert(
    id: fighter.id,
    name: fighter.name,
    age: fighter.age,
    nationality: fighter.nationality,
    weightClass: fighter.weightClass.name,
    heightInches: Value(fighter.heightInches),
    weightLbs: Value(fighter.weightLbs),
    wins: Value(fighter.record.wins),
    losses: Value(fighter.record.losses),
    draws: Value(fighter.record.draws),
    striking: fighter.stats.striking,
    grappling: fighter.stats.grappling,
    cardio: fighter.stats.cardio,
    chin: fighter.stats.chin,
    power: fighter.stats.power,
    popularity: Value(fighter.popularity),
    morale: Value(fighter.morale),
    injuryStatus: Value(fighter.injuryStatus.name),
    winStreak: Value(fighter.winStreak),
    styleTags: Value(fighter.styleTags.map((t) => t.name).join(',')),
  );
}

Contract contractFromRow(ContractRow row) {
  return Contract(
    id: row.id,
    fighterId: row.fighterId,
    fightsRemaining: row.fightsRemaining,
    payPerFight: row.payPerFight,
    exclusive: row.exclusive,
    signedOn: row.signedOn,
  );
}

ContractsCompanion contractToCompanion(Contract contract) {
  return ContractsCompanion.insert(
    id: contract.id,
    fighterId: contract.fighterId,
    fightsRemaining: contract.fightsRemaining,
    payPerFight: contract.payPerFight,
    exclusive: Value(contract.exclusive),
    signedOn: contract.signedOn,
  );
}

Organization organizationFromRow(OrganizationRow row) {
  return Organization(
    id: row.id,
    name: row.name,
    reputationTier: ReputationTier.values.byName(row.reputationTier),
    reputationPoints: row.reputationPoints,
    cashBalance: row.cashBalance,
    fanbaseSize: row.fanbaseSize,
    homeRegion: row.homeRegion,
    promotionBudget: row.promotionBudget,
  );
}

OrganizationsCompanion organizationToCompanion(Organization org) {
  return OrganizationsCompanion.insert(
    id: org.id,
    name: org.name,
    reputationTier: Value(org.reputationTier.name),
    reputationPoints: Value(org.reputationPoints),
    cashBalance: org.cashBalance,
    fanbaseSize: Value(org.fanbaseSize),
    homeRegion: org.homeRegion,
    promotionBudget: Value(org.promotionBudget),
  );
}

MmaEvent eventFromRow(EventRow row) {
  return MmaEvent(
    id: row.id,
    name: row.name,
    date: row.date,
    venue: Venue.values.byName(row.venue),
    ticketPrice: row.ticketPrice,
    status: EventStatus.values.byName(row.status),
    promotionBudgetSpent: row.promotionBudgetSpent,
    attendance: row.attendance,
    ppvBuys: row.ppvBuys,
    revenue: row.revenue,
    expenses: row.expenses,
    reputationChange: row.reputationChange,
    fightOfTheNightFightId: row.fightOfTheNightFightId,
    performanceOfTheNightFighterId: row.performanceOfTheNightFighterId,
  );
}

EventsCompanion eventToCompanion(MmaEvent event) {
  return EventsCompanion.insert(
    id: event.id,
    name: event.name,
    date: event.date,
    venue: event.venue.name,
    ticketPrice: Value(event.ticketPrice),
    status: Value(event.status.name),
    promotionBudgetSpent: Value(event.promotionBudgetSpent),
    attendance: Value(event.attendance),
    ppvBuys: Value(event.ppvBuys),
    revenue: Value(event.revenue),
    expenses: Value(event.expenses),
    reputationChange: Value(event.reputationChange),
    fightOfTheNightFightId: Value(event.fightOfTheNightFightId),
    performanceOfTheNightFighterId:
        Value(event.performanceOfTheNightFighterId),
  );
}

Fight fightFromRow(FightRow row) {
  FightResult? result;
  if (row.resultWinnerId != null && row.resultMethod != null) {
    result = FightResult(
      winnerId: row.resultWinnerId!,
      method: FightMethod.values.byName(row.resultMethod!),
      round: row.resultRound ?? 1,
      winnerPerformanceRating: row.winnerPerformanceRating ?? 0,
      loserPerformanceRating: row.loserPerformanceRating ?? 0,
      fighterAInjury: row.resultFighterAInjury == null
          ? InjuryStatus.healthy
          : InjuryStatus.values.byName(row.resultFighterAInjury!),
      fighterBInjury: row.resultFighterBInjury == null
          ? InjuryStatus.healthy
          : InjuryStatus.values.byName(row.resultFighterBInjury!),
      // Round-by-round scores are display-only and not persisted; they're
      // only present on a freshly-simulated result held in memory.
    );
  }
  return Fight(
    id: row.id,
    eventId: row.eventId,
    fighterAId: row.fighterAId,
    fighterBId: row.fighterBId,
    weightClass: WeightClass.values.byName(row.weightClass),
    titleFightType: TitleFightType.values.byName(row.titleFightType),
    isMainEvent: row.isMainEvent,
    isCoMainEvent: row.isCoMainEvent,
    rounds: row.rounds,
    cardOrder: row.cardOrder,
    result: result,
  );
}

FightsCompanion fightToCompanion(Fight fight) {
  return FightsCompanion.insert(
    id: fight.id,
    eventId: fight.eventId,
    fighterAId: fight.fighterAId,
    fighterBId: fight.fighterBId,
    weightClass: fight.weightClass.name,
    titleFightType: Value(fight.titleFightType.name),
    isMainEvent: Value(fight.isMainEvent),
    isCoMainEvent: Value(fight.isCoMainEvent),
    rounds: Value(fight.rounds),
    cardOrder: Value(fight.cardOrder),
    resultWinnerId: Value(fight.result?.winnerId),
    resultMethod: Value(fight.result?.method.name),
    resultRound: Value(fight.result?.round),
    winnerPerformanceRating: Value(fight.result?.winnerPerformanceRating),
    loserPerformanceRating: Value(fight.result?.loserPerformanceRating),
    resultFighterAInjury: Value(fight.result?.fighterAInjury.name),
    resultFighterBInjury: Value(fight.result?.fighterBInjury.name),
  );
}

RandomEvent randomEventFromRow(RandomEventRow row) {
  final rawChoices = jsonDecode(row.choicesJson) as List<dynamic>;
  return RandomEvent(
    id: row.id,
    type: RandomEventType.values.byName(row.type),
    affectedFighterId: row.affectedFighterId,
    headline: row.headline,
    description: row.description,
    occurredOn: row.occurredOn,
    chosenChoiceId: row.chosenChoiceId,
    choices: rawChoices
        .map((c) => RandomEventChoice(
              id: c['id'] as String,
              label: c['label'] as String,
              consequenceSummary: c['consequenceSummary'] as String,
            ))
        .toList(),
  );
}

RandomEventsCompanion randomEventToCompanion(RandomEvent event) {
  final choicesJson = jsonEncode(event.choices
      .map((c) => {
            'id': c.id,
            'label': c.label,
            'consequenceSummary': c.consequenceSummary,
          })
      .toList());
  return RandomEventsCompanion.insert(
    id: event.id,
    type: event.type.name,
    affectedFighterId: Value(event.affectedFighterId),
    headline: event.headline,
    description: event.description,
    choicesJson: choicesJson,
    chosenChoiceId: Value(event.chosenChoiceId),
    occurredOn: event.occurredOn,
  );
}
