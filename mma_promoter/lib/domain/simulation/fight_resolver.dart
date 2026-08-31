import 'dart:math';

import '../../data/models/models.dart';
import 'judging.dart';
import 'submissions.dart';

/// Live, mutable state for one fighter over the course of one bout.
///
/// Everything the resolver reads goes through [rate], so fatigue, damage,
/// morale and pre-existing injuries automatically degrade every single
/// stat rather than being bolted on at one or two call sites.
class _Corner {
  final Fighter f;
  final bool isA;

  /// Morale and carried-in injury, folded into one multiplier up front.
  final double condition;

  double stamina = 100;
  double health = 100; // head/overall — hits 0 and you're out.
  double bodyHealth = 100;
  double legHealth = 100;

  /// Seconds of "rocked" state remaining. While positive the fighter is
  /// badly compromised and one clean shot away from a stoppage.
  double hurtSeconds = 0;
  double cutSeverity = 0;

  // -- Fight totals (box score) --
  int sigLanded = 0;
  int sigThrown = 0;
  int headLanded = 0;
  int bodyLanded = 0;
  int legLanded = 0;
  int tdLanded = 0;
  int tdThrown = 0;
  int subAttempts = 0;
  int knockdowns = 0;
  int controlSeconds = 0;
  int reversals = 0;
  double damageDealt = 0;
  double damageTaken = 0;

  /// What this fighter has done in the round currently being fought.
  RoundTally tally = RoundTally();

  _Corner(this.f, {required this.isA})
      : condition = _conditionFactor(f);

  static double _conditionFactor(Fighter f) {
    final morale = 0.9 + (f.morale.clamp(0, 100) / 100) * 0.2; // 0.9 - 1.1
    final injury = switch (f.injuryStatus) {
      InjuryStatus.healthy => 1.0,
      InjuryStatus.minor => 0.88,
      InjuryStatus.major => 0.68,
    };
    return morale * injury;
  }

  FightingStats get fs => f.fightingStats;
  PhysicalStats get ps => f.physicalStats;
  MentalStats get ms => f.mentalStats;
  Tendencies get t => f.tendencies;

  bool get isHurt => hurtSeconds > 0;

  /// The usable value of a stat right now.
  ///
  /// [fatigue] scales how badly an empty gas tank hurts this particular
  /// attribute — explosive things (shots, speed) collapse when tired,
  /// while chin and heart barely care. [legDependent] additionally scales
  /// with leg health, so a chopped-up fighter can't move, kick or shoot.
  double rate(int base, {double fatigue = 1.0, bool legDependent = false}) {
    var v = base * condition;
    final gas = stamina / 100;
    v *= 1 - (1 - gas) * 0.45 * fatigue;
    v *= 0.80 + 0.20 * (health / 100); // accumulated damage dulls output
    if (legDependent) v *= 0.55 + 0.45 * (legHealth / 100);
    if (isHurt) v *= 0.55;
    return v;
  }

  /// Weighted blend helper — `rate` each stat then combine.
  double blend(List<(int, double)> parts, {double fatigue = 1.0, bool legDependent = false}) {
    var total = 0.0;
    for (final (value, weight) in parts) {
      total += rate(value, fatigue: fatigue, legDependent: legDependent) * weight;
    }
    return total;
  }

  void spendStamina(double base) {
    final efficiency = 0.55 + 0.9 * (ps.cardio / 100); // 0.55 - 1.45
    var cost = base / efficiency;
    cost *= 1 + (1 - bodyHealth / 100) * 0.9; // body work wrecks the tank
    stamina = (stamina - cost).clamp(0.0, 100.0);
  }

  void recoverBetweenRounds() {
    final gain = 11 + ps.recovery * 0.30;
    final bodyPenalty = (1 - bodyHealth / 100) * 0.55;
    stamina = (stamina + gain * (1 - bodyPenalty)).clamp(0.0, 100.0);
    health = (health + 1.5 + ps.recovery * 0.055).clamp(0.0, 100.0);
    bodyHealth = (bodyHealth + 2 + ps.recovery * 0.05).clamp(0.0, 100.0);
    hurtSeconds = 0;
  }

  void takeHeadDamage(double amount) {
    final resist = 0.62 + 0.75 * (ps.durability / 100);
    final applied = amount / resist;
    health = (health - applied).clamp(0.0, 100.0);
    damageTaken += applied;
  }

  void takeBodyDamage(double amount) {
    final resist = 0.62 + 0.75 * (ps.bodyToughness / 100);
    final applied = amount / resist;
    bodyHealth = (bodyHealth - applied).clamp(0.0, 100.0);
    // Body shots also drain the tank hard.
    stamina = (stamina - applied * 0.75).clamp(0.0, 100.0);
    damageTaken += applied * 0.5;
  }

  void takeLegDamage(double amount) {
    final resist = 0.62 + 0.75 * (ps.legToughness / 100);
    final applied = amount / resist;
    legHealth = (legHealth - applied).clamp(0.0, 100.0);
    damageTaken += applied * 0.4;
  }

  FightStatline toStatline() => FightStatline(
        significantStrikesLanded: sigLanded,
        significantStrikesAttempted: sigThrown,
        headStrikes: headLanded,
        bodyStrikes: bodyLanded,
        legStrikes: legLanded,
        takedownsLanded: tdLanded,
        takedownsAttempted: tdThrown,
        submissionAttempts: subAttempts,
        knockdowns: knockdowns,
        controlSeconds: controlSeconds,
        reversals: reversals,
      );
}

/// How the fight ended, once something has ended it.
class _Finish {
  final String winnerId;
  final FightMethod method;
  final String detail;
  final int round;
  final int timeSeconds;

  const _Finish({
    required this.winnerId,
    required this.method,
    required this.detail,
    required this.round,
    required this.timeSeconds,
  });
}

/// Resolves a matchup into a [FightResult] by actually simulating it:
/// the fight moves between standing, clinch and ground positions, fighters
/// choose actions from their [Tendencies] and execute them with their
/// [FightingStats], damage and fatigue accumulate, and if nobody finishes
/// it, three judges score it round by round.
///
/// Pure Dart, no Flutter/DB dependencies, so it can be unit tested by
/// injecting a seeded [Random] for deterministic outcomes.
class FightResolver {
  static const int roundLengthSeconds = Fight.roundLengthSeconds;

  final Random _random;

  FightResolver({Random? random}) : _random = random ?? Random();

  // -- Per-bout scratch state. Reset at the top of every resolve() call. --
  late _Corner _a;
  late _Corner _b;
  late int _scheduledRounds;
  FightPosition _position = FightPosition.standing;
  GroundPosition _groundPosition = GroundPosition.guard;
  _Corner? _controller; // whoever is on top / running the clinch.
  int _round = 1;
  int _clock = 0;
  double _momentum = 0.5;
  double _creditA = 0;
  double _creditB = 0;
  /// Seconds of ground control with nothing happening — the referee
  /// eventually stands them back up, which is what keeps real fights from
  /// being 60% control time.
  int _stalledGroundSeconds = 0;
  _Finish? _finish;
  final List<MomentumTick> _ticks = [];
  final List<FightEvent> _events = [];
  final List<(RoundTally, RoundTally)> _roundTallies = [];

