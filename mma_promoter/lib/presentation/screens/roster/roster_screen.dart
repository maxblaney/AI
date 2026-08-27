import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../data/seed/roster_seed.dart';
import '../../state/game_controller.dart';
import '../../widgets/fighter_list_tile.dart';
import 'fighter_editor_screen.dart';
import 'fighter_profile_screen.dart';

enum RosterSortKey { name, age, weightClass, wins, popularity }

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
    }
  }
}

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final Set<String> _nationalityFilter = {};
  WeightClass? _weightClassFilter;
  final Set<FightingStyle> _styleFilter = {};
  RosterSortKey _sortKey = RosterSortKey.name;
  bool _sortDescending = false;

  bool get _hasActiveFilters =>
      _nationalityFilter.isNotEmpty ||
      _weightClassFilter != null ||
      _styleFilter.isNotEmpty;

  List<Fighter> _apply(List<Fighter> fighters) {
    var result = fighters.where((f) {
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
        body: TabBarView(
          children: [
            _FighterList(
              fighters: _apply(controller.signedRoster),
              emptyText: _hasActiveFilters
                  ? 'No signed fighters match these filters.'
                  : 'No fighters signed yet.',
            ),
            _FighterList(
              fighters: _apply(controller.talentPool),
              emptyText: _hasActiveFilters
                  ? 'No free agents match these filters.'
                  : 'No free agents available.',
            ),
          ],
        ),
      ),
    );
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

class _FighterList extends StatelessWidget {
  final List<Fighter> fighters;
  final String emptyText;

  const _FighterList({required this.fighters, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (fighters.isEmpty) {
      return Center(child: Text(emptyText));
    }
    return ListView.builder(
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
    );
  }
}
