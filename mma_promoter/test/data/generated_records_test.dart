import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';

/// A roster big enough that these read as distribution facts rather than
/// sampling noise — a single 400-fighter roster is far too small to tell
/// a real bias from a bad seed.
List<Fighter> _largeSample() =>
    [for (var i = 0; i < 12; i++) ...generateStartingRoster()];

double _winRate(Fighter f) {
  final total = f.record.wins + f.record.losses;
  return total == 0 ? 0 : f.record.wins / total;
}

void main() {
  late List<Fighter> roster;

  setUpAll(() => roster = _largeSample());

  test('no fighter is generated more than 4 losses below .500', () {
    final offenders = roster
        .where((f) => f.record.losses - f.record.wins > 4)
        .map((f) => '${f.name} ${f.record.wins}-${f.record.losses}')
        .toList();
    expect(offenders, isEmpty,
        reason: 'records like 5-10 should never be generated');
  });

  test('nobody with a real career is generated winless', () {
    final winless = roster.where(
        (f) => f.record.wins + f.record.losses >= 3 && f.record.wins == 0);
    expect(winless, isEmpty);
  });

  test('win rate rises monotonically with overall', () {
    const bands = [(0, 55), (55, 65), (65, 75), (75, 85), (85, 101)];
    final rates = <double>[];

    for (final (lo, hi) in bands) {
      final group = roster
          .where((f) =>
              f.overall >= lo &&
              f.overall < hi &&
              f.record.wins + f.record.losses > 0)
          .toList();
      expect(group, isNotEmpty, reason: 'no fighters in OVR band $lo-$hi');
      rates.add(group.map(_winRate).reduce((a, b) => a + b) / group.length);
    }

    for (var i = 1; i < rates.length; i++) {
      expect(rates[i], greaterThan(rates[i - 1]),
          reason: 'OVR band ${bands[i]} should out-win ${bands[i - 1]}: $rates');
    }
    // And the spread should be substantial, not a rounding-error trend.
    expect(rates.last - rates.first, greaterThan(0.15));
  });

  test('elite fighters have records that match their skill', () {
    final elites = roster
        .where((f) => f.overall >= 88 && f.record.wins + f.record.losses >= 5)
        .toList();
    expect(elites, isNotEmpty);

    // The complaint this rule exists for: a 94 overall with a 10-28 record.
    final losing = elites.where((f) => f.record.losses >= f.record.wins);
    expect(losing, isEmpty);

    final avg = elites.map(_winRate).reduce((a, b) => a + b) / elites.length;
    expect(avg, greaterThan(0.7));
  });

  test('most fighters still have a winning record (80-90%)', () {
    final positive =
        roster.where((f) => f.record.wins > f.record.losses).length;
    expect(positive / roster.length, inInclusiveRange(0.80, 0.90));
  });

  test('most fighters still sit in a 4-30 fight career (85-90%)', () {
    final inBand = roster.where((f) {
      final total = f.record.wins + f.record.losses;
      return total >= 4 && total <= 30;
    }).length;
    expect(inBand / roster.length, inInclusiveRange(0.85, 0.90));
  });
}
