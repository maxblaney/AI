import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../widgets/random_event_dialog.dart';
import 'dashboard/dashboard_screen.dart';
import 'finance/finance_screen.dart';
import 'history/history_screen.dart';
import 'new_game/new_game_screen.dart';
import 'rankings/rankings_screen.dart';
import 'roster/roster_screen.dart';

/// App shell: bottom-tab navigation plus a global watcher that pops up a
/// modal whenever a random event needs the player's attention, regardless
/// of which tab they're on.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;
  String? _dialogShownForEventId;

  static const _tabs = [
    DashboardScreen(),
    RosterScreen(),
    RankingsScreen(),
    HistoryScreen(),
    FinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.initError != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  "Couldn't open your save",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The game stores saves in your browser. This can fail in '
                  'private browsing, or if site data is blocked.',
                ),
                const SizedBox(height: 16),
                SelectableText(
                  controller.initError!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (controller.needsNewGame) {
      return const NewGameScreen();
    }

    final pending = controller.pendingRandomEvents;
    if (pending.isNotEmpty && _dialogShownForEventId != pending.first.id) {
      _dialogShownForEventId = pending.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showRandomEventDialog(context, pending.first);
      });
    }

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Roster'),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Rankings',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
        ],
      ),
    );
  }
}
