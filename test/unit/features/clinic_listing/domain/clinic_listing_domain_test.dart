// The directory's domain: the times of day, the opening hours grouped into
// rows and the open status at a moment (ranges [opens, closes)), the
// search queries as family keys, the value objects' equality.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/opening_schedule.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';

ClockTime _t(String text) => ClockTime.parse(text)!;

OpeningHours _h(int day, String opens, String closes) =>
    OpeningHours(day: day, opensAt: _t(opens), closesAt: _t(closes));

OpeningRange _r(String opens, String closes) =>
    OpeningRange(_t(opens), _t(closes));

/// Lyon (capture): Monday to Friday 08:30–19:00, Saturday 09:00–12:00.
final List<OpeningHours> _lyon = [
  for (var day = 1; day <= 5; day++) _h(day, '08:30', '19:00'),
  _h(6, '09:00', '12:00'),
];

/// Paris (capture): two ranges Monday to Thursday, one on Friday and
/// Saturday; listed out of order to check the sorting.
final List<OpeningHours> _paris = [
  for (var day = 1; day <= 4; day++) ...[
    _h(day, '14:00', '19:00'),
    _h(day, '09:00', '12:30'),
  ],
  _h(5, '09:00', '19:00'),
  _h(6, '09:00', '13:00'),
];

