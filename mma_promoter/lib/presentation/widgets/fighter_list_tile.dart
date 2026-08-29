import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/models.dart';
import '../../domain/calendar/game_calendar.dart';
import '../state/game_controller.dart';
import 'fighter_avatar.dart';

class FighterListTile extends StatelessWidget {
  final Fighter fighter;
  final VoidCallback? onTap;

  const FighterListTile({super.key, required this.fighter, this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final booking = controller.bookingsByFighterId[fighter.id];
    final contract = fighter.contract;
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall;

    return ListTile(
      isThreeLine: true,
      leading: FighterAvatar(fighter: fighter),
      title: Row(
        children: [
          Expanded(child: Text(fighter.name)),
          if (fighter.isChampion)
            Icon(Icons.emoji_events, size: 15, color: scheme.primary),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${fighter.weightClass.label} · ${fighter.record.display} · '
            '${fighter.style.label}',
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              // Health first: an injured fighter can't be booked, so it's
              // the thing that changes what you can do with them.
              _Pill(
                label: fighter.injuryStatus == InjuryStatus.healthy
                    ? 'Healthy'
                    : fighter.injuryStatus.label,
                color: fighter.injuryStatus == InjuryStatus.healthy
                    ? Colors.green
                    : Colors.orange,
              ),
              if (contract != null) ...[
                const SizedBox(width: 6),
                _Pill(
                  label: contract.fightsRemaining == 1
                      ? '1 fight left'
                      : '${contract.fightsRemaining} fights left',
                  color: contract.fightsRemaining <= 1
                      ? Colors.orange
                      : scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
          if (booking != null) ...[
            const SizedBox(height: 2),
            Text(
              'vs ${controller.fighterById(booking.opponentId)?.name ?? 'TBD'}'
              ' · ${GameCalendar.label(GameCalendar.weekNumberFor(booking.date))}'
              '${booking.isTitleFight ? ' · Title' : ''}',
              style: small?.copyWith(color: scheme.primary),
            ),
          ],
        ],
      ),
      trailing: Text(
        'OVR ${fighter.overall.round()}',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      onTap: onTap,
    );
  }
}

/// Small status chip — deliberately lighter than a Material Chip, which
/// is too heavy repeated twice on every row of a long list.
class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}
