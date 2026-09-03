import '../../../domain/betting/fight_odds.dart';
import '../../../domain/booking/card_matchmaker.dart';
import '../../../domain/finance/event_finance_calculator.dart';
import '../../../domain/booking/fight_hype.dart';
import '../../../domain/booking/title_fight_rules.dart';
import '../../../domain/history/head_to_head.dart';
import '../../../domain/history/recent_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';
import '../../theme/app_theme.dart';

class EventBookingScreen extends StatefulWidget {
  /// The scheduled event this screen is editing, or null to book a new
  /// one. A card booked weeks out is a plan rather than a commitment —
  /// fighters get hurt and better matchups turn up — so the same screen
  /// that builds a card reopens it.
  final String? eventId;

  const EventBookingScreen({super.key, this.eventId});

  bool get isEditing => eventId != null;

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

  /// True while an existing event's card is being read back. Without it
  /// the screen would flash an empty card before the real one arrives.
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Fight Night');
    _ticketPriceController =
        TextEditingController(text: '${_venue.suggestedTicketPrice}');
    if (widget.isEditing) {
      _loading = true;
      // After the first frame so the controller can be read from context.
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  /// Fills the form from the event being edited: its name, venue, price,
  /// how far out it sits, and the card exactly as booked — running order,
  /// main event and co-main included.
  Future<void> _loadExisting() async {
    final controller = context.read<GameController>();
    final event = await controller.getEventById(widget.eventId!);
    if (event == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('That event no longer exists.');
      return;
    }
    final card = await controller.getEventCard(event.id);
    if (!mounted) return;
    final currentWeek = controller.organization?.currentWeek ?? 1;
    setState(() {
      _nameController.text = event.name;
      _venue = event.venue;
      _ticketPriceController.text = '${event.ticketPrice}';
      // Editing an existing price is an edit, whoever made it — don't
      // overwrite it the next time the venue changes.
      _ticketPriceEdited = true;
      _weeksFromNow =
          (GameCalendar.weekNumberFor(event.date) - currentWeek).clamp(1, 26);
      _card
        ..clear()
        ..addAll(card..sort((a, b) => a.cardOrder.compareTo(b.cardOrder)));
      _mainEventFightId = _idOfFirst(card, (f) => f.isMainEvent);
      _coMainEventFightId = _idOfFirst(card, (f) => f.isCoMainEvent);
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
  }

  /// The id of the first fight matching [test], or null if none does.
  static String? _idOfFirst(List<Fight> card, bool Function(Fight) test) {
    for (final fight in card) {
      if (test(fight)) return fight.id;
    }
    return null;
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

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Card')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Card' : 'Book Event'),
      ),
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
            // Venue lines are long — name, capacity and rent — and on a
            // phone they ran off the side of the field. Expanded plus an
            // ellipsis keeps the whole row inside the screen.
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Venue'),
            items: Venue.values
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        '${v.label} (cap. ${v.capacity}, \$${v.baseCost})',
                        overflow: TextOverflow.ellipsis,
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
            // setState, not a bare assignment: the ledger below prices
            // the card off this field, so it has to rebuild as the
            // player types.
            onChanged: (_) => setState(() => _ticketPriceEdited = true),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Card', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              // Most of a card is prelims nobody agonises over. This
              // fills the rest of the night in one tap; everything it
              // picks can still be reordered, edited or thrown out.
              TextButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(_card.isEmpty ? 'Auto-fill' : 'Fill rest'),
                onPressed: roster.length - _usedFighterIds.length >= 2
                    ? () => _autoFill(roster)
                    : null,
              ),
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
          // One list for the whole card, dragged by the handle on each
          // bout. The main-card/prelim split is positional, so a single
          // list is the only shape that lets a prelim be promoted by
          // being dragged into the top five — two lists couldn't hand a
          // fight across. The section labels ride on the bouts that open
          // each section, which is why they move with the running order
          // instead of being fixed rows of their own.
          if (_card.isNotEmpty)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: _reorder,
              children: [
                for (var i = 0; i < _card.length; i++)
                  Column(
                    key: ValueKey(_card[i].id),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (i == 0) const _SectionLabel('Main Card'),
                      if (i == Fight.mainCardSize) const _SectionLabel('Prelims'),
                      _buildFightTile(
                        controller,
                        roster,
                        bookableClasses,
                        _card[i],
                        index: i,
                        isMainCardEligible: i < Fight.mainCardSize,
                      ),
                    ],
                  ),
              ],
            ),
          // What this card is expected to make, updated as it is built.
          // The cost of a card is knowable the moment the fighters are
          // picked; before this it wasn't shown until the night had run
          // and the money was already gone.
          if (_card.isNotEmpty && controller.organization != null)
            Builder(builder: (context) {
              final lookup = {
                for (final f in controller.allFighters) f.id: f,
              };
              final price = int.tryParse(_ticketPriceController.text) ??
                  _venue.suggestedTicketPrice;
              return _CardLedger(
                projection: EventFinanceCalculator.project(
                  venue: _venue,
                  ticketPrice: price,
                  organization: controller.organization!,
                  card: _card,
                  fighterLookup: lookup,
                ),
                ticketPrice: price,
                bestPrice: EventFinanceCalculator.bestTicketPrice(
                  venue: _venue,
                  organization: controller.organization!,
                  card: _card,
                  fighterLookup: lookup,
                ),
                onUseBestPrice: (best) => setState(() {
                  _ticketPriceController.text = '$best';
                  _ticketPriceEdited = true;
                }),
                weeklyOverhead: controller.weeklyOverhead,
                cashBalance: controller.organization!.cashBalance,
              );
            }),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _confirm,
            child: _submitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.isEditing ? 'Save Card' : 'Confirm Card'),
          ),
        ],
      ),
    );
  }

  /// Drops the bout dragged from [oldIndex] at [newIndex]. The
  /// main-card/prelim split is positional, so dragging a bout into the
  /// top five promotes it with no extra bookkeeping.
  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      // The framework reports the target index as it was *before* the
      // dragged item was lifted out, so dragging downward is off by one.
      if (newIndex > oldIndex) newIndex -= 1;
      _card.insert(newIndex, _card.removeAt(oldIndex));
    });
  }

  Widget _buildFightTile(
    GameController controller,
    List<Fighter> roster,
    List<WeightClass> bookableClasses,
    Fight fight, {
    required int index,
    required bool isMainCardEligible,
  }) {
    final a = controller.fighterById(fight.fighterAId);
    final b = controller.fighterById(fight.fighterBId);
    return _FightTile(
      fight: fight,
      index: index,
      fighterA: a,
      fighterB: b,
      // Each man's standing in his *own* division, which is the rank he
      // actually carries — a lightweight moving up to welterweight for
      // one night is still the lightweight #2, and that is the fact
      // worth putting on the tile.
      rankA: a == null ? null : controller.divisionRankOf(a),
      rankB: b == null ? null : controller.divisionRankOf(b),
      headToHead: controller.headToHead(fight.fighterAId, fight.fighterBId),
      isMainEvent: fight.id == _mainEventFightId,
      isCoMainEvent: fight.id == _coMainEventFightId,
      showMainEventControls: isMainCardEligible,
      onEdit: () => _showFightDialog(roster, bookableClasses, existing: fight),
      // Tapping the star a second time clears it. Picking the wrong bout
      // for the main event shouldn't be a one-way door — before this the
      // only way out was to keep tapping until it landed somewhere you
      // could live with.
      onSetMainEvent: () => setState(() {
        if (_mainEventFightId == fight.id) {
          _mainEventFightId = null;
          return;
        }
        _mainEventFightId = fight.id;
        if (_coMainEventFightId == fight.id) _coMainEventFightId = null;
      }),
      onSetCoMainEvent: () => setState(() {
        if (_coMainEventFightId == fight.id) {
          _coMainEventFightId = null;
          return;
        }
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

  /// How long a card the auto-filler aims at: a main card of five plus
  /// prelims, which is the shape of a real show.
  static const int _autoFillTarget = 10;

  /// Share of a full house's gate the auto-filler will commit to purses.
  /// Leaves room for the venue, promotion and a night that actually
  /// turns a profit.
  static const double _purseShareOfGate = 0.45;

  /// Fills the card out to [_autoFillTarget] bouts with whoever is
  /// available, leaving anything already booked exactly where it is.
  void _autoFill(List<Fighter> roster) {
    final controller = context.read<GameController>();
    // What the night can plausibly gross, at the room and price the
    // player has actually chosen, times the share of it that sensibly
    // goes to fighters. Booking a card the gate cannot cover is the
    // easiest way to lose money in this game, and an auto-filler that
    // did it by default would be a trap rather than a convenience.
    final ticketPrice =
        int.tryParse(_ticketPriceController.text) ?? _venue.suggestedTicketPrice;
    final org = controller.organization;
    final expectedHeads = org == null
        ? _venue.capacity
        : EventFinanceCalculator.baselineAttendance(
            organization: org,
            venue: _venue,
            ticketPrice: ticketPrice,
          );
    final purseBudget =
        (expectedHeads * ticketPrice * _purseShareOfGate).round();

    final added = CardMatchmaker.build(
      roster: roster,
      bouts: _autoFillTarget - _card.length,
      unavailable: _usedFighterIds,
      purseBudget: purseBudget,
      priorMeetings: controller.priorMeetingsByPair,
    );
    if (added.isEmpty) {
      _showError('Nobody left to match up.');
      return;
    }

    setState(() {
      _card.addAll(added);
      // Only claim the top of the card if the player hasn't already
      // decided who headlines — filling out the prelims shouldn't
      // demote the fight they built the show around.
      _mainEventFightId ??= _card.first.id;
      if (_coMainEventFightId == null && _card.length >= 2) {
        _coMainEventFightId =
            _card.firstWhere((f) => f.id != _mainEventFightId).id;
      }
    });
    _showError('Added ${added.length} '
        'fight${added.length == 1 ? '' : 's'} — reorder or edit any of them.');
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
          // Home division first, then the neighbours a fighter can move
          // to. The roster comes back in the order fighters were
          // generated — division by division — so picking Lightweight
          // used to open on a list of featherweights, with the actual
          // lightweights somewhere below the fold. Whoever is *in* the
          // division being booked is the answer to the question being
          // asked; crossing someone over is a second thought, and it
          // should take a deliberate scroll.
          final available = roster
              .where((f) =>
                  f.weightClass.canFightAt(weightClass) &&
                  !blocked.contains(f.id))
              .toList()
            ..sort((a, b) {
              final homeA = a.weightClass == weightClass ? 0 : 1;
              final homeB = b.weightClass == weightClass ? 0 : 1;
              if (homeA != homeB) return homeA.compareTo(homeB);
              // Then lighter neighbours before heavier ones, so the two
              // visiting groups stay in a fixed order rather than
              // interleaving.
              final byClass = a.weightClass.index.compareTo(b.weightClass.index);
              if (byClass != 0) return byClass;
              // And alphabetical inside a group, because at this point
              // the player is looking for a name.
              return a.name.compareTo(b.name);
            });

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
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Weight Class'),
                    items: classes
                        .map((w) => DropdownMenuItem(
                            value: w,
                            child: Text(w.labelWithLimit,
                                overflow: TextOverflow.ellipsis)))
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
                                bookedAt: weightClass,
                                rank: controller.divisionRankOf(f))))
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
                                bookedAt: weightClass,
                                rank: controller.divisionRankOf(f))))
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
                    isExpanded: true,
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
    final name = _nameController.text.trim().isEmpty
        ? 'Fight Night'
        : _nameController.text.trim();
    final date = GameCalendar.dateForWeek(currentWeek + _weeksFromNow);
    final error = widget.isEditing
        ? await controller.updateEvent(
            eventId: widget.eventId!,
            name: name,
            date: date,
            venue: _venue,
            ticketPrice: ticketPrice,
            card: card,
          )
        : await controller.bookEvent(
            name: name,
            date: date,
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

  /// Position on the card — the drag handle needs it to tell the
  /// reorderable list which row it is starting a drag for.
  final int index;
  final Fighter? fighterA;
  final Fighter? fighterB;

  /// Divisional standing for each corner — 'C', 'iC', a contender
  /// number, or null for unranked.
  final String? rankA;
  final String? rankB;

  /// Whether these two have met here before, and how it went.
  final HeadToHead headToHead;
  final bool isMainEvent;
  final bool isCoMainEvent;
  final bool showMainEventControls;
  final VoidCallback onSetMainEvent;
  final VoidCallback onSetCoMainEvent;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _FightTile({
    required this.fight,
    required this.index,
    required this.fighterA,
    required this.fighterB,
    required this.rankA,
    required this.rankB,
    required this.headToHead,
    required this.isMainEvent,
    required this.isCoMainEvent,
    required this.showMainEventControls,
    required this.onSetMainEvent,
    required this.onSetCoMainEvent,
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

    // The same reading the booking dialog gives, carried onto the card
    // itself: whether this show has a fight worth turning up for is a
    // question about the card as a whole, and answering it one dialog at
    // a time meant reopening every bout to compare them.
    final a = fighterA;
    final b = fighterB;
    final hype = a == null || b == null
        ? null
        : HypeCalculator.forFight(
            a: a,
            b: b,
            titleFightType: fight.titleFightType,
          );

    return Card(
      color: isMainEvent
          ? Theme.of(context).colorScheme.primaryContainer
          : isCoMainEvent
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
      child: Column(
        children: [
          ListTile(
            // Ranks ride on the names themselves rather than a line of
            // their own: "#2 vs #9" underneath two names leaves the
            // player working out which number belongs to whom, and a
            // card is read at a glance or not at all.
            title: Text.rich(
              TextSpan(children: [
                ..._namePart(context, a, rankA),
                const TextSpan(text: ' vs '),
                ..._namePart(context, b, rankB),
              ]),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hype != null) _TileHype(hype: hype),
                Text(tags.join(' · ')),
                if (headToHead.isRematch && a != null && b != null)
                  _RematchLine(
                    headToHead: headToHead,
                    nameA: a.name,
                    nameB: b.name,
                  ),
              ],
            ),
            // Tapping the bout opens it for editing — the same reflex as
            // tapping anything else in a list.
            onTap: onEdit,
            // Position on the card *is* the running order, so dragging a
            // bout above the fifth slot promotes it to the main card.
            trailing: ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Tooltip(
                  message: 'Drag to reorder the card',
                  child: Icon(Icons.drag_handle),
                ),
              ),
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
                    tooltip: isMainEvent
                        ? 'Not the main event after all'
                        : 'Set as main event',
                    onPressed: onSetMainEvent,
                  ),
                  IconButton(
                    icon: Icon(
                        isCoMainEvent ? Icons.star_half : Icons.star_outline),
                    tooltip: isCoMainEvent
                        ? 'Not the co-main event after all'
                        : 'Set as co-main event',
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

/// The running money on a card being built: what it should gross, what
/// it will cost, and what that leaves.
///
/// Deliberately plain arithmetic rather than a verdict. The projection
/// has no luck roll in it and the gate is a model, not a promise, so the
/// job here is to let a player see a card that cannot pay for itself
/// *before* they run it — not to tell them what to book.
class _CardLedger extends StatelessWidget {
  final EventProjection projection;
  final int ticketPrice;

  /// What this card would take the most at, in this room. Differs from
  /// the venue's own suggestion, which knows nothing about how big the
  /// promotion asking has become.
  final int bestPrice;
  final ValueChanged<int> onUseBestPrice;
  final int weeklyOverhead;
  final int cashBalance;

  const _CardLedger({
    required this.projection,
    required this.ticketPrice,
    required this.bestPrice,
    required this.onUseBestPrice,
    required this.weeklyOverhead,
    required this.cashBalance,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(decimalDigits: 0);
    final scheme = Theme.of(context).colorScheme;
    final net = projection.net;
    final losing = net < 0;
    final share = (projection.purseShareOfRevenue * 100).round();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: losing
          ? scheme.errorContainer.withOpacity(0.35)
          : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  losing ? Icons.warning_amber : Icons.savings_outlined,
                  size: 18,
                  color: losing ? scheme.error : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  losing ? 'This card loses money' : 'Projected for this card',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: losing ? scheme.error : null,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _LedgerRow(
              label: 'Gate (~${projection.attendance} in)',
              value: currency.format(projection.ticketRevenue),
            ),
            if (projection.ppvRevenue > 0)
              _LedgerRow(
                label: 'PPV',
                value: currency.format(projection.ppvRevenue),
              ),
            _LedgerRow(
              label: 'Purses ($share% of gross)',
              value: '-${currency.format(projection.purses)}',
              // Fighter pay is the one line the player controls bout by
              // bout, so it is the one worth colouring when it runs away.
              emphasise: share > 60,
            ),
            _LedgerRow(
              label: 'Venue',
              value: '-${currency.format(projection.venueCost)}',
            ),
            // Turning people away is not a triumph — it is the room
            // telling you the ticket is underpriced.
            if (projection.soldOut)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.local_activity_outlined,
                        size: 15, color: Colors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Selling out — about '
                        '${projection.uncappedAttendance - projection.attendance} '
                        'more would come than the room holds.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            if (bestPrice != ticketPrice)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        bestPrice > ticketPrice
                            ? 'This card takes the most at '
                                '${currency.format(bestPrice)} a ticket.'
                            : 'A cheaper ticket takes more here: '
                                '${currency.format(bestPrice)}.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onUseBestPrice(bestPrice),
                      child: const Text('Use it'),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16),
            _LedgerRow(
              label: 'Net',
              value: '${net < 0 ? '-' : ''}${currency.format(net.abs())}',
              bold: true,
              emphasise: losing,
            ),
            const SizedBox(height: 6),
            Text(
              'Cash ${currency.format(cashBalance)} · '
              'overheads ${currency.format(weeklyOverhead)}/wk run whether '
              'or not you put a show on.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            Text(
              'A projection, not a promise — the real gate swings about '
              '15% either way.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool emphasise;

  const _LedgerRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.emphasise = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = (bold
            ? Theme.of(context).textTheme.titleSmall
            : Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(color: emphasise ? scheme.error : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// One corner's name on a card tile, with its divisional standing worn
/// in front of it the way a fight poster writes it: "#3 Femi Adeleke",
/// "C Michal Szymanski".
///
/// Returned as spans rather than a widget so both corners sit in one
/// paragraph and wrap as a single line of text — two Rows would break
/// "vs" onto its own line on a narrow phone.
List<InlineSpan> _namePart(BuildContext context, Fighter? fighter, String? rank) {
  final name = fighter?.name ?? '?';
  if (rank == null) return [TextSpan(text: name)];

  final isBelt = rank == 'C' || rank == 'iC';
  return [
    TextSpan(
      text: isBelt ? '$rank ' : '#$rank ',
      style: TextStyle(
        color: isBelt
            ? (rank == 'C' ? AppColors.belt : AppColors.beltInterim)
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
    ),
    TextSpan(text: name),
  ];
}

/// The "you've run this one before" line on a card tile.
///
/// Deliberately louder than the tags beside it: booking a rematch by
/// accident is one of the few genuinely bad cards a player can put
/// together, and this is the only place the game gets to say so before
/// the fight is confirmed.
class _RematchLine extends StatelessWidget {
  final HeadToHead headToHead;
  final String nameA;
  final String nameB;

  const _RematchLine({
    required this.headToHead,
    required this.nameA,
    required this.nameB,
  });

  @override
  Widget build(BuildContext context) {
    // Surnames only — the full names are already on the line above, and
    // the series line has to share a tile with everything else.
    String last(String name) => name.split(' ').last;
    final summary = headToHead.summary(last(nameA), last(nameB));

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const Icon(Icons.replay, size: 13, color: Colors.amber),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              summary.isEmpty
                  ? headToHead.label
                  : '${headToHead.label} · $summary',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hype reading on a card tile: a short bar, the score, and the band
/// it falls in. Compact on purpose — the full breakdown of what is
/// driving it lives in the booking dialog; this is here to be scanned
/// down a card.
class _TileHype extends StatelessWidget {
  final FightHype hype;

  const _TileHype({required this.hype});

  @override
  Widget build(BuildContext context) {
    final color = _hypeColor(hype.score);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: hype.score / 100,
                minHeight: 5,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.18),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Hype ${hype.score} · ${hype.label}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
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
  String? rank,
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
      // Contenders are picked by number as much as by name, so the
      // ladder position belongs in the list you pick from and not only
      // in the preview underneath it.
      if (rank != null && rank != 'C' && rank != 'iC')
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            '#$rank',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
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
    final h2h = controller.headToHead(a.id, b.id);
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
            // Whether the player is about to run something they've
            // already run. Better learned in the dialog, before the bout
            // is added, than off the tile afterwards.
            if (h2h.isRematch) ...[
              const SizedBox(height: 6),
              _RematchLine(headToHead: h2h, nameA: a.name, nameB: b.name),
            ],
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
            // "Decent Scrap" is the longest band, and inside a dialog on
            // a narrow phone it was pushing the score off the row.
            Flexible(
              child: Text(
                hype.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
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
