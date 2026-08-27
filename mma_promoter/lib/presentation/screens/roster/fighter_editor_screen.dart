import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/roster_seed.dart';
import '../../state/game_controller.dart';

const List<(String, String)> _fightingStatFields = [
  ('punching', 'Punching'),
  ('kicking', 'Kicking'),
  ('power', 'Power'),
  ('speed', 'Speed'),
  ('accuracy', 'Accuracy'),
  ('defense', 'Defense'),
  ('takedowns', 'Takedowns'),
  ('takedownDefense', 'Takedown Defense'),
  ('wrestling', 'Wrestling'),
  ('groundAndPound', 'Ground & Pound'),
  ('submissionOffense', 'Submission Offense'),
  ('submissionDefense', 'Submission Defense'),
  ('grappling', 'Grappling'),
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
];

const List<(String, String)> _mentalStatFields = [
  ('fightIq', 'Fight IQ'),
  ('composure', 'Composure'),
  ('aggression', 'Aggression'),
  ('discipline', 'Discipline'),
  ('confidence', 'Confidence'),
  ('heart', 'Heart'),
  ('adaptability', 'Adaptability'),
];

const List<(String, String)> _tendencyFields = [
  ('strikingFrequency', 'Striking Frequency'),
  ('takedownFrequency', 'Takedown Frequency'),
  ('kickFrequency', 'Kick Frequency'),
  ('clinchFrequency', 'Clinch Frequency'),
  ('submissionAttempts', 'Submission Attempts'),
  ('groundAndPound', 'Ground & Pound'),
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
  late int _wins;
  late int _losses;
  late int _draws;
  late int _popularity;
  late int _potential;
  late final Map<String, int> _fighting;
  late final Map<String, int> _physical;
  late final Map<String, int> _mental;
  late final Map<String, int> _tendencies;
  bool _saving = false;

  bool get _isEditing => widget.existingFighter != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final f = widget.existingFighter;
    _nameController = TextEditingController(text: f?.name ?? '');
    _age = f?.age ?? 25;
    _nationality = f?.nationality ?? knownNationalities.first;
    _weightClass = f?.weightClass ?? WeightClass.lightweight;
    _style = f?.style ?? FightingStyle.wellRounded;
    _popularity = f?.popularity ?? 20;
    _potential = f?.potential ?? 65;
    final defaultPhysical = generatePhysicalStats(_weightClass, Random());
    _heightInches = f?.heightInches ?? defaultPhysical.$1;
    _weightLbs = f?.weightLbs ?? defaultPhysical.$2;
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
            Tab(text: 'Fighting'),
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
          _buildStatTab(_fightingStatFields, _fighting),
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
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
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
          onChanged: (v) => setState(() => _nationality = v ?? _nationality),
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
      takedowns: _fighting['takedowns']!,
      takedownDefense: _fighting['takedownDefense']!,
      wrestling: _fighting['wrestling']!,
      groundAndPound: _fighting['groundAndPound']!,
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
    );

    final mentalStats = MentalStats(
      fightIq: _mental['fightIq']!,
      composure: _mental['composure']!,
      aggression: _mental['aggression']!,
      discipline: _mental['discipline']!,
      confidence: _mental['confidence']!,
      heart: _mental['heart']!,
      adaptability: _mental['adaptability']!,
    );

    final tendencies = Tendencies(
      strikingFrequency: _tendencies['strikingFrequency']!,
      takedownFrequency: _tendencies['takedownFrequency']!,
      kickFrequency: _tendencies['kickFrequency']!,
      clinchFrequency: _tendencies['clinchFrequency']!,
      submissionAttempts: _tendencies['submissionAttempts']!,
      groundAndPound: _tendencies['groundAndPound']!,
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
            weightClass: _weightClass,
            heightInches: _heightInches,
            weightLbs: _weightLbs,
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
            nationality: _nationality,
            weightClass: _weightClass,
            heightInches: _heightInches,
            weightLbs: _weightLbs,
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
      case 'takedowns': return stats.takedowns;
      case 'takedownDefense': return stats.takedownDefense;
      case 'wrestling': return stats.wrestling;
      case 'groundAndPound': return stats.groundAndPound;
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