  /// [rounds] is the fight's scheduled length (3 or 5) — see [Fight.rounds].
  FightResult resolve({
    required Fighter fighterA,
    required Fighter fighterB,
    int rounds = 3,
  }) {
    _resetBout(fighterA, fighterB, rounds);

    roundLoop:
    for (_round = 1; _round <= _scheduledRounds; _round++) {
      _startRound();

      while (_clock < roundLengthSeconds) {
        final elapsed = _runExchange();
        _clock += elapsed;
        _decayHurt(elapsed.toDouble());
        _emitTick();
        if (_finish != null) break roundLoop;
      }

      _endRound();
      if (_finish != null) break roundLoop;
      if (_round < _scheduledRounds) _betweenRounds();
    }

    return _buildResult(fighterA, fighterB);
  }

  void _resetBout(Fighter fighterA, Fighter fighterB, int rounds) {
    _a = _Corner(fighterA, isA: true);
    _b = _Corner(fighterB, isA: false);
    _scheduledRounds = rounds;
    _position = FightPosition.standing;
    _groundPosition = GroundPosition.guard;
    _controller = null;
    _round = 1;
    _clock = 0;
    _momentum = 0.5;
    _creditA = 0;
    _creditB = 0;
    _stalledGroundSeconds = 0;
    _finish = null;
    _ticks.clear();
    _events.clear();
    _roundTallies.clear();
  }

  void _startRound() {
    _clock = 0;
    // Every round restarts on the feet.
    _position = FightPosition.standing;
    _controller = null;
    _groundPosition = GroundPosition.guard;
    _stalledGroundSeconds = 0;
    _a.tally = RoundTally();
    _b.tally = RoundTally();
    _log(FightEventType.roundStart, 'Round $_round begins.');
  }

  void _endRound() {
    _roundTallies.add((_a.tally, _b.tally));
    _log(FightEventType.roundEnd, 'End of round $_round.');
  }

  void _betweenRounds() {
    _a.recoverBetweenRounds();
    _b.recoverBetweenRounds();
    _checkDoctorStoppage(_a, _b);
    if (_finish == null) _checkDoctorStoppage(_b, _a);
  }

  /// A badly cut fighter can get pulled out between rounds.
  void _checkDoctorStoppage(_Corner corner, _Corner opponent) {
    if (corner.cutSeverity < 72) return;
    final toughness = corner.ms.heart * 0.5 + corner.ps.durability * 0.5;
    final chance = ((corner.cutSeverity - 72) / 190) * (1.4 - toughness / 200);
    if (_random.nextDouble() < chance) {
      _setFinish(
        winner: opponent,
        method: FightMethod.doctorStoppage,
        detail: 'Cut',
      );
      _log(
        FightEventType.finish,
        'The doctor has seen enough — ${corner.f.name} is not allowed to continue.',
        fighter: opponent,
      );
    }
  }

  // ---- Exchange dispatch ---------------------------------------------------

  int _runExchange() {
    _creditA = 0;
    _creditB = 0;
    return switch (_position) {
      FightPosition.standing => _standingExchange(),
      FightPosition.clinch => _clinchExchange(),
      FightPosition.ground => _groundExchange(),
    };
  }

  // ---- Standing ------------------------------------------------------------

  int _standingExchange() {
    final initiator = _pickInitiator();
    final defender = _other(initiator);

    final action = _pickStandingAction(initiator, defender);
    return switch (action) {
      _StandingAction.strike => _strikingExchange(initiator, defender),
      _StandingAction.takedown => _takedownAttempt(initiator, defender, fromClinch: false),
      _StandingAction.clinch => _clinchEntry(initiator, defender),
      _StandingAction.reset => _resetExchange(initiator, defender),
    };
  }

  /// Whoever is pushing the pace this exchange. Footwork, speed and
  /// aggression decide who dictates; being hurt makes you reactive.
  _Corner _pickInitiator() {
    double drive(_Corner c) {
      final base = c.blend([
        (c.fs.footwork, 0.30),
        (c.fs.speed, 0.25),
      ], fatigue: 1.2, legDependent: true);
      final mind = (c.t.aggression * 0.6 + c.ms.aggression * 0.4) * 0.45;
      final counterPull = c.t.counterStriking * 0.18; // counter fighters wait
      return base + mind - counterPull + _random.nextDouble() * 22;
    }

    return drive(_a) >= drive(_b) ? _a : _b;
  }

  _StandingAction _pickStandingAction(_Corner c, _Corner opponent) {
    // Fight IQ: shooting into elite takedown defence, or standing with a
    // much better striker, is punished — smart fighters do it less.
    final tdEdge = c.blend([(c.fs.takedowns, 0.5), (c.fs.wrestling, 0.5)]) -
        opponent.blend([(opponent.fs.takedownDefense, 0.6), (opponent.fs.wrestling, 0.4)]);
    final iqAdjust = (c.ms.fightIq / 100) * tdEdge * 0.35;

    final weights = <_StandingAction, double>{
      _StandingAction.strike: c.t.strikingFrequency.toDouble() + 18,
      _StandingAction.takedown: (c.t.takedownFrequency + iqAdjust).clamp(2, 140),
      _StandingAction.clinch: c.t.clinchFrequency * 0.75 + 6,
      _StandingAction.reset: (100 - c.t.aggression) * 0.28 + c.t.counterStriking * 0.12,
    };

    // Chasing the finish: a hurt opponent gets swarmed, not wrestled.
    if (opponent.isHurt) {
      weights[_StandingAction.strike] =
          weights[_StandingAction.strike]! * (1.6 + c.ms.killerInstinct / 100);
      weights[_StandingAction.reset] = weights[_StandingAction.reset]! * 0.2;
    }
    // Gassed fighters stop shooting and start holding.
    if (c.stamina < 35) {
      weights[_StandingAction.takedown] = weights[_StandingAction.takedown]! * 0.55;
      weights[_StandingAction.clinch] = weights[_StandingAction.clinch]! * 1.5;
    }

    return _weightedPick(weights);
  }

  int _strikingExchange(_Corner attacker, _Corner defender) {
    _flurry(attacker, defender);

    // Real exchanges are two-way — unless they've been hurt or they're a
    // pure counter-fighter waiting for the next opening, the fighter being
    // hit throws back.
    if (_finish == null && !defender.isHurt) {
      final returnFire = 0.72 +
          defender.t.strikingFrequency / 100 * 0.2 +
          defender.t.aggression / 100 * 0.1;
      if (_random.nextDouble() < returnFire) {
        _flurry(defender, attacker, isReturn: true);
      }
    }
    return 4 + _random.nextInt(6);
  }

