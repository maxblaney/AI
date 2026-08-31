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
    headshotAsset: row.headshotAsset,
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
    injuryClearsAtWeek: row.injuryClearsAtWeek,
    winStreak: row.winStreak,
    lossStreak: row.lossStreak,
    contract: contractRow == null ? null : contractFromRow(contractRow),
    eloRating: row.eloRating,
    isRanked: row.isRanked,
    retired: row.retired,
    retirementReason: row.retirementReason,
    fightOfTheNightCount: row.fightOfTheNightCount,
    performanceOfTheNightCount: row.performanceOfTheNightCount,
    condition: row.condition,
    lastFoughtWeek: row.lastFoughtWeek,
    belts: _beltsFromJson(row.beltsJson),
    interimBelts: _beltsFromJson(row.interimBeltsJson),
    suspendedUntilWeek: row.suspendedUntilWeek,
  );
}

FightersCompanion fighterToCompanion(Fighter fighter, String saveId) {
  return FightersCompanion.insert(
    id: fighter.id,
    saveId: Value(saveId),
    name: fighter.name,
    age: fighter.age,
    nationality: fighter.nationality,
    headshotAsset: Value(fighter.headshotAsset),
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
    injuryClearsAtWeek: Value(fighter.injuryClearsAtWeek),
    winStreak: Value(fighter.winStreak),
    lossStreak: Value(fighter.lossStreak),
    eloRating: Value(fighter.eloRating),
    isRanked: Value(fighter.isRanked),
    retired: Value(fighter.retired),
    retirementReason: Value(fighter.retirementReason),
    fightOfTheNightCount: Value(fighter.fightOfTheNightCount),
    performanceOfTheNightCount: Value(fighter.performanceOfTheNightCount),
    condition: Value(fighter.condition),
    lastFoughtWeek: Value(fighter.lastFoughtWeek),
    beltsJson: Value(_beltsToJson(fighter.belts)),
    interimBeltsJson: Value(_beltsToJson(fighter.interimBelts)),
    suspendedUntilWeek: Value(fighter.suspendedUntilWeek),
  );
}

/// Belts are stored as a JSON array of `WeightClass.name`s. Unknown
/// names are dropped rather than thrown on, so a save written by a newer
/// build with an extra division still loads.
Set<WeightClass> _beltsFromJson(String raw) {
  if (raw.isEmpty) return const {};
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const {};
  final byName = {for (final w in WeightClass.values) w.name: w};
  return {
    for (final entry in decoded)
      if (entry is String && byName.containsKey(entry)) byName[entry]!,
  };
}

String _beltsToJson(Set<WeightClass> belts) =>
    jsonEncode([for (final w in WeightClass.values) if (belts.contains(w)) w.name]);

Contract contractFromRow(ContractRow row) {
  return Contract(
    id: row.id,
    fighterId: row.fighterId,
    fightsRemaining: row.fightsRemaining,
    showMoney: row.showMoney,
    winBonus: row.winBonus,
    exclusive: row.exclusive,
    signedOn: row.signedOn,
  );
}

ContractsCompanion contractToCompanion(Contract contract) {
  return ContractsCompanion.insert(
    id: contract.id,
    fighterId: contract.fighterId,
    fightsRemaining: contract.fightsRemaining,
    showMoney: contract.showMoney,
    winBonus: contract.winBonus,
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
    lastTalentRefreshWeek: row.lastTalentRefreshWeek,
    currentWeek: row.currentWeek,
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
    lastTalentRefreshWeek: Value(org.lastTalentRefreshWeek),
    currentWeek: Value(org.currentWeek),
  );
}

MmaEvent eventFromRow(EventRow row) {
  return MmaEvent(
    id: row.id,
    name: row.name,
    date: row.date,
    venue: Venue.values.byName(row.venue),
    ticketPrice: row.ticketPrice,
    bookedAtWeek: row.bookedAtWeek,
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

EventsCompanion eventToCompanion(MmaEvent event, String saveId) {
  return EventsCompanion.insert(
    id: event.id,
    saveId: Value(saveId),
    name: event.name,
    date: event.date,
    venue: event.venue.name,
    ticketPrice: Value(event.ticketPrice),
    bookedAtWeek: Value(event.bookedAtWeek),
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

/// Box scores are persisted as JSON rather than a column per stat — see
/// the note on `Fights.statsAJson`. An empty or unreadable blob decodes
/// to an empty statline, which is what fights resolved before v3 have.
Map<String, dynamic> _statlineToJson(FightStatline s) => {
      'sigL': s.significantStrikesLanded,
      'sigA': s.significantStrikesAttempted,
      'head': s.headStrikes,
      'body': s.bodyStrikes,
      'leg': s.legStrikes,
      'tdL': s.takedownsLanded,
      'tdA': s.takedownsAttempted,
      'sub': s.submissionAttempts,
      'kd': s.knockdowns,
      'ctrl': s.controlSeconds,
      'rev': s.reversals,
    };

FightStatline _statlineFromJson(String raw) {
  if (raw.isEmpty) return const FightStatline();
  try {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    int read(String key) => (j[key] as num?)?.toInt() ?? 0;
    return FightStatline(
      significantStrikesLanded: read('sigL'),
      significantStrikesAttempted: read('sigA'),
      headStrikes: read('head'),
      bodyStrikes: read('body'),
      legStrikes: read('leg'),
      takedownsLanded: read('tdL'),
      takedownsAttempted: read('tdA'),
      submissionAttempts: read('sub'),
      knockdowns: read('kd'),
      controlSeconds: read('ctrl'),
      reversals: read('rev'),
    );
  } on FormatException {
    return const FightStatline();
  }
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
      statsA: _statlineFromJson(row.statsAJson),
      statsB: _statlineFromJson(row.statsBJson),
      // Momentum ticks, play-by-play and scorecards stay display-only —
      // they're only present on a freshly-simulated result held in memory.
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
    preFightProbabilityA: row.preFightProbabilityA,
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
    statsAJson: Value(fight.result == null
        ? ''
        : jsonEncode(_statlineToJson(fight.result!.statsA))),
    statsBJson: Value(fight.result == null
        ? ''
        : jsonEncode(_statlineToJson(fight.result!.statsB))),
    preFightProbabilityA: Value(fight.preFightProbabilityA),
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

RandomEventsCompanion randomEventToCompanion(RandomEvent event, String saveId) {
  final choicesJson = jsonEncode(event.choices
      .map((c) => {
            'id': c.id,
            'label': c.label,
            'consequenceSummary': c.consequenceSummary,
          })
      .toList());
  return RandomEventsCompanion.insert(
    id: event.id,
    saveId: Value(saveId),
    type: event.type.name,
    affectedFighterId: Value(event.affectedFighterId),
    headline: event.headline,
    description: event.description,
    choicesJson: choicesJson,
    chosenChoiceId: Value(event.chosenChoiceId),
    occurredOn: event.occurredOn,
  );
}

InboxItem inboxItemFromRow(InboxItemRow row) {
  return InboxItem(
    id: row.id,
    type: InboxItemType.values.byName(row.type),
    week: row.week,
    title: row.title,
    body: row.body,
    fighterId: row.fighterId,
    read: row.read,
  );
}

InboxItemsCompanion inboxItemToCompanion(InboxItem item, String saveId) {
  return InboxItemsCompanion.insert(
    id: item.id,
    saveId: Value(saveId),
    type: item.type.name,
    week: item.week,
    title: item.title,
    body: item.body,
    fighterId: Value(item.fighterId),
    read: Value(item.read),
  );
}
