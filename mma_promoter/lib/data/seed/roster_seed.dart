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
  'New Zealand': _NamePool(
    ['Jayden', 'Mitchell', 'Israel', 'Tane', 'Beauden', 'Dane', 'Reuben', 'Kane', 'Hayden', 'Rhys'],
    ['Whanau', 'Ngata', 'Taylor', 'Robertson', 'MacDonald', 'Wilson', 'Harrison', 'Barrett', 'Cane', 'Tuipulotu'],
  ),
};

/// Nationalities the generator knows how to produce fitting names for.
/// Reused by the fighter editor so manually-created fighters stay
/// consistent with generated ones.
final List<String> knownNationalities = _namePoolsByNationality.keys.toList();

/// Rough regional makeup of the talent pool, reflecting where the sport's
/// real-world talent base actually comes from: American-heavy with strong
/// Brazilian and Russian contingents, a solid European base, a small
/// Oceania slice, and the rest spread across the remaining nationalities.
/// Weights are approximate by design, not a hard quota.
const Map<String, double> _regionWeights = {
  'USA': 35,
  'Brazil': 12.5,
  'Russia': 12.5,
  'Europe': 12.5,
  'Oceania': 5,
  'RestOfWorld': 22.5,
};

const List<String> _usaNationalities = ['USA'];
const List<String> _brazilNationalities = ['Brazil'];
const List<String> _russiaNationalities = ['Russia'];
const List<String> _europeNationalities = [
  'Poland', 'Ireland', 'Sweden', 'England', 'Netherlands', 'Germany',
  'France', 'Ukraine', 'Czech Republic', 'Croatia', 'Italy', 'Spain',
  'Scotland', 'Georgia',
];
const List<String> _oceaniaNationalities = ['Australia', 'New Zealand'];
const List<String> _restOfWorldNationalities = [
  'Nigeria', 'Japan', 'Mexico', 'Canada', 'South Korea', 'Kazakhstan',
  'South Africa', 'China', 'Thailand', 'Philippines', 'Cuba',
  'Dominican Republic', 'Argentina', 'Cameroon',
];

/// Per-nationality pick weight, flattened from [_regionWeights] — each
/// nationality within a region splits that region's share evenly. Built
/// once at load time.
final Map<String, double> _nationalityWeights = {
  for (final n in _usaNationalities) n: _regionWeights['USA']! / _usaNationalities.length,
  for (final n in _brazilNationalities) n: _regionWeights['Brazil']! / _brazilNationalities.length,
  for (final n in _russiaNationalities) n: _regionWeights['Russia']! / _russiaNationalities.length,
  for (final n in _europeNationalities) n: _regionWeights['Europe']! / _europeNationalities.length,
  for (final n in _oceaniaNationalities) n: _regionWeights['Oceania']! / _oceaniaNationalities.length,
  for (final n in _restOfWorldNationalities) n: _regionWeights['RestOfWorld']! / _restOfWorldNationalities.length,
};

/// Picks a nationality weighted toward the regional makeup above, falling
/// back to a uniform pick for any nationality not yet bucketed (so adding
/// a new country to the name pool without also bucketing it doesn't make
/// it unreachable).
String _pickNationality(Random rng) {
  final total = _nationalityWeights.values.fold(0.0, (a, b) => a + b);
  var roll = rng.nextDouble() * total;
  for (final entry in _nationalityWeights.entries) {
    roll -= entry.value;
    if (roll <= 0) return entry.key;
  }
  return knownNationalities[rng.nextInt(knownNationalities.length)];
}

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

