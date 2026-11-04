// PortalNewClientBookingRepository on the real chain and the live captures
// of 2026-11-04: Lyon's motifs, practitioners and availability for a new
// client (Paris closed: booking_not_open), the request of a new pet (its
// body and Idempotency-Key; the replay; the refusals: slot_taken,
// already_linked, booking_request_limit, the key reused, a name refused,
// the key missing), a known pet refused before any call, and the
// account's requests (pending, declined, confirmed, none; the limit; the
// enums by name, unknown kept).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_new_client_booking_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _lyonId = '01a19a12-79bb-7408-9051-a42bd37f652d';
const _lyon = ListingId(_lyonId);
const _paris = ListingId('01a19a11-0518-78b1-9eea-49198a26a6a7');
const _base = '$api/clinic-listings/$_lyonId/booking';
const _consultation = MotifId('01a19a10-d3d1-7031-bd42-3d901474af59');
const _lemoine = PractitionerId('01a19a0e-29db-7550-a605-8ac512a656c1');
const _key = IdempotencyKey('listing-intent-1');
const _requests = '$api/me/booking-requests';

PortalReply _edited(
  String fixture,
  void Function(Object? body) change, {
  int status = 200,
}) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body), status: status);
}

BookingRequest _request(BookingPet pet) => BookingRequest(
  pet: pet,
  motifId: _consultation,
  practitionerId: _lemoine,
  startAt: ClinicInstant.parse('2026-11-12T14:00:00+01:00'),
);

const _capture = NewPet('Capture', Species.cat);

