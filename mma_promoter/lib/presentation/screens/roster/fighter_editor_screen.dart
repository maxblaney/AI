import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/roster_seed.dart';
import '../../state/game_controller.dart';

/// Create-from-scratch and edit-existing share this one form. In edit mode
/// the fighter's id, win streak, morale, injury status and contract are
/// preserved untouched — everything shown here, record and weight class
/// included, can be changed.
class FighterEditorScreen extends StatefulWidget {
  final Fighter? existingFighter;

  const FighterEditorScreen({super.key, this.existingFighter});

  @override
  State<FighterEditorScreen> createState() => _FighterEditorScreenState();
}

class _FighterEditorScreenState extends State<FighterEditorScreen> {
  late final TextEditingController _nameController;
  late int _age;
  late String _nationality;
  late WeightClass _weightClass;
  late Set<StyleTag> _styleTags;
  late int _striking;
  late int _grappling;
  late int _cardio;
  late int _chin;
  late int _power;
  late int _popularity;
  late int _heightInches;
  late int _weightLbs;
  late int _wins;
  late int _losses;
  late int _draws;
  bool _saving = false;

  bool get _isEditing => widget.existingFighter != null;

  @override
  void initState() {
    super.initState();
    final f = widget.existingFighter;
    _nameController = TextEditingController(text: f?.name ?? '');
    _age = f?.age ?? 25;
    _nationality = f?.nationality ?? knownNationalities.first;
    _weightClass = f?.weightClass ?? WeightClass.lightweight;
    _styleTags = {...(f?.styleTags ?? const [StyleTag.allRounder])};
    _striking = f?.stats.striking ?? 50;
    _grappling = f?.stats.grappling ?? 50;
    _cardio = f?.stats.cardio ?? 50;
    _chin = f?.stats.chin ?? 50;
    _power = f?.stats.power ?? 50;
    _popularity = f?.popularity ?? 20;
    final defaultPhysical = generatePhysicalStats(_weightClass, Random());
    _heightInches = f?.heightInches ?? defaultPhysical.$1;
    _weightLbs = f?.weightLbs ?? defaultPhysical.$2;
    _wins = f?.record.wins ?? 0;
    _losses = f?.record.losses ?? 0;
    _draws = f?.record.draws ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Fighter' : 'Create Fighter'),
      ),
      body: ListView(
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
          Text('Style', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: StyleTag.values.map((tag) {
              return FilterChip(
                label: Text(tag.label),
                selected: _styleTags.contains(tag),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _styleTags.add(tag);
                  } else if (_styleTags.length > 1) {
                    _styleTags.remove(tag);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Stats', style: Theme.of(context).textTheme.titleMedium),
          _StatSlider(label: 'Striking', value: _striking, onChanged: (v) => setState(() => _striking = v)),
          _StatSlider(label: 'Grappling', value: _grappling, onChanged: (v) => setState(() => _grappling = v)),
          _StatSlider(label: 'Cardio', value: _cardio, onChanged: (v) => setState(() => _cardio = v)),
          _StatSlider(label: 'Chin', value: _chin, onChanged: (v) => setState(() => _chin = v)),
          _StatSlider(label: 'Power', value: _power, onChanged: (v) => setState(() => _power = v)),
          _StatSlider(label: 'Popularity', value: _popularity, onChanged: (v) => setState(() => _popularity = v)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save Changes' : 'Add to Talent Pool'),
          ),
        ],
      ),
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

    final stats = FighterStats(
      striking: _striking,
      grappling: _grappling,
      cardio: _cardio,
      chin: _chin,
      power: _power,
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
            stats: stats,
            popularity: _popularity,
            morale: 70,
            injuryStatus: InjuryStatus.healthy,
            winStreak: 0,
            styleTags: _styleTags.toList(),
          )
        : existing.copyWith(
            name: name,
            age: _age,
            nationality: _nationality,
            weightClass: _weightClass,
            heightInches: _heightInches,
            weightLbs: _weightLbs,
            record: record,
            stats: stats,
            popularity: _popularity,
            styleTags: _styleTags.toList(),
          );

    await controller.saveFighter(fighter);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _heightDisplay(int inches) => '${inches ~/ 12}\'${inches % 12}"';
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
  final ValueChanged<int> onChanged;

  const _StatSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.right)),
      ],
    );
  }
}
