import '../../data/models/models.dart';

/// When a booked matchup is a title fight whether the matchmaker says so
/// or not.
///
/// A champion doesn't take non-title fights in his own division — the
/// belt is on the line because he's carrying it. Leaving that to the
/// player to remember meant a title fight could quietly be booked as a
/// regular bout and the belt wouldn't move when it changed hands.
///
/// A champion crossing divisions is a different matter: a lightweight
/// champion fighting at welterweight isn't defending anything unless the
/// welterweight belt is explicitly put up, so the rule keys off the
/// *fight's* weight class, not the fighter's home one.
class TitleFightRules {
  TitleFightRules._();

  /// The type this matchup has to be, or null when nothing is forced and
  /// the player's own choice stands.
  static TitleFightType? forcedType({
    required Fighter? a,
    required Fighter? b,
    required WeightClass division,
  }) {
    final holdsBelt =
        (a?.championOf(division) ?? false) || (b?.championOf(division) ?? false);
    if (holdsBelt) return TitleFightType.championship;

    final holdsInterim = (a?.interimChampionOf(division) ?? false) ||
        (b?.interimChampionOf(division) ?? false);
    if (holdsInterim) return TitleFightType.interim;

    return null;
  }

  /// [chosen] with the forced type applied. An undisputed champion always
  /// wins out — if a champion and an interim champion meet, that's a
  /// unification bout for the real belt, not an interim one.
  static TitleFightType resolve({
    required Fighter? a,
    required Fighter? b,
    required WeightClass division,
    required TitleFightType chosen,
  }) {
    return forcedType(a: a, b: b, division: division) ?? chosen;
  }

  /// Why the choice was taken out of the player's hands, for the UI to
  /// show next to the locked control. Null when nothing is forced.
  static String? explain({
    required Fighter? a,
    required Fighter? b,
    required WeightClass division,
  }) {
    final forced = forcedType(a: a, b: b, division: division);
    if (forced == null) return null;

    final champions = [
      for (final fighter in [a, b])
        if (fighter != null &&
            (forced == TitleFightType.championship
                ? fighter.championOf(division)
                : fighter.interimChampionOf(division)))
          fighter.name,
    ];
    final who = champions.join(' and ');
    final belt = forced == TitleFightType.championship
        ? '${division.label} title'
        : 'interim ${division.label} title';
    return champions.length > 1
        ? '$who both hold a belt here — this is for the $belt.'
        : '$who holds the $belt, so it is on the line.';
  }
}
