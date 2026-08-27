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
  'Australia': _NamePool(
    ['Jack', 'Liam', 'Cooper', 'Riley', 'Lachlan', 'Ethan', 'Jai', 'Blake', 'Corey', 'Tyson'],
    ['Mitchell', 'Whittaker', 'Robinson', 'Hunt', 'Bennett', 'Fraser', 'Kennedy', 'Hayes', 'Sinclair', 'Barrett'],
  ),
  'Netherlands': _NamePool(
    ['Bas', 'Sem', 'Daan', 'Joris', 'Kees', 'Rick', 'Wouter', 'Lars', 'Erik', 'Twan'],
    ['de Jong', 'Bakker', 'Visser', 'Smit', 'Mulder', 'Dekker', 'Hendriks', 'Verhoeven', 'Peeters', 'Willems'],
  ),
  'Germany': _NamePool(
    ['Lukas', 'Felix', 'Jonas', 'Maximilian', 'Niklas', 'Tobias', 'Sven', 'Matthias', 'Dennis', 'Marcel'],
    ['Muller', 'Schmidt', 'Schneider', 'Fischer', 'Weber', 'Wagner', 'Becker', 'Hoffmann', 'Schulz', 'Koch'],
  ),
  'France': _NamePool(
    ['Antoine', 'Julien', 'Nicolas', 'Mathieu', 'Thomas', 'Cedric', 'Kevin', 'Ludovic', 'Jerome', 'Damien'],
    ['Dubois', 'Lefevre', 'Moreau', 'Girard', 'Bonnet', 'Rousseau', 'Fontaine', 'Chevalier', 'Robert', 'Simon'],
  ),
  'Georgia': _NamePool(
    ['Levan', 'Giorgi', 'Nika', 'Davit', 'Irakli', 'Zurab', 'Beka', 'Saba', 'Luka', 'Otar'],
    ['Beridze', 'Kapanadze', 'Lomidze', 'Tskitishvili', 'Chkheidze', 'Gelashvili', 'Meskhi', 'Sichinava', 'Kiladze', 'Iashvili'],
  ),
  'Kazakhstan': _NamePool(
    ['Aslan', 'Nurlan', 'Yerlan', 'Dias', 'Almas', 'Sanzhar', 'Bekzat', 'Timur', 'Ruslan', 'Daulet'],
    ['Bekov', 'Nurgaliyev', 'Zhaksylykov', 'Kairatov', 'Seitkali', 'Amanzholov', 'Kenzhebek', 'Tulegen', 'Abenov', 'Shokan'],
  ),
  'South Africa': _NamePool(
    ['Dricus', 'Chad', 'Ryan', 'Warren', 'Johan', 'Pieter', 'Riaan', 'Deon', 'Cameron', 'Trevor'],
    ['van der Merwe', 'Botha', 'Nel', 'Coetzee', 'Pretorius', 'Fourie', 'Kruger', 'Marais', 'Steenkamp', 'du Plessis'],
  ),
  'China': _NamePool(
    ['Wei', 'Jun', 'Hao', 'Bo', 'Liang', 'Feng', 'Chao', 'Yong', 'Tao', 'Peng'],
    ['Zhang', 'Wang', 'Li', 'Liu', 'Chen', 'Yang', 'Zhao', 'Huang', 'Wu', 'Sun'],
  ),
  'Thailand': _NamePool(
    ['Somchai', 'Anucha', 'Chatchai', 'Kiat', 'Prasit', 'Sombat', 'Narong', 'Wichai', 'Somsak', 'Rangsan'],
    ['Sukhumvit', 'Charoensuk', 'Wongsawat', 'Boonmee', 'Saetang', 'Thongchai', 'Rattanakosin', 'Phromma', 'Chaisurin', 'Kittisak'],
  ),
  'Philippines': _NamePool(
    ['Mark', 'Jayson', 'Rico', 'Bryan', 'Jerome', 'Renato', 'Ferdinand', 'Noel', 'Rolando', 'Danilo'],
    ['Santos', 'Reyes', 'Cruz', 'Bautista', 'Ocampo', 'Mercado', 'Aquino', 'Gonzales', 'Pascual', 'Rivera'],
  ),
  'Ukraine': _NamePool(
    ['Andriy', 'Oleksandr', 'Mykola', 'Bohdan', 'Taras', 'Vitaliy', 'Roman', 'Yevhen', 'Ihor', 'Denys'],
    ['Shevchenko', 'Kovalenko', 'Bondarenko', 'Tkachenko', 'Melnyk', 'Kravchenko', 'Oliynyk', 'Moroz', 'Rudenko', 'Marchenko'],
  ),
  'Czech Republic': _NamePool(
    ['Jakub', 'Tomas', 'Ondrej', 'Vaclav', 'Milan', 'Petr', 'Radek', 'Jiri', 'Lukas', 'Martin'],
    ['Novak', 'Svoboda', 'Novotny', 'Dvorak', 'Cerny', 'Prochazka', 'Kucera', 'Vesely', 'Horak', 'Nemec'],
  ),
  'Croatia': _NamePool(
    ['Ivan', 'Marko', 'Luka', 'Ante', 'Josip', 'Filip', 'Tomislav', 'Nikola', 'Petar', 'Mario'],
    ['Horvat', 'Kovacic', 'Babic', 'Maric', 'Juric', 'Vukovic', 'Novak', 'Kovac', 'Barisic', 'Matic'],
  ),
  'Italy': _NamePool(
    ['Marco', 'Luca', 'Matteo', 'Alessandro', 'Davide', 'Simone', 'Francesco', 'Andrea', 'Stefano', 'Giovanni'],
    ['Rossi', 'Russo', 'Ferrari', 'Esposito', 'Bianchi', 'Romano', 'Colombo', 'Ricci', 'Marino', 'Greco'],
  ),
  'Spain': _NamePool(
    ['Javier', 'Carlos', 'Alejandro', 'Pablo', 'Sergio', 'Ivan', 'Ruben', 'Adrian', 'Raul', 'Victor'],
    ['Garcia', 'Fernandez', 'Lopez', 'Martinez', 'Sanchez', 'Perez', 'Gomez', 'Diaz', 'Alvarez', 'Romero'],
  ),
  'Cuba': _NamePool(
    ['Yoel', 'Alexis', 'Yuniel', 'Reinier', 'Osvaldo', 'Yosvani', 'Leonel', 'Frank', 'Yasiel', 'Yordan'],
    ['Rodriguez', 'Fernandez', 'Gonzalez', 'Perez', 'Alvarez', 'Diaz', 'Castillo', 'Ramos', 'Pena', 'Vega'],
  ),
  'Dominican Republic': _NamePool(
    ['Luis', 'Jose', 'Manuel', 'Rafael', 'Pedro', 'Julio', 'Ramon', 'Wilfredo', 'Cristian', 'Elvis'],
    ['Perez', 'Rosario', 'Mercedes', 'Guzman', 'Familia', 'Peguero', 'Encarnacion', 'Abreu', 'Tavarez', 'Beltre'],
  ),
  'Argentina': _NamePool(
    ['Mateo', 'Nicolas', 'Santiago', 'Facundo', 'Franco', 'Ezequiel', 'Ignacio', 'Agustin', 'Federico', 'Emiliano'],
    ['Gonzalez', 'Rodriguez', 'Fernandez', 'Lopez', 'Diaz', 'Perez', 'Martinez', 'Sosa', 'Romero', 'Alvarez'],
  ),
  'Scotland': _NamePool(
    ['Fraser', 'Callum', 'Ewan', 'Angus', 'Struan', 'Hamish', 'Finlay', 'Lewis', 'Ross', 'Kyle'],
    ['MacDonald', 'Robertson', 'Wallace', 'Ferguson', 'Morrison', 'Cunningham', 'Sutherland', 'Sinclair', 'Anderson', 'Buchanan'],
  ),
  'Cameroon': _NamePool(
    ['Franck', 'Yannick', 'Junior', 'Herve', 'Serge', 'Landry', 'Patrick', 'Cedric', 'Gaston', 'Blaise'],
    ['Mbarga', 'Ngoua', 'Fotso', 'Talla', 'Mvondo', 'Ateba', 'Biya', 'Njoya', 'Onana', 'Kamga'],
  ),
};

