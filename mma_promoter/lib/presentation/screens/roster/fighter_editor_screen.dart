import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/roster_seed.dart';
import '../../../domain/cosmetics/fighter_headshots.dart';
import '../../../domain/cosmetics/headshot_catalog.dart';
import '../../state/game_controller.dart';
import '../../theme/app_theme.dart';

const List<(String, String)> _strikingStatFields = [
  ('punching', 'Punching'),
  ('kicking', 'Kicking'),
  ('power', 'Power'),
  ('speed', 'Speed'),
  ('accuracy', 'Accuracy'),
  ('defense', 'Defense'),
  ('headMovement', 'Head Movement'),
  ('blocking', 'Blocking / Checks'),
  ('footwork', 'Footwork'),
];

const List<(String, String)> _grapplingStatFields = [
  ('takedowns', 'Takedowns'),
  ('takedownDefense', 'Takedown Defense'),
  ('wrestling', 'Wrestling'),
  ('clinchStriking', 'Clinch Striking'),
  ('clinchControl', 'Clinch Control'),
  ('clinchDefense', 'Clinch Defense'),
  ('topControl', 'Top Control'),
  ('groundAndPound', 'Ground & Pound'),
  ('guardRetention', 'Guard Retention'),
  ('sweeps', 'Sweeps'),
  ('scrambling', 'Scrambling'),
  ('submissionOffense', 'Submission Offense'),
  ('submissionDefense', 'Submission Defense'),
  ('grappling', 'Grappling'),
];

const List<(String, String)> _fightingStatFields = [
  ..._strikingStatFields,
  ..._grapplingStatFields,
];

const List<(String, String)> _physicalStatFields = [
  ('cardio', 'Cardio'),
  ('durability', 'Durability'),
  ('chin', 'Chin'),
  ('bodyToughness', 'Body Toughness'),
  ('legToughness', 'Leg Toughness'),
  ('strength', 'Strength'),
  ('athleticism', 'Athleticism'),
  ('recovery', 'Recovery'),
  ('explosiveness', 'Explosiveness'),
  ('flexibility', 'Flexibility'),
  ('gripStrength', 'Grip Strength'),
];

const List<(String, String)> _mentalStatFields = [
  ('fightIq', 'Fight IQ'),
  ('composure', 'Composure'),
  ('aggression', 'Aggression'),
  ('discipline', 'Discipline'),
  ('confidence', 'Confidence'),
  ('heart', 'Heart'),
  ('adaptability', 'Adaptability'),
  ('killerInstinct', 'Killer Instinct'),
];

const List<(String, String)> _tendencyFields = [
  ('strikingFrequency', 'Striking Frequency'),
  ('takedownFrequency', 'Takedown Frequency'),
  ('kickFrequency', 'Kick Frequency'),
  ('clinchFrequency', 'Clinch Frequency'),
  ('submissionAttempts', 'Submission Attempts'),
  ('groundAndPound', 'Ground & Pound'),
  ('positionControl', 'Position Control'),
  ('standUpPreference', 'Stand-Up Preference'),
  ('wallWork', 'Wall Work'),
  ('aggression', 'Aggression'),
  ('counterStriking', 'Counter Striking'),
  ('headHunting', 'Head Hunting'),
  ('bodyAttacks', 'Body Attacks'),
  ('legAttacks', 'Leg Attacks'),
];

/// Create-from-scratch and edit-existing share this one form. In edit mode
/// the fighter's id, Elo rating, ranked/retired status, award counts and
/// contract are preserved untouched — everything else, including record
/// and weight class, can be changed.
class FighterEditorScreen extends StatefulWidget {
  final Fighter? existingFighter;

  const FighterEditorScreen({super.key, this.existingFighter});

  @override
  State<FighterEditorScreen> createState() => _FighterEditorScreenState();
}

