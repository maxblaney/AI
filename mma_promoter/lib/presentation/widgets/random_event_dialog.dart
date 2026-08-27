import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/models.dart';
import '../state/game_controller.dart';

Future<void> showRandomEventDialog(BuildContext context, RandomEvent event) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => RandomEventDialog(event: event),
  );
}

class RandomEventDialog extends StatelessWidget {
  final RandomEvent event;

  const RandomEventDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameController>();
    final fighter = event.affectedFighterId == null
        ? null
        : controller.fighterById(event.affectedFighterId!);

    return AlertDialog(
      icon: const Icon(Icons.report_gmailerrorred),
      title: Text(event.headline),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.description),
          if (fighter != null) ...[
            const SizedBox(height: 12),
            Text(
              '${fighter.name} — Morale ${fighter.morale}, '
              '${fighter.injuryStatus.label}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: event.choices.map((choice) {
        return TextButton(
          onPressed: () async {
            await controller.resolveRandomEvent(event, choice.id);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(choice.label),
              Text(
                choice.consequenceSummary,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
