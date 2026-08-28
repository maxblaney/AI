import 'package:flutter_test/flutter_test.dart';
import 'package:mma_promoter/domain/calendar/game_calendar.dart';

void main() {
  group('GameCalendar', () {
    test('week 1 is Year 1, Week 1', () {
      expect(GameCalendar.yearOf(1), 1);
      expect(GameCalendar.weekOfYear(1), 1);
    });

    test('week 52 is still Year 1', () {
      expect(GameCalendar.yearOf(52), 1);
      expect(GameCalendar.weekOfYear(52), 52);
    });

    test('week 53 rolls over into Year 2, Week 1', () {
      expect(GameCalendar.yearOf(53), 2);
      expect(GameCalendar.weekOfYear(53), 1);
    });

    test('week 104 is the last week of Year 2', () {
      expect(GameCalendar.yearOf(104), 2);
      expect(GameCalendar.weekOfYear(104), 52);
    });

    test('dateForWeek and weekNumberFor are inverses', () {
      for (final week in [1, 2, 10, 52, 53, 104, 200]) {
        final date = GameCalendar.dateForWeek(week);
        expect(GameCalendar.weekNumberFor(date), week);
      }
    });

    test('dateForWeek advances by exactly 7 days per week', () {
      final week1 = GameCalendar.dateForWeek(1);
      final week2 = GameCalendar.dateForWeek(2);
      expect(week2.difference(week1).inDays, 7);
    });

    test('label formats as "Year N, Week M"', () {
      expect(GameCalendar.label(1), 'Year 1, Week 1');
      expect(GameCalendar.label(53), 'Year 2, Week 1');
    });
  });
}
