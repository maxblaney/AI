import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/models.dart';

/// One frame of playback: where momentum sat at that instant, plus any
/// play-by-play lines that happened since the previous frame.
class _Frame {
  final int round;
  final int timeSeconds;
  final double share;
  final List<FightEvent> events;

  const _Frame({
    required this.round,
    required this.timeSeconds,
    required this.share,
    required this.events,
  });
}

/// Plays a resolved fight back live: a continuously-updating blue
/// (fighter A) / red (fighter B) momentum bar, a running clock, and a
/// commentary feed of everything that happens. Once it's over you get the
/// box score and the judges' cards.
///
/// Only works right after a fresh simulation — the play-by-play isn't
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
  late final List<_Frame> _frames;
  final ScrollController _feedController = ScrollController();
  Timer? _timer;
  int _frameIndex = 0;
  int _speed = 1;

  FightResult? get _result => widget.fight.result;
  bool get _isFinished => _frames.isEmpty || _frameIndex >= _frames.length - 1;

  /// Everything that has been "said" up to the current frame.
  List<FightEvent> get _spokenEvents => [
        for (var i = 0; i <= _frameIndex && i < _frames.length; i++)
          ..._frames[i].events,
      ];

  @override
  void initState() {
    super.initState();
    _frames = _buildFrames();
    if (_frames.isNotEmpty) _startTimer();
  }

  List<_Frame> _buildFrames() {
    final result = _result;
    if (result == null || result.momentumTicks.isEmpty) return const [];

    final events = [...result.events];
    var cursor = 0;
    int order(int round, int seconds) => round * 1000 + seconds;

    final frames = <_Frame>[];
    for (final tick in result.momentumTicks) {
      final upTo = order(tick.round, tick.timeSeconds);
      final batch = <FightEvent>[];
      while (cursor < events.length &&
          order(events[cursor].round, events[cursor].timeSeconds) <= upTo) {
        batch.add(events[cursor]);
        cursor++;
      }
      frames.add(_Frame(
        round: tick.round,
        timeSeconds: tick.timeSeconds,
        share: tick.fighterAShare,
        events: batch,
      ));
    }
    // Anything left (the finish line, the decision) rides on the last frame.
    if (cursor < events.length && frames.isNotEmpty) {
      final last = frames.removeLast();
      frames.add(_Frame(
        round: last.round,
        timeSeconds: last.timeSeconds,
        share: last.share,
        events: [...last.events, ...events.sublist(cursor)],
      ));
    }
    return frames;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 900 ~/ _speed), (timer) {
      if (_frameIndex >= _frames.length - 1) {
        timer.cancel();
        return;
      }
      setState(() => _frameIndex++);
      _scrollFeedToBottom();
    });
  }

  void _scrollFeedToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_feedController.hasClients) return;
      _feedController.animateTo(
        _feedController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _setSpeed(int speed) {
    setState(() => _speed = speed);
    if (!_isFinished) _startTimer();
  }

  void _skipToEnd() {
    _timer?.cancel();
    setState(() => _frameIndex = _frames.length - 1);
    _scrollFeedToBottom();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_frames.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Fight')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "This fight's live breakdown isn't available anymore — it only "
              'exists right after simulating the event, not after leaving and '
              'coming back.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final frame = _frames[_frameIndex];
    final result = _result!;

    return DefaultTabController(
      length: _isFinished ? 3 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Fight'),
          actions: [
            if (!_isFinished)
              TextButton(
                onPressed: _skipToEnd,
                child: const Text('Skip'),
              ),
          ],
          bottom: _isFinished
              ? const TabBar(tabs: [
                  Tab(text: 'Play-by-Play'),
                  Tab(text: 'Box Score'),
                  Tab(text: 'Scorecards'),
                ])
              : null,
        ),
        body: Column(
          children: [
            _Scoreboard(
              fighterA: widget.fighterA,
              fighterB: widget.fighterB,
              frame: frame,
              totalRounds: widget.fight.rounds,
            ),
            const Divider(height: 1),
            Expanded(
              child: _isFinished
                  ? TabBarView(
                      children: [
                        _CommentaryFeed(
                          controller: _feedController,
                          events: _spokenEvents,
                          fighterA: widget.fighterA,
                          result: result,
                          fighterB: widget.fighterB,
                        ),
                        _BoxScore(
                          fighterA: widget.fighterA,
                          fighterB: widget.fighterB,
                          result: result,
                        ),
                        _Scorecards(
                          fighterA: widget.fighterA,
                          fighterB: widget.fighterB,
                          result: result,
                        ),
                      ],
                    )
                  : _CommentaryFeed(
                      controller: _feedController,
                      events: _spokenEvents,
                      fighterA: widget.fighterA,
                      fighterB: widget.fighterB,
                      result: null,
                    ),
            ),
            if (!_isFinished)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Speed'),
                      const SizedBox(width: 12),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 1, label: Text('1x')),
                          ButtonSegment(value: 2, label: Text('2x')),
                          ButtonSegment(value: 4, label: Text('4x')),
                        ],
                        selected: {_speed},
                        onSelectionChanged: (s) => _setSpeed(s.first),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Names, round, clock and the momentum bar.
class _Scoreboard extends StatelessWidget {
  final Fighter fighterA;
  final Fighter fighterB;
  final _Frame frame;
  final int totalRounds;

  const _Scoreboard({
    required this.fighterA,
    required this.fighterB,
    required this.frame,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    final remaining =
        (Fight.roundLengthSeconds - frame.timeSeconds).clamp(0, Fight.roundLengthSeconds);
    final clock = '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fighterA.name,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: [
                  Text('R${frame.round}/$totalRounds',
                      style: Theme.of(context).textTheme.labelMedium),
                  Text(clock,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
              Expanded(
                child: Text(
                  fighterB.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MomentumBar(share: frame.share),
        ],
      ),
    );
  }
}

class _MomentumBar extends StatelessWidget {
  final double share;

  const _MomentumBar({required this.share});

  @override
  Widget build(BuildContext context) {
    // Expanded's flex doesn't animate on its own — TweenAnimationBuilder
    // smoothly interpolates the share value itself between frames, and we
    // rebuild flex from that interpolated value every tick.
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 26,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: share),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final aFlex = (value * 1000).round().clamp(10, 990);
            return Row(
              children: [
                Expanded(flex: aFlex, child: Container(color: Colors.blue)),
                Expanded(flex: 1000 - aFlex, child: Container(color: Colors.red)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The scrolling commentary — the thing that makes watching a fight fun.
class _CommentaryFeed extends StatelessWidget {
  final ScrollController controller;
  final List<FightEvent> events;
  final Fighter fighterA;
  final Fighter fighterB;
  final FightResult? result;

  const _CommentaryFeed({
    required this.controller,
    required this.events,
    required this.fighterA,
    required this.fighterB,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: events.length + (result != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == events.length) {
          return _ResultBanner(
            result: result!,
            fighterA: fighterA,
            fighterB: fighterB,
          );
        }
        return _CommentaryLine(event: events[index], fighterA: fighterA);
      },
    );
  }
}

class _CommentaryLine extends StatelessWidget {
  final FightEvent event;
  final Fighter fighterA;

  const _CommentaryLine({required this.event, required this.fighterA});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isA = event.fighterId == fighterA.id;
    final neutral = event.fighterId == null;

    final (icon, color, bold) = switch (event.type) {
      FightEventType.knockdown => (Icons.bolt, Colors.amber, true),
      FightEventType.finish => (Icons.sports_mma, theme.colorScheme.primary, true),
      FightEventType.bigStrike => (Icons.flash_on, Colors.orange, false),
      FightEventType.submissionAttempt => (Icons.link, Colors.purple, false),
      FightEventType.takedown => (Icons.arrow_downward, Colors.teal, false),
      FightEventType.takedownStuffed => (Icons.block, Colors.blueGrey, false),
      FightEventType.sweep => (Icons.swap_vert, Colors.teal, false),
      FightEventType.standUp => (Icons.arrow_upward, Colors.blueGrey, false),
      FightEventType.positionChange => (Icons.open_with, Colors.indigo, false),
      FightEventType.clinch => (Icons.compress, Colors.blueGrey, false),
      FightEventType.roundStart ||
      FightEventType.roundEnd =>
        (Icons.timer_outlined, theme.colorScheme.outline, true),
      _ => (Icons.circle, theme.colorScheme.outline, false),
    };

    final accent = neutral
        ? theme.colorScheme.outline
        : (isA ? Colors.blue : Colors.red);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              event.clockDisplay(Fight.roundLengthSeconds),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Icon(icon, size: 14, color: color),
          ),
          Expanded(
            child: Text(
              event.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: neutral ? theme.colorScheme.outline : accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final FightResult result;
  final Fighter fighterA;
  final Fighter fighterB;

  const _ResultBanner({
    required this.result,
    required this.fighterA,
    required this.fighterB,
  });

  @override
  Widget build(BuildContext context) {
    final winner = result.winnerId == fighterA.id
        ? fighterA
        : (result.winnerId == fighterB.id ? fighterB : null);

    return Card(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              winner == null ? 'Draw / No Contest' : '${winner.name} def. '
                  '${winner.id == fighterA.id ? fighterB.name : fighterA.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${result.methodDisplay} · R${result.round} ${result.timeDisplay}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The fight's box score, laid out the way a broadcast graphic would.
class _BoxScore extends StatelessWidget {
  final Fighter fighterA;
  final Fighter fighterB;
  final FightResult result;

  const _BoxScore({
    required this.fighterA,
    required this.fighterB,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final a = result.statsA;
    final b = result.statsB;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatRow(
          // Landed / attempted, same as a broadcast graphic — spelled out
          // because "38/91" on its own is a coin flip between that and a
          // score.
          label: 'Significant strikes (landed/thrown)',
          a: '${a.significantStrikesLanded}/${a.significantStrikesAttempted}',
          b: '${b.significantStrikesLanded}/${b.significantStrikesAttempted}',
          isHeader: true,
        ),
        _StatRow(
          label: 'Striking accuracy',
          a: '${a.strikingAccuracyPercent}%',
          b: '${b.strikingAccuracyPercent}%',
        ),
        _StatRow(label: 'Head', a: '${a.headStrikes}', b: '${b.headStrikes}'),
        _StatRow(label: 'Body', a: '${a.bodyStrikes}', b: '${b.bodyStrikes}'),
        _StatRow(label: 'Leg', a: '${a.legStrikes}', b: '${b.legStrikes}'),
        const Divider(height: 24),
        _StatRow(
          label: 'Takedowns (landed/attempted)',
          a: '${a.takedownsLanded}/${a.takedownsAttempted}',
          b: '${b.takedownsLanded}/${b.takedownsAttempted}',
          isHeader: true,
        ),
        _StatRow(
          label: 'Takedown accuracy',
          a: '${a.takedownAccuracyPercent}%',
          b: '${b.takedownAccuracyPercent}%',
        ),
        _StatRow(
          label: 'Submission attempts',
          a: '${a.submissionAttempts}',
          b: '${b.submissionAttempts}',
        ),
        _StatRow(label: 'Reversals', a: '${a.reversals}', b: '${b.reversals}'),
        _StatRow(
          label: 'Control time',
          a: a.controlTimeDisplay,
          b: b.controlTimeDisplay,
        ),
        const Divider(height: 24),
        _StatRow(
          label: 'Knockdowns',
          a: '${a.knockdowns}',
          b: '${b.knockdowns}',
          isHeader: true,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String a;
  final String b;
  final bool isHeader;

  const _StatRow({
    required this.label,
    required this.a,
    required this.b,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(a, style: style?.copyWith(color: Colors.blue)),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              b,
              textAlign: TextAlign.right,
              style: style?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// The three judges' cards — only populated when the fight went the distance.
class _Scorecards extends StatelessWidget {
  final Fighter fighterA;
  final Fighter fighterB;
  final FightResult result;

  const _Scorecards({
    required this.fighterA,
    required this.fighterB,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result.scorecards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No scorecards — this one ended before a round was completed.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // A finish doesn't erase the rounds the judges already scored, and
    // they're often the interesting part — the man who got stopped was
    // sometimes winning.
    final endedEarly = result.method != FightMethod.decision && !result.isDraw;
    final scored = result.scorecards.first.rounds.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (endedEarly)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              scored == 1
                  ? 'The fight ended in round ${result.round}. Round 1 had '
                      'already been scored:'
                  : 'The fight ended in round ${result.round}. The first '
                      '$scored rounds had already been scored:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        for (final card in result.scorecards)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(card.judgeName,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        card.display,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final round in card.rounds)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text('Round ${round.round}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                          Expanded(
                            child: Text(
                              '${round.fighterAScore}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: round.fighterAScore > round.fighterBScore
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${round.fighterBScore}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: round.fighterBScore > round.fighterAScore
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A finished fight, read rather than watched: the result, the box score
/// and the judges' cards.
///
/// The live playback only exists in the moment — momentum ticks and
/// commentary are not persisted, so a fight reloaded from a save has
/// nothing to replay. The statlines and scorecards *are* persisted, and
/// until now there was no way back to them: you watched a fight once and
/// the numbers were gone. This is where a fight on a finished card goes
/// when you tap it.
class FightStatsScreen extends StatelessWidget {
  final Fight fight;
  final Fighter fighterA;
  final Fighter fighterB;

  const FightStatsScreen({
    super.key,
    required this.fight,
    required this.fighterA,
    required this.fighterB,
  });

  @override
  Widget build(BuildContext context) {
    final result = fight.result;
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fight')),
        body: const Center(child: Text('This fight has not been run yet.')),
      );
    }

    final hasCards = result.scorecards.isNotEmpty;
    return DefaultTabController(
      length: hasCards ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${fighterA.name.split(' ').last} vs '
            '${fighterB.name.split(' ').last}',
          ),
          bottom: TabBar(tabs: [
            const Tab(text: 'Box Score'),
            if (hasCards) const Tab(text: 'Scorecards'),
          ]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ResultBanner(
                result: result,
                fighterA: fighterA,
                fighterB: fighterB,
              ),
            ),
            Expanded(
              child: TabBarView(children: [
                _BoxScore(
                  fighterA: fighterA,
                  fighterB: fighterB,
                  result: result,
                ),
                if (hasCards)
                  _Scorecards(
                    fighterA: fighterA,
                    fighterB: fighterB,
                    result: result,
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
