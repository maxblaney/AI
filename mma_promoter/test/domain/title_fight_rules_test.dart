import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/booking/title_fight_rules.dart';

import '../support/fighter_fixtures.dart';

Fighter _f(
  String name, {
  WeightClass division = WeightClass.lightweight,
  Set<WeightClass> belts = const {},
  Set<WeightClass> interimBelts = const {},
}) {
  return testFighter(name).copyWith(
    name: name,
    weightClass: division,
    belts: belts,
    interimBelts: interimBelts,
  );
}

void main() {
  final champ = _f('Champ', belts: {WeightClass.lightweight});
  final interimChamp =
      _f('Interim', interimBelts: {WeightClass.lightweight});
  final contender = _f('Contender');

  test('a champion at home is always defending', () {
    expect(
      TitleFightRules.resolve(
        a: champ,
        b: contender,
        division: WeightClass.lightweight,
        chosen: TitleFightType.none,
      ),
      TitleFightType.championship,
      reason: 'there is no such thing as a champ taking a non-title fight '
          'in his own division',
    );
  });

  test('it does not matter which corner the champion is in', () {
    expect(
      TitleFightRules.resolve(
        a: contender,
        b: champ,
        division: WeightClass.lightweight,
        chosen: TitleFightType.none,
      ),
      TitleFightType.championship,
    );
  });

  test('a champion fighting up a division is not defending anything', () {
    // The lightweight belt is not on the line at welterweight.
    expect(
      TitleFightRules.forcedType(
        a: champ,
        b: _f('Welterweight', division: WeightClass.welterweight),
        division: WeightClass.welterweight,
      ),
      isNull,
    );
    expect(
      TitleFightRules.resolve(
        a: champ,
        b: _f('Welterweight', division: WeightClass.welterweight),
        division: WeightClass.welterweight,
        chosen: TitleFightType.none,
      ),
      TitleFightType.none,
      reason: 'the player can still put a belt up, but nothing is forced',
    );
  });

  test('an interim champion forces an interim fight', () {
    expect(
      TitleFightRules.resolve(
        a: interimChamp,
        b: contender,
        division: WeightClass.lightweight,
        chosen: TitleFightType.none,
      ),
      TitleFightType.interim,
    );
  });

  test('champion versus interim champion is for the real belt', () {
    expect(
      TitleFightRules.resolve(
        a: champ,
        b: interimChamp,
        division: WeightClass.lightweight,
        chosen: TitleFightType.none,
      ),
      TitleFightType.championship,
      reason: 'a unification bout is for the undisputed title',
    );
  });

  test('two contenders are whatever the matchmaker says', () {
    for (final chosen in TitleFightType.values) {
      expect(
        TitleFightRules.resolve(
          a: contender,
          b: _f('Other'),
          division: WeightClass.lightweight,
          chosen: chosen,
        ),
        chosen,
      );
    }
  });

  test('an unfilled corner forces nothing', () {
    expect(
      TitleFightRules.forcedType(
        a: null,
        b: null,
        division: WeightClass.lightweight,
      ),
      isNull,
    );
    expect(
      TitleFightRules.forcedType(
        a: champ,
        b: null,
        division: WeightClass.lightweight,
      ),
      TitleFightType.championship,
      reason: 'one champion is enough to put the belt up',
    );
  });

  group('explain', () {
    test('names the champion and the belt', () {
      final reason = TitleFightRules.explain(
        a: champ,
        b: contender,
        division: WeightClass.lightweight,
      );
      expect(reason, contains('Champ'));
      expect(reason, contains('Lightweight title'));
    });

    test('says nothing when nothing is forced', () {
      expect(
        TitleFightRules.explain(
          a: contender,
          b: _f('Other'),
          division: WeightClass.lightweight,
        ),
        isNull,
      );
    });
  });
}
