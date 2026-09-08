import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../../domain/finance/payroll_health.dart';
import '../../state/game_controller.dart';
import '../calendar/calendar_screen.dart';
import '../saves/saves_screen.dart';
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
            icon: const Icon(Icons.settings),
            tooltip: 'Saves',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavesScreen()),
            ),
          ),
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
                _StatsRow(
                  org: org,
                  currency: currency,
                  weeklyOverhead: controller.weeklyOverhead,
                  payroll: controller.payrollHealth,
                ),
                // Being cut off should never be a surprise — the slide
                // into it takes months, and this is the warning.
                if (controller.isOverextended)
                  _CutOffBanner(currency: currency, ceiling: controller.debtCeiling),
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

/// Shown once the bank has stopped the promotion booking anything new.
class _CutOffBanner extends StatelessWidget {
  final NumberFormat currency;
  final int ceiling;

  const _CutOffBanner({required this.currency, required this.ceiling});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.account_balance, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The bank has cut you off past ${currency.format(-ceiling)} '
                'in debt. Run the cards you have booked and release '
                'fighters you are not using — every one of them is on your '
                'weekly bill.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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

  /// What the promotion spends every week whether or not it runs a card.
  /// On the dashboard because a cost the player cannot see is a cost
  /// they cannot manage.
  final int weeklyOverhead;

  /// Null until the promotion has run a show — there is no ratio to
  /// report before there are takings to take a share of.
  final PayrollHealth? payroll;

  const _StatsRow({
    required this.org,
    required this.currency,
    required this.weeklyOverhead,
    required this.payroll,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(label: 'Cash', value: currency.format(org.cashBalance)),
        // The tier is what you *are*; the line under it is what you are
        // climbing toward. Reputation used to accumulate to nothing and
        // the tier never moved, so neither number was worth reading.
        _StatCard(
          label: 'Reputation',
          value: org.reputationTier.label,
          footnote: _tierProgress(org),
        ),
        _StatCard(label: 'Fanbase', value: '${org.fanbaseSize}'),
        _StatCard(
          label: 'Weekly Costs',
          value: '-${currency.format(weeklyOverhead)}',
        ),
        // The reading that predicts a cash crisis. A promotion can sit
        // at 40% for years, upgrade its roster, and be paying out more
        // than its shows take before anything says so.
        if (payroll != null)
          _StatCard(
            label: 'Fighter Pay',
            value: '${payroll!.sharePercent}% of takings',
            footnote: switch (payroll!.pressure) {
              PayrollPressure.comfortable =>
                'last ${payroll!.shows} shows · room to grow',
              PayrollPressure.tight =>
                'last ${payroll!.shows} shows · little room left',
              PayrollPressure.overcommitted =>
                'last ${payroll!.shows} shows · more than they take in',
            },
            emphasise: payroll!.pressure.needsAttention,
          ),
        _StatCard(label: 'Home Region', value: org.homeRegion),
      ],
    );
  }
}

/// How far off the next tier is, or that there isn't one.
String _tierProgress(Organization org) {
  final next = org.reputationTier.nextTier;
  if (next == null) return '${org.reputationPoints} rep · at the top';
  final togo = next.reputationRequired - org.reputationPoints;
  return '${org.reputationPoints} rep · $togo to ${next.label}';
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  /// A smaller line under the value, for context the headline number
  /// can't carry on its own.
  final String? footnote;

  /// Colours the card when the number is one to act on.
  final bool emphasise;

  const _StatCard({
    required this.label,
    required this.value,
    this.footnote,
    this.emphasise = false,
  });

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
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: emphasise ? Theme.of(context).colorScheme.error : null,
                    fontWeight: emphasise ? FontWeight.bold : null,
                  ),
            ),
            if (footnote != null)
              Text(
                footnote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
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
