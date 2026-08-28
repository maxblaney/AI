import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Circular fighter portrait — shows the fighter's headshot art when one is
/// assigned, otherwise falls back to an initial-letter avatar.
class FighterAvatar extends StatelessWidget {
  final Fighter fighter;
  final double radius;

  const FighterAvatar({super.key, required this.fighter, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final asset = fighter.headshotAsset;
    if (asset == null) {
      return CircleAvatar(
        radius: radius,
        child: Text(fighter.name.substring(0, 1)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(asset),
    );
  }
}