/// Fighting-stat deltas applied on top of a fighter's random baseline, so
/// a wrestler's sheet actually reads like a wrestler's. Keys are
/// [FightingStats] field names.
const Map<FightingStyle, Map<String, int>> _styleFightingDeltas = {
  FightingStyle.boxer: {
    'punching': 16, 'accuracy': 12, 'headMovement': 14, 'footwork': 10,
    'blocking': 8, 'defense': 8, 'clinchStriking': 6,
    'kicking': -20, 'takedowns': -12, 'wrestling': -10, 'submissionOffense': -12,
    'topControl': -8, 'guardRetention': -6, 'sweeps': -8, 'groundAndPound': -6,
  },
  FightingStyle.kickboxer: {
    'kicking': 16, 'punching': 8, 'footwork': 10, 'power': 6, 'blocking': 6,
    'takedowns': -14, 'wrestling': -12, 'submissionOffense': -12,
    'topControl': -8, 'sweeps': -8, 'guardRetention': -6,
  },
  FightingStyle.muayThai: {
    'kicking': 14, 'clinchStriking': 20, 'clinchControl': 12, 'power': 8,
    'blocking': 10, 'takedownDefense': 6,
    'submissionOffense': -12, 'sweeps': -10, 'guardRetention': -6,
    'headMovement': -6, 'footwork': -4,
  },
  FightingStyle.wrestler: {
    'takedowns': 18, 'wrestling': 18, 'topControl': 16, 'takedownDefense': 12,
    'clinchControl': 12, 'scrambling': 10, 'groundAndPound': 6, 'sweeps': 6,
    'kicking': -14, 'submissionOffense': -8, 'headMovement': -6,
    'guardRetention': -4,
  },
  FightingStyle.bjj: {
    'submissionOffense': 18, 'submissionDefense': 14, 'grappling': 14,
    'guardRetention': 16, 'sweeps': 14, 'scrambling': 8, 'topControl': 6,
    'power': -8, 'kicking': -6, 'blocking': -4, 'takedownDefense': -6,
    'clinchControl': -4,
  },
  FightingStyle.wrestlingHeavy: {
    'takedowns': 14, 'wrestling': 14, 'topControl': 14, 'groundAndPound': 12,
    'clinchControl': 10, 'scrambling': 8,
    'kicking': -12, 'guardRetention': -4, 'headMovement': -4,
  },
  FightingStyle.counterStriker: {
    'accuracy': 14, 'defense': 14, 'headMovement': 16, 'footwork': 12, 'speed': 8,
    'takedowns': -10, 'clinchControl': -8, 'groundAndPound': -6, 'topControl': -4,
  },
  FightingStyle.pressureFighter: {
    'punching': 10, 'power': 10, 'clinchControl': 12, 'clinchStriking': 8,
    'footwork': 6, 'takedowns': 4,
    'defense': -10, 'headMovement': -8, 'blocking': -4,
  },
  FightingStyle.pointFighter: {
    'accuracy': 14, 'footwork': 16, 'speed': 12, 'defense': 8, 'headMovement': 8,
    'power': -14, 'clinchControl': -10, 'topControl': -8, 'groundAndPound': -10,
    'clinchStriking': -8,
  },
  FightingStyle.brawler: {
    'power': 16, 'punching': 12, 'clinchStriking': 8,
    'defense': -14, 'headMovement': -14, 'accuracy': -10, 'footwork': -8,
    'blocking': -6,
  },
  FightingStyle.wellRounded: {
    'punching': 3, 'kicking': 3, 'takedowns': 3, 'wrestling': 3,
    'submissionOffense': 3, 'defense': 3, 'scrambling': 4, 'footwork': 3,
  },
};

/// Physical-stat deltas — a BJJ player is bendy, a wrestler is strong.
const Map<FightingStyle, Map<String, int>> _stylePhysicalDeltas = {
  FightingStyle.boxer: {'chin': 4, 'athleticism': 4, 'flexibility': -6},
  FightingStyle.kickboxer: {'legToughness': 8, 'athleticism': 6},
  FightingStyle.muayThai: {'legToughness': 10, 'bodyToughness': 6, 'gripStrength': 4},
  FightingStyle.wrestler: {'strength': 8, 'gripStrength': 8, 'explosiveness': 6, 'cardio': 4},
  FightingStyle.bjj: {'flexibility': 14, 'gripStrength': 10, 'strength': -4},
  FightingStyle.wrestlingHeavy: {'strength': 8, 'gripStrength': 6, 'cardio': 4},
  FightingStyle.counterStriker: {'athleticism': 6, 'explosiveness': 6},
  FightingStyle.pressureFighter: {'cardio': 10, 'durability': 6},
  FightingStyle.pointFighter: {'athleticism': 8, 'explosiveness': 6, 'strength': -8},
  FightingStyle.brawler: {'chin': 6, 'durability': 4, 'cardio': -8},
  FightingStyle.wellRounded: {},
};

