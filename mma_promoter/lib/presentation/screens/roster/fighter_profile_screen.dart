import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
import 'fighter_editor_screen.dart';

class FighterProfileScreen extends StatelessWidget {
  final String fighterId;

  const FighterProfileScreen({super.key, required this.fighterId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final fighter = controller.fighterById(fighterId);

    if (fighter == null) {
      return const Scaffold(body: Center(child: Text('Fighter not found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(fighter.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit fighter',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FighterEditorScreen(existingFighter: fighter),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (fighter.retired)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.event_busy,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Retired${fighter.retirementReason != null ? ' — ${fighter.retirementReason}' : ''}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (fighter.retired) const SizedBox(height: 12),
          Text(
            '${fighter.weightClass.label} · ${fighter.nationality} · Age ${fighter.age}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${fighter.heightDisplay} · ${fighter.weightLbs} lbs · ${fighter.reachDisplay} reach',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Record: ${fighter.record.display}   Streak: '
            '${fighter.winStreak > 0 ? 'W${fighter.winStreak}' : fighter.lossStreak > 0 ? 'L${fighter.lossStreak}' : '-'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Style: ${fighter.style.label}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Elo: ${fighter.eloRating}${fighter.isRanked ? ' (Ranked)' : ' (Unranked)'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (fighter.fightOfTheNightCount > 0 || fighter.performanceOfTheNightCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (fighter.fightOfTheNightCount > 0)
                  'FOTN x${fighter.fightOfTheNightCount}',
                if (fighter.performanceOfTheNightCount > 0)
                  'POTN x${fighter.performanceOfTheNightCount}',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          Text('Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _StatBar(label: 'Overall', value: fighter.overall.round()),
          _StatBar(label: 'Potential', value: fighter.potential),
          _StatBar(label: 'Striking', value: fighter.fightingStats.strikingAverage.round()),
          _StatBar(label: 'Grappling', value: fighter.fightingStats.grapplingAverage.round()),
          _StatBar(label: 'Physical', value: fighter.physicalStats.average.round()),
          _StatBar(label: 'Mental', value: fighter.mentalStats.average.round()),
          const SizedBox(height: 16),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Striking'),
            children: [
              _StatBar(label: 'Punching', value: fighter.fightingStats.punching),
              _StatBar(label: 'Kicking', value: fighter.fightingStats.kicking),
              _StatBar(label: 'Power', value: fighter.fightingStats.power),
              _StatBar(label: 'Speed', value: fighter.fightingStats.speed),
              _StatBar(label: 'Accuracy', value: fighter.fightingStats.accuracy),
              _StatBar(label: 'Defense', value: fighter.fightingStats.defense),
              _StatBar(label: 'Head Movement', value: fighter.fightingStats.headMovement),
              _StatBar(label: 'Blocking', value: fighter.fightingStats.blocking),
              _StatBar(label: 'Footwork', value: fighter.fightingStats.footwork),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Wrestling & Clinch'),
            children: [
              _StatBar(label: 'Takedowns', value: fighter.fightingStats.takedowns),
              _StatBar(label: 'TD Defense', value: fighter.fightingStats.takedownDefense),
              _StatBar(label: 'Wrestling', value: fighter.fightingStats.wrestling),
              _StatBar(label: 'Clinch Striking', value: fighter.fightingStats.clinchStriking),
              _StatBar(label: 'Clinch Control', value: fighter.fightingStats.clinchControl),
              _StatBar(label: 'Clinch Defense', value: fighter.fightingStats.clinchDefense),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Ground Game'),
            children: [
              _StatBar(label: 'Top Control', value: fighter.fightingStats.topControl),
              _StatBar(label: 'Ground & Pound', value: fighter.fightingStats.groundAndPound),
              _StatBar(label: 'Guard Retention', value: fighter.fightingStats.guardRetention),
              _StatBar(label: 'Sweeps', value: fighter.fightingStats.sweeps),
              _StatBar(label: 'Scrambling', value: fighter.fightingStats.scrambling),
              _StatBar(label: 'Sub. Offense', value: fighter.fightingStats.submissionOffense),
              _StatBar(label: 'Sub. Defense', value: fighter.fightingStats.submissionDefense),
              _StatBar(label: 'Grappling', value: fighter.fightingStats.grappling),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Physical Stats'),
            children: [
              _StatBar(label: 'Cardio', value: fighter.physicalStats.cardio),
              _StatBar(label: 'Durability', value: fighter.physicalStats.durability),
              _StatBar(label: 'Chin', value: fighter.physicalStats.chin),
              _StatBar(label: 'Body Toughness', value: fighter.physicalStats.bodyToughness),
              _StatBar(label: 'Leg Toughness', value: fighter.physicalStats.legToughness),
              _StatBar(label: 'Strength', value: fighter.physicalStats.strength),
              _StatBar(label: 'Athleticism', value: fighter.physicalStats.athleticism),
              _StatBar(label: 'Recovery', value: fighter.physicalStats.recovery),
              _StatBar(label: 'Explosiveness', value: fighter.physicalStats.explosiveness),
              _StatBar(label: 'Flexibility', value: fighter.physicalStats.flexibility),
              _StatBar(label: 'Grip Strength', value: fighter.physicalStats.gripStrength),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Mental Stats'),
            children: [
              _StatBar(label: 'Fight IQ', value: fighter.mentalStats.fightIq),
              _StatBar(label: 'Composure', value: fighter.mentalStats.composure),
              _StatBar(label: 'Aggression', value: fighter.mentalStats.aggression),
              _StatBar(label: 'Discipline', value: fighter.mentalStats.discipline),
              _StatBar(label: 'Confidence', value: fighter.mentalStats.confidence),
              _StatBar(label: 'Heart', value: fighter.mentalStats.heart),
              _StatBar(label: 'Adaptability', value: fighter.mentalStats.adaptability),
              _StatBar(label: 'Killer Instinct', value: fighter.mentalStats.killerInstinct),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Tendencies'),
            children: [
              _StatBar(label: 'Striking Freq.', value: fighter.tendencies.strikingFrequency, max: 100),
              _StatBar(label: 'Takedown Freq.', value: fighter.tendencies.takedownFrequency, max: 100),
              _StatBar(label: 'Kick Freq.', value: fighter.tendencies.kickFrequency, max: 100),
              _StatBar(label: 'Clinch Freq.', value: fighter.tendencies.clinchFrequency, max: 100),
              _StatBar(label: 'Sub. Attempts', value: fighter.tendencies.submissionAttempts, max: 100),
              _StatBar(label: 'Ground & Pound', value: fighter.tendencies.groundAndPound, max: 100),
              _StatBar(label: 'Position Control', value: fighter.tendencies.positionControl, max: 100),
              _StatBar(label: 'Stand-Up Preference', value: fighter.tendencies.standUpPreference, max: 100),
              _StatBar(label: 'Wall Work', value: fighter.tendencies.wallWork, max: 100),
              _StatBar(label: 'Aggression', value: fighter.tendencies.aggression, max: 100),
              _StatBar(label: 'Counter Striking', value: fighter.tendencies.counterStriking, max: 100),
              _StatBar(label: 'Head Hunting', value: fighter.tendencies.headHunting, max: 100),
              _StatBar(label: 'Body Attacks', value: fighter.tendencies.bodyAttacks, max: 100),
              _StatBar(label: 'Leg Attacks', value: fighter.tendencies.legAttacks, max: 100),
            ],
          ),
          const SizedBox(height: 8),
          Text('Condition', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _StatBar(label: 'Morale', value: fighter.morale),
          _StatBar(label: 'Popularity', value: fighter.popularity),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              fighter.injuryStatus == InjuryStatus.healthy
                  ? Icons.favorite
                  : Icons.local_hospital,
              color: fighter.injuryStatus == InjuryStatus.healthy
                  ? Colors.green
                  : Colors.orange,
            ),
            title: Text(fighter.injuryStatus.label),
          ),
          const SizedBox(height: 24),
          if (fighter.retired)
            const SizedBox.shrink()
          else if (fighter.isSigned)
            _ContractSection(fighter: fighter)
          else
            FilledButton.icon(
              icon: const Icon(Icons.handshake),
              label: const Text('Sign Fighter'),
              onPressed: () => _showSignDialog(context, fighter),
            ),
          const SizedBox(height: 24),
          _FightHistorySection(fighter: fighter),
        ],
      ),
    );
  }

  void _showSignDialog(BuildContext context, Fighter fighter) {
    final controller = context.read<GameController>();
    final suggestedPay = 1000 + fighter.popularity * 40;
    final payController = TextEditingController(text: '$suggestedPay');
    var fightsInDeal = 4;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('Sign ${fighter.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: payController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pay per fight (also charged now as signing bonus)',
                ),
              ),
              const SizedBox(height: 12),
              Text('Fights in deal: $fightsInDeal'),
              Slider(
                value: fightsInDeal.toDouble(),
                min: 1,
                max: 8,
                divisions: 7,
                label: '$fightsInDeal',
                onChanged: (v) => setState(() => fightsInDeal = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final pay = int.tryParse(payController.text) ?? suggestedPay;
                final error = await controller.signFighter(
                  fighter,
                  payPerFight: pay,
                  fightsInDeal: fightsInDeal,
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: const Text('Sign'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractSection extends StatelessWidget {
  final Fighter fighter;

  const _ContractSection({required this.fighter});

  @override
  Widget build(BuildContext context) {
    final contract = fighter.contract!;
    final currency = NumberFormat.simpleCurrency();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contract', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Pay per fight: ${currency.format(contract.payPerFight)}'),
        Text('Fights remaining: ${contract.fightsRemaining}'),
        Text('Exclusive: ${contract.exclusive ? 'Yes' : 'No'}'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.person_remove),
          label: const Text('Release Fighter'),
          onPressed: () => _confirmRelease(context),
        ),
      ],
    );
  }

  void _confirmRelease(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Release ${fighter.name}?'),
        content: const Text(
          'They will return to the free-agent pool and can be re-signed by '
          'you or a rival promotion later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GameController>().releaseFighter(fighter.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Release'),
          ),
        ],
      ),
    );
  }
}

class _FightHistorySection extends StatelessWidget {
  final Fighter fighter;

  const _FightHistorySection({required this.fighter});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fight History', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder<List<({Fight fight, MmaEvent? event})>>(
          future: controller.getFightHistory(fighter.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              );
            }
            final history = snapshot.data!;
            if (history.isEmpty) {
              return const Text('No fights yet.');
            }
            return Column(
              children: [
                for (final entry in history)
                  _FightHistoryTile(
                    fight: entry.fight,
                    event: entry.event,
                    fighterId: fighter.id,
                    opponentName: _opponentName(controller, entry.fight, fighter.id),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _opponentName(GameController controller, Fight fight, String fighterId) {
    final opponentId =
        fight.fighterAId == fighterId ? fight.fighterBId : fight.fighterAId;
    return controller.fighterById(opponentId)?.name ?? 'Unknown Opponent';
  }
}

class _FightHistoryTile extends StatelessWidget {
  final Fight fight;
  final MmaEvent? event;
  final String fighterId;
  final String opponentName;

  const _FightHistoryTile({
    required this.fight,
    required this.event,
    required this.fighterId,
    required this.opponentName,
  });

  @override
  Widget build(BuildContext context) {
    final result = fight.result!;
    final outcome = result.isDraw
        ? 'Draw'
        : (result.winnerId == fighterId ? 'Win' : 'Loss');
    final outcomeColor = switch (outcome) {
      'Win' => Colors.green,
      'Loss' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: outcomeColor,
          child: Text(
            outcome[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('vs $opponentName'),
        subtitle: Text(
          '${result.isDraw ? 'Draw' : '${result.method.label}, Round ${result.round}'}'
          '${event != null ? ' · ${DateFormat.yMMMd().format(event!.date)}' : ''}',
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const _StatBar({required this.label, required this.value, this.max = 100});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / max,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