/// Nationalities the generator knows how to produce fitting names for.
/// Reused by the fighter editor so manually-created fighters stay
/// consistent with generated ones.
final List<String> knownNationalities = _namePoolsByNationality.keys.toList();

/// Plausible height range (inches) by weight class — heavier divisions
/// skew taller, same as real MMA.
const Map<WeightClass, (int, int)> _heightRangeByWeightClass = {
  WeightClass.flyweight: (63, 68),
  WeightClass.bantamweight: (65, 70),
  WeightClass.featherweight: (66, 71),
  WeightClass.lightweight: (67, 73),
  WeightClass.welterweight: (69, 75),
  WeightClass.middleweight: (70, 76),
  WeightClass.lightHeavyweight: (71, 77),
  WeightClass.heavyweight: (72, 80),
};

/// Fighting-stat fields boosted (positive) or held back (negative) by each
/// [FightingStyle], applied on top of a fighter's random baseline so a
/// wrestler's sheet actually looks like a wrestler's. Values are deltas.
const Map<FightingStyle, Map<String, int>> _styleFightingDeltas = {
  FightingStyle.boxer: {
    'punching': 14, 'accuracy': 10, 'defense': 8,
    'kicking': -14, 'takedowns': -10, 'wrestling': -8, 'submissionOffense': -8,
  },
  FightingStyle.kickboxer: {
    'kicking': 14, 'punching': 8, 'power': 8,
    'takedowns': -12, 'wrestling': -10, 'submissionOffense': -10,
  },
  FightingStyle.muayThai: {
    'kicking': 12, 'power': 10, 'takedownDefense': 8,
    'submissionOffense': -10, 'submissionDefense': -6,
  },
  FightingStyle.wrestler: {
    'takedowns': 16, 'wrestling': 16, 'groundAndPound': 10, 'takedownDefense': 8,
    'kicking': -12, 'submissionOffense': -6,
  },
  FightingStyle.bjj: {
    'submissionOffense': 16, 'submissionDefense': 12, 'grappling': 10,
    'kicking': -8, 'power': -8, 'takedowns': -4,
  },
  FightingStyle.wrestlingHeavy: {
    'takedowns': 12, 'wrestling': 12, 'groundAndPound': 8, 'grappling': 6,
    'kicking': -10,
  },
  FightingStyle.counterStriker: {
    'accuracy': 12, 'defense': 12, 'speed': 8,
    'takedowns': -8,
  },
  FightingStyle.pressureFighter: {
    'power': 10, 'punching': 8,
    'defense': -8,
  },
  FightingStyle.pointFighter: {
    'accuracy': 12, 'defense': 10, 'speed': 8,
    'power': -10,
  },
  FightingStyle.brawler: {
    'power': 14, 'punching': 10,
    'defense': -12, 'accuracy': -8,
  },
  FightingStyle.wellRounded: {
    'punching': 3, 'kicking': 3, 'takedowns': 3, 'wrestling': 3,
    'submissionOffense': 3, 'defense': 3,
  },
};

