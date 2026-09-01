import '../../../domain/betting/fight_odds.dart';
import '../../../domain/booking/fight_hype.dart';
import '../../../domain/booking/title_fight_rules.dart';
import '../../../domain/history/recent_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';
import '../../theme/app_theme.dart';

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

  /// Which division a new fight should open on: the first one that has
  /// two fighters who actually *fight* there. Allowing a fighter to cross
  /// one division makes the neighbouring weights bookable too, so without
  /// this the dialog could open on a class nobody on the card belongs to
  /// — two lightweights defaulting into a featherweight bout, with a
  /// lightweight champion no longer defending anything.
  WeightClass _defaultWeightClass(
    List<Fighter> roster,
    List<WeightClass> classes,
  ) {
    for (final weightClass in classes) {
      final athome = roster
          .where((f) =>
              f.weightClass == weightClass && !_usedFighterIds.contains(f.id))
          .length;
      if (athome >= 2) return weightClass;
    }
    return classes.first;
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
                    ? () => _showFightDialog(roster, bookableClasses)
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
            for (final fight in mainCard)
              _buildFightTile(controller, roster, bookableClasses, fight,
                  isMainCardEligible: true),
          ],
          if (prelims.isNotEmpty) ...[
            const _SectionLabel('Prelims'),
            for (final fight in prelims)
              _buildFightTile(controller, roster, bookableClasses, fight,
                  isMainCardEligible: false),
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

  /// Moves [fight] [delta] places up (-1) or down (+1) the card. The
  /// main-card/prelim split is positional, so moving a bout into the top
  /// five promotes it without any extra bookkeeping.
  void _move(Fight fight, int delta) {
    final from = _card.indexOf(fight);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= _card.length) return;
    setState(() {
      _card.removeAt(from);
      _card.insert(to, fight);
    });
  }

  Widget _buildFightTile(
    GameController controller,
    List<Fighter> roster,
    List<WeightClass> bookableClasses,
    Fight fight, {
    required bool isMainCardEligible,
  }) {
    final index = _card.indexOf(fight);
    return _FightTile(
      fight: fight,
      fighterA: controller.fighterById(fight.fighterAId),
      fighterB: controller.fighterById(fight.fighterBId),
      isMainEvent: fight.id == _mainEventFightId,
      isCoMainEvent: fight.id == _coMainEventFightId,
      showMainEventControls: isMainCardEligible,
      canMoveUp: index > 0,
      canMoveDown: index >= 0 && index < _card.length - 1,
      onMoveUp: () => _move(fight, -1),
      onMoveDown: () => _move(fight, 1),
      onEdit: () => _showFightDialog(roster, bookableClasses, existing: fight),
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

  /// Adds a fight, or edits [existing] in place — same dialog either
  /// way, because a booked matchup is exactly the thing you most want to
  /// change your mind about.
  void _showFightDialog(
    List<Fighter> roster,
    List<WeightClass> bookableClasses, {
    Fight? existing,
  }) {
    final editing = existing != null;
    // Grabbed from the screen's own context: the dialog route sits
    // beside this subtree, not under it, so the preview can't look the
    // controller up for itself once it's open.
    final controller = context.read<GameController>();
    // When editing, the fight's own two corners aren't "used" as far as
    // this dialog is concerned — otherwise you couldn't keep either of
    // them.
    final blocked = {..._usedFighterIds};
    if (editing) {
      blocked.remove(existing.fighterAId);
      blocked.remove(existing.fighterBId);
    }

    // An edited fight's own division stays offered even if it wouldn't
    // qualify with both corners taken out of the pool.
    final classes = <WeightClass>{
      ...bookableClasses,
      if (editing) existing.weightClass,
    }.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    WeightClass weightClass =
        editing ? existing.weightClass : _defaultWeightClass(roster, classes);
    String? fighterAId = editing ? existing.fighterAId : null;
    String? fighterBId = editing ? existing.fighterBId : null;
    int rounds = editing ? existing.rounds : 3;
    TitleFightType titleFightType =
        editing ? existing.titleFightType : TitleFightType.none;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final available = roster
              .where((f) =>
                  f.weightClass.canFightAt(weightClass) &&
                  !blocked.contains(f.id))
              .toList();

          Fighter? cornerOf(String? id) {
            if (id == null) return null;
            for (final f in available) {
              if (f.id == id) return f;
            }
            return null;
          }

          // A champion in his own division is defending, whatever the
          // matchmaker picked — so the control locks and says why.
          final forcedTitle = TitleFightRules.forcedType(
            a: cornerOf(fighterAId),
            b: cornerOf(fighterBId),
            division: weightClass,
          );
          final titleReason = TitleFightRules.explain(
            a: cornerOf(fighterAId),
            b: cornerOf(fighterBId),
            division: weightClass,
          );
          final effectiveTitle = forcedTitle ?? titleFightType;

          return AlertDialog(
            title: Text(editing ? 'Edit Fight' : 'Add Fight'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<WeightClass>(
                    value: weightClass,
                    decoration: const InputDecoration(labelText: 'Weight Class'),
                    items: classes
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
                      controller: controller,
                      a: available.firstWhere((f) => f.id == fighterAId),
                      b: available.firstWhere((f) => f.id == fighterBId),
                      titleFightType: effectiveTitle,
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
                    value: effectiveTitle,
                    decoration: InputDecoration(
                      labelText: 'Title Implications',
                      helperText: titleReason,
                      helperMaxLines: 3,
                    ),
                    items: TitleFightType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    // Locked when a belt is already in the room.
                    onChanged: forcedTitle != null
                        ? null
                        : (v) =>
                            setState(() => titleFightType = v ?? titleFightType),
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
                          final updated = Fight(
                            id: editing ? existing.id : newId(),
                            eventId: '',
                            fighterAId: fighterAId!,
                            fighterBId: fighterBId!,
                            weightClass: weightClass,
                            rounds: rounds,
                            titleFightType: effectiveTitle,
                            cardOrder: editing
                                ? existing.cardOrder
                                : _card.length,
                          );
                          if (editing) {
                            // Replace in place so the bout keeps its slot
                            // on the card, and its main-event flag with it.
                            _card[_card.indexOf(existing)] = updated;
                          } else {
                            _card.add(updated);
                          }
                        });
                        Navigator.of(dialogContext).pop();
                      }
                    : null,
                child: Text(editing ? 'Save' : 'Add'),
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
    final controller = context.read<GameController>();

    final card = [
      for (var i = 0; i < _card.length; i++)
        _card[i].copyWith(
          isMainEvent: _card[i].id == _mainEventFightId,
          isCoMainEvent: _card[i].id == _coMainEventFightId,
          cardOrder: i,
          // Belt-checked once more on the way out. The dialog already
          // locks it, but a fighter can win a title between this card
          // being built and confirmed, and a champion's home fight is a
          // title fight whether or not anyone remembered to say so.
          titleFightType: TitleFightRules.resolve(
            a: controller.fighterById(_card[i].fighterAId),
            b: controller.fighterById(_card[i].fighterBId),
            division: _card[i].weightClass,
            chosen: _card[i].titleFightType,
          ),
        ),
    ];
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
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onSetMainEvent;
  final VoidCallback onSetCoMainEvent;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _FightTile({
    required this.fight,
    required this.fighterA,
    required this.fighterB,
    required this.isMainEvent,
    required this.isCoMainEvent,
    required this.showMainEventControls,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onSetMainEvent,
    required this.onSetCoMainEvent,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
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
      child: Column(
        children: [
          ListTile(
            title: Text('${fighterA?.name ?? '?'} vs ${fighterB?.name ?? '?'}'),
            subtitle: Text(tags.join(' · ')),
            // Tapping the bout opens it for editing — the same reflex as
            // tapping anything else in a list.
            onTap: onEdit,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Position on the card *is* the running order, so moving a
                // bout up past the fifth slot promotes it to the main card.
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  tooltip: 'Move up the card',
                  onPressed: canMoveUp ? onMoveUp : null,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  tooltip: 'Move down the card',
                  onPressed: canMoveDown ? onMoveDown : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showMainEventControls) ...[
                  IconButton(
                    icon: Icon(isMainEvent ? Icons.star : Icons.star_border),
                    tooltip: 'Set as main event',
                    onPressed: onSetMainEvent,
                  ),
                  IconButton(
                    icon: Icon(
                        isCoMainEvent ? Icons.star_half : Icons.star_outline),
                    tooltip: 'Set as co-main event',
                    onPressed: onSetCoMainEvent,
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit this fight',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove from the card',
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ],
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
          child: Icon(Icons.emoji_events, size: 14, color: AppColors.belt),
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
class _MatchupPreview extends StatefulWidget {
  /// Passed in rather than read from context — this widget lives inside
  /// a dialog route, which is not a descendant of the screen's provider.
  final GameController controller;
  final Fighter a;
  final Fighter b;

  /// Feeds the hype reading — a belt on the line changes how big the
  /// fight is, so the bar has to move when the player sets it.
  final TitleFightType titleFightType;

  const _MatchupPreview({
    required this.controller,
    required this.a,
    required this.b,
    this.titleFightType = TitleFightType.none,
  });

  @override
  State<_MatchupPreview> createState() => _MatchupPreviewState();
}

class _MatchupPreviewState extends State<_MatchupPreview> {
  /// Recent form comes from the database, and the dialog rebuilds on
  /// every control the player touches — so the query is fired once per
  /// pair of corners and held, rather than on each rebuild.
  Future<List<List<FormEntry>>>? _form;
  String? _loadedFor;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void didUpdateWidget(_MatchupPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadForm();
  }

  void _loadForm() {
    final key = '${widget.a.id}|${widget.b.id}';
    if (key == _loadedFor) return;
    _loadedFor = key;
    final controller = widget.controller;
    _form = Future.wait([
      controller.getRecentForm(widget.a.id),
      controller.getRecentForm(widget.b.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.a;
    final b = widget.b;
    final titleFightType = widget.titleFightType;
    final controller = widget.controller;
    final odds = OddsCalculator.forFight(a: a, b: b);
    final hype = HypeCalculator.forFight(
      a: a,
      b: b,
      titleFightType: titleFightType,
    );
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
            // Where each man stands in his own division — a #2 against a
            // #9 is a very different fight from the records alone.
            Row(
              children: [
                Expanded(
                  child: _RankBadge(
                    label: controller.divisionRankOf(a),
                    division: a.weightClass,
                  ),
                ),
                Text('RANK', style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                  child: _RankBadge(
                    label: controller.divisionRankOf(b),
                    division: b.weightClass,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Last five, newest first. A record hides a slide; this
            // doesn't.
            FutureBuilder<List<List<FormEntry>>>(
              future: _form,
              builder: (context, snapshot) {
                final forms = snapshot.data;
                return Row(
                  children: [
                    Expanded(child: _FormLine(entries: forms?[0])),
                    Text('LAST 5',
                        style: Theme.of(context).textTheme.bodySmall),
                    Expanded(
                      child: _FormLine(entries: forms?[1], alignEnd: true),
                    ),
                  ],
                );
              },
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
            _HypeMeter(hype: hype),
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

/// A fighter's standing in his own division: 'C' for the champion, 'iC'
/// for an interim one, '#4' for a contender, or "Unranked" for someone
/// who hasn't fought for the promotion yet.
class _RankBadge extends StatelessWidget {
  final String? label;
  final WeightClass division;
  final bool alignEnd;

  const _RankBadge({
    required this.label,
    required this.division,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    final rank = label;

    if (rank == null) {
      return Text(
        'Unranked',
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: small?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final isBelt = rank == 'C' || rank == 'iC';
    return Text(
      isBelt
          ? '$rank · ${division.label}'
          : '#$rank ${division.label}',
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: small?.copyWith(
        color: isBelt
            ? (rank == 'C' ? AppColors.belt : AppColors.beltInterim)
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isBelt ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

/// The last five results as W/L/D chips, newest first, with the span's
/// own record beside them.
///
/// Newest first because that is the question being asked — not "what has
/// this man done", which the record already answers, but "what has he
/// done *lately*".
class _FormLine extends StatelessWidget {
  final List<FormEntry>? entries;
  final bool alignEnd;

  const _FormLine({required this.entries, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final form = entries;
    final small = Theme.of(context).textTheme.bodySmall;

    if (form == null) {
      // Still loading — hold the row's height so the dialog doesn't jump.
      return const SizedBox(height: 18);
    }
    if (form.isEmpty) {
      return SizedBox(
        height: 18,
        child: Align(
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            'No fights here yet',
            style: small?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final chips = [
      for (final entry in form)
        Tooltip(
          message: entry.methodLabel,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 15,
            height: 15,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _formColor(entry.result).withOpacity(0.22),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              entry.result.letter,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: FontWeight.bold,
                color: _formColor(entry.result),
              ),
            ),
          ),
        ),
    ];

    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [
              Text(RecentForm.summarise(form), style: small),
              const SizedBox(width: 4),
              // Newest first still reads right-to-left on this side, so
              // the most recent fight sits nearest the fighter's name.
              ...chips.reversed,
            ]
          : [
              ...chips,
              const SizedBox(width: 4),
              Text(RecentForm.summarise(form), style: small),
            ],
    );
  }
}

Color _formColor(FormResult result) => switch (result) {
      FormResult.win => Colors.green,
      FormResult.loss => Colors.redAccent,
      FormResult.draw => Colors.blueGrey,
    };

/// How big a fight this is, as a bar. Booking on stats alone tells you
/// who wins; this tells you whether anyone wants to watch — which is the
/// promoter's actual job. The breakdown underneath says *why*, so a
/// short bar is a prompt to fix something rather than a mystery.
class _HypeMeter extends StatelessWidget {
  final FightHype hype;

  const _HypeMeter({required this.hype});

  @override
  Widget build(BuildContext context) {
    final color = _hypeColor(hype.score);
    final weakness = hype.weakestLink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('HYPE', style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Text(
              hype.label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text('${hype.score}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: hype.score / 100,
            minHeight: 8,
            backgroundColor: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withOpacity(0.18),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        // The four things that sell a fight, so the player can see which
        // one is letting this matchup down.
        Row(
          children: [
            _HypeFactor(label: 'Stars', value: hype.starPower),
            _HypeFactor(label: 'Even', value: hype.competitiveness),
            _HypeFactor(label: 'Violence', value: hype.violence),
            _HypeFactor(label: 'Stakes', value: hype.stakes),
          ],
        ),
        if (weakness != null) ...[
          const SizedBox(height: 6),
          Text(
            'Holding it back: $weakness.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

/// Cold red through hot amber — a glance at the colour should read the
/// same way as the number.
Color _hypeColor(int score) {
  if (score >= 80) return Colors.amber;
  if (score >= 64) return Colors.orangeAccent;
  if (score >= 48) return Colors.lightGreen;
  if (score >= 30) return Colors.blueGrey;
  return Colors.grey;
}

/// One contributing factor, as a short labelled sub-bar.
class _HypeFactor extends StatelessWidget {
  final String label;
  final int value;

  const _HypeFactor({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 10),
            ),
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 4,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.18),
                valueColor:
                    AlwaysStoppedAnimation<Color>(_hypeColor(value)),
              ),
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
