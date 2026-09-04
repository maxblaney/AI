/// The game's clock: a single authoritative "current week", counted from 1
/// at new-game start. Everything that used to lean on the real wall clock
/// (`DateTime.now()`) reads this instead, so time in the game only ever
/// moves forward when the *player* advances it — by skipping a week on the
/// dashboard or by resolving an event — never by chance of when they
/// happen to be looking at the app.
///
/// A year is a fixed 52 weeks. Week 1 of Year 1 is [epoch] itself, so
/// `weekNumber` 1 maps to Year 1, Week 1.
class GameCalendar {
  GameCalendar._();

  /// An arbitrary Monday used only to turn a week number into a real
  /// [DateTime] for display (event cards, "Week of …" formatting). The
  /// actual year/week shown to the player always comes from [yearOf] /
  /// [weekOfYear], not from this date's real-world year.
  static final DateTime epoch = DateTime(2026, 1, 5);

  static DateTime dateForWeek(int weekNumber) =>
      epoch.add(Duration(days: (weekNumber - 1) * 7));

  /// Inverse of [dateForWeek] — which absolute week a date falls in.
  /// Only meaningful for dates that came from [dateForWeek] in the first
  /// place (i.e. every date the game itself produces).
  static int weekNumberFor(DateTime date) =>
      (date.difference(epoch).inDays / 7).round() + 1;

  static int yearOf(int weekNumber) => ((weekNumber - 1) ~/ 52) + 1;

  static int weekOfYear(int weekNumber) => ((weekNumber - 1) % 52) + 1;

  /// "Year 1, Week 7".
  static String label(int weekNumber) =>
      'Year ${yearOf(weekNumber)}, Week ${weekOfYear(weekNumber)}';
}
