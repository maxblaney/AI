import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
import 'fight_breakdown_screen.dart';

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
  List<FighterOutcomeSummary>? _fighterOutcomes;

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
          ? _ResultsView(
              event: event,
              card: _card!,
              fighterOutcomes: _fighterOutcomes,
            )
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
      if (summary != null) {
        _card = summary.resolvedCard;
        _fighterOutcomes = summary.fighterOutcomes;
      }
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
            subtitle: Text([
              if (fight.isMainEvent) 'Main Event'
              else if (fight.isCoMainEvent) 'Co-Main Event'
              else if (fight.isMainCard) 'Main Card'
              else 'Prelim',
              '${fight.rounds} Rounds',
              if (fight.titleFightType != TitleFightType.none) fight.titleFightType.label,
            ].join(' · ')),
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
  final List<FighterOutcomeSummary>? fighterOutcomes;

  const _ResultsView({
    required this.event,
    required this.card,
    required this.fighterOutcomes,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final currency = NumberFormat.simpleCurrency();
    final outcomes = fighterOutcomes;
    final injured = outcomes?.where((o) => o.injuryStatus != InjuryStatus.healthy).toList();

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
        const SizedBox(height: 24),
        _AwardsSection(event: event, card: card, controller: controller),
        if (injured != null && injured.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Injuries', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final outcome in injured)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_hospital, color: Colors.orange),
              title: Text(outcome.fighterName),
              subtitle: Text(outcome.injuryStatus.label),
            ),
        ],
        if (outcomes != null && outcomes.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Popularity Changes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final outcome in outcomes)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(outcome.fighterName),
              trailing: Text(
                '${outcome.popularityDelta >= 0 ? '+' : ''}${outcome.popularityDelta}',
                style: TextStyle(
                  color: outcome.popularityDelta >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _AwardsSection extends StatelessWidget {
  final MmaEvent event;
  final List<Fight> card;
  final GameController controller;

  const _AwardsSection({
    required this.event,
    required this.card,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bonus = controller.organization?.reputationTier.nightlyBonusAmount ?? 0;
    final currency = NumberFormat.simpleCurrency();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fight Night Awards', style: Theme.of(context).textTheme.titleLarge),
        Text(
          'Bonus per award: ${currency.format(bonus)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (event.fightOfTheNightFightId != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: const Text('Fight of the Night'),
            subtitle: Text(_fightLabel(event.fightOfTheNightFightId!)),
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.emoji_events),
            label: const Text('Award Fight of the Night'),
            onPressed: () => _pickFight(context),
          ),
        const SizedBox(height: 8),
        if (event.performanceOfTheNightFighterId != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Performance of the Night'),
            subtitle: Text(
              controller.fighterById(event.performanceOfTheNightFighterId!)?.name ??
                  'Unknown',
            ),
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.star),
            label: const Text('Award Performance of the Night'),
            onPressed: () => _pickFighter(context),
          ),
      ],
    );
  }

  String _fightLabel(String fightId) {
    for (final fight in card) {
      if (fight.id == fightId) {
        final a = controller.fighterById(fight.fighterAId)?.name ?? '?';
        final b = controller.fighterById(fight.fighterBId)?.name ?? '?';
        return '$a vs $b';
      }
    }
    return 'Unknown fight';
  }

  void _pickFight(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Fight of the Night'),
        children: [
          for (final fight in card)
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final error =
                    await controller.awardFightOfTheNight(event.id, fight.id);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: Text(
                '${controller.fighterById(fight.fighterAId)?.name ?? '?'} vs '
                '${controller.fighterById(fight.fighterBId)?.name ?? '?'}',
              ),
            ),
        ],
      ),
    );
  }

  void _pickFighter(BuildContext context) {
    final fighterIds = <String>{};
    for (final fight in card) {
      fighterIds.add(fight.fighterAId);
      fighterIds.add(fight.fighterBId);
    }

    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Performance of the Night'),
        children: [
          for (final id in fighterIds)
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final error =
                    await controller.awardPerformanceOfTheNight(event.id, id);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: Text(controller.fighterById(id)?.name ?? 'Unknown'),
            ),
        ],
      ),
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
    final tag = fight.isMainEvent
        ? ' (Main Event)'
        : fight.isCoMainEvent
            ? ' (Co-Main Event)'
            : '';

    return Card(
      child: ListTile(
        title: Text('${a.name} vs ${b.name}$tag'),
        subtitle: Text(
          result.isDraw
              ? 'Draw / No Contest'
              : '$winnerName wins by ${result.method.label}, Round ${result.round}',
        ),
        trailing: result.momentumTicks.isEmpty
            ? null
            : TextButton(
                child: const Text('Watch Live'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FightBreakdownScreen(
                      fight: fight,
                      fighterA: a,
                      fighterB: b,
                    ),
                  ),
                ),
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