/// Mental-stat deltas — a brawler swings for the fences, a point fighter
/// never does.
const Map<FightingStyle, Map<String, int>> _styleMentalDeltas = {
  FightingStyle.boxer: {'fightIq': 6, 'composure': 4},
  FightingStyle.kickboxer: {'discipline': 4},
  FightingStyle.muayThai: {'composure': 8, 'heart': 6},
  FightingStyle.wrestler: {'discipline': 10, 'heart': 8, 'fightIq': 6},
  FightingStyle.bjj: {'composure': 10, 'fightIq': 8, 'adaptability': 8},
  FightingStyle.wrestlingHeavy: {'discipline': 8, 'killerInstinct': 6},
  FightingStyle.counterStriker: {
    'fightIq': 12, 'composure': 10, 'discipline': 8, 'aggression': -14,
  },
  FightingStyle.pressureFighter: {
    'aggression': 14, 'heart': 8, 'killerInstinct': 8, 'discipline': -6,
  },
  FightingStyle.pointFighter: {
    'discipline': 12, 'fightIq': 8, 'killerInstinct': -14, 'aggression': -12,
  },
  FightingStyle.brawler: {
    'aggression': 16, 'killerInstinct': 12, 'heart': 8,
    'fightIq': -12, 'discipline': -14, 'composure': -8,
  },
  FightingStyle.wellRounded: {'adaptability': 6, 'fightIq': 4},
};

/// Tendency deltas — how a fighter behaves in the cage, not how good they
/// are at it. Ground-game tendencies are set separately by [_GroundPlan].
const Map<FightingStyle, Map<String, int>> _styleTendencyDeltas = {
  FightingStyle.boxer: {
    'strikingFrequency': 25, 'headHunting': 12,
    'kickFrequency': -30, 'takedownFrequency': -25, 'legAttacks': -25,
  },
  FightingStyle.kickboxer: {
    'kickFrequency': 28, 'legAttacks': 18, 'strikingFrequency': 12,
    'takedownFrequency': -22,
  },
  FightingStyle.muayThai: {
    'kickFrequency': 20, 'clinchFrequency': 28, 'wallWork': 18,
    'legAttacks': 18, 'bodyAttacks': 14, 'takedownFrequency': -12,
  },
  FightingStyle.wrestler: {
    'takedownFrequency': 32, 'clinchFrequency': 12, 'wallWork': 15,
    'strikingFrequency': -15,
  },
  FightingStyle.bjj: {
    'takedownFrequency': 8, 'strikingFrequency': -18, 'clinchFrequency': -8,
  },
  FightingStyle.wrestlingHeavy: {
    'takedownFrequency': 28, 'wallWork': 12, 'clinchFrequency': 10,
  },
  FightingStyle.counterStriker: {
    'counterStriking': 30, 'aggression': -22, 'strikingFrequency': -6,
  },
  FightingStyle.pressureFighter: {
    'aggression': 26, 'strikingFrequency': 16, 'clinchFrequency': 12,
    'wallWork': 12, 'counterStriking': -18,
  },
  FightingStyle.pointFighter: {
    'strikingFrequency': 12, 'counterStriking': 12,
    'aggression': -18, 'clinchFrequency': -15,
  },
  FightingStyle.brawler: {
    'aggression': 30, 'headHunting': 22, 'strikingFrequency': 14,
    'counterStriking': -22, 'takedownFrequency': -12,
  },
  FightingStyle.wellRounded: {},
};

/// What a fighter actually *does* once the fight hits the mat. Two
/// wrestlers with identical takedown stats fight completely differently
/// depending on which of these they are — one rides position for a
/// decision, the next postures up and hunts a TKO.
enum _GroundPlan {
  /// Rides position, passes, grinds out control time. Low risk.
  grinder,

  /// Postures up and hits — looking to finish with ground and pound.
  groundStriker,

  /// Chases the tap from any position, happy to give up position for it.
  submissionHunter,

  /// Doesn't want to be down there at all — scrambles straight back up.
  scrambler,
}