  void _flurry(_Corner attacker, _Corner defender, {bool isReturn = false}) {
    var volume = 5 +
        _random.nextInt(
          5 + ((attacker.t.strikingFrequency + attacker.t.aggression) / 20).round(),
        );
    if (isReturn) volume = (volume * 0.75).round().clamp(1, 8);

    for (var i = 0; i < volume && _finish == null; i++) {
      final landed = _throwStrike(attacker, defender, context: _StrikeContext.standing);
      if (!landed && _finish == null && !isReturn) {
        _maybeCounter(defender, attacker);
      }
    }
  }

  /// A missed strike is an opening — high counter-striking fighters make
  /// people pay for it.
  void _maybeCounter(_Corner counterer, _Corner original) {
    final speedEdge = counterer.rate(counterer.fs.speed) - original.rate(original.fs.speed);
    final chance = (counterer.t.counterStriking / 100) * 0.32 +
        (counterer.ms.fightIq / 100) * 0.08 +
        speedEdge * 0.002;
    if (_random.nextDouble() < chance.clamp(0.0, 0.55)) {
      _throwStrike(counterer, original, context: _StrikeContext.standing, isCounter: true);
    }
  }

  int _resetExchange(_Corner c, _Corner opponent) {
    // Circling out and resetting range — a breather that lets both
    // fighters get a little air back.
    c.stamina = (c.stamina + 1.2).clamp(0.0, 100.0);
    opponent.stamina = (opponent.stamina + 1.0).clamp(0.0, 100.0);
    return 5 + _random.nextInt(7);
  }

  // ---- Striking resolution -------------------------------------------------

  /// Returns true if the strike landed.
  bool _throwStrike(
    _Corner attacker,
    _Corner defender, {
    required _StrikeContext context,
    bool isCounter = false,
  }) {
    final target = _pickTarget(attacker, context);
    final isKick = _pickIsKick(attacker, context, target);

    attacker.sigThrown++;

    final offense = _strikeOffense(attacker, isKick: isKick, context: context);
    final defenseValue = _strikeDefense(defender, target, context: context);

    var landChance = 0.33 + (offense - defenseValue) / 175;
    landChance += switch (target) {
      StrikeTarget.head => 0.0,
      StrikeTarget.body => 0.06,
      StrikeTarget.leg => 0.11,
    };
    if (context == _StrikeContext.standing) {
      // Reach matters at range, and only at range.
      landChance += (attacker.f.reach - defender.f.reach) * 0.006;
    }
    if (context == _StrikeContext.ground) {
      landChance += _groundPosition.strikeMultiplier * 0.09;
    }
    if (isCounter) landChance += 0.08;
    if (defender.isHurt) landChance += 0.24;
    landChance = landChance.clamp(0.05, 0.82);

    attacker.spendStamina(isKick ? 1.5 : 1.0);

    if (_random.nextDouble() >= landChance) return false;

    // -- It landed --
    attacker.sigLanded++;
    attacker.tally.significantStrikes++;
    switch (target) {
      case StrikeTarget.head:
        attacker.headLanded++;
      case StrikeTarget.body:
        attacker.bodyLanded++;
      case StrikeTarget.leg:
        attacker.legLanded++;
    }

    final damage = _strikeDamage(attacker, isKick: isKick, target: target, context: context);
    attacker.damageDealt += damage;
    attacker.tally.damage += damage;
    _credit(attacker, damage * 2.5 + 1.5);

    switch (target) {
      case StrikeTarget.head:
        defender.takeHeadDamage(damage);
        _maybeCut(attacker, defender, damage, context: context);
        _checkKnockdown(attacker, defender, damage, isKick: isKick, context: context);
      case StrikeTarget.body:
        defender.takeBodyDamage(damage);
        _checkBodyStoppage(attacker, defender);
      case StrikeTarget.leg:
        defender.takeLegDamage(damage);
        _checkLegStoppage(attacker, defender);
    }

    if (_finish == null) {
      _checkDamageStoppage(attacker, defender);
    }

    if (_finish == null && damage > 1.8) {
      _log(
        FightEventType.bigStrike,
        '${attacker.f.name} lands a big ${_strikeName(isKick, target, context)} '
        'on ${defender.f.name}.',
        fighter: attacker,
      );
    } else if (_finish == null && _random.nextDouble() < 0.22) {
      _log(
        FightEventType.strike,
        '${attacker.f.name} connects with a ${_strikeName(isKick, target, context)}.',
        fighter: attacker,
      );
    }
    return true;
  }

  double _strikeOffense(_Corner c, {required bool isKick, required _StrikeContext context}) {
    if (context == _StrikeContext.clinch) {
      return c.blend([
        (c.fs.clinchStriking, 0.45),
        (c.fs.accuracy, 0.30),
        (c.fs.punching, 0.25),
      ], fatigue: 0.9);
    }
    if (context == _StrikeContext.ground) {
      return c.blend([
        (c.fs.groundAndPound, 0.50),
        (c.fs.accuracy, 0.25),
        (c.fs.topControl, 0.25),
      ], fatigue: 0.9);
    }
    final weapon = isKick ? c.fs.kicking : c.fs.punching;
    return c.blend([
          (weapon, 0.38),
          (c.fs.accuracy, 0.34),
          (c.fs.speed, 0.28),
        ], fatigue: 1.1, legDependent: isKick) +
        (c.ms.fightIq / 100) * 6; // shot selection / setups
  }

  double _strikeDefense(_Corner c, StrikeTarget target, {required _StrikeContext context}) {
    if (context == _StrikeContext.ground) {
      // Very little you can do about strikes from a dominant position.
      return c.blend([
        (c.fs.guardRetention, 0.45),
        (c.fs.defense, 0.30),
        (c.fs.grappling, 0.25),
      ], fatigue: 0.7);
    }
    if (context == _StrikeContext.clinch) {
      return c.blend([
        (c.fs.clinchDefense, 0.45),
        (c.fs.blocking, 0.30),
        (c.fs.defense, 0.25),
      ], fatigue: 0.8);
    }
    return switch (target) {
      StrikeTarget.head => c.blend([
          (c.fs.defense, 0.30),
          (c.fs.headMovement, 0.30),
          (c.fs.footwork, 0.20),
          (c.fs.blocking, 0.20),
        ], fatigue: 1.2, legDependent: true),
      StrikeTarget.body => c.blend([
          (c.fs.defense, 0.30),
          (c.fs.blocking, 0.40),
          (c.fs.footwork, 0.30),
        ], fatigue: 1.1, legDependent: true),
      StrikeTarget.leg => c.blend([
          (c.fs.blocking, 0.55), // checking kicks
          (c.fs.footwork, 0.25),
          (c.fs.defense, 0.20),
        ], fatigue: 1.0, legDependent: true),
    };
  }

