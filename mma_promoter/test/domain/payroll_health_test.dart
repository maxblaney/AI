import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/data/models/models.dart';
import 'package:mma_promoter/domain/finance/event_finance_calculator.dart';
import 'package:mma_promoter/domain/finance/payroll_health.dart';

MmaEvent _show({
  required String id,
  required int revenue,
  required int purses,
  required DateTime date,
  bool completed = true,
  bool withBreakdown = true,
}) =>
    MmaEvent(
      id: id,
      name: id,
      date: date,
      venue: Venue.regionalUsa,
      ticketPrice: 50,
      status: completed ? EventStatus.completed : EventStatus.scheduled,
      revenue: revenue,
      bookedAtWeek: 1,
      financeBreakdown: withBreakdown
          ? EventFinanceBreakdown(
              fromFanbase: 0,
              fromMainEvent: 0,
              fromCard: 0,
              fromPromotion: 0,
              fromWalkUp: 0,
              depthMultiplier: 1,
              priceMultiplier: 1,
              luckMultiplier: 1,
              uncappedAttendance: 0,
              soldOut: false,
              venueOvershoot: 0,
              ticketRevenue: revenue,
              ppvRevenue: 0,
              venueCost: 1500,
              purses: purses,
              promotionSpend: 0,
            )
          : null,
    );

void main() {
  group('PayrollHealth', () {
    test('a promotion that has run nothing has no ratio to report', () {
      expect(PayrollHealth.fromRecentEvents(const []), isNull);
    });

    test('reads pay as a share of what the shows took', () {
      final health = PayrollHealth.fromRecentEvents([
        _show(id: 'a', revenue: 100000, purses: 40000, date: DateTime(2026, 1)),
        _show(id: 'b', revenue: 100000, purses: 40000, date: DateTime(2026, 2)),
      ])!;

      expect(health.sharePercent, 40);
      expect(health.pressure, PayrollPressure.comfortable);
      expect(health.revenuePerShow, 100000);
      expect(health.shows, 2);
    });

    test('paying out more than you take is called what it is', () {
      // The measured crisis year: purses ran to 145% of takings and
      // nothing in the game said a word about it.
      final health = PayrollHealth.fromRecentEvents([
        _show(id: 'a', revenue: 100000, purses: 145000, date: DateTime(2026)),
      ])!;

      expect(health.sharePercent, 145);
      expect(health.pressure, PayrollPressure.overcommitted);
      expect(health.pressure.needsAttention, isTrue);
    });

    test('the band between the two is flagged but not alarming', () {
      final health = PayrollHealth.fromRecentEvents([
        _show(id: 'a', revenue: 100000, purses: 70000, date: DateTime(2026)),
      ])!;

      expect(health.pressure, PayrollPressure.tight);
      expect(health.pressure.needsAttention, isTrue);
    });

    test('it reads recent shows, not the whole history', () {
      // Six cheap early cards should not hide a roster that has since
      // priced itself out.
      final shows = [
        for (var i = 0; i < 10; i++)
          _show(
            id: 'old$i',
            revenue: 100000,
            purses: 20000,
            date: DateTime(2026, 1, i + 1),
          ),
        for (var i = 0; i < 6; i++)
          _show(
            id: 'new$i',
            revenue: 100000,
            purses: 120000,
            date: DateTime(2027, 1, i + 1),
          ),
      ];

      final health = PayrollHealth.fromRecentEvents(shows, sample: 6)!;
      expect(health.sharePercent, 120);
      expect(health.pressure, PayrollPressure.overcommitted);
    });

    test('shows that have not run yet are not takings', () {
      final health = PayrollHealth.fromRecentEvents([
        _show(id: 'ran', revenue: 100000, purses: 30000, date: DateTime(2026)),
        _show(
          id: 'booked',
          revenue: 0,
          purses: 0,
          date: DateTime(2027),
          completed: false,
        ),
      ])!;

      expect(health.shows, 1);
      expect(health.sharePercent, 30);
    });

    test('one contract can be weighed against one night', () {
      final health = PayrollHealth.fromRecentEvents([
        _show(id: 'a', revenue: 200000, purses: 60000, date: DateTime(2026)),
      ])!;

      // Pay is geometric in skill, so a single fighter really can be a
      // fifth of the night on their own — which is the thing you cannot
      // see reading profiles one at a time.
      expect(health.shareOfOneShow(40000), closeTo(0.2, 0.001));
      expect(health.shareOfOneShow(2000), closeTo(0.01, 0.001));
    });
  });
}
