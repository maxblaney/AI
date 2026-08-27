import 'dart:math';

import '../../core/utils/id_generator.dart';
import '../models/models.dart';

class _NamePool {
  final List<String> first;
  final List<String> last;
  const _NamePool(this.first, this.last);
}

/// First/last name pools keyed by nationality, so a generated fighter's
/// name is at least plausible for where they're from (a Brazilian fighter
/// gets a name like "Thiago Silva", not a randomly-assembled mismatch).
const Map<String, _NamePool> _namePoolsByNationality = {
  'USA': _NamePool(
    ['James', 'Michael', 'Chris', 'Tyler', 'Josh', 'Kevin', 'Brandon', 'Derek', 'Cody', 'Blake'],
    ['Johnson', 'Williams', 'Miller', 'Davis', 'Anderson', 'Thompson', 'Mitchell', 'Carter', 'Foster', 'Coleman'],
  ),
  'Brazil': _NamePool(
    ['Thiago', 'Rafael', 'Bruno', 'Anderson', 'Mateus', 'Gabriel', 'Lucas', 'Renan', 'Vitor', 'Diego'],
    ['Silva', 'Santos', 'Oliveira', 'Souza', 'Costa', 'Pereira', 'Almeida', 'Ferreira', 'Rodrigues', 'Barbosa'],
  ),
  'Russia': _NamePool(
    ['Viktor', 'Dmitri', 'Nikolai', 'Sergei', 'Ivan', 'Alexei', 'Pavel', 'Yuri', 'Oleg', 'Maxim'],
    ['Volkov', 'Petrov', 'Sokolov', 'Ivanov', 'Kuznetsov', 'Popov', 'Smirnov', 'Novikov', 'Fedorov', 'Orlov'],
  ),
  'Poland': _NamePool(
    ['Krzysztof', 'Marek', 'Piotr', 'Tomasz', 'Pawel', 'Adam', 'Michal', 'Wojciech', 'Rafal', 'Kamil'],
    ['Kowalski', 'Nowak', 'Wisniewski', 'Wojcik', 'Kaminski', 'Lewandowski', 'Zielinski', 'Szymanski', 'Dabrowski', 'Kozlowski'],
  ),
  'Nigeria': _NamePool(
    ['Chidi', 'Emeka', 'Segun', 'Kunle', 'Chinedu', 'Tunde', 'Femi', 'Obi', 'Ikenna', 'Uche'],
    ['Okafor', 'Okonkwo', 'Adeyemi', 'Balogun', 'Eze', 'Nwosu', 'Afolabi', 'Chukwu', 'Adeleke', 'Okoro'],
  ),
  'Japan': _NamePool(
    ['Hiroshi', 'Yuto', 'Kenji', 'Takeshi', 'Daiki', 'Ryota', 'Sho', 'Haruto', 'Kaito', 'Tatsuya'],
    ['Tanaka', 'Nakamura', 'Suzuki', 'Sato', 'Yamamoto', 'Watanabe', 'Ito', 'Kobayashi', 'Kato', 'Yoshida'],
  ),
  'Ireland': _NamePool(
    ['Connor', 'Declan', 'Sean', 'Liam', 'Cian', 'Aidan', 'Ronan', 'Eoin', 'Fionn', 'Darragh'],
    ['Reilly', 'Murphy', 'Kelly', 'Byrne', 'Ryan', 'Walsh', 'Gallagher', 'Doyle', 'McCarthy', 'Fitzgerald'],
  ),
  'Sweden': _NamePool(
    ['Erik', 'Lukas', 'Viktor', 'Oscar', 'Gustav', 'Anton', 'Filip', 'Emil', 'Axel', 'Hugo'],
    ['Lindqvist', 'Andersson', 'Johansson', 'Karlsson', 'Nilsson', 'Eriksson', 'Larsson', 'Olsson', 'Persson', 'Svensson'],
  ),
  'Mexico': _NamePool(
    ['Diego', 'Sergio', 'Miguel', 'Alejandro', 'Carlos', 'Fernando', 'Rodrigo', 'Gustavo', 'Emilio', 'Hector'],
    ['Reyes', 'Hernandez', 'Garcia', 'Martinez', 'Lopez', 'Gonzalez', 'Ramirez', 'Torres', 'Flores', 'Vasquez'],
  ),
  'Canada': _NamePool(
    ['Owen', 'Caleb', 'Jordan', 'Mason', 'Logan', 'Ethan', 'Noah', 'Wyatt', 'Carter', 'Jack'],
    ['MacLeod', 'Campbell', 'Stewart', 'Fraser', 'Wilson', 'Bennett', 'Cameron', 'Fletcher', 'Grant', 'Robertson'],
  ),
  'England': _NamePool(
    ['Oliver', 'George', 'Harry', 'Charlie', 'Freddie', 'Alfie', 'Archie', 'Theo', 'Jamie', 'Elliot'],
    ['Hughes', 'Baker', 'Cooper', 'Bailey', 'Turner', 'Parker', 'Wood', 'Hall', 'Wright', 'Kensington'],
  ),
  'South Korea': _NamePool(
    ['Min-jun', 'Seo-jun', 'Do-yun', 'Ji-ho', 'Joon-ho', 'Hyun-woo', 'Tae-yang', 'Sung-min', 'Jae-won', 'Woo-jin'],
    ['Kim', 'Lee', 'Park', 'Choi', 'Jung', 'Kang', 'Han', 'Yoon', 'Song', 'Jang'],
  ),
};

