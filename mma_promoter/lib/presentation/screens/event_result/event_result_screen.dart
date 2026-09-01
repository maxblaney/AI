import '../../../domain/betting/fight_odds.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/simulation/fight_excitement.dart';
import '../../state/game_controller.dart';
import '../event_booking/event_booking_screen.dart';
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
      appBar: AppBar(
        title: Text(event.name),
        actions: [
          // A card booked weeks out can still be changed — reopen it in
          // the same screen that built it. Gone once the event has run,
          // because by then it is a result rather than a plan.
          if (!event.isCompleted)
            IconButton(
              icon: const Icon(Icons.edit_calendar_outlined),
              tooltip: 'Edit this card',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventBookingScreen(eventId: event.id),
                  ),
                );
                // The card may have changed under us while it was open.
                if (mounted) await _loadCard();
              },
            ),
        ],
      ),
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
          Builder(builder: (context) {
            final a = controller.fighterById(fight.fighterAId);
            final b = controller.fighterById(fight.fighterBId);
            final odds = (a != null && b != null)
                ? OddsCalculator.forFight(a: a, b: b)
                : null;
            return ListTile(
              title: Text('${a?.name ?? '?'} vs ${b?.name ?? '?'}'),
              subtitle: Text([
                if (fight.isMainEvent) 'Main Event'
                else if (fight.isCoMainEvent) 'Co-Main Event'
                else if (fight.isMainCard) 'Main Card'
                else 'Prelim',
                '${fight.rounds} Rounds',
                if (fight.titleFightType != TitleFightType.none)
                  fight.titleFightType.label,
              ].join(' · ')),
              trailing: odds == null
                  ? null
                  : Text(
                      '${odds.displayA} / ${odds.displayB}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            );
          }),
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

class _ResultsView extends StatefulWidget {
  final MmaEvent event;
  final List<Fight> card;
  final List<FighterOutcomeSummary>? fighterOutcomes;

  const _ResultsView({
    required this.event,
    required this.card,
    required this.fighterOutcomes,
  });

  @override
  State<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<_ResultsView> {
  /// Fights the player has already seen the outcome of, either by
  /// watching them or by choosing to skip to the result. Everything that
  /// would give an unseen fight away stays hidden until it's in here.
  final Set<String> _revealed = {};

  bool get _allRevealed =>
      widget.card.every((f) => _revealed.contains(f.id) || f.result == null);

  void _reveal(String fightId) => setState(() => _revealed.add(fightId));

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final card = widget.card;
    final fighterOutcomes = widget.fighterOutcomes;
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
        for (final fight in card)
          _FightResultTile(
            fight: fight,
            controller: controller,
            revealed: _revealed.contains(fight.id),
            onReveal: () => _reveal(fight.id),
          ),
        // Awards, injuries and popularity swings all give away who won, so
        // none of them appear until every fight on the card has been seen.
        if (!_allRevealed) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.visibility_off, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Awards, injuries and popularity changes are hidden '
                      'until you\'ve seen every fight.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_allRevealed) ...[
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

  /// Whether the outcome may be shown. Until it is, the tile is a fight
  /// preview with odds — the point being that you find out by watching,
  /// not by reading it off a list.
  final bool revealed;
  final VoidCallback onReveal;

  const _FightResultTile({
    required this.fight,
    required this.controller,
    required this.revealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final result = fight.result;
    final a = controller.fighterById(fight.fighterAId);
    final b = controller.fighterById(fight.fighterBId);
    if (result == null || a == null || b == null) {
      return ListTile(title: Text('${a?.name ?? '?'} vs ${b?.name ?? '?'}'));
    }

    final tag = fight.isMainEvent
        ? ' (Main Event)'
        : fight.isCoMainEvent
            ? ' (Co-Main Event)'
            : '';
    final odds = OddsCalculator.forFight(a: a, b: b);
    final canWatch = result.momentumTicks.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${a.name} vs ${b.name}$tag'),
            const SizedBox(height: 2),
            Text(
              '${a.name.split(' ').last} ${odds.displayA}  ·  '
              '${b.name.split(' ').last} ${odds.displayB}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            if (revealed) ...[
              Text(
                result.isDraw
                    ? 'Draw / No Contest'
                    : '${result.winnerId == a.id ? a.name : b.name} def. by '
                        '${result.methodDisplay} · R${result.round} '
                        '${result.timeDisplay}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              // How good it was to watch, which is also what moved both
              // men's popularity — so the number that explains the swing
              // is on the same tile as the swing.
              _ExcitementMeter(
                excitement: FightExcitement.rate(
                  result: result,
                  scheduledRounds: fight.rounds,
                ),
              ),
            ]
            else
              // Wrap rather than Row: on a narrow phone the two buttons
              // together were running off the side of the card.
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (canWatch)
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Watch Live'),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FightBreakdownScreen(
                              fight: fight,
                              fighterA: a,
                              fighterB: b,
                            ),
                          ),
                        );
                        onReveal();
                      },
                    ),
                  TextButton(
                    onPressed: onReveal,
                    child: Text(canWatch ? 'Skip to result' : 'Show result'),
                  ),
                ],
              ),
          ],
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

/// How exciting a finished fight was, out of ten, with the band beside
/// it. Deliberately the same shape as the hype bar on the booking side:
/// hype is what you expected, this is what you got.
class _ExcitementMeter extends StatelessWidget {
  final FightExcitement excitement;

  const _ExcitementMeter({required this.excitement});

  @override
  Widget build(BuildContext context) {
    final color = _excitementColor(excitement.rating);
    return Row(
      children: [
        Text('FIGHT', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: excitement.rating / 10,
              minHeight: 7,
              backgroundColor:
                  Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${excitement.rating}/10',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            excitement.label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Cold grey through hot amber, matching how the booking screen colours
/// hype so the two read on the same scale.
Color _excitementColor(int rating) {
  if (rating >= 9) return Colors.amber;
  if (rating >= 7) return Colors.orangeAccent;
  if (rating >= 5) return Colors.lightGreen;
  if (rating >= 3) return Colors.blueGrey;
  return Colors.grey;
}
