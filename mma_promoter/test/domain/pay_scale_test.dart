import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/finance/pay_scale.dart';

void main() {
  group('PayScale.suggest', () {
    test(r'a bottom-tier prospect (25 overall, no popularity) gets $400/$400',
        () {
      final pay = PayScale.suggest(overall: 25, popularity: 0);
      expect(pay.showMoney, 400);
      expect(pay.winBonus, 400);
      expect(pay.total, 800);
    });

    test('pay rises monotonically with overall at fixed popularity', () {
      final bands = [25.0, 40.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 99.0];
      var last = 0;
      for (final ovr in bands) {
        final pay = PayScale.suggest(overall: ovr, popularity: 20);
        expect(pay.total, greaterThanOrEqualTo(last));
        last = pay.total;
      }
    });

    test('a regional-level fighter is affordable at zero popularity', () {
      // The band a promotion starting out actually shops in.
      final low = PayScale.suggest(overall: 56, popularity: 0);
      final high = PayScale.suggest(overall: 65, popularity: 0);
      expect(low.total, inInclusiveRange(1400, 2000));
      expect(high.total, inInclusiveRange(2800, 3600));
    });

    test(r'75-85 overall climbs from five figures into six', () {
      final low = PayScale.suggest(overall: 75, popularity: 0);
      final high = PayScale.suggest(overall: 85, popularity: 0);
      expect(low.total, inInclusiveRange(8000, 11000));
      expect(high.total, inInclusiveRange(90000, 110000));
    });

    test('no single point of overall is a cliff', () {
      // The old table jumped 55 -> 56 by double and 75 -> 76 by more than
      // four times, so one point of overall cost more than the ten before
      // it — and a card of 60s lost money that a card of 55s made.
      for (var ovr = 26; ovr <= 99; ovr++) {
        final before =
            PayScale.suggest(overall: ovr - 1.0, popularity: 0).total;
        final after = PayScale.suggest(overall: ovr.toDouble(), popularity: 0);
        if (before == 0) continue;
        expect(after.total / before, lessThan(1.35),
            reason: 'pay jumps too hard approaching $ovr overall');
      }
    });

    test(r'85+ overall clears $100k even before popularity', () {
      final pay = PayScale.suggest(overall: 86, popularity: 0);
      expect(pay.total, greaterThanOrEqualTo(100000));
    });

    test('popularity scales pay up for the same overall', () {
      final unknown = PayScale.suggest(overall: 70, popularity: 0);
      final star = PayScale.suggest(overall: 70, popularity: 100);
      expect(star.total, greaterThan(unknown.total));
      // Max popularity is worth up to +67% over the same fighter with none.
      expect(star.total / unknown.total, closeTo(1.667, 0.05));
    });

    test('show money and win bonus roughly split the total in half', () {
      final pay = PayScale.suggest(overall: 80, popularity: 50);
      expect(pay.showMoney, closeTo(pay.winBonus, pay.total * 0.05));
    });
  });
}
