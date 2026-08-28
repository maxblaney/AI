import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/finance/pay_scale.dart';

void main() {
  group('PayScale.suggest', () {
    test(r'a bottom-tier prospect (25 overall, no popularity) gets $500/$500', () {
      final pay = PayScale.suggest(overall: 25, popularity: 0);
      expect(pay.showMoney, 500);
      expect(pay.winBonus, 500);
      expect(pay.total, 1000);
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

    test(r'56-65 overall lands in the $2,500-$5,000 band at zero popularity', () {
      final low = PayScale.suggest(overall: 56, popularity: 0);
      final high = PayScale.suggest(overall: 65, popularity: 0);
      expect(low.total, inInclusiveRange(2000, 3000));
      expect(high.total, inInclusiveRange(4500, 5500));
    });

    test(r'75-85 overall lands roughly in the $50k-$100k band at zero popularity', () {
      final low = PayScale.suggest(overall: 76, popularity: 0);
      final high = PayScale.suggest(overall: 85, popularity: 0);
      expect(low.total, inInclusiveRange(40000, 60000));
      expect(high.total, inInclusiveRange(90000, 110000));
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
