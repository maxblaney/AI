/// Shared enums for the MMA Promoter domain model.
library;

enum WeightClass {
  flyweight,
  bantamweight,
  featherweight,
  lightweight,
  welterweight,
  middleweight,
  lightHeavyweight,
  heavyweight,
}

extension WeightClassMovement on WeightClass {
  /// Whether a fighter whose home division is this one can be booked at
  /// [other]. One step either way: moving up a division (or, with a
  /// harder cut, down one) is a normal career move in MMA, and it's what
  /// makes chasing a second belt possible at all. Two divisions in one
  /// jump is not a fight anyone would sanction.
  bool canFightAt(WeightClass other) => (index - other.index).abs() <= 1;

  /// How this fighter is crossing over to reach [division]: 'up',
  /// 'down', or null when it's their own weight.
  String? movementTo(WeightClass division) {
    if (division == this) return null;
    return division.index > index ? 'up' : 'down';
  }
}

extension WeightClassLabel on WeightClass {
  String get label {
    switch (this) {
      case WeightClass.flyweight:
        return 'Flyweight';
      case WeightClass.bantamweight:
        return 'Bantamweight';
      case WeightClass.featherweight:
        return 'Featherweight';
      case WeightClass.lightweight:
        return 'Lightweight';
      case WeightClass.welterweight:
        return 'Welterweight';
      case WeightClass.middleweight:
        return 'Middleweight';
      case WeightClass.lightHeavyweight:
        return 'Light Heavyweight';
      case WeightClass.heavyweight:
        return 'Heavyweight';
    }
  }

  /// Upper weight limit in pounds.
  int get limitLbs {
    switch (this) {
      case WeightClass.flyweight:
        return 125;
      case WeightClass.bantamweight:
        return 135;
      case WeightClass.featherweight:
        return 145;
      case WeightClass.lightweight:
        return 155;
      case WeightClass.welterweight:
        return 170;
      case WeightClass.middleweight:
        return 185;
      case WeightClass.lightHeavyweight:
        return 200;
      case WeightClass.heavyweight:
        return 265;
    }
  }

  String get labelWithLimit => '$label ($limitLbs lbs)';
}

/// A fighter's primary approach — drives both stat generation (see
/// `roster_seed.dart`) and how their [Tendencies] weight into a fight.
enum FightingStyle {
  boxer,
  kickboxer,
  muayThai,
  wrestler,
  bjj,
  wrestlingHeavy,
  counterStriker,
  pressureFighter,
  pointFighter,
  brawler,
  wellRounded,
}

extension FightingStyleLabel on FightingStyle {
  String get label {
    switch (this) {
      case FightingStyle.boxer:
        return 'Boxer';
      case FightingStyle.kickboxer:
        return 'Kickboxer';
      case FightingStyle.muayThai:
        return 'Muay Thai';
      case FightingStyle.wrestler:
        return 'Wrestler';
      case FightingStyle.bjj:
        return 'BJJ';
      case FightingStyle.wrestlingHeavy:
        return 'Wrestling-Heavy';
      case FightingStyle.counterStriker:
        return 'Counter Striker';
      case FightingStyle.pressureFighter:
        return 'Pressure Fighter';
      case FightingStyle.pointFighter:
        return 'Point Fighter';
      case FightingStyle.brawler:
        return 'Brawler';
      case FightingStyle.wellRounded:
        return 'Well-Rounded';
    }
  }
}

enum InjuryStatus { healthy, minor, major }

extension InjuryStatusLabel on InjuryStatus {
  String get label {
    switch (this) {
      case InjuryStatus.healthy:
        return 'Healthy';
      case InjuryStatus.minor:
        return 'Minor Injury';
      case InjuryStatus.major:
        return 'Major Injury';
    }
  }
}

/// The organization's overall standing. Also used at new-game setup to pick
/// a starting cash balance (see [ReputationTierInfo.startingCash]).
enum ReputationTier { local, regional, national, international }