/// Nationalities the generator knows how to produce fitting names for.
/// Reused by the fighter editor so manually-created fighters stay
/// consistent with generated ones.
final List<String> knownNationalities = _namePoolsByNationality.keys.toList();

final List<String> _nationalities = knownNationalities;

/// Generates a fresh, unsigned talent pool spread across every weight
/// class for a new game. Some are strong enough to headline immediately,
/// most are mid-tier prospects and journeymen — enough variety to make
/// early signing decisions interesting.
List<Fighter> generateStartingRoster({
  int fightersPerWeightClass = 8,
  Random? random,
}) {
  final rng = random ?? Random();
  return [
    for (final weightClass in WeightClass.values)
      for (var i = 0; i < fightersPerWeightClass; i++)
        _generateFighter(weightClass, rng),
  ];
}

Fighter _generateFighter(WeightClass weightClass, Random rng) {
  final age = 21 + rng.nextInt(15); // 21-35
  final int experienceFights = max(0, (age - 20)) * (1 + rng.nextInt(3));
  final winRate = 0.4 + rng.nextDouble() * 0.4; // 40-80%
  final wins = (experienceFights * winRate).round();
  final losses = experienceFights - wins;

  // Younger/inexperienced fighters skew toward raw-but-uneven stats;
  // veterans skew toward higher, more balanced stats.
  final int skillFloor = 35 + min(experienceFights, 20);
  final int skillCeiling = min(95, skillFloor + 35);
  int stat() => skillFloor + rng.nextInt(max(1, skillCeiling - skillFloor));

  final tags = StyleTag.values.toList()..shuffle(rng);
  final styleTags = tags.take(1 + rng.nextInt(2)).toList();

  final nationality = _nationalities[rng.nextInt(_nationalities.length)];

  return Fighter(
    id: newId(),
    name: _generateName(nationality, rng),
    age: age,
    nationality: nationality,
    weightClass: weightClass,
    record: FightRecord(wins: wins, losses: losses, draws: rng.nextInt(2)),
    stats: FighterStats(
      striking: stat(),
      grappling: stat(),
      cardio: stat(),
      chin: stat(),
      power: stat(),
    ),
    popularity: 10 + rng.nextInt(50),
    morale: 65 + rng.nextInt(25),
    injuryStatus: InjuryStatus.healthy,
    winStreak: rng.nextInt(4),
    styleTags: styleTags,
  );
}

String _generateName(String nationality, Random rng) {
  final pool = _namePoolsByNationality[nationality]!;
  final first = pool.first[rng.nextInt(pool.first.length)];
  final last = pool.last[rng.nextInt(pool.last.length)];
  return '$first $last';
}

/// Signs the top few fighters in each weight class to the org's initial
/// roster so the player has a presence in every division immediately,
/// leaving the rest as free agents.
List<Fighter> signStartingRoster(
  List<Fighter> pool, {
  int signPerWeightClass = 2,
  DateTime? signedOn,
}) {
  final date = signedOn ?? DateTime.now();
  final toSign = <String>{};

  for (final weightClass in WeightClass.values) {
    final inClass = pool.where((f) => f.weightClass == weightClass).toList()
      ..sort((a, b) => b.stats.overall.compareTo(a.stats.overall));
    toSign.addAll(inClass.take(signPerWeightClass).map((f) => f.id));
  }

  return pool.map((fighter) {
    if (!toSign.contains(fighter.id)) return fighter;
    return fighter.copyWith(
      contract: Contract(
        id: newId(),
        fighterId: fighter.id,
        fightsRemaining: 3 + Random().nextInt(3),
        payPerFight: 1000 + fighter.popularity * 40,
        exclusive: true,
        signedOn: date,
      ),
    );
  }).toList();
}

Organization generateStartingOrganization({
  required String name,
  required ReputationTier tier,
}) {
  return Organization(
    id: newId(),
    name: name,
    reputationTier: tier,
    reputationPoints: 0,
    cashBalance: tier.startingCash,
    fanbaseSize: tier.startingFanbase,
    homeRegion: 'Midwest, USA',
    promotionBudget: (tier.startingCash * 0.1).round(),
  );
}
