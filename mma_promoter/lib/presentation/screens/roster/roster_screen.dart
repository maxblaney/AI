import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../data/seed/roster_seed.dart';
import '../../state/game_controller.dart';
import '../../widgets/fighter_list_tile.dart';
import 'fighter_editor_screen.dart';
import 'fighter_profile_screen.dart';

enum RosterSortKey { name, age, weightClass, wins, popularity, overall }

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
    }
  }
}

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
  RosterSortKey _sortKey = RosterSortKey.name;
  bool _sortDescending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _nationalityFilter.isNotEmpty ||
      _weightClassFilter != null ||
      _styleFilter.isNotEmpty;

  /// Anything at all narrowing the list, search included — drives the
  /// "nothing matched" wording, which has to name the search or it reads
  /// as an empty talent pool.
  bool get _isNarrowed => _hasActiveFilters || _query.isNotEmpty;

  List<Fighter> _apply(List<Fighter> fighters) {
    var result = fighters.where((f) {
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
      }
    }

    result.sort(compare);
    if (_sortDescending) result = result.reversed.toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

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
                    fighters: _apply(controller.signedRoster),
                    total: controller.signedRoster.length,
                    noun: 'signed fighter',
                    emptyText: _isNarrowed
                        ? 'No signed fighters match your search or filters.'
                        : 'No fighters signed yet.',
                  ),
                  _FighterList(
                    fighters: _apply(controller.talentPool),
                    total: controller.talentPool.length,
                    noun: 'free agent',
                    emptyText: _isNarrowed
                        ? 'No free agents match your search or filters.'
                        : 'No free agents available.',
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
                      });
                      setSheetState(() {});
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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

  const _FighterList({
    required this.fighters,
    required this.total,
    required this.noun,
    required this.emptyText,
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
              return FighterListTile(
                fighter: fighter,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FighterProfileScreen(fighterId: fighter.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
