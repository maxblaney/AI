// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FightersTable extends Fighters
    with TableInfo<$FightersTable, FighterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FightersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nationalityMeta =
      const VerificationMeta('nationality');
  @override
  late final GeneratedColumn<String> nationality = GeneratedColumn<String>(
      'nationality', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightClassMeta =
      const VerificationMeta('weightClass');
  @override
  late final GeneratedColumn<String> weightClass = GeneratedColumn<String>(
      'weight_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _heightInchesMeta =
      const VerificationMeta('heightInches');
  @override
  late final GeneratedColumn<int> heightInches = GeneratedColumn<int>(
      'height_inches', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(70));
  static const VerificationMeta _weightLbsMeta =
      const VerificationMeta('weightLbs');
  @override
  late final GeneratedColumn<int> weightLbs = GeneratedColumn<int>(
      'weight_lbs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(155));
  static const VerificationMeta _winsMeta = const VerificationMeta('wins');
  @override
  late final GeneratedColumn<int> wins = GeneratedColumn<int>(
      'wins', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lossesMeta = const VerificationMeta('losses');
  @override
  late final GeneratedColumn<int> losses = GeneratedColumn<int>(
      'losses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _drawsMeta = const VerificationMeta('draws');
  @override
  late final GeneratedColumn<int> draws = GeneratedColumn<int>(
      'draws', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _strikingMeta =
      const VerificationMeta('striking');
  @override
  late final GeneratedColumn<int> striking = GeneratedColumn<int>(
      'striking', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _grapplingMeta =
      const VerificationMeta('grappling');
  @override
  late final GeneratedColumn<int> grappling = GeneratedColumn<int>(
      'grappling', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardioMeta = const VerificationMeta('cardio');
  @override
  late final GeneratedColumn<int> cardio = GeneratedColumn<int>(
      'cardio', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chinMeta = const VerificationMeta('chin');
  @override
  late final GeneratedColumn<int> chin = GeneratedColumn<int>(
      'chin', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<int> power = GeneratedColumn<int>(
      'power', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _popularityMeta =
      const VerificationMeta('popularity');
  @override
  late final GeneratedColumn<int> popularity = GeneratedColumn<int>(
      'popularity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _moraleMeta = const VerificationMeta('morale');
  @override
  late final GeneratedColumn<int> morale = GeneratedColumn<int>(
      'morale', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(70));
  static const VerificationMeta _injuryStatusMeta =
      const VerificationMeta('injuryStatus');
  @override
  late final GeneratedColumn<String> injuryStatus = GeneratedColumn<String>(
      'injury_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('healthy'));
  static const VerificationMeta _winStreakMeta =
      const VerificationMeta('winStreak');
  @override
  late final GeneratedColumn<int> winStreak = GeneratedColumn<int>(
      'win_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _styleTagsMeta =
      const VerificationMeta('styleTags');
  @override
  late final GeneratedColumn<String> styleTags = GeneratedColumn<String>(
      'style_tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        nationality,
        weightClass,
        heightInches,
        weightLbs,
        wins,
        losses,
        draws,
        striking,
        grappling,
        cardio,
        chin,
        power,
        popularity,
        morale,
        injuryStatus,
        winStreak,
        styleTags
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fighters';
  @override
  VerificationContext validateIntegrity(Insertable<FighterRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('nationality')) {
      context.handle(
          _nationalityMeta,
          nationality.isAcceptableOrUnknown(
              data['nationality']!, _nationalityMeta));
    } else if (isInserting) {
      context.missing(_nationalityMeta);
    }
    if (data.containsKey('weight_class')) {
      context.handle(
          _weightClassMeta,
          weightClass.isAcceptableOrUnknown(
              data['weight_class']!, _weightClassMeta));
    } else if (isInserting) {
      context.missing(_weightClassMeta);
    }
    if (data.containsKey('height_inches')) {
      context.handle(
          _heightInchesMeta,
          heightInches.isAcceptableOrUnknown(
              data['height_inches']!, _heightInchesMeta));
    }
    if (data.containsKey('weight_lbs')) {
      context.handle(_weightLbsMeta,
          weightLbs.isAcceptableOrUnknown(data['weight_lbs']!, _weightLbsMeta));
    }
    if (data.containsKey('wins')) {
      context.handle(
          _winsMeta, wins.isAcceptableOrUnknown(data['wins']!, _winsMeta));
    }
    if (data.containsKey('losses')) {
      context.handle(_lossesMeta,
          losses.isAcceptableOrUnknown(data['losses']!, _lossesMeta));
    }
    if (data.containsKey('draws')) {
      context.handle(
          _drawsMeta, draws.isAcceptableOrUnknown(data['draws']!, _drawsMeta));
    }
    if (data.containsKey('striking')) {
      context.handle(_strikingMeta,
          striking.isAcceptableOrUnknown(data['striking']!, _strikingMeta));
    } else if (isInserting) {
      context.missing(_strikingMeta);
    }
    if (data.containsKey('grappling')) {
      context.handle(_grapplingMeta,
          grappling.isAcceptableOrUnknown(data['grappling']!, _grapplingMeta));
    } else if (isInserting) {
      context.missing(_grapplingMeta);
    }
    if (data.containsKey('cardio')) {
      context.handle(_cardioMeta,
          cardio.isAcceptableOrUnknown(data['cardio']!, _cardioMeta));
    } else if (isInserting) {
      context.missing(_cardioMeta);
    }
    if (data.containsKey('chin')) {
      context.handle(
          _chinMeta, chin.isAcceptableOrUnknown(data['chin']!, _chinMeta));
    } else if (isInserting) {
      context.missing(_chinMeta);
    }
    if (data.containsKey('power')) {
      context.handle(
          _powerMeta, power.isAcceptableOrUnknown(data['power']!, _powerMeta));
    } else if (isInserting) {
      context.missing(_powerMeta);
    }
    if (data.containsKey('popularity')) {
      context.handle(
          _popularityMeta,
          popularity.isAcceptableOrUnknown(
              data['popularity']!, _popularityMeta));
    }
    if (data.containsKey('morale')) {
      context.handle(_moraleMeta,
          morale.isAcceptableOrUnknown(data['morale']!, _moraleMeta));
    }
    if (data.containsKey('injury_status')) {
      context.handle(
          _injuryStatusMeta,
          injuryStatus.isAcceptableOrUnknown(
              data['injury_status']!, _injuryStatusMeta));
    }
    if (data.containsKey('win_streak')) {
      context.handle(_winStreakMeta,
          winStreak.isAcceptableOrUnknown(data['win_streak']!, _winStreakMeta));
    }
    if (data.containsKey('style_tags')) {
      context.handle(_styleTagsMeta,
          styleTags.isAcceptableOrUnknown(data['style_tags']!, _styleTagsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FighterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FighterRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      nationality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nationality'])!,
      weightClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_class'])!,
      heightInches: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height_inches'])!,
      weightLbs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight_lbs'])!,
      wins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wins'])!,
      losses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}losses'])!,
      draws: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}draws'])!,
      striking: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}striking'])!,
      grappling: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grappling'])!,
      cardio: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cardio'])!,
      chin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chin'])!,
      power: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}power'])!,
      popularity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}popularity'])!,
      morale: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}morale'])!,
      injuryStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}injury_status'])!,
      winStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}win_streak'])!,
      styleTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}style_tags'])!,
    );
  }

  @override
  $FightersTable createAlias(String alias) {
    return $FightersTable(attachedDatabase, alias);
  }
}

class FighterRow extends DataClass implements Insertable<FighterRow> {
  final String id;
  final String name;
  final int age;
  final String nationality;
  final String weightClass;
  final int heightInches;
  final int weightLbs;
  final int wins;
  final int losses;
  final int draws;
  final int striking;
  final int grappling;
  final int cardio;
  final int chin;
  final int power;
  final int popularity;
  final int morale;
  final String injuryStatus;
  final int winStreak;

  /// Comma-separated [StyleTag] names, e.g. "striker,wrestler".
  final String styleTags;
  const FighterRow(
      {required this.id,
      required this.name,
      required this.age,
      required this.nationality,
      required this.weightClass,
      required this.heightInches,
      required this.weightLbs,
      required this.wins,
      required this.losses,
      required this.draws,
      required this.striking,
      required this.grappling,
      required this.cardio,
      required this.chin,
      required this.power,
      required this.popularity,
      required this.morale,
      required this.injuryStatus,
      required this.winStreak,
      required this.styleTags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    map['nationality'] = Variable<String>(nationality);
    map['weight_class'] = Variable<String>(weightClass);
    map['height_inches'] = Variable<int>(heightInches);
    map['weight_lbs'] = Variable<int>(weightLbs);
    map['wins'] = Variable<int>(wins);
    map['losses'] = Variable<int>(losses);
    map['draws'] = Variable<int>(draws);
    map['striking'] = Variable<int>(striking);
    map['grappling'] = Variable<int>(grappling);
    map['cardio'] = Variable<int>(cardio);
    map['chin'] = Variable<int>(chin);
    map['power'] = Variable<int>(power);
    map['popularity'] = Variable<int>(popularity);
    map['morale'] = Variable<int>(morale);
    map['injury_status'] = Variable<String>(injuryStatus);
    map['win_streak'] = Variable<int>(winStreak);
    map['style_tags'] = Variable<String>(styleTags);
    return map;
  }

  FightersCompanion toCompanion(bool nullToAbsent) {
    return FightersCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      nationality: Value(nationality),
      weightClass: Value(weightClass),
      heightInches: Value(heightInches),
      weightLbs: Value(weightLbs),
      wins: Value(wins),
      losses: Value(losses),
      draws: Value(draws),
      striking: Value(striking),
      grappling: Value(grappling),
      cardio: Value(cardio),
      chin: Value(chin),
      power: Value(power),
      popularity: Value(popularity),
      morale: Value(morale),
      injuryStatus: Value(injuryStatus),
      winStreak: Value(winStreak),
      styleTags: Value(styleTags),
    );
  }

  factory FighterRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FighterRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      nationality: serializer.fromJson<String>(json['nationality']),
      weightClass: serializer.fromJson<String>(json['weightClass']),
      heightInches: serializer.fromJson<int>(json['heightInches']),
      weightLbs: serializer.fromJson<int>(json['weightLbs']),
      wins: serializer.fromJson<int>(json['wins']),
      losses: serializer.fromJson<int>(json['losses']),
      draws: serializer.fromJson<int>(json['draws']),
      striking: serializer.fromJson<int>(json['striking']),
      grappling: serializer.fromJson<int>(json['grappling']),
      cardio: serializer.fromJson<int>(json['cardio']),
      chin: serializer.fromJson<int>(json['chin']),
      power: serializer.fromJson<int>(json['power']),
      popularity: serializer.fromJson<int>(json['popularity']),
      morale: serializer.fromJson<int>(json['morale']),
      injuryStatus: serializer.fromJson<String>(json['injuryStatus']),
      winStreak: serializer.fromJson<int>(json['winStreak']),
      styleTags: serializer.fromJson<String>(json['styleTags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'nationality': serializer.toJson<String>(nationality),
      'weightClass': serializer.toJson<String>(weightClass),
      'heightInches': serializer.toJson<int>(heightInches),
      'weightLbs': serializer.toJson<int>(weightLbs),
      'wins': serializer.toJson<int>(wins),
      'losses': serializer.toJson<int>(losses),
      'draws': serializer.toJson<int>(draws),
      'striking': serializer.toJson<int>(striking),
      'grappling': serializer.toJson<int>(grappling),
      'cardio': serializer.toJson<int>(cardio),
      'chin': serializer.toJson<int>(chin),
      'power': serializer.toJson<int>(power),
      'popularity': serializer.toJson<int>(popularity),
      'morale': serializer.toJson<int>(morale),
      'injuryStatus': serializer.toJson<String>(injuryStatus),
      'winStreak': serializer.toJson<int>(winStreak),
      'styleTags': serializer.toJson<String>(styleTags),
    };
  }

  FighterRow copyWith(
          {String? id,
          String? name,
          int? age,
          String? nationality,
          String? weightClass,
          int? heightInches,
          int? weightLbs,
          int? wins,
          int? losses,
          int? draws,
          int? striking,
          int? grappling,
          int? cardio,
          int? chin,
          int? power,
          int? popularity,
          int? morale,
          String? injuryStatus,
          int? winStreak,
          String? styleTags}) =>
      FighterRow(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        nationality: nationality ?? this.nationality,
        weightClass: weightClass ?? this.weightClass,
        heightInches: heightInches ?? this.heightInches,
        weightLbs: weightLbs ?? this.weightLbs,
        wins: wins ?? this.wins,
        losses: losses ?? this.losses,
        draws: draws ?? this.draws,
        striking: striking ?? this.striking,
        grappling: grappling ?? this.grappling,
        cardio: cardio ?? this.cardio,
        chin: chin ?? this.chin,
        power: power ?? this.power,
        popularity: popularity ?? this.popularity,
        morale: morale ?? this.morale,
        injuryStatus: injuryStatus ?? this.injuryStatus,
        winStreak: winStreak ?? this.winStreak,
        styleTags: styleTags ?? this.styleTags,
      );
  FighterRow copyWithCompanion(FightersCompanion data) {
    return FighterRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      nationality:
          data.nationality.present ? data.nationality.value : this.nationality,
      weightClass:
          data.weightClass.present ? data.weightClass.value : this.weightClass,
      heightInches: data.heightInches.present
          ? data.heightInches.value
          : this.heightInches,
      weightLbs: data.weightLbs.present ? data.weightLbs.value : this.weightLbs,
      wins: data.wins.present ? data.wins.value : this.wins,
      losses: data.losses.present ? data.losses.value : this.losses,
      draws: data.draws.present ? data.draws.value : this.draws,
      striking: data.striking.present ? data.striking.value : this.striking,
      grappling: data.grappling.present ? data.grappling.value : this.grappling,
      cardio: data.cardio.present ? data.cardio.value : this.cardio,
      chin: data.chin.present ? data.chin.value : this.chin,
      power: data.power.present ? data.power.value : this.power,
      popularity:
          data.popularity.present ? data.popularity.value : this.popularity,
      morale: data.morale.present ? data.morale.value : this.morale,
      injuryStatus: data.injuryStatus.present
          ? data.injuryStatus.value
          : this.injuryStatus,
      winStreak: data.winStreak.present ? data.winStreak.value : this.winStreak,
      styleTags: data.styleTags.present ? data.styleTags.value : this.styleTags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FighterRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('nationality: $nationality, ')
          ..write('weightClass: $weightClass, ')
          ..write('heightInches: $heightInches, ')
          ..write('weightLbs: $weightLbs, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('draws: $draws, ')
          ..write('striking: $striking, ')
          ..write('grappling: $grappling, ')
          ..write('cardio: $cardio, ')
          ..write('chin: $chin, ')
          ..write('power: $power, ')
          ..write('popularity: $popularity, ')
          ..write('morale: $morale, ')
          ..write('injuryStatus: $injuryStatus, ')
          ..write('winStreak: $winStreak, ')
          ..write('styleTags: $styleTags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      age,
      nationality,
      weightClass,
      heightInches,
      weightLbs,
      wins,
      losses,
      draws,
      striking,
      grappling,
      cardio,
      chin,
      power,
      popularity,
      morale,
      injuryStatus,
      winStreak,
      styleTags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FighterRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.nationality == this.nationality &&
          other.weightClass == this.weightClass &&
          other.heightInches == this.heightInches &&
          other.weightLbs == this.weightLbs &&
          other.wins == this.wins &&
          other.losses == this.losses &&
          other.draws == this.draws &&
          other.striking == this.striking &&
          other.grappling == this.grappling &&
          other.cardio == this.cardio &&
          other.chin == this.chin &&
          other.power == this.power &&
          other.popularity == this.popularity &&
          other.morale == this.morale &&
          other.injuryStatus == this.injuryStatus &&
          other.winStreak == this.winStreak &&
          other.styleTags == this.styleTags);
}

class FightersCompanion extends UpdateCompanion<FighterRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String> nationality;
  final Value<String> weightClass;
  final Value<int> heightInches;
  final Value<int> weightLbs;
  final Value<int> wins;
  final Value<int> losses;
  final Value<int> draws;
  final Value<int> striking;
  final Value<int> grappling;
  final Value<int> cardio;
  final Value<int> chin;
  final Value<int> power;
  final Value<int> popularity;
  final Value<int> morale;
  final Value<String> injuryStatus;
  final Value<int> winStreak;
  final Value<String> styleTags;
  final Value<int> rowid;
  const FightersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.nationality = const Value.absent(),
    this.weightClass = const Value.absent(),
    this.heightInches = const Value.absent(),
    this.weightLbs = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.draws = const Value.absent(),
    this.striking = const Value.absent(),
    this.grappling = const Value.absent(),
    this.cardio = const Value.absent(),
    this.chin = const Value.absent(),
    this.power = const Value.absent(),
    this.popularity = const Value.absent(),
    this.morale = const Value.absent(),
    this.injuryStatus = const Value.absent(),
    this.winStreak = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FightersCompanion.insert({
    required String id,
    required String name,
    required int age,
    required String nationality,
    required String weightClass,
    this.heightInches = const Value.absent(),
    this.weightLbs = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.draws = const Value.absent(),
    required int striking,
    required int grappling,
    required int cardio,
    required int chin,
    required int power,
    this.popularity = const Value.absent(),
    this.morale = const Value.absent(),
    this.injuryStatus = const Value.absent(),
    this.winStreak = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        age = Value(age),
        nationality = Value(nationality),
        weightClass = Value(weightClass),
        striking = Value(striking),
        grappling = Value(grappling),
        cardio = Value(cardio),
        chin = Value(chin),
        power = Value(power);
  static Insertable<FighterRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? nationality,
    Expression<String>? weightClass,
    Expression<int>? heightInches,
    Expression<int>? weightLbs,
    Expression<int>? wins,
    Expression<int>? losses,
    Expression<int>? draws,
    Expression<int>? striking,
    Expression<int>? grappling,
    Expression<int>? cardio,
    Expression<int>? chin,
    Expression<int>? power,
    Expression<int>? popularity,
    Expression<int>? morale,
    Expression<String>? injuryStatus,
    Expression<int>? winStreak,
    Expression<String>? styleTags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (weightClass != null) 'weight_class': weightClass,
      if (heightInches != null) 'height_inches': heightInches,
      if (weightLbs != null) 'weight_lbs': weightLbs,
      if (wins != null) 'wins': wins,
      if (losses != null) 'losses': losses,
      if (draws != null) 'draws': draws,
      if (striking != null) 'striking': striking,
      if (grappling != null) 'grappling': grappling,
      if (cardio != null) 'cardio': cardio,
      if (chin != null) 'chin': chin,
      if (power != null) 'power': power,
      if (popularity != null) 'popularity': popularity,
      if (morale != null) 'morale': morale,
      if (injuryStatus != null) 'injury_status': injuryStatus,
      if (winStreak != null) 'win_streak': winStreak,
      if (styleTags != null) 'style_tags': styleTags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FightersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? age,
      Value<String>? nationality,
      Value<String>? weightClass,
      Value<int>? heightInches,
      Value<int>? weightLbs,
      Value<int>? wins,
      Value<int>? losses,
      Value<int>? draws,
      Value<int>? striking,
      Value<int>? grappling,
      Value<int>? cardio,
      Value<int>? chin,
      Value<int>? power,
      Value<int>? popularity,
      Value<int>? morale,
      Value<String>? injuryStatus,
      Value<int>? winStreak,
      Value<String>? styleTags,
      Value<int>? rowid}) {
    return FightersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      weightClass: weightClass ?? this.weightClass,
      heightInches: heightInches ?? this.heightInches,
      weightLbs: weightLbs ?? this.weightLbs,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      striking: striking ?? this.striking,
      grappling: grappling ?? this.grappling,
      cardio: cardio ?? this.cardio,
      chin: chin ?? this.chin,
      power: power ?? this.power,
      popularity: popularity ?? this.popularity,
      morale: morale ?? this.morale,
      injuryStatus: injuryStatus ?? this.injuryStatus,
      winStreak: winStreak ?? this.winStreak,
      styleTags: styleTags ?? this.styleTags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (nationality.present) {
      map['nationality'] = Variable<String>(nationality.value);
    }
    if (weightClass.present) {
      map['weight_class'] = Variable<String>(weightClass.value);
    }
    if (heightInches.present) {
      map['height_inches'] = Variable<int>(heightInches.value);
    }
    if (weightLbs.present) {
      map['weight_lbs'] = Variable<int>(weightLbs.value);
    }
    if (wins.present) {
      map['wins'] = Variable<int>(wins.value);
    }
    if (losses.present) {
      map['losses'] = Variable<int>(losses.value);
    }
    if (draws.present) {
      map['draws'] = Variable<int>(draws.value);
    }
    if (striking.present) {
      map['striking'] = Variable<int>(striking.value);
    }
    if (grappling.present) {
      map['grappling'] = Variable<int>(grappling.value);
    }
    if (cardio.present) {
      map['cardio'] = Variable<int>(cardio.value);
    }
    if (chin.present) {
      map['chin'] = Variable<int>(chin.value);
    }
    if (power.present) {
      map['power'] = Variable<int>(power.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<int>(popularity.value);
    }
    if (morale.present) {
      map['morale'] = Variable<int>(morale.value);
    }
    if (injuryStatus.present) {
      map['injury_status'] = Variable<String>(injuryStatus.value);
    }
    if (winStreak.present) {
      map['win_streak'] = Variable<int>(winStreak.value);
    }
    if (styleTags.present) {
      map['style_tags'] = Variable<String>(styleTags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FightersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('nationality: $nationality, ')
          ..write('weightClass: $weightClass, ')
          ..write('heightInches: $heightInches, ')
          ..write('weightLbs: $weightLbs, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('draws: $draws, ')
          ..write('striking: $striking, ')
          ..write('grappling: $grappling, ')
          ..write('cardio: $cardio, ')
          ..write('chin: $chin, ')
          ..write('power: $power, ')
          ..write('popularity: $popularity, ')
          ..write('morale: $morale, ')
          ..write('injuryStatus: $injuryStatus, ')
          ..write('winStreak: $winStreak, ')
          ..write('styleTags: $styleTags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, ContractRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fighterIdMeta =
      const VerificationMeta('fighterId');
  @override
  late final GeneratedColumn<String> fighterId = GeneratedColumn<String>(
      'fighter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fightsRemainingMeta =
      const VerificationMeta('fightsRemaining');
  @override
  late final GeneratedColumn<int> fightsRemaining = GeneratedColumn<int>(
      'fights_remaining', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payPerFightMeta =
      const VerificationMeta('payPerFight');
  @override
  late final GeneratedColumn<int> payPerFight = GeneratedColumn<int>(
      'pay_per_fight', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exclusiveMeta =
      const VerificationMeta('exclusive');
  @override
  late final GeneratedColumn<bool> exclusive = GeneratedColumn<bool>(
      'exclusive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("exclusive" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _signedOnMeta =
      const VerificationMeta('signedOn');
  @override
  late final GeneratedColumn<DateTime> signedOn = GeneratedColumn<DateTime>(
      'signed_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fighterId, fightsRemaining, payPerFight, exclusive, signedOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(Insertable<ContractRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fighter_id')) {
      context.handle(_fighterIdMeta,
          fighterId.isAcceptableOrUnknown(data['fighter_id']!, _fighterIdMeta));
    } else if (isInserting) {
      context.missing(_fighterIdMeta);
    }
    if (data.containsKey('fights_remaining')) {
      context.handle(
          _fightsRemainingMeta,
          fightsRemaining.isAcceptableOrUnknown(
              data['fights_remaining']!, _fightsRemainingMeta));
    } else if (isInserting) {
      context.missing(_fightsRemainingMeta);
    }
    if (data.containsKey('pay_per_fight')) {
      context.handle(
          _payPerFightMeta,
          payPerFight.isAcceptableOrUnknown(
              data['pay_per_fight']!, _payPerFightMeta));
    } else if (isInserting) {
      context.missing(_payPerFightMeta);
    }
    if (data.containsKey('exclusive')) {
      context.handle(_exclusiveMeta,
          exclusive.isAcceptableOrUnknown(data['exclusive']!, _exclusiveMeta));
    }
    if (data.containsKey('signed_on')) {
      context.handle(_signedOnMeta,
          signedOn.isAcceptableOrUnknown(data['signed_on']!, _signedOnMeta));
    } else if (isInserting) {
      context.missing(_signedOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContractRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fighterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fighter_id'])!,
      fightsRemaining: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fights_remaining'])!,
      payPerFight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pay_per_fight'])!,
      exclusive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}exclusive'])!,
      signedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}signed_on'])!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }
}

class ContractRow extends DataClass implements Insertable<ContractRow> {
  final String id;
  final String fighterId;
  final int fightsRemaining;
  final int payPerFight;
  final bool exclusive;
  final DateTime signedOn;
  const ContractRow(
      {required this.id,
      required this.fighterId,
      required this.fightsRemaining,
      required this.payPerFight,
      required this.exclusive,
      required this.signedOn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fighter_id'] = Variable<String>(fighterId);
    map['fights_remaining'] = Variable<int>(fightsRemaining);
    map['pay_per_fight'] = Variable<int>(payPerFight);
    map['exclusive'] = Variable<bool>(exclusive);
    map['signed_on'] = Variable<DateTime>(signedOn);
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(id),
      fighterId: Value(fighterId),
      fightsRemaining: Value(fightsRemaining),
      payPerFight: Value(payPerFight),
      exclusive: Value(exclusive),
      signedOn: Value(signedOn),
    );
  }

  factory ContractRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractRow(
      id: serializer.fromJson<String>(json['id']),
      fighterId: serializer.fromJson<String>(json['fighterId']),
      fightsRemaining: serializer.fromJson<int>(json['fightsRemaining']),
      payPerFight: serializer.fromJson<int>(json['payPerFight']),
      exclusive: serializer.fromJson<bool>(json['exclusive']),
      signedOn: serializer.fromJson<DateTime>(json['signedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fighterId': serializer.toJson<String>(fighterId),
      'fightsRemaining': serializer.toJson<int>(fightsRemaining),
      'payPerFight': serializer.toJson<int>(payPerFight),
      'exclusive': serializer.toJson<bool>(exclusive),
      'signedOn': serializer.toJson<DateTime>(signedOn),
    };
  }

  ContractRow copyWith(
          {String? id,
          String? fighterId,
          int? fightsRemaining,
          int? payPerFight,
          bool? exclusive,
          DateTime? signedOn}) =>
      ContractRow(
        id: id ?? this.id,
        fighterId: fighterId ?? this.fighterId,
        fightsRemaining: fightsRemaining ?? this.fightsRemaining,
        payPerFight: payPerFight ?? this.payPerFight,
        exclusive: exclusive ?? this.exclusive,
        signedOn: signedOn ?? this.signedOn,
      );
  ContractRow copyWithCompanion(ContractsCompanion data) {
    return ContractRow(
      id: data.id.present ? data.id.value : this.id,
      fighterId: data.fighterId.present ? data.fighterId.value : this.fighterId,
      fightsRemaining: data.fightsRemaining.present
          ? data.fightsRemaining.value
          : this.fightsRemaining,
      payPerFight:
          data.payPerFight.present ? data.payPerFight.value : this.payPerFight,
      exclusive: data.exclusive.present ? data.exclusive.value : this.exclusive,
      signedOn: data.signedOn.present ? data.signedOn.value : this.signedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContractRow(')
          ..write('id: $id, ')
          ..write('fighterId: $fighterId, ')
          ..write('fightsRemaining: $fightsRemaining, ')
          ..write('payPerFight: $payPerFight, ')
          ..write('exclusive: $exclusive, ')
          ..write('signedOn: $signedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, fighterId, fightsRemaining, payPerFight, exclusive, signedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractRow &&
          other.id == this.id &&
          other.fighterId == this.fighterId &&
          other.fightsRemaining == this.fightsRemaining &&
          other.payPerFight == this.payPerFight &&
          other.exclusive == this.exclusive &&
          other.signedOn == this.signedOn);
}

class ContractsCompanion extends UpdateCompanion<ContractRow> {
  final Value<String> id;
  final Value<String> fighterId;
  final Value<int> fightsRemaining;
  final Value<int> payPerFight;
  final Value<bool> exclusive;
  final Value<DateTime> signedOn;
  final Value<int> rowid;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.fighterId = const Value.absent(),
    this.fightsRemaining = const Value.absent(),
    this.payPerFight = const Value.absent(),
    this.exclusive = const Value.absent(),
    this.signedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractsCompanion.insert({
    required String id,
    required String fighterId,
    required int fightsRemaining,
    required int payPerFight,
    this.exclusive = const Value.absent(),
    required DateTime signedOn,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fighterId = Value(fighterId),
        fightsRemaining = Value(fightsRemaining),
        payPerFight = Value(payPerFight),
        signedOn = Value(signedOn);
  static Insertable<ContractRow> custom({
    Expression<String>? id,
    Expression<String>? fighterId,
    Expression<int>? fightsRemaining,
    Expression<int>? payPerFight,
    Expression<bool>? exclusive,
    Expression<DateTime>? signedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fighterId != null) 'fighter_id': fighterId,
      if (fightsRemaining != null) 'fights_remaining': fightsRemaining,
      if (payPerFight != null) 'pay_per_fight': payPerFight,
      if (exclusive != null) 'exclusive': exclusive,
      if (signedOn != null) 'signed_on': signedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractsCompanion copyWith(
      {Value<String>? id,
      Value<String>? fighterId,
      Value<int>? fightsRemaining,
      Value<int>? payPerFight,
      Value<bool>? exclusive,
      Value<DateTime>? signedOn,
      Value<int>? rowid}) {
    return ContractsCompanion(
      id: id ?? this.id,
      fighterId: fighterId ?? this.fighterId,
      fightsRemaining: fightsRemaining ?? this.fightsRemaining,
      payPerFight: payPerFight ?? this.payPerFight,
      exclusive: exclusive ?? this.exclusive,
      signedOn: signedOn ?? this.signedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fighterId.present) {
      map['fighter_id'] = Variable<String>(fighterId.value);
    }
    if (fightsRemaining.present) {
      map['fights_remaining'] = Variable<int>(fightsRemaining.value);
    }
    if (payPerFight.present) {
      map['pay_per_fight'] = Variable<int>(payPerFight.value);
    }
    if (exclusive.present) {
      map['exclusive'] = Variable<bool>(exclusive.value);
    }
    if (signedOn.present) {
      map['signed_on'] = Variable<DateTime>(signedOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('fighterId: $fighterId, ')
          ..write('fightsRemaining: $fightsRemaining, ')
          ..write('payPerFight: $payPerFight, ')
          ..write('exclusive: $exclusive, ')
          ..write('signedOn: $signedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, OrganizationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reputationTierMeta =
      const VerificationMeta('reputationTier');
  @override
  late final GeneratedColumn<String> reputationTier = GeneratedColumn<String>(
      'reputation_tier', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('regional'));
  static const VerificationMeta _reputationPointsMeta =
      const VerificationMeta('reputationPoints');
  @override
  late final GeneratedColumn<int> reputationPoints = GeneratedColumn<int>(
      'reputation_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cashBalanceMeta =
      const VerificationMeta('cashBalance');
  @override
  late final GeneratedColumn<int> cashBalance = GeneratedColumn<int>(
      'cash_balance', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fanbaseSizeMeta =
      const VerificationMeta('fanbaseSize');
  @override
  late final GeneratedColumn<int> fanbaseSize = GeneratedColumn<int>(
      'fanbase_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _homeRegionMeta =
      const VerificationMeta('homeRegion');
  @override
  late final GeneratedColumn<String> homeRegion = GeneratedColumn<String>(
      'home_region', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promotionBudgetMeta =
      const VerificationMeta('promotionBudget');
  @override
  late final GeneratedColumn<int> promotionBudget = GeneratedColumn<int>(
      'promotion_budget', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        reputationTier,
        reputationPoints,
        cashBalance,
        fanbaseSize,
        homeRegion,
        promotionBudget
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(Insertable<OrganizationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reputation_tier')) {
      context.handle(
          _reputationTierMeta,
          reputationTier.isAcceptableOrUnknown(
              data['reputation_tier']!, _reputationTierMeta));
    }
    if (data.containsKey('reputation_points')) {
      context.handle(
          _reputationPointsMeta,
          reputationPoints.isAcceptableOrUnknown(
              data['reputation_points']!, _reputationPointsMeta));
    }
    if (data.containsKey('cash_balance')) {
      context.handle(
          _cashBalanceMeta,
          cashBalance.isAcceptableOrUnknown(
              data['cash_balance']!, _cashBalanceMeta));
    } else if (isInserting) {
      context.missing(_cashBalanceMeta);
    }
    if (data.containsKey('fanbase_size')) {
      context.handle(
          _fanbaseSizeMeta,
          fanbaseSize.isAcceptableOrUnknown(
              data['fanbase_size']!, _fanbaseSizeMeta));
    }
    if (data.containsKey('home_region')) {
      context.handle(
          _homeRegionMeta,
          homeRegion.isAcceptableOrUnknown(
              data['home_region']!, _homeRegionMeta));
    } else if (isInserting) {
      context.missing(_homeRegionMeta);
    }
    if (data.containsKey('promotion_budget')) {
      context.handle(
          _promotionBudgetMeta,
          promotionBudget.isAcceptableOrUnknown(
              data['promotion_budget']!, _promotionBudgetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrganizationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrganizationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      reputationTier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reputation_tier'])!,
      reputationPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reputation_points'])!,
      cashBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cash_balance'])!,
      fanbaseSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fanbase_size'])!,
      homeRegion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}home_region'])!,
      promotionBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}promotion_budget'])!,
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class OrganizationRow extends DataClass implements Insertable<OrganizationRow> {
  final String id;
  final String name;
  final String reputationTier;
  final int reputationPoints;
  final int cashBalance;
  final int fanbaseSize;
  final String homeRegion;
  final int promotionBudget;
  const OrganizationRow(
      {required this.id,
      required this.name,
      required this.reputationTier,
      required this.reputationPoints,
      required this.cashBalance,
      required this.fanbaseSize,
      required this.homeRegion,
      required this.promotionBudget});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['reputation_tier'] = Variable<String>(reputationTier);
    map['reputation_points'] = Variable<int>(reputationPoints);
    map['cash_balance'] = Variable<int>(cashBalance);
    map['fanbase_size'] = Variable<int>(fanbaseSize);
    map['home_region'] = Variable<String>(homeRegion);
    map['promotion_budget'] = Variable<int>(promotionBudget);
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      name: Value(name),
      reputationTier: Value(reputationTier),
      reputationPoints: Value(reputationPoints),
      cashBalance: Value(cashBalance),
      fanbaseSize: Value(fanbaseSize),
      homeRegion: Value(homeRegion),
      promotionBudget: Value(promotionBudget),
    );
  }

  factory OrganizationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrganizationRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      reputationTier: serializer.fromJson<String>(json['reputationTier']),
      reputationPoints: serializer.fromJson<int>(json['reputationPoints']),
      cashBalance: serializer.fromJson<int>(json['cashBalance']),
      fanbaseSize: serializer.fromJson<int>(json['fanbaseSize']),
      homeRegion: serializer.fromJson<String>(json['homeRegion']),
      promotionBudget: serializer.fromJson<int>(json['promotionBudget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'reputationTier': serializer.toJson<String>(reputationTier),
      'reputationPoints': serializer.toJson<int>(reputationPoints),
      'cashBalance': serializer.toJson<int>(cashBalance),
      'fanbaseSize': serializer.toJson<int>(fanbaseSize),
      'homeRegion': serializer.toJson<String>(homeRegion),
      'promotionBudget': serializer.toJson<int>(promotionBudget),
    };
  }

  OrganizationRow copyWith(
          {String? id,
          String? name,
          String? reputationTier,
          int? reputationPoints,
          int? cashBalance,
          int? fanbaseSize,
          String? homeRegion,
          int? promotionBudget}) =>
      OrganizationRow(
        id: id ?? this.id,
        name: name ?? this.name,
        reputationTier: reputationTier ?? this.reputationTier,
        reputationPoints: reputationPoints ?? this.reputationPoints,
        cashBalance: cashBalance ?? this.cashBalance,
        fanbaseSize: fanbaseSize ?? this.fanbaseSize,
        homeRegion: homeRegion ?? this.homeRegion,
        promotionBudget: promotionBudget ?? this.promotionBudget,
      );
  OrganizationRow copyWithCompanion(OrganizationsCompanion data) {
    return OrganizationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      reputationTier: data.reputationTier.present
          ? data.reputationTier.value
          : this.reputationTier,
      reputationPoints: data.reputationPoints.present
          ? data.reputationPoints.value
          : this.reputationPoints,
      cashBalance:
          data.cashBalance.present ? data.cashBalance.value : this.cashBalance,
      fanbaseSize:
          data.fanbaseSize.present ? data.fanbaseSize.value : this.fanbaseSize,
      homeRegion:
          data.homeRegion.present ? data.homeRegion.value : this.homeRegion,
      promotionBudget: data.promotionBudget.present
          ? data.promotionBudget.value
          : this.promotionBudget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reputationTier: $reputationTier, ')
          ..write('reputationPoints: $reputationPoints, ')
          ..write('cashBalance: $cashBalance, ')
          ..write('fanbaseSize: $fanbaseSize, ')
          ..write('homeRegion: $homeRegion, ')
          ..write('promotionBudget: $promotionBudget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, reputationTier, reputationPoints,
      cashBalance, fanbaseSize, homeRegion, promotionBudget);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.reputationTier == this.reputationTier &&
          other.reputationPoints == this.reputationPoints &&
          other.cashBalance == this.cashBalance &&
          other.fanbaseSize == this.fanbaseSize &&
          other.homeRegion == this.homeRegion &&
          other.promotionBudget == this.promotionBudget);
}

class OrganizationsCompanion extends UpdateCompanion<OrganizationRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> reputationTier;
  final Value<int> reputationPoints;
  final Value<int> cashBalance;
  final Value<int> fanbaseSize;
  final Value<String> homeRegion;
  final Value<int> promotionBudget;
  final Value<int> rowid;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.reputationTier = const Value.absent(),
    this.reputationPoints = const Value.absent(),
    this.cashBalance = const Value.absent(),
    this.fanbaseSize = const Value.absent(),
    this.homeRegion = const Value.absent(),
    this.promotionBudget = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    required String id,
    required String name,
    this.reputationTier = const Value.absent(),
    this.reputationPoints = const Value.absent(),
    required int cashBalance,
    this.fanbaseSize = const Value.absent(),
    required String homeRegion,
    this.promotionBudget = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        cashBalance = Value(cashBalance),
        homeRegion = Value(homeRegion);
  static Insertable<OrganizationRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? reputationTier,
    Expression<int>? reputationPoints,
    Expression<int>? cashBalance,
    Expression<int>? fanbaseSize,
    Expression<String>? homeRegion,
    Expression<int>? promotionBudget,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (reputationTier != null) 'reputation_tier': reputationTier,
      if (reputationPoints != null) 'reputation_points': reputationPoints,
      if (cashBalance != null) 'cash_balance': cashBalance,
      if (fanbaseSize != null) 'fanbase_size': fanbaseSize,
      if (homeRegion != null) 'home_region': homeRegion,
      if (promotionBudget != null) 'promotion_budget': promotionBudget,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrganizationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? reputationTier,
      Value<int>? reputationPoints,
      Value<int>? cashBalance,
      Value<int>? fanbaseSize,
      Value<String>? homeRegion,
      Value<int>? promotionBudget,
      Value<int>? rowid}) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      reputationTier: reputationTier ?? this.reputationTier,
      reputationPoints: reputationPoints ?? this.reputationPoints,
      cashBalance: cashBalance ?? this.cashBalance,
      fanbaseSize: fanbaseSize ?? this.fanbaseSize,
      homeRegion: homeRegion ?? this.homeRegion,
      promotionBudget: promotionBudget ?? this.promotionBudget,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reputationTier.present) {
      map['reputation_tier'] = Variable<String>(reputationTier.value);
    }
    if (reputationPoints.present) {
      map['reputation_points'] = Variable<int>(reputationPoints.value);
    }
    if (cashBalance.present) {
      map['cash_balance'] = Variable<int>(cashBalance.value);
    }
    if (fanbaseSize.present) {
      map['fanbase_size'] = Variable<int>(fanbaseSize.value);
    }
    if (homeRegion.present) {
      map['home_region'] = Variable<String>(homeRegion.value);
    }
    if (promotionBudget.present) {
      map['promotion_budget'] = Variable<int>(promotionBudget.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reputationTier: $reputationTier, ')
          ..write('reputationPoints: $reputationPoints, ')
          ..write('cashBalance: $cashBalance, ')
          ..write('fanbaseSize: $fanbaseSize, ')
          ..write('homeRegion: $homeRegion, ')
          ..write('promotionBudget: $promotionBudget, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ticketPriceMeta =
      const VerificationMeta('ticketPrice');
  @override
  late final GeneratedColumn<int> ticketPrice = GeneratedColumn<int>(
      'ticket_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scheduled'));
  static const VerificationMeta _promotionBudgetSpentMeta =
      const VerificationMeta('promotionBudgetSpent');
  @override
  late final GeneratedColumn<int> promotionBudgetSpent = GeneratedColumn<int>(
      'promotion_budget_spent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _attendanceMeta =
      const VerificationMeta('attendance');
  @override
  late final GeneratedColumn<int> attendance = GeneratedColumn<int>(
      'attendance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ppvBuysMeta =
      const VerificationMeta('ppvBuys');
  @override
  late final GeneratedColumn<int> ppvBuys = GeneratedColumn<int>(
      'ppv_buys', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _revenueMeta =
      const VerificationMeta('revenue');
  @override
  late final GeneratedColumn<int> revenue = GeneratedColumn<int>(
      'revenue', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _expensesMeta =
      const VerificationMeta('expenses');
  @override
  late final GeneratedColumn<int> expenses = GeneratedColumn<int>(
      'expenses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reputationChangeMeta =
      const VerificationMeta('reputationChange');
  @override
  late final GeneratedColumn<int> reputationChange = GeneratedColumn<int>(
      'reputation_change', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fightOfTheNightFightIdMeta =
      const VerificationMeta('fightOfTheNightFightId');
  @override
  late final GeneratedColumn<String> fightOfTheNightFightId =
      GeneratedColumn<String>('fight_of_the_night_fight_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _performanceOfTheNightFighterIdMeta =
      const VerificationMeta('performanceOfTheNightFighterId');
  @override
  late final GeneratedColumn<String> performanceOfTheNightFighterId =
      GeneratedColumn<String>(
          'performance_of_the_night_fighter_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        date,
        venue,
        ticketPrice,
        status,
        promotionBudgetSpent,
        attendance,
        ppvBuys,
        revenue,
        expenses,
        reputationChange,
        fightOfTheNightFightId,
        performanceOfTheNightFighterId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<EventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
          _venueMeta, venue.isAcceptableOrUnknown(data['venue']!, _venueMeta));
    } else if (isInserting) {
      context.missing(_venueMeta);
    }
    if (data.containsKey('ticket_price')) {
      context.handle(
          _ticketPriceMeta,
          ticketPrice.isAcceptableOrUnknown(
              data['ticket_price']!, _ticketPriceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('promotion_budget_spent')) {
      context.handle(
          _promotionBudgetSpentMeta,
          promotionBudgetSpent.isAcceptableOrUnknown(
              data['promotion_budget_spent']!, _promotionBudgetSpentMeta));
    }
    if (data.containsKey('attendance')) {
      context.handle(
          _attendanceMeta,
          attendance.isAcceptableOrUnknown(
              data['attendance']!, _attendanceMeta));
    }
    if (data.containsKey('ppv_buys')) {
      context.handle(_ppvBuysMeta,
          ppvBuys.isAcceptableOrUnknown(data['ppv_buys']!, _ppvBuysMeta));
    }
    if (data.containsKey('revenue')) {
      context.handle(_revenueMeta,
          revenue.isAcceptableOrUnknown(data['revenue']!, _revenueMeta));
    }
    if (data.containsKey('expenses')) {
      context.handle(_expensesMeta,
          expenses.isAcceptableOrUnknown(data['expenses']!, _expensesMeta));
    }
    if (data.containsKey('reputation_change')) {
      context.handle(
          _reputationChangeMeta,
          reputationChange.isAcceptableOrUnknown(
              data['reputation_change']!, _reputationChangeMeta));
    }
    if (data.containsKey('fight_of_the_night_fight_id')) {
      context.handle(
          _fightOfTheNightFightIdMeta,
          fightOfTheNightFightId.isAcceptableOrUnknown(
              data['fight_of_the_night_fight_id']!,
              _fightOfTheNightFightIdMeta));
    }
    if (data.containsKey('performance_of_the_night_fighter_id')) {
      context.handle(
          _performanceOfTheNightFighterIdMeta,
          performanceOfTheNightFighterId.isAcceptableOrUnknown(
              data['performance_of_the_night_fighter_id']!,
              _performanceOfTheNightFighterIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      venue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue'])!,
      ticketPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_price'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      promotionBudgetSpent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}promotion_budget_spent'])!,
      attendance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attendance'])!,
      ppvBuys: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ppv_buys'])!,
      revenue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revenue'])!,
      expenses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expenses'])!,
      reputationChange: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reputation_change'])!,
      fightOfTheNightFightId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fight_of_the_night_fight_id']),
      performanceOfTheNightFighterId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}performance_of_the_night_fighter_id']),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String name;
  final DateTime date;
  final String venue;
  final int ticketPrice;
  final String status;
  final int promotionBudgetSpent;
  final int attendance;
  final int ppvBuys;
  final int revenue;
  final int expenses;
  final int reputationChange;
  final String? fightOfTheNightFightId;
  final String? performanceOfTheNightFighterId;
  const EventRow(
      {required this.id,
      required this.name,
      required this.date,
      required this.venue,
      required this.ticketPrice,
      required this.status,
      required this.promotionBudgetSpent,
      required this.attendance,
      required this.ppvBuys,
      required this.revenue,
      required this.expenses,
      required this.reputationChange,
      this.fightOfTheNightFightId,
      this.performanceOfTheNightFighterId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['venue'] = Variable<String>(venue);
    map['ticket_price'] = Variable<int>(ticketPrice);
    map['status'] = Variable<String>(status);
    map['promotion_budget_spent'] = Variable<int>(promotionBudgetSpent);
    map['attendance'] = Variable<int>(attendance);
    map['ppv_buys'] = Variable<int>(ppvBuys);
    map['revenue'] = Variable<int>(revenue);
    map['expenses'] = Variable<int>(expenses);
    map['reputation_change'] = Variable<int>(reputationChange);
    if (!nullToAbsent || fightOfTheNightFightId != null) {
      map['fight_of_the_night_fight_id'] =
          Variable<String>(fightOfTheNightFightId);
    }
    if (!nullToAbsent || performanceOfTheNightFighterId != null) {
      map['performance_of_the_night_fighter_id'] =
          Variable<String>(performanceOfTheNightFighterId);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      name: Value(name),
      date: Value(date),
      venue: Value(venue),
      ticketPrice: Value(ticketPrice),
      status: Value(status),
      promotionBudgetSpent: Value(promotionBudgetSpent),
      attendance: Value(attendance),
      ppvBuys: Value(ppvBuys),
      revenue: Value(revenue),
      expenses: Value(expenses),
      reputationChange: Value(reputationChange),
      fightOfTheNightFightId: fightOfTheNightFightId == null && nullToAbsent
          ? const Value.absent()
          : Value(fightOfTheNightFightId),
      performanceOfTheNightFighterId:
          performanceOfTheNightFighterId == null && nullToAbsent
              ? const Value.absent()
              : Value(performanceOfTheNightFighterId),
    );
  }

  factory EventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      venue: serializer.fromJson<String>(json['venue']),
      ticketPrice: serializer.fromJson<int>(json['ticketPrice']),
      status: serializer.fromJson<String>(json['status']),
      promotionBudgetSpent:
          serializer.fromJson<int>(json['promotionBudgetSpent']),
      attendance: serializer.fromJson<int>(json['attendance']),
      ppvBuys: serializer.fromJson<int>(json['ppvBuys']),
      revenue: serializer.fromJson<int>(json['revenue']),
      expenses: serializer.fromJson<int>(json['expenses']),
      reputationChange: serializer.fromJson<int>(json['reputationChange']),
      fightOfTheNightFightId:
          serializer.fromJson<String?>(json['fightOfTheNightFightId']),
      performanceOfTheNightFighterId:
          serializer.fromJson<String?>(json['performanceOfTheNightFighterId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'venue': serializer.toJson<String>(venue),
      'ticketPrice': serializer.toJson<int>(ticketPrice),
      'status': serializer.toJson<String>(status),
      'promotionBudgetSpent': serializer.toJson<int>(promotionBudgetSpent),
      'attendance': serializer.toJson<int>(attendance),
      'ppvBuys': serializer.toJson<int>(ppvBuys),
      'revenue': serializer.toJson<int>(revenue),
      'expenses': serializer.toJson<int>(expenses),
      'reputationChange': serializer.toJson<int>(reputationChange),
      'fightOfTheNightFightId':
          serializer.toJson<String?>(fightOfTheNightFightId),
      'performanceOfTheNightFighterId':
          serializer.toJson<String?>(performanceOfTheNightFighterId),
    };
  }

  EventRow copyWith(
          {String? id,
          String? name,
          DateTime? date,
          String? venue,
          int? ticketPrice,
          String? status,
          int? promotionBudgetSpent,
          int? attendance,
          int? ppvBuys,
          int? revenue,
          int? expenses,
          int? reputationChange,
          Value<String?> fightOfTheNightFightId = const Value.absent(),
          Value<String?> performanceOfTheNightFighterId =
              const Value.absent()}) =>
      EventRow(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        venue: venue ?? this.venue,
        ticketPrice: ticketPrice ?? this.ticketPrice,
        status: status ?? this.status,
        promotionBudgetSpent: promotionBudgetSpent ?? this.promotionBudgetSpent,
        attendance: attendance ?? this.attendance,
        ppvBuys: ppvBuys ?? this.ppvBuys,
        revenue: revenue ?? this.revenue,
        expenses: expenses ?? this.expenses,
        reputationChange: reputationChange ?? this.reputationChange,
        fightOfTheNightFightId: fightOfTheNightFightId.present
            ? fightOfTheNightFightId.value
            : this.fightOfTheNightFightId,
        performanceOfTheNightFighterId: performanceOfTheNightFighterId.present
            ? performanceOfTheNightFighterId.value
            : this.performanceOfTheNightFighterId,
      );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      venue: data.venue.present ? data.venue.value : this.venue,
      ticketPrice:
          data.ticketPrice.present ? data.ticketPrice.value : this.ticketPrice,
      status: data.status.present ? data.status.value : this.status,
      promotionBudgetSpent: data.promotionBudgetSpent.present
          ? data.promotionBudgetSpent.value
          : this.promotionBudgetSpent,
      attendance:
          data.attendance.present ? data.attendance.value : this.attendance,
      ppvBuys: data.ppvBuys.present ? data.ppvBuys.value : this.ppvBuys,
      revenue: data.revenue.present ? data.revenue.value : this.revenue,
      expenses: data.expenses.present ? data.expenses.value : this.expenses,
      reputationChange: data.reputationChange.present
          ? data.reputationChange.value
          : this.reputationChange,
      fightOfTheNightFightId: data.fightOfTheNightFightId.present
          ? data.fightOfTheNightFightId.value
          : this.fightOfTheNightFightId,
      performanceOfTheNightFighterId:
          data.performanceOfTheNightFighterId.present
              ? data.performanceOfTheNightFighterId.value
              : this.performanceOfTheNightFighterId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('venue: $venue, ')
          ..write('ticketPrice: $ticketPrice, ')
          ..write('status: $status, ')
          ..write('promotionBudgetSpent: $promotionBudgetSpent, ')
          ..write('attendance: $attendance, ')
          ..write('ppvBuys: $ppvBuys, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('reputationChange: $reputationChange, ')
          ..write('fightOfTheNightFightId: $fightOfTheNightFightId, ')
          ..write(
              'performanceOfTheNightFighterId: $performanceOfTheNightFighterId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      date,
      venue,
      ticketPrice,
      status,
      promotionBudgetSpent,
      attendance,
      ppvBuys,
      revenue,
      expenses,
      reputationChange,
      fightOfTheNightFightId,
      performanceOfTheNightFighterId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.date == this.date &&
          other.venue == this.venue &&
          other.ticketPrice == this.ticketPrice &&
          other.status == this.status &&
          other.promotionBudgetSpent == this.promotionBudgetSpent &&
          other.attendance == this.attendance &&
          other.ppvBuys == this.ppvBuys &&
          other.revenue == this.revenue &&
          other.expenses == this.expenses &&
          other.reputationChange == this.reputationChange &&
          other.fightOfTheNightFightId == this.fightOfTheNightFightId &&
          other.performanceOfTheNightFighterId ==
              this.performanceOfTheNightFighterId);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<String> venue;
  final Value<int> ticketPrice;
  final Value<String> status;
  final Value<int> promotionBudgetSpent;
  final Value<int> attendance;
  final Value<int> ppvBuys;
  final Value<int> revenue;
  final Value<int> expenses;
  final Value<int> reputationChange;
  final Value<String?> fightOfTheNightFightId;
  final Value<String?> performanceOfTheNightFighterId;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.venue = const Value.absent(),
    this.ticketPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.promotionBudgetSpent = const Value.absent(),
    this.attendance = const Value.absent(),
    this.ppvBuys = const Value.absent(),
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.reputationChange = const Value.absent(),
    this.fightOfTheNightFightId = const Value.absent(),
    this.performanceOfTheNightFighterId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String name,
    required DateTime date,
    required String venue,
    this.ticketPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.promotionBudgetSpent = const Value.absent(),
    this.attendance = const Value.absent(),
    this.ppvBuys = const Value.absent(),
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.reputationChange = const Value.absent(),
    this.fightOfTheNightFightId = const Value.absent(),
    this.performanceOfTheNightFighterId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        date = Value(date),
        venue = Value(venue);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? venue,
    Expression<int>? ticketPrice,
    Expression<String>? status,
    Expression<int>? promotionBudgetSpent,
    Expression<int>? attendance,
    Expression<int>? ppvBuys,
    Expression<int>? revenue,
    Expression<int>? expenses,
    Expression<int>? reputationChange,
    Expression<String>? fightOfTheNightFightId,
    Expression<String>? performanceOfTheNightFighterId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (venue != null) 'venue': venue,
      if (ticketPrice != null) 'ticket_price': ticketPrice,
      if (status != null) 'status': status,
      if (promotionBudgetSpent != null)
        'promotion_budget_spent': promotionBudgetSpent,
      if (attendance != null) 'attendance': attendance,
      if (ppvBuys != null) 'ppv_buys': ppvBuys,
      if (revenue != null) 'revenue': revenue,
      if (expenses != null) 'expenses': expenses,
      if (reputationChange != null) 'reputation_change': reputationChange,
      if (fightOfTheNightFightId != null)
        'fight_of_the_night_fight_id': fightOfTheNightFightId,
      if (performanceOfTheNightFighterId != null)
        'performance_of_the_night_fighter_id': performanceOfTheNightFighterId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? date,
      Value<String>? venue,
      Value<int>? ticketPrice,
      Value<String>? status,
      Value<int>? promotionBudgetSpent,
      Value<int>? attendance,
      Value<int>? ppvBuys,
      Value<int>? revenue,
      Value<int>? expenses,
      Value<int>? reputationChange,
      Value<String?>? fightOfTheNightFightId,
      Value<String?>? performanceOfTheNightFighterId,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      status: status ?? this.status,
      promotionBudgetSpent: promotionBudgetSpent ?? this.promotionBudgetSpent,
      attendance: attendance ?? this.attendance,
      ppvBuys: ppvBuys ?? this.ppvBuys,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      reputationChange: reputationChange ?? this.reputationChange,
      fightOfTheNightFightId:
          fightOfTheNightFightId ?? this.fightOfTheNightFightId,
      performanceOfTheNightFighterId:
          performanceOfTheNightFighterId ?? this.performanceOfTheNightFighterId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (ticketPrice.present) {
      map['ticket_price'] = Variable<int>(ticketPrice.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (promotionBudgetSpent.present) {
      map['promotion_budget_spent'] = Variable<int>(promotionBudgetSpent.value);
    }
    if (attendance.present) {
      map['attendance'] = Variable<int>(attendance.value);
    }
    if (ppvBuys.present) {
      map['ppv_buys'] = Variable<int>(ppvBuys.value);
    }
    if (revenue.present) {
      map['revenue'] = Variable<int>(revenue.value);
    }
    if (expenses.present) {
      map['expenses'] = Variable<int>(expenses.value);
    }
    if (reputationChange.present) {
      map['reputation_change'] = Variable<int>(reputationChange.value);
    }
    if (fightOfTheNightFightId.present) {
      map['fight_of_the_night_fight_id'] =
          Variable<String>(fightOfTheNightFightId.value);
    }
    if (performanceOfTheNightFighterId.present) {
      map['performance_of_the_night_fighter_id'] =
          Variable<String>(performanceOfTheNightFighterId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('venue: $venue, ')
          ..write('ticketPrice: $ticketPrice, ')
          ..write('status: $status, ')
          ..write('promotionBudgetSpent: $promotionBudgetSpent, ')
          ..write('attendance: $attendance, ')
          ..write('ppvBuys: $ppvBuys, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('reputationChange: $reputationChange, ')
          ..write('fightOfTheNightFightId: $fightOfTheNightFightId, ')
          ..write(
              'performanceOfTheNightFighterId: $performanceOfTheNightFighterId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FightsTable extends Fights with TableInfo<$FightsTable, FightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fighterAIdMeta =
      const VerificationMeta('fighterAId');
  @override
  late final GeneratedColumn<String> fighterAId = GeneratedColumn<String>(
      'fighter_a_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fighterBIdMeta =
      const VerificationMeta('fighterBId');
  @override
  late final GeneratedColumn<String> fighterBId = GeneratedColumn<String>(
      'fighter_b_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightClassMeta =
      const VerificationMeta('weightClass');
  @override
  late final GeneratedColumn<String> weightClass = GeneratedColumn<String>(
      'weight_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleFightTypeMeta =
      const VerificationMeta('titleFightType');
  @override
  late final GeneratedColumn<String> titleFightType = GeneratedColumn<String>(
      'title_fight_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _isMainEventMeta =
      const VerificationMeta('isMainEvent');
  @override
  late final GeneratedColumn<bool> isMainEvent = GeneratedColumn<bool>(
      'is_main_event', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_main_event" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isCoMainEventMeta =
      const VerificationMeta('isCoMainEvent');
  @override
  late final GeneratedColumn<bool> isCoMainEvent = GeneratedColumn<bool>(
      'is_co_main_event', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_co_main_event" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
      'rounds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _cardOrderMeta =
      const VerificationMeta('cardOrder');
  @override
  late final GeneratedColumn<int> cardOrder = GeneratedColumn<int>(
      'card_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _resultWinnerIdMeta =
      const VerificationMeta('resultWinnerId');
  @override
  late final GeneratedColumn<String> resultWinnerId = GeneratedColumn<String>(
      'result_winner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMethodMeta =
      const VerificationMeta('resultMethod');
  @override
  late final GeneratedColumn<String> resultMethod = GeneratedColumn<String>(
      'result_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultRoundMeta =
      const VerificationMeta('resultRound');
  @override
  late final GeneratedColumn<int> resultRound = GeneratedColumn<int>(
      'result_round', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _winnerPerformanceRatingMeta =
      const VerificationMeta('winnerPerformanceRating');
  @override
  late final GeneratedColumn<int> winnerPerformanceRating =
      GeneratedColumn<int>('winner_performance_rating', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _loserPerformanceRatingMeta =
      const VerificationMeta('loserPerformanceRating');
  @override
  late final GeneratedColumn<int> loserPerformanceRating = GeneratedColumn<int>(
      'loser_performance_rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _resultFighterAInjuryMeta =
      const VerificationMeta('resultFighterAInjury');
  @override
  late final GeneratedColumn<String> resultFighterAInjury =
      GeneratedColumn<String>('result_fighter_a_injury', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultFighterBInjuryMeta =
      const VerificationMeta('resultFighterBInjury');
  @override
  late final GeneratedColumn<String> resultFighterBInjury =
      GeneratedColumn<String>('result_fighter_b_injury', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eventId,
        fighterAId,
        fighterBId,
        weightClass,
        titleFightType,
        isMainEvent,
        isCoMainEvent,
        rounds,
        cardOrder,
        resultWinnerId,
        resultMethod,
        resultRound,
        winnerPerformanceRating,
        loserPerformanceRating,
        resultFighterAInjury,
        resultFighterBInjury
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fights';
  @override
  VerificationContext validateIntegrity(Insertable<FightRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('fighter_a_id')) {
      context.handle(
          _fighterAIdMeta,
          fighterAId.isAcceptableOrUnknown(
              data['fighter_a_id']!, _fighterAIdMeta));
    } else if (isInserting) {
      context.missing(_fighterAIdMeta);
    }
    if (data.containsKey('fighter_b_id')) {
      context.handle(
          _fighterBIdMeta,
          fighterBId.isAcceptableOrUnknown(
              data['fighter_b_id']!, _fighterBIdMeta));
    } else if (isInserting) {
      context.missing(_fighterBIdMeta);
    }
    if (data.containsKey('weight_class')) {
      context.handle(
          _weightClassMeta,
          weightClass.isAcceptableOrUnknown(
              data['weight_class']!, _weightClassMeta));
    } else if (isInserting) {
      context.missing(_weightClassMeta);
    }
    if (data.containsKey('title_fight_type')) {
      context.handle(
          _titleFightTypeMeta,
          titleFightType.isAcceptableOrUnknown(
              data['title_fight_type']!, _titleFightTypeMeta));
    }
    if (data.containsKey('is_main_event')) {
      context.handle(
          _isMainEventMeta,
          isMainEvent.isAcceptableOrUnknown(
              data['is_main_event']!, _isMainEventMeta));
    }
    if (data.containsKey('is_co_main_event')) {
      context.handle(
          _isCoMainEventMeta,
          isCoMainEvent.isAcceptableOrUnknown(
              data['is_co_main_event']!, _isCoMainEventMeta));
    }
    if (data.containsKey('rounds')) {
      context.handle(_roundsMeta,
          rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta));
    }
    if (data.containsKey('card_order')) {
      context.handle(_cardOrderMeta,
          cardOrder.isAcceptableOrUnknown(data['card_order']!, _cardOrderMeta));
    }
    if (data.containsKey('result_winner_id')) {
      context.handle(
          _resultWinnerIdMeta,
          resultWinnerId.isAcceptableOrUnknown(
              data['result_winner_id']!, _resultWinnerIdMeta));
    }
    if (data.containsKey('result_method')) {
      context.handle(
          _resultMethodMeta,
          resultMethod.isAcceptableOrUnknown(
              data['result_method']!, _resultMethodMeta));
    }
    if (data.containsKey('result_round')) {
      context.handle(
          _resultRoundMeta,
          resultRound.isAcceptableOrUnknown(
              data['result_round']!, _resultRoundMeta));
    }
    if (data.containsKey('winner_performance_rating')) {
      context.handle(
          _winnerPerformanceRatingMeta,
          winnerPerformanceRating.isAcceptableOrUnknown(
              data['winner_performance_rating']!,
              _winnerPerformanceRatingMeta));
    }
    if (data.containsKey('loser_performance_rating')) {
      context.handle(
          _loserPerformanceRatingMeta,
          loserPerformanceRating.isAcceptableOrUnknown(
              data['loser_performance_rating']!, _loserPerformanceRatingMeta));
    }
    if (data.containsKey('result_fighter_a_injury')) {
      context.handle(
          _resultFighterAInjuryMeta,
          resultFighterAInjury.isAcceptableOrUnknown(
              data['result_fighter_a_injury']!, _resultFighterAInjuryMeta));
    }
    if (data.containsKey('result_fighter_b_injury')) {
      context.handle(
          _resultFighterBInjuryMeta,
          resultFighterBInjury.isAcceptableOrUnknown(
              data['result_fighter_b_injury']!, _resultFighterBInjuryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FightRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      fighterAId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fighter_a_id'])!,
      fighterBId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fighter_b_id'])!,
      weightClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_class'])!,
      titleFightType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}title_fight_type'])!,
      isMainEvent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_main_event'])!,
      isCoMainEvent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_co_main_event'])!,
      rounds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rounds'])!,
      cardOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_order'])!,
      resultWinnerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_winner_id']),
      resultMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_method']),
      resultRound: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}result_round']),
      winnerPerformanceRating: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}winner_performance_rating']),
      loserPerformanceRating: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}loser_performance_rating']),
      resultFighterAInjury: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}result_fighter_a_injury']),
      resultFighterBInjury: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}result_fighter_b_injury']),
    );
  }

  @override
  $FightsTable createAlias(String alias) {
    return $FightsTable(attachedDatabase, alias);
  }
}

class FightRow extends DataClass implements Insertable<FightRow> {
  final String id;
  final String eventId;
  final String fighterAId;
  final String fighterBId;
  final String weightClass;
  final String titleFightType;
  final bool isMainEvent;
  final bool isCoMainEvent;
  final int rounds;
  final int cardOrder;
  final String? resultWinnerId;
  final String? resultMethod;
  final int? resultRound;
  final int? winnerPerformanceRating;
  final int? loserPerformanceRating;
  final String? resultFighterAInjury;
  final String? resultFighterBInjury;
  const FightRow(
      {required this.id,
      required this.eventId,
      required this.fighterAId,
      required this.fighterBId,
      required this.weightClass,
      required this.titleFightType,
      required this.isMainEvent,
      required this.isCoMainEvent,
      required this.rounds,
      required this.cardOrder,
      this.resultWinnerId,
      this.resultMethod,
      this.resultRound,
      this.winnerPerformanceRating,
      this.loserPerformanceRating,
      this.resultFighterAInjury,
      this.resultFighterBInjury});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['fighter_a_id'] = Variable<String>(fighterAId);
    map['fighter_b_id'] = Variable<String>(fighterBId);
    map['weight_class'] = Variable<String>(weightClass);
    map['title_fight_type'] = Variable<String>(titleFightType);
    map['is_main_event'] = Variable<bool>(isMainEvent);
    map['is_co_main_event'] = Variable<bool>(isCoMainEvent);
    map['rounds'] = Variable<int>(rounds);
    map['card_order'] = Variable<int>(cardOrder);
    if (!nullToAbsent || resultWinnerId != null) {
      map['result_winner_id'] = Variable<String>(resultWinnerId);
    }
    if (!nullToAbsent || resultMethod != null) {
      map['result_method'] = Variable<String>(resultMethod);
    }
    if (!nullToAbsent || resultRound != null) {
      map['result_round'] = Variable<int>(resultRound);
    }
    if (!nullToAbsent || winnerPerformanceRating != null) {
      map['winner_performance_rating'] = Variable<int>(winnerPerformanceRating);
    }
    if (!nullToAbsent || loserPerformanceRating != null) {
      map['loser_performance_rating'] = Variable<int>(loserPerformanceRating);
    }
    if (!nullToAbsent || resultFighterAInjury != null) {
      map['result_fighter_a_injury'] = Variable<String>(resultFighterAInjury);
    }
    if (!nullToAbsent || resultFighterBInjury != null) {
      map['result_fighter_b_injury'] = Variable<String>(resultFighterBInjury);
    }
    return map;
  }

  FightsCompanion toCompanion(bool nullToAbsent) {
    return FightsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      fighterAId: Value(fighterAId),
      fighterBId: Value(fighterBId),
      weightClass: Value(weightClass),
      titleFightType: Value(titleFightType),
      isMainEvent: Value(isMainEvent),
      isCoMainEvent: Value(isCoMainEvent),
      rounds: Value(rounds),
      cardOrder: Value(cardOrder),
      resultWinnerId: resultWinnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(resultWinnerId),
      resultMethod: resultMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(resultMethod),
      resultRound: resultRound == null && nullToAbsent
          ? const Value.absent()
          : Value(resultRound),
      winnerPerformanceRating: winnerPerformanceRating == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerPerformanceRating),
      loserPerformanceRating: loserPerformanceRating == null && nullToAbsent
          ? const Value.absent()
          : Value(loserPerformanceRating),
      resultFighterAInjury: resultFighterAInjury == null && nullToAbsent
          ? const Value.absent()
          : Value(resultFighterAInjury),
      resultFighterBInjury: resultFighterBInjury == null && nullToAbsent
          ? const Value.absent()
          : Value(resultFighterBInjury),
    );
  }

  factory FightRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FightRow(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      fighterAId: serializer.fromJson<String>(json['fighterAId']),
      fighterBId: serializer.fromJson<String>(json['fighterBId']),
      weightClass: serializer.fromJson<String>(json['weightClass']),
      titleFightType: serializer.fromJson<String>(json['titleFightType']),
      isMainEvent: serializer.fromJson<bool>(json['isMainEvent']),
      isCoMainEvent: serializer.fromJson<bool>(json['isCoMainEvent']),
      rounds: serializer.fromJson<int>(json['rounds']),
      cardOrder: serializer.fromJson<int>(json['cardOrder']),
      resultWinnerId: serializer.fromJson<String?>(json['resultWinnerId']),
      resultMethod: serializer.fromJson<String?>(json['resultMethod']),
      resultRound: serializer.fromJson<int?>(json['resultRound']),
      winnerPerformanceRating:
          serializer.fromJson<int?>(json['winnerPerformanceRating']),
      loserPerformanceRating:
          serializer.fromJson<int?>(json['loserPerformanceRating']),
      resultFighterAInjury:
          serializer.fromJson<String?>(json['resultFighterAInjury']),
      resultFighterBInjury:
          serializer.fromJson<String?>(json['resultFighterBInjury']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'fighterAId': serializer.toJson<String>(fighterAId),
      'fighterBId': serializer.toJson<String>(fighterBId),
      'weightClass': serializer.toJson<String>(weightClass),
      'titleFightType': serializer.toJson<String>(titleFightType),
      'isMainEvent': serializer.toJson<bool>(isMainEvent),
      'isCoMainEvent': serializer.toJson<bool>(isCoMainEvent),
      'rounds': serializer.toJson<int>(rounds),
      'cardOrder': serializer.toJson<int>(cardOrder),
      'resultWinnerId': serializer.toJson<String?>(resultWinnerId),
      'resultMethod': serializer.toJson<String?>(resultMethod),
      'resultRound': serializer.toJson<int?>(resultRound),
      'winnerPerformanceRating':
          serializer.toJson<int?>(winnerPerformanceRating),
      'loserPerformanceRating': serializer.toJson<int?>(loserPerformanceRating),
      'resultFighterAInjury': serializer.toJson<String?>(resultFighterAInjury),
      'resultFighterBInjury': serializer.toJson<String?>(resultFighterBInjury),
    };
  }

  FightRow copyWith(
          {String? id,
          String? eventId,
          String? fighterAId,
          String? fighterBId,
          String? weightClass,
          String? titleFightType,
          bool? isMainEvent,
          bool? isCoMainEvent,
          int? rounds,
          int? cardOrder,
          Value<String?> resultWinnerId = const Value.absent(),
          Value<String?> resultMethod = const Value.absent(),
          Value<int?> resultRound = const Value.absent(),
          Value<int?> winnerPerformanceRating = const Value.absent(),
          Value<int?> loserPerformanceRating = const Value.absent(),
          Value<String?> resultFighterAInjury = const Value.absent(),
          Value<String?> resultFighterBInjury = const Value.absent()}) =>
      FightRow(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        fighterAId: fighterAId ?? this.fighterAId,
        fighterBId: fighterBId ?? this.fighterBId,
        weightClass: weightClass ?? this.weightClass,
        titleFightType: titleFightType ?? this.titleFightType,
        isMainEvent: isMainEvent ?? this.isMainEvent,
        isCoMainEvent: isCoMainEvent ?? this.isCoMainEvent,
        rounds: rounds ?? this.rounds,
        cardOrder: cardOrder ?? this.cardOrder,
        resultWinnerId:
            resultWinnerId.present ? resultWinnerId.value : this.resultWinnerId,
        resultMethod:
            resultMethod.present ? resultMethod.value : this.resultMethod,
        resultRound: resultRound.present ? resultRound.value : this.resultRound,
        winnerPerformanceRating: winnerPerformanceRating.present
            ? winnerPerformanceRating.value
            : this.winnerPerformanceRating,
        loserPerformanceRating: loserPerformanceRating.present
            ? loserPerformanceRating.value
            : this.loserPerformanceRating,
        resultFighterAInjury: resultFighterAInjury.present
            ? resultFighterAInjury.value
            : this.resultFighterAInjury,
        resultFighterBInjury: resultFighterBInjury.present
            ? resultFighterBInjury.value
            : this.resultFighterBInjury,
      );
  FightRow copyWithCompanion(FightsCompanion data) {
    return FightRow(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      fighterAId:
          data.fighterAId.present ? data.fighterAId.value : this.fighterAId,
      fighterBId:
          data.fighterBId.present ? data.fighterBId.value : this.fighterBId,
      weightClass:
          data.weightClass.present ? data.weightClass.value : this.weightClass,
      titleFightType: data.titleFightType.present
          ? data.titleFightType.value
          : this.titleFightType,
      isMainEvent:
          data.isMainEvent.present ? data.isMainEvent.value : this.isMainEvent,
      isCoMainEvent: data.isCoMainEvent.present
          ? data.isCoMainEvent.value
          : this.isCoMainEvent,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      cardOrder: data.cardOrder.present ? data.cardOrder.value : this.cardOrder,
      resultWinnerId: data.resultWinnerId.present
          ? data.resultWinnerId.value
          : this.resultWinnerId,
      resultMethod: data.resultMethod.present
          ? data.resultMethod.value
          : this.resultMethod,
      resultRound:
          data.resultRound.present ? data.resultRound.value : this.resultRound,
      winnerPerformanceRating: data.winnerPerformanceRating.present
          ? data.winnerPerformanceRating.value
          : this.winnerPerformanceRating,
      loserPerformanceRating: data.loserPerformanceRating.present
          ? data.loserPerformanceRating.value
          : this.loserPerformanceRating,
      resultFighterAInjury: data.resultFighterAInjury.present
          ? data.resultFighterAInjury.value
          : this.resultFighterAInjury,
      resultFighterBInjury: data.resultFighterBInjury.present
          ? data.resultFighterBInjury.value
          : this.resultFighterBInjury,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FightRow(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('fighterAId: $fighterAId, ')
          ..write('fighterBId: $fighterBId, ')
          ..write('weightClass: $weightClass, ')
          ..write('titleFightType: $titleFightType, ')
          ..write('isMainEvent: $isMainEvent, ')
          ..write('isCoMainEvent: $isCoMainEvent, ')
          ..write('rounds: $rounds, ')
          ..write('cardOrder: $cardOrder, ')
          ..write('resultWinnerId: $resultWinnerId, ')
          ..write('resultMethod: $resultMethod, ')
          ..write('resultRound: $resultRound, ')
          ..write('winnerPerformanceRating: $winnerPerformanceRating, ')
          ..write('loserPerformanceRating: $loserPerformanceRating, ')
          ..write('resultFighterAInjury: $resultFighterAInjury, ')
          ..write('resultFighterBInjury: $resultFighterBInjury')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      eventId,
      fighterAId,
      fighterBId,
      weightClass,
      titleFightType,
      isMainEvent,
      isCoMainEvent,
      rounds,
      cardOrder,
      resultWinnerId,
      resultMethod,
      resultRound,
      winnerPerformanceRating,
      loserPerformanceRating,
      resultFighterAInjury,
      resultFighterBInjury);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FightRow &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.fighterAId == this.fighterAId &&
          other.fighterBId == this.fighterBId &&
          other.weightClass == this.weightClass &&
          other.titleFightType == this.titleFightType &&
          other.isMainEvent == this.isMainEvent &&
          other.isCoMainEvent == this.isCoMainEvent &&
          other.rounds == this.rounds &&
          other.cardOrder == this.cardOrder &&
          other.resultWinnerId == this.resultWinnerId &&
          other.resultMethod == this.resultMethod &&
          other.resultRound == this.resultRound &&
          other.winnerPerformanceRating == this.winnerPerformanceRating &&
          other.loserPerformanceRating == this.loserPerformanceRating &&
          other.resultFighterAInjury == this.resultFighterAInjury &&
          other.resultFighterBInjury == this.resultFighterBInjury);
}

class FightsCompanion extends UpdateCompanion<FightRow> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> fighterAId;
  final Value<String> fighterBId;
  final Value<String> weightClass;
  final Value<String> titleFightType;
  final Value<bool> isMainEvent;
  final Value<bool> isCoMainEvent;
  final Value<int> rounds;
  final Value<int> cardOrder;
  final Value<String?> resultWinnerId;
  final Value<String?> resultMethod;
  final Value<int?> resultRound;
  final Value<int?> winnerPerformanceRating;
  final Value<int?> loserPerformanceRating;
  final Value<String?> resultFighterAInjury;
  final Value<String?> resultFighterBInjury;
  final Value<int> rowid;
  const FightsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.fighterAId = const Value.absent(),
    this.fighterBId = const Value.absent(),
    this.weightClass = const Value.absent(),
    this.titleFightType = const Value.absent(),
    this.isMainEvent = const Value.absent(),
    this.isCoMainEvent = const Value.absent(),
    this.rounds = const Value.absent(),
    this.cardOrder = const Value.absent(),
    this.resultWinnerId = const Value.absent(),
    this.resultMethod = const Value.absent(),
    this.resultRound = const Value.absent(),
    this.winnerPerformanceRating = const Value.absent(),
    this.loserPerformanceRating = const Value.absent(),
    this.resultFighterAInjury = const Value.absent(),
    this.resultFighterBInjury = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FightsCompanion.insert({
    required String id,
    required String eventId,
    required String fighterAId,
    required String fighterBId,
    required String weightClass,
    this.titleFightType = const Value.absent(),
    this.isMainEvent = const Value.absent(),
    this.isCoMainEvent = const Value.absent(),
    this.rounds = const Value.absent(),
    this.cardOrder = const Value.absent(),
    this.resultWinnerId = const Value.absent(),
    this.resultMethod = const Value.absent(),
    this.resultRound = const Value.absent(),
    this.winnerPerformanceRating = const Value.absent(),
    this.loserPerformanceRating = const Value.absent(),
    this.resultFighterAInjury = const Value.absent(),
    this.resultFighterBInjury = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eventId = Value(eventId),
        fighterAId = Value(fighterAId),
        fighterBId = Value(fighterBId),
        weightClass = Value(weightClass);
  static Insertable<FightRow> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? fighterAId,
    Expression<String>? fighterBId,
    Expression<String>? weightClass,
    Expression<String>? titleFightType,
    Expression<bool>? isMainEvent,
    Expression<bool>? isCoMainEvent,
    Expression<int>? rounds,
    Expression<int>? cardOrder,
    Expression<String>? resultWinnerId,
    Expression<String>? resultMethod,
    Expression<int>? resultRound,
    Expression<int>? winnerPerformanceRating,
    Expression<int>? loserPerformanceRating,
    Expression<String>? resultFighterAInjury,
    Expression<String>? resultFighterBInjury,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (fighterAId != null) 'fighter_a_id': fighterAId,
      if (fighterBId != null) 'fighter_b_id': fighterBId,
      if (weightClass != null) 'weight_class': weightClass,
      if (titleFightType != null) 'title_fight_type': titleFightType,
      if (isMainEvent != null) 'is_main_event': isMainEvent,
      if (isCoMainEvent != null) 'is_co_main_event': isCoMainEvent,
      if (rounds != null) 'rounds': rounds,
      if (cardOrder != null) 'card_order': cardOrder,
      if (resultWinnerId != null) 'result_winner_id': resultWinnerId,
      if (resultMethod != null) 'result_method': resultMethod,
      if (resultRound != null) 'result_round': resultRound,
      if (winnerPerformanceRating != null)
        'winner_performance_rating': winnerPerformanceRating,
      if (loserPerformanceRating != null)
        'loser_performance_rating': loserPerformanceRating,
      if (resultFighterAInjury != null)
        'result_fighter_a_injury': resultFighterAInjury,
      if (resultFighterBInjury != null)
        'result_fighter_b_injury': resultFighterBInjury,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FightsCompanion copyWith(
      {Value<String>? id,
      Value<String>? eventId,
      Value<String>? fighterAId,
      Value<String>? fighterBId,
      Value<String>? weightClass,
      Value<String>? titleFightType,
      Value<bool>? isMainEvent,
      Value<bool>? isCoMainEvent,
      Value<int>? rounds,
      Value<int>? cardOrder,
      Value<String?>? resultWinnerId,
      Value<String?>? resultMethod,
      Value<int?>? resultRound,
      Value<int?>? winnerPerformanceRating,
      Value<int?>? loserPerformanceRating,
      Value<String?>? resultFighterAInjury,
      Value<String?>? resultFighterBInjury,
      Value<int>? rowid}) {
    return FightsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      fighterAId: fighterAId ?? this.fighterAId,
      fighterBId: fighterBId ?? this.fighterBId,
      weightClass: weightClass ?? this.weightClass,
      titleFightType: titleFightType ?? this.titleFightType,
      isMainEvent: isMainEvent ?? this.isMainEvent,
      isCoMainEvent: isCoMainEvent ?? this.isCoMainEvent,
      rounds: rounds ?? this.rounds,
      cardOrder: cardOrder ?? this.cardOrder,
      resultWinnerId: resultWinnerId ?? this.resultWinnerId,
      resultMethod: resultMethod ?? this.resultMethod,
      resultRound: resultRound ?? this.resultRound,
      winnerPerformanceRating:
          winnerPerformanceRating ?? this.winnerPerformanceRating,
      loserPerformanceRating:
          loserPerformanceRating ?? this.loserPerformanceRating,
      resultFighterAInjury: resultFighterAInjury ?? this.resultFighterAInjury,
      resultFighterBInjury: resultFighterBInjury ?? this.resultFighterBInjury,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (fighterAId.present) {
      map['fighter_a_id'] = Variable<String>(fighterAId.value);
    }
    if (fighterBId.present) {
      map['fighter_b_id'] = Variable<String>(fighterBId.value);
    }
    if (weightClass.present) {
      map['weight_class'] = Variable<String>(weightClass.value);
    }
    if (titleFightType.present) {
      map['title_fight_type'] = Variable<String>(titleFightType.value);
    }
    if (isMainEvent.present) {
      map['is_main_event'] = Variable<bool>(isMainEvent.value);
    }
    if (isCoMainEvent.present) {
      map['is_co_main_event'] = Variable<bool>(isCoMainEvent.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (cardOrder.present) {
      map['card_order'] = Variable<int>(cardOrder.value);
    }
    if (resultWinnerId.present) {
      map['result_winner_id'] = Variable<String>(resultWinnerId.value);
    }
    if (resultMethod.present) {
      map['result_method'] = Variable<String>(resultMethod.value);
    }
    if (resultRound.present) {
      map['result_round'] = Variable<int>(resultRound.value);
    }
    if (winnerPerformanceRating.present) {
      map['winner_performance_rating'] =
          Variable<int>(winnerPerformanceRating.value);
    }
    if (loserPerformanceRating.present) {
      map['loser_performance_rating'] =
          Variable<int>(loserPerformanceRating.value);
    }
    if (resultFighterAInjury.present) {
      map['result_fighter_a_injury'] =
          Variable<String>(resultFighterAInjury.value);
    }
    if (resultFighterBInjury.present) {
      map['result_fighter_b_injury'] =
          Variable<String>(resultFighterBInjury.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FightsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('fighterAId: $fighterAId, ')
          ..write('fighterBId: $fighterBId, ')
          ..write('weightClass: $weightClass, ')
          ..write('titleFightType: $titleFightType, ')
          ..write('isMainEvent: $isMainEvent, ')
          ..write('isCoMainEvent: $isCoMainEvent, ')
          ..write('rounds: $rounds, ')
          ..write('cardOrder: $cardOrder, ')
          ..write('resultWinnerId: $resultWinnerId, ')
          ..write('resultMethod: $resultMethod, ')
          ..write('resultRound: $resultRound, ')
          ..write('winnerPerformanceRating: $winnerPerformanceRating, ')
          ..write('loserPerformanceRating: $loserPerformanceRating, ')
          ..write('resultFighterAInjury: $resultFighterAInjury, ')
          ..write('resultFighterBInjury: $resultFighterBInjury, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RandomEventsTable extends RandomEvents
    with TableInfo<$RandomEventsTable, RandomEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RandomEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _affectedFighterIdMeta =
      const VerificationMeta('affectedFighterId');
  @override
  late final GeneratedColumn<String> affectedFighterId =
      GeneratedColumn<String>('affected_fighter_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _headlineMeta =
      const VerificationMeta('headline');
  @override
  late final GeneratedColumn<String> headline = GeneratedColumn<String>(
      'headline', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _choicesJsonMeta =
      const VerificationMeta('choicesJson');
  @override
  late final GeneratedColumn<String> choicesJson = GeneratedColumn<String>(
      'choices_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chosenChoiceIdMeta =
      const VerificationMeta('chosenChoiceId');
  @override
  late final GeneratedColumn<String> chosenChoiceId = GeneratedColumn<String>(
      'chosen_choice_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _occurredOnMeta =
      const VerificationMeta('occurredOn');
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
      'occurred_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        affectedFighterId,
        headline,
        description,
        choicesJson,
        chosenChoiceId,
        occurredOn
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'random_events';
  @override
  VerificationContext validateIntegrity(Insertable<RandomEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('affected_fighter_id')) {
      context.handle(
          _affectedFighterIdMeta,
          affectedFighterId.isAcceptableOrUnknown(
              data['affected_fighter_id']!, _affectedFighterIdMeta));
    }
    if (data.containsKey('headline')) {
      context.handle(_headlineMeta,
          headline.isAcceptableOrUnknown(data['headline']!, _headlineMeta));
    } else if (isInserting) {
      context.missing(_headlineMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('choices_json')) {
      context.handle(
          _choicesJsonMeta,
          choicesJson.isAcceptableOrUnknown(
              data['choices_json']!, _choicesJsonMeta));
    } else if (isInserting) {
      context.missing(_choicesJsonMeta);
    }
    if (data.containsKey('chosen_choice_id')) {
      context.handle(
          _chosenChoiceIdMeta,
          chosenChoiceId.isAcceptableOrUnknown(
              data['chosen_choice_id']!, _chosenChoiceIdMeta));
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
          _occurredOnMeta,
          occurredOn.isAcceptableOrUnknown(
              data['occurred_on']!, _occurredOnMeta));
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RandomEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RandomEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      affectedFighterId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}affected_fighter_id']),
      headline: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headline'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      choicesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}choices_json'])!,
      chosenChoiceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}chosen_choice_id']),
      occurredOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_on'])!,
    );
  }

  @override
  $RandomEventsTable createAlias(String alias) {
    return $RandomEventsTable(attachedDatabase, alias);
  }
}

class RandomEventRow extends DataClass implements Insertable<RandomEventRow> {
  final String id;
  final String type;
  final String? affectedFighterId;
  final String headline;
  final String description;

  /// JSON-encoded list of `{id, label, consequenceSummary}` objects.
  final String choicesJson;
  final String? chosenChoiceId;
  final DateTime occurredOn;
  const RandomEventRow(
      {required this.id,
      required this.type,
      this.affectedFighterId,
      required this.headline,
      required this.description,
      required this.choicesJson,
      this.chosenChoiceId,
      required this.occurredOn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || affectedFighterId != null) {
      map['affected_fighter_id'] = Variable<String>(affectedFighterId);
    }
    map['headline'] = Variable<String>(headline);
    map['description'] = Variable<String>(description);
    map['choices_json'] = Variable<String>(choicesJson);
    if (!nullToAbsent || chosenChoiceId != null) {
      map['chosen_choice_id'] = Variable<String>(chosenChoiceId);
    }
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    return map;
  }

  RandomEventsCompanion toCompanion(bool nullToAbsent) {
    return RandomEventsCompanion(
      id: Value(id),
      type: Value(type),
      affectedFighterId: affectedFighterId == null && nullToAbsent
          ? const Value.absent()
          : Value(affectedFighterId),
      headline: Value(headline),
      description: Value(description),
      choicesJson: Value(choicesJson),
      chosenChoiceId: chosenChoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(chosenChoiceId),
      occurredOn: Value(occurredOn),
    );
  }

  factory RandomEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RandomEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      affectedFighterId:
          serializer.fromJson<String?>(json['affectedFighterId']),
      headline: serializer.fromJson<String>(json['headline']),
      description: serializer.fromJson<String>(json['description']),
      choicesJson: serializer.fromJson<String>(json['choicesJson']),
      chosenChoiceId: serializer.fromJson<String?>(json['chosenChoiceId']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'affectedFighterId': serializer.toJson<String?>(affectedFighterId),
      'headline': serializer.toJson<String>(headline),
      'description': serializer.toJson<String>(description),
      'choicesJson': serializer.toJson<String>(choicesJson),
      'chosenChoiceId': serializer.toJson<String?>(chosenChoiceId),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
    };
  }

  RandomEventRow copyWith(
          {String? id,
          String? type,
          Value<String?> affectedFighterId = const Value.absent(),
          String? headline,
          String? description,
          String? choicesJson,
          Value<String?> chosenChoiceId = const Value.absent(),
          DateTime? occurredOn}) =>
      RandomEventRow(
        id: id ?? this.id,
        type: type ?? this.type,
        affectedFighterId: affectedFighterId.present
            ? affectedFighterId.value
            : this.affectedFighterId,
        headline: headline ?? this.headline,
        description: description ?? this.description,
        choicesJson: choicesJson ?? this.choicesJson,
        chosenChoiceId:
            chosenChoiceId.present ? chosenChoiceId.value : this.chosenChoiceId,
        occurredOn: occurredOn ?? this.occurredOn,
      );
  RandomEventRow copyWithCompanion(RandomEventsCompanion data) {
    return RandomEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      affectedFighterId: data.affectedFighterId.present
          ? data.affectedFighterId.value
          : this.affectedFighterId,
      headline: data.headline.present ? data.headline.value : this.headline,
      description:
          data.description.present ? data.description.value : this.description,
      choicesJson:
          data.choicesJson.present ? data.choicesJson.value : this.choicesJson,
      chosenChoiceId: data.chosenChoiceId.present
          ? data.chosenChoiceId.value
          : this.chosenChoiceId,
      occurredOn:
          data.occurredOn.present ? data.occurredOn.value : this.occurredOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RandomEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('affectedFighterId: $affectedFighterId, ')
          ..write('headline: $headline, ')
          ..write('description: $description, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('chosenChoiceId: $chosenChoiceId, ')
          ..write('occurredOn: $occurredOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, affectedFighterId, headline,
      description, choicesJson, chosenChoiceId, occurredOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RandomEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.affectedFighterId == this.affectedFighterId &&
          other.headline == this.headline &&
          other.description == this.description &&
          other.choicesJson == this.choicesJson &&
          other.chosenChoiceId == this.chosenChoiceId &&
          other.occurredOn == this.occurredOn);
}

class RandomEventsCompanion extends UpdateCompanion<RandomEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> affectedFighterId;
  final Value<String> headline;
  final Value<String> description;
  final Value<String> choicesJson;
  final Value<String?> chosenChoiceId;
  final Value<DateTime> occurredOn;
  final Value<int> rowid;
  const RandomEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.affectedFighterId = const Value.absent(),
    this.headline = const Value.absent(),
    this.description = const Value.absent(),
    this.choicesJson = const Value.absent(),
    this.chosenChoiceId = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RandomEventsCompanion.insert({
    required String id,
    required String type,
    this.affectedFighterId = const Value.absent(),
    required String headline,
    required String description,
    required String choicesJson,
    this.chosenChoiceId = const Value.absent(),
    required DateTime occurredOn,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        headline = Value(headline),
        description = Value(description),
        choicesJson = Value(choicesJson),
        occurredOn = Value(occurredOn);
  static Insertable<RandomEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? affectedFighterId,
    Expression<String>? headline,
    Expression<String>? description,
    Expression<String>? choicesJson,
    Expression<String>? chosenChoiceId,
    Expression<DateTime>? occurredOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (affectedFighterId != null) 'affected_fighter_id': affectedFighterId,
      if (headline != null) 'headline': headline,
      if (description != null) 'description': description,
      if (choicesJson != null) 'choices_json': choicesJson,
      if (chosenChoiceId != null) 'chosen_choice_id': chosenChoiceId,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RandomEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String?>? affectedFighterId,
      Value<String>? headline,
      Value<String>? description,
      Value<String>? choicesJson,
      Value<String?>? chosenChoiceId,
      Value<DateTime>? occurredOn,
      Value<int>? rowid}) {
    return RandomEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      affectedFighterId: affectedFighterId ?? this.affectedFighterId,
      headline: headline ?? this.headline,
      description: description ?? this.description,
      choicesJson: choicesJson ?? this.choicesJson,
      chosenChoiceId: chosenChoiceId ?? this.chosenChoiceId,
      occurredOn: occurredOn ?? this.occurredOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (affectedFighterId.present) {
      map['affected_fighter_id'] = Variable<String>(affectedFighterId.value);
    }
    if (headline.present) {
      map['headline'] = Variable<String>(headline.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (choicesJson.present) {
      map['choices_json'] = Variable<String>(choicesJson.value);
    }
    if (chosenChoiceId.present) {
      map['chosen_choice_id'] = Variable<String>(chosenChoiceId.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RandomEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('affectedFighterId: $affectedFighterId, ')
          ..write('headline: $headline, ')
          ..write('description: $description, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('chosenChoiceId: $chosenChoiceId, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FightersTable fighters = $FightersTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $FightsTable fights = $FightsTable(this);
  late final $RandomEventsTable randomEvents = $RandomEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [fighters, contracts, organizations, events, fights, randomEvents];
}

typedef $$FightersTableCreateCompanionBuilder = FightersCompanion Function({
  required String id,
  required String name,
  required int age,
  required String nationality,
  required String weightClass,
  Value<int> heightInches,
  Value<int> weightLbs,
  Value<int> wins,
  Value<int> losses,
  Value<int> draws,
  required int striking,
  required int grappling,
  required int cardio,
  required int chin,
  required int power,
  Value<int> popularity,
  Value<int> morale,
  Value<String> injuryStatus,
  Value<int> winStreak,
  Value<String> styleTags,
  Value<int> rowid,
});
typedef $$FightersTableUpdateCompanionBuilder = FightersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> age,
  Value<String> nationality,
  Value<String> weightClass,
  Value<int> heightInches,
  Value<int> weightLbs,
  Value<int> wins,
  Value<int> losses,
  Value<int> draws,
  Value<int> striking,
  Value<int> grappling,
  Value<int> cardio,
  Value<int> chin,
  Value<int> power,
  Value<int> popularity,
  Value<int> morale,
  Value<String> injuryStatus,
  Value<int> winStreak,
  Value<String> styleTags,
  Value<int> rowid,
});

class $$FightersTableFilterComposer
    extends Composer<_$AppDatabase, $FightersTable> {
  $$FightersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heightInches => $composableBuilder(
      column: $table.heightInches, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weightLbs => $composableBuilder(
      column: $table.weightLbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wins => $composableBuilder(
      column: $table.wins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get losses => $composableBuilder(
      column: $table.losses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get draws => $composableBuilder(
      column: $table.draws, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get striking => $composableBuilder(
      column: $table.striking, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grappling => $composableBuilder(
      column: $table.grappling, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardio => $composableBuilder(
      column: $table.cardio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chin => $composableBuilder(
      column: $table.chin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get power => $composableBuilder(
      column: $table.power, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get morale => $composableBuilder(
      column: $table.morale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get injuryStatus => $composableBuilder(
      column: $table.injuryStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get winStreak => $composableBuilder(
      column: $table.winStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get styleTags => $composableBuilder(
      column: $table.styleTags, builder: (column) => ColumnFilters(column));
}

class $$FightersTableOrderingComposer
    extends Composer<_$AppDatabase, $FightersTable> {
  $$FightersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heightInches => $composableBuilder(
      column: $table.heightInches,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weightLbs => $composableBuilder(
      column: $table.weightLbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wins => $composableBuilder(
      column: $table.wins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get losses => $composableBuilder(
      column: $table.losses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get draws => $composableBuilder(
      column: $table.draws, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get striking => $composableBuilder(
      column: $table.striking, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grappling => $composableBuilder(
      column: $table.grappling, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardio => $composableBuilder(
      column: $table.cardio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chin => $composableBuilder(
      column: $table.chin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get power => $composableBuilder(
      column: $table.power, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get morale => $composableBuilder(
      column: $table.morale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get injuryStatus => $composableBuilder(
      column: $table.injuryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get winStreak => $composableBuilder(
      column: $table.winStreak, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get styleTags => $composableBuilder(
      column: $table.styleTags, builder: (column) => ColumnOrderings(column));
}

class $$FightersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FightersTable> {
  $$FightersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => column);

  GeneratedColumn<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => column);

  GeneratedColumn<int> get heightInches => $composableBuilder(
      column: $table.heightInches, builder: (column) => column);

  GeneratedColumn<int> get weightLbs =>
      $composableBuilder(column: $table.weightLbs, builder: (column) => column);

  GeneratedColumn<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => column);

  GeneratedColumn<int> get losses =>
      $composableBuilder(column: $table.losses, builder: (column) => column);

  GeneratedColumn<int> get draws =>
      $composableBuilder(column: $table.draws, builder: (column) => column);

  GeneratedColumn<int> get striking =>
      $composableBuilder(column: $table.striking, builder: (column) => column);

  GeneratedColumn<int> get grappling =>
      $composableBuilder(column: $table.grappling, builder: (column) => column);

  GeneratedColumn<int> get cardio =>
      $composableBuilder(column: $table.cardio, builder: (column) => column);

  GeneratedColumn<int> get chin =>
      $composableBuilder(column: $table.chin, builder: (column) => column);

  GeneratedColumn<int> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => column);

  GeneratedColumn<int> get morale =>
      $composableBuilder(column: $table.morale, builder: (column) => column);

  GeneratedColumn<String> get injuryStatus => $composableBuilder(
      column: $table.injuryStatus, builder: (column) => column);

  GeneratedColumn<int> get winStreak =>
      $composableBuilder(column: $table.winStreak, builder: (column) => column);

  GeneratedColumn<String> get styleTags =>
      $composableBuilder(column: $table.styleTags, builder: (column) => column);
}

class $$FightersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FightersTable,
    FighterRow,
    $$FightersTableFilterComposer,
    $$FightersTableOrderingComposer,
    $$FightersTableAnnotationComposer,
    $$FightersTableCreateCompanionBuilder,
    $$FightersTableUpdateCompanionBuilder,
    (FighterRow, BaseReferences<_$AppDatabase, $FightersTable, FighterRow>),
    FighterRow,
    PrefetchHooks Function()> {
  $$FightersTableTableManager(_$AppDatabase db, $FightersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FightersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FightersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FightersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<String> nationality = const Value.absent(),
            Value<String> weightClass = const Value.absent(),
            Value<int> heightInches = const Value.absent(),
            Value<int> weightLbs = const Value.absent(),
            Value<int> wins = const Value.absent(),
            Value<int> losses = const Value.absent(),
            Value<int> draws = const Value.absent(),
            Value<int> striking = const Value.absent(),
            Value<int> grappling = const Value.absent(),
            Value<int> cardio = const Value.absent(),
            Value<int> chin = const Value.absent(),
            Value<int> power = const Value.absent(),
            Value<int> popularity = const Value.absent(),
            Value<int> morale = const Value.absent(),
            Value<String> injuryStatus = const Value.absent(),
            Value<int> winStreak = const Value.absent(),
            Value<String> styleTags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightersCompanion(
            id: id,
            name: name,
            age: age,
            nationality: nationality,
            weightClass: weightClass,
            heightInches: heightInches,
            weightLbs: weightLbs,
            wins: wins,
            losses: losses,
            draws: draws,
            striking: striking,
            grappling: grappling,
            cardio: cardio,
            chin: chin,
            power: power,
            popularity: popularity,
            morale: morale,
            injuryStatus: injuryStatus,
            winStreak: winStreak,
            styleTags: styleTags,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int age,
            required String nationality,
            required String weightClass,
            Value<int> heightInches = const Value.absent(),
            Value<int> weightLbs = const Value.absent(),
            Value<int> wins = const Value.absent(),
            Value<int> losses = const Value.absent(),
            Value<int> draws = const Value.absent(),
            required int striking,
            required int grappling,
            required int cardio,
            required int chin,
            required int power,
            Value<int> popularity = const Value.absent(),
            Value<int> morale = const Value.absent(),
            Value<String> injuryStatus = const Value.absent(),
            Value<int> winStreak = const Value.absent(),
            Value<String> styleTags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightersCompanion.insert(
            id: id,
            name: name,
            age: age,
            nationality: nationality,
            weightClass: weightClass,
            heightInches: heightInches,
            weightLbs: weightLbs,
            wins: wins,
            losses: losses,
            draws: draws,
            striking: striking,
            grappling: grappling,
            cardio: cardio,
            chin: chin,
            power: power,
            popularity: popularity,
            morale: morale,
            injuryStatus: injuryStatus,
            winStreak: winStreak,
            styleTags: styleTags,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FightersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FightersTable,
    FighterRow,
    $$FightersTableFilterComposer,
    $$FightersTableOrderingComposer,
    $$FightersTableAnnotationComposer,
    $$FightersTableCreateCompanionBuilder,
    $$FightersTableUpdateCompanionBuilder,
    (FighterRow, BaseReferences<_$AppDatabase, $FightersTable, FighterRow>),
    FighterRow,
    PrefetchHooks Function()>;
typedef $$ContractsTableCreateCompanionBuilder = ContractsCompanion Function({
  required String id,
  required String fighterId,
  required int fightsRemaining,
  required int payPerFight,
  Value<bool> exclusive,
  required DateTime signedOn,
  Value<int> rowid,
});
typedef $$ContractsTableUpdateCompanionBuilder = ContractsCompanion Function({
  Value<String> id,
  Value<String> fighterId,
  Value<int> fightsRemaining,
  Value<int> payPerFight,
  Value<bool> exclusive,
  Value<DateTime> signedOn,
  Value<int> rowid,
});

class $$ContractsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fighterId => $composableBuilder(
      column: $table.fighterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fightsRemaining => $composableBuilder(
      column: $table.fightsRemaining,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get payPerFight => $composableBuilder(
      column: $table.payPerFight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exclusive => $composableBuilder(
      column: $table.exclusive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get signedOn => $composableBuilder(
      column: $table.signedOn, builder: (column) => ColumnFilters(column));
}

class $$ContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fighterId => $composableBuilder(
      column: $table.fighterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fightsRemaining => $composableBuilder(
      column: $table.fightsRemaining,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get payPerFight => $composableBuilder(
      column: $table.payPerFight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exclusive => $composableBuilder(
      column: $table.exclusive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get signedOn => $composableBuilder(
      column: $table.signedOn, builder: (column) => ColumnOrderings(column));
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fighterId =>
      $composableBuilder(column: $table.fighterId, builder: (column) => column);

  GeneratedColumn<int> get fightsRemaining => $composableBuilder(
      column: $table.fightsRemaining, builder: (column) => column);

  GeneratedColumn<int> get payPerFight => $composableBuilder(
      column: $table.payPerFight, builder: (column) => column);

  GeneratedColumn<bool> get exclusive =>
      $composableBuilder(column: $table.exclusive, builder: (column) => column);

  GeneratedColumn<DateTime> get signedOn =>
      $composableBuilder(column: $table.signedOn, builder: (column) => column);
}

class $$ContractsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContractsTable,
    ContractRow,
    $$ContractsTableFilterComposer,
    $$ContractsTableOrderingComposer,
    $$ContractsTableAnnotationComposer,
    $$ContractsTableCreateCompanionBuilder,
    $$ContractsTableUpdateCompanionBuilder,
    (ContractRow, BaseReferences<_$AppDatabase, $ContractsTable, ContractRow>),
    ContractRow,
    PrefetchHooks Function()> {
  $$ContractsTableTableManager(_$AppDatabase db, $ContractsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fighterId = const Value.absent(),
            Value<int> fightsRemaining = const Value.absent(),
            Value<int> payPerFight = const Value.absent(),
            Value<bool> exclusive = const Value.absent(),
            Value<DateTime> signedOn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContractsCompanion(
            id: id,
            fighterId: fighterId,
            fightsRemaining: fightsRemaining,
            payPerFight: payPerFight,
            exclusive: exclusive,
            signedOn: signedOn,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fighterId,
            required int fightsRemaining,
            required int payPerFight,
            Value<bool> exclusive = const Value.absent(),
            required DateTime signedOn,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContractsCompanion.insert(
            id: id,
            fighterId: fighterId,
            fightsRemaining: fightsRemaining,
            payPerFight: payPerFight,
            exclusive: exclusive,
            signedOn: signedOn,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContractsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContractsTable,
    ContractRow,
    $$ContractsTableFilterComposer,
    $$ContractsTableOrderingComposer,
    $$ContractsTableAnnotationComposer,
    $$ContractsTableCreateCompanionBuilder,
    $$ContractsTableUpdateCompanionBuilder,
    (ContractRow, BaseReferences<_$AppDatabase, $ContractsTable, ContractRow>),
    ContractRow,
    PrefetchHooks Function()>;
typedef $$OrganizationsTableCreateCompanionBuilder = OrganizationsCompanion
    Function({
  required String id,
  required String name,
  Value<String> reputationTier,
  Value<int> reputationPoints,
  required int cashBalance,
  Value<int> fanbaseSize,
  required String homeRegion,
  Value<int> promotionBudget,
  Value<int> rowid,
});
typedef $$OrganizationsTableUpdateCompanionBuilder = OrganizationsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> reputationTier,
  Value<int> reputationPoints,
  Value<int> cashBalance,
  Value<int> fanbaseSize,
  Value<String> homeRegion,
  Value<int> promotionBudget,
  Value<int> rowid,
});

class $$OrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reputationTier => $composableBuilder(
      column: $table.reputationTier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reputationPoints => $composableBuilder(
      column: $table.reputationPoints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fanbaseSize => $composableBuilder(
      column: $table.fanbaseSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeRegion => $composableBuilder(
      column: $table.homeRegion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promotionBudget => $composableBuilder(
      column: $table.promotionBudget,
      builder: (column) => ColumnFilters(column));
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reputationTier => $composableBuilder(
      column: $table.reputationTier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reputationPoints => $composableBuilder(
      column: $table.reputationPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fanbaseSize => $composableBuilder(
      column: $table.fanbaseSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeRegion => $composableBuilder(
      column: $table.homeRegion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promotionBudget => $composableBuilder(
      column: $table.promotionBudget,
      builder: (column) => ColumnOrderings(column));
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get reputationTier => $composableBuilder(
      column: $table.reputationTier, builder: (column) => column);

  GeneratedColumn<int> get reputationPoints => $composableBuilder(
      column: $table.reputationPoints, builder: (column) => column);

  GeneratedColumn<int> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => column);

  GeneratedColumn<int> get fanbaseSize => $composableBuilder(
      column: $table.fanbaseSize, builder: (column) => column);

  GeneratedColumn<String> get homeRegion => $composableBuilder(
      column: $table.homeRegion, builder: (column) => column);

  GeneratedColumn<int> get promotionBudget => $composableBuilder(
      column: $table.promotionBudget, builder: (column) => column);
}

class $$OrganizationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    OrganizationRow,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (
      OrganizationRow,
      BaseReferences<_$AppDatabase, $OrganizationsTable, OrganizationRow>
    ),
    OrganizationRow,
    PrefetchHooks Function()> {
  $$OrganizationsTableTableManager(_$AppDatabase db, $OrganizationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> reputationTier = const Value.absent(),
            Value<int> reputationPoints = const Value.absent(),
            Value<int> cashBalance = const Value.absent(),
            Value<int> fanbaseSize = const Value.absent(),
            Value<String> homeRegion = const Value.absent(),
            Value<int> promotionBudget = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrganizationsCompanion(
            id: id,
            name: name,
            reputationTier: reputationTier,
            reputationPoints: reputationPoints,
            cashBalance: cashBalance,
            fanbaseSize: fanbaseSize,
            homeRegion: homeRegion,
            promotionBudget: promotionBudget,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> reputationTier = const Value.absent(),
            Value<int> reputationPoints = const Value.absent(),
            required int cashBalance,
            Value<int> fanbaseSize = const Value.absent(),
            required String homeRegion,
            Value<int> promotionBudget = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrganizationsCompanion.insert(
            id: id,
            name: name,
            reputationTier: reputationTier,
            reputationPoints: reputationPoints,
            cashBalance: cashBalance,
            fanbaseSize: fanbaseSize,
            homeRegion: homeRegion,
            promotionBudget: promotionBudget,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrganizationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    OrganizationRow,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (
      OrganizationRow,
      BaseReferences<_$AppDatabase, $OrganizationsTable, OrganizationRow>
    ),
    OrganizationRow,
    PrefetchHooks Function()>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String name,
  required DateTime date,
  required String venue,
  Value<int> ticketPrice,
  Value<String> status,
  Value<int> promotionBudgetSpent,
  Value<int> attendance,
  Value<int> ppvBuys,
  Value<int> revenue,
  Value<int> expenses,
  Value<int> reputationChange,
  Value<String?> fightOfTheNightFightId,
  Value<String?> performanceOfTheNightFighterId,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> date,
  Value<String> venue,
  Value<int> ticketPrice,
  Value<String> status,
  Value<int> promotionBudgetSpent,
  Value<int> attendance,
  Value<int> ppvBuys,
  Value<int> revenue,
  Value<int> expenses,
  Value<int> reputationChange,
  Value<String?> fightOfTheNightFightId,
  Value<String?> performanceOfTheNightFighterId,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ticketPrice => $composableBuilder(
      column: $table.ticketPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promotionBudgetSpent => $composableBuilder(
      column: $table.promotionBudgetSpent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attendance => $composableBuilder(
      column: $table.attendance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ppvBuys => $composableBuilder(
      column: $table.ppvBuys, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revenue => $composableBuilder(
      column: $table.revenue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expenses => $composableBuilder(
      column: $table.expenses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reputationChange => $composableBuilder(
      column: $table.reputationChange,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fightOfTheNightFightId => $composableBuilder(
      column: $table.fightOfTheNightFightId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get performanceOfTheNightFighterId =>
      $composableBuilder(
          column: $table.performanceOfTheNightFighterId,
          builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ticketPrice => $composableBuilder(
      column: $table.ticketPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promotionBudgetSpent => $composableBuilder(
      column: $table.promotionBudgetSpent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attendance => $composableBuilder(
      column: $table.attendance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ppvBuys => $composableBuilder(
      column: $table.ppvBuys, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revenue => $composableBuilder(
      column: $table.revenue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expenses => $composableBuilder(
      column: $table.expenses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reputationChange => $composableBuilder(
      column: $table.reputationChange,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fightOfTheNightFightId => $composableBuilder(
      column: $table.fightOfTheNightFightId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get performanceOfTheNightFighterId =>
      $composableBuilder(
          column: $table.performanceOfTheNightFighterId,
          builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<int> get ticketPrice => $composableBuilder(
      column: $table.ticketPrice, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get promotionBudgetSpent => $composableBuilder(
      column: $table.promotionBudgetSpent, builder: (column) => column);

  GeneratedColumn<int> get attendance => $composableBuilder(
      column: $table.attendance, builder: (column) => column);

  GeneratedColumn<int> get ppvBuys =>
      $composableBuilder(column: $table.ppvBuys, builder: (column) => column);

  GeneratedColumn<int> get revenue =>
      $composableBuilder(column: $table.revenue, builder: (column) => column);

  GeneratedColumn<int> get expenses =>
      $composableBuilder(column: $table.expenses, builder: (column) => column);

  GeneratedColumn<int> get reputationChange => $composableBuilder(
      column: $table.reputationChange, builder: (column) => column);

  GeneratedColumn<String> get fightOfTheNightFightId => $composableBuilder(
      column: $table.fightOfTheNightFightId, builder: (column) => column);

  GeneratedColumn<String> get performanceOfTheNightFighterId =>
      $composableBuilder(
          column: $table.performanceOfTheNightFighterId,
          builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    EventRow,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
    EventRow,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> venue = const Value.absent(),
            Value<int> ticketPrice = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> promotionBudgetSpent = const Value.absent(),
            Value<int> attendance = const Value.absent(),
            Value<int> ppvBuys = const Value.absent(),
            Value<int> revenue = const Value.absent(),
            Value<int> expenses = const Value.absent(),
            Value<int> reputationChange = const Value.absent(),
            Value<String?> fightOfTheNightFightId = const Value.absent(),
            Value<String?> performanceOfTheNightFighterId =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            name: name,
            date: date,
            venue: venue,
            ticketPrice: ticketPrice,
            status: status,
            promotionBudgetSpent: promotionBudgetSpent,
            attendance: attendance,
            ppvBuys: ppvBuys,
            revenue: revenue,
            expenses: expenses,
            reputationChange: reputationChange,
            fightOfTheNightFightId: fightOfTheNightFightId,
            performanceOfTheNightFighterId: performanceOfTheNightFighterId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime date,
            required String venue,
            Value<int> ticketPrice = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> promotionBudgetSpent = const Value.absent(),
            Value<int> attendance = const Value.absent(),
            Value<int> ppvBuys = const Value.absent(),
            Value<int> revenue = const Value.absent(),
            Value<int> expenses = const Value.absent(),
            Value<int> reputationChange = const Value.absent(),
            Value<String?> fightOfTheNightFightId = const Value.absent(),
            Value<String?> performanceOfTheNightFighterId =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            name: name,
            date: date,
            venue: venue,
            ticketPrice: ticketPrice,
            status: status,
            promotionBudgetSpent: promotionBudgetSpent,
            attendance: attendance,
            ppvBuys: ppvBuys,
            revenue: revenue,
            expenses: expenses,
            reputationChange: reputationChange,
            fightOfTheNightFightId: fightOfTheNightFightId,
            performanceOfTheNightFighterId: performanceOfTheNightFighterId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    EventRow,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
    EventRow,
    PrefetchHooks Function()>;
typedef $$FightsTableCreateCompanionBuilder = FightsCompanion Function({
  required String id,
  required String eventId,
  required String fighterAId,
  required String fighterBId,
  required String weightClass,
  Value<String> titleFightType,
  Value<bool> isMainEvent,
  Value<bool> isCoMainEvent,
  Value<int> rounds,
  Value<int> cardOrder,
  Value<String?> resultWinnerId,
  Value<String?> resultMethod,
  Value<int?> resultRound,
  Value<int?> winnerPerformanceRating,
  Value<int?> loserPerformanceRating,
  Value<String?> resultFighterAInjury,
  Value<String?> resultFighterBInjury,
  Value<int> rowid,
});
typedef $$FightsTableUpdateCompanionBuilder = FightsCompanion Function({
  Value<String> id,
  Value<String> eventId,
  Value<String> fighterAId,
  Value<String> fighterBId,
  Value<String> weightClass,
  Value<String> titleFightType,
  Value<bool> isMainEvent,
  Value<bool> isCoMainEvent,
  Value<int> rounds,
  Value<int> cardOrder,
  Value<String?> resultWinnerId,
  Value<String?> resultMethod,
  Value<int?> resultRound,
  Value<int?> winnerPerformanceRating,
  Value<int?> loserPerformanceRating,
  Value<String?> resultFighterAInjury,
  Value<String?> resultFighterBInjury,
  Value<int> rowid,
});

class $$FightsTableFilterComposer
    extends Composer<_$AppDatabase, $FightsTable> {
  $$FightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fighterAId => $composableBuilder(
      column: $table.fighterAId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fighterBId => $composableBuilder(
      column: $table.fighterBId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleFightType => $composableBuilder(
      column: $table.titleFightType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMainEvent => $composableBuilder(
      column: $table.isMainEvent, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCoMainEvent => $composableBuilder(
      column: $table.isCoMainEvent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rounds => $composableBuilder(
      column: $table.rounds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardOrder => $composableBuilder(
      column: $table.cardOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultWinnerId => $composableBuilder(
      column: $table.resultWinnerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultMethod => $composableBuilder(
      column: $table.resultMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resultRound => $composableBuilder(
      column: $table.resultRound, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get winnerPerformanceRating => $composableBuilder(
      column: $table.winnerPerformanceRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get loserPerformanceRating => $composableBuilder(
      column: $table.loserPerformanceRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultFighterAInjury => $composableBuilder(
      column: $table.resultFighterAInjury,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultFighterBInjury => $composableBuilder(
      column: $table.resultFighterBInjury,
      builder: (column) => ColumnFilters(column));
}

class $$FightsTableOrderingComposer
    extends Composer<_$AppDatabase, $FightsTable> {
  $$FightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fighterAId => $composableBuilder(
      column: $table.fighterAId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fighterBId => $composableBuilder(
      column: $table.fighterBId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleFightType => $composableBuilder(
      column: $table.titleFightType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMainEvent => $composableBuilder(
      column: $table.isMainEvent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCoMainEvent => $composableBuilder(
      column: $table.isCoMainEvent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rounds => $composableBuilder(
      column: $table.rounds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardOrder => $composableBuilder(
      column: $table.cardOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultWinnerId => $composableBuilder(
      column: $table.resultWinnerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultMethod => $composableBuilder(
      column: $table.resultMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resultRound => $composableBuilder(
      column: $table.resultRound, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get winnerPerformanceRating => $composableBuilder(
      column: $table.winnerPerformanceRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get loserPerformanceRating => $composableBuilder(
      column: $table.loserPerformanceRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultFighterAInjury => $composableBuilder(
      column: $table.resultFighterAInjury,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultFighterBInjury => $composableBuilder(
      column: $table.resultFighterBInjury,
      builder: (column) => ColumnOrderings(column));
}

class $$FightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FightsTable> {
  $$FightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get fighterAId => $composableBuilder(
      column: $table.fighterAId, builder: (column) => column);

  GeneratedColumn<String> get fighterBId => $composableBuilder(
      column: $table.fighterBId, builder: (column) => column);

  GeneratedColumn<String> get weightClass => $composableBuilder(
      column: $table.weightClass, builder: (column) => column);

  GeneratedColumn<String> get titleFightType => $composableBuilder(
      column: $table.titleFightType, builder: (column) => column);

  GeneratedColumn<bool> get isMainEvent => $composableBuilder(
      column: $table.isMainEvent, builder: (column) => column);

  GeneratedColumn<bool> get isCoMainEvent => $composableBuilder(
      column: $table.isCoMainEvent, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get cardOrder =>
      $composableBuilder(column: $table.cardOrder, builder: (column) => column);

  GeneratedColumn<String> get resultWinnerId => $composableBuilder(
      column: $table.resultWinnerId, builder: (column) => column);

  GeneratedColumn<String> get resultMethod => $composableBuilder(
      column: $table.resultMethod, builder: (column) => column);

  GeneratedColumn<int> get resultRound => $composableBuilder(
      column: $table.resultRound, builder: (column) => column);

  GeneratedColumn<int> get winnerPerformanceRating => $composableBuilder(
      column: $table.winnerPerformanceRating, builder: (column) => column);

  GeneratedColumn<int> get loserPerformanceRating => $composableBuilder(
      column: $table.loserPerformanceRating, builder: (column) => column);

  GeneratedColumn<String> get resultFighterAInjury => $composableBuilder(
      column: $table.resultFighterAInjury, builder: (column) => column);

  GeneratedColumn<String> get resultFighterBInjury => $composableBuilder(
      column: $table.resultFighterBInjury, builder: (column) => column);
}

class $$FightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FightsTable,
    FightRow,
    $$FightsTableFilterComposer,
    $$FightsTableOrderingComposer,
    $$FightsTableAnnotationComposer,
    $$FightsTableCreateCompanionBuilder,
    $$FightsTableUpdateCompanionBuilder,
    (FightRow, BaseReferences<_$AppDatabase, $FightsTable, FightRow>),
    FightRow,
    PrefetchHooks Function()> {
  $$FightsTableTableManager(_$AppDatabase db, $FightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> fighterAId = const Value.absent(),
            Value<String> fighterBId = const Value.absent(),
            Value<String> weightClass = const Value.absent(),
            Value<String> titleFightType = const Value.absent(),
            Value<bool> isMainEvent = const Value.absent(),
            Value<bool> isCoMainEvent = const Value.absent(),
            Value<int> rounds = const Value.absent(),
            Value<int> cardOrder = const Value.absent(),
            Value<String?> resultWinnerId = const Value.absent(),
            Value<String?> resultMethod = const Value.absent(),
            Value<int?> resultRound = const Value.absent(),
            Value<int?> winnerPerformanceRating = const Value.absent(),
            Value<int?> loserPerformanceRating = const Value.absent(),
            Value<String?> resultFighterAInjury = const Value.absent(),
            Value<String?> resultFighterBInjury = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightsCompanion(
            id: id,
            eventId: eventId,
            fighterAId: fighterAId,
            fighterBId: fighterBId,
            weightClass: weightClass,
            titleFightType: titleFightType,
            isMainEvent: isMainEvent,
            isCoMainEvent: isCoMainEvent,
            rounds: rounds,
            cardOrder: cardOrder,
            resultWinnerId: resultWinnerId,
            resultMethod: resultMethod,
            resultRound: resultRound,
            winnerPerformanceRating: winnerPerformanceRating,
            loserPerformanceRating: loserPerformanceRating,
            resultFighterAInjury: resultFighterAInjury,
            resultFighterBInjury: resultFighterBInjury,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String eventId,
            required String fighterAId,
            required String fighterBId,
            required String weightClass,
            Value<String> titleFightType = const Value.absent(),
            Value<bool> isMainEvent = const Value.absent(),
            Value<bool> isCoMainEvent = const Value.absent(),
            Value<int> rounds = const Value.absent(),
            Value<int> cardOrder = const Value.absent(),
            Value<String?> resultWinnerId = const Value.absent(),
            Value<String?> resultMethod = const Value.absent(),
            Value<int?> resultRound = const Value.absent(),
            Value<int?> winnerPerformanceRating = const Value.absent(),
            Value<int?> loserPerformanceRating = const Value.absent(),
            Value<String?> resultFighterAInjury = const Value.absent(),
            Value<String?> resultFighterBInjury = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FightsCompanion.insert(
            id: id,
            eventId: eventId,
            fighterAId: fighterAId,
            fighterBId: fighterBId,
            weightClass: weightClass,
            titleFightType: titleFightType,
            isMainEvent: isMainEvent,
            isCoMainEvent: isCoMainEvent,
            rounds: rounds,
            cardOrder: cardOrder,
            resultWinnerId: resultWinnerId,
            resultMethod: resultMethod,
            resultRound: resultRound,
            winnerPerformanceRating: winnerPerformanceRating,
            loserPerformanceRating: loserPerformanceRating,
            resultFighterAInjury: resultFighterAInjury,
            resultFighterBInjury: resultFighterBInjury,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FightsTable,
    FightRow,
    $$FightsTableFilterComposer,
    $$FightsTableOrderingComposer,
    $$FightsTableAnnotationComposer,
    $$FightsTableCreateCompanionBuilder,
    $$FightsTableUpdateCompanionBuilder,
    (FightRow, BaseReferences<_$AppDatabase, $FightsTable, FightRow>),
    FightRow,
    PrefetchHooks Function()>;
typedef $$RandomEventsTableCreateCompanionBuilder = RandomEventsCompanion
    Function({
  required String id,
  required String type,
  Value<String?> affectedFighterId,
  required String headline,
  required String description,
  required String choicesJson,
  Value<String?> chosenChoiceId,
  required DateTime occurredOn,
  Value<int> rowid,
});
typedef $$RandomEventsTableUpdateCompanionBuilder = RandomEventsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String?> affectedFighterId,
  Value<String> headline,
  Value<String> description,
  Value<String> choicesJson,
  Value<String?> chosenChoiceId,
  Value<DateTime> occurredOn,
  Value<int> rowid,
});

class $$RandomEventsTableFilterComposer
    extends Composer<_$AppDatabase, $RandomEventsTable> {
  $$RandomEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affectedFighterId => $composableBuilder(
      column: $table.affectedFighterId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headline => $composableBuilder(
      column: $table.headline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get choicesJson => $composableBuilder(
      column: $table.choicesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chosenChoiceId => $composableBuilder(
      column: $table.chosenChoiceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => ColumnFilters(column));
}

class $$RandomEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $RandomEventsTable> {
  $$RandomEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affectedFighterId => $composableBuilder(
      column: $table.affectedFighterId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headline => $composableBuilder(
      column: $table.headline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get choicesJson => $composableBuilder(
      column: $table.choicesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chosenChoiceId => $composableBuilder(
      column: $table.chosenChoiceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => ColumnOrderings(column));
}

class $$RandomEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RandomEventsTable> {
  $$RandomEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get affectedFighterId => $composableBuilder(
      column: $table.affectedFighterId, builder: (column) => column);

  GeneratedColumn<String> get headline =>
      $composableBuilder(column: $table.headline, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get choicesJson => $composableBuilder(
      column: $table.choicesJson, builder: (column) => column);

  GeneratedColumn<String> get chosenChoiceId => $composableBuilder(
      column: $table.chosenChoiceId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => column);
}

class $$RandomEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RandomEventsTable,
    RandomEventRow,
    $$RandomEventsTableFilterComposer,
    $$RandomEventsTableOrderingComposer,
    $$RandomEventsTableAnnotationComposer,
    $$RandomEventsTableCreateCompanionBuilder,
    $$RandomEventsTableUpdateCompanionBuilder,
    (
      RandomEventRow,
      BaseReferences<_$AppDatabase, $RandomEventsTable, RandomEventRow>
    ),
    RandomEventRow,
    PrefetchHooks Function()> {
  $$RandomEventsTableTableManager(_$AppDatabase db, $RandomEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RandomEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RandomEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RandomEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> affectedFighterId = const Value.absent(),
            Value<String> headline = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> choicesJson = const Value.absent(),
            Value<String?> chosenChoiceId = const Value.absent(),
            Value<DateTime> occurredOn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RandomEventsCompanion(
            id: id,
            type: type,
            affectedFighterId: affectedFighterId,
            headline: headline,
            description: description,
            choicesJson: choicesJson,
            chosenChoiceId: chosenChoiceId,
            occurredOn: occurredOn,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<String?> affectedFighterId = const Value.absent(),
            required String headline,
            required String description,
            required String choicesJson,
            Value<String?> chosenChoiceId = const Value.absent(),
            required DateTime occurredOn,
            Value<int> rowid = const Value.absent(),
          }) =>
              RandomEventsCompanion.insert(
            id: id,
            type: type,
            affectedFighterId: affectedFighterId,
            headline: headline,
            description: description,
            choicesJson: choicesJson,
            chosenChoiceId: chosenChoiceId,
            occurredOn: occurredOn,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RandomEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RandomEventsTable,
    RandomEventRow,
    $$RandomEventsTableFilterComposer,
    $$RandomEventsTableOrderingComposer,
    $$RandomEventsTableAnnotationComposer,
    $$RandomEventsTableCreateCompanionBuilder,
    $$RandomEventsTableUpdateCompanionBuilder,
    (
      RandomEventRow,
      BaseReferences<_$AppDatabase, $RandomEventsTable, RandomEventRow>
    ),
    RandomEventRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FightersTableTableManager get fighters =>
      $$FightersTableTableManager(_db, _db.fighters);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$FightsTableTableManager get fights =>
      $$FightsTableTableManager(_db, _db.fights);
  $$RandomEventsTableTableManager get randomEvents =>
      $$RandomEventsTableTableManager(_db, _db.randomEvents);
}
