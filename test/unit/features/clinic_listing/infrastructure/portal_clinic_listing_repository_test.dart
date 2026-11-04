// PortalClinicListingRepository on the real chain and the live captures of
// 2026-11-04: the search (all, by name, empty, around a position, page
// after page), the refusals (422 on q or lat, 400 cursor_invalid, 429),
// the sheets (Lyon, Paris and its two ranges, Vercors without address,
// phone or hours), the 404, a malformed opening time, a next slot.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/infrastructure/portal_clinic_listing_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _listings = '$api/clinic-listings';
const _lyon = '01a19a12-79bb-7408-9051-a42bd37f652d';
const _paris = '01a19a11-0518-78b1-9eea-49198a26a6a7';
const _vercors = '01a19a12-79dd-76b5-980f-ef11ab1a74e5';

PortalReply _edited(
  String fixture,
  void Function(Object? body) change, {
  int status = 200,
}) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body), status: status);
}

String _cursor() =>
    (jsonDecode(
          File('$portalFixtures/clinic-listings.page1.get.200.json')
              .readAsStringSync(),
        ) as Map<String, Object?>)['nextCursor']!
        as String;

void main() {
  late PortalHarness harness;
  late PortalClinicListingRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalClinicListingRepository(
      harness.http.server,
      harness.failures,
    );
  });

  group('search', () {
    test('all (capture): by name, no q; Vercors without address nor phone, '
        'Lyon online, Paris with its tags', () async {
      harness.backend.on(
        'GET',
        _listings,
        PortalReply.fixture('clinic-listings.get.200.json'),
      );

      final page = await repository.search(ListingQuery());

      expect(page.nextCursor, isNull);
      expect(page.items.map((clinic) => clinic.name), [
        'Clinique du Vercors',
        'Clinique Vétérinaire de Lyon',
        'Clinique Vétérinaire de Paris',
      ]);
      final [vercors, lyon, paris] = page.items;
      expect(vercors.id, const ListingId(_vercors));
      expect(vercors.address, isNull);
      expect(vercors.phone, isNull);
      expect(vercors.onKiveto, isTrue);
      expect(vercors.onlineBooking, isFalse);
      expect(vercors.tags, ['Rurale']);
      expect(vercors.distanceM, isNull);
      expect(vercors.nextAvailableAt, isNull);
      expect(lyon.address?.line, '7 quai Saint-Antoine, Bâtiment B');
      expect(lyon.address?.postalCode, '69002');
      expect(lyon.address?.city, 'Lyon');
      expect(lyon.phone, '+33478920145');
      expect(lyon.onlineBooking, isTrue);
      expect(paris.tags, hasLength(8));
      expect(harness.backend.requests.single.pathWithQuery, _listings);
    });

    test('by name (capture): q sent trimmed', () async {
      harness.backend.on(
        'GET',
        '$_listings?q=Lyon',
        PortalReply.fixture('clinic-listings.search.get.200.json'),
      );

      final page = await repository.search(ListingQuery(text: ' Lyon '));

      expect(page.items.single.id, const ListingId(_lyon));
    });

    test('nothing found (capture)', () async {
      harness.backend.on(
        'GET',
        '$_listings?q=Zz',
        PortalReply.fixture('clinic-listings.search-empty.get.200.json'),
      );

      final page = await repository.search(ListingQuery(text: 'Zz'));

      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('around a position (capture): lat and lng with the text, the '
        'distance', () async {
      harness.backend.onRequest(
        'GET',
        '$_listings?q=Paris&lat=48.88&lng=2.33',
        (request) => PortalReply.fixture('clinic-listings.near.get.200.json'),
      );

      final page = await repository.search(
        ListingQuery(text: 'Paris', near: const GeoPoint(48.88, 2.33)),
      );

      final paris = page.items.single;
      expect(paris.id, const ListingId(_paris));
      expect(paris.distanceM, 2074);
      final query = harness.backend.requests.single.uri.queryParameters;
      expect(query, {'q': 'Paris', 'lat': '48.88', 'lng': '2.33'});
    });

    test('page after page (captures): the cursor of the first', () async {
      harness.backend
        ..on(
          'GET',
          _listings,
          PortalReply.fixture('clinic-listings.page1.get.200.json'),
        )
        ..on(
          'GET',
          '$_listings?cursor=${_cursor()}',
          PortalReply.fixture('clinic-listings.page2.get.200.json'),
        );

      final first = await repository.search(ListingQuery());
      final second = await repository.search(
        ListingQuery(),
        cursor: first.nextCursor,
      );

      expect(first.items, hasLength(2));
      expect(first.nextCursor, _cursor());
      expect(second.items.single.id, const ListingId(_paris));
      expect(second.nextCursor, isNull);
    });

    test('a next slot is read on the clinic clock', () async {
      harness.backend.on(
        'GET',
        _listings,
        _edited('clinic-listings.get.200.json', (body) {
          final items = (body! as Map<String, Object?>)['items']! as List;
          (items[1] as Map<String, Object?>)['nextAvailableAt'] =
              '2026-11-05T13:00:00+01:00';
        }),
      );

      final lyon = (await repository.search(ListingQuery())).items[1];

      expect(
        lyon.nextAvailableAt?.toIso8601String(),
        '2026-11-05T13:00:00+01:00',
      );
    });

    test('the refusals: 422 on q (its violation), 422 on lat, 400 '
        'cursor_invalid, 429', () async {
      harness.backend
        ..on(
          'GET',
          '$_listings?q=a',
          PortalReply.fixture(
            'clinic-listings.validation.get.422.json',
            status: 422,
          ),
        )
        ..on(
          'GET',
          '$_listings?q=b',
          PortalReply.fixture(
            'clinic-listings.coordinates.get.422.json',
            status: 422,
          ),
        )
        ..on(
          'GET',
          '$_listings?cursor=stale',
          PortalReply.fixture(
            'clinic-listings.cursor-invalid.get.400.json',
            status: 400,
          ),
        )
        ..on('GET', '$_listings?q=c', problem('rate_limited', 429));

      await expectLater(
        repository.search(ListingQuery(text: 'a')),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.message,
            'message',
            'Saisissez au moins 2 caractères.',
          ),
        ),
      );
      await expectLater(
        repository.search(ListingQuery(text: 'b')),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.propertyPath,
            'propertyPath',
            'lat',
          ),
        ),
      );
      await expectLater(
        repository.search(ListingQuery(), cursor: 'stale'),
        throwsA(
          isA<BusinessFailure>().having(
            (failure) => failure.code,
            'code',
            'cursor_invalid',
          ),
        ),
      );
      await expectLater(
        repository.search(ListingQuery(text: 'c')),
        throwsA(isA<RateLimitedFailure>()),
      );
    });
  });

  group('listing', () {
    test('Lyon (capture): address, phone, zone, the week, open to new '
        'clients online', () async {
      harness.backend.on(
        'GET',
        '$_listings/$_lyon',
        PortalReply.fixture('clinic-listings.lyon.get.200.json'),
      );

      final lyon = await repository.listing(const ListingId(_lyon));

      expect(lyon.id, const ListingId(_lyon));
      expect(lyon.name, 'Clinique Vétérinaire de Lyon');
      expect(lyon.address?.postalCode, '69002');
      expect(lyon.phone, '+33478920145');
      expect(lyon.timezone, 'Europe/Paris');
      expect(lyon.acceptsNewClients, isTrue);
      expect(lyon.onlineBooking, isTrue);
      expect(lyon.tags, ['Équidés', 'NAC']);
      expect(lyon.openingHours, hasLength(6));
      expect(
        lyon.openingHours.first,
        OpeningHours(
          day: 1,
          opensAt: ClockTime(8, 30),
          closesAt: ClockTime(19, 0),
        ),
      );
      expect(lyon.openingHours.last.day, 6);
    });

    test('Paris (capture): two ranges a day, not online', () async {
      harness.backend.on(
        'GET',
        '$_listings/$_paris',
        PortalReply.fixture('clinic-listings.paris.get.200.json'),
      );

      final paris = await repository.listing(const ListingId(_paris));

      expect(paris.openingHours, hasLength(10));
      expect(paris.openingHours[1].opensAt, ClockTime(14, 0));
      expect(paris.onlineBooking, isFalse);
    });

    test(
      'Vercors (capture): no address, phone or hours; no new client',
      () async {
        harness.backend.on(
          'GET',
          '$_listings/$_vercors',
          PortalReply.fixture('clinic-listings.vercors.get.200.json'),
        );

        final vercors = await repository.listing(const ListingId(_vercors));

        expect(vercors.address, isNull);
        expect(vercors.phone, isNull);
        expect(vercors.openingHours, isEmpty);
        expect(vercors.acceptsNewClients, isFalse);
      },
    );

    test('unknown (capture): a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        '$_listings/unknown',
        PortalReply.fixture(
          'clinic-listings.unknown.get.404.json',
          status: 404,
        ),
      );

      await expectLater(
        repository.listing(const ListingId('unknown')),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test(
      'a malformed opening time is an answer this app cannot read',
      () async {
        harness.backend.on(
          'GET',
          '$_listings/$_lyon',
          _edited('clinic-listings.lyon.get.200.json', (body) {
            final hours =
                (body! as Map<String, Object?>)['openingHours']! as List;
            (hours.first as Map<String, Object?>)['closesAt'] = '7pm';
          }),
        );

        await expectLater(
          repository.listing(const ListingId(_lyon)),
          throwsA(
            isA<ServerFailure>().having(
              (failure) => failure.detail,
              'detail',
              contains('7pm'),
            ),
          ),
        );
      },
    );
  });
}
