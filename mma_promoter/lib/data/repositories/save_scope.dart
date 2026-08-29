/// Which save the repositories are currently reading and writing.
///
/// One database holds every playthrough, with each game-state row tagged
/// by the id of the organization it belongs to. Rather than threading a
/// save id through every repository call, the repositories share one of
/// these and read [saveId] off it — so switching saves is a single
/// assignment, and no query can accidentally be written unscoped.
///
/// [saveId] is null before a save is loaded (a fresh install, or straight
/// after deleting the save that was open). Repositories treat that as
/// "nothing to read" rather than "read everything", which is what keeps a
/// half-loaded state from showing another save's fighters.
class SaveScope {
  String? saveId;

  SaveScope([this.saveId]);

  bool get hasSave => saveId != null;

  /// The value to match rows against. Empty string when no save is
  /// active — it matches nothing, because every real row carries an
  /// organization id.
  String get key => saveId ?? '';
}