  double _strikeDamage(
    _Corner c, {
    required bool isKick,
    required StrikeTarget target,
    required _StrikeContext context,
  }) {
    // Scaled so a full fight's worth of clean shots wears a fighter down
    // without automatically ending them — accumulation raises knockdown
    // odds rather than acting as a health bar that empties on schedule.
    var base = 0.28 +
        c.rate(c.fs.power, fatigue: 0.5) / 100 * 1.75 +
        c.rate(c.ps.strength, fatigue: 0.4) / 100 * 0.42;

    if (isKick) base *= 1.18;
    base *= switch (target) {
      StrikeTarget.head => 1.0,
      StrikeTarget.body => 0.78,
      StrikeTarget.leg => 0.72,
    };
    base *= switch (context) {
      _StrikeContext.standing => 1.0,
      _StrikeContext.clinch => 0.88,
      _StrikeContext.ground => 0.80 + _groundPosition.strikeMultiplier * 0.45,
    };
    // Headhunters swing heavier at the cost of accuracy (already priced in
    // through target selection).
    base *= 0.92 + (c.t.headHunting / 100) * 0.16;
    return base * (0.8 + _random.nextDouble() * 0.45);
  }

  StrikeTarget _pickTarget(_Corner c, _StrikeContext context) {
    // Leg kicks only exist at range.
    final legWeight = context == _StrikeContext.standing ? c.t.legAttacks.toDouble() : 0.0;
    // On the ground it's overwhelmingly head strikes.
    final headWeight = context == _StrikeContext.ground
        ? c.t.headHunting + 120.0
        : c.t.headHunting + 25.0;
    return _weightedPick({
      StrikeTarget.head: headWeight,
      StrikeTarget.body: c.t.bodyAttacks.toDouble() + 12,
      StrikeTarget.leg: legWeight,
    });
  }

  bool _pickIsKick(_Corner c, _StrikeContext context, StrikeTarget target) {
    if (context != _StrikeContext.standing) return false;
    if (target == StrikeTarget.leg) return true;
    return _random.nextDouble() < (c.t.kickFrequency / 100) * 0.85;
  }

  // ---- Knockdowns, stoppages, cuts ----------------------------------------

  void _checkKnockdown(
    _Corner attacker,
    _Corner defender,
    double damage, {
    required bool isKick,
    required _StrikeContext context,
  }) {
    if (context == _StrikeContext.ground) return; // already down.

    final powerVsChin =
        (attacker.rate(attacker.fs.power, fatigue: 0.4) - defender.rate(defender.ps.chin, fatigue: 0.3)) / 100;
    // A worn-down fighter gets dropped by shots they'd have walked through
    // in round one.
    final wearFactor = 1 + (1 - defender.health / 100) * 2.6;

    var chance = (0.0062 + powerVsChin * 0.042 + (damage - 1.1) * 0.014) * wearFactor;
    if (isKick) chance *= 1.35; // head kicks end nights
    if (defender.isHurt) chance *= 2.0;
    chance = chance.clamp(0.0, 0.30);

    if (_random.nextDouble() >= chance) return;

    defender.knockdowns; // (kept for symmetry — knockdowns credited below)
    attacker.knockdowns++;
    attacker.tally.knockdowns++;
    attacker.tally.nearFinishes += 1;
    defender.hurtSeconds = 14 + _random.nextDouble() * 16;
    defender.takeHeadDamage(damage * 2.5);
    _credit(attacker, 22);

    _log(
      FightEventType.knockdown,
      '${attacker.f.name} DROPS ${defender.f.name} with a '
      '${_strikeName(isKick, StrikeTarget.head, context)}!',
      fighter: attacker,
    );

    if (defender.health <= 0) {
      _setFinish(
        winner: attacker,
        method: FightMethod.koTko,
        detail: _strikeName(isKick, StrikeTarget.head, context, capitalised: true),
      );
      _log(FightEventType.finish,
          '${defender.f.name} is out cold. ${attacker.f.name} wins by knockout!',
          fighter: attacker);
      return;
    }

    // Follow-up: does the attacker jump on it, and can the defender survive?
    final pursuit = 0.35 + attacker.ms.killerInstinct / 100 * 0.5 + attacker.t.aggression / 100 * 0.25;
    if (_random.nextDouble() < pursuit) {
      _swarm(attacker, defender);
    }
  }

  /// The finishing sequence after a knockdown — the attacker teeing off
  /// while the referee decides whether the defender is still there.
  void _swarm(_Corner attacker, _Corner defender) {
    final shots = 2 + _random.nextInt(3);
    for (var i = 0; i < shots && _finish == null; i++) {
      final landed = _throwStrike(attacker, defender, context: _StrikeContext.standing);
      if (!landed) continue;

      // Referee stoppage: heart and composure are what keep a hurt fighter
      // in the fight; recovery is what clears their head.
      final resilience =
          (defender.ms.heart * 0.4 + defender.ms.composure * 0.3 + defender.ps.recovery * 0.3) / 100;
      final stopChance = (0.31 - resilience * 0.15) * (1 + (1 - defender.health / 100));
      if (_random.nextDouble() < stopChance.clamp(0.02, 0.48)) {
        _setFinish(winner: attacker, method: FightMethod.koTko, detail: 'Punches');
        _log(FightEventType.finish,
            'The referee steps in! ${attacker.f.name} wins by TKO.',
            fighter: attacker);
        return;
      }
    }
    if (_finish == null) {
      _log(FightEventType.strike,
          '${defender.f.name} survives the storm and clears their head.',
          fighter: defender);
    }
  }

  void _checkDamageStoppage(_Corner attacker, _Corner defender) {
    if (defender.health > 0) return;
    _setFinish(winner: attacker, method: FightMethod.koTko, detail: 'Accumulated Damage');
    _log(FightEventType.finish,
        '${defender.f.name} cannot answer back — the fight is waved off.',
        fighter: attacker);
  }

  void _checkBodyStoppage(_Corner attacker, _Corner defender) {
    if (defender.bodyHealth > 6) return;
    final chance = 0.35 - defender.ms.heart / 100 * 0.2;
    if (_random.nextDouble() < chance.clamp(0.05, 0.4)) {
      _setFinish(winner: attacker, method: FightMethod.koTko, detail: 'Body Shot');
      _log(FightEventType.finish,
          '${defender.f.name} crumples from the body work! TKO.',
          fighter: attacker);
    }
  }

  void _checkLegStoppage(_Corner attacker, _Corner defender) {
    if (defender.legHealth > 5) return;
    final chance = 0.22 - defender.ms.heart / 100 * 0.14;
    if (_random.nextDouble() < chance.clamp(0.02, 0.25)) {
      _setFinish(winner: attacker, method: FightMethod.koTko, detail: 'Leg Kicks');
      _log(FightEventType.finish,
          '${defender.f.name} can no longer stand on that leg. TKO.',
          fighter: attacker);
    }
  }