class _FighterEditorScreenState extends State<FighterEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _nameController;
  late int _age;
  late String _nationality;
  late WeightClass _weightClass;
  late FightingStyle _style;
  late int _heightInches;
  late int _weightLbs;
  late int _reachInches;
  late int _wins;
  late int _losses;
  late int _draws;
  late int _popularity;
  late int _potential;
  late final Map<String, int> _fighting;
  late final Map<String, int> _physical;
  late final Map<String, int> _mental;
  late final Map<String, int> _tendencies;

  /// The chosen portrait, or null for "no portrait". Starts as whatever
  /// the fighter already had; a brand new fighter starts on a face rolled
  /// for their nationality, which the player can then change.
  String? _headshotAsset;

  /// True while the portrait is still whatever nationality rolled rather
  /// than something the player picked — so changing nationality re-rolls
  /// it, but only until they've made a choice of their own.
  bool _headshotIsAuto = true;

  /// Every portrait this build ships, read from the asset manifest once
  /// when the screen opens rather than each time the picker is opened.
  /// Null until it lands, which is a frame or two.
  HeadshotCatalog? _catalog;

  bool _saving = false;

  bool get _isEditing => widget.existingFighter != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final f = widget.existingFighter;
    _nameController = TextEditingController(text: f?.name ?? '');
    _age = f?.age ?? 25;
    _nationality = f?.nationality ?? knownNationalities.first;
    _headshotAsset = f?.headshotAsset ?? rollHeadshot(_nationality, Random());
    _headshotIsAuto = f == null;
    HeadshotCatalog.load().then((catalog) {
      if (mounted) setState(() => _catalog = catalog);
    });
    _weightClass = f?.weightClass ?? WeightClass.lightweight;
    _style = f?.style ?? FightingStyle.wellRounded;
    _popularity = f?.popularity ?? 20;
    _potential = f?.potential ?? 65;
    final defaultPhysical = generatePhysicalStats(_weightClass, Random());
    _heightInches = f?.heightInches ?? defaultPhysical.$1;
    _weightLbs = f?.weightLbs ?? defaultPhysical.$2;
    _reachInches = (f != null && f.reachInches > 0) ? f.reachInches : _heightInches;
    _wins = f?.record.wins ?? 0;
    _losses = f?.record.losses ?? 0;
    _draws = f?.record.draws ?? 0;

    _fighting = {
      for (final (key, _) in _fightingStatFields)
        key: _fightingValue(f?.fightingStats, key) ?? 50,
    };
    _physical = {
      for (final (key, _) in _physicalStatFields)
        key: _physicalValue(f?.physicalStats, key) ?? 50,
    };
    _mental = {
      for (final (key, _) in _mentalStatFields)
        key: _mentalValue(f?.mentalStats, key) ?? 50,
    };
    _tendencies = {
      for (final (key, _) in _tendencyFields)
        key: _tendencyValue(f?.tendencies, key) ?? 50,
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Fighter' : 'Create Fighter'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Bio'),
            Tab(text: 'Striking'),
            Tab(text: 'Grappling'),
            Tab(text: 'Physical'),
            Tab(text: 'Mental'),
            Tab(text: 'Style'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBioTab(),
          _buildStatTab(_strikingStatFields, _fighting),
          _buildStatTab(_grapplingStatFields, _fighting),
          _buildStatTab(_physicalStatFields, _physical),
          _buildStatTab(_mentalStatFields, _mental),
          _buildStyleTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save Changes' : 'Add to Talent Pool'),
          ),
        ),
      ),
    );
  }

  Widget _buildBioTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PortraitPicker(
          asset: _headshotAsset,
          catalog: _catalog,
          name: _nameController.text,
          onChanged: (asset) => setState(() {
            _headshotAsset = asset;
            _headshotIsAuto = false;
          }),
          onRandom: () => setState(() {
            _headshotAsset = rollHeadshot(_nationality, Random());
            _headshotIsAuto = true;
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          // The portrait above shows the fighter's initial when there is
          // no art, so it has to follow what is typed.
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text('Age: $_age'),
        Slider(
          value: _age.toDouble(),
          min: 18,
          max: 45,
          divisions: 27,
          label: '$_age',
          onChanged: (v) => setState(() => _age = v.round()),
        ),
        DropdownButtonFormField<String>(
          value: _nationality,
          decoration: const InputDecoration(labelText: 'Nationality'),
          items: knownNationalities
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => setState(() {
            _nationality = v ?? _nationality;
            // A rolled face follows the nationality; a chosen one does
            // not get taken away because a dropdown moved.
            if (_headshotIsAuto) {
              _headshotAsset = rollHeadshot(_nationality, Random());
            }
          }),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<WeightClass>(
          value: _weightClass,
          decoration: const InputDecoration(labelText: 'Weight Class'),
          items: WeightClass.values
              .map((w) => DropdownMenuItem(value: w, child: Text(w.labelWithLimit)))
              .toList(),
          onChanged: (v) => setState(() => _weightClass = v ?? _weightClass),
        ),
        const SizedBox(height: 16),
        Text('Height: ${_heightDisplay(_heightInches)}'),
        Slider(
          value: _heightInches.toDouble(),
          min: 60,
          max: 84,
          divisions: 24,
          label: _heightDisplay(_heightInches),
          onChanged: (v) => setState(() => _heightInches = v.round()),
        ),
        Text('Reach: $_reachInches"'),
        Slider(
          value: _reachInches.toDouble(),
          min: 58,
          max: 88,
          divisions: 30,
          label: '$_reachInches"',
          onChanged: (v) => setState(() => _reachInches = v.round()),
        ),
        Text('Weight: $_weightLbs lbs'),
        Slider(
          value: _weightLbs.toDouble(),
          min: 110,
          max: 320,
          divisions: 42,
          label: '$_weightLbs lbs',
          onChanged: (v) => setState(() => _weightLbs = v.round()),
        ),
        const SizedBox(height: 16),
        Text('Record', style: Theme.of(context).textTheme.titleMedium),
        _CountStepper(label: 'Wins', value: _wins, onChanged: (v) => setState(() => _wins = v)),
        _CountStepper(label: 'Losses', value: _losses, onChanged: (v) => setState(() => _losses = v)),
        _CountStepper(label: 'Draws', value: _draws, onChanged: (v) => setState(() => _draws = v)),
        const SizedBox(height: 16),
        _StatSlider(label: 'Popularity', value: _popularity, onChanged: (v) => setState(() => _popularity = v)),
        _StatSlider(
          label: 'Potential',
          value: _potential,
          onChanged: (v) => setState(() => _potential = v),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatTab(List<(String, String)> fields, Map<String, int> values) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (key, label) in fields)
          _StatSlider(
            label: label,
            value: values[key]!,
            onChanged: (v) => setState(() => values[key] = v),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStyleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Fighting Style', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FightingStyle.values.map((style) {
            return ChoiceChip(
              label: Text(style.label),
              selected: _style == style,
              onSelected: (_) => setState(() => _style = style),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Tendencies', style: Theme.of(context).textTheme.titleMedium),
        for (final (key, label) in _tendencyFields)
          _StatSlider(
            label: label,
            value: _tendencies[key]!,
            max: 100,
            onChanged: (v) => setState(() => _tendencies[key] = v),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a name.')));
      return;
    }

    setState(() => _saving = true);
    final controller = context.read<GameController>();
    final existing = widget.existingFighter;

    final fightingStats = FightingStats(
      punching: _fighting['punching']!,
      kicking: _fighting['kicking']!,
      power: _fighting['power']!,
      speed: _fighting['speed']!,
      accuracy: _fighting['accuracy']!,
      defense: _fighting['defense']!,
      headMovement: _fighting['headMovement']!,
      blocking: _fighting['blocking']!,
      footwork: _fighting['footwork']!,
      takedowns: _fighting['takedowns']!,
      takedownDefense: _fighting['takedownDefense']!,
      wrestling: _fighting['wrestling']!,
      clinchStriking: _fighting['clinchStriking']!,
      clinchControl: _fighting['clinchControl']!,
      clinchDefense: _fighting['clinchDefense']!,
      topControl: _fighting['topControl']!,
      groundAndPound: _fighting['groundAndPound']!,
      guardRetention: _fighting['guardRetention']!,
      sweeps: _fighting['sweeps']!,
      scrambling: _fighting['scrambling']!,
      submissionOffense: _fighting['submissionOffense']!,
      submissionDefense: _fighting['submissionDefense']!,
      grappling: _fighting['grappling']!,
    );

    final physicalStats = PhysicalStats(
      cardio: _physical['cardio']!,
      durability: _physical['durability']!,
      chin: _physical['chin']!,
      bodyToughness: _physical['bodyToughness']!,
      legToughness: _physical['legToughness']!,
      strength: _physical['strength']!,
      athleticism: _physical['athleticism']!,
      recovery: _physical['recovery']!,
      explosiveness: _physical['explosiveness']!,
      flexibility: _physical['flexibility']!,
      gripStrength: _physical['gripStrength']!,
    );

    final mentalStats = MentalStats(
      fightIq: _mental['fightIq']!,
      composure: _mental['composure']!,
      aggression: _mental['aggression']!,
      discipline: _mental['discipline']!,
      confidence: _mental['confidence']!,
      heart: _mental['heart']!,
      adaptability: _mental['adaptability']!,
      killerInstinct: _mental['killerInstinct']!,
    );

    final tendencies = Tendencies(
      strikingFrequency: _tendencies['strikingFrequency']!,
      takedownFrequency: _tendencies['takedownFrequency']!,
      kickFrequency: _tendencies['kickFrequency']!,
      clinchFrequency: _tendencies['clinchFrequency']!,
      submissionAttempts: _tendencies['submissionAttempts']!,
      groundAndPound: _tendencies['groundAndPound']!,
      positionControl: _tendencies['positionControl']!,
      standUpPreference: _tendencies['standUpPreference']!,
      wallWork: _tendencies['wallWork']!,
      aggression: _tendencies['aggression']!,
      counterStriking: _tendencies['counterStriking']!,
      headHunting: _tendencies['headHunting']!,
      bodyAttacks: _tendencies['bodyAttacks']!,
      legAttacks: _tendencies['legAttacks']!,
    );

    final record = FightRecord(wins: _wins, losses: _losses, draws: _draws);

    final fighter = existing == null
        ? Fighter(
            id: newId(),
            name: name,
            age: _age,
            nationality: _nationality,
            headshotAsset: _headshotAsset,
            weightClass: _weightClass,
            heightInches: _heightInches,
            weightLbs: _weightLbs,
            reachInches: _reachInches,
            record: record,
            fightingStats: fightingStats,
            physicalStats: physicalStats,
            mentalStats: mentalStats,
            style: _style,
            tendencies: tendencies,
            potential: _potential,
            popularity: _popularity,
            morale: 70,
            injuryStatus: InjuryStatus.healthy,
            winStreak: 0,
          )
        : existing.copyWith(
            name: name,
            age: _age,
            // Editing a fighter could not change their face before this
            // — copyWith simply never touched it.
            headshotAsset: _headshotAsset,
            clearHeadshotAsset: _headshotAsset == null,
            nationality: _nationality,
            weightClass: _weightClass,
            heightInches: _heightInches,
            weightLbs: _weightLbs,
            reachInches: _reachInches,
            record: record,
            fightingStats: fightingStats,
            physicalStats: physicalStats,
            mentalStats: mentalStats,
            style: _style,
            tendencies: tendencies,
            potential: _potential,
            popularity: _popularity,
          );

    await controller.saveFighter(fighter);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _heightDisplay(int inches) => '${inches ~/ 12}\'${inches % 12}"';

  int? _fightingValue(FightingStats? stats, String key) {
    if (stats == null) return null;
    switch (key) {
      case 'punching': return stats.punching;
      case 'kicking': return stats.kicking;
      case 'power': return stats.power;
      case 'speed': return stats.speed;
      case 'accuracy': return stats.accuracy;
      case 'defense': return stats.defense;
      case 'headMovement': return stats.headMovement;
      case 'blocking': return stats.blocking;
      case 'footwork': return stats.footwork;
      case 'takedowns': return stats.takedowns;
      case 'takedownDefense': return stats.takedownDefense;
      case 'wrestling': return stats.wrestling;
      case 'clinchStriking': return stats.clinchStriking;
      case 'clinchControl': return stats.clinchControl;
      case 'clinchDefense': return stats.clinchDefense;
      case 'topControl': return stats.topControl;
      case 'groundAndPound': return stats.groundAndPound;
      case 'guardRetention': return stats.guardRetention;
      case 'sweeps': return stats.sweeps;
      case 'scrambling': return stats.scrambling;
      case 'submissionOffense': return stats.submissionOffense;
      case 'submissionDefense': return stats.submissionDefense;
      case 'grappling': return stats.grappling;
    }
    return null;
  }

  int? _physicalValue(PhysicalStats? stats, String key) {
    if (stats == null) return null;
    switch (key) {
      case 'cardio': return stats.cardio;
      case 'durability': return stats.durability;
      case 'chin': return stats.chin;
      case 'bodyToughness': return stats.bodyToughness;
      case 'legToughness': return stats.legToughness;
      case 'strength': return stats.strength;
      case 'athleticism': return stats.athleticism;
      case 'recovery': return stats.recovery;
      case 'explosiveness': return stats.explosiveness;
      case 'flexibility': return stats.flexibility;
      case 'gripStrength': return stats.gripStrength;
    }
    return null;
  }

  int? _mentalValue(MentalStats? stats, String key) {
    if (stats == null) return null;
    switch (key) {
      case 'fightIq': return stats.fightIq;
      case 'composure': return stats.composure;
      case 'aggression': return stats.aggression;
      case 'discipline': return stats.discipline;
      case 'confidence': return stats.confidence;
      case 'heart': return stats.heart;
      case 'adaptability': return stats.adaptability;
      case 'killerInstinct': return stats.killerInstinct;
    }
    return null;
  }

  int? _tendencyValue(Tendencies? t, String key) {
    if (t == null) return null;
    switch (key) {
      case 'strikingFrequency': return t.strikingFrequency;
      case 'takedownFrequency': return t.takedownFrequency;
      case 'kickFrequency': return t.kickFrequency;
      case 'clinchFrequency': return t.clinchFrequency;
      case 'submissionAttempts': return t.submissionAttempts;
      case 'groundAndPound': return t.groundAndPound;
      case 'positionControl': return t.positionControl;
      case 'standUpPreference': return t.standUpPreference;
      case 'wallWork': return t.wallWork;
      case 'aggression': return t.aggression;
      case 'counterStriking': return t.counterStriking;
      case 'headHunting': return t.headHunting;
      case 'bodyAttacks': return t.bodyAttacks;
      case 'legAttacks': return t.legAttacks;
    }
    return null;
  }
}

class _CountStepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CountStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.center)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < 99 ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StatSlider extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _StatSlider({
    required this.label,
    required this.value,
    this.max = 99,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble().clamp(1, max.toDouble()),
            min: 1,
            max: max.toDouble(),
            divisions: max - 1,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.right)),
      ],
    );
  }
}

