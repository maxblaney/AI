import 'package:flutter/material.dart';

import '../../data/models/models.dart';

class FighterListTile extends StatelessWidget {
  final Fighter fighter;
  final VoidCallback? onTap;

  const FighterListTile({super.key, required this.fighter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(fighter.name.substring(0, 1))),
      title: Text(fighter.name),
      subtitle: Text(
        '${fighter.weightClass.label} · ${fighter.record.display} · '
        '${fighter.style.label}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('OVR ${fighter.overall.round()}'),
          if (fighter.injuryStatus != InjuryStatus.healthy)
            Text(
              fighter.injuryStatus.label,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
