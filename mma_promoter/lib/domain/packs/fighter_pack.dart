import 'dart:convert';

import '../../data/models/models.dart';
import 'fighter_codec.dart';

/// A named, shareable group of fighters.
///
/// The point is that a roster you built by hand isn't stuck in the save
/// you built it in. A pack lives outside any one save, gets imported
/// into whichever ones you like, and travels to another player as a
/// share code.
class FighterPack {
  final String id;
  final String name;

  /// Free text — what this pack is, who it's for.
  final String description;

  /// Who made it. Carried through a share code so a pack arriving from
  /// someone else still says whose it is.
  final String author;

  final DateTime createdAt;
  final List<Fighter> fighters;

  const FighterPack({
    required this.id,
    required this.name,
    this.description = '',
    this.author = '',
    required this.createdAt,
    required this.fighters,
  });

  FighterPack copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    DateTime? createdAt,
    List<Fighter>? fighters,
  }) {
    return FighterPack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      fighters: fighters ?? this.fighters,
    );
  }

  /// "12 fighters · 6 divisions", for a list row.
  String get summary {
    final divisions = {for (final f in fighters) f.weightClass}.length;
    final fighterWord = fighters.length == 1 ? 'fighter' : 'fighters';
    final divisionWord = divisions == 1 ? 'division' : 'divisions';
    return '${fighters.length} $fighterWord · $divisions $divisionWord';
  }
}

/// Something wrong with a share code, phrased for the person who pasted
/// it rather than for a log file.
class FighterPackFormatException implements Exception {
  final String message;

  const FighterPackFormatException(this.message);

  @override
  String toString() => message;
}

/// Reads and writes the share code — the string a player copies out of
/// one game and pastes into another.
class FighterPackCodec {
  FighterPackCodec._();

  /// Bumped only for a change old builds could not read. Decoding
  /// tolerates anything at or below this, and refuses anything above
  /// with a message saying so rather than half-importing it.
  static const int formatVersion = 1;

  /// Marks the string as one of ours, so a player who pastes the wrong
  /// thing gets told that instead of a parser error.
  static const String magic = 'MMAPACK';

  /// How many fighters one pack may carry. Not a technical limit — a
  /// guard against a paste that would sit there building a roster of
  /// nonsense.
  static const int maxFighters = 500;

  static String encode(FighterPack pack) {
    return jsonEncode({
      'magic': magic,
      'v': formatVersion,
      'name': pack.name,
      if (pack.description.isNotEmpty) 'desc': pack.description,
      if (pack.author.isNotEmpty) 'by': pack.author,
      'at': pack.createdAt.millisecondsSinceEpoch,
      'f': [for (final fighter in pack.fighters) FighterCodec.toJson(fighter)],
    });
  }

  /// Parses [code] into a pack, with [idFor] minting an id for the pack
  /// itself and for every fighter in it.
  ///
  /// Fresh ids on the way in, always: the same pack can be imported into
  /// several saves, or twice into one, and reusing the ids it was
  /// exported with would have the second import overwrite the first.
  ///
  /// Throws [FighterPackFormatException] with something readable for
  /// anything that isn't a pack.
  static FighterPack decode(String code, {required String Function() idFor}) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw const FighterPackFormatException('Nothing pasted.');
    }

    final Object? parsed;
    try {
      parsed = jsonDecode(trimmed);
    } on FormatException {
      throw const FighterPackFormatException(
        "That doesn't look like a fighter pack — check the whole code was "
        'copied, from the first { to the last }.',
      );
    }

    if (parsed is! Map<String, dynamic>) {
      throw const FighterPackFormatException(
        "That doesn't look like a fighter pack.",
      );
    }
    if (parsed['magic'] != magic) {
      throw const FighterPackFormatException(
        'That code is valid JSON, but it is not a fighter pack.',
      );
    }

    final version = parsed['v'];
    if (version is int && version > formatVersion) {
      throw FighterPackFormatException(
        'That pack was made in a newer version of the game (format '
        '$version, this build reads $formatVersion). Update and try again.',
      );
    }

    final rawFighters = parsed['f'];
    if (rawFighters is! List || rawFighters.isEmpty) {
      throw const FighterPackFormatException(
        'That pack has no fighters in it.',
      );
    }
    if (rawFighters.length > maxFighters) {
      throw FighterPackFormatException(
        'That pack holds ${rawFighters.length} fighters, more than the '
        '$maxFighters this game will import at once.',
      );
    }

    final fighters = <Fighter>[];
    for (final entry in rawFighters) {
      if (entry is! Map<String, dynamic>) continue;
      fighters.add(FighterCodec.fromJson(entry, id: idFor()));
    }
    if (fighters.isEmpty) {
      throw const FighterPackFormatException(
        'That pack has no fighters this version can read.',
      );
    }

    final at = parsed['at'];
    return FighterPack(
      id: idFor(),
      name: _text(parsed['name'], 'Imported Pack'),
      description: _text(parsed['desc'], ''),
      author: _text(parsed['by'], ''),
      createdAt: at is int
          ? DateTime.fromMillisecondsSinceEpoch(at)
          : DateTime.now(),
      fighters: fighters,
    );
  }

  static String _text(Object? value, String fallback) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
