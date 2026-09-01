import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/rankings/pound_for_pound.dart';
import '../../state/game_controller.dart';
import '../../theme/app_theme.dart';
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
    // A division's list is its own fighters plus anyone who came up (or
    // down) and took the belt — a champion has to appear in the ranking
    // of the division he's champion of, even when it isn't his home
    // weight.
    final pool = controller.rankedFighters
        .where((f) =>
            isP4P ||
            f.weightClass == _weightClass ||
            f.holdsAnyBeltIn(_weightClass!))
        .toList();

    // In a division the champion sits above the contenders regardless of
    // Elo — that's what holding the belt means. Pound-for-pound spans
    // every division and can't put all eight champions on top, so there
    // a belt is worth just enough to lift its holder past his own
    // contenders and no further — see [PoundForPound].
    final List<Fighter> ranked;
    if (isP4P) {
      ranked = PoundForPound.rank(pool);
    } else {
      ranked = pool
        ..sort((a, b) {
          int rank(Fighter f) => f.championOf(_weightClass!)
              ? 0
              : (f.interimChampionOf(_weightClass!) ? 1 : 2);
          final byBelt = rank(a).compareTo(rank(b));
          return byBelt != 0 ? byBelt : b.eloRating.compareTo(a.eloRating);
        });
    }

    // Contenders number from 1; belt holders are labelled instead.
    final labels = <String>[];
    var contender = 0;
    for (final f in ranked) {
      if (!isP4P && f.championOf(_weightClass!)) {
        labels.add('C');
      } else if (!isP4P && f.interimChampionOf(_weightClass!)) {
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
                                  color: label == 'C'
                                      ? AppColors.belt
                                      : (label == 'iC'
                                          ? AppColors.beltInterim
                                          : null),
                                ),
                              ),
                            ),
                            Expanded(child: Text(fighter.name)),
                            // Pound-for-pound numbers everyone 1..n, so
                            // without this you can't tell a champion from
                            // a contender at a glance.
                            if (isP4P) _BeltBadge(fighter: fighter),
                          ],
                        ),
                        subtitle: Text(
                          isP4P
                              ? [
                                  _p4pDivisionLine(fighter),
                                  fighter.record.display,
                                  fighter.style.label,
                                ].join(' · ')
                              // A visiting champion's home division is
                              // worth saying, or he looks like he was
                              // always ranked here.
                              : [
                                  if (fighter.weightClass != _weightClass)
                                    '${fighter.weightClass.label} champ',
                                  fighter.record.display,
                                  fighter.style.label,
                                ].join(' · '),
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

/// What division a fighter belongs to in the P4P list — naming the belts
/// they hold rather than just where they weigh in, since that's the thing
/// that puts them on this list high.
String _p4pDivisionLine(Fighter fighter) {
  final belts = [
    for (final division in WeightClass.values)
      if (fighter.championOf(division)) division.label,
  ];
  if (belts.isEmpty) {
    final interim = [
      for (final division in WeightClass.values)
        if (fighter.interimChampionOf(division)) division.label,
    ];
    if (interim.isNotEmpty) return '${interim.join(' & ')} interim champ';
    return fighter.weightClass.label;
  }
  return '${belts.join(' & ')} champion';
}

/// The gold belt marker on a pound-for-pound row. Undisputed belts read
/// as gold, interim as the muted version, so the two are never confused.
class _BeltBadge extends StatelessWidget {
  final Fighter fighter;

  const _BeltBadge({required this.fighter});

  @override
  Widget build(BuildContext context) {
    if (!fighter.isChampion && !fighter.isInterimChampion) {
      return const SizedBox.shrink();
    }
    final undisputed = fighter.isChampion;
    final color = undisputed ? AppColors.belt : AppColors.beltInterim;
    final label = fighter.isDoubleChampion
        ? 'DOUBLE CHAMP'
        : (undisputed ? 'CHAMP' : 'INTERIM');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events, size: 15, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
