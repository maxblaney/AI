import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/booking/fight_hype.dart';

import '../support/fighter_fixtures.dart';

const _brawlerTendencies = Tendencies(
  strikingFrequency: 90,
  takedownFrequency: 5,
  kickFrequency: 50,
  clinchFrequency: 20,
  submissionAttempts: 5,
  groundAndPound: 60,
  positionControl: 10,
  standUpPreference: 90,
  wallWork: 10,
  aggression: 95,
  counterStriking: 20,
  headHunting: 90,
  bodyAttacks: 50,
  legAttacks: 40,
);

const _grinderTendencies = Tendencies(
  strikingFrequency: 20,
  takedownFrequency: 90,
  kickFrequency: 10,
  clinchFrequency: 80,
  submissionAttempts: 20,
  groundAndPound: 30,
  positionControl: 95,
  standUpPreference: 10,
  wallWork: 90,
  aggression: 15,
  counterStriking: 60,
  headHunting: 10,
  bodyAttacks: 30,
  legAttacks: 20,
);

Fighter _brawler(String id, {int stat = 75, int popularity = 40}) =>
    testFighter(id,
        stat: stat,
        popularity: popularity,
        power: 90,
        mentalAggression: 90,
        killerInstinct: 90,
        tendencies: _brawlerTendencies);

Fighter _grinder(String id, {int stat = 75, int popularity = 40}) =>
    testFighter(id,
        stat: stat,
        popularity: popularity,
        power: 30,
        mentalAggression: 20,
        killerInstinct: 20,
        tendencies: _grinderTendencies);

int _score(Fighter a, Fighter b,
        {TitleFightType title = TitleFightType.none}) =>
    HypeCalculator.forFight(a: a, b: b, titleFightType: title).score;

void main() {
  test('stays inside 0-100 across extremes', () {
    final scores = [
      _score(_grinder('a', stat: 40, popularity: 0),
          _grinder('b', stat: 40, popularity: 0)),
      _score(_brawler('a', stat: 99, popularity: 100),
          _brawler('b', stat: 99, popularity: 100),
          title: TitleFightType.championship),
    ];
    for (final score in scores) {
      expect(score, inInclusiveRange(0, 100));
    }
    expect(scores.first, lessThan(scores.last));
  });

  test('star power lifts a fight', () {
    final unknowns =
        _score(_brawler('a', popularity: 5), _brawler('b', popularity: 5));
    final stars =
        _score(_brawler('c', popularity: 95), _brawler('d', popularity: 95));
    expect(stars, greaterThan(unknowns));
  });

  test('a squash is worth less than a pick-em between the same names', () {
    final even =
        _score(_brawler('a', stat: 75), _brawler('b', stat: 75));
    final squash =
        _score(_brawler('a', stat: 92), _brawler('b', stat: 45));

    expect(squash, lessThan(even),
        reason: 'nobody buys a ticket for a foregone conclusion');
    expect(
      HypeCalculator.forFight(a: _brawler('a', stat: 92), b: _brawler('b', stat: 45))
          .competitiveness,
      lessThan(
        HypeCalculator.forFight(a: _brawler('a'), b: _brawler('b'))
            .competitiveness,
      ),
    );
  });

  test('two grinders are less hyped than two brawlers', () {
    expect(_score(_grinder('a'), _grinder('b')),
        lessThan(_score(_brawler('c'), _brawler('d'))));
  });

  test('a belt on the line raises the stakes and the score', () {
    final a = _brawler('a');
    final b = _brawler('b');

    final normal = HypeCalculator.forFight(a: a, b: b);
    final title = HypeCalculator.forFight(
        a: a, b: b, titleFightType: TitleFightType.championship);
    final interim = HypeCalculator.forFight(
        a: a, b: b, titleFightType: TitleFightType.interim);

    expect(title.stakes, greaterThan(interim.stakes));
    expect(interim.stakes, greaterThan(normal.stakes));
    expect(title.score, greaterThan(normal.score));
  });

  test('a champion in a non-title fight still carries weight', () {
    final champ = _brawler('champ').copyWith(belts: {WeightClass.lightweight});
    final plain = _brawler('plain');
    expect(
      HypeCalculator.forFight(a: champ, b: plain).stakes,
      greaterThan(HypeCalculator.forFight(a: _brawler('x'), b: plain).stakes),
    );
  });

  test('labels run through every band', () {
    FightHype at(int score) => FightHype(
          score: score,
          starPower: 0,
          competitiveness: 0,
          violence: 0,
          stakes: 0,
        );
    expect(at(90).label, 'Must-See');
    expect(at(70).label, 'Big Fight');
    expect(at(50).label, 'Solid Draw');
    expect(at(35).label, 'Decent Scrap');
    expect(at(10).label, 'Filler');
  });

  test('names the weakest factor, and stays quiet when nothing is weak', () {
    const weakStars = FightHype(
      score: 40,
      starPower: 8,
      competitiveness: 90,
      violence: 80,
      stakes: 70,
    );
    expect(weakStars.weakestLink, contains('draw'));

    const allStrong = FightHype(
      score: 85,
      starPower: 80,
      competitiveness: 88,
      violence: 75,
      stakes: 90,
    );
    expect(allStrong.weakestLink, isNull);
  });
}
