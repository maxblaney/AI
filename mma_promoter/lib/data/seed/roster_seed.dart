import 'dart:math';

import '../../core/utils/id_generator.dart';
import '../models/models.dart';

const _firstNames = [
  'Marcus', 'Diego', 'Kai', 'Viktor', 'Andre', 'Lukas', 'Rafael', 'Jamal',
  'Erik', 'Tomas', 'Malik', 'Sergio', 'Dmitri', 'Owen', 'Hiroshi', 'Connor',
  'Bruno', 'Felix', 'Amir', 'Nikolai', 'Caleb', 'Mateus', 'Yuto', 'Declan',
];

const _lastNames = [
  'Reyes', 'Kowalski', 'Silva', 'Volkov', 'Okafor', 'Nakamura', 'Novak',
  'Hendricks', 'Duarte', 'Petrov', 'Osei', 'Fitzgerald', 'Moreno', 'Lindqvist',
  'Barros', 'Kensington', 'Alvi', 'Costa', 'Baptiste', 'Sokolov', 'Reilly',
  'Tanaka', 'Ferreira', 'MacLeod',
];

const _nationalities = [
  'USA', 'Brazil', 'Russia', 'Poland', 'Nigeria', 'Japan', 'Ireland',
  'Sweden', 'Mexico', 'Canada', 'England', 'South Korea',
];

/// Generates a fresh, unsigned talent pool in a single weight class for a
/// new game. Some are strong enough to headline immediately, most are
/// mid-tier prospects and journeymen — enough variety to make early signing
/// decisions interesting.
List<Fighter> generateStartingRoster({
  int count = 24,
  WeightClass weightClass = WeightClass.lightweight,
  Random? random,
}) {
  final rng = random ?? Random();
  return List.generate(count, (_) => _generateFighter(weightClass, rng));
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

  return Fighter(
    id: newId(),
    name: '${_firstNames[rng.nextInt(_firstNames.length)]} '
        '${_lastNames[rng.nextInt(_lastNames.length)]}',
    age: age,
    nationality: _nationalities[rng.nextInt(_nationalities.length)],
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

/// Signs a handful of the generated pool to the org's initial roster so the
/// player can book a first event immediately, leaving the rest as free
/// agents. Returns the roster with contracts attached to the chosen few.
List<Fighter> signStartingRoster(
  List<Fighter> pool, {
  int signCount = 8,
  DateTime? signedOn,
}) {
  final sorted = [...pool]..sort((a, b) => b.stats.overall.compareTo(a.stats.overall));
  final toSign = sorted.take(signCount).map((f) => f.id).toSet();
  final date = signedOn ?? DateTime.now();

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

Organization generateStartingOrganization({required String name}) {
  return Organization(
    id: newId(),
    name: name,
    reputationTier: ReputationTier.regional,
    reputationPoints: 0,
    cashBalance: 250000,
    fanbaseSize: 5000,
    homeRegion: 'Midwest, USA',
    promotionBudget: 20000,
  );
}
