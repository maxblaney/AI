import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_theme.dart';

/// Circular fighter portrait — the fighter's pixel-art headshot on a
/// neutral studio backdrop, falling back to an initial-letter avatar for
/// fighters saved before portraits existed.
class FighterAvatar extends StatelessWidget {
  final Fighter fighter;
  final double radius;

  const FighterAvatar({super.key, required this.fighter, this.radius = 20});

  /// The art is 32x32 with the head inset a few pixels on every side, so
  /// a slight zoom fills the circle more like a real headshot crop. Held
  /// below the 1.14 at which the tightest-framed sprite would start
  /// losing its hairline.
  static const double _headshotZoom = 1.12;

  static const _backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.avatarBackdropTop, AppColors.avatarBackdropBottom],
  );

  @override
  Widget build(BuildContext context) {
    final asset = fighter.headshotAsset;

    return Container(
      width: radius * 2,
      height: radius * 2,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: _backdrop,
      ),
      // Painted over the child, so the rim stays a clean circle on top of
      // the portrait rather than being clipped away with it.
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: asset == null
          ? Center(
              child: Text(
                fighter.name.substring(0, 1),
                style: TextStyle(
                  fontSize: radius * 0.9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : Transform.scale(
              scale: _headshotZoom,
              child: Image.asset(
                asset,
                // Pixel art: nearest-neighbour keeps the pixels square and
                // crisp when scaled past their native 32x32, instead of
                // smearing them into a blur.
                filterQuality: FilterQuality.none,
                fit: BoxFit.contain,
              ),
            ),
    );
  }
}