  void _maybeCut(_Corner attacker, _Corner defender, double damage,
      {required _StrikeContext context}) {
    // Elbows on the ground and in the clinch are what really open people up.
    final base = context == _StrikeContext.standing ? 0.012 : 0.032;
    final chance = base * (damage / 2.0).clamp(0.3, 2.2);
    if (_random.nextDouble() < chance) {
      final fresh = defender.cutSeverity == 0;
      defender.cutSeverity += 18 + _random.nextDouble() * 22;
      if (fresh) {
        _log(FightEventType.bigStrike,
            '${defender.f.name} is cut and bleeding.',
            fighter: attacker);
      }
    } else if (defender.cutSeverity > 0) {
      defender.cutSeverity += damage * 0.9;
    }
  }

  // ---- Takedowns and the clinch -------------------------------------------

  int _takedownAttempt(_Corner attacker, _Corner defender, {required bool fromClinch}) {
    attacker.tdThrown++;
    attacker.spendStamina(fromClinch ? 4.0 : 5.5);

    final attack = attacker.blend([
          (attacker.fs.takedowns, 0.34),
          (attacker.fs.wrestling, 0.28),
          (attacker.ps.explosiveness, 0.16),
          (attacker.ps.strength, 0.12),
          (attacker.ps.athleticism, 0.10),
        ], fatigue: 1.4, legDependent: true) +
        (fromClinch ? 11 : 0) +
        (fromClinch ? attacker.rate(attacker.fs.clinchControl) * 0.15 : 0);

    final defend = defender.blend([
      (defender.fs.takedownDefense, 0.40),
      (defender.fs.wrestling, 0.22),
      (defender.ps.athleticism, 0.14),
      (defender.ps.strength, 0.12),
      (defender.fs.footwork, 0.12),
    ], fatigue: 1.2, legDependent: true);

    var chance = 0.34 + (attack - defend) / 150;
    if (defender.isHurt) chance += 0.25;
    chance = chance.clamp(0.04, 0.92);

    if (_random.nextDouble() < chance) {
      attacker.tdLanded++;
      attacker.tally.takedowns++;
      _credit(attacker, 12);

      // A dominant wrestler lands in a better spot than a scrappy one.
      final edge = attack - defend;
      _groundPosition = edge > 32 && _random.nextDouble() < 0.4
          ? GroundPosition.sideControl
          : (edge > 14 && _random.nextDouble() < 0.45
              ? GroundPosition.halfGuard
              : GroundPosition.guard);
      _position = FightPosition.ground;
      _controller = attacker;

      _log(FightEventType.takedown,
          '${attacker.f.name} takes ${defender.f.name} down, landing ${_groundPosition.label}.',
          fighter: attacker);
      return 5 + _random.nextInt(6);
    }

    // Stuffed. Good scramblers turn a failed shot into their own top position.
    _credit(defender, 7);
    final scrambleEdge = defender.blend([
          (defender.fs.scrambling, 0.5),
          (defender.fs.wrestling, 0.5),
        ]) -
        attacker.blend([(attacker.fs.scrambling, 0.6), (attacker.fs.grappling, 0.4)]);

    if (_random.nextDouble() < (0.10 + scrambleEdge / 400).clamp(0.02, 0.35)) {
      _position = FightPosition.ground;
      _groundPosition = GroundPosition.guard;
      _controller = defender;
      defender.reversals++;
      defender.tally.reversals++;
      _log(FightEventType.takedownStuffed,
          '${defender.f.name} stuffs the shot and comes up on top!',
          fighter: defender);
      return 8 + _random.nextInt(8);
    }

    if (_random.nextDouble() < 0.35) {
      _position = FightPosition.clinch;
      _controller = attacker;
      _log(FightEventType.takedownStuffed,
          '${defender.f.name} defends the takedown; they end up in the clinch.',
          fighter: defender);
    } else {
      _log(FightEventType.takedownStuffed,
          '${defender.f.name} stuffs the takedown.',
          fighter: defender);
    }
    return 6 + _random.nextInt(8);
  }

  int _clinchEntry(_Corner initiator, _Corner defender) {
    final entry = initiator.blend([
      (initiator.fs.clinchControl, 0.5),
      (initiator.fs.footwork, 0.25),
      (initiator.ps.explosiveness, 0.25),
    ]);
    final stop = defender.blend([
      (defender.fs.clinchDefense, 0.55),
      (defender.fs.footwork, 0.45),
    ]);
    if (_random.nextDouble() < (0.55 + (entry - stop) / 200).clamp(0.15, 0.9)) {
      _position = FightPosition.clinch;
      _controller = initiator;
      _log(FightEventType.clinch,
          '${initiator.f.name} closes the distance and ties ${defender.f.name} up.',
          fighter: initiator);
      return 4 + _random.nextInt(6);
    }
    _log(FightEventType.clinch,
        '${defender.f.name} circles away before the clinch is established.',
        fighter: defender);
    return 4 + _random.nextInt(6);
  }

  int _clinchExchange() {
    var controller = _controller ?? _a;
    var opponent = _other(controller);

    // Control is re-contested every exchange — grip, strength and pummelling.
    final control = controller.blend([
      (controller.fs.clinchControl, 0.40),
      (controller.ps.strength, 0.24),
      (controller.ps.gripStrength, 0.20),
      (controller.fs.wrestling, 0.16),
    ], fatigue: 1.3);
    final resist = opponent.blend([
      (opponent.fs.clinchDefense, 0.38),
      (opponent.ps.strength, 0.22),
      (opponent.fs.scrambling, 0.22),
      (opponent.fs.footwork, 0.18),
    ], fatigue: 1.2);

    if (_random.nextDouble() < (0.18 + (resist - control) / 190).clamp(0.03, 0.7)) {
      _position = FightPosition.standing;
      _controller = null;
      _credit(opponent, 4);
      _log(FightEventType.clinch,
          '${opponent.f.name} breaks the clinch and gets back to range.',
          fighter: opponent);
      return 5 + _random.nextInt(6);
    }

    // The controller decides what the clinch is *for*.
    final action = _weightedPick({
      _ClinchAction.strike: controller.t.strikingFrequency * 0.7 +
          controller.fs.clinchStriking * 0.5 +
          10,
      _ClinchAction.takedown: controller.t.takedownFrequency * 0.9 + 8,
      _ClinchAction.control: controller.t.wallWork * 1.1 + controller.t.positionControl * 0.4 + 6,
    });

    switch (action) {
      case _ClinchAction.strike:
        final volume = 2 + _random.nextInt(3);
        for (var i = 0; i < volume && _finish == null; i++) {
          _throwStrike(controller, opponent, context: _StrikeContext.clinch);
        }
        return 5 + _random.nextInt(7);

      case _ClinchAction.takedown:
        return _takedownAttempt(controller, opponent, fromClinch: true);

      case _ClinchAction.control:
        final seconds = 7 + _random.nextInt(10);
        controller.controlSeconds += seconds;
        controller.tally.controlValue += seconds * 0.55; // fence control is worth less
        opponent.spendStamina(seconds * 0.28);
        controller.spendStamina(seconds * 0.18);
        _credit(controller, seconds * 0.28);
        if (_random.nextDouble() < 0.3) {
          _log(FightEventType.clinch,
              '${controller.f.name} presses ${opponent.f.name} into the fence and works for position.',
              fighter: controller);
        }
        return seconds;
    }
  }

