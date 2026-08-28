import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
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
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(fighter.name),
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
