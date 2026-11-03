import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

void main() {
  group('ClinicInstant.parse', () {
    test('keeps the clinic offset and its wall clock', () {
      final instant = ClinicInstant.parse('2026-11-04T10:30:00+01:00');

      expect(instant.offset, const Duration(hours: 1));
      expect(instant.instant, DateTime.utc(2026, 11, 4, 9, 30));
      expect(instant.instant.isUtc, isTrue);
      expect(
        (
          instant.year,
          instant.month,
          instant.day,
          instant.hour,
          instant.minute,
          instant.second,
        ),
        (2026, 11, 4, 10, 30, 0),
      );
      expect(instant.weekday, DateTime.wednesday);
      expect(instant.date, LocalDate(2026, 11, 4));
      expect(instant.toIso8601String(), '2026-11-04T10:30:00+01:00');
      expect('$instant', '2026-11-04T10:30:00+01:00');
    });

    test('Z is a zero offset, written +00:00', () {
      final instant = ClinicInstant.parse('2026-11-04T09:30:00Z');

      expect(instant.offset, Duration.zero);
      expect(instant.hour, 9);
      expect(instant.toIso8601String(), '2026-11-04T09:30:00+00:00');
    });

    test('negative offsets, minutes without seconds, fractions', () {
      final west = ClinicInstant.parse('2026-11-03T23:15-03:30');
      expect(west.offset, const Duration(hours: -3, minutes: -30));
      expect(west.instant, DateTime.utc(2026, 11, 4, 2, 45));
      expect(west.date, LocalDate(2026, 11, 3));
      expect(west.toIso8601String(), '2026-11-03T23:15:00-03:30');

      final precise = ClinicInstant.parse('2026-11-04T10:30:05.123456+01:00');
      expect(precise.instant.microsecond, 456);
      expect(precise.instant.millisecond, 123);
      expect(precise.toIso8601String(), '2026-11-04T10:30:05+01:00');
    });

    test('the clinic date can differ from the UTC date', () {
      final instant = ClinicInstant.parse('2026-11-05T00:30:00+11:00');

      expect(instant.instant.day, 4);
      expect(instant.date, LocalDate(2026, 11, 5));
    });

    for (final text in [
      '2026-11-04T10:30:00',
      '2026-11-04 10:30:00+01:00',
      '2026-11-04',
      'tomorrow',
      '2026-11-04T10:30:00+0100',
    ]) {
      test('refuses "$text" (no offset or another shape)', () {
        expect(() => ClinicInstant.parse(text), throwsFormatException);
      });
    }

    for (final text in [
      '2026-02-30T10:30:00Z',
      '2026-11-04T24:00:00Z',
      '2026-11-04T10:60:00Z',
      '2026-11-04T10:30:60Z',
      '2026-11-04T10:30:00+01:60',
      '2026-11-04T10:30:00+19:00',
    ]) {
      test('refuses "$text" (invalid date, time or offset)', () {
        expect(() => ClinicInstant.parse(text), throwsFormatException);
      });
    }
  });

  group('ClinicInstant()', () {
    test('stores the instant in UTC, whatever its zone', () {
      final local = DateTime(2026, 11, 4, 10, 30);

      final instant = ClinicInstant(local, const Duration(hours: 2));

      expect(instant.instant.isUtc, isTrue);
      expect(instant.instant.isAtSameMomentAs(local), isTrue);
    });

    test('refuses an offset that is not whole minutes or beyond 18 h', () {
      final now = DateTime.utc(2026);

      expect(
        () => ClinicInstant(now, const Duration(seconds: 30)),
        throwsArgumentError,
      );
      expect(
        () => ClinicInstant(now, const Duration(hours: -18, minutes: -1)),
        throwsArgumentError,
      );
      expect(
        ClinicInstant(now, const Duration(hours: 18)).offset,
        const Duration(hours: 18),
      );
    });
  });

  group('comparison and equality', () {
    final paris = ClinicInstant.parse('2026-11-04T10:30:00+01:00');
    final utc = ClinicInstant.parse('2026-11-04T09:30:00Z');
    final later = ClinicInstant.parse('2026-11-04T11:00:00+01:00');

    test('compares by instant', () {
      expect(paris.compareTo(utc), 0);
      expect(paris.isAtSameMomentAs(utc), isTrue);
      expect(paris.isBefore(later), isTrue);
      expect(later.isAfter(paris), isTrue);
      expect(paris.isAfter(later), isFalse);
      expect(paris.compareTo(later), lessThan(0));
    });

    test('equality needs the same instant and the same offset', () {
      expect(paris, isNot(utc));
      expect(paris, ClinicInstant.parse('2026-11-04T10:30:00+01:00'));
      expect(
        paris.hashCode,
        ClinicInstant.parse('2026-11-04T10:30:00+01:00').hashCode,
      );
      expect(paris == Object(), isFalse);
    });
  });
}
