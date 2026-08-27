import 'dart:math';

import '../../core/utils/id_generator.dart';
import '../../data/models/models.dart';

/// The effect of resolving a [RandomEvent] choice, applied by the caller to
/// its stored [Fighter]/[Organization] state.
class RandomEventOutcome {
  final Fighter updatedFighter;
  final int cashDelta;

  const RandomEventOutcome({
    required this.updatedFighter,
    this.cashDelta = 0,
  });
}

const _injuryChoiceRush = 'rush_recovery';
const _injuryChoiceRest = 'let_them_rest';
const _disputeChoiceRaise = 'grant_raise';
const _disputeChoiceDeny = 'hold_firm';

/// Generates and resolves the v1 random events: fighter injuries and
/// contract-pay disputes. Both interrupt the player's plans with a
/// short-term cost/benefit trade-off, per the "random events" pillar.
class RandomEventEngine {
  final Random _random;

  RandomEventEngine({Random? random}) : _random = random ?? Random();

  /// Call this periodically (e.g. once per in-game week or before booking
  /// an event) with the current signed roster. Returns null most of the
  /// time — events shouldn't fire every tick.
  RandomEvent? maybeGenerate(List<Fighter> signedRoster, DateTime now) {
    final eligible = signedRoster.where((f) => f.isSigned).toList();
    if (eligible.isEmpty) return null;

    // ~12% chance per tick that *something* happens to the roster.
    if (_random.nextDouble() > 0.12) return null;

    final fighter = eligible[_random.nextInt(eligible.length)];
    final isInjury = _random.nextBool();
    return isInjury
        ? _generateInjury(fighter, now)
        : _generateContractDispute(fighter, now);
  }

  RandomEvent _generateInjury(Fighter fighter, DateTime now) {
    return RandomEvent(
      id: newId(),
      type: RandomEventType.injury,
      affectedFighterId: fighter.id,
      headline: '${fighter.name} injured in training',
      description:
          '${fighter.name} picked up an injury during camp. Rushing '
          'recovery costs cash but gets them fight-ready sooner; resting '
          'is free but keeps them out longer and tests their patience.',
      occurredOn: now,
      choices: const [
        RandomEventChoice(
          id: _injuryChoiceRush,
          label: 'Pay for expedited treatment (\$5,000)',
          consequenceSummary: 'Injury severity improves immediately; morale dips.',
        ),
        RandomEventChoice(
          id: _injuryChoiceRest,
          label: 'Let them rest naturally',
          consequenceSummary: 'No cost, morale rises, but they stay injured longer.',
        ),
      ],
    );
  }

  RandomEvent _generateContractDispute(Fighter fighter, DateTime now) {
    return RandomEvent(
      id: newId(),
      type: RandomEventType.contractDispute,
      affectedFighterId: fighter.id,
      headline: '${fighter.name} demands a new deal',
      description:
          '${fighter.name} feels underpaid given their recent run and is '
          'threatening to sit out their next fight unless pay improves.',
      occurredOn: now,
      choices: const [
        RandomEventChoice(
          id: _disputeChoiceRaise,
          label: 'Grant a 25% pay raise',
          consequenceSummary: 'Per-fight pay rises; morale improves.',
        ),
        RandomEventChoice(
          id: _disputeChoiceDeny,
          label: 'Hold firm and deny the raise',
          consequenceSummary: 'No cost now, but morale takes a real hit.',
        ),
      ],
    );
  }

  /// Applies the consequence of [choiceId] to [fighter]. The caller is
  /// responsible for persisting the returned fighter and adjusting the
  /// organization's cash balance by [RandomEventOutcome.cashDelta].
  RandomEventOutcome resolveChoice(
    RandomEvent event,
    String choiceId,
    Fighter fighter,
  ) {
    switch (event.type) {
      case RandomEventType.injury:
        return _resolveInjury(choiceId, fighter);
      case RandomEventType.contractDispute:
        return _resolveDispute(choiceId, fighter);
      default:
        return RandomEventOutcome(updatedFighter: fighter);
    }
  }

  RandomEventOutcome _resolveInjury(String choiceId, Fighter fighter) {
    if (choiceId == _injuryChoiceRush) {
      final improved = fighter.injuryStatus == InjuryStatus.major
          ? InjuryStatus.minor
          : InjuryStatus.healthy;
      return RandomEventOutcome(
        updatedFighter: fighter.copyWith(
          injuryStatus: improved,
          morale: (fighter.morale - 5).clamp(0, 100),
        ),
        cashDelta: -5000,
      );
    }
    // Rest naturally: status unchanged here (heals over subsequent weeks
    // outside this engine's scope), morale rises for the support shown.
    return RandomEventOutcome(
      updatedFighter: fighter.copyWith(
        morale: (fighter.morale + 10).clamp(0, 100),
      ),
    );
  }

  RandomEventOutcome _resolveDispute(String choiceId, Fighter fighter) {
    if (choiceId == _disputeChoiceRaise) {
      final updatedContract = fighter.contract?.copyWith(
        payPerFight: (fighter.contract!.payPerFight * 1.25).round(),
      );
      return RandomEventOutcome(
        updatedFighter: fighter.copyWith(
          contract: updatedContract,
          morale: (fighter.morale + 15).clamp(0, 100),
        ),
      );
    }
    return RandomEventOutcome(
      updatedFighter: fighter.copyWith(
        morale: (fighter.morale - 20).clamp(0, 100),
      ),
    );
  }
}
