/// Core attributes that drive fight simulation. Each stat is 1-100.
class FighterStats {
  final int striking;
  final int grappling;
  final int cardio;
  final int chin;
  final int power;

  const FighterStats({
    required this.striking,
    required this.grappling,
    required this.cardio,
    required this.chin,
    required this.power,
  });

  /// Rough single-number overview used for matchmaking/scouting display.
  double get overall => (striking + grappling + cardio + chin + power) / 5;

  FighterStats copyWith({
    int? striking,
    int? grappling,
    int? cardio,
    int? chin,
    int? power,
  }) {
    return FighterStats(
      striking: striking ?? this.striking,
      grappling: grappling ?? this.grappling,
      cardio: cardio ?? this.cardio,
      chin: chin ?? this.chin,
      power: power ?? this.power,
    );
  }

  Map<String, dynamic> toJson() => {
        'striking': striking,
        'grappling': grappling,
        'cardio': cardio,
        'chin': chin,
        'power': power,
      };

  factory FighterStats.fromJson(Map<String, dynamic> json) => FighterStats(
        striking: json['striking'] as int,
        grappling: json['grappling'] as int,
        cardio: json['cardio'] as int,
        chin: json['chin'] as int,
        power: json['power'] as int,
      );
}

/// Win-loss-draw record.
class FightRecord {
  final int wins;
  final int losses;
  final int draws;

  const FightRecord({this.wins = 0, this.losses = 0, this.draws = 0});

  int get totalFights => wins + losses + draws;

  String get display => '$wins-$losses-$draws';

  FightRecord copyWith({int? wins, int? losses, int? draws}) {
    return FightRecord(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
    );
  }

  FightRecord addWin() => copyWith(wins: wins + 1);
  FightRecord addLoss() => copyWith(losses: losses + 1);
  FightRecord addDraw() => copyWith(draws: draws + 1);

  Map<String, dynamic> toJson() => {
        'wins': wins,
        'losses': losses,
        'draws': draws,
      };

  factory FightRecord.fromJson(Map<String, dynamic> json) => FightRecord(
        wins: json['wins'] as int,
        losses: json['losses'] as int,
        draws: json['draws'] as int,
      );
}
