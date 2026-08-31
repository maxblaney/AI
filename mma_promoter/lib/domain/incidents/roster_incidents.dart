import 'dart:math';

import '../../data/models/models.dart';

/// The kinds of trouble a roster gets into between fights. These are
/// distinct from [RandomEvent]s: those interrupt the player with a
/// decision to make, these have already happened by the time the
/// promoter hears about them. All the player gets is the mailbox item
/// and the consequences.
enum IncidentType {
  /// A failed drug test — the big one. Long suspension, public fallout.
  failedDrugTest,

  /// Off-the-clock trouble. Nothing the commission cares about; plenty
  /// the fighter's head cares about.
  dui,

  /// Two of your own going at it backstage. Terrible for the peace,
  /// excellent for business.
  backstageAltercation,

  /// Hurt doing something no one in a fight camp should have been doing.
  freakInjury,
}

/// One thing that happened to the roster this week: the fighters it
/// changed (already updated, ready to persist) and the mailbox story
/// that goes with it.
class Incident {
  final IncidentType type;

  /// The affected fighters with their consequences already applied. The
  /// caller persists these as-is.
  final List<Fighter> updatedFighters;

  final String headline;
  final String body;

  const Incident({
    required this.type,
    required this.updatedFighters,
    required this.headline,
    required this.body,
  });

  /// The fighter the mailbox item should link to — the first one
  /// involved.
  String get primaryFighterId => updatedFighters.first.id;
}

/// Rolls the roster's off-camera trouble, once per game week.
///
/// Deliberately rare. At [weeklyChance] the roster gets a story roughly
/// three times a year, which is about right for a promotion of this size
/// — often enough that a long save has a history, rare enough that it
/// never feels like the point of the game.
class RosterIncidentEngine {
  /// Chance that *anything* happens to the roster in a given week.
  static const double weeklyChance = 0.06;

  /// How long a failed test sits a fighter down: six months.
  static const int suspensionWeeks = 26;

  /// Relative likelihood of each incident once one is happening. Failed
  /// tests are the rarest because they're the most disruptive — losing a
  /// fighter for half a year should sting, not become routine.
  static const Map<IncidentType, double> typeWeights = {
    IncidentType.freakInjury: 0.40,
    IncidentType.backstageAltercation: 0.25,
    IncidentType.dui: 0.22,
    IncidentType.failedDrugTest: 0.13,
  };

  final Random _random;

  RosterIncidentEngine({Random? random}) : _random = random ?? Random();

  /// Rolls for an incident among [roster] (the signed roster — the
  /// player is only told about their own fighters). Returns null most
  /// weeks. [currentWeek] is the absolute game week, used to date
  /// suspensions and injury recoveries.
  Incident? maybeGenerate({
    required List<Fighter> roster,
    required int currentWeek,
  }) {
    final eligible = roster
        .where((f) => f.isSigned && !f.retired && !f.isSuspendedOn(currentWeek))
        .toList();
    if (eligible.isEmpty) return null;
    if (_random.nextDouble() >= weeklyChance) return null;

    return generate(
      type: _rollType(canBrawl: eligible.length >= 2),
      roster: eligible,
      currentWeek: currentWeek,
    );
  }

  /// Builds a specific incident. Split out from [maybeGenerate] so tests
  /// (and any future "make this happen" hook) can ask for one type
  /// without fighting the dice.
  Incident? generate({
    required IncidentType type,
    required List<Fighter> roster,
    required int currentWeek,
  }) {
    if (roster.isEmpty) return null;
    switch (type) {
      case IncidentType.failedDrugTest:
        return _failedDrugTest(_pick(roster), currentWeek);
      case IncidentType.dui:
        return _dui(_pick(roster));
      case IncidentType.backstageAltercation:
        if (roster.length < 2) return null;
        return _altercation(roster);
      case IncidentType.freakInjury:
        return _freakInjury(_pick(roster), currentWeek);
    }
  }

