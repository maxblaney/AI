import 'enums.dart';
import 'fighter_stats.dart';
import 'contract.dart';

/// A fighter available in the talent pool or signed to the player's roster.
class Fighter {
  final String id;
  final String name;
  final int age;
  final String nationality;
  final WeightClass weightClass;
  final FightRecord record;
  final FighterStats stats;
  final int popularity; // 0-100, drives ticket/PPV draw.
  final int morale; // 0-100, drifts with events, affects performance.
  final InjuryStatus injuryStatus;
  final int winStreak;
  final List<StyleTag> styleTags;
  final Contract? contract; // null = unsigned / in the free talent pool.

  const Fighter({
    required this.id,
    required this.name,
    required this.age,
    required this.nationality,
    required this.weightClass,
    required this.record,
    required this.stats,
    required this.popularity,
    required this.morale,
    required this.injuryStatus,
    required this.winStreak,
    required this.styleTags,
    this.contract,
  });

  bool get isSigned => contract != null;
  bool get isAvailableToFight => injuryStatus == InjuryStatus.healthy;

  Fighter copyWith({
    String? id,
    String? name,
    int? age,
    String? nationality,
    WeightClass? weightClass,
    FightRecord? record,
    FighterStats? stats,
    int? popularity,
    int? morale,
    InjuryStatus? injuryStatus,
    int? winStreak,
    List<StyleTag>? styleTags,
    Contract? contract,
    bool clearContract = false,
  }) {
    return Fighter(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      weightClass: weightClass ?? this.weightClass,
      record: record ?? this.record,
      stats: stats ?? this.stats,
      popularity: popularity ?? this.popularity,
      morale: morale ?? this.morale,
      injuryStatus: injuryStatus ?? this.injuryStatus,
      winStreak: winStreak ?? this.winStreak,
      styleTags: styleTags ?? this.styleTags,
      contract: clearContract ? null : (contract ?? this.contract),
    );
  }
}
