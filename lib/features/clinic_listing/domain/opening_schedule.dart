// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';

// The opening hours of a clinic of the directory, as screen 11 shows them:
// the week grouped into rows, and whether the clinic is open at a moment.
// The ranges are the clinic's typical week (no exceptional closure); a
// range is open from its opening time (included) to its closing time
// (excluded).

/// One range of a day: from [opensAt] (included) to [closesAt] (excluded).
final class OpeningRange {
  const new(this.opensAt, this.closesAt);

  final ClockTime opensAt;
  final ClockTime closesAt;

  @override
  bool operator ==(Object other) =>
      other is OpeningRange &&
      other.opensAt == opensAt &&
      other.closesAt == closesAt;

  @override
  int get hashCode => Object.hash(opensAt, closesAt);

  @override
  String toString() => '$opensAt–$closesAt';
}

/// A row of the hours grid: the days from [firstDay] to [lastDay] (ISO, 1 =
/// Monday), which share the same [ranges]; closed when [ranges] is empty.
final class OpeningRow {
  const new({
    required this.firstDay,
    required this.lastDay,
    this.ranges = const [],
  });

  final int firstDay;
  final int lastDay;

  /// By opening time.
  final List<OpeningRange> ranges;

  bool get closed => ranges.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is OpeningRow &&
      other.firstDay == firstDay &&
      other.lastDay == lastDay &&
      _sameRanges(other.ranges, ranges);

  @override
  int get hashCode => Object.hash(firstDay, lastDay, Object.hashAll(ranges));

  @override
  String toString() => 'OpeningRow($firstDay–$lastDay, $ranges)';
}

bool _sameRanges(List<OpeningRange> a, List<OpeningRange> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The ranges of [day], by opening time.
List<OpeningRange> _rangesOf(List<OpeningHours> hours, int day) => [
  for (final range in hours)
    if (range.day == day) OpeningRange(range.opensAt, range.closesAt),
]..sort((a, b) => a.opensAt.compareTo(b.opensAt));

/// The week from Monday to Sunday as rows of the hours grid: consecutive
/// days with the same ranges in one row, a closed day kept as a row
/// without range; no row at all without [hours] (the clinic gave none).
List<OpeningRow> weeklyRows(List<OpeningHours> hours) {
  if (hours.isEmpty) return const [];
  final rows = <OpeningRow>[];
  for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
    final ranges = _rangesOf(hours, day);
    final last = rows.isEmpty ? null : rows.last;
    if (last != null && _sameRanges(last.ranges, ranges)) {
      rows.last = OpeningRow(
        firstDay: last.firstDay,
        lastDay: day,
        ranges: last.ranges,
      );
    } else {
      rows.add(OpeningRow(firstDay: day, lastDay: day, ranges: ranges));
    }
  }
  return rows;
}

/// Whether the clinic is open at a moment, and until or from when.
sealed class OpeningStatus {
  const new();
}

/// Open now, until [closesAt] today.
final class OpenUntil extends OpeningStatus {
  const new(this.closesAt);

  final ClockTime closesAt;

  @override
  bool operator ==(Object other) =>
      other is OpenUntil && other.closesAt == closesAt;

  @override
  int get hashCode => closesAt.hashCode;

  @override
  String toString() => 'OpenUntil($closesAt)';
}

/// Closed now, opening again today at [opensAt].
final class OpensLater extends OpeningStatus {
  const new(this.opensAt);

  final ClockTime opensAt;

  @override
  bool operator ==(Object other) =>
      other is OpensLater && other.opensAt == opensAt;

  @override
  int get hashCode => opensAt.hashCode;

  @override
  String toString() => 'OpensLater($opensAt)';
}

/// Closed for the rest of the day, opening again on [weekday] (ISO) at
/// [opensAt]; [tomorrow] when that is the next day.
final class OpensOn extends OpeningStatus {
  const new(this.weekday, this.opensAt, {required this.tomorrow});

  final int weekday;
  final ClockTime opensAt;
  final bool tomorrow;

  @override
  bool operator ==(Object other) =>
      other is OpensOn &&
      other.weekday == weekday &&
      other.opensAt == opensAt &&
      other.tomorrow == tomorrow;

  @override
  int get hashCode => Object.hash(weekday, opensAt, tomorrow);

  @override
  String toString() => 'OpensOn($weekday, $opensAt, tomorrow: $tomorrow)';
}

/// The clinic gave no opening hours: nothing to say.
final class NoOpeningHours extends OpeningStatus {
  const new();

  @override
  bool operator ==(Object other) => other is NoOpeningHours;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'NoOpeningHours()';
}

/// The ranges of [day] by opening time, a range opening when the one
/// before closes merged into it (08:00–12:00 and 12:00–19:00: open from
/// 08:00 to 19:00).
List<OpeningRange> _continuousRangesOf(List<OpeningHours> hours, int day) {
  final merged = <OpeningRange>[];
  for (final range in _rangesOf(hours, day)) {
    final last = merged.isEmpty ? null : merged.last;
    if (last != null && range.opensAt == last.closesAt) {
      merged.last = OpeningRange(last.opensAt, range.closesAt);
    } else {
      merged.add(range);
    }
  }
  return merged;
}

/// Whether the clinic is open on [weekday] (ISO) at [time], by its typical
/// week [hours]: open until the end of the range holding [time] (ranges
/// that touch count as one); else the next range of the day; else the
/// first range of the next open day (the same day a week later for a
/// clinic open one day a week).
OpeningStatus openingStatusAt(
  List<OpeningHours> hours, {
  required int weekday,
  required ClockTime time,
}) {
  final today = _continuousRangesOf(hours, weekday);
  for (final range in today) {
    if (!time.isBefore(range.opensAt) && time.isBefore(range.closesAt)) {
      return OpenUntil(range.closesAt);
    }
  }
  for (final range in today) {
    if (time.isBefore(range.opensAt)) return OpensLater(range.opensAt);
  }
  for (var offset = 1; offset <= 7; offset++) {
    final day = (weekday - 1 + offset) % 7 + 1;
    final ranges = _rangesOf(hours, day);
    if (ranges.isNotEmpty) {
      return OpensOn(day, ranges.first.opensAt, tomorrow: offset == 1);
    }
  }
  return const NoOpeningHours();
}
