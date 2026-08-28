import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';
import '../calendar/calendar_screen.dart';
import '../event_booking/event_booking_screen.dart';
import '../event_result/event_result_screen.dart';
import '../inbox/inbox_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _advanceWeek(BuildContext context) async {
    final controller = context.read<GameController>();
    final error = await controller.advanceWeek();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final org = controller.organization;
    final currency = NumberFormat.simpleCurrency();
    final unread = controller.unreadInboxCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(org?.name ?? 'MMA Promoter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
          ),
          IconButton(
            icon: Badge(
              label: Text('$unread'),
              isLabelVisible: unread > 0,
              child: const Icon(Icons.mail_outline),
            ),
            tooltip: 'Inbox',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InboxScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Book Event'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EventBookingScreen()),
        ),
      ),
      body: org == null
          ? const Center(child: Text('No organization yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WeekCard(org: org, controller: controller, onAdvance: () => _advanceWeek(context)),
                const SizedBox(height: 16),
                _StatsRow(org: org, currency: currency),
                const SizedBox(height: 24),
                Text('Upcoming Events', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (controller.scheduledEvents.isEmpty)
                  const _EmptyHint(text: 'No events booked yet. Tap "Book Event" to build a card.'),
                for (final event in controller.scheduledEvents)
                  _EventTile(event: event, currentWeek: org.currentWeek),
                const SizedBox(height: 24),
                Text('Recent Results', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (controller.completedEvents.isEmpty)
                  const _EmptyHint(text: 'No events have run yet.'),
                for (final event in controller.completedEvents.reversed.take(5))
                  _EventTile(event: event, currentWeek: org.currentWeek),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  final Organization org;
  final GameController controller;
  final VoidCallback onAdvance;

  const _WeekCard({required this.org, required this.controller, required this.onAdvance});

  @override
  Widget build(BuildContext context) {
    final due = controller.nextScheduledEvent;
    final dueNow = due != null && GameCalendar.weekNumberFor(due.date) <= org.currentWeek;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Now', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    GameCalendar.label(org.currentWeek),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (dueNow)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '"${due.name}" is ready to run.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            if (dueNow)
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Event'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EventResultScreen(eventId: due.id)),
                ),
              )
            else
              FilledButton.icon(
                icon: const Icon(Icons.skip_next),
                label: const Text('Advance Week'),
                onPressed: onAdvance,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Organization org;
  final NumberFormat currency;

  const _StatsRow({required this.org, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(label: 'Cash', value: currency.format(org.cashBalance)),
        _StatCard(label: 'Reputation', value: org.reputationTier.label),
        _StatCard(label: 'Fanbase', value: '${org.fanbaseSize}'),
        _StatCard(label: 'Home Region', value: org.homeRegion),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final MmaEvent event;
  final int currentWeek;

  const _EventTile({required this.event, required this.currentWeek});

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
        subtitle: Text('${GameCalendar.label(week)} · ${event.venue.label}${isDue ? ' · Ready to run' : ''}'),
        trailing: event.isCompleted
            ? Text('${event.netProfit >= 0 ? '+' : ''}\$${event.netProfit}')
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventResultScreen(eventId: event.id),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
