import '../../data/models/models.dart';

/// How healthy a fighter is, as the roster shows it. Ordered best to
/// worst. The bottom two come straight from an actual injury; the top
/// three are degrees of physical freshness — a fighter who just went five
/// hard rounds is banged up without being hurt.
enum FighterCondition { peak, healthy, inShape, injured, battered }

extension FighterConditionLabel on FighterCondition {
  String get label => switch (this) {
        FighterCondition.peak => 'Peak',
        FighterCondition.healthy => 'Healthy',
        FighterCondition.inShape => 'In-Shape',
        FighterCondition.injured => 'Injured',
        FighterCondition.battered => 'Battered',
      };

  /// True when the fighter shouldn't be booked — the game blocks majors
  /// outright and flags minors.
  bool get isHurt =>
      this == FighterCondition.injured || this == FighterCondition.battered;
}

/// How prepared a fighter is for their next outing. Ordered best to
/// worst. Driven mainly by camp length — how many weeks they had between
/// the fight being booked and the event — which is the thing a promoter
/// actually controls.
enum Sharpness { sharp, prepared, uneasy, notPrepared, outOfShape }

extension SharpnessLabel on Sharpness {
  String get label => switch (this) {
        Sharpness.sharp => 'Sharp',
        Sharpness.prepared => 'Prepared',
        Sharpness.uneasy => 'Uneasy',
        Sharpness.notPrepared => 'Not Prepared',
        Sharpness.outOfShape => 'Out of Shape',
      };
}

/// Reads a fighter's condition and sharpness off their stored state.
///
/// Neither of these feeds the fight simulation yet — they're indicators
/// of what the roster looks like, not modifiers on outcomes. Wiring them
/// into the resolver would change how every fight resolves, which is a
/// deliberate decision rather than a side effect of showing a label.
class FighterConditionCalculator {
  FighterConditionCalculator._();

  /// [Fighter.condition] at or above this reads as Peak.
  static const int peakThreshold = 85;

  /// At or above this (and below [peakThreshold]) reads as Healthy.
  static const int healthyThreshold = 60;

  /// Camp length, in weeks, that counts as a full one. Eight weeks is the
  /// standard MMA camp; anything under that is a fighter taking the fight
  /// on progressively shorter notice.
  static const int fullCampWeeks = 8;

  static FighterCondition conditionOf(Fighter fighter) {
    // A real injury outranks freshness — a hurt fighter isn't at their
    // peak no matter how rested they are.
    switch (fighter.injuryStatus) {
      case InjuryStatus.major:
        return FighterCondition.battered;
      case InjuryStatus.minor:
        return FighterCondition.injured;
      case InjuryStatus.healthy:
        break;
    }
    if (fighter.condition >= peakThreshold) return FighterCondition.peak;
    if (fighter.condition >= healthyThreshold) return FighterCondition.healthy;
    return FighterCondition.inShape;
  }

  /// Sharpness for a fighter, given how long a camp they've had for their
  /// next fight.
  ///
  /// [campWeeks] is the gap between the card being booked and the event —
  /// null when they have nothing booked, in which case readiness is read
  /// off how long they've been idle instead. "Sharp" is reserved for
  /// someone actually in a full camp: nobody is at their sharpest sitting
  /// in the gym with no date.
  static Sharpness sharpnessOf(
    Fighter fighter, {
    int? campWeeks,
    int? weeksSinceLastFight,
  }) {
    if (campWeeks != null) {
      if (campWeeks >= fullCampWeeks) return Sharpness.sharp;
      if (campWeeks >= 6) return Sharpness.prepared;
      if (campWeeks >= 4) return Sharpness.uneasy;
      if (campWeeks >= 2) return Sharpness.notPrepared;
      return Sharpness.outOfShape;
    }

    // No fight booked. A fighter who competed recently is still in
    // rhythm; one who's been out for a year has gone off the boil.
    final layoff = weeksSinceLastFight;
    if (layoff == null) return Sharpness.prepared;
    if (layoff <= 12) return Sharpness.prepared;
    if (layoff <= 26) return Sharpness.uneasy;
    if (layoff <= 52) return Sharpness.notPrepared;
    return Sharpness.outOfShape;
  }

  /// What a fight takes out of a fighter. A long, damaging fight costs
  /// more than a quick finish, so a busy champion visibly wears down
  /// across a season rather than resetting every week.
  static int conditionAfterFight({
    required int current,
    required int roundsFought,
    required bool wasFinished,
  }) {
    final wear = 8 + roundsFought * 4 + (wasFinished ? 8 : 0);
    return (current - wear).clamp(0, 100);
  }

  /// Weekly recovery between fights.
  static int conditionAfterRest(int current) => (current + 6).clamp(0, 100);
}
