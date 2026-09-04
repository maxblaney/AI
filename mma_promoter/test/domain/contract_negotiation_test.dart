import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/finance/contract_negotiation.dart';
import 'package:mma_promoter/domain/finance/pay_scale.dart';

OfferResponse offer(double ovr, int pop, int perFight) =>
    ContractNegotiation.consider(
      overall: ovr,
      popularity: pop,
      showMoney: perFight ~/ 2,
      winBonus: perFight - perFight ~/ 2,
    );

void main() {
  group('ContractNegotiation', () {
    test('a great fighter will not sign for a thousand dollars', () {
      // The report this exists for: a 93-overall signed on 1,000/1,000,
      // a man worth six figures a night taking a hundredth of it.
      final response = offer(93, 50, 2000);

      expect(response.accepted, isFalse);
      expect(response.wouldAccept, greaterThan(100000));
      expect(response.marketRate, greaterThan(300000));
    });

    test('the market rate is always enough', () {
      for (final ovr in [50.0, 65.0, 75.0, 85.0, 95.0, 99.0]) {
        for (final pop in [0, 50, 100]) {
          final market = PayScale.suggest(overall: ovr, popularity: pop);
          final response = offer(ovr, pop, market.total);
          expect(response.accepted, isTrue,
              reason: 'OVR $ovr pop $pop should take the going rate');
        }
      }
    });

    test('there is real room to haggle below it', () {
      // Negotiating a discount is part of the job and has to still work,
      // or the market rate is just a price tag.
      final market = PayScale.suggest(overall: 70, popularity: 30);
      final response = offer(70, 30, (market.total * 0.8).round());
      expect(response.accepted, isTrue);
      expect(response.share, lessThan(1.0));
    });

    test('the better they are, the less they will discount', () {
      final journeyman =
          ContractNegotiation.floorFor(overall: 60, popularity: 10);
      final contender =
          ContractNegotiation.floorFor(overall: 85, popularity: 50);
      final star = ContractNegotiation.floorFor(overall: 95, popularity: 90);

      expect(journeyman, lessThan(contender));
      expect(contender, lessThan(star));
      expect(star, lessThanOrEqualTo(1.0),
          reason: 'nobody should demand more than they are worth');
      expect(journeyman, greaterThanOrEqualTo(ContractNegotiation.baseFloor));
    });

    test('fame is leverage on its own', () {
      final unknown = ContractNegotiation.floorFor(overall: 75, popularity: 5);
      final famous = ContractNegotiation.floorFor(overall: 75, popularity: 95);
      expect(famous, greaterThan(unknown));
    });

    test('the answer does not change if you ask twice', () {
      // Deterministic on purpose: a player who finds the number that
      // works should be able to trust it, not re-roll the same offer.
      final a = offer(88, 60, 40000);
      final b = offer(88, 60, 40000);
      expect(a.accepted, b.accepted);
      expect(a.wouldAccept, b.wouldAccept);
    });

    test('what it asks for is exactly what it accepts', () {
      final refused = offer(90, 40, 1000);
      expect(refused.accepted, isFalse);
      final atTheirNumber = offer(90, 40, refused.wouldAccept!);
      expect(atTheirNumber.accepted, isTrue,
          reason: 'the number they name has to be a number they take');
    });
  });
}
