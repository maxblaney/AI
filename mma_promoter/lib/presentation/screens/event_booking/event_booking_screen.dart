import '../../../domain/betting/fight_odds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';

class EventBookingScreen extends StatefulWidget {
  const EventBookingScreen({super.key});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ticketPriceController;

  /// How many weeks out from the org's current week to book this event.
  /// Booking is always relative to the game clock, never a free-form
  /// calendar date — this is what keeps the timeline linear.
  int _weeksFromNow = 2;
  Venue _venue = Venue.regionalUsa;
  bool _ticketPriceEdited = false;
  final List<Fight> _card = [];
  String? _mainEventFightId;
  String? _coMainEventFightId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Fight Night');
    _ticketPriceController =
        TextEditingController(text: '${_venue.suggestedTicketPrice}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
  }

  Set<String> get _usedFighterIds =>
      _card.expand((f) => [f.fighterAId, f.fighterBId]).toSet();

  /// Everyone on [roster] who could be booked at [weightClass] — the
  /// division's own fighters plus anyone one class either side, since
  /// moving up or down a weight is a normal career move and the only way
  /// a champion ever gets a shot at a second belt.
  List<Fighter> _eligibleAt(List<Fighter> roster, WeightClass weightClass) {
    return roster
        .where((f) =>
            f.weightClass.canFightAt(weightClass) &&
            !_usedFighterIds.contains(f.id))
        .toList();
  }

