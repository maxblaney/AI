import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/data/seed/roster_seed.dart';
import 'package:mma_promoter/domain/packs/fighter_codec.dart';
import 'package:mma_promoter/domain/packs/fighter_pack.dart';

import '../support/fighter_fixtures.dart';

/// Every value the codec is supposed to carry, pulled off a fighter so
/// two of them can be compared field by field.
///
/// Written out longhand on purpose. The stat classes have no equality
/// and no `toString`, so comparing them as objects would compare
/// identity and pass no matter what the codec dropped — which is the
/// exact bug this test exists to catch.
Map<String, Object?> _carried(Fighter f) {
  final fi = f.fightingStats;
  final ph = f.physicalStats;
  final me = f.mentalStats;
  final te = f.tendencies;
  return {
    'name': f.name,
    'age': f.age,
    'nationality': f.nationality,
    'headshotAsset': f.headshotAsset,
    'weightClass': f.weightClass,
    'heightInches': f.heightInches,
    'weightLbs': f.weightLbs,
    'reachInches': f.reachInches,
    'wins': f.record.wins,
    'losses': f.record.losses,
    'draws': f.record.draws,
    'style': f.style,
    'potential': f.potential,
    'popularity': f.popularity,
    'morale': f.morale,
    'winStreak': f.winStreak,
    'lossStreak': f.lossStreak,
    // Fighting (23)
    'punching': fi.punching, 'kicking': fi.kicking, 'power': fi.power,
    'speed': fi.speed, 'accuracy': fi.accuracy, 'defense': fi.defense,
    'headMovement': fi.headMovement, 'blocking': fi.blocking,
    'footwork': fi.footwork, 'takedowns': fi.takedowns,
    'takedownDefense': fi.takedownDefense, 'wrestling': fi.wrestling,
    'clinchStriking': fi.clinchStriking, 'clinchControl': fi.clinchControl,
    'clinchDefense': fi.clinchDefense, 'topControl': fi.topControl,
    'fightingGroundAndPound': fi.groundAndPound,
    'guardRetention': fi.guardRetention, 'sweeps': fi.sweeps,
    'scrambling': fi.scrambling, 'submissionOffense': fi.submissionOffense,
    'submissionDefense': fi.submissionDefense, 'grappling': fi.grappling,
    // Physical (11)
    'cardio': ph.cardio, 'durability': ph.durability, 'chin': ph.chin,
    'bodyToughness': ph.bodyToughness, 'legToughness': ph.legToughness,
    'strength': ph.strength, 'athleticism': ph.athleticism,
    'recovery': ph.recovery, 'explosiveness': ph.explosiveness,
    'flexibility': ph.flexibility, 'gripStrength': ph.gripStrength,
    // Mental (8)
    'fightIq': me.fightIq, 'composure': me.composure,
    'mentalAggression': me.aggression, 'discipline': me.discipline,
    'confidence': me.confidence, 'heart': me.heart,
    'adaptability': me.adaptability, 'killerInstinct': me.killerInstinct,
    // Tendencies (14)
    'tendStriking': te.strikingFrequency,
    'tendTakedown': te.takedownFrequency,
    'tendKick': te.kickFrequency, 'tendClinch': te.clinchFrequency,
    'tendSubmission': te.submissionAttempts,
    'tendGroundAndPound': te.groundAndPound,
    'tendPositionControl': te.positionControl,
    'tendStandUp': te.standUpPreference, 'tendWallWork': te.wallWork,
    'tendAggression': te.aggression,
    'tendCounterStriking': te.counterStriking,
    'tendHeadHunting': te.headHunting, 'tendBodyAttacks': te.bodyAttacks,
    'tendLegAttacks': te.legAttacks,
  };
}

int _idCounter = 0;
String _nextId() => 'id-${_idCounter++}';

