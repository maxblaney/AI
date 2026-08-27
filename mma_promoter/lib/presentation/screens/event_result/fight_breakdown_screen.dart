import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/models.dart';

/// Replays a resolved fight's round-by-round momentum as a blue (fighter
/// A) / red (fighter B) split bar, one round revealed at a time. Only
/// works right after a fresh simulation — [FightResult.roundScores] isn't
/// persisted, so a fight reloaded from storage won't have any to show.
class FightBreakdownScreen extends StatefulWidget {
  final Fight fight;
  final Fighter fighterA;
  final Fighter fighterB;

  const FightBreakdownScreen({
    super.key,
    required this.fight,
    required this.fighterA,
    required this.fighterB,
  });

  @override
  State<FightBreakdownScreen> createState() => _FightBreakdownScreenState();
}

class _FightBreakdownScreenState extends State<FightBreakdownScreen> {
  int _visibleRounds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final total = widget.fight.result?.roundScores.length ?? 0;
    if (total > 0) {
      _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
        setState(() => _visibleRounds++);
        if (_visibleRounds >= total) timer.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.fight.result;
    final roundScores = result?.roundScores ?? const [];
    final isFinished = _visibleRounds >= roundScores.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Round-by-Round')),
      body: roundScores.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Round-by-round detail isn't available for this fight — "
                  'it only exists right after simulating the event, not '
                  'after leaving and coming back.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.fighterA.name,
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.fighterB.name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < _visibleRounds && i < roundScores.length; i++)
                  _RoundBar(score: roundScores[i]),
                if (isFinished && result != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    result.isDraw
                        ? 'Draw / No Contest'
                        : '${result.winnerId == widget.fighterA.id ? widget.fighterA.name : widget.fighterB.name} '
                            'wins by ${result.method.label}, Round ${result.round}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ],
            ),
    );
  }
}

class _RoundBar extends StatelessWidget {
  final RoundScore score;

  const _RoundBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final aFlex = (score.fighterAShare * 100).round().clamp(1, 99);
    final bFlex = 100 - aFlex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Round ${score.round}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(flex: aFlex, child: Container(color: Colors.blue)),
                  Expanded(flex: bFlex, child: Container(color: Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