extension ReputationTierInfo on ReputationTier {
  String get label {
    switch (this) {
      case ReputationTier.local:
        return 'Local';
      case ReputationTier.regional:
        return 'Regional';
      case ReputationTier.national:
        return 'National';
      case ReputationTier.international:
        return 'International';
    }
  }

  int get startingCash {
    switch (this) {
      case ReputationTier.local:
        return 10000;
      case ReputationTier.regional:
        return 100000;
      case ReputationTier.national:
        return 1000000;
      case ReputationTier.international:
        return 10000000;
    }
  }

  int get startingFanbase {
    switch (this) {
      case ReputationTier.local:
        return 800;
      case ReputationTier.regional:
        return 8000;
      case ReputationTier.national:
        return 80000;
      case ReputationTier.international:
        return 800000;
    }
  }

  /// Fight of the Night / Performance of the Night cash bonus, paid out of
  /// org funds — scales with how big a promotion you're running.
  int get nightlyBonusAmount {
    switch (this) {
      case ReputationTier.local:
        return 500;
      case ReputationTier.regional:
        return 1000;
      case ReputationTier.national:
        return 10000;
      case ReputationTier.international:
        return 100000;
    }
  }
}

/// Whether a fight carries championship stakes.
enum TitleFightType { none, championship, interim }

extension TitleFightTypeLabel on TitleFightType {
  String get label {
    switch (this) {
      case TitleFightType.none:
        return 'Non-Title';
      case TitleFightType.championship:
        return 'Championship';
      case TitleFightType.interim:
        return 'Interim Title';
    }
  }
}

/// A specific, bookable event venue. Replaces the earlier abstract
/// "tier" concept with real locations, each with its own capacity and
/// rental cost.
enum Venue {
  regionalUsa,
  hartfordCt,
  atlantaGa,
  bostonMa,
  lasVegasNv,
  newYorkNy,
  manchesterUk,
}

extension VenueInfo on Venue {
  String get label {
    switch (this) {
      case Venue.regionalUsa:
        return 'Regional USA';
      case Venue.hartfordCt:
        return 'Hartford, CT';
      case Venue.atlantaGa:
        return 'Atlanta, GA';
      case Venue.bostonMa:
        return 'Boston, MA';
      case Venue.lasVegasNv:
        return 'Las Vegas, NV';
      case Venue.newYorkNy:
        return 'New York, NY';
      case Venue.manchesterUk:
        return 'Manchester, UK';
    }
  }

  /// Base venue rental cost in dollars.
  int get baseCost {
    switch (this) {
      case Venue.regionalUsa:
        return 1500;
      case Venue.hartfordCt:
        return 10000;
      case Venue.atlantaGa:
        return 20000;
      case Venue.bostonMa:
        return 50000;
      case Venue.lasVegasNv:
        return 75000;
      case Venue.newYorkNy:
        return 250000;
      case Venue.manchesterUk:
        return 100000;
    }
  }

  /// Maximum attendance capacity for ticket revenue purposes.
  int get capacity {
    switch (this) {
      case Venue.regionalUsa:
        return 3500;
      case Venue.hartfordCt:
        return 10000;
      case Venue.atlantaGa:
        return 15000;
      case Venue.bostonMa:
        return 20000;
      case Venue.lasVegasNv:
        return 20000;
      case Venue.newYorkNy:
        return 25000;
      case Venue.manchesterUk:
        return 25000;
    }
  }

  /// A reasonable default ticket price to pre-fill the booking form with;
  /// the player can override it there.
  int get suggestedTicketPrice {
    switch (this) {
      case Venue.regionalUsa:
        return 35;
      case Venue.hartfordCt:
        return 55;
      case Venue.atlantaGa:
        return 70;
      case Venue.bostonMa:
        return 90;
      case Venue.lasVegasNv:
        return 120;
      case Venue.newYorkNy:
        return 175;
      case Venue.manchesterUk:
        return 140;
    }
  }
}

