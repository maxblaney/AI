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

  final nationality = knownNationalities[rng.nextInt(knownNationalities.length)];
  final (heightInches, weightLbs) = generatePhysicalStats(weightClass, rng);

  return Fighter(
    id: newId(),
    name: _generateName(nationality, rng),
    age: age,
    nationality: nationality,
    weightClass: weightClass,
    heightInches: heightInches,
    weightLbs: weightLbs,
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