/// Tendency fields pushed high (positive) or low (negative) by each style —
/// how a fighter actually behaves in the cage, not just how skilled they are.
const Map<FightingStyle, Map<String, int>> _styleTendencyDeltas = {
  FightingStyle.boxer: {'strikingFrequency': 25, 'headHunting': 15, 'takedownFrequency': -25, 'kickFrequency': -25},
  FightingStyle.kickboxer: {'kickFrequency': 25, 'strikingFrequency': 15, 'takedownFrequency': -20},
  FightingStyle.muayThai: {'kickFrequency': 20, 'clinchFrequency': 25, 'bodyAttacks': 15, 'legAttacks': 15},
  FightingStyle.wrestler: {'takedownFrequency': 30, 'groundAndPound': 25, 'strikingFrequency': -15},
  FightingStyle.bjj: {'submissionAttempts': 30, 'takedownFrequency': 10, 'strikingFrequency': -15},
  FightingStyle.wrestlingHeavy: {'takedownFrequency': 25, 'groundAndPound': 20, 'clinchFrequency': 10},
  FightingStyle.counterStriker: {'counterStriking': 30, 'aggression': -20},
  FightingStyle.pressureFighter: {'aggression': 25, 'strikingFrequency': 15, 'counterStriking': -15},
  FightingStyle.pointFighter: {'strikingFrequency': 10, 'aggression': -15, 'counterStriking': 10},
  FightingStyle.brawler: {'aggression': 30, 'headHunting': 20, 'counterStriking': -20},
  FightingStyle.wellRounded: {},
};

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

