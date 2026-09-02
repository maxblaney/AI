import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/cosmetics/fighter_headshots.dart';

/// Every path the tone map hands out has to be a file that exists — a
/// typo here is a crash in the avatar, not a compile error.
void main() {
  test('every rolled headshot path points at real art', () {
    final rng = Random(4);
    final rolled = <String>{};
    for (final nationality in ['Nigeria', 'USA', 'Brazil', 'Japan',
      'Netherlands', 'Cuba', 'England', 'Nowhereland']) {
      for (var i = 0; i < 400; i++) {
        rolled.add(rollHeadshot(nationality, rng));
      }
    }

    expect(rolled, isNotEmpty);
    for (final path in rolled) {
      expect(File(path).existsSync(), isTrue, reason: '$path does not exist');
    }
  });

  test('an unknown nationality still gets a face', () {
    final rng = Random(9);
    for (var i = 0; i < 50; i++) {
      final path = rollHeadshot('Atlantis', rng);
      expect(File(path).existsSync(), isTrue);
    }
  });

  test('the art the map draws from covers all three tones', () {
    // Guards a sheet being sliced and then only half-wired: rolling
    // enough times across a spread of nationalities should reach every
    // tone the game has art for.
    final rng = Random(11);
    final rolled = <String>{};
    for (var i = 0; i < 4000; i++) {
      rolled.add(rollHeadshot('USA', rng));
    }

    for (final tone in ['deep', 'medium', 'tan']) {
      expect(
        rolled.any((p) => p.contains('/$tone')),
        isTrue,
        reason: 'nothing from the $tone set was ever rolled',
      );
    }
  });
}
