/// Terms binding a fighter to the player's organization. Pay is split into
/// guaranteed show money and a win bonus — a fighter who loses or draws
/// still takes home [showMoney], but only pockets [winBonus] on a win.
class Contract {
  final String id;
  final String fighterId;
  final int fightsRemaining;
  final int showMoney;
  final int winBonus;
  final bool exclusive;
  final DateTime signedOn;

  const Contract({
    required this.id,
    required this.fighterId,
    required this.fightsRemaining,
    required this.showMoney,
    required this.winBonus,
    required this.exclusive,
    required this.signedOn,
  });

  bool get isExpired => fightsRemaining <= 0;

  /// What this fighter takes home on a win — the figure usually quoted as
  /// "pay" when the outcome isn't yet known.
  int get payOnWin => showMoney + winBonus;

  Contract copyWith({
    String? id,
    String? fighterId,
    int? fightsRemaining,
    int? showMoney,
    int? winBonus,
    bool? exclusive,
    DateTime? signedOn,
  }) {
    return Contract(
      id: id ?? this.id,
      fighterId: fighterId ?? this.fighterId,
      fightsRemaining: fightsRemaining ?? this.fightsRemaining,
      showMoney: showMoney ?? this.showMoney,
      winBonus: winBonus ?? this.winBonus,
      exclusive: exclusive ?? this.exclusive,
      signedOn: signedOn ?? this.signedOn,
    );
  }

  Contract afterFight() => copyWith(fightsRemaining: fightsRemaining - 1);
}
