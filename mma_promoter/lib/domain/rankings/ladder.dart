/// How long a ranking ladder is.
///
/// Every ladder in the game — each division's and pound-for-pound — is a
/// top fifteen, which is what a real promotion publishes. It matters
/// beyond presentation: a fighter outside the fifteen is unranked, and
/// the booking screen says so, so "who is ranked" has one answer rather
/// than one per screen.
class Ladder {
  Ladder._();

  static const int size = 15;

  /// [ordered] cut to the ladder's length, leaving shorter lists alone.
  static List<T> top<T>(List<T> ordered) =>
      ordered.length <= size ? ordered : ordered.sublist(0, size);
}
