import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/models.dart';

/// Plays a resolved fight back live: one continuously-updating blue
/// (fighter A) / red (fighter B) bar that ticks through every momentum
/// sample in real time, fluctuating within and across rounds rather than
/// jumping from one static round score to the next. Only works right
/// after a fresh simulation — [FightResult.momentumTicks] isn't
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
  int _tickIndex = 0;
  Timer? _timer;

  List<MomentumTick> get _ticks => widget.fight.result?.momentumTicks ?? const [];

  @override
  void initState() {
    super.initState();
    if (_ticks.isNotEmpty) {
      _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
        setState(() => _tickIndex++);
        if (_tickIndex >= _ticks.length - 1) timer.cancel();
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
    final isFinished = _ticks.isNotEmpty && _tickIndex >= _ticks.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Round-by-Round')),
      body: _ticks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "This fight's live breakdown isn't available anymore — "
                  'it only exists right after simulating the event, not '
                  'after leaving and coming back.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                  const SizedBox(height: 8),
                  Text(
                    'Round ${_ticks[_tickIndex].round} of ${widget.fight.rounds}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _LiveMomentumBar(share: _ticks[_tickIndex].fighterAShare),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _MomentumHistory(
                      ticks: _ticks.sublist(0, _tickIndex + 1),
                    ),
                  ),
                  if (isFinished && result != null) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      result.isDraw
                          ? 'Draw / No Contest'
                          : '${result.winnerId == widget.fighterA.id ? widget.fighterA.name : widget.fighterB.name} '
                              'wins by ${result.method.label}, Round ${result.round}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
    );
  }
}

class _LiveMomentumBar extends StatelessWidget {
  final double share;

  const _LiveMomentumBar({required this.share});

  @override
  Widget build(BuildContext context) {
    // Expanded's flex doesn't animate on its own — TweenAnimationBuilder
    // smoothly interpolates the share value itself between ticks, and we
    // rebuild flex from that interpolated value every frame.
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 28,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: share),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final aFlex = (value * 1000).round().clamp(10, 990);
            final bFlex = 1000 - aFlex;
            return Row(
              children: [
                Expanded(flex: aFlex, child: Container(color: Colors.blue)),
                Expanded(flex: bFlex, child: Container(color: Colors.red)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A compact strip of past ticks so the fluctuation is visible over time,
/// not just the current instant.
class _MomentumHistory extends StatelessWidget {
  final List<MomentumTick> ticks;

  const _MomentumHistory({required this.ticks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Momentum so far', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: ticks.length,
            itemBuilder: (context, index) {
              final tick = ticks[ticks.length - 1 - index];
              final aFlex = (tick.fighterAShare * 1000).round().clamp(10, 990);
              final bFlex = 1000 - aFlex;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        'R${tick.round}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 10,
                          child: Row(
                            children: [
                              Expanded(
                                flex: aFlex,
                                child: Container(color: Colors.blue.withOpacity(0.6)),
                              ),
                              Expanded(
                                flex: bFlex,
                                child: Container(color: Colors.red.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
