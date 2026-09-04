import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';

/// Shown once, before the first save exists: name your promotion and pick
/// a starting tier, which sets your opening cash and fanbase.
class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  late final TextEditingController _nameController;
  ReputationTier _tier = ReputationTier.regional;

  /// True to open with a roster already under contract, false to start
  /// with nobody signed. Defaults to the roster, which is the gentler
  /// opening — from scratch you have to sign a division before you can
  /// make a single fight.
  bool _signRoster = true;

  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Apex Fighting Championship');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('New Promotion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Start your MMA promotion',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Name it, pick where you're starting from, and you're in.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Promotion Name'),
          ),
          const SizedBox(height: 24),
          Text('Starting Tier', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final tier in ReputationTier.values)
            Card(
              color: tier == _tier
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: RadioListTile<ReputationTier>(
                value: tier,
                groupValue: _tier,
                onChanged: (v) => setState(() => _tier = v ?? _tier),
                title: Text(tier.label),
                subtitle: Text(
                  'Cash: ${currency.format(tier.startingCash)} · '
                  'Fanbase: ${NumberFormat.decimalPattern().format(tier.startingFanbase)}',
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('Starting Roster',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final signed in [true, false])
            Card(
              color: signed == _signRoster
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: RadioListTile<bool>(
                value: signed,
                groupValue: _signRoster,
                onChanged: (v) => setState(() => _signRoster = v ?? _signRoster),
                title: Text(signed
                    ? 'Established promotion'
                    : 'Start from scratch'),
                isThreeLine: true,
                subtitle: Text(
                  signed
                      ? '160 fighters already under contract, twenty to a '
                          'division. Open the booking screen and make a '
                          'card on day one.'
                      : 'Nobody signed. The whole talent pool is free '
                          'agents — sign a division before you can book a '
                          'fight, and the roster is entirely yours.',
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _starting ? null : _start,
            child: _starting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Start Promotion'),
          ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    final name = _nameController.text.trim().isEmpty
        ? 'Apex Fighting Championship'
        : _nameController.text.trim();
    await context.read<GameController>().startNewGame(
          orgName: name,
          tier: _tier,
          signRoster: _signRoster,
        );
    if (!mounted) return;
    // Reached as a route from the saves screen, so it has to dismiss
    // itself — the shell swapping to the dashboard underneath would
    // otherwise leave this sitting on top of it.
    Navigator.of(context).pop();
  }
}
