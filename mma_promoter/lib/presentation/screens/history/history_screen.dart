import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/history/record_book.dart';
import '../../state/game_controller.dart';
import '../roster/fighter_profile_screen.dart';

/// The promotion's record book. Every figure here comes from fights that
/// happened on this org's cards — a fighter who arrived 10-2 and went 6-0
/// for you counts as 6 fights, not 18.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<RecordCategory>>? _records;
  int _knownFightCount = -1;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    // The book is rebuilt from the database, so it has to be refetched
    // when new results land. Keying off the completed-event count means a
    // simulated card refreshes it without re-querying on every rebuild.
    final completed = controller.completedEvents.length;
    if (completed != _knownFightCount) {
      _knownFightCount = completed;
      _records = controller.getRecordBook();
    }

    final retired = [...controller.retiredFighters]
      ..sort((a, b) => b.record.wins.compareTo(a.record.wins));

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Record Book', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'All-time bests inside the promotion. Only fights on your cards '
            'count toward these.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<RecordCategory>>(
            future: _records,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final categories = snapshot.data ?? const <RecordCategory>[];
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No fights have happened yet. Run an event and the record '
                    'book fills in.',
                  ),
                );
              }
              return Column(
                children: [
                  for (final category in categories) _RecordCard(category: category),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Retired Fighters',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (retired.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nobody has retired yet.'),
            )
          else
            for (final fighter in retired)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: Text(fighter.name),
                  subtitle: Text(
                    '${fighter.weightClass.label} · ${fighter.record.display} · '
                    '${fighter.retirementReason ?? 'Retired'}',
                  ),
                  trailing: Text('Age ${fighter.age}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FighterProfileScreen(fighterId: fighter.id),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final RecordCategory category;

  const _RecordCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (category.qualifier != null)
                  Text(
                    category.qualifier!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < category.entries.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: InkWell(
                  // Event-level records name a show, not a person, so
                  // there's nothing to open.
                  onTap: category.entries[i].fighterId == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FighterProfileScreen(
                                fighterId: category.entries[i].fighterId!,
                              ),
                            ),
                          ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${i + 1}.',
                          style: TextStyle(
                            color: i == 0 ? scheme.primary : null,
                            fontWeight: i == 0 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      Expanded(child: Text(category.entries[i].fighterName)),
                      Text(
                        category.entries[i].value,
                        style: TextStyle(
                          fontWeight: i == 0 ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
