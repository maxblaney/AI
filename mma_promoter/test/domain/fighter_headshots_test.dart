import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/domain/cosmetics/fighter_headshots.dart';

/// Which tone bucket an asset path belongs to, read off its filename
/// (`assets/fighters/deep_03.png` -> `deep`).
String _toneOf(String asset) => asset.split('/').last.split('_').first;

void main() {
  group('rollHeadshot', () {
    test('always returns art, for known and unknown nationalities alike', () {
      final rng = Random(7);
      for (final nationality in [...knownNationalities, 'Atlantis']) {
        for (var i = 0; i < 50; i++) {
          final asset = rollHeadshot(nationality, rng);
          expect(asset, startsWith('assets/fighters/'));
          expect(asset, endsWith('.png'));
        }
      }
    });

    test('Northern/Eastern European fighters never draw the deep tones', () {
      final rng = Random(11);
      for (final nationality in ['Russia', 'Poland', 'Sweden', 'Czech Republic']) {
        for (var i = 0; i < 300; i++) {
          expect(_toneOf(rollHeadshot(nationality, rng)), 'tan');
        }
      }
    });

    test('Nigerian fighters skew heavily to the deep tones', () {
      final rng = Random(13);
      final tones = <String, int>{};
      for (var i = 0; i < 1000; i++) {
        final tone = _toneOf(rollHeadshot('Nigeria', rng));
        tones[tone] = (tones[tone] ?? 0) + 1;
      }
      expect(tones['deep']! / 1000, greaterThan(0.5));
      expect(tones['tan']! / 1000, lessThan(0.15));
    });

    test('the USA draws a genuine spread across every tone', () {
      final rng = Random(17);
      final tones = <String, int>{};
      for (var i = 0; i < 1000; i++) {
        final tone = _toneOf(rollHeadshot('USA', rng));
        tones[tone] = (tones[tone] ?? 0) + 1;
      }
      for (final tone in ['deep', 'medium', 'tan']) {
        expect(tones[tone] ?? 0, greaterThan(100), reason: 'missing $tone');
      }
    });
  });

  group('generated roster', () {
    test('every generated fighter has a headshot', () {
      final roster = generateStartingRoster();
      expect(roster.where((f) => f.headshotAsset == null), isEmpty);
    });

    test('names rarely collide now that the pools are large', () {
      final roster = generateStartingRoster();
      final unique = roster.map((f) => f.name).toSet();
      final duplicateRate = 1 - unique.length / roster.length;
      expect(duplicateRate, lessThan(0.06));
    });
  });
}
