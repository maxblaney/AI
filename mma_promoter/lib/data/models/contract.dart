/// Terms binding a fighter to the player's organization.
class Contract {
  final String id;
  final String fighterId;
  final int fightsRemaining;
  final int payPerFight;
  final bool exclusive;
  final DateTime signedOn;

  const Contract({
    required this.id,
    required this.fighterId,
    required this.fightsRemaining,
    required this.payPerFight,
    required this.exclusive,
    required this.signedOn,
  });

  bool get isExpired => fightsRemaining <= 0;

  Contract copyWith({
    String? id,
    String? fighterId,
    int? fightsRemaining,
    int? payPerFight,
    bool? exclusive,
    DateTime? signedOn,
  }) {
    return Contract(
      id: id ?? this.id,
      fighterId: fighterId ?? this.fighterId,
      fightsRemaining: fightsRemaining ?? this.fightsRemaining,
      payPerFight: payPerFight ?? this.payPerFight,
      exclusive: exclusive ?? this.exclusive,
      signedOn: signedOn ?? this.signedOn,
    );
  }

  Contract afterFight() => copyWith(fightsRemaining: fightsRemaining - 1);
}
