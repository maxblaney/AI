import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';

/// Shows a booked card before it runs (with a "Run Event" action that
/// resolves every fight) or the full results breakdown once it's completed.
class EventResultScreen extends StatefulWidget {
  final String eventId;

  const EventResultScreen({super.key, required this.eventId});

  @override
  State<EventResultScreen> createState() => _EventResultScreenState();
}

class _EventResultScreenState extends State<EventResultScreen> {
  double _promoSpend = 2000;
  bool _simulating = false;
  List<Fight>? _card;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final controller = context.read<GameController>();
    final event = await controller.getEventById(widget.eventId);
    if (event == null) return;
    final card = await controller.getEventCard(widget.eventId);
    if (!mounted) return;
    setState(() => _card = card);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final event = [...controller.scheduledEvents, ...controller.completedEvents]
        .cast<MmaEvent?>()
        .firstWhere((e) => e?.id == widget.eventId, orElse: () => null);

    if (event == null || _card == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(event.name)),
      body: event.isCompleted
          ? _ResultsView(event: event, card: _card!)
          : _PreEventView(
              event: event,
              card: _card!,
              promoSpend: _promoSpend,
              simulating: _simulating,
              onPromoSpendChanged: (v) => setState(() => _promoSpend = v),
              onRun: _runEvent,
            ),
    );
  }

  Future<void> _runEvent() async {
    setState(() => _simulating = true);
    final controller = context.read<GameController>();
    final summary = await controller.simulateEvent(
      widget.eventId,
      promotionBudgetSpent: _promoSpend.round(),
    );
    if (!mounted) return;
    setState(() {
      _simulating = false;
      if (summary != null) _card = summary.resolvedCard;
    });
  }
}

class _PreEventView extends StatelessWidget {
  final MmaEvent event;
  final List<Fight> card;
  final double promoSpend;
  final bool simulating;
  final ValueChanged<double> onPromoSpendChanged;
  final VoidCallback onRun;

  const _PreEventView({
    required this.event,
    required this.card,
    required this.promoSpend,
    required this.simulating,
    required this.onPromoSpendChanged,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final currency = NumberFormat.simpleCurrency();
    final maxSpend = (controller.organization?.cashBalance ?? 0).clamp(0, 1 << 30);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${DateFormat.yMMMd().format(event.date)} · ${event.venue.label} · '
          '\$${event.ticketPrice} tickets',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text('Card', style: Theme.of(context).textTheme.titleLarge),
        for (final fight in card)
          ListTile(
            title: Text(
              '${controller.fighterById(fight.fighterAId)?.name ?? '?'} vs '
              '${controller.fighterById(fight.fighterBId)?.name ?? '?'}',
            ),
            subtitle: Text(fight.isMainEvent ? 'Main Event' : 'Undercard'),
          ),
        const SizedBox(height: 16),
        Text('Promotion Spend', style: Theme.of(context).textTheme.titleMedium),
        Text('${currency.format(promoSpend)} of up to ${currency.format(maxSpend)}'),
        Slider(
          value: promoSpend.clamp(0, maxSpend.toDouble()),
          min: 0,
          max: maxSpend > 0 ? maxSpend.toDouble() : 1,
          divisions: 20,
          onChanged: onPromoSpendChanged,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: Text(simulating ? 'Running...' : 'Run Event'),
          onPressed: simulating ? null : onRun,
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  final MmaEvent event;
  final List<Fight> card;

  const _ResultsView({required this.event, required this.card});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final currency = NumberFormat.simpleCurrency();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricChip(label: 'Attendance', value: '${event.attendance}'),
            _MetricChip(label: 'PPV Buys', value: '${event.ppvBuys}'),
            _MetricChip(label: 'Revenue', value: currency.format(event.revenue)),
            _MetricChip(label: 'Expenses', value: currency.format(event.expenses)),
            _MetricChip(
              label: 'Net',
              value: currency.format(event.netProfit),
              highlight: event.netProfit >= 0,
            ),
            _MetricChip(label: 'Reputation', value: '${event.reputationChange >= 0 ? '+' : ''}${event.reputationChange}'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Results', style: Theme.of(context).textTheme.titleLarge),
        for (final fight in card) _FightResultTile(fight: fight, controller: controller),
      ],
    );
  }
}

class _FightResultTile extends StatelessWidget {
  final Fight fight;
  final GameController controller;

  const _FightResultTile({required this.fight, required this.controller});

  @override
  Widget build(BuildContext context) {
    final result = fight.result;
    final a = controller.fighterById(fight.fighterAId);
    final b = controller.fighterById(fight.fighterBId);
    if (result == null || a == null || b == null) {
      return ListTile(title: Text('${a?.name ?? '?'} vs ${b?.name ?? '?'}'));
    }

    final winnerName = result.isDraw
        ? null
        : (result.winnerId == a.id ? a.name : b.name);

    return Card(
      child: ListTile(
        title: Text('${a.name} vs ${b.name}${fight.isMainEvent ? ' (Main Event)' : ''}'),
        subtitle: Text(
          result.isDraw
              ? 'Draw / No Contest'
              : '$winnerName wins by ${result.method.label}, Round ${result.round}',
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final bool? highlight;

  const _MetricChip({required this.label, required this.value, this.highlight});

  @override
  Widget build(BuildContext context) {
    final color = highlight == null
        ? null
        : (highlight! ? Colors.green : Colors.red);
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