void main() {
  late PortalHarness harness;
  late PortalNewClientBookingRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalNewClientBookingRepository(
      harness.http.server,
      harness.failures,
    );
  });

  test("Lyon's motifs for a new client (capture)", () async {
    harness.backend.on(
      'GET',
      '$_base/motifs',
      PortalReply.fixture('clinic-listings.lyon.booking.motifs.get.200.json'),
    );

    final motif = (await repository.motifs(_lyon)).single;

    expect(motif.id, _consultation);
    expect(motif.label, 'Consultation');
    expect(motif.durationMin, 30);
    expect(
      motif.description,
      'Un problème de santé, un avis, un contrôle de routine.',
    );
    expect(motif.suggested, isFalse);
    expect(motif.suggestionReason, isNull);
  });

  test(
    'Paris closed to new clients online (capture): booking_not_open',
    () async {
      harness.backend.on(
        'GET',
        '$api/clinic-listings/${_paris.value}/booking/motifs',
        PortalReply.fixture(
          'clinic-listings.paris.booking.motifs.get.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.motifs(_paris),
        throwsA(
          isA<BusinessFailure>().having(
            (failure) => failure.code,
            'code',
            'booking_not_open',
          ),
        ),
      );
    },
  );

  test('the practitioners (capture), by name; a motif refused', () async {
    harness.backend
      ..on(
        'GET',
        '$_base/practitioners?motifId=${_consultation.value}',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.practitioners.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_base/practitioners?motifId=',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.practitioners.validation.get.422.json',
          status: 422,
        ),
      );

    final practitioners = await repository.practitioners(_lyon, _consultation);

    expect(practitioners.map((practitioner) => practitioner.displayName), [
      'Dr Sarah Lemoine',
      'Dr Éric Rousseau',
    ]);
    expect(practitioners.first.id, _lemoine);
    await expectLater(
      repository.practitioners(_lyon, const MotifId('')),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test(
    "Lemoine's 14 days from the 4th (capture), the clinic's offset kept",
    () async {
      harness.backend.on(
        'GET',
        '$_base/availability?motifId=${_consultation.value}'
            '&practitionerId=${_lemoine.value}&from=2026-11-04&to=2026-11-17',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.availability.get.200.json',
        ),
      );

      final days = await repository.availability(
        _lyon,
        _consultation,
        _lemoine,
        LocalDate(2026, 11, 4),
        LocalDate(2026, 11, 17),
      );

      expect(days, hasLength(14));
      expect(days.first.date, LocalDate(2026, 11, 4));
      expect(days.first.open, isTrue);
      expect(days.first.slots, isEmpty);
      expect(
        days[1].slots.first.toIso8601String(),
        '2026-11-05T13:00:00+01:00',
      );
    },
  );

  test('a past from refused (422 validation_failed on from)', () async {
    harness.backend.on(
      'GET',
      '$_base/availability?motifId=${_consultation.value}'
          '&practitionerId=${_lemoine.value}&from=2026-11-03&to=2026-11-16',
      PortalReply.json(
        jsonEncode({
          'type': 'validation_failed',
          'title': 'Données invalides.',
          'status': 422,
          'violations': [
            {'propertyPath': 'from', 'message': 'Date passée.'},
          ],
        }),
        status: 422,
      ),
    );

    await expectLater(
      repository.availability(
        _lyon,
        _consultation,
        _lemoine,
        LocalDate(2026, 11, 3),
        LocalDate(2026, 11, 16),
      ),
      throwsA(
        isA<ValidationFailure>().having(
          (failure) => failure.violations.single.propertyPath,
          'propertyPath',
          'from',
        ),
      ),
    );
  });

  group('request', () {
    test('a new pet (capture): the body with the slot as received, the key; '
        'pending, no appointment yet', () async {
      harness.backend.on(
        'POST',
        '$_base/appointments',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.appointments.post.201.json',
          status: 201,
        ),
      );

      final request = await repository.request(_lyon, _request(_capture), _key);

      final sent = harness.backend.requestsTo('$_base/appointments').single;
      expect(sent.headers['Idempotency-Key'], 'listing-intent-1');
      expect(jsonDecode(utf8.decode(sent.body)), {
        'newPet': {'name': 'Capture', 'species': 'cat'},
        'motifId': _consultation.value,
        'practitionerId': _lemoine.value,
        'startAt': '2026-11-12T14:00:00+01:00',
      });
      expect(
        request.id,
        const AppointmentRequestId('01a1a496-639e-7512-a3b9-e5c2596e2c3d'),
      );
      expect(request.clinicName, 'Clinique Vétérinaire de Lyon');
      expect(request.clinicCity, 'Lyon');
      expect(request.petName, 'Capture');
      expect(request.petSpecies, Species.cat);
      expect(request.motifLabel, 'Consultation');
      expect(request.startAt.toIso8601String(), '2026-11-12T14:00:00+01:00');
      expect(request.status, AppointmentRequestStatus.pending);
      expect(request.declineReason, isNull);
      expect(request.appointmentId, isNull);
    });

    test('the replay (capture: the stored body, spaced): the same request; '
        'a species this app does not know sends none', () async {
      harness.backend.on(
        'POST',
        '$_base/appointments',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.appointments.replay.post.201.json',
          status: 201,
        ),
      );

      final request = await repository.request(
        _lyon,
        _request(const NewPet('Capture', Species.unknown)),
        _key,
      );

      expect(request.id.value, '01a1a496-639e-7512-a3b9-e5c2596e2c3d');
      final body = jsonDecode(
        utf8.decode(
          harness.backend.requestsTo('$_base/appointments').single.body,
        ),
      ) as Map<String, Object?>;
      expect(
        (body['newPet']! as Map<String, Object?>).containsKey('species'),
        isFalse,
      );
    });

    test('a known pet: refused before any call', () async {
      expect(
        () => repository.request(
          _lyon,
          _request(const ExistingPet('p', 'Oslo')),
          _key,
        ),
        throwsArgumentError,
      );
      expect(harness.backend.requests, isEmpty);
    });

    for (final (fixture, status, matcher) in [
      (
        'slot-taken.post.409',
        409,
        isA<ConflictFailure>().having((f) => f.code, 'code', 'slot_taken'),
      ),
      (
        'already-linked.post.422',
        422,
        isA<BusinessFailure>().having((f) => f.code, 'code', 'already_linked'),
      ),
      (
        'limit.post.422',
        422,
        isA<BusinessFailure>().having(
          (f) => f.code,
          'code',
          'booking_request_limit',
        ),
      ),
      (
        'key-reused.post.422',
        422,
        isA<BusinessFailure>().having(
          (f) => f.code,
          'code',
          'idempotency_key_reused',
        ),
      ),
      (
        'validation.post.422',
        422,
        isA<ValidationFailure>().having(
          (f) => f.violations.single.propertyPath,
          'propertyPath',
          'newPet.name',
        ),
      ),
      (
        'key-missing.post.400',
        400,
        isA<BusinessFailure>().having(
          (f) => f.code,
          'code',
          'idempotency_key_missing',
        ),
      ),
    ]) {
      test('refused (capture $fixture)', () async {
        harness.backend.on(
          'POST',
          '$_base/appointments',
          PortalReply.fixture(
            'clinic-listings.lyon.booking.appointments.$fixture.json',
            status: status,
          ),
        );

        await expectLater(
          repository.request(_lyon, _request(_capture), _key),
          throwsA(matcher),
        );
      });
    }
  });

  group('requests', () {
    test('pending (capture), the first page of 50', () async {
      harness.backend.on(
        'GET',
        '$_requests?limit=50',
        PortalReply.fixture('me.booking-requests.pending.get.200.json'),
      );

      final page = await repository.requests(limit: 50);

      expect(page.nextCursor, isNull);
      final request = page.items.single;
      expect(request.status, AppointmentRequestStatus.pending);
      expect(request.petName, 'Capture');
    });

    test('declined (capture): expired, declined', () async {
      harness.backend.on(
        'GET',
        _requests,
        PortalReply.fixture('me.booking-requests.declined.get.200.json'),
      );

      final page = await repository.requests();

      expect(page.items.map((request) => request.declineReason), [
        DeclineReason.expired,
        DeclineReason.declined,
        DeclineReason.expired,
      ]);
      expect(
        page.items.every(
          (request) => request.status == AppointmentRequestStatus.declined,
        ),
        isTrue,
      );
      expect(page.items.first.petSpecies, Species.cat);
    });

    test('confirmed (capture): its appointment; none (capture)', () async {
      harness.backend.on(
        'GET',
        _requests,
        PortalReply.fixture('me.booking-requests.confirmed.get.200.json'),
      );
      final confirmed = (await repository.requests()).items.single;
      expect(confirmed.status, AppointmentRequestStatus.confirmed);
      expect(
        confirmed.appointmentId,
        const AppointmentId('01a19a12-9db0-7703-80f3-d1f2f41e32e5'),
      );
      expect(confirmed.petSpecies, Species.dog);

      harness.backend.on(
        'GET',
        _requests,
        PortalReply.fixture('me.booking-requests.get.200.json'),
      );
      expect((await repository.requests()).items, isEmpty);
    });

    test('a status, a reason and a species this app does not know; no pet '
        'name nor species; a next page', () async {
      harness.backend.on(
        'GET',
        '$_requests?cursor=c',
        _edited('me.booking-requests.declined.get.200.json', (body) {
          final map = body! as Map<String, Object?>;
          map['nextCursor'] = 'next';
          final items = map['items']! as List<Object?>;
          (items[0]! as Map<String, Object?>)['status'] = 'archived';
          (items[1]! as Map<String, Object?>)
            ..['declineReason'] = 'clinic_closed'
            ..['pet'] = {'name': null, 'species': null};
          (items[2]! as Map<String, Object?>)['declineReason'] =
              'account_deleted';
          ((items[2]! as Map<String, Object?>)['pet']!
                  as Map<String, Object?>)['species'] =
              'bird';
        }),
      );

      final page = await repository.requests(cursor: 'c');

      expect(page.nextCursor, 'next');
      final [first, second, third] = page.items;
      expect(first.status, AppointmentRequestStatus.unknown);
      expect(second.declineReason, DeclineReason.unknown);
      expect(second.petName, isNull);
      expect(second.petSpecies, isNull);
      expect(third.declineReason, DeclineReason.accountDeleted);
      expect(third.petSpecies, Species.unknown);
    });

    test('signed out: an UnauthorizedFailure', () async {
      harness.backend.on('GET', _requests, problem('unauthorized', 401));
      await harness.session.signOut();

      await expectLater(
        repository.requests(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });
}
