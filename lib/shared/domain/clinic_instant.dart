// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/shared/domain/local_date.dart';

/// An instant with the UTC offset of the clinic that sent it.
///
/// The Portal API sends every `date-time` in the clinic's offset
/// (`2026-11-04T10:30:00+01:00`); `DateTime.parse` keeps the instant but
/// drops the offset, so the app would show the device's wall clock instead
/// of the clinic's. The clinic-local fields ([hour], [date]…) read the wall
/// clock of the clinic.
final class ClinicInstant implements Comparable<ClinicInstant> {
  /// [instant] (any zone, stored in UTC) seen with [offset], a whole number
  /// of minutes within ±18 h ([ArgumentError] otherwise).
  new(DateTime instant, this.offset)
    : instant = DateTime.fromMicrosecondsSinceEpoch(
        instant.microsecondsSinceEpoch,
        isUtc: true,
      ) {
    if (offset.inMicroseconds % Duration.microsecondsPerMinute != 0 ||
        offset.abs() > _maxOffset) {
      throw ArgumentError.value(
        offset,
        'offset',
        'expected whole minutes within ±18 h',
      );
    }
  }

  /// Parses `YYYY-MM-DDTHH:MM[:SS[.fraction]]` followed by `Z` or `±HH:MM`;
  /// a value without offset, or an invalid date, time or offset, is a
  /// [FormatException].
  factory parse(String text) {
    final match = _format.firstMatch(text);
    if (match == null) {
      throw FormatException(
        'expected an ISO 8601 date-time with Z or ±HH:MM',
        text,
      );
    }
    int field(int group) => int.parse(match[group] ?? '0');
    final (hour, minute, second) = (field(4), field(5), field(6));
    final (offsetHours, offsetMinutes) = (field(10), field(11));
    if (hour > 23 || minute > 59 || second > 59 || offsetMinutes > 59) {
      throw FormatException('invalid time', text);
    }
    final date = LocalDate.parse(text.substring(0, 10));
    final sign = match[9] == '-' ? -1 : 1;
    final offset = Duration(minutes: sign * (offsetHours * 60 + offsetMinutes));
    if (offset.abs() > _maxOffset) {
      throw FormatException('offset out of range', text);
    }
    final fraction = (match[7] ?? '').padRight(6, '0').substring(0, 6);
    final wallClock = DateTime.utc(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
      second,
      0,
      int.parse(fraction),
    );
    return ClinicInstant(wallClock.subtract(offset), offset);
  }

  static const _maxOffset = Duration(hours: 18);

  static final _format = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d+))?)?'
    r'(Z|([+-])(\d{2}):(\d{2}))$',
  );

  /// The instant, in UTC.
  final DateTime instant;

  /// The clinic's UTC offset at that instant.
  final Duration offset;

  /// The clinic's wall clock, as a UTC [DateTime] whose fields are local.
  DateTime get _local => instant.add(offset);

  int get year => _local.year;
  int get month => _local.month;
  int get day => _local.day;
  int get hour => _local.hour;
  int get minute => _local.minute;
  int get second => _local.second;

  /// [DateTime.monday] (1) to [DateTime.sunday] (7), in the clinic.
  int get weekday => _local.weekday;

  /// The clinic-local date.
  LocalDate get date => LocalDate(year, month, day);

  bool isBefore(ClinicInstant other) => instant.isBefore(other.instant);

  bool isAfter(ClinicInstant other) => instant.isAfter(other.instant);

  bool isAtSameMomentAs(ClinicInstant other) =>
      instant.isAtSameMomentAs(other.instant);

  /// By instant only: two offsets of the same moment compare equal here,
  /// unlike [==].
  @override
  int compareTo(ClinicInstant other) => instant.compareTo(other.instant);

  @override
  bool operator ==(Object other) =>
      other is ClinicInstant &&
      other.instant == instant &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(instant, offset);

  /// `2026-11-04T10:30:00+01:00`: seconds, no fraction, `+00:00` for UTC.
  String toIso8601String() {
    final minutes = offset.inMinutes.abs();
    final sign = offset.isNegative ? '-' : '+';
    return '${date.toIso8601String()}T${_two(hour)}:${_two(minute)}:'
        '${_two(second)}$sign${_two(minutes ~/ 60)}:${_two(minutes % 60)}';
  }

  @override
  String toString() => toIso8601String();
}

String _two(int value) => value.toString().padLeft(2, '0');