/// How likely each style is to have each ground game plan. Even inside one
/// style there's real spread, which is the point.
const Map<FightingStyle, Map<_GroundPlan, double>> _groundPlanWeights = {
  FightingStyle.wrestler: {
    _GroundPlan.grinder: 45, _GroundPlan.groundStriker: 30,
    _GroundPlan.submissionHunter: 10, _GroundPlan.scrambler: 15,
  },
  FightingStyle.wrestlingHeavy: {
    _GroundPlan.grinder: 25, _GroundPlan.groundStriker: 50,
    _GroundPlan.submissionHunter: 10, _GroundPlan.scrambler: 15,
  },
  FightingStyle.bjj: {
    _GroundPlan.grinder: 10, _GroundPlan.groundStriker: 8,
    _GroundPlan.submissionHunter: 62, _GroundPlan.scrambler: 20,
  },
  FightingStyle.brawler: {
    _GroundPlan.grinder: 10, _GroundPlan.groundStriker: 35,
    _GroundPlan.submissionHunter: 15, _GroundPlan.scrambler: 40,
  },
  FightingStyle.pressureFighter: {
    _GroundPlan.grinder: 25, _GroundPlan.groundStriker: 30,
    _GroundPlan.submissionHunter: 15, _GroundPlan.scrambler: 30,
  },
  FightingStyle.wellRounded: {
    _GroundPlan.grinder: 25, _GroundPlan.groundStriker: 25,
    _GroundPlan.submissionHunter: 25, _GroundPlan.scrambler: 25,
  },
  // Pure strikers want no part of the mat.
  FightingStyle.boxer: {
    _GroundPlan.grinder: 8, _GroundPlan.groundStriker: 12,
    _GroundPlan.submissionHunter: 12, _GroundPlan.scrambler: 68,
  },
  FightingStyle.kickboxer: {
    _GroundPlan.grinder: 8, _GroundPlan.groundStriker: 12,
    _GroundPlan.submissionHunter: 12, _GroundPlan.scrambler: 68,
  },
  FightingStyle.muayThai: {
    _GroundPlan.grinder: 10, _GroundPlan.groundStriker: 15,
    _GroundPlan.submissionHunter: 15, _GroundPlan.scrambler: 60,
  },
  FightingStyle.counterStriker: {
    _GroundPlan.grinder: 10, _GroundPlan.groundStriker: 12,
    _GroundPlan.submissionHunter: 18, _GroundPlan.scrambler: 60,
  },
  FightingStyle.pointFighter: {
    _GroundPlan.grinder: 8, _GroundPlan.groundStriker: 8,
    _GroundPlan.submissionHunter: 14, _GroundPlan.scrambler: 70,
  },
};

