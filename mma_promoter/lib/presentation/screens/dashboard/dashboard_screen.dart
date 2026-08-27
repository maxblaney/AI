import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
import '../event_booking/event_booking_screen.dart';
import '../event_result/event_result_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final org = controller.organization;
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: Text(org?.name ?? 'MMA Promoter')),
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
                _StatsRow(org: org, currency: currency),
                const SizedBox(height: 24),
                Text('Upcoming Events', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (controller.scheduledEvents.isEmpty)
                  const _EmptyHint(text: 'No events booked yet. Tap "Book Event" to build a card.'),
                for (final event in controller.scheduledEvents)
                  _EventTile(event: event),
                const SizedBox(height: 24),
                Text('Recent Results', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (controller.completedEvents.isEmpty)
                  const _EmptyHint(text: 'No events have run yet.'),
                for (final event in controller.completedEvents.reversed.take(5))
                  _EventTile(event: event),
                const SizedBox(height: 80),
              ],
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

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(event.date);
    return Card(
      child: ListTile(
        leading: Icon(
          event.isCompleted ? Icons.check_circle : Icons.event,
          color: event.isCompleted ? Colors.green : null,
        ),
        title: Text(event.name),
        subtitle: Text('$dateStr · ${event.venue.label}'),
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
