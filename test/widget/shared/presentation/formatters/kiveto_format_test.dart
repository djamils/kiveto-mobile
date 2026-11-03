import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  // The mockup's sample (a Tuesday in 2025; 4 Nov 2026 is a Wednesday).
  final instant = ClinicInstant.parse('2025-11-04T10:30:00+01:00');

  test('dates and times on the clinic wall clock', () {
    expect(KivetoFormat.dateTimeShort(instant), 'Mar. 4 nov. · 10:30');
    expect(KivetoFormat.time(instant), '10:30');
    // Another offset of the same instant shows that clinic's clock.
    expect(
      KivetoFormat.dateTimeShort(
        ClinicInstant.parse('2025-11-05T06:30:00+11:00'),
      ),
      'Mer. 5 nov. · 06:30',
    );
    expect(KivetoFormat.dayMonth(LocalDate(2026, 11, 4)), '4 nov.');
    expect(KivetoFormat.dayMonthYear(LocalDate(2026, 10, 14)), '14 oct. 2026');
    expect(KivetoFormat.numericDate(LocalDate(2026, 11, 4)), '04/11/2026');
    // The long form of the history, on the clinic's clock too.
    expect(
      KivetoFormat.dayMonthYearLong(
        ClinicInstant.parse('2026-08-18T17:45:00+02:00'),
      ),
      '18 août 2026',
    );
    expect(
      KivetoFormat.dayMonthYearLong(
        ClinicInstant.parse('2026-10-14T23:30:00-05:00'),
      ),
      '14 octobre 2026',
    );
  });

  test('the days of the booking: long, short, in a sentence, the day '
      'picker, the date tile, the months a week covers', () {
    final monday = LocalDate(2026, 11, 9);
    expect(KivetoFormat.dayLong(monday), 'Lundi 9 novembre');
    expect(KivetoFormat.dayShort(monday), 'Lun. 9 nov.');
    expect(KivetoFormat.dayShort(monday, capitalized: false), 'lun. 9 nov.');
    expect(KivetoFormat.weekdayShort(monday), 'Lun');
    expect(KivetoFormat.weekdayShort(LocalDate(2026, 11, 11)), 'Mer');
    expect(KivetoFormat.monthShort(monday), 'nov.');
    expect(
      KivetoFormat.monthRange(LocalDate(2026, 11, 3), LocalDate(2026, 11, 9)),
      'Novembre 2026',
    );
    expect(
      KivetoFormat.monthRange(LocalDate(2026, 11, 27), LocalDate(2026, 12, 3)),
      'Novembre – décembre 2026',
    );
    expect(
      KivetoFormat.monthRange(LocalDate(2026, 12, 29), LocalDate(2027, 1, 4)),
      'Décembre 2026 – janvier 2027',
    );
  });

  test('money with the currency decimals and French separators', () {
    expect(KivetoFormat.money(Money(6800, 'EUR')), '68,00 €');
    expect(KivetoFormat.money(Money(123456789, 'EUR')), '1 234 567,89 €');
    expect(KivetoFormat.money(Money(1500, 'JPY')), '1 500 ¥');
  });

  test('phone numbers', () {
    expect(KivetoFormat.phone('+33612345678'), '06 12 34 56 78');
    expect(KivetoFormat.phone('+262692123456'), '06 92 12 34 56');
    expect(KivetoFormat.phone('+590690001122'), '06 90 00 11 22');
    expect(KivetoFormat.phone('+687751234'), '+687 75 12 34');
    expect(KivetoFormat.phone('+14155550123'), '+1 41 55 55 01 23');
    expect(KivetoFormat.phone('+447911123456'), '+44 79 11 12 34 56');
    expect(KivetoFormat.phone('+3361234567'), '+33 61 23 45 67');
    expect(KivetoFormat.phone('0612345678'), '0612345678');
    expect(KivetoFormat.phone('+33 6 12'), '+33 6 12');
    expect(KivetoFormat.phone(''), '');
  });
}