void main() {
  setUp(() => _idCounter = 0);

  group('FighterCodec', () {
    test('a generated roster survives the round trip intact', () {
      final roster = generateStartingRoster(random: Random(31)).take(60);

      for (final original in roster) {
        final restored = FighterCodec.fromJson(
          jsonDecode(jsonEncode(FighterCodec.toJson(original)))
              as Map<String, dynamic>,
          id: original.id,
        );

        expect(_carried(restored), _carried(original),
            reason: 'lost something on ${original.name}');
        // The whole point of carrying every stat is that the fighter is
        // the same fighter on the other side.
        expect(restored.overall, closeTo(original.overall, 0.001));
      }
    });

    test('the stat payload holds one byte for every stat', () {
      // The round trip proves the values are right; this proves the
      // payload is the length the reader assumes, so nothing is being
      // quietly dropped off the end.
      final json = FighterCodec.toJson(testFighter('a', stat: 61));

      expect(FighterCodec.statOrder, hasLength(23 + 11 + 8 + 14),
          reason: '23 fighting, 11 physical, 8 mental, 14 tendencies');
      expect(FighterCodec.statOrder.toSet(), hasLength(56),
          reason: 'a duplicated name would make two stats share a slot');

      final packed = base64Decode(json[FighterCodec.statsKey] as String);
      expect(packed, hasLength(FighterCodec.statOrder.length));
    });

    test('a pack missing the tail of its stats defaults only those', () {
      // What a pack made before a stat existed looks like: the payload
      // stops short.
      final full = FighterCodec.toJson(testFighter('a', stat: 61));
      final packed = base64Decode(full[FighterCodec.statsKey] as String);
      final truncated = {
        ...full,
        FighterCodec.statsKey: base64Encode(packed.sublist(0, 23)),
      };

      final restored = FighterCodec.fromJson(truncated, id: 'x');

      // The 23 fighting stats came through; everything after defaults.
      expect(restored.fightingStats.punching, 61);
      expect(restored.fightingStats.grappling, 61);
      expect(restored.physicalStats.cardio, 50);
      expect(restored.tendencies.aggression, 50);
    });

    test('a mangled stat payload loses the stats, not the fighter', () {
      final restored = FighterCodec.fromJson(
        const {'n': 'Half Pasted', FighterCodec.statsKey: 'not base64!!!'},
        id: 'x',
      );

      expect(restored.name, 'Half Pasted');
      expect(restored.fightingStats.punching, 50);
    });

    test('a pack from an older build imports with sane defaults', () {
      // Everything the format knows about, gone except a name.
      final restored =
          FighterCodec.fromJson(const {'n': 'Old Timer'}, id: 'x');

      expect(restored.name, 'Old Timer');
      expect(restored.weightClass, WeightClass.lightweight);
      expect(restored.fightingStats.punching, 50);
      expect(restored.physicalStats.cardio, 50);
      expect(restored.mentalStats.heart, 50);
      expect(restored.tendencies.aggression, 50);
      expect(restored.record.wins, 0);
    });

    test('junk values fall back instead of throwing', () {
      final restored = FighterCodec.fromJson(const {
        'n': '   ',
        'ag': 'not a number',
        'wc': 'nonexistentDivision',
        'sty': 'nonexistentStyle',
        'ht': -40,
      }, id: 'x');

      expect(restored.name, 'Unnamed Fighter');
      expect(restored.age, 27);
      expect(restored.weightClass, WeightClass.lightweight);
      expect(restored.style, FightingStyle.wellRounded);
      expect(restored.fightingStats.punching, 50,
          reason: 'no stat payload at all, so every stat defaults');
      expect(restored.heightInches, 48, reason: 'clamped to the floor');
    });

    test('career state is deliberately left behind', () {
      final champion = testFighter('champ').copyWith(
        belts: {WeightClass.lightweight},
        eloRating: 2100,
        isRanked: true,
        injuryStatus: InjuryStatus.major,
        suspendedUntilWeek: 900,
        contract: Contract(
          id: 'c',
          fighterId: 'champ',
          fightsRemaining: 3,
          showMoney: 5000,
          winBonus: 5000,
          exclusive: true,
          signedOn: DateTime(2026),
        ),
      );

      final restored = FighterCodec.fromJson(
          FighterCodec.toJson(champion), id: 'new');

      // Importing somebody else's roster should not hand you their
      // champion, their injuries or their contracts.
      expect(restored.belts, isEmpty);
      expect(restored.eloRating, 1500);
      expect(restored.isRanked, isFalse);
      expect(restored.injuryStatus, InjuryStatus.healthy);
      expect(restored.suspendedUntilWeek, isNull);
      expect(restored.contract, isNull);
    });
  });

  group('FighterPackCodec', () {
    FighterPack samplePack() => FighterPack(
          id: 'p1',
          name: 'Lightweight Legends',
          description: 'The good ones.',
          author: 'Max',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
          fighters: [
            testFighter('a', stat: 80).copyWith(name: 'Fighter A'),
            testFighter('b', stat: 70).copyWith(name: 'Fighter B'),
          ],
        );

    test('a pack survives being encoded and pasted back', () {
      final decoded =
          FighterPackCodec.decode(FighterPackCodec.encode(samplePack()),
              idFor: _nextId);

      expect(decoded.name, 'Lightweight Legends');
      expect(decoded.description, 'The good ones.');
      expect(decoded.author, 'Max');
      expect(decoded.createdAt.millisecondsSinceEpoch, 1700000000000);
      expect(decoded.fighters.map((f) => f.name), ['Fighter A', 'Fighter B']);
    });

    test('every fighter gets a fresh id on the way in', () {
      final code = FighterPackCodec.encode(samplePack());
      final first = FighterPackCodec.decode(code, idFor: _nextId);
      final second = FighterPackCodec.decode(code, idFor: _nextId);

      final ids = [
        ...first.fighters.map((f) => f.id),
        ...second.fighters.map((f) => f.id),
      ];
      // Importing the same pack twice must not have the second import
      // overwrite the first.
      expect(ids.toSet(), hasLength(ids.length));
      expect(first.id, isNot(second.id));
    });

    test('the summary counts fighters and divisions', () {
      expect(samplePack().summary, '2 fighters · 1 division');
    });

    group('bad input says what is wrong', () {
      void expectsMessage(String code, Matcher message) {
        expect(
          () => FighterPackCodec.decode(code, idFor: _nextId),
          throwsA(isA<FighterPackFormatException>()
              .having((e) => e.message, 'message', message)),
        );
      }

      test('empty', () => expectsMessage('   ', contains('Nothing pasted')));

      test('not json', () =>
          expectsMessage('hello there', contains("doesn't look like")));

      test('json but not a pack', () => expectsMessage(
          '{"hello":"there"}', contains('not a fighter pack')));

      test('no fighters', () => expectsMessage(
          jsonEncode({'magic': FighterPackCodec.magic, 'v': 1, 'f': []}),
          contains('no fighters')));

      test('from a newer build', () => expectsMessage(
          jsonEncode({
            'magic': FighterPackCodec.magic,
            'v': FighterPackCodec.formatVersion + 1,
            'f': [<String, dynamic>{}],
          }),
          contains('newer version')));

      test('absurdly large', () => expectsMessage(
          jsonEncode({
            'magic': FighterPackCodec.magic,
            'v': 1,
            'f': [
              for (var i = 0; i < FighterPackCodec.maxFighters + 1; i++)
                <String, dynamic>{'n': 'F$i'},
            ],
          }),
          contains('more than the')));
    });

    test('a code stays a size a person can actually send', () {
      final roster = generateStartingRoster(random: Random(7)).take(20).toList();
      final code = FighterPackCodec.encode(FighterPack(
        id: 'p',
        name: 'Twenty',
        createdAt: DateTime(2026),
        fighters: roster,
      ));

      // A canary, not a requirement. Twenty fighters encode to about
      // 5,500 characters — roughly 275 each, most of which is the 76-char
      // stat payload. If this trips, the format got fat (a stat block
      // back in keyed JSON, say) rather than the test being wrong.
      expect(code.length, lessThan(8000),
          reason: '20 fighters encoded to ${code.length} characters');
    });
  });
}
