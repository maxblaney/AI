import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/models.dart';
import '../../domain/calendar/game_calendar.dart';
import '../../domain/condition/fighter_condition.dart';
import '../../domain/history/recent_form.dart';
import '../state/game_controller.dart';
import '../theme/app_theme.dart';
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
    final currentWeek = controller.organization?.currentWeek ?? 1;

    final condition = FighterConditionCalculator.conditionOf(fighter);
    final sharpness = FighterConditionCalculator.sharpnessOf(
      fighter,
      campWeeks: controller.campWeeksFor(fighter.id),
      weeksSinceLastFight: fighter.lastFoughtWeek == null
          ? null
          : currentWeek - fighter.lastFoughtWeek!,
    );

    final form = controller.recentFormByFighterId[fighter.id] ?? const [];

    return ListTile(
      isThreeLine: true,
      leading: FighterAvatar(fighter: fighter),
      title: Row(
        children: [
          Expanded(child: Text(fighter.name)),
          // One belt, one trophy — a double champ shows two.
          if (fighter.isChampion)
            const Icon(Icons.emoji_events, size: 15, color: AppColors.belt),
          if (fighter.isDoubleChampion)
            const Icon(Icons.emoji_events, size: 15, color: AppColors.belt),
          if (!fighter.isChampion && fighter.isInterimChampion)
            const Icon(Icons.emoji_events,
                size: 15, color: AppColors.beltInterim),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${fighter.weightClass.label} · ${fighter.record.display} · '
            '${fighter.style.label}',
          ),
          // Last five results and how big a draw they are, on the row.
          // A record says what a fighter has done; these say what they
          // have been doing and whether anyone is watching.
          const SizedBox(height: 3),
          Row(
            children: [
              _FormChips(entries: form),
              if (form.isNotEmpty) const SizedBox(width: 8),
              _StarPower(popularity: fighter.popularity),
            ],
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              // A ban outranks everything else on the row: however fit
              // and sharp they are, you can't put them on a card.
              if (fighter.isSuspendedOn(currentWeek))
                _Pill(
                  label: 'Suspended · '
                      '${fighter.suspendedUntilWeek! - currentWeek}w',
                  color: Colors.redAccent,
                ),
              // Condition next: an injured fighter can't be booked, so
              // it's the thing that changes what you can do with them.
              _Pill(
                label: condition.label,
                color: _conditionColor(condition),
              ),
              _Pill(
                label: sharpness.label,
                color: _sharpnessColor(sharpness),
              ),
              if (contract != null)
                _Pill(
                  label: contract.fightsRemaining == 1
                      ? '1 fight left'
                      : '${contract.fightsRemaining} fights left',
                  color: contract.fightsRemaining <= 1
                      ? Colors.orange
                      : scheme.onSurfaceVariant,
                ),
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

/// Green through red as condition falls — the colour carries the reading
/// at a glance, the label says exactly which tier.
Color _conditionColor(FighterCondition condition) => switch (condition) {
      FighterCondition.peak => Colors.greenAccent,
      FighterCondition.healthy => Colors.green,
      FighterCondition.inShape => Colors.amber,
      FighterCondition.injured => Colors.orange,
      FighterCondition.battered => Colors.red,
    };

Color _sharpnessColor(Sharpness sharpness) => switch (sharpness) {
      Sharpness.sharp => Colors.lightBlueAccent,
      Sharpness.prepared => Colors.lightBlue,
      Sharpness.uneasy => Colors.amber,
      Sharpness.notPrepared => Colors.orange,
      Sharpness.outOfShape => Colors.red,
    };

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

/// The last five results, oldest of the five on the left, so the row
/// reads left-to-right like a run of form. Green win, red loss, grey
/// draw or no contest.
class _FormChips extends StatelessWidget {
  final List<FormEntry> entries;

  const _FormChips({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    // [entries] arrive newest first; reversed here so the most recent
    // result sits on the right, where a run of form ends.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in entries.reversed)
          Tooltip(
            message: entry.methodLabel,
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _formColor(entry.result).withOpacity(0.22),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                _formLetter(entry.result),
                style: TextStyle(
                  fontSize: 9,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                  color: _formColor(entry.result),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A draw shows as T here rather than D: on a coloured chip beside W and
/// L, "T" for tie is the one people read without thinking about it.
String _formLetter(FormResult result) => switch (result) {
      FormResult.win => 'W',
      FormResult.loss => 'L',
      FormResult.draw => 'T',
    };

Color _formColor(FormResult result) => switch (result) {
      FormResult.win => Colors.green,
      FormResult.loss => Colors.redAccent,
      FormResult.draw => Colors.grey,
    };

/// Popularity as a mark out of ten, which is how the rest of the game
/// talks about a fight being worth watching. The underlying value is
/// 0-100; this is that, rounded up so anyone with any following at all
/// reads as at least a 1.
class _StarPower extends StatelessWidget {
  final int popularity;

  const _StarPower({required this.popularity});

  static int outOfTen(int popularity) =>
      popularity <= 0 ? 0 : ((popularity + 9) ~/ 10).clamp(1, 10);

  @override
  Widget build(BuildContext context) {
    final score = outOfTen(popularity);
    final color = score >= 8
        ? Colors.amber
        : score >= 5
            ? Colors.orangeAccent
            : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, size: 13, color: color),
        const SizedBox(width: 2),
        Text(
          '$score/10',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