enum FightMethod { koTko, submission, decision, doctorStoppage, drawOrNc }

extension FightMethodLabel on FightMethod {
  String get label {
    switch (this) {
      case FightMethod.koTko:
        return 'KO/TKO';
      case FightMethod.submission:
        return 'Submission';
      case FightMethod.decision:
        return 'Decision';
      case FightMethod.doctorStoppage:
        return 'TKO (Doctor Stoppage)';
      case FightMethod.drawOrNc:
        return 'Draw / No Contest';
    }
  }
}

/// How the judges split on a fight that went the distance.
enum DecisionType { unanimous, split, majority, none }

extension DecisionTypeLabel on DecisionType {
  String get label {
    switch (this) {
      case DecisionType.unanimous:
        return 'Unanimous';
      case DecisionType.split:
        return 'Split';
      case DecisionType.majority:
        return 'Majority';
      case DecisionType.none:
        return '';
    }
  }
}

/// Where the fight currently is. The resolver moves between these as
/// takedowns land, clinches are broken, and fighters stand back up.
enum FightPosition { standing, clinch, ground }

/// Ground position from the *top* fighter's point of view. Ordered from
/// least to most dominant — [index] is used directly for advancement.
enum GroundPosition { guard, halfGuard, sideControl, mount, backMount }

extension GroundPositionInfo on GroundPosition {
  String get label {
    switch (this) {
      case GroundPosition.guard:
        return 'in guard';
      case GroundPosition.halfGuard:
        return 'in half guard';
      case GroundPosition.sideControl:
        return 'in side control';
      case GroundPosition.mount:
        return 'in mount';
      case GroundPosition.backMount:
        return 'on the back';
    }
  }

  /// How much of the top fighter's ground striking gets through. Almost
  /// nothing lands from closed guard; mount is where fights end.
  double get strikeMultiplier {
    switch (this) {
      case GroundPosition.guard:
        return 0.35;
      case GroundPosition.halfGuard:
        return 0.6;
      case GroundPosition.sideControl:
        return 0.85;
      case GroundPosition.mount:
        return 1.3;
      case GroundPosition.backMount:
        return 1.0;
    }
  }

  /// How much easier submissions are from here.
  double get submissionMultiplier {
    switch (this) {
      case GroundPosition.guard:
        return 0.5;
      case GroundPosition.halfGuard:
        return 0.7;
      case GroundPosition.sideControl:
        return 1.0;
      case GroundPosition.mount:
        return 1.4;
      case GroundPosition.backMount:
        return 2.2; // rear-naked choke territory.
    }
  }

  /// Judges reward dominant position, not just time on top.
  double get controlValue {
    switch (this) {
      case GroundPosition.guard:
        return 0.5;
      case GroundPosition.halfGuard:
        return 0.8;
      case GroundPosition.sideControl:
        return 1.0;
      case GroundPosition.mount:
        return 1.3;
      case GroundPosition.backMount:
        return 1.4;
    }
  }
}

/// What a fighter is targeting with a strike.
enum StrikeTarget { head, body, leg }

extension StrikeTargetLabel on StrikeTarget {
  String get label {
    switch (this) {
      case StrikeTarget.head:
        return 'head';
      case StrikeTarget.body:
        return 'body';
      case StrikeTarget.leg:
        return 'leg';
    }
  }
}

/// What the fighter on top is trying to do — the thing that makes one
/// wrestler a grinder and the next a finisher from the same position.
enum GroundIntent { control, groundAndPound, submission }

/// Categories for play-by-play lines, so the UI can colour/icon them.
enum FightEventType {
  strike,
  bigStrike,
  knockdown,
  takedown,
  takedownStuffed,
  positionChange,
  submissionAttempt,
  sweep,
  standUp,
  clinch,
  roundStart,
  roundEnd,
  finish,
  decision,
}

enum RandomEventType {
  injury,
  callout,
  contractDispute,
  positiveDrugTest,
  rivalPoaching,
  mediaControversy,
  weighInIncident,
}