void main() {
  group('ClockTime', () {
    test('parses HH:MM, 24:00 included; null for anything else', () {
      expect(_t('08:30').hour, 8);
      expect(_t('08:30').minute, 30);
      expect(_t('08:30').minutes, 510);
      expect(_t('24:00').minutes, 1440);
      for (final text in ['8:30', '08:3', '25:00', '24:01', '12:60', 'x', '']) {
        expect(ClockTime.parse(text), isNull, reason: text);
      }
    });

    test('refuses an impossible time', () {
      expect(() => ClockTime(-1, 0), throwsArgumentError);
      expect(() => ClockTime(25, 0), throwsArgumentError);
      expect(() => ClockTime(8, -1), throwsArgumentError);
      expect(() => ClockTime(8, 60), throwsArgumentError);
      expect(() => ClockTime(24, 30), throwsArgumentError);
      expect(ClockTime(0, 0).minutes, 0);
    });

    test('compares, equals, prints', () {
      expect(_t('08:30').isBefore(_t('09:00')), isTrue);
      expect(_t('09:00').isBefore(_t('09:00')), isFalse);
      expect(_t('09:00').compareTo(_t('08:30')), 1);
      expect(_t('09:05'), ClockTime(9, 5));
      expect(_t('09:05').hashCode, ClockTime(9, 5).hashCode);
      expect(_t('09:05'), isNot(ClockTime(9, 6)));
      expect(_t('09:05') == Object(), isFalse);
      expect('${ClockTime(9, 5)}', '09:05');
    });
  });

  group('the value objects', () {
    test('OpeningHours: equality and text', () {
      expect(_h(1, '08:30', '19:00'), _h(1, '08:30', '19:00'));
      expect(
        _h(1, '08:30', '19:00').hashCode,
        _h(1, '08:30', '19:00').hashCode,
      );
      expect(_h(1, '08:30', '19:00'), isNot(_h(2, '08:30', '19:00')));
      expect(_h(1, '08:30', '19:00'), isNot(_h(1, '08:00', '19:00')));
      expect(_h(1, '08:30', '19:00'), isNot(_h(1, '08:30', '18:00')));
      expect('${_h(1, '08:30', '19:00')}', 'OpeningHours(1, 08:30–19:00)');
    });

    test('GeoPoint: equality and text', () {
      const point = GeoPoint(48.88, 2.33);
      expect(point, const GeoPoint(48.88, 2.33));
      expect(point.hashCode, const GeoPoint(48.88, 2.33).hashCode);
      expect(point, isNot(const GeoPoint(48.88, 2.34)));
      expect(point, isNot(const GeoPoint(48.89, 2.33)));
      expect('$point', 'GeoPoint(48.88, 2.33)');
      // Built at run time, as the device's position is.
      final latitude = double.parse('48.88');
      expect(GeoPoint(latitude, 2.33), point);
    });

    test('ListingQuery: the text trimmed, no q when empty; equal searches '
        'are one family key', () {
      final query = ListingQuery(text: '  Lyon ');
      expect(query.text, 'Lyon');
      expect(query.q, 'Lyon');
      expect(query.near, isNull);
      expect(ListingQuery().q, isNull);
      expect(ListingQuery(text: '   ').q, isNull);
      expect(query, ListingQuery(text: 'Lyon'));
      expect(query.hashCode, ListingQuery(text: 'Lyon').hashCode);
      expect(query, isNot(ListingQuery(text: 'Paris')));
      expect(
        query,
        isNot(ListingQuery(text: 'Lyon', near: const GeoPoint(1, 2))),
      );
      expect(
        ListingQuery(near: const GeoPoint(1, 2)),
        ListingQuery(near: const GeoPoint(1, 2)),
      );
      expect('$query', 'ListingQuery(Lyon, null)');
    });

    test('the listings print their id and name', () {
      const summary = ClinicListingSummary(
        id: ListingId('l'),
        name: 'Clinique',
        onKiveto: true,
        onlineBooking: false,
      );
      expect('$summary', 'ClinicListingSummary(l, Clinique)');
      expect(summary.tags, isEmpty);
      expect(summary.address, isNull);
      const detail = ClinicListingDetail(
        id: ListingId('l'),
        name: 'Clinique',
        timezone: 'Europe/Paris',
        acceptsNewClients: true,
        onlineBooking: true,
      );
      expect('$detail', 'ClinicListingDetail(l, Clinique)');
      expect(detail.openingHours, isEmpty);
      const page = ClinicListingPage();
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
      const address = ListingAddress(line: '1 rue', city: 'Lyon');
      expect(address.postalCode, isNull);
      expect(
        ClinicListingSummary(
          id: const ListingId('x'),
          name: 'X',
          onKiveto: true,
          onlineBooking: true,
          nextAvailableAt: ClinicInstant.parse('2026-11-05T13:00:00+01:00'),
        ).nextAvailableAt?.hour,
        13,
      );
    });
  });

  group('weeklyRows', () {
    test('Lyon: Monday to Friday in one row, Saturday, Sunday closed', () {
      expect(weeklyRows(_lyon), [
        OpeningRow(firstDay: 1, lastDay: 5, ranges: [_r('08:30', '19:00')]),
        OpeningRow(firstDay: 6, lastDay: 6, ranges: [_r('09:00', '12:00')]),
        const OpeningRow(firstDay: 7, lastDay: 7),
      ]);
      expect(weeklyRows(_lyon).last.closed, isTrue);
      expect(weeklyRows(_lyon).first.closed, isFalse);
    });

    test('Paris: the two ranges sorted, Monday to Thursday in one row', () {
      final rows = weeklyRows(_paris);

      expect(rows, hasLength(4));
      expect(rows.first.firstDay, 1);
      expect(rows.first.lastDay, 4);
      expect(rows.first.ranges, [_r('09:00', '12:30'), _r('14:00', '19:00')]);
      expect(rows[1].ranges, [_r('09:00', '19:00')]);
      expect(rows[2].ranges, [_r('09:00', '13:00')]);
      expect(rows[3].closed, isTrue);
    });

    test('closed days apart keep their own rows; no hours, no row', () {
      final rows = weeklyRows([
        _h(2, '09:00', '12:00'),
        _h(4, '09:00', '12:00'),
      ]);

      expect(
        [for (final row in rows) (row.firstDay, row.lastDay)],
        [(1, 1), (2, 2), (3, 3), (4, 4), (5, 7)],
      );
      expect(weeklyRows(const []), isEmpty);
    });

    test('OpeningRow and OpeningRange: equality and text', () {
      final row = OpeningRow(
        firstDay: 1,
        lastDay: 5,
        ranges: [_r('08:30', '19:00')],
      );
      expect(
        row,
        OpeningRow(firstDay: 1, lastDay: 5, ranges: [_r('08:30', '19:00')]),
      );
      expect(
        row.hashCode,
        OpeningRow(
          firstDay: 1,
          lastDay: 5,
          ranges: [_r('08:30', '19:00')],
        ).hashCode,
      );
      expect(row, isNot(const OpeningRow(firstDay: 1, lastDay: 5)));
      expect(
        row,
        isNot(
          OpeningRow(firstDay: 1, lastDay: 5, ranges: [_r('08:30', '18:00')]),
        ),
      );
      expect(
        row,
        isNot(
          OpeningRow(firstDay: 2, lastDay: 5, ranges: [_r('08:30', '19:00')]),
        ),
      );
      expect(
        row,
        isNot(
          OpeningRow(firstDay: 1, lastDay: 4, ranges: [_r('08:30', '19:00')]),
        ),
      );
      expect(row == Object(), isFalse);
      expect('$row', 'OpeningRow(1–5, [08:30–19:00])');
      expect(_r('08:30', '19:00'), _r('08:30', '19:00'));
      expect(_r('08:30', '19:00').hashCode, _r('08:30', '19:00').hashCode);
      expect(_r('08:30', '19:00'), isNot(_r('08:30', '18:00')));
      expect(_r('08:30', '19:00') == Object(), isFalse);
    });
  });

  group('openingStatusAt', () {
    OpeningStatus at(List<OpeningHours> hours, int weekday, String time) =>
        openingStatusAt(hours, weekday: weekday, time: _t(time));

    test('open within a range, until its end (the end excluded)', () {
      expect(at(_lyon, 2, '10:22'), OpenUntil(_t('19:00')));
      expect(at(_lyon, 2, '08:30'), OpenUntil(_t('19:00')));
      expect(at(_paris, 1, '15:00'), OpenUntil(_t('19:00')));
      expect(at(_paris, 1, '12:29'), OpenUntil(_t('12:30')));
    });

    test('ranges that touch are one: open until the last one ends', () {
      final touching = [
        _h(1, '12:00', '19:00'),
        _h(1, '08:00', '12:00'),
        _h(1, '19:00', '20:00'),
        _h(2, '08:00', '12:00'),
        _h(2, '14:00', '19:00'),
      ];

      expect(at(touching, 1, '11:00'), OpenUntil(_t('20:00')));
      expect(at(touching, 1, '12:00'), OpenUntil(_t('20:00')));
      expect(at(touching, 1, '07:00'), OpensLater(_t('08:00')));
      // A break between two ranges is still a break.
      expect(at(touching, 2, '11:00'), OpenUntil(_t('12:00')));
      expect(at(touching, 2, '12:00'), OpensLater(_t('14:00')));
      // The grid keeps the ranges as the clinic set them.
      expect(weeklyRows(touching).first.ranges, hasLength(3));
    });

    test('closed for now, opening later today', () {
      expect(at(_lyon, 2, '07:00'), OpensLater(_t('08:30')));
      // The lunch break of Paris.
      expect(at(_paris, 1, '12:30'), OpensLater(_t('14:00')));
    });

    test('closed for the day: tomorrow, or another day', () {
      expect(
        at(_lyon, 2, '19:00'),
        OpensOn(2 + 1, _t('08:30'), tomorrow: true),
      );
      expect(at(_lyon, 6, '13:00'), OpensOn(1, _t('08:30'), tomorrow: false));
      expect(at(_lyon, 7, '10:00'), OpensOn(1, _t('08:30'), tomorrow: true));
      // Open one day a week: the same day a week later.
      expect(
        at([_h(3, '09:00', '12:00')], 3, '18:00'),
        OpensOn(3, _t('09:00'), tomorrow: false),
      );
    });

    test('no opening hours: nothing to say', () {
      expect(at(const [], 1, '10:00'), const NoOpeningHours());
    });

    test('the statuses: equality and text', () {
      expect(OpenUntil(_t('19:00')).hashCode, OpenUntil(_t('19:00')).hashCode);
      expect(OpenUntil(_t('19:00')), isNot(OpenUntil(_t('18:00'))));
      expect(OpenUntil(_t('19:00')) == Object(), isFalse);
      expect('${OpenUntil(_t('19:00'))}', 'OpenUntil(19:00)');
      expect(
        OpensLater(_t('14:00')).hashCode,
        OpensLater(_t('14:00')).hashCode,
      );
      expect(OpensLater(_t('14:00')), isNot(OpensLater(_t('15:00'))));
      expect(OpensLater(_t('14:00')) == Object(), isFalse);
      expect('${OpensLater(_t('14:00'))}', 'OpensLater(14:00)');
      final on = OpensOn(1, _t('09:00'), tomorrow: true);
      expect(on.hashCode, OpensOn(1, _t('09:00'), tomorrow: true).hashCode);
      expect(on, isNot(OpensOn(2, _t('09:00'), tomorrow: true)));
      expect(on, isNot(OpensOn(1, _t('10:00'), tomorrow: true)));
      expect(on, isNot(OpensOn(1, _t('09:00'), tomorrow: false)));
      expect(on == Object(), isFalse);
      expect('$on', 'OpensOn(1, 09:00, tomorrow: true)');
      expect(const NoOpeningHours().hashCode, const NoOpeningHours().hashCode);
      expect(const NoOpeningHours() == Object(), isFalse);
      expect('${const NoOpeningHours()}', 'NoOpeningHours()');
    });
  });
}
