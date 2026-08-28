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

  /// Weight classes with at least 2 unused signed fighters — the only ones
  /// a new fight can be booked in.
  List<WeightClass> _bookableWeightClasses(List<Fighter> roster) {
    return WeightClass.values.where((wc) {
      final count = roster
          .where((f) => f.weightClass == wc && !_usedFighterIds.contains(f.id))
          .length;
      return count >= 2;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final roster = controller.signedRoster
        .where((f) => f.injuryStatus != InjuryStatus.major)
        .toList();
    final bookableClasses = _bookableWeightClasses(roster);
    final currentWeek = controller.organization?.currentWeek ?? 1;
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
          final available = roster
              .where((f) =>
                  f.weightClass == weightClass &&
                  !_usedFighterIds.contains(f.id))
              .toList();

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
                    decoration: const InputDecoration(labelText: 'Fighter A'),
                    items: available
                        .where((f) => f.id != fighterBId)
                        .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (v) => setState(() => fighterAId = v),
                  ),
                  DropdownButtonFormField<String>(
                    value: fighterBId,
                    decoration: const InputDecoration(labelText: 'Fighter B'),
                    items: available
                        .where((f) => f.id != fighterAId)
                        .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (v) => setState(() => fighterBId = v),
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
