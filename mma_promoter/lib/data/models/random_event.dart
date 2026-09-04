import 'enums.dart';

/// One option the player can pick when responding to a [RandomEvent].
class RandomEventChoice {
  final String id;
  final String label;
  final String consequenceSummary;

  const RandomEventChoice({
    required this.id,
    required this.label,
    required this.consequenceSummary,
  });
}

/// An unplanned occurrence (injury, callout, contract dispute, ...) that
/// interrupts the player's plans and forces a decision with trade-offs.
class RandomEvent {
  final String id;
  final RandomEventType type;
  final String? affectedFighterId;
  final String headline;
  final String description;
  final List<RandomEventChoice> choices;
  final String? chosenChoiceId;
  final DateTime occurredOn;

  const RandomEvent({
    required this.id,
    required this.type,
    required this.headline,
    required this.description,
    required this.choices,
    required this.occurredOn,
    this.affectedFighterId,
    this.chosenChoiceId,
  });

  bool get isResolved => chosenChoiceId != null;

  RandomEvent copyWith({String? chosenChoiceId}) {
    return RandomEvent(
      id: id,
      type: type,
      affectedFighterId: affectedFighterId,
      headline: headline,
      description: description,
      choices: choices,
      occurredOn: occurredOn,
      chosenChoiceId: chosenChoiceId ?? this.chosenChoiceId,
    );
  }
}
