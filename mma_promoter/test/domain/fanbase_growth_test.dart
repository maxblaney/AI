import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/growth/fanbase_growth.dart';

int _greatNight({required int fanbase, int capacity = 25000}) =>
    FanbaseGrowth.forEvent(
      fanbaseSize: fanbase,
      attendance: capacity,
      venueCapacity: capacity,
      ppvBuys: 20000,
      mainEventPopularity: 85,
      averageExcitement: 8,
    );

void main() {
  group('FanbaseGrowth', () {
    test('a good night compounds instead of paying a flat rate', () {
      // The old model added attendance/10 and nothing else, so a
      // promotion with a million followers got exactly as much out of a
      // great night as one with a thousand. Success has to compound or
      // the top of the game is unreachable.
      final small = _greatNight(fanbase: 10000);
      final big = _greatNight(fanbase: 1000000);
      expect(big, greaterThan(small * 5));

      // Past the point where the proportional term dominates, twice the
      // following is worth close to twice the night — that is what
      // compounding means, and what a flat term can never do.
      final oneMillion = _greatNight(fanbase: 1000000);
      final twoMillion = _greatNight(fanbase: 2000000);
      expect(twoMillion / oneMillion, closeTo(2, 0.2));
    });

    test('a tiny promotion still gets off the ground', () {
      // 3% of 800 is 24 people, which is no way to start a career — the
      // direct term is what carries a promotion nobody has heard of.
      final growth = FanbaseGrowth.forEvent(
        fanbaseSize: 800,
        attendance: 900,
        venueCapacity: 3500,
        ppvBuys: 0,
        mainEventPopularity: 30,
        averageExcitement: 6,
      );

      expect(growth, greaterThan(80));
    });

    test('the pay-per-view audience counts', () {
      int withBuys(int buys) => FanbaseGrowth.forEvent(
            fanbaseSize: 500000,
            attendance: 15000,
            venueCapacity: 20000,
            ppvBuys: buys,
            mainEventPopularity: 70,
            averageExcitement: 7,
          );

      // Broadcast is what actually makes a promotion national, and it
      // used to contribute nothing at all.
      expect(withBuys(200000), greaterThan(withBuys(0)));
    });

    test('a bad night costs you followers', () {
      final growth = FanbaseGrowth.forEvent(
        fanbaseSize: 1000000,
        attendance: 2000,
        venueCapacity: 25000,
        ppvBuys: 0,
        mainEventPopularity: 5,
        averageExcitement: 1,
      );

      // Quality is only a real lever if it can move the number the wrong
      // way. An empty house watching forgettable fights should shrink a
      // following, not merely fail to grow it.
      expect(growth, lessThan(0));
    });

    test('the top of the game is reachable in a career', () {
      // The measured failure: at attendance/10 a sold-out 25,000-seat
      // arena added 2,500 fans, so 800,000 to the 20 million that
      // supports arena ticket prices took over six hundred years.
      var fanbase = 800000;
      var years = 0;
      while (fanbase < 20000000 && years < 40) {
        for (var show = 0; show < 12; show++) {
          fanbase += FanbaseGrowth.forEvent(
            fanbaseSize: fanbase,
            attendance: 24000,
            venueCapacity: 25000,
            ppvBuys: 30000,
            mainEventPopularity: 75,
            averageExcitement: 7,
          );
        }
        years++;
      }

      expect(fanbase, greaterThanOrEqualTo(20000000));
      expect(years, lessThan(20),
          reason: 'a career, not a geological age');
      expect(years, greaterThan(4),
          reason: 'and still a climb worth making, not a formality');
    });

    test('quality reads the three things a promoter is judged on', () {
      double q({
        int attendance = 20000,
        double star = 80,
        double fights = 8,
      }) =>
          FanbaseGrowth.showQuality(
            attendance: attendance,
            venueCapacity: 25000,
            mainEventPopularity: star,
            averageExcitement: fights,
          );

      final baseline = q();
      expect(q(attendance: 4000), lessThan(baseline));
      expect(q(star: 10), lessThan(baseline));
      expect(q(fights: 2), lessThan(baseline));
      // Fights carry the most weight: it is a fight promotion.
      expect(baseline - q(fights: 2), greaterThan(baseline - q(star: 10)));
      expect(q(), inInclusiveRange(0, 1));
    });
  });
}
