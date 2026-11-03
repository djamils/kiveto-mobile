import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

void main() {
  group('LocalDate', () {
    test('parses and writes YYYY-MM-DD', () {
      final date = LocalDate.parse('2026-11-04');

      expect((date.year, date.month, date.day), (2026, 11, 4));
      expect(date.weekday, DateTime.wednesday);
      expect(date.toIso8601String(), '2026-11-04');
      expect('$date', '2026-11-04');
      expect(LocalDate(7, 1, 2).toIso8601String(), '0007-01-02');
    });

    test('refuses an invalid date', () {
      expect(() => LocalDate(2026, 2, 30), throwsArgumentError);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
      expect(() => LocalDate(0, 1, 1), throwsArgumentError);
      expect(() => LocalDate(10000, 1, 1), throwsArgumentError);
      expect(LocalDate(2028, 2, 29).day, 29);
    });

    test('parse refuses another shape or an invalid date', () {
      expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
      expect(() => LocalDate.parse('2026-2-3'), throwsFormatException);
      expect(() => LocalDate.parse('04/11/2026'), throwsFormatException);
      expect(() => LocalDate.parse('2026-11-04T00:00'), throwsFormatException);
    });

    test('counts and adds days across months and years', () {
      final date = LocalDate(2026, 12, 30);

      expect(date.addDays(3), LocalDate(2027, 1, 2));
      expect(date.addDays(-30), LocalDate(2026, 11, 30));
      expect(date.daysUntil(LocalDate(2027, 1, 2)), 3);
      expect(LocalDate(2027, 1, 2).daysUntil(date), -3);
      expect(LocalDate(2026, 3, 28).daysUntil(LocalDate(2026, 3, 30)), 2);
    });

    test('compares and equals by calendar date', () {
      final a = LocalDate(2026, 11, 4);
      final b = LocalDate(2026, 11, 5);

      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.isAfter(b), isFalse);
      expect(a.compareTo(b), lessThan(0));
      expect(a.compareTo(LocalDate(2026, 11, 4)), 0);
      expect(a, LocalDate(2026, 11, 4));
      expect(a.hashCode, LocalDate(2026, 11, 4).hashCode);
      expect(a == Object(), isFalse);
      expect([b, a]..sort(), [a, b]);
    });
  });
}
