import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';

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
      appBar: AppBar(title: Text(fighter.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${fighter.weightClass.label} · ${fighter.nationality} · Age ${fighter.age}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Record: ${fighter.record.display}   Win streak: ${fighter.winStreak}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Style: ${fighter.styleTags.map((t) => t.label).join(', ')}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Stats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _StatBar(label: 'Striking', value: fighter.stats.striking),
          _StatBar(label: 'Grappling', value: fighter.stats.grappling),
          _StatBar(label: 'Cardio', value: fighter.stats.cardio),
          _StatBar(label: 'Chin', value: fighter.stats.chin),
          _StatBar(label: 'Power', value: fighter.stats.power),
          const SizedBox(height: 24),
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
          if (fighter.isSigned)
            _ContractSection(fighter: fighter)
          else
            FilledButton.icon(
              icon: const Icon(Icons.handshake),
              label: const Text('Sign Fighter'),
              onPressed: () => _showSignDialog(context, fighter),
            ),
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

class _StatBar extends StatelessWidget {
  final String label;
  final int value;

  const _StatBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
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
