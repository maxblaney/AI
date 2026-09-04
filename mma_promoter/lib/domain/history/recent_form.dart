import '../../data/models/models.dart';

/// Which way one fight went for the fighter being looked at.
enum FormResult { win, loss, draw }

extension FormResultLabel on FormResult {
  /// The single letter a form line is written in.
  String get letter => switch (this) {
        FormResult.win => 'W',
        FormResult.loss => 'L',
        FormResult.draw => 'D',
      };
}

/// One entry on a fighter's form line — what happened, how, and to whom.
class FormEntry {
  final FormResult result;
  final FightMethod method;
  final String opponentId;

  /// Round the fight ended in, for the "KO R2" shorthand.
  final int round;

  const FormEntry({
    required this.result,
    required this.method,
    required this.opponentId,
    required this.round,
  });

  /// Short-hand for how it ended: "KO R2", "SUB R1", "DEC". Decisions
  /// carry no round because they all go the distance.
  String get methodLabel {
    final name = switch (method) {
      FightMethod.koTko => 'KO',
      FightMethod.submission => 'SUB',
      FightMethod.doctorStoppage => 'DR',
      FightMethod.decision => 'DEC',
      FightMethod.drawOrNc => 'NC',
    };
    if (method == FightMethod.decision || method == FightMethod.drawOrNc) {
      return name;
    }
    return '$name R$round';
  }
}

/// A fighter's recent results, newest first.
///
/// Booking off a record alone hides the thing that actually matters: a
/// 12-4 fighter who has lost his last three is a different proposition
/// from a 12-4 fighter on a four-fight run, and the record reads the same
/// either way.
class RecentForm {
  RecentForm._();

  /// How many fights a form line shows.
  static const int defaultLength = 5;

  /// Reads [fights] — expected newest first, and already resolved — from
  /// [fighterId]'s point of view. Unresolved bouts are skipped rather
  /// than counted, so a fight that is booked but not yet run never shows
  /// up as a result.
  static List<FormEntry> from({
    required List<Fight> fights,
    required String fighterId,
    int limit = defaultLength,
  }) {
    final entries = <FormEntry>[];
    for (final fight in fights) {
      if (entries.length >= limit) break;
      final outcome = fight.result;
      if (outcome == null) continue;
      if (fight.fighterAId != fighterId && fight.fighterBId != fighterId) {
        continue;
      }

      entries.add(FormEntry(
        result: outcome.isDraw
            ? FormResult.draw
            : (outcome.winnerId == fighterId
                ? FormResult.win
                : FormResult.loss),
        method: outcome.method,
        opponentId: fight.fighterAId == fighterId
            ? fight.fighterBId
            : fight.fighterAId,
        round: outcome.round,
      ));
    }
    return entries;
  }

  /// "3-1-1" across [entries] — wins, losses, draws over the span shown,
  /// not the fighter's whole career.
  static String summarise(List<FormEntry> entries) {
    var wins = 0, losses = 0, draws = 0;
    for (final entry in entries) {
      switch (entry.result) {
        case FormResult.win:
          wins++;
        case FormResult.loss:
          losses++;
        case FormResult.draw:
          draws++;
      }
    }
    return draws > 0 ? '$wins-$losses-$draws' : '$wins-$losses';
  }
}