  // ---- Ground --------------------------------------------------------------

  int _groundExchange() {
    final top = _controller ?? _a;
    final bottom = _other(top);

    // Referee stand-up: nothing has happened down there for over a minute.
    if (_stalledGroundSeconds >= 70) {
      _position = FightPosition.standing;
      _controller = null;
      _groundPosition = GroundPosition.guard;
      _stalledGroundSeconds = 0;
      _log(FightEventType.standUp,
          'The referee stands them up for a lack of action.');
      return 6 + _random.nextInt(5);
    }

    // The bottom fighter gets first say — they're the one who wants out.
    final bottomActed = _bottomGroundAction(bottom, top);
    if (bottomActed != null) return bottomActed;
    if (_finish != null) return 5;

    return _topGroundAction(top, bottom);
  }

  /// This is where "grappling styles" actually diverge: the same top
  /// position produces a grinder riding position, a ground striker
  /// posturing up, or a submission hunter climbing for the finish,
  /// depending on their tendencies *and* what they're actually good at.
  int _topGroundAction(_Corner top, _Corner bottom) {
    final pos = _groundPosition;

    var controlWeight = top.t.positionControl * (0.45 + top.fs.topControl / 190);
    var gnpWeight = top.t.groundAndPound *
        (0.45 + top.fs.groundAndPound / 190) *
        (0.35 + pos.strikeMultiplier * 0.75);
    var subWeight = top.t.submissionAttempts *
        (0.07 + top.fs.submissionOffense / 900) *
        (0.20 + pos.submissionMultiplier * 0.28);

    // Already in the best seat in the house? Stop advancing, start finishing.
    if (pos == GroundPosition.backMount) {
      controlWeight *= 0.45;
      subWeight *= 1.8;
    }
    // A hurt opponent on the bottom gets finished, not ridden.
    if (bottom.isHurt || bottom.health < 35) {
      final instinct = 1 + top.ms.killerInstinct / 100;
      gnpWeight *= 1.5 * instinct;
      subWeight *= 1.3 * instinct;
      controlWeight *= 0.5;
    }
    // Gassed fighters grind.
    if (top.stamina < 30) {
      controlWeight *= 1.8;
      gnpWeight *= 0.7;
      subWeight *= 0.7;
    }

    final intent = _weightedPick({
      GroundIntent.control: controlWeight + 4,
      GroundIntent.groundAndPound: gnpWeight + 3,
      GroundIntent.submission: subWeight + 2,
    });

    return switch (intent) {
      GroundIntent.control => _advancePosition(top, bottom),
      GroundIntent.groundAndPound => _groundStrikes(top, bottom),
      GroundIntent.submission => _submissionAttempt(top, bottom, fromTop: true),
    };
  }

  int _advancePosition(_Corner top, _Corner bottom) {
    final seconds = 8 + _random.nextInt(11);
    _stalledGroundSeconds += seconds;
    top.controlSeconds += seconds;
    top.tally.controlValue += seconds * _groundPosition.controlValue;
    bottom.spendStamina(seconds * 0.25);
    top.spendStamina(seconds * 0.18);
    _credit(top, seconds * 0.35 * _groundPosition.controlValue);

    if (_groundPosition == GroundPosition.backMount) {
      // Nowhere better to go — just ride it.
      return seconds;
    }

    final pass = top.blend([
      (top.fs.topControl, 0.36),
      (top.fs.grappling, 0.24),
      (top.ps.gripStrength, 0.16),
      (top.ps.strength, 0.14),
      (top.fs.wrestling, 0.10),
    ], fatigue: 1.1);
    final retain = bottom.blend([
      (bottom.fs.guardRetention, 0.38),
      (bottom.fs.scrambling, 0.24),
      (bottom.ps.flexibility, 0.20),
      (bottom.ps.athleticism, 0.18),
    ], fatigue: 1.1);

    if (_random.nextDouble() < (0.30 + (pass - retain) / 175).clamp(0.05, 0.8)) {
      final next = GroundPosition.values[
          (_groundPosition.index + 1).clamp(0, GroundPosition.values.length - 1)];
      if (next != _groundPosition) {
        _groundPosition = next;
        _stalledGroundSeconds = 0;
        _credit(top, 8);
        _log(FightEventType.positionChange,
            '${top.f.name} advances to ${_groundPosition.label}.',
            fighter: top);
      }
    }
    return seconds;
  }

  int _groundStrikes(_Corner top, _Corner bottom) {
    final seconds = 6 + _random.nextInt(9);
    _stalledGroundSeconds = 0;
    top.controlSeconds += seconds;
    top.tally.controlValue += seconds * _groundPosition.controlValue;

    final volume = 1 + _random.nextInt(3 + (_groundPosition.strikeMultiplier * 2).round());
    for (var i = 0; i < volume && _finish == null; i++) {
      _throwStrike(top, bottom, context: _StrikeContext.ground);
    }
    if (_finish == null && _random.nextDouble() < 0.25) {
      _log(FightEventType.strike,
          '${top.f.name} postures up and works ground and pound ${_groundPosition.label}.',
          fighter: top);
    }
    return seconds;
  }

