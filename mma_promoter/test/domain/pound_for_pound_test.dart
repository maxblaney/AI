import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/rankings/ladder.dart';
import 'package:mma_promoter/domain/rankings/pound_for_pound.dart';

import '../support/fighter_fixtures.dart';

Fighter _f(
  String id, {
  required int elo,
  WeightClass division = WeightClass.lightweight,
  Set<WeightClass> belts = const {},
  Set<WeightClass> interimBelts = const {},
}) {
  return testFighter(id).copyWith(
    name: id,
    weightClass: division,
    eloRating: elo,
    belts: belts,
    interimBelts: interimBelts,
  );
}

List<String> _order(List<Fighter> fighters) =>
    PoundForPound.rank(fighters).map((f) => f.id).toList();

void main() {
  test('a champion outranks the contenders in his own division', () {
    // The contender is 80 Elo clear, but the champion holds the belt over
    // him — if he were really better he'd have taken it.
    final order = _order([
      _f('contender', elo: 1680),
      _f('champ', elo: 1600, belts: {WeightClass.lightweight}),
    ]);

    expect(order, ['champ', 'contender']);
  });

  test('a contender far enough clear stays above his champion', () {
    // The extreme case the rule leaves room for: past the credit cap,
    // the ranking should say what it sees.
    final order = _order([
      _f('contender', elo: 1600 + PoundForPound.maxBeltCredit + 40),
      _f('champ', elo: 1600, belts: {WeightClass.lightweight}),
    ]);

    expect(order, ['contender', 'champ']);
  });

  test('the belt is worth nothing against other divisions', () {
    // A lightweight champion should not leapfrog a better welterweight
    // he has never fought — P4P across divisions is still earned on Elo.
    final order = _order([
      _f('welterweight', elo: 1750, division: WeightClass.welterweight),
      _f('lw-champ', elo: 1600, belts: {WeightClass.lightweight}),
      _f('lw-contender', elo: 1590),
    ]);

    expect(order, ['welterweight', 'lw-champ', 'lw-contender']);
  });

  test('a champion already ahead of his division gets no free lift', () {
    final fighters = [
      _f('champ', elo: 1700, belts: {WeightClass.lightweight}),
      _f('contender', elo: 1500),
    ];
    final scores = PoundForPound.scoresFor(fighters);

    expect(scores['champ'], 1700, reason: 'he did not need the help');
    expect(scores['contender'], 1500);
  });

  test('a double champ takes the larger credit, not both', () {
    final fighters = [
      _f('double', elo: 1500, belts: {
        WeightClass.lightweight,
        WeightClass.welterweight,
      }),
      _f('lw-contender', elo: 1540),
      _f('ww-contender', elo: 1580, division: WeightClass.welterweight),
    ];
    final scores = PoundForPound.scoresFor(fighters);

    // Enough to clear the welterweight (the harder of the two), not
    // enough to clear both gaps stacked.
    expect(scores['double'], 1581);
  });

  test('an interim belt is worth less than the real one', () {
    final interim = [
      _f('interim', elo: 1500, interimBelts: {WeightClass.lightweight}),
      _f('contender', elo: 1700),
    ];
    final undisputed = [
      _f('champ', elo: 1500, belts: {WeightClass.lightweight}),
      _f('contender', elo: 1700),
    ];

    final interimCredit =
        PoundForPound.scoresFor(interim)['interim']! - 1500;
    final champCredit = PoundForPound.scoresFor(undisputed)['champ']! - 1500;

    expect(interimCredit, PoundForPound.maxInterimBeltCredit);
    expect(champCredit, PoundForPound.maxBeltCredit);
    expect(interimCredit, lessThan(champCredit));

    // And with a 200-point gap, neither is enough — the contender stays up.
    expect(_order(interim), ['contender', 'interim']);
  });

  test('an empty division asks nothing of its champion', () {
    final fighters = [
      _f('champ', elo: 1500, belts: {WeightClass.heavyweight},
          division: WeightClass.heavyweight),
    ];
    expect(PoundForPound.scoresFor(fighters)['champ'], 1500);
  });

  test('ranking does not disturb the list it was given', () {
    final fighters = [
      _f('a', elo: 1400),
      _f('b', elo: 1600, belts: {WeightClass.lightweight}),
    ];
    final before = fighters.map((f) => f.id).toList();
    PoundForPound.rank(fighters);
    expect(fighters.map((f) => f.id).toList(), before);
  });

  test('equal scores order stably by Elo then name', () {
    final order = _order([
      _f('zeta', elo: 1500),
      _f('alpha', elo: 1500),
      _f('beta', elo: 1501),
    ]);
    expect(order, ['beta', 'alpha', 'zeta']);
  });

  test('pound-for-pound is a top fifteen like every other ladder', () {
    final crowd = [
      for (var i = 0; i < 40; i++)
        testFighter('f$i').copyWith(eloRating: 2000 - i, isRanked: true),
    ];

    final ranked = PoundForPound.rank(crowd);

    expect(ranked, hasLength(Ladder.size));
    expect(ranked.first.id, 'f0');
    expect(ranked.last.id, 'f14');
  });
}