  /// Weight classes with at least 2 available fighters — the only ones a
  /// new fight can be booked in.
  List<WeightClass> _bookableWeightClasses(List<Fighter> roster) {
    return WeightClass.values
        .where((wc) => _eligibleAt(roster, wc).length >= 2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final currentWeek = controller.organization?.currentWeek ?? 1;
    final roster = controller.signedRoster
        .where((f) =>
            f.injuryStatus != InjuryStatus.major &&
            !f.isSuspendedOn(currentWeek))
        .toList();
    final bookableClasses = _bookableWeightClasses(roster);
    final bookedWeek = currentWeek + _weeksFromNow;

    final mainCard = <Fight>[];
    final prelims = <Fight>[];
    for (var i = 0; i < _card.length; i++) {
      (i < Fight.mainCardSize ? mainCard : prelims).add(_card[i]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Event')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Event Name'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book for', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    GameCalendar.label(bookedWeek),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _weeksFromNow.toDouble(),
                    min: 1,
                    max: 26,
                    divisions: 25,
                    label: '$_weeksFromNow week${_weeksFromNow == 1 ? '' : 's'} out',
                    onChanged: (v) => setState(() => _weeksFromNow = v.round()),
                  ),
                  Text(
                    '$_weeksFromNow week${_weeksFromNow == 1 ? '' : 's'} from now '
                    '(currently ${GameCalendar.label(currentWeek)})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Venue>(
            value: _venue,
            decoration: const InputDecoration(labelText: 'Venue'),
            items: Venue.values
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        '${v.label} (cap. ${v.capacity}, \$${v.baseCost})',
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _venue = v ?? _venue;
              if (!_ticketPriceEdited) {
                _ticketPriceController.text = '${_venue.suggestedTicketPrice}';
              }
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ticketPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Ticket Price',
              helperText: 'Suggested for this venue: \$${_venue.suggestedTicketPrice}. '
                  'Pricing above it softens demand, below it boosts it.',
              helperMaxLines: 2,
              prefixText: '\$',
            ),
            onChanged: (_) => _ticketPriceEdited = true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Card', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Fight'),
                onPressed: bookableClasses.isNotEmpty
                    ? () => _addFight(roster, bookableClasses)
                    : null,
              ),
            ],
          ),
          // A disabled Add Fight button with no explanation is a dead end
          // — this says exactly what's missing and how to fix it.
          if (bookableClasses.isEmpty)
            _CannotBookNotice(
              signedCount: controller.signedRoster.length,
              healthyCount: roster.length,
              alreadyBooked: _usedFighterIds.length,
              suspendedCount: controller.signedRoster
                  .where((f) => f.isSuspendedOn(currentWeek))
                  .length,
            ),
          if (_card.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No fights added yet.'),
            ),
          if (mainCard.isNotEmpty) ...[
            const _SectionLabel('Main Card'),
            for (final fight in mainCard) _buildFightTile(controller, fight, isMainCardEligible: true),
          ],
          if (prelims.isNotEmpty) ...[
            const _SectionLabel('Prelims'),
            for (final fight in prelims) _buildFightTile(controller, fight, isMainCardEligible: false),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _confirm,
            child: _submitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildFightTile(
    GameController controller,
    Fight fight, {
    required bool isMainCardEligible,
  }) {
    return _FightTile(
      fight: fight,
      fighterA: controller.fighterById(fight.fighterAId),
      fighterB: controller.fighterById(fight.fighterBId),
      isMainEvent: fight.id == _mainEventFightId,
      isCoMainEvent: fight.id == _coMainEventFightId,
      showMainEventControls: isMainCardEligible,
      onSetMainEvent: () => setState(() {
        _mainEventFightId = fight.id;
        if (_coMainEventFightId == fight.id) _coMainEventFightId = null;
      }),
      onSetCoMainEvent: () => setState(() {
        _coMainEventFightId = fight.id;
        if (_mainEventFightId == fight.id) _mainEventFightId = null;
      }),
      onRemove: () => setState(() {
        _card.remove(fight);
        if (_mainEventFightId == fight.id) _mainEventFightId = null;
        if (_coMainEventFightId == fight.id) _coMainEventFightId = null;
      }),
    );
  }

  void _addFight(List<Fighter> roster, List<WeightClass> bookableClasses) {
    WeightClass weightClass = bookableClasses.first;
    String? fighterAId;
    String? fighterBId;
    int rounds = 3;
    TitleFightType titleFightType = TitleFightType.none;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final available = _eligibleAt(roster, weightClass);

          return AlertDialog(
            title: const Text('Add Fight'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<WeightClass>(
                    value: weightClass,
                    decoration: const InputDecoration(labelText: 'Weight Class'),
                    items: bookableClasses
                        .map((w) => DropdownMenuItem(value: w, child: Text(w.labelWithLimit)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      weightClass = v ?? weightClass;
                      fighterAId = null;
                      fighterBId = null;
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: fighterAId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Fighter A'),
                    items: available
                        .where((f) => f.id != fighterBId)
                        .map((f) => DropdownMenuItem(
                            value: f.id,
                            child: _fighterOption(context, f,
                                bookedAt: weightClass)))
                        .toList(),
                    onChanged: (v) => setState(() => fighterAId = v),
                  ),
                  DropdownButtonFormField<String>(
                    value: fighterBId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Fighter B'),
                    items: available
                        .where((f) => f.id != fighterAId)
                        .map((f) => DropdownMenuItem(
                            value: f.id,
                            child: _fighterOption(context, f,
                                bookedAt: weightClass)))
                        .toList(),
                    onChanged: (v) => setState(() => fighterBId = v),
                  ),

                  // Booking blind is the complaint this answers: once both
                  // corners are picked, show what you'd want to know before
                  // signing off on the matchup.
                  if (fighterAId != null && fighterBId != null)
                    _MatchupPreview(
                      a: available.firstWhere((f) => f.id == fighterAId),
                      b: available.firstWhere((f) => f.id == fighterBId),
                    ),
                  const SizedBox(height: 12),
                  const Text('Rounds'),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 3, label: Text('3')),
                      ButtonSegment(value: 5, label: Text('5')),
                    ],
                    selected: {rounds},
                    onSelectionChanged: (s) => setState(() => rounds = s.first),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TitleFightType>(
                    value: titleFightType,
                    decoration: const InputDecoration(labelText: 'Title Implications'),
                    items: TitleFightType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setState(() => titleFightType = v ?? titleFightType),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: fighterAId != null && fighterBId != null
                    ? () {
                        this.setState(() {
                          _card.add(Fight(
                            id: newId(),
                            eventId: '',
                            fighterAId: fighterAId!,
                            fighterBId: fighterBId!,
                            weightClass: weightClass,
                            rounds: rounds,
                            titleFightType: titleFightType,
                            cardOrder: _card.length,
                          ));
                        });
                        Navigator.of(dialogContext).pop();
                      }
                    : null,
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirm() async {
    if (_card.isEmpty) {
      _showError('Add at least one fight.');
      return;
    }
    if (_mainEventFightId == null) {
      _showError('Pick a main event fight.');
      return;
    }
    final mainCardCount = _card.length < Fight.mainCardSize ? _card.length : Fight.mainCardSize;
    if (mainCardCount >= 2 && _coMainEventFightId == null) {
      _showError('Pick a co-main event fight.');
      return;
    }
    final ticketPrice = int.tryParse(_ticketPriceController.text);
    if (ticketPrice == null || ticketPrice <= 0) {
      _showError('Enter a valid ticket price.');
      return;
    }

    setState(() => _submitting = true);
    final card = [
      for (var i = 0; i < _card.length; i++)
        _card[i].copyWith(
          isMainEvent: _card[i].id == _mainEventFightId,
          isCoMainEvent: _card[i].id == _coMainEventFightId,
          cardOrder: i,
        ),
    ];

    final controller = context.read<GameController>();
    final currentWeek = controller.organization?.currentWeek ?? 1;
    final error = await controller.bookEvent(
      name: _nameController.text.trim().isEmpty
          ? 'Fight Night'
          : _nameController.text.trim(),
      date: GameCalendar.dateForWeek(currentWeek + _weeksFromNow),
      venue: _venue,
      ticketPrice: ticketPrice,
      card: card,
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      _showError(error);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _FightTile extends StatelessWidget {
  final Fight fight;
  final Fighter? fighterA;
  final Fighter? fighterB;
  final bool isMainEvent;
  final bool isCoMainEvent;
  final bool showMainEventControls;
  final VoidCallback onSetMainEvent;
  final VoidCallback onSetCoMainEvent;
  final VoidCallback onRemove;

  const _FightTile({
    required this.fight,
    required this.fighterA,
    required this.fighterB,
    required this.isMainEvent,
    required this.isCoMainEvent,
    required this.showMainEventControls,
    required this.onSetMainEvent,
    required this.onSetCoMainEvent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tags = [
      fight.weightClass.label,
      '${fight.rounds} Rounds',
      if (fight.titleFightType != TitleFightType.none) fight.titleFightType.label,
      if (isMainEvent) 'Main Event',
      if (isCoMainEvent) 'Co-Main Event',
    ];

    return Card(
      color: isMainEvent
          ? Theme.of(context).colorScheme.primaryContainer
          : isCoMainEvent
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
      child: ListTile(
        title: Text('${fighterA?.name ?? '?'} vs ${fighterB?.name ?? '?'}'),
        subtitle: Text(tags.join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMainEventControls) ...[
              IconButton(
                icon: Icon(isMainEvent ? Icons.star : Icons.star_border),
                tooltip: 'Set as main event',
                onPressed: onSetMainEvent,
              ),
              IconButton(
                icon: Icon(isCoMainEvent ? Icons.star_half : Icons.star_outline),
                tooltip: 'Set as co-main event',
                onPressed: onSetCoMainEvent,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// One line in a fighter dropdown — name plus the figures that actually
/// decide a matchup, so you're not picking from a list of bare names.
Widget _fighterOption(
  BuildContext context,
  Fighter fighter, {
  WeightClass? bookedAt,
}) {
  final hurt = fighter.injuryStatus != InjuryStatus.healthy;
  // Crossing divisions is worth calling out — it's the player's own
  // decision to move someone, not something to discover afterwards.
  final movement =
      bookedAt == null ? null : fighter.weightClass.movementTo(bookedAt);
  return Row(
    children: [
      if (fighter.isChampion)
        const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(Icons.emoji_events, size: 14),
        ),
      Expanded(child: Text(fighter.name, overflow: TextOverflow.ellipsis)),
      if (movement != null) ...[
        const SizedBox(width: 4),
        Icon(
          movement == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
          size: 13,
          color: Colors.amber,
        ),
        Text(
          fighter.weightClass.label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.amber, fontSize: 11),
        ),
      ],
      const SizedBox(width: 6),
      Text(
        '${fighter.record.display} · OVR ${fighter.overall.round()}'
        '${hurt ? ' · ${fighter.injuryStatus.label}' : ''}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: hurt ? Colors.orange : null,
            ),
      ),
    ],
  );
}

/// Side-by-side comparison of the two booked corners, with the opening
/// line so the player can see at a glance whether they've made a
/// competitive fight or a squash.
class _MatchupPreview extends StatelessWidget {
  final Fighter a;
  final Fighter b;

  const _MatchupPreview({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final odds = OddsCalculator.forFight(a: a, b: b);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(a.name,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                Text('vs', style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                  child: Text(
                    b.name,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    odds.displayA,
                    style: TextStyle(
                      color: odds.aIsFavourite ? scheme.primary : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('ODDS', style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                  child: Text(
                    odds.displayB,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: odds.aIsFavourite ? null : scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _CompareRow(
                label: 'Overall', a: a.overall.round(), b: b.overall.round()),
            _CompareRow(
              label: 'Striking',
              a: a.fightingStats.strikingAverage.round(),
              b: b.fightingStats.strikingAverage.round(),
            ),
            _CompareRow(
              label: 'Grappling',
              a: a.fightingStats.grapplingAverage.round(),
              b: b.fightingStats.grapplingAverage.round(),
            ),
            _CompareRow(
              label: 'Physical',
              a: a.physicalStats.average.round(),
              b: b.physicalStats.average.round(),
            ),
            _CompareRow(
              label: 'Mental',
              a: a.mentalStats.average.round(),
              b: b.mentalStats.average.round(),
            ),
            _CompareRow(label: 'Popularity', a: a.popularity, b: b.popularity),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(a.style.label,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                Expanded(
                  child: Text(
                    b.style.label,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One stat compared across both corners, with the higher side
/// highlighted so an edge is visible without reading the numbers.
class _CompareRow extends StatelessWidget {
  final String label;
  final int a;
  final int b;

  const _CompareRow({required this.label, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    TextStyle? style(bool leads) => TextStyle(
          fontWeight: leads ? FontWeight.bold : FontWeight.normal,
          color: leads ? scheme.primary : null,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('$a', style: style(a > b))),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text('$b', textAlign: TextAlign.end, style: style(b > a)),
          ),
        ],
      ),
    );
  }
}


/// Explains why no fight can be added. Booking needs two healthy, signed,
/// not-already-booked fighters *in the same division* — several different
/// shortfalls land here, and each one needs a different fix.
class _CannotBookNotice extends StatelessWidget {
  final int signedCount;
  final int healthyCount;
  final int alreadyBooked;
  final int suspendedCount;

  const _CannotBookNotice({
    required this.signedCount,
    required this.healthyCount,
    required this.alreadyBooked,
    required this.suspendedCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final String reason;
    if (signedCount == 0) {
      reason = "You haven't signed anyone yet. Head to Roster > Talent Pool, "
          'open a fighter and sign them.';
    } else if (signedCount == 1) {
      reason = 'You have one fighter signed. A fight needs two, and both '
          'must be in the same weight class.';
    } else if (healthyCount < 2 && suspendedCount > 0) {
      reason = suspendedCount == 1
          ? 'One of your fighters is serving a suspension and the rest are '
              "hurt. Suspended fighters can't be booked until their ban runs "
              'out — check the Inbox for the week they return.'
          : '$suspendedCount of your fighters are suspended, and there '
              "aren't two healthy fighters left to make a fight.";
    } else if (healthyCount < 2) {
      reason = 'Too many of your roster are hurt to make a fight. Injured '
          "fighters can't be booked — advance a few weeks to let them heal.";
    } else if (alreadyBooked > 0) {
      reason = 'Everyone left is either already on this card or has nobody '
          'to face at their weight.';
    } else {
      reason = 'No division has two available fighters. A fighter can be '
          'booked at their own weight or one division either side, so sign '
          'someone close in weight to a fighter you already have.';
    }

    return Card(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Can't add a fight yet",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(reason,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
