/// What kind of notification an [InboxItem] is — drives its icon and, for
/// [fightRequest], whether it links to booking a fight for [InboxItem.fighterId].
enum InboxItemType {
  injury,
  retirement,
  fightRequest,

  /// A failed drug test — the fighter is suspended and the promotion
  /// wears the story.
  suspension,

  /// Off-the-clock trouble: a DUI, a bad night out. No suspension, but
  /// the fighter's head isn't right.
  misconduct,

  /// Backstage beef between two of your own — bad for the peace, good
  /// for business.
  altercation,

  /// A contract ran out: either re-signed for you, or waiting on you.
  contract,
}

extension InboxItemTypeLabel on InboxItemType {
  String get label {
    switch (this) {
      case InboxItemType.injury:
        return 'Injury';
      case InboxItemType.retirement:
        return 'Retirement';
      case InboxItemType.fightRequest:
        return 'Fight Request';
      case InboxItemType.suspension:
        return 'Suspension';
      case InboxItemType.misconduct:
        return 'Misconduct';
      case InboxItemType.altercation:
        return 'Backstage';
      case InboxItemType.contract:
        return 'Contract';
    }
  }
}

/// A notification about the player's own roster — an injury, a
/// retirement, or a fighter asking to be booked. Purely informational;
/// resolving it (tapping it) just marks it read.
class InboxItem {
  final String id;
  final InboxItemType type;

  /// The absolute game week ([GameCalendar]) this happened on.
  final int week;

  final String title;
  final String body;
  final String? fighterId;
  final bool read;

  const InboxItem({
    required this.id,
    required this.type,
    required this.week,
    required this.title,
    required this.body,
    this.fighterId,
    this.read = false,
  });

  InboxItem copyWith({
    String? id,
    InboxItemType? type,
    int? week,
    String? title,
    String? body,
    String? fighterId,
    bool? read,
  }) {
    return InboxItem(
      id: id ?? this.id,
      type: type ?? this.type,
      week: week ?? this.week,
      title: title ?? this.title,
      body: body ?? this.body,
      fighterId: fighterId ?? this.fighterId,
      read: read ?? this.read,
    );
  }
}