  int _submissionAttempt(_Corner attacker, _Corner defender, {required bool fromTop}) {
    attacker.subAttempts++;
    attacker.tally.submissionAttempts++;
    attacker.spendStamina(4.0);
    defender.spendStamina(3.0);

    final name = _submissionName(fromTop: fromTop);

    final offense = attacker.blend([
      (attacker.fs.submissionOffense, 0.42),
      (attacker.fs.grappling, 0.20),
      (attacker.ps.gripStrength, 0.20),
      (attacker.ps.strength, 0.10),
      (attacker.ps.flexibility, 0.08),
    ], fatigue: 1.1);
    final defense = defender.blend([
      (defender.fs.submissionDefense, 0.42),
      (defender.ps.flexibility, 0.20),
      (defender.fs.scrambling, 0.18),
      (defender.ms.composure, 0.12),
      (defender.ps.strength, 0.08),
    ], fatigue: 1.0);

    final positional = fromTop ? _groundPosition.submissionMultiplier : 0.85;
    var chance = (0.115 + (offense - defense) / 300) * positional;
    if (defender.isHurt) chance *= 1.6;
    if (defender.stamina < 25) chance *= 1.35;
    chance = chance.clamp(0.01, 0.72);

    _log(FightEventType.submissionAttempt,
        '${attacker.f.name} goes for a $name!',
        fighter: attacker);
    _credit(attacker, 10);

    if (_random.nextDouble() < chance) {
      attacker.tally.nearFinishes += 1;
      _setFinish(winner: attacker, method: FightMethod.submission, detail: name);
      _log(FightEventType.finish,
          '${defender.f.name} taps out! ${attacker.f.name} wins by $name.',
          fighter: attacker);
      return 12 + _random.nextInt(14);
    }

    // A deep-but-escaped attempt still swings a round on the cards.
    if (chance > 0.16) {
      attacker.tally.nearFinishes += 0.6;
      _log(FightEventType.submissionAttempt,
          '${defender.f.name} survives a deep $name.',
          fighter: defender);
    }

    // Gambling on a submission can cost you the position.
    final losePosition = fromTop ? 0.22 : 0.10;
    if (_random.nextDouble() < losePosition) {
      if (fromTop) {
        _groundPosition = GroundPosition.guard;
        _log(FightEventType.positionChange,
            '${defender.f.name} escapes back to guard as the ${name.toLowerCase()} slips.',
            fighter: defender);
      }
    }
    return 14 + _random.nextInt(16);
  }

  /// Returns the seconds consumed if the bottom fighter did something
  /// meaningful, or null to let the top fighter act.
  int? _bottomGroundAction(_Corner bottom, _Corner top) {
    // Initiative on the bottom comes from scrambling and explosiveness.
    final initiative = bottom.blend([
          (bottom.fs.scrambling, 0.45),
          (bottom.ps.explosiveness, 0.30),
          (bottom.fs.grappling, 0.25),
        ], fatigue: 1.3) -
        top.blend([
          (top.fs.topControl, 0.55),
          (top.ps.strength, 0.25),
          (top.fs.grappling, 0.20),
        ], fatigue: 1.1);

    final actChance = (0.34 + initiative / 230).clamp(0.06, 0.72);
    if (_random.nextDouble() >= actChance) return null;

    final canAttackSubs = _groundPosition == GroundPosition.guard ||
        _groundPosition == GroundPosition.halfGuard;

    final action = _weightedPick({
      _BottomAction.standUp: bottom.t.standUpPreference * (0.5 + bottom.fs.scrambling / 190) + 6,
      _BottomAction.sweep: (100 - bottom.t.standUpPreference) * 0.6 * (0.5 + bottom.fs.sweeps / 190) + 5,
      _BottomAction.submit: canAttackSubs
          ? bottom.t.submissionAttempts * (0.09 + bottom.fs.submissionOffense / 700)
          : 0.0,
    });

    switch (action) {
      case _BottomAction.standUp:
        return _standUpAttempt(bottom, top);
      case _BottomAction.sweep:
        return _sweepAttempt(bottom, top);
      case _BottomAction.submit:
        return _submissionAttempt(bottom, top, fromTop: false);
    }
  }

  int _standUpAttempt(_Corner bottom, _Corner top) {
    bottom.spendStamina(4.5);
    final escape = bottom.blend([
      (bottom.fs.scrambling, 0.38),
      (bottom.ps.explosiveness, 0.24),
      (bottom.ps.athleticism, 0.20),
      (bottom.ps.strength, 0.18),
    ], fatigue: 1.4);
    final hold = top.blend([
      (top.fs.topControl, 0.48),
      (top.ps.strength, 0.22),
      (top.fs.grappling, 0.18),
      (top.ps.gripStrength, 0.12),
    ], fatigue: 1.1);

    // Getting up from under mount is a different problem than from guard.
    final positionPenalty = _groundPosition.index * 0.055;
    final chance = (0.32 + (escape - hold) / 190 - positionPenalty).clamp(0.03, 0.8);

    if (_random.nextDouble() < chance) {
      _position = FightPosition.standing;
      _controller = null;
      _groundPosition = GroundPosition.guard;
      _stalledGroundSeconds = 0;
      _credit(bottom, 8);
      _log(FightEventType.standUp,
          '${bottom.f.name} works back to their feet.',
          fighter: bottom);
      return 8 + _random.nextInt(9);
    }
    _credit(top, 4);
    return 8 + _random.nextInt(10);
  }

  int _sweepAttempt(_Corner bottom, _Corner top) {
    bottom.spendStamina(4.0);
    final sweep = bottom.blend([
      (bottom.fs.sweeps, 0.38),
      (bottom.fs.scrambling, 0.22),
      (bottom.ps.strength, 0.22),
      (bottom.ps.athleticism, 0.18),
    ], fatigue: 1.3);
    final base = top.blend([
      (top.fs.topControl, 0.50),
      (top.ps.athleticism, 0.22),
      (top.ps.strength, 0.18),
      (top.fs.grappling, 0.10),
    ], fatigue: 1.1);

    final positionPenalty = _groundPosition.index * 0.05;
    final chance = (0.26 + (sweep - base) / 195 - positionPenalty).clamp(0.02, 0.72);

    if (_random.nextDouble() < chance) {
      _controller = bottom;
      _groundPosition = GroundPosition.guard;
      _stalledGroundSeconds = 0;
      bottom.reversals++;
      bottom.tally.reversals++;
      _credit(bottom, 14);
      _log(FightEventType.sweep,
          '${bottom.f.name} sweeps ${top.f.name} and takes top position!',
          fighter: bottom);
      return 7 + _random.nextInt(8);
    }
    _credit(top, 3);
    return 7 + _random.nextInt(9);
  }

  // ---- Bookkeeping ---------------------------------------------------------

  _Corner _other(_Corner c) => identical(c, _a) ? _b : _a;

  void _credit(_Corner c, double amount) {
    if (c.isA) {
      _creditA += amount;
    } else {
      _creditB += amount;
    }
  }

  void _decayHurt(double elapsed) {
    for (final c in [_a, _b]) {
      if (c.hurtSeconds > 0) {
        final clearRate = 1 + c.ps.recovery / 100;
        c.hurtSeconds = (c.hurtSeconds - elapsed * clearRate).clamp(0.0, 60.0);
      }
    }
  }

  /// Momentum eases toward whoever just won the exchange, so the live bar
  /// swings with the action instead of jumping around at random.
  void _emitTick() {
    final total = _creditA + _creditB;
    final instant = total <= 0 ? 0.5 : (_creditA / total);

    // Standing damage taken bleeds into momentum too — a fighter who's
    // badly hurt is losing even in a quiet moment.
    final healthTilt = ((_a.health - _b.health) / 400).clamp(-0.15, 0.15);

    _momentum = (_momentum * 0.62 + instant * 0.38 + healthTilt * 0.06).clamp(0.05, 0.95);
    _ticks.add(MomentumTick(
      round: _round,
      timeSeconds: _clock.clamp(0, roundLengthSeconds),
      fighterAShare: _momentum,
    ));
  }