/// Generates roughly [count] brand-new free agents spread randomly across
/// weight classes, for the monthly talent-pool refresh — keeps the pool
/// from going stale as the player signs fighters out of it over time.
List<Fighter> generateMonthlyTalentPool({int count = 10, Random? random}) {
  final rng = random ?? Random();
  const weightClasses = WeightClass.values;
  return List.generate(
    count,
    (_) => _generateFighter(weightClasses[rng.nextInt(weightClasses.length)], rng),
  );
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
  int tendency() => 20 + rng.nextInt(41); // 20-60 baseline

  final style = FightingStyle.values[rng.nextInt(FightingStyle.values.length)];

  final nationality = knownNationalities[rng.nextInt(knownNationalities.length)];
  final (heightInches, weightLbs) = generatePhysicalStats(weightClass, rng);

  final fightingStats = _applyStyleDeltas(
    FightingStats(
      punching: stat(),
      kicking: stat(),
      power: stat(),
      speed: stat(),
      accuracy: stat(),
      defense: stat(),
      takedowns: stat(),
      takedownDefense: stat(),
      wrestling: stat(),
      groundAndPound: stat(),
      submissionOffense: stat(),
      submissionDefense: stat(),
      grappling: stat(),
    ),
    _styleFightingDeltas[style] ?? const {},
  );

  final physicalStats = PhysicalStats(
    cardio: stat(),
    durability: stat(),
    chin: stat(),
    bodyToughness: stat(),
    legToughness: stat(),
    strength: stat(),
    athleticism: stat(),
    recovery: stat(),
  );

  final mentalStats = MentalStats(
    fightIq: stat(),
    composure: stat(),
    aggression: stat(),
    discipline: stat(),
    confidence: stat(),
    heart: stat(),
    adaptability: stat(),
  );

  final tendencies = _applyTendencyDeltas(
    Tendencies(
      strikingFrequency: tendency(),
      takedownFrequency: tendency(),
      kickFrequency: tendency(),
      clinchFrequency: tendency(),
      submissionAttempts: tendency(),
      groundAndPound: tendency(),
      aggression: tendency(),
      counterStriking: tendency(),
      headHunting: tendency(),
      bodyAttacks: tendency(),
      legAttacks: tendency(),
    ),
    _styleTendencyDeltas[style] ?? const {},
  );

  final overall = (fightingStats.average + physicalStats.average + mentalStats.average) / 3;
  // Younger fighters have more room left to grow; veterans are close to
  // whatever they've already shown.
  final growthRoom = age <= 24 ? 10 + rng.nextInt(16) : age <= 29 ? 4 + rng.nextInt(10) : rng.nextInt(6);
  final potential = (overall.round() + growthRoom).clamp(30, 99);

  return Fighter(
    id: newId(),
    name: _generateName(nationality, rng),
    age: age,
    nationality: nationality,
    weightClass: weightClass,
    heightInches: heightInches,
    weightLbs: weightLbs,
    record: FightRecord(wins: wins, losses: losses, draws: rng.nextInt(2)),
    fightingStats: fightingStats,
    physicalStats: physicalStats,
    mentalStats: mentalStats,
    style: style,
    tendencies: tendencies,
    potential: potential,
    popularity: 10 + rng.nextInt(50),
    morale: 65 + rng.nextInt(25),
    injuryStatus: InjuryStatus.healthy,
    winStreak: rng.nextInt(4),
  );
}

