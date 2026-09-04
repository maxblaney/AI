import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../data/seed/roster_seed.dart';
import '../../../domain/finance/pay_scale.dart';
import '../../../domain/scouting/division_needs.dart';
import '../../state/game_controller.dart';
import '../../widgets/fighter_list_tile.dart';
import 'fighter_editor_screen.dart';
import 'fighter_profile_screen.dart';

enum RosterSortKey {
  name,
  age,
  weightClass,
  wins,
  popularity,
  overall,
  potential,
  askingPrice,
  newest,
}

/// Age bands a scout actually thinks in: someone to build, someone in
/// their prime, someone on the way out.
enum AgeBand { any, prospect, prime, veteran }

extension AgeBandInfo on AgeBand {
  String get label => switch (this) {
        AgeBand.any => 'Any age',
        AgeBand.prospect => 'Under 26',
        AgeBand.prime => '26-32',
        AgeBand.veteran => '33+',
      };

  bool matches(int age) => switch (this) {
        AgeBand.any => true,
        AgeBand.prospect => age < 26,
        AgeBand.prime => age >= 26 && age <= 32,
        AgeBand.veteran => age > 32,
      };
}

extension on RosterSortKey {
  String get label {
    switch (this) {
      case RosterSortKey.name:
        return 'Name';
      case RosterSortKey.age:
        return 'Age';
      case RosterSortKey.weightClass:
        return 'Weight Class';
      case RosterSortKey.wins:
        return 'Record (Wins)';
      case RosterSortKey.popularity:
        return 'Popularity';
      case RosterSortKey.overall:
        return 'Overall';
      case RosterSortKey.potential:
        return 'Potential';
      case RosterSortKey.askingPrice:
        return 'Asking Price';
      case RosterSortKey.newest:
        return 'Recently Arrived';
    }
  }
}