  void _log(FightEventType type, String text, {_Corner? fighter}) {
    _events.add(FightEvent(
      round: _round,
      timeSeconds: _clock.clamp(0, roundLengthSeconds),
      type: type,
      text: text,
      fighterId: fighter?.f.id,
    ));
  }

  void _setFinish({
    required _Corner winner,
    required FightMethod method,
    required String detail,
  }) {
    _finish = _Finish(
      winnerId: winner.f.id,
      method: method,
      detail: detail,
      round: _round,
      timeSeconds: _clock.clamp(1, roundLengthSeconds),
    );
  }

  // ---- Result assembly -----------------------------------------------------

  FightResult _buildResult(Fighter fighterA, Fighter fighterB) {
    final finish = _finish;

    String winnerId;
    FightMethod method;
    String detail;
    int round;
    int timeSeconds;
    var decisionType = DecisionType.none;
    var scorecards = const <Scorecard>[];

    if (finish != null) {
      winnerId = finish.winnerId;
      method = finish.method;
      detail = finish.detail;
      round = finish.round;
      timeSeconds = finish.timeSeconds;
    } else {
      final panel = JudgePanel(random: _random);
      final cards = panel.score(_roundTallies);
      final verdict = readCards(cards, fighterA.id, fighterB.id);
      scorecards = cards;
      winnerId = verdict.winnerId;
      decisionType = verdict.type;
      method = winnerId.isEmpty ? FightMethod.drawOrNc : FightMethod.decision;
      detail = '';
      round = _scheduledRounds;
      timeSeconds = roundLengthSeconds;
    }

    final isDraw = method == FightMethod.drawOrNc;
    final aWon = !isDraw && winnerId == fighterA.id;
    final bWon = !isDraw && winnerId == fighterB.id;

    final winnerCorner = aWon ? _a : (bWon ? _b : null);
    final loserCorner = aWon ? _b : (bWon ? _a : null);

    return FightResult(
      winnerId: winnerId,
      method: method,
      round: round,
      timeSeconds: timeSeconds,
      decisionType: decisionType,
      methodDetail: detail,
      winnerPerformanceRating: _performanceRating(winnerCorner, won: true, finished: finish != null),
      loserPerformanceRating: _performanceRating(loserCorner, won: false, finished: finish != null),
      fighterAInjury: _rollInjury(_a, lostByKo: bWon && method == FightMethod.koTko),
      fighterBInjury: _rollInjury(_b, lostByKo: aWon && method == FightMethod.koTko),
      momentumTicks: _ticks.isEmpty
          ? const [MomentumTick(round: 1, fighterAShare: 0.5)]
          : List.unmodifiable(_ticks),
      events: List.unmodifiable(_events),
      statsA: _a.toStatline(),
      statsB: _b.toStatline(),
      scorecards: scorecards,
    );
  }

  int _performanceRating(_Corner? c, {required bool won, required bool finished}) {
    if (c == null) return 50; // draw
    final base = won ? 58.0 : 36.0;
    final score = base +
        c.damageDealt * 0.75 +
        c.sigLanded * 0.11 +
        c.knockdowns * 6 +
        c.subAttempts * 2.5 +
        c.tdLanded * 1.5 +
        (won && finished ? 9 : 0) -
        (won ? 0 : c.damageTaken * 0.30);
    return score.round().clamp(0, 100);
  }

  /// Injury risk now keys off what actually happened in there — a fighter
  /// who absorbed 80 points of damage is far more likely to leave hurt
  /// than one who won a clean decision.
  InjuryStatus _rollInjury(_Corner c, {required bool lostByKo}) {
    var minorChance = 0.05 + ((100 - c.health) / 100) * 0.22;
    var majorChance = 0.005 + ((100 - c.health) / 100) * 0.055;

    if (lostByKo) {
      minorChance += 0.14;
      majorChance += 0.05;
    }
    if (c.legHealth < 35) minorChance += 0.10;
    if (c.bodyHealth < 30) minorChance += 0.05;
    if (c.cutSeverity > 40) minorChance += 0.08;

    final durabilityFactor = ((125 - c.ps.durability) / 100).clamp(0.5, 1.5);
    minorChance *= durabilityFactor;
    majorChance *= durabilityFactor;

    final roll = _random.nextDouble();
    if (roll < majorChance) return InjuryStatus.major;
    if (roll < majorChance + minorChance) return InjuryStatus.minor;
    return InjuryStatus.healthy;
  }

  // ---- Small helpers -------------------------------------------------------

  T _weightedPick<T>(Map<T, double> weights) {
    var total = 0.0;
    for (final w in weights.values) {
      if (w > 0) total += w;
    }
    if (total <= 0) return weights.keys.first;
    var roll = _random.nextDouble() * total;
    for (final entry in weights.entries) {
      if (entry.value <= 0) continue;
      roll -= entry.value;
      if (roll <= 0) return entry.key;
    }
    return weights.keys.last;
  }

  String _strikeName(
    bool isKick,
    StrikeTarget target,
    _StrikeContext context, {
    bool capitalised = false,
  }) {
    final options = switch (context) {
      _StrikeContext.ground => const ['ground strike', 'elbow', 'hammerfist', 'right hand'],
      _StrikeContext.clinch => switch (target) {
          StrikeTarget.body => const ['knee to the body', 'short hook to the ribs'],
          _ => const ['knee', 'elbow', 'short uppercut'],
        },
      _StrikeContext.standing => isKick
          ? switch (target) {
              StrikeTarget.head => const ['head kick', 'high kick'],
              StrikeTarget.body => const ['body kick', 'kick to the ribs'],
              StrikeTarget.leg => const ['leg kick', 'calf kick', 'low kick'],
            }
          : switch (target) {
              StrikeTarget.head => const [
                  'right hand',
                  'left hook',
                  'jab',
                  'uppercut',
                  'overhand right',
                  'straight left',
                ],
              StrikeTarget.body => const ['body shot', 'hook to the body'],
              StrikeTarget.leg => const ['low kick'],
            },
    };
    final name = options[_random.nextInt(options.length)];
    if (!capitalised) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Which hold this attempt is. Positions still gate what's possible,
  /// but within a position the pick is weighted by how often each
  /// submission actually finishes fights — see [SubmissionCatalog].
  String _submissionName({required bool fromTop}) {
    return SubmissionCatalog.roll(
      _random,
      position: _groundPosition,
      fromTop: fromTop,
    ).name;
  }
}

enum _StandingAction { strike, takedown, clinch, reset }

enum _ClinchAction { strike, takedown, control }

enum _BottomAction { standUp, sweep, submit }

enum _StrikeContext { standing, clinch, ground }
