import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';

/// French formatting of the shared value objects (`fr_FR`; the date
/// symbols are initialised by bootstrap, and by the tests).
///
/// A [ClinicInstant] is always formatted on the clinic's wall clock, never
/// the device's zone.
abstract final class KivetoFormat {
  static const _locale = 'fr_FR';

  /// `Mar. 4 nov. · 10:30`.
  static String dateTimeShort(ClinicInstant instant) {
    final local = _wallClock(instant);
    final weekday = DateFormat('EEE', _locale).format(local);
    return '${_capitalize(weekday)} '
        '${DateFormat('d MMM', _locale).format(local)} · '
        '${DateFormat('HH:mm', _locale).format(local)}';
  }

  /// `4 nov.`
  static String dayMonth(LocalDate date) =>
      DateFormat('d MMM', _locale).format(_utc(date));

  /// `14 oct. 2026`
  static String dayMonthYear(LocalDate date) =>
      DateFormat('d MMM y', _locale).format(_utc(date));

  /// `14 octobre 2026`, the day of [instant] on the clinic's wall clock.
  static String dayMonthYearLong(ClinicInstant instant) =>
      DateFormat('d MMMM y', _locale).format(_wallClock(instant));

  /// `04/11/2026`
  static String numericDate(LocalDate date) =>
      DateFormat('dd/MM/y', _locale).format(_utc(date));

  /// `10:30`
  static String time(ClinicInstant instant) =>
      DateFormat('HH:mm', _locale).format(_wallClock(instant));

  /// `68,00 €` (a no-break space before the symbol, a narrow no-break space
  /// between thousands), with the currency's own decimals.
  static String money(Money money) {
    final format = NumberFormat.simpleCurrency(
      locale: _locale,
      name: money.currency,
    );
    final digits = format.decimalDigits ?? 2;
    return format.format(money.minorUnits / math.pow(10, digits));
  }

  /// A phone number in E.164 (`+33612345678`): France and its overseas
  /// departments as a national number in pairs (`06 12 34 56 78`), other
  /// countries as `+CCC` then pairs (`+687 75 12 34`); anything else is
  /// returned unchanged.
  static String phone(String e164) {
    if (!_e164.hasMatch(e164)) return e164;
    final digits = e164.substring(1);
    final codeLength = _countryCodeLength(digits);
    final code = digits.substring(0, codeLength);
    final national = digits.substring(codeLength);
    if (_frenchCodes.contains(code) && national.length == 9) {
      return _pairs('0$national');
    }
    return '+$code ${_pairs(national)}';
  }

  static final _e164 = RegExp(r'^\+[1-9]\d{6,14}$');

  /// France and the overseas departments dialled like it (Réunion and
  /// Mayotte, Guadeloupe, French Guiana, Martinique).
  static const _frenchCodes = {'33', '262', '590', '594', '596'};

  /// The length of the E.164 country code that starts [digits] (the ITU
  /// numbering plan: 1 and 7 are one digit; the two-digit codes are listed;
  /// the rest are three digits).
  static int _countryCodeLength(String digits) {
    if (digits.startsWith('1') || digits.startsWith('7')) return 1;
    const twoDigits = {
      '20', '27', '30', '31', '32', '33', '34', '36', '39', '40', '41', //
      '43', '44', '45', '46', '47', '48', '49', '51', '52', '53', '54', //
      '55', '56', '57', '58', '60', '61', '62', '63', '64', '65', '66', //
      '81', '82', '84', '86', '90', '91', '92', '93', '94', '95', '98',
    };
    return twoDigits.contains(digits.substring(0, 2)) ? 2 : 3;
  }

  static String _pairs(String digits) => [
    for (var i = 0; i < digits.length; i += 2)
      digits.substring(i, math.min(i + 2, digits.length)),
  ].join(' ');

  static DateTime _wallClock(ClinicInstant instant) => DateTime.utc(
    instant.year,
    instant.month,
    instant.day,
    instant.hour,
    instant.minute,
  );

  static DateTime _utc(LocalDate date) =>
      DateTime.utc(date.year, date.month, date.day);

  static String _capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}
