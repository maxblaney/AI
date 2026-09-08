import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/simulation/fight_excitement.dart';

FightResult _result({
  FightMethod method = FightMethod.decision,
  int round = 3,
  int timeSeconds = 300,
  int winnerRating = 60,
  int loserRating = 50,
  int strikesA = 40,
  int strikesB = 35,
  int knockdownsA = 0,
  int knockdownsB = 0,
  int controlA = 0,
  int controlB = 0,
}) {
  return FightResult(
    winnerId: method == FightMethod.drawOrNc ? '' : 'a',
    method: method,
    round: round,
    timeSeconds: timeSeconds,
    winnerPerformanceRating: winnerRating,
    loserPerformanceRating: loserRating,
    statsA: FightStatline(
      significantStrikesLanded: strikesA,
      knockdowns: knockdownsA,
      controlSeconds: controlA,
    ),
    statsB: FightStatline(
      significantStrikesLanded: strikesB,
      knockdowns: knockdownsB,
      controlSeconds: controlB,
    ),
  );
}

int _rate(FightResult result, {int rounds = 3}) =>
    FightExcitement.rate(result: result, scheduledRounds: rounds).rating;

void main() {
  group('rating', () {
    test('always lands inside one to ten', () {
      final worst = _rate(_result(
        method: FightMethod.drawOrNc,
        winnerRating: 0,
        loserRating: 0,
        strikesA: 0,
        strikesB: 0,
        controlA: 800,
        controlB: 0,
      ));
      final best = _rate(_result(
        method: FightMethod.koTko,
        round: 3,
        winnerRating: 100,
        loserRating: 100,
        strikesA: 120,
        strikesB: 120,
        knockdownsA: 2,
        knockdownsB: 2,
      ));

      expect(worst, 1);
      expect(best, 10);
    });

    test('a war beats a walkover between the same two men', () {
      final war = _rate(_result(winnerRating: 85, loserRating: 82,
          strikesA: 110, strikesB: 105));
      final walkover = _rate(_result(winnerRating: 85, loserRating: 20,
          strikesA: 60, strikesB: 6));

      expect(war, greaterThan(walkover));
    });

    test('getting dropped is worth more than landing more', () {
      final clean = _rate(_result(strikesA: 60, strikesB: 40));
      final dropped = _rate(_result(strikesA: 60, strikesB: 40,
          knockdownsA: 1));

      expect(dropped, greaterThan(clean));
    });

    test('a finish beats the same fight going to the cards', () {
      const shared = (winnerRating: 70, loserRating: 60);
      final decision = _rate(_result(
          winnerRating: shared.winnerRating, loserRating: shared.loserRating));
      final ko = _rate(_result(
        method: FightMethod.koTko,
        round: 3,
        winnerRating: shared.winnerRating,
        loserRating: shared.loserRating,
      ));
      final submission = _rate(_result(
        method: FightMethod.submission,
        round: 3,
        winnerRating: shared.winnerRating,
        loserRating: shared.loserRating,
      ));

      expect(ko, greaterThan(decision));
      expect(submission, greaterThan(decision));
    });

    test('holding someone down for the whole fight costs it', () {
      final scrap = _rate(_result(controlA: 0));
      // Thirteen of fifteen minutes on top.
      final grind = _rate(_result(controlA: 780));

      expect(grind, lessThan(scrap));
    });

    test('control that produced the tap is not held against it', () {
      final grindToDecision = _rate(_result(controlA: 780));
      final grindToTap = _rate(_result(
        method: FightMethod.submission,
        round: 3,
        controlA: 780,
      ));

      expect(grindToTap, greaterThan(grindToDecision));
    });

    test('a doctor stoppage is an anticlimax', () {
      final decision = _rate(_result());
      final doctor = _rate(_result(method: FightMethod.doctorStoppage));

      expect(doctor, lessThan(decision));
    });
  });

  group('labels', () {
    test('every rating has a band, and they run in order', () {
      final seen = <String>[];
      for (var i = 1; i <= 10; i++) {
        // Reach each rating through a fight rather than by construction,
        // since the constructor is private on purpose.
        final label = FightExcitement.rate(
          result: _result(
            winnerRating: (i * 11).clamp(0, 100),
            loserRating: (i * 10).clamp(0, 100),
            strikesA: i * 12,
            strikesB: i * 10,
          ),
          scheduledRounds: 3,
        ).label;
        if (seen.isEmpty || seen.last != label) seen.add(label);
      }

      expect(seen.first, 'Forgettable');
      expect(seen.last, 'Instant Classic');
      expect(seen, ['Forgettable', 'Flat', 'Good Scrap', 'Barnburner',
        'Instant Classic']);
    });
  });

  group('popularityDelta', () {
    test('an average fight pays the winner and costs the loser a little', () {
      expect(FightExcitement.popularityDelta(rating: 5, won: true), 2);
      expect(FightExcitement.popularityDelta(rating: 5, won: false), -1);
    });

    test('losing a classic still gains fans', () {
      expect(
        FightExcitement.popularityDelta(rating: 10, won: false),
        greaterThan(0),
      );
    });

    test('winning a stinker loses them', () {
      expect(
        FightExcitement.popularityDelta(rating: 1, won: true),
        lessThan(0),
      );
    });

    test('the winner always does better out of it than the loser', () {
      for (var rating = 1; rating <= 10; rating++) {
        expect(
          FightExcitement.popularityDelta(rating: rating, won: true),
          greaterThan(
              FightExcitement.popularityDelta(rating: rating, won: false)),
          reason: 'at rating $rating',
        );
      }
    });

    test('a draw sits between the two', () {
      for (var rating = 1; rating <= 10; rating++) {
        final drawn =
            FightExcitement.popularityDelta(rating: rating, won: false, draw: true);
        expect(drawn,
            lessThan(FightExcitement.popularityDelta(rating: rating, won: true)));
        expect(
            drawn,
            greaterThan(FightExcitement.popularityDelta(
                rating: rating, won: false)));
      }
    });
  });
}