/// Generates a fresh, unsigned talent pool spread across every weight
/// class for a new game. Some are strong enough to headline immediately,
/// most are mid-tier prospects and journeymen — enough variety to make
/// early signing decisions interesting.
List<Fighter> generateStartingRoster({
  int fightersPerWeightClass = 50,
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

/// Talent tiers driving each fighter's stat center. Weighted so the pool
/// averages roughly a 72 overall, with a real "best of the best" slice
/// that peaks in the low-to-mid 90s and a vanishingly rare legend tier
/// that's the only way to see a 95+ overall.
int _rollStatCenter(Random rng) {
  final roll = rng.nextDouble();
  if (roll < 0.005) return 95 + rng.nextInt(5); // legend: 95-99
  if (roll < 0.04) return 84 + rng.nextInt(10); // elite: 84-93
  if (roll < 0.28) return 75 + rng.nextInt(11); // above average: 75-85
  if (roll < 0.75) return 65 + rng.nextInt(15); // average: 65-79
  return 48 + rng.nextInt(21); // prospect/journeyman: 48-68
}

/// How common each fighting style is in the generated pool. Percentages
/// sum to 100 — Well-Rounded and the grappling-heavy styles (Wrestling-
/// Heavy, Counter Striker) are the most common archetypes, Brawler/Point
/// Fighter/Muay Thai/BJJ the rarest.
const Map<FightingStyle, double> _styleWeights = {
  FightingStyle.wellRounded: 16,
  FightingStyle.wrestlingHeavy: 12,
  FightingStyle.counterStriker: 12,
  FightingStyle.pressureFighter: 10,
  FightingStyle.boxer: 10,
  FightingStyle.kickboxer: 10,
  FightingStyle.wrestler: 10,
  FightingStyle.brawler: 5,
  FightingStyle.pointFighter: 5,
  FightingStyle.muayThai: 5,
  FightingStyle.bjj: 5,
};

FightingStyle _pickFightingStyle(Random rng) {
  final total = _styleWeights.values.fold(0.0, (a, b) => a + b);
  var roll = rng.nextDouble() * total;
  for (final entry in _styleWeights.entries) {
    roll -= entry.value;
    if (roll <= 0) return entry.key;
  }
  return FightingStyle.wellRounded;
}

/// Rolls a career fight count. Weighted so ~88% of fighters land in a
/// believable 4-30 fight "prime of career" range, with a green-prospect
/// tail (0-3 fights) and a grizzled-veteran tail (31-50) making up the
/// rest — enough to hit the 85-90% target without every fighter looking
/// like a carbon copy.
int _rollFightCount(Random rng) {
  final roll = rng.nextDouble();
  if (roll < 0.06) return rng.nextInt(4); // green prospect: 0-3
  if (roll < 0.94) return 4 + rng.nextInt(27); // standard: 4-30
  return 31 + rng.nextInt(20); // veteran: 31-50
}

/// Rolls (wins, losses) for a fighter with [fights] total bouts, biased
/// toward a winning record. Built by construction rather than rounding a
/// win-rate float — at low fight counts, rounding a rate near 50% ties
/// far too often (e.g. 2 wins/2 losses at 4 fights and a 60% "win rate"),
/// which undershot the positive-record target. Instead losses are
/// deliberately kept a minority share for the ~85% of fighters who
/// should have a winning record, so wins > losses by construction for
/// anyone who's actually fought.
(int, int) _rollRecord(int fights, Random rng) {
  if (fights == 0) return (0, 0);
  final roll = rng.nextDouble();
  if (roll < 0.85) {
    // Winning record: losses are 10-40% of the fights, always a minority.
    final losses = (fights * (0.10 + rng.nextDouble() * 0.30)).floor();
    return (fights - losses, losses);
  }
  // Break-even or a losing skid — the other ~15%, for real variety.
  final wins = (fights * (0.20 + rng.nextDouble() * 0.30)).round();
  return (wins, fights - wins);
}

Fighter _generateFighter(WeightClass weightClass, Random rng) {
  final int experienceFights = _rollFightCount(rng);
  final (wins, losses) = _rollRecord(experienceFights, rng);
  // Age should be plausible for how many pro fights this fighter has —
  // roughly a fight every 4-5 months of an active career, starting in
  // their early 20s — so a 22-year-old never shows up with 40 fights.
  final minAge = 21 + (experienceFights / 2.5).floor();
  final age = (minAge + rng.nextInt(6)).clamp(21, 42);

  // Every fighter has a talent-tier "center" their stats cluster around.
  // Young/inexperienced fighters swing wider around that center (raw,
  // uneven tools); veterans are tighter and more consistent — but neither
  // shifts the *average*, only how much a given stat can stray from it.
  final int center = _rollStatCenter(rng);
  final int band = 12 - min(experienceFights, 6); // 12 (green) down to 6 (veteran)
  int stat() => (center + rng.nextInt(band * 2 + 1) - band).clamp(15, 99);
  int tendency() => 20 + rng.nextInt(41); // 20-60 baseline

  final style = _pickFightingStyle(rng);
  final groundPlan = _pickGroundPlan(style, rng);

  final nationality = _pickNationality(rng);
  final (heightInches, weightLbs) = generatePhysicalStats(weightClass, rng);
  final reachInches = generateReach(heightInches, rng);

  final fightingDeltas = _styleFightingDeltas[style] ?? const {};
  int fs(String key) => (stat() + (fightingDeltas[key] ?? 0)).clamp(1, 99);

  final physicalDeltas = _stylePhysicalDeltas[style] ?? const {};
  int phys(String key) => (stat() + (physicalDeltas[key] ?? 0)).clamp(1, 99);

  final mentalDeltas = _styleMentalDeltas[style] ?? const {};
  int ment(String key) => (stat() + (mentalDeltas[key] ?? 0)).clamp(1, 99);

  final tendencyDeltas = _styleTendencyDeltas[style] ?? const {};
  int tend(String key) => (tendency() + (tendencyDeltas[key] ?? 0)).clamp(0, 100);

  final fightingStats = FightingStats(
    punching: fs('punching'),
    kicking: fs('kicking'),
    power: fs('power'),
    speed: fs('speed'),
    accuracy: fs('accuracy'),
    defense: fs('defense'),
    headMovement: fs('headMovement'),
    blocking: fs('blocking'),
    footwork: fs('footwork'),
    takedowns: fs('takedowns'),
    takedownDefense: fs('takedownDefense'),
    wrestling: fs('wrestling'),
    clinchStriking: fs('clinchStriking'),
    clinchControl: fs('clinchControl'),
    clinchDefense: fs('clinchDefense'),
    topControl: fs('topControl'),
    groundAndPound: fs('groundAndPound'),
    guardRetention: fs('guardRetention'),
    sweeps: fs('sweeps'),
    scrambling: fs('scrambling'),
    submissionOffense: fs('submissionOffense'),
    submissionDefense: fs('submissionDefense'),
    grappling: fs('grappling'),
  );

  final physicalStats = PhysicalStats(
    cardio: phys('cardio'),
    durability: phys('durability'),
    chin: phys('chin'),
    bodyToughness: phys('bodyToughness'),
    legToughness: phys('legToughness'),
    strength: phys('strength'),
    athleticism: phys('athleticism'),
    recovery: phys('recovery'),
    explosiveness: phys('explosiveness'),
    flexibility: phys('flexibility'),
    gripStrength: phys('gripStrength'),
  );

  final mentalStats = MentalStats(
    fightIq: ment('fightIq'),
    composure: ment('composure'),
    aggression: ment('aggression'),
    discipline: ment('discipline'),
    confidence: ment('confidence'),
    heart: ment('heart'),
    adaptability: ment('adaptability'),
    killerInstinct: ment('killerInstinct'),
  );

  final groundTendencies = _groundPlanTendencies(groundPlan, rng);
  final tendencies = Tendencies(
    strikingFrequency: tend('strikingFrequency'),
    takedownFrequency: tend('takedownFrequency'),
    kickFrequency: tend('kickFrequency'),
    clinchFrequency: tend('clinchFrequency'),
    aggression: tend('aggression'),
    counterStriking: tend('counterStriking'),
    headHunting: tend('headHunting'),
    bodyAttacks: tend('bodyAttacks'),
    legAttacks: tend('legAttacks'),
    wallWork: tend('wallWork'),
    // The ground game plan wins outright over the generic baseline — this
    // is what makes one wrestler a grinder and the next a finisher.
    submissionAttempts: groundTendencies.submissionAttempts,
    groundAndPound: groundTendencies.groundAndPound,
    positionControl: groundTendencies.positionControl,
    standUpPreference: groundTendencies.standUpPreference,
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
    reachInches: reachInches,
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

_GroundPlan _pickGroundPlan(FightingStyle style, Random rng) {
  final weights = _groundPlanWeights[style] ??
      const {
        _GroundPlan.grinder: 25,
        _GroundPlan.groundStriker: 25,
        _GroundPlan.submissionHunter: 25,
        _GroundPlan.scrambler: 25,
      };
  final total = weights.values.fold(0.0, (a, b) => a + b);
  var roll = rng.nextDouble() * total;
  for (final entry in weights.entries) {
    roll -= entry.value;
    if (roll <= 0) return entry.key;
  }
  return _GroundPlan.scrambler;
}

/// The four ground-game dials, set from the fighter's plan rather than
/// rolled generically — with enough spread inside each plan that two
/// grinders still don't feel identical.
({
  int positionControl,
  int groundAndPound,
  int submissionAttempts,
  int standUpPreference,
}) _groundPlanTendencies(_GroundPlan plan, Random rng) {
  int band(int low, int high) => low + rng.nextInt(high - low + 1);
  switch (plan) {
    case _GroundPlan.grinder:
      return (
        positionControl: band(68, 90),
        groundAndPound: band(25, 48),
        submissionAttempts: band(10, 30),
        standUpPreference: band(10, 32),
      );
    case _GroundPlan.groundStriker:
      return (
        positionControl: band(40, 62),
        groundAndPound: band(70, 94),
        submissionAttempts: band(15, 35),
        standUpPreference: band(10, 32),
      );
    case _GroundPlan.submissionHunter:
      return (
        positionControl: band(28, 52),
        groundAndPound: band(15, 38),
        submissionAttempts: band(72, 96),
        standUpPreference: band(12, 36),
      );
    case _GroundPlan.scrambler:
      return (
        positionControl: band(22, 45),
        groundAndPound: band(22, 48),
        submissionAttempts: band(28, 55),
        standUpPreference: band(65, 92),
      );
  }
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

/// Reach tracks height closely but not exactly — most fighters are within
/// a couple of inches either way, with the occasional real outlier.
int generateReach(int heightInches, Random rng) {
  final variance = rng.nextInt(9) - 3; // -3 to +5
  return (heightInches + variance).clamp(58, 88);
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
    lastTalentRefreshWeek: 1,
    currentWeek: 1,
  );
}
