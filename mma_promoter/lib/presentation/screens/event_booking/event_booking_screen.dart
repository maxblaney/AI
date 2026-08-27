import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../state/game_controller.dart';

class EventBookingScreen extends StatefulWidget {
  const EventBookingScreen({super.key});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ticketPriceController;
  DateTime _date = DateTime.now().add(const Duration(days: 14));
  Venue _venue = Venue.regionalUsa;
  bool _ticketPriceEdited = false;
  final List<Fight> _card = [];
  String? _mainEventFightId;
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final roster = controller.signedRoster
        .where((f) => f.injuryStatus != InjuryStatus.major)
        .toList();

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
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat.yMMMd().format(_date)),
            trailing: const Icon(Icons.edit_calendar),
            onTap: _pickDate,
          ),
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
                onPressed: roster.length - _usedFighterIds.length >= 2
                    ? () => _addFight(roster)
                    : null,
              ),
            ],
          ),
          if (_card.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No fights added yet.'),
            ),
          for (final fight in _card) _FightTile(
            fight: fight,
            fighterA: controller.fighterById(fight.fighterAId),
            fighterB: controller.fighterById(fight.fighterBId),
            isMainEvent: fight.id == _mainEventFightId,
            onSetMainEvent: () => setState(() => _mainEventFightId = fight.id),
            onRemove: () => setState(() {
              _card.remove(fight);
              if (_mainEventFightId == fight.id) _mainEventFightId = null;
            }),
          ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addFight(List<Fighter> roster) {
    final available =
        roster.where((f) => !_usedFighterIds.contains(f.id)).toList();
    String? fighterAId;
    String? fighterBId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          // Fights are matched within a single weight class — once one
          // side is picked, the other dropdown locks to that division.
          WeightClass? lockedClass;
          if (fighterAId != null) {
            lockedClass =
                available.firstWhere((f) => f.id == fighterAId).weightClass;
          } else if (fighterBId != null) {
            lockedClass =
                available.firstWhere((f) => f.id == fighterBId).weightClass;
          }

          final optionsForA = available
              .where((f) => f.id != fighterBId)
              .where((f) => lockedClass == null || f.weightClass == lockedClass)
              .toList();
          final optionsForB = available
              .where((f) => f.id != fighterAId)
              .where((f) => lockedClass == null || f.weightClass == lockedClass)
              .toList();

          return AlertDialog(
            title: const Text('Add Fight'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lockedClass != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      lockedClass.labelWithLimit,
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: fighterAId,
                  decoration: const InputDecoration(labelText: 'Fighter A'),
                  items: optionsForA
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                      .toList(),
                  onChanged: (v) => setState(() => fighterAId = v),
                ),
                DropdownButtonFormField<String>(
                  value: fighterBId,
                  decoration: const InputDecoration(labelText: 'Fighter B'),
                  items: optionsForB
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                      .toList(),
                  onChanged: (v) => setState(() => fighterBId = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: fighterAId != null && fighterBId != null
                    ? () {
                        final a = roster.firstWhere((f) => f.id == fighterAId);
                        this.setState(() {
                          _card.add(Fight(
                            id: newId(),
                            eventId: '',
                            fighterAId: fighterAId!,
                            fighterBId: fighterBId!,
                            weightClass: a.weightClass,
                            isTitleFight: false,
                            isMainEvent: false,
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
          cardOrder: i,
        ),
    ];

    final controller = context.read<GameController>();
    final error = await controller.bookEvent(
      name: _nameController.text.trim().isEmpty
          ? 'Fight Night'
          : _nameController.text.trim(),
      date: _date,
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

class _FightTile extends StatelessWidget {
  final Fight fight;
  final Fighter? fighterA;
  final Fighter? fighterB;
  final bool isMainEvent;
  final VoidCallback onSetMainEvent;
  final VoidCallback onRemove;

  const _FightTile({
    required this.fight,
    required this.fighterA,
    required this.fighterB,
    required this.isMainEvent,
    required this.onSetMainEvent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isMainEvent
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        title: Text('${fighterA?.name ?? '?'} vs ${fighterB?.name ?? '?'}'),
        subtitle: Text(
          '${fight.weightClass.label}'
          '${isMainEvent ? ' · Main Event' : ' · Undercard'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isMainEvent ? Icons.star : Icons.star_border),
              tooltip: 'Set as main event',
              onPressed: onSetMainEvent,
            ),
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