/// The fighter's face, with the controls to change it.
///
/// Sits at the top of the Bio tab because it is the first thing anyone
/// decides about a fighter they are making up.
class _PortraitPicker extends StatelessWidget {
  final String? asset;

  /// Null until the manifest has been read; the Choose button waits for
  /// it rather than opening onto an empty grid.
  final HeadshotCatalog? catalog;

  /// Only used for the fallback initial when there is no portrait.
  final String name;

  final ValueChanged<String?> onChanged;
  final VoidCallback onRandom;

  const _PortraitPicker({
    required this.asset,
    required this.catalog,
    required this.name,
    required this.onChanged,
    required this.onRandom,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PortraitThumb(asset: asset, name: name, size: 72),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Portrait', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                asset == null
                    ? 'No portrait — shows their initial instead.'
                    : HeadshotCatalog.labelFor(
                        HeadshotCatalog.groupKeyOf(asset!)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: catalog == null
                        ? null
                        : () async {
                            final picked = await showDialog<_PortraitChoice>(
                              context: context,
                              builder: (_) => _PortraitGridDialog(
                                catalog: catalog!,
                                selected: asset,
                              ),
                            );
                            if (picked == null) return;
                            onChanged(picked.asset);
                          },
                    child: const Text('Choose'),
                  ),
                  TextButton(
                    onPressed: onRandom,
                    child: const Text('Random'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A dialog result, so "picked nothing" and "picked no portrait" stay
/// different things — the first closes the dialog, the second clears the
/// face.
class _PortraitChoice {
  final String? asset;

  const _PortraitChoice(this.asset);
}

/// One portrait, drawn the way the game draws them: pixel art on the
/// studio backdrop, nearest-neighbour so it stays crisp.
class _PortraitThumb extends StatelessWidget {
  final String? asset;
  final String name;
  final double size;
  final bool selected;

  const _PortraitThumb({
    required this.asset,
    required this.name,
    required this.size,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.avatarBackdropTop,
            AppColors.avatarBackdropBottom,
          ],
        ),
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.primary : Colors.white.withOpacity(0.14),
          width: selected ? 3 : 1,
        ),
      ),
      child: asset == null
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : Transform.scale(
              scale: 1.12,
              child: Image.asset(
                asset!,
                filterQuality: FilterQuality.none,
                fit: BoxFit.contain,
              ),
            ),
    );
  }
}

/// Every portrait the build ships, in a grid, grouped by set.
///
/// The list comes from the asset manifest rather than from Dart, so a
/// new set of faces dropped into `assets/fighters/` turns up here with
/// no code change — see [HeadshotCatalog].
class _PortraitGridDialog extends StatelessWidget {
  final HeadshotCatalog catalog;
  final String? selected;

  const _PortraitGridDialog({required this.catalog, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a portrait'),
      content: SizedBox(
        width: 460,
        height: 440,
        child: catalog.isEmpty
            ? const Center(
                child: Text('No portrait art is bundled with this build.'),
              )
            : ListView(
                children: [
                  for (final set in catalog.sets) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                      child: Text(
                        '${set.label}  ·  ${set.assets.length}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final asset in set.assets)
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context)
                                .pop(_PortraitChoice(asset)),
                            child: _PortraitThumb(
                              asset: asset,
                              name: '',
                              size: 56,
                              selected: asset == selected,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Distinct from cancelling: this is a choice, and it is the only
        // way back to the plain initial-letter avatar.
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const _PortraitChoice(null)),
          child: const Text('No portrait'),
        ),
      ],
    );
  }
}
