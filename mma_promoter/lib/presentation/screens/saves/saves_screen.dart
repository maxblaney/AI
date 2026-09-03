import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repository_contracts.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';
import '../new_game/new_game_screen.dart';
import '../packs/fighter_packs_screen.dart';

/// The saves picker. Doubles as the app's start screen when nothing is
/// loaded, and is reachable from the dashboard mid-game so a player can
/// hop between promotions without losing either.
class SavesScreen extends StatefulWidget {
  /// True when this is the start screen (no save open). It then has no
  /// back button, because there's nothing to go back to.
  final bool isStartScreen;

  const SavesScreen({super.key, this.isStartScreen = false});

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  late Future<List<SaveSummary>> _saves;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _saves = context.read<GameController>().listSaves();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final activeId = controller.activeSaveId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStartScreen ? 'Saves' : 'Saves & Settings'),
        automaticallyImplyLeading: !widget.isStartScreen,
      ),
      body: FutureBuilder<List<SaveSummary>>(
        future: _saves,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final saves = snapshot.data ?? const <SaveSummary>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (saves.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        'No promotions yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start one below — you can keep several going at '
                        'once and switch between them any time.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              for (final save in saves)
                _SaveCard(
                  save: save,
                  isActive: save.organization.id == activeId,
                  onLoad: () => _load(save),
                  onDelete: () => _confirmDelete(save),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Promotion'),
                onPressed: _startNew,
              ),
              // Settings belong to a save rather than to the app, so
              // they're only here once one is open — and they're below
              // the saves list because switching promotions is what
              // people come to this screen for.
              if (controller.organization != null) ...[
                const SizedBox(height: 32),
                Text('Settings',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups_2_outlined),
                    title: const Text('Fighter Packs'),
                    subtitle: const Text(
                      'Build your own group of fighters, import it into '
                      'any save, and share it with someone else.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FighterPacksScreen(),
                      ),
                    ),
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    value: controller.organization!.autoResignFighters,
                    onChanged: (v) =>
                        controller.setAutoResignFighters(v),
                    title: const Text('Auto re-sign fighters'),
                    subtitle: const Text(
                      'When a fighter finishes the last fight on their '
                      'deal, put them straight onto a new four-fight '
                      'contract at what they are now worth. The signing '
                      'bonus still comes out of the bank, and the mailbox '
                      'tells you what it cost. Turn it off to work your '
                      'own contracts — anyone you let fight out their '
                      'deal leaves as a free agent, and the mailbox warns '
                      'you a fight ahead.',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _load(SaveSummary save) async {
    final controller = context.read<GameController>();
    if (save.organization.id == controller.activeSaveId) {
      if (!widget.isStartScreen) Navigator.of(context).pop();
      return;
    }
    await controller.loadSave(save.organization.id);
    if (!mounted) return;
    // On the start screen the shell swaps itself out once a save is
    // active; from the dashboard we opened this as a route, so pop back.
    if (!widget.isStartScreen) Navigator.of(context).pop();
  }

  Future<void> _startNew() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewGameScreen()),
    );
    if (!mounted) return;
    // Coming back without having started one — refresh in case something
    // changed, and drop the route if a save is now open.
    final controller = context.read<GameController>();
    if (!widget.isStartScreen && controller.activeSaveId != null) {
      Navigator.of(context).pop();
      return;
    }
    setState(_reload);
  }

  Future<void> _confirmDelete(SaveSummary save) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${save.organization.name}?'),
        content: const Text(
          'This permanently deletes the promotion, its roster and its whole '
          'event history. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<GameController>().deleteSave(save.organization.id);
    if (!mounted) return;
    setState(_reload);
  }
}

class _SaveCard extends StatelessWidget {
  final SaveSummary save;
  final bool isActive;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  const _SaveCard({
    required this.save,
    required this.isActive,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final org = save.organization;
    final currency = NumberFormat.simpleCurrency(decimalDigits: 0);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onLoad,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      org.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        'PLAYING',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete save',
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${GameCalendar.label(org.currentWeek)} · '
                '${org.reputationTier.label}',
              ),
              const SizedBox(height: 2),
              Text(
                '${currency.format(org.cashBalance)} · '
                '${save.rosterSize} signed · '
                '${save.talentPoolSize} fighters',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (save.lastPlayedAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Last played ${_ago(save.lastPlayedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _ago(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return DateFormat.yMMMd().format(at);
  }
}
