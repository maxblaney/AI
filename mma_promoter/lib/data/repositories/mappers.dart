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
    reachInches: row.reachInches,
    record: FightRecord(wins: row.wins, losses: row.losses, draws: row.draws),
    fightingStats: FightingStats(
      punching: row.punching,
      kicking: row.kicking,
      power: row.power,
      speed: row.speed,
      accuracy: row.accuracy,
      defense: row.defense,
      headMovement: row.headMovement,
      blocking: row.blocking,
      footwork: row.footwork,
      takedowns: row.takedowns,
      takedownDefense: row.takedownDefense,
      wrestling: row.wrestling,
      clinchStriking: row.clinchStriking,
      clinchControl: row.clinchControl,
      clinchDefense: row.clinchDefense,
      topControl: row.topControl,
      groundAndPound: row.groundAndPound,
      guardRetention: row.guardRetention,
      sweeps: row.sweeps,
      scrambling: row.scrambling,
      submissionOffense: row.submissionOffense,
      submissionDefense: row.submissionDefense,
      grappling: row.grappling,
    ),
    physicalStats: PhysicalStats(
      cardio: row.cardio,
      durability: row.durability,
      chin: row.chin,
      bodyToughness: row.bodyToughness,
      legToughness: row.legToughness,
      strength: row.strength,
      athleticism: row.athleticism,
      recovery: row.recovery,
      explosiveness: row.explosiveness,
      flexibility: row.flexibility,
      gripStrength: row.gripStrength,
    ),
    mentalStats: MentalStats(
      fightIq: row.fightIq,
      composure: row.composure,
      aggression: row.aggression,
      discipline: row.discipline,
      confidence: row.confidence,
      heart: row.heart,
      adaptability: row.adaptability,
      killerInstinct: row.killerInstinct,
    ),
    tendencies: Tendencies(
      strikingFrequency: row.tendStrikingFrequency,
      takedownFrequency: row.tendTakedownFrequency,
      kickFrequency: row.tendKickFrequency,
      clinchFrequency: row.tendClinchFrequency,
      submissionAttempts: row.tendSubmissionAttempts,
      groundAndPound: row.tendGroundAndPound,
      positionControl: row.tendPositionControl,
      standUpPreference: row.tendStandUpPreference,
      wallWork: row.tendWallWork,
      aggression: row.tendAggression,
      counterStriking: row.tendCounterStriking,
      headHunting: row.tendHeadHunting,
      bodyAttacks: row.tendBodyAttacks,
      legAttacks: row.tendLegAttacks,
    ),
    style: FightingStyle.values.byName(row.style),
    potential: row.potential,
    popularity: row.popularity,
    morale: row.morale,
    injuryStatus: InjuryStatus.values.byName(row.injuryStatus),
    winStreak: row.winStreak,
    lossStreak: row.lossStreak,
    contract: contractRow == null ? null : contractFromRow(contractRow),
    eloRating: row.eloRating,
    isRanked: row.isRanked,
    retired: row.retired,
    retirementReason: row.retirementReason,
    fightOfTheNightCount: row.fightOfTheNightCount,
    performanceOfTheNightCount: row.performanceOfTheNightCount,
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
    reachInches: Value(fighter.reachInches),
    wins: Value(fighter.record.wins),
    losses: Value(fighter.record.losses),
    draws: Value(fighter.record.draws),
    punching: fighter.fightingStats.punching,
    kicking: fighter.fightingStats.kicking,
    power: fighter.fightingStats.power,
    speed: fighter.fightingStats.speed,
    accuracy: fighter.fightingStats.accuracy,
    defense: fighter.fightingStats.defense,
    headMovement: Value(fighter.fightingStats.headMovement),
    blocking: Value(fighter.fightingStats.blocking),
    footwork: Value(fighter.fightingStats.footwork),
    takedowns: fighter.fightingStats.takedowns,
    takedownDefense: fighter.fightingStats.takedownDefense,
    wrestling: fighter.fightingStats.wrestling,
    clinchStriking: Value(fighter.fightingStats.clinchStriking),
    clinchControl: Value(fighter.fightingStats.clinchControl),
    clinchDefense: Value(fighter.fightingStats.clinchDefense),
    topControl: Value(fighter.fightingStats.topControl),
    groundAndPound: fighter.fightingStats.groundAndPound,
    guardRetention: Value(fighter.fightingStats.guardRetention),
    sweeps: Value(fighter.fightingStats.sweeps),
    scrambling: Value(fighter.fightingStats.scrambling),
    submissionOffense: fighter.fightingStats.submissionOffense,
    submissionDefense: fighter.fightingStats.submissionDefense,
    grappling: fighter.fightingStats.grappling,
    cardio: fighter.physicalStats.cardio,
    durability: fighter.physicalStats.durability,
    chin: fighter.physicalStats.chin,
    bodyToughness: fighter.physicalStats.bodyToughness,
    legToughness: fighter.physicalStats.legToughness,
    strength: fighter.physicalStats.strength,
    athleticism: fighter.physicalStats.athleticism,
    recovery: fighter.physicalStats.recovery,
    explosiveness: Value(fighter.physicalStats.explosiveness),
    flexibility: Value(fighter.physicalStats.flexibility),
    gripStrength: Value(fighter.physicalStats.gripStrength),
    fightIq: fighter.mentalStats.fightIq,
    composure: fighter.mentalStats.composure,
    aggression: fighter.mentalStats.aggression,
    discipline: fighter.mentalStats.discipline,
    confidence: fighter.mentalStats.confidence,
    heart: fighter.mentalStats.heart,
    adaptability: fighter.mentalStats.adaptability,
    killerInstinct: Value(fighter.mentalStats.killerInstinct),
    tendStrikingFrequency: fighter.tendencies.strikingFrequency,
    tendTakedownFrequency: fighter.tendencies.takedownFrequency,
    tendKickFrequency: fighter.tendencies.kickFrequency,
    tendClinchFrequency: fighter.tendencies.clinchFrequency,
    tendSubmissionAttempts: fighter.tendencies.submissionAttempts,
    tendGroundAndPound: fighter.tendencies.groundAndPound,
    tendPositionControl: Value(fighter.tendencies.positionControl),
    tendStandUpPreference: Value(fighter.tendencies.standUpPreference),
    tendWallWork: Value(fighter.tendencies.wallWork),
    tendAggression: fighter.tendencies.aggression,
    tendCounterStriking: fighter.tendencies.counterStriking,
    tendHeadHunting: fighter.tendencies.headHunting,
    tendBodyAttacks: fighter.tendencies.bodyAttacks,
    tendLegAttacks: fighter.tendencies.legAttacks,
    style: Value(fighter.style.name),
    potential: Value(fighter.potential),
    popularity: Value(fighter.popularity),
    morale: Value(fighter.morale),
    injuryStatus: Value(fighter.injuryStatus.name),
    winStreak: Value(fighter.winStreak),
    lossStreak: Value(fighter.lossStreak),
    eloRating: Value(fighter.eloRating),
    isRanked: Value(fighter.isRanked),
    retired: Value(fighter.retired),
    retirementReason: Value(fighter.retirementReason),
    fightOfTheNightCount: Value(fighter.fightOfTheNightCount),
    performanceOfTheNightCount: Value(fighter.performanceOfTheNightCount),
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
    lastTalentRefresh: row.lastTalentRefresh,
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
    lastTalentRefresh: org.lastTalentRefresh,
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
      timeSeconds: row.resultTimeSeconds,
      decisionType: DecisionType.values.byName(row.resultDecisionType),
      methodDetail: row.resultMethodDetail,
      winnerPerformanceRating: row.winnerPerformanceRating ?? 0,
      loserPerformanceRating: row.loserPerformanceRating ?? 0,
      fighterAInjury: row.resultFighterAInjury == null
          ? InjuryStatus.healthy
          : InjuryStatus.values.byName(row.resultFighterAInjury!),
      fighterBInjury: row.resultFighterBInjury == null
          ? InjuryStatus.healthy
          : InjuryStatus.values.byName(row.resultFighterBInjury!),
      // Momentum ticks, play-by-play, box score and scorecards are
      // display-only and not persisted; they're only present on a
      // freshly-simulated result held in memory.
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
    resultTimeSeconds: Value(fight.result?.timeSeconds ?? 300),
    resultDecisionType: Value(fight.result?.decisionType.name ?? 'none'),
    resultMethodDetail: Value(fight.result?.methodDetail ?? ''),
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
