import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
import '../roster/fighter_profile_screen.dart';

/// Hall-of-fame style leaderboards plus the list of retired fighters —
/// the record book for the promotion's whole history.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final all = controller.allFighters;
    final retired = controller.retiredFighters
      ..sort((a, b) => b.record.wins.compareTo(a.record.wins));

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Accolades & Feats', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _Leaderboard(
            title: 'Most Wins',
            icon: Icons.emoji_events,
            fighters: [...all]..sort((a, b) => b.record.wins.compareTo(a.record.wins)),
            valueOf: (f) => '${f.record.wins} wins',
          ),
          _Leaderboard(
            title: 'Highest Elo Rating',
            icon: Icons.trending_up,
            fighters: [...all]..sort((a, b) => b.eloRating.compareTo(a.eloRating)),
            valueOf: (f) => '${f.eloRating} Elo',
          ),
          _Leaderboard(
            title: 'Most Fight of the Night Awards',
            icon: Icons.local_fire_department,
            fighters: [...all]
              ..sort((a, b) => b.fightOfTheNightCount.compareTo(a.fightOfTheNightCount)),
            valueOf: (f) => '${f.fightOfTheNightCount}',
            filter: (f) => f.fightOfTheNightCount > 0,
          ),
          _Leaderboard(
            title: 'Most Performance of the Night Awards',
            icon: Icons.star,
            fighters: [...all]..sort(
                (a, b) => b.performanceOfTheNightCount.compareTo(a.performanceOfTheNightCount)),
            valueOf: (f) => '${f.performanceOfTheNightCount}',
            filter: (f) => f.performanceOfTheNightCount > 0,
          ),
          _Leaderboard(
            title: 'Longest Active Win Streak',
            icon: Icons.whatshot,
            fighters: [...all]..sort((a, b) => b.winStreak.compareTo(a.winStreak)),
            valueOf: (f) => '${f.winStreak} in a row',
            filter: (f) => f.winStreak > 0,
          ),
          _Leaderboard(
            title: 'Highest Potential',
            icon: Icons.auto_awesome,
            fighters: [...all]..sort((a, b) => b.potential.compareTo(a.potential)),
            valueOf: (f) => '${f.potential} ceiling',
          ),
          const SizedBox(height: 24),
          Text('Retired Fighters', style: Theme.of(context).textTheme.titleLarge),
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
                      builder: (_) => FighterProfileScreen(fighterId: fighter.id),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Fighter> fighters;
  final String Function(Fighter) valueOf;
  final bool Function(Fighter)? filter;

  const _Leaderboard({
    required this.title,
    required this.icon,
    required this.fighters,
    required this.valueOf,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final top = fighters.where(filter ?? (_) => true).take(5).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < top.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(width: 20, child: Text('${i + 1}.')),
                    Expanded(child: Text(top[i].name)),
                    Text(valueOf(top[i])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