  IncidentType _rollType({required bool canBrawl}) {
    final weights = {
      for (final entry in typeWeights.entries)
        if (canBrawl || entry.key != IncidentType.backstageAltercation)
          entry.key: entry.value,
    };
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll <= 0) return entry.key;
    }
    return weights.keys.last;
  }

  Fighter _pick(List<Fighter> from) => from[_random.nextInt(from.length)];

  // ---- Individual incidents -------------------------------------------

  Incident _failedDrugTest(Fighter fighter, int currentWeek) {
    final substance = _substances[_random.nextInt(_substances.length)];
    // A ban costs them the crowd and, when they come back, some of what
    // the cycle was giving them. The stat hit is on the physical side —
    // the strength and burst are what they were buying.
    final updated = fighter.copyWith(
      suspendedUntilWeek: currentWeek + suspensionWeeks,
      popularity: (fighter.popularity - 12).clamp(0, 100),
      morale: (fighter.morale - 10).clamp(0, 100),
      physicalStats: fighter.physicalStats.copyWith(
        strength: (fighter.physicalStats.strength - 6).clamp(1, 100),
        explosiveness: (fighter.physicalStats.explosiveness - 5).clamp(1, 100),
      ),
      fightingStats: fighter.fightingStats.copyWith(
        power: (fighter.fightingStats.power - 4).clamp(1, 100),
      ),
    );
    return Incident(
      type: IncidentType.failedDrugTest,
      updatedFighters: [updated],
      headline: '${fighter.name} fails a drug test',
      body: '${fighter.name} tested positive for $substance and has been '
          'handed a six-month suspension — back in week '
          '${currentWeek + suspensionWeeks}. They cannot be booked until '
          'then. The story cost them a chunk of goodwill with fans, and '
          'they have come back off the cycle noticeably weaker.',
    );
  }

  Incident _dui(Fighter fighter) {
    // No commission involvement, no suspension. It sits with the fighter.
    final updated = fighter.copyWith(
      morale: (fighter.morale - 22).clamp(0, 100),
    );
    return Incident(
      type: IncidentType.dui,
      updatedFighters: [updated],
      headline: '${fighter.name} arrested for DUI',
      body: '${fighter.name} was pulled over and charged with driving under '
          'the influence. No suspension is coming, but they are dealing '
          'with lawyers and a very unhappy gym instead of training, and '
          'their head is not in a good place.',
    );
  }

  Incident _altercation(List<Fighter> roster) {
    final a = _pick(roster);
    final others = roster.where((f) => f.id != a.id).toList();
    final b = others[_random.nextInt(others.length)];
    final flashpoint = _flashpoints[_random.nextInt(_flashpoints.length)];

    // Everyone involved in a viral backstage scrap comes out of it more
    // famous than they went in. That's the trade: your locker room is
    // now a problem, and your next press release writes itself.
    Fighter bump(Fighter f) => f.copyWith(
          popularity: (f.popularity + 8).clamp(0, 100),
          morale: (f.morale - 4).clamp(0, 100),
        );

    return Incident(
      type: IncidentType.backstageAltercation,
      updatedFighters: [bump(a), bump(b)],
      headline: '${a.name} and ${b.name} come to blows backstage',
      body: '${a.name} and ${b.name} had to be pulled apart backstage after '
          '$flashpoint. Nobody was hurt, the clip is everywhere, and both '
          'men are a good deal more famous this morning than they were '
          'last night. Book it while it is hot.',
    );
  }

  Incident _freakInjury(Fighter fighter, int currentWeek) {
    final cause = _dumbInjuries[_random.nextInt(_dumbInjuries.length)];
    // Mostly minor — these are embarrassing, not career-altering — but
    // occasionally someone really does wreck themselves.
    final major = _random.nextDouble() < 0.25;
    final weeksOut = major ? 8 + _random.nextInt(9) : 2 + _random.nextInt(5);
    final updated = fighter.copyWith(
      injuryStatus: major ? InjuryStatus.major : InjuryStatus.minor,
      injuryClearsAtWeek: currentWeek + weeksOut,
      condition: (fighter.condition - (major ? 25 : 12)).clamp(0, 100),
      morale: (fighter.morale - 8).clamp(0, 100),
    );
    return Incident(
      type: IncidentType.freakInjury,
      updatedFighters: [updated],
      headline: '${fighter.name} hurt away from the gym',
      body: '${fighter.name} $cause. It is a '
          '${major ? 'serious' : 'minor'} injury and they are out for about '
          '$weeksOut weeks. Camp, as of now, is off.',
    );
  }

  static const List<String> _substances = [
    'elevated testosterone',
    'a banned diuretic',
    'ostarine',
    'clomiphene',
    'EPO',
    'a metabolite of turinabol',
  ];

  static const List<String> _flashpoints = [
    'a shoving match over locker room space',
    'weeks of back-and-forth on social media boiled over',
    'a training partner story got repeated one time too many',
    'a disagreement about who was closer to a title shot',
    'one of them walked past the other and said something',
  ];

  static const List<String> _dumbInjuries = [
    'broke a hand punching a wall after losing a video game',
    'tore an ankle ligament coming off an electric scooter',
    'sliced a hand open trying to open a coconut with a kitchen knife',
    'threw their back out lifting a friend at a wedding',
    'broke a toe kicking a door frame in the dark',
    'dislocated a shoulder on a waterslide',
    'cracked a rib falling off a hoverboard in a hotel lobby',
    'burned a forearm badly on a barbecue',
    'sprained a knee in a charity basketball game',
    'chipped a bone in a hand slap-boxing with a cousin',
    'was bitten by their own dog breaking up a fight with another dog',
    'concussed themselves headbutting a low doorway',
  ];
}