FightingStats _applyStyleDeltas(FightingStats stats, Map<String, int> deltas) {
  int adj(String key, int base) => (base + (deltas[key] ?? 0)).clamp(1, 99);
  return stats.copyWith(
    punching: adj('punching', stats.punching),
    kicking: adj('kicking', stats.kicking),
    power: adj('power', stats.power),
    speed: adj('speed', stats.speed),
    accuracy: adj('accuracy', stats.accuracy),
    defense: adj('defense', stats.defense),
    takedowns: adj('takedowns', stats.takedowns),
    takedownDefense: adj('takedownDefense', stats.takedownDefense),
    wrestling: adj('wrestling', stats.wrestling),
    groundAndPound: adj('groundAndPound', stats.groundAndPound),
    submissionOffense: adj('submissionOffense', stats.submissionOffense),
    submissionDefense: adj('submissionDefense', stats.submissionDefense),
    grappling: adj('grappling', stats.grappling),
  );
}

Tendencies _applyTendencyDeltas(Tendencies t, Map<String, int> deltas) {
  int adj(String key, int base) => (base + (deltas[key] ?? 0)).clamp(0, 100);
  return t.copyWith(
    strikingFrequency: adj('strikingFrequency', t.strikingFrequency),
    takedownFrequency: adj('takedownFrequency', t.takedownFrequency),
    kickFrequency: adj('kickFrequency', t.kickFrequency),
    clinchFrequency: adj('clinchFrequency', t.clinchFrequency),
    submissionAttempts: adj('submissionAttempts', t.submissionAttempts),
    groundAndPound: adj('groundAndPound', t.groundAndPound),
    aggression: adj('aggression', t.aggression),
    counterStriking: adj('counterStriking', t.counterStriking),
    headHunting: adj('headHunting', t.headHunting),
    bodyAttacks: adj('bodyAttacks', t.bodyAttacks),
    legAttacks: adj('legAttacks', t.legAttacks),
  );
}

String _generateName(String nationality, Random rng) {
  final pool = _namePoolsByNationality[nationality]!;
  final first = pool.first[rng.nextInt(pool.first.length)];
  final last = pool.last[rng.nextInt(pool.last.length)];
  return '$first $last';
}

/// A plausible (height in inches, walk-around weight in lbs) pair for the
/// given weight class. Exposed for the fighter editor to re-roll defaults
/// when the player changes weight class on a manually-created fighter.
(int, int) generatePhysicalStats(WeightClass weightClass, Random rng) {
  final (minHeight, maxHeight) = _heightRangeByWeightClass[weightClass]!;
  final heightInches = minHeight + rng.nextInt(maxHeight - minHeight + 1);
  final weightAboveLimit = 3 + rng.nextInt(13); // walk-around +3 to +15 lbs
  final weightLbs = weightClass.limitLbs + weightAboveLimit;
  return (heightInches, weightLbs);
}

Organization generateStartingOrganization({
  required String name,
  required ReputationTier tier,
  DateTime? asOf,
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
    lastTalentRefresh: asOf ?? DateTime.now(),
  );
}
