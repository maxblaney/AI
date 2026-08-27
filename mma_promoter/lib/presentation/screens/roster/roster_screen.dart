import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';
import '../../widgets/fighter_list_tile.dart';
import 'fighter_profile_screen.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Roster'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Roster'),
              Tab(text: 'Talent Pool'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FighterList(fighters: controller.signedRoster, emptyText: 'No fighters signed yet.'),
            _FighterList(fighters: controller.talentPool, emptyText: 'No free agents available.'),
          ],
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
