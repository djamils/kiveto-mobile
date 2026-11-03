// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// A calendar date without time or zone, the `format: date` of the Portal
/// API (`2026-11-04`): birth dates, due dates, day pickers.
final class LocalDate implements Comparable<LocalDate> {
  /// A real date of the proleptic Gregorian calendar, years 1 to 9999;
  /// [ArgumentError] otherwise (`LocalDate(2026, 2, 30)`).
  new(this.year, this.month, this.day) {
    if (!_isValid(year, month, day)) {
      throw ArgumentError(
        'invalid date ${_pad(year, 4)}-${_pad(month, 2)}-${_pad(day, 2)}',
      );
    }
  }

  /// Parses `YYYY-MM-DD`; [FormatException] on another shape or an invalid
  /// date.
  factory parse(String text) {
    final match = _format.firstMatch(text);
    if (match == null) {
      throw FormatException('expected YYYY-MM-DD', text);
    }
    final (year, month, day) = (
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
    if (!_isValid(year, month, day)) {
      throw FormatException('invalid date', text);
    }
    return LocalDate(year, month, day);
  }

  static bool _isValid(int year, int month, int day) {
    final utc = DateTime.utc(year, month, day);
    return year >= 1 &&
        year <= 9999 &&
        utc.year == year &&
        utc.month == month &&
        utc.day == day;
  }

  static final _format = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// [DateTime.monday] (1) to [DateTime.sunday] (7).
  int get weekday => _utc.weekday;

  /// The number of days from this date to [other] (negative before).
  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  LocalDate addDays(int days) {
    final shifted = _utc.add(Duration(days: days));
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }

  bool isBefore(LocalDate other) => compareTo(other) < 0;

  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `2026-11-04`.
  String toIso8601String() =>
      '${_pad(year, 4)}-${_pad(month, 2)}-${_pad(day, 2)}';

  @override
  String toString() => toIso8601String();
}

String _pad(int value, int width) => value.toString().padLeft(width, '0');
