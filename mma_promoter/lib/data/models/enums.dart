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
}

enum StyleTag {
  striker,
  wrestler,
  grappler,
  brawler,
  boxer,
  allRounder,
}

extension StyleTagLabel on StyleTag {
  String get label {
    switch (this) {
      case StyleTag.striker:
        return 'Striker';
      case StyleTag.wrestler:
        return 'Wrestler';
      case StyleTag.grappler:
        return 'Grappler';
      case StyleTag.brawler:
        return 'Brawler';
      case StyleTag.boxer:
        return 'Boxer';
      case StyleTag.allRounder:
        return 'All-Rounder';
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

enum ReputationTier { regional, national, global }

extension ReputationTierLabel on ReputationTier {
  String get label {
    switch (this) {
      case ReputationTier.regional:
        return 'Regional';
      case ReputationTier.national:
        return 'National';
      case ReputationTier.global:
        return 'Global';
    }
  }
}

enum VenueTier {
  localGym,
  regionalArena,
  nationalArena,
  globalStadium,
}

extension VenueTierInfo on VenueTier {
  String get label {
    switch (this) {
      case VenueTier.localGym:
        return 'Local Gym';
      case VenueTier.regionalArena:
        return 'Regional Arena';
      case VenueTier.nationalArena:
        return 'National Arena';
      case VenueTier.globalStadium:
        return 'Global Stadium';
    }
  }

  /// Base venue rental cost in dollars.
  int get baseCost {
    switch (this) {
      case VenueTier.localGym:
        return 2000;
      case VenueTier.regionalArena:
        return 15000;
      case VenueTier.nationalArena:
        return 60000;
      case VenueTier.globalStadium:
        return 250000;
    }
  }

  /// Maximum attendance capacity for ticket revenue purposes.
  int get capacity {
    switch (this) {
      case VenueTier.localGym:
        return 500;
      case VenueTier.regionalArena:
        return 5000;
      case VenueTier.nationalArena:
        return 20000;
      case VenueTier.globalStadium:
        return 60000;
    }
  }
}

enum FightMethod { koTko, submission, decision, drawOrNc }

extension FightMethodLabel on FightMethod {
  String get label {
    switch (this) {
      case FightMethod.koTko:
        return 'KO/TKO';
      case FightMethod.submission:
        return 'Submission';
      case FightMethod.decision:
        return 'Decision';
      case FightMethod.drawOrNc:
        return 'Draw / No Contest';
    }
  }
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
