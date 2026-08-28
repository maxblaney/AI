import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/calendar/game_calendar.dart';
import '../../state/game_controller.dart';
import '../roster/fighter_profile_screen.dart';

/// Notifications about the player's own roster — injuries, retirements,
/// and fighters asking to be booked.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final items = [...controller.inboxItems]
      ..sort((a, b) => b.week.compareTo(a.week));

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: items.isEmpty
          ? const Center(child: Text('Nothing here yet.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) => _InboxTile(item: items[i]),
            ),
    );
  }
}

class _InboxTile extends StatelessWidget {
  final InboxItem item;

  const _InboxTile({required this.item});

  IconData get _icon {
    switch (item.type) {
      case InboxItemType.injury:
        return Icons.local_hospital;
      case InboxItemType.retirement:
        return Icons.emoji_events;
      case InboxItemType.fightRequest:
        return Icons.handshake;
    }
  }

  Color? _iconColor(BuildContext context) {
    switch (item.type) {
      case InboxItemType.injury:
        // Matches the injury icon color used on the event results screen.
        return Colors.orange;
      case InboxItemType.retirement:
        return Colors.amber[800];
      case InboxItemType.fightRequest:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameController>();
    return ListTile(
      leading: Icon(_icon, color: _iconColor(context)),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: item.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text('${item.body}\n${GameCalendar.label(item.week)}'),
      isThreeLine: true,
      trailing: item.read ? null : const Icon(Icons.circle, size: 10, color: Colors.blue),
      onTap: () {
        if (!item.read) controller.markInboxItemRead(item.id);
        if (item.fighterId != null && controller.fighterById(item.fighterId!) != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FighterProfileScreen(fighterId: item.fighterId!),
            ),
          );
        }
      },
    );
  }
}
