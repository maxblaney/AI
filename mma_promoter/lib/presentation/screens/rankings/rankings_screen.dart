import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
import '../../widgets/fighter_avatar.dart';
import '../roster/fighter_profile_screen.dart';

/// Elo-based rankings — one ladder per weight class, plus a
/// Pound-for-Pound ladder that ranks every signed fighter against each
/// other regardless of division. A fighter shows up here as soon as
/// they've had a single fight — no minimum fight count required.
class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  /// Null means Pound-for-Pound — every division ranked together on one
  /// Elo ladder — otherwise the selected division only.
  WeightClass? _weightClass;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final isP4P = _weightClass == null;
    final ranked = controller.rankedFighters
        .where((f) => isP4P || f.weightClass == _weightClass)
        .toList()
      ..sort((a, b) => b.eloRating.compareTo(a.eloRating));

    // In a division the champion sits above the contenders regardless of
    // Elo — that's what holding the belt means. Pound-for-pound spans
    // every division and so has many champions in it; there it stays a
    // straight Elo list, with the belt shown as a badge instead.
    if (!isP4P) {
      ranked.sort((a, b) {
        int rank(Fighter f) =>
            f.isChampion ? 0 : (f.isInterimChampion ? 1 : 2);
        final byBelt = rank(a).compareTo(rank(b));
        return byBelt != 0 ? byBelt : b.eloRating.compareTo(a.eloRating);
      });
    }

    // Contenders number from 1; belt holders are labelled instead.
    final labels = <String>[];
    var contender = 0;
    for (final f in ranked) {
      if (!isP4P && f.isChampion) {
        labels.add('C');
      } else if (!isP4P && f.isInterimChampion) {
        labels.add('iC');
      } else {
        contender++;
        labels.add('$contender.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rankings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Pound-for-Pound'),
                    selected: isP4P,
                    onSelected: (_) => setState(() => _weightClass = null),
                  ),
                  for (final w in WeightClass.values)
                    ChoiceChip(
                      label: Text(w.label),
                      selected: _weightClass == w,
                      onSelected: (_) => setState(() => _weightClass = w),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ranked.isEmpty
                ? Center(
                    child: Text(
                      isP4P
                          ? 'No ranked fighters yet.'
                          : 'No ranked fighters yet in this division.',
                    ),
                  )
                : ListView.builder(
                    itemCount: ranked.length,
                    itemBuilder: (context, index) {
                      final fighter = ranked[index];
                      final label = labels[index];
                      final isBelt = label == 'C' || label == 'iC';
                      return ListTile(
                        leading: FighterAvatar(fighter: fighter),
                        title: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontWeight:
                                      isBelt ? FontWeight.bold : FontWeight.normal,
                                  color: isBelt
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(child: Text(fighter.name)),
                            if (isP4P && fighter.isChampion)
                              Icon(
                                Icons.emoji_events,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          isP4P
                              ? '${fighter.weightClass.label} · ${fighter.record.display} · ${fighter.style.label}'
                              : '${fighter.record.display} · ${fighter.style.label}',
                        ),
                        trailing: Text(
                          '${fighter.eloRating}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FighterProfileScreen(fighterId: fighter.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