/// What this fighter would cost to put under contract right now — show
/// money, which is charged as the signing bonus. The number a scout is
/// actually shopping against.
int _askingPrice(Fighter fighter) =>
    PayScale.suggest(overall: fighter.overall, popularity: fighter.popularity)
        .showMoney;

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Free text typed into the search box, lower-cased once here rather
  /// than per fighter on every keystroke — the pool is 400 rows.
  String _query = '';

  final Set<String> _nationalityFilter = {};
  WeightClass? _weightClassFilter;
  final Set<FightingStyle> _styleFilter = {};

  /// Scouting filters. They apply to both tabs — narrowing your own
  /// roster by age is a fair question too — but they exist for the
  /// talent pool, which runs past a thousand names on an older save.
  AgeBand _ageBand = AgeBand.any;
  bool _newArrivalsOnly = false;
  bool _affordableOnly = false;

  RosterSortKey _sortKey = RosterSortKey.name;
  bool _sortDescending = false;

  /// How recently a fighter has to have turned up to count as new.
  static const int newArrivalWeeks = 8;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _nationalityFilter.isNotEmpty ||
      _weightClassFilter != null ||
      _styleFilter.isNotEmpty ||
      _ageBand != AgeBand.any ||
      _newArrivalsOnly ||
      _affordableOnly;

  /// Anything at all narrowing the list, search included — drives the
  /// "nothing matched" wording, which has to name the search or it reads
  /// as an empty talent pool.
  bool get _isNarrowed => _hasActiveFilters || _query.isNotEmpty;

  List<Fighter> _apply(
    List<Fighter> fighters, {
    int currentWeek = 1,
    int? cashBalance,
  }) {
    var result = fighters.where((f) {
      if (!_ageBand.matches(f.age)) return false;
      if (_newArrivalsOnly &&
          currentWeek - f.arrivedWeek >= newArrivalWeeks) {
        return false;
      }
      // "Can I actually sign him" is the first question a scout asks and
      // the one the list could never answer — you found out by opening a
      // profile and reading the market rate.
      if (_affordableOnly &&
          cashBalance != null &&
          _askingPrice(f) > cashBalance) {
        return false;
      }
      // Name first, then nationality — typing "brazil" to find Brazilians
      // is a reasonable thing to expect of a search box.
      if (_query.isNotEmpty &&
          !f.name.toLowerCase().contains(_query) &&
          !f.nationality.toLowerCase().contains(_query)) {
        return false;
      }
      if (_nationalityFilter.isNotEmpty &&
          !_nationalityFilter.contains(f.nationality)) {
        return false;
      }
      if (_weightClassFilter != null && f.weightClass != _weightClassFilter) {
        return false;
      }
      if (_styleFilter.isNotEmpty && !_styleFilter.contains(f.style)) {
        return false;
      }
      return true;
    }).toList();

    int compare(Fighter a, Fighter b) {
      switch (_sortKey) {
        case RosterSortKey.name:
          return a.name.compareTo(b.name);
        case RosterSortKey.age:
          return a.age.compareTo(b.age);
        case RosterSortKey.weightClass:
          return a.weightClass.index.compareTo(b.weightClass.index);
        case RosterSortKey.wins:
          return a.record.wins.compareTo(b.record.wins);
        case RosterSortKey.popularity:
          return a.popularity.compareTo(b.popularity);
        case RosterSortKey.overall:
          return a.overall.compareTo(b.overall);
        case RosterSortKey.potential:
          return a.potential.compareTo(b.potential);
        case RosterSortKey.askingPrice:
          return _askingPrice(a).compareTo(_askingPrice(b));
        case RosterSortKey.newest:
          return a.arrivedWeek.compareTo(b.arrivedWeek);
      }
    }

    result.sort(compare);
    if (_sortDescending) result = result.reversed.toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final currentWeek = controller.organization?.currentWeek ?? 1;
    final cash = controller.organization?.cashBalance;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Roster'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onPressed: _showSortSheet,
            ),
            IconButton(
              icon: Icon(
                _hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              tooltip: 'Filter',
              onPressed: _showFilterSheet,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Roster'),
              Tab(text: 'Talent Pool'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Create Fighter'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FighterEditorScreen()),
          ),
        ),
        body: Column(
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
            if (_hasActiveFilters)
              _ActiveFilterBanner(onClear: _clearFilters),
            Expanded(
              child: TabBarView(
                children: [
                  _FighterList(
                    fighters: _apply(controller.signedRoster,
                        currentWeek: currentWeek, cashBalance: cash),
                    total: controller.signedRoster.length,
                    noun: 'signed fighter',
                    emptyText: _isNarrowed
                        ? 'No signed fighters match your search or filters.'
                        : 'No fighters signed yet.',
                  ),
                  Column(
                    children: [
                      // Which divisions can't make a fight, at the top of
                      // the market you'd fix them in. "Sign somebody" is
                      // useless advice against eighteen hundred names;
                      // "you have two lightweights" is not.
                      _ShortageBanner(
                        shortages:
                            DivisionNeeds.shortages(controller.signedRoster),
                        selected: _weightClassFilter,
                        onPick: (division) => setState(() {
                          _weightClassFilter =
                              _weightClassFilter == division ? null : division;
                        }),
                      ),
                      Expanded(
                        child: _FighterList(
                          fighters: _apply(controller.talentPool,
                              currentWeek: currentWeek, cashBalance: cash),
                          total: controller.talentPool.length,
                          noun: 'free agent',
                          currentWeek: currentWeek,
                          showScoutingDetail: true,
                          emptyText: _isNarrowed
                              ? 'No free agents match your search or filters.'
                              : 'No free agents available.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _nationalityFilter.clear();
      _weightClassFilter = null;
      _styleFilter.clear();
      _ageBand = AgeBand.any;
      _newArrivalsOnly = false;
      _affordableOnly = false;
    });
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (final key in RosterSortKey.values)
                RadioListTile<RosterSortKey>(
                  value: key,
                  groupValue: _sortKey,
                  title: Text(key.label),
                  onChanged: (v) {
                    setState(() => _sortKey = v ?? _sortKey);
                    setSheetState(() {});
                  },
                ),
              SwitchListTile(
                title: const Text('Descending'),
                value: _sortDescending,
                onChanged: (v) {
                  setState(() => _sortDescending = v);
                  setSheetState(() {});
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _nationalityFilter.clear();
                        _weightClassFilter = null;
                        _styleFilter.clear();
                        _ageBand = AgeBand.any;
                        _newArrivalsOnly = false;
                        _affordableOnly = false;
                      });
                      setSheetState(() {});
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Weight class first, because it is the filter people
              // actually came here for. It used to sit under the scouting
              // switches, which pushed it below the fold of a sheet that
              // opens at 70% height — so picking Lightweight meant
              // scrolling past three things to find it, and it read as
              // the option having gone missing.
              Text('Weight Class', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _weightClassFilter == null,
                    onSelected: (_) {
                      setState(() => _weightClassFilter = null);
                      setSheetState(() {});
                    },
                  ),
                  for (final w in WeightClass.values)
                    ChoiceChip(
                      label: Text(w.label),
                      selected: _weightClassFilter == w,
                      onSelected: (_) {
                        setState(() => _weightClassFilter = w);
                        setSheetState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Then the scouting filters: questions asked of a market
              // rather than of a person.
              Text('Age', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final band in AgeBand.values)
                    ChoiceChip(
                      label: Text(band.label),
                      selected: _ageBand == band,
                      onSelected: (_) {
                        setState(() => _ageBand = band);
                        setSheetState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('New arrivals only'),
                subtitle: Text(
                  'Turned pro in the last '
                  '${_RosterScreenState.newArrivalWeeks} weeks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: _newArrivalsOnly,
                onChanged: (v) {
                  setState(() => _newArrivalsOnly = v);
                  setSheetState(() {});
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Only what I can afford'),
                subtitle: Text(
                  'Hides anyone whose signing bonus is more than the bank',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: _affordableOnly,
                onChanged: (v) {
                  setState(() => _affordableOnly = v);
                  setSheetState(() {});
                },
              ),
              Text('Style', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in FightingStyle.values)
                    FilterChip(
                      label: Text(s.label),
                      selected: _styleFilter.contains(s),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _styleFilter.add(s);
                          } else {
                            _styleFilter.remove(s);
                          }
                        });
                        setSheetState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Nationality', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final n in knownNationalities)
                    FilterChip(
                      label: Text(n),
                      selected: _nationalityFilter.contains(n),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _nationalityFilter.add(n);
                          } else {
                            _nationalityFilter.remove(n);
                          }
                        });
                        setSheetState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search by name or nationality, sitting above both tabs. The talent
/// pool is 400 fighters deep, and scrolling an alphabetical list of 400
/// to find one man isn't a search — it's a chore.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search by name or nationality',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: 'Clear search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Filters live behind an app-bar icon and apply to *both* tabs, so it's
/// easy to set one on your roster and then wonder where the talent pool
/// went. This says so, with a one-tap way out.
class _ActiveFilterBanner extends StatelessWidget {
  final VoidCallback onClear;

  const _ActiveFilterBanner({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Filters are on — they hide fighters in both tabs.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.primary),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _FighterList extends StatelessWidget {
  final List<Fighter> fighters;

  /// How many exist before searching/filtering, so the count line can
  /// say "12 of 400" and make it obvious the rest are hidden rather
  /// than missing.
  final int total;
  final String noun;
  final String emptyText;

  /// Adds the line a scout is reading for: asking price, potential, and
  /// whether this one has just turned up. Off on your own roster, where
  /// none of it is a question any more.
  final bool showScoutingDetail;
  final int currentWeek;

  const _FighterList({
    required this.fighters,
    required this.total,
    required this.noun,
    required this.emptyText,
    this.showScoutingDetail = false,
    this.currentWeek = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (fighters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyText, textAlign: TextAlign.center),
        ),
      );
    }

    final plural = fighters.length == 1 ? noun : '${noun}s';
    final count = fighters.length == total
        ? '${fighters.length} $plural'
        : '${fighters.length} of $total $plural';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(count, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fighters.length,
            itemBuilder: (context, index) {
              final fighter = fighters[index];
              final tile = FighterListTile(
                fighter: fighter,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FighterProfileScreen(fighterId: fighter.id),
                  ),
                ),
              );
              if (!showScoutingDetail) return tile;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tile,
                  _ScoutingLine(fighter: fighter, currentWeek: currentWeek),
                  const Divider(height: 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The line under a free agent that says whether to bother: what they
/// would cost, how old they are, how far they might still come, and
/// whether they only turned up this month.
///
/// All of it was reachable before — by opening the profile, one fighter
/// at a time, out of a pool past a thousand. Scouting is a comparison,
/// and a comparison you have to make one page at a time isn't one.
class _ScoutingLine extends StatelessWidget {
  final Fighter fighter;
  final int currentWeek;

  const _ScoutingLine({required this.fighter, required this.currentWeek});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(decimalDigits: 0);
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall;
    final isNew =
        currentWeek - fighter.arrivedWeek < _RosterScreenState.newArrivalWeeks;
    // Room left to grow, which is the whole case for signing a 22-year-old
    // over a finished 30-year-old with the same overall today.
    final upside = (fighter.potential - fighter.overall).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'NEW',
                style: small?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          Text('Age ${fighter.age}', style: small),
          Text('OVR ${fighter.overall.round()}', style: small),
          if (upside > 2)
            Text(
              'Upside +$upside',
              style: small?.copyWith(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            '${currency.format(_askingPrice(fighter))} to show',
            style: small?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The divisions that cannot make a fight, above the market you would fix
/// them in. Tapping one filters the pool to it.
class _ShortageBanner extends StatelessWidget {
  final List<({WeightClass division, int count, DivisionNeed need})> shortages;
  final WeightClass? selected;
  final ValueChanged<WeightClass> onPick;

  const _ShortageBanner({
    required this.shortages,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    if (shortages.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    Color colourFor(DivisionNeed need) => switch (need) {
          DivisionNeed.empty => scheme.error,
          DivisionNeed.critical => scheme.error,
          DivisionNeed.thin => Colors.amber,
          DivisionNeed.fine => scheme.onSurfaceVariant,
        };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Short of fighters here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shortages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final s = shortages[i];
                final isSelected = selected == s.division;
                return ActionChip(
                  onPressed: () => onPick(s.division),
                  backgroundColor:
                      isSelected ? scheme.primaryContainer : null,
                  side: BorderSide(color: colourFor(s.need)),
                  label: Text(
                    '${s.division.label} · ${s.count}',
                    style: TextStyle(color: colourFor(s.need)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
