import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';
import '../event_result/event_result_screen.dart';

/// Shows where the promotion sits on the game's own clock — Year/Week —
/// plus every scheduled and completed event, in chronological order, so
/// it's obvious which event is next up.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final org = controller.organization;
    final currentWeek = org?.currentWeek ?? 1;

    final scheduled = [...controller.scheduledEvents]
      ..sort((a, b) => a.date.compareTo(b.date));
    final completed = [...controller.completedEvents]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Now', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    GameCalendar.label(currentWeek),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    DateFormat.yMMMd().format(GameCalendar.dateForWeek(currentWeek)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Scheduled', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (scheduled.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nothing on the books yet.'),
            ),
          for (var i = 0; i < scheduled.length; i++)
            _CalendarEventTile(
              event: scheduled[i],
              currentWeek: currentWeek,
              isNext: i == 0,
            ),
          const SizedBox(height: 24),
          Text('Completed', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No events run yet.'),
            ),
          for (final event in completed)
            _CalendarEventTile(event: event, currentWeek: currentWeek, isNext: false),
        ],
      ),
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  final MmaEvent event;
  final int currentWeek;
  final bool isNext;

  const _CalendarEventTile({
    required this.event,
    required this.currentWeek,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final week = GameCalendar.weekNumberFor(event.date);
    final isDue = !event.isCompleted && week <= currentWeek;

    return Card(
      color: isDue ? Theme.of(context).colorScheme.tertiaryContainer : null,
      child: ListTile(
        leading: Icon(
          event.isCompleted ? Icons.check_circle : (isDue ? Icons.notifications_active : Icons.event),
          color: event.isCompleted ? Colors.green : null,
        ),
        title: Text(event.name),
        subtitle: Text(
          '${GameCalendar.label(week)} · ${event.venue.label}'
          '${isDue ? ' · Ready to run' : ''}',
        ),
        trailing: event.isCompleted
            ? Text('${event.netProfit >= 0 ? '+' : ''}\$${event.netProfit}')
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventResultScreen(eventId: event.id)),
        ),
      ),
    );
  }
}
