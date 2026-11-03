// PortalSchedulingRepository on the real chain and the live captures of
// 2026-11-03: the motifs (with and without a pet), the practitioners, the
// availability windows, the bookings (a known pet, a new pet, pending, a
// replay) with their bodies and Idempotency-Key, the lists (upcoming, past
// page after page), one appointment, the reschedule, the cancellation, the
// .ics; every enum of the contract (unknown kept), the six appointment
// views through one mapper, and the failures (404, 409, 422, 400, none).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_scheduling_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _paris = ClinicId(_parisId);
const _lyon = ClinicId('01960000-0000-7000-8000-000000000101');
const _oslo = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _consultation = MotifId('01a19a10-d467-7bc2-9344-790c64b6ab03');
const _vaccination = MotifId('01a19a10-d47d-7781-87b0-627f2e3b5819');
const _dupont = PractitionerId('01a19a0e-23cd-70de-a551-46681e052884');
const _rousseau = PractitionerId('01a19a0e-1afe-7116-ad21-672cf69c5366');
const _booked = AppointmentId('01a1a297-4a0a-7093-83f7-14de2798613e');
const _base = '$api/clinics/$_parisId';
const _key = IdempotencyKey('booking-intent-1');

/// The capture [fixture] with [change] applied to its JSON body.
PortalReply _edited(
  String fixture,
  void Function(Object? body) change, {
  int status = 200,
}) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body), status: status);
}

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

BookingRequest _request(BookingPet pet, {String at = '2026-11-09T10:00'}) =>
    BookingRequest(
      pet: pet,
      motifId: _consultation,
      practitionerId: _dupont,
      startAt: ClinicInstant.parse('$at:00+01:00'),
    );

void main() {
  late PortalHarness harness;
  late PortalSchedulingRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalSchedulingRepository(
      harness.http.server,
      harness.failures,
    );
  });

  group('motifs', () {
    test("Paris for Oslo (capture): in the clinic's order, none suggested, "
        'petId sent', () async {
      harness.backend.on(
        'GET',
        '$_base/booking/motifs?petId=$_oslo',
        PortalReply.fixture('clinics.paris.booking.motifs.get.200.json'),
      );

      final motifs = await repository.motifs(_paris, petId: _oslo);

      expect(motifs.map((motif) => motif.label), [
        'Consultation',
        'Vaccination',
        'Contrôle / suivi',
      ]);
      final consultation = motifs.first;
      expect(consultation.id, _consultation);
      expect(consultation.durationMin, 30);
      expect(
        consultation.description,
        'Un problème de santé, un avis, un contrôle de routine.',
      );
      expect(consultation.suggested, isFalse);
      expect(consultation.suggestionReason, isNull);
      expect(motifs.map((motif) => motif.durationMin), [30, 20, 20]);
    });

    test('Lyon for a new pet (capture): no petId in the query', () async {
      harness.backend.on(
        'GET',
        '$api/clinics/${_lyon.value}/booking/motifs',
        PortalReply.fixture('clinics.lyon.booking.motifs.get.200.json'),
      );

      final motifs = await repository.motifs(_lyon);

      expect(motifs, hasLength(3));
      expect(
        harness.backend.requests.single.pathWithQuery,
        '$api/clinics/${_lyon.value}/booking/motifs',
      );
    });

    test('a suggested motif, its reason; no description', () async {
      harness.backend.on(
        'GET',
        '$_base/booking/motifs?petId=$_oslo',
        _edited('clinics.paris.booking.motifs.get.200.json', (body) {
          final vaccination =
              (body! as List<Object?>)[1]! as Map<String, Object?>;
          vaccination['suggested'] = true;
          vaccination['suggestionReason'] = 'Rappel de vaccin à prévoir';
          vaccination['description'] = null;
        }),
      );

      final vaccination = (await repository.motifs(_paris, petId: _oslo))[1];

      expect(vaccination.suggested, isTrue);
      expect(vaccination.suggestionReason, 'Rappel de vaccin à prévoir');
      expect(vaccination.description, isNull);
    });

    test('booking closed (422 booking_not_open): a BusinessFailure', () async {
      harness.backend.on(
        'GET',
        '$_base/booking/motifs',
        problem('booking_not_open', 422),
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
    });
  });

  test(
    'practitioners (capture): Dupont and Rousseau; a nameless one',
    () async {
      harness.backend
        ..on(
          'GET',
          '$_base/booking/practitioners?motifId=${_consultation.value}',
          PortalReply.fixture(
            'clinics.paris.booking.practitioners.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$_base/booking/practitioners?motifId=${_vaccination.value}',
          PortalReply.json('[{"id":"${_rousseau.value}","displayName":null}]'),
        );

      final practitioners = await repository.practitioners(
        _paris,
        _consultation,
      );
      final nameless = await repository.practitioners(_paris, _vaccination);

      expect(practitioners.map((practitioner) => practitioner.id), [
        _dupont,
        _rousseau,
      ]);
      expect(practitioners.map((practitioner) => practitioner.displayName), [
        'Dr Marc Dupont',
        'Dr Éric Rousseau',
      ]);
      expect(nameless.single.displayName, isNull);
      await expectLater(
        repository.practitioners(_lyon, _consultation),
        throwsA(isA<NetworkFailure>()),
      );
    },
  );

  group('availability', () {
    const query =
        '$_base/booking/availability?motifId=01a19a10-d467-7bc2-9344-790c64b6ab03'
        '&practitionerId=01a19a0e-23cd-70de-a551-46681e052884';

    test('14 days from the 3rd (capture): open and closed days, the slots '
        'with their offset', () async {
      harness.backend.on(
        'GET',
        '$query&from=2026-11-03&to=2026-11-16',
        PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
      );

      final days = await repository.availability(
        _paris,
        _consultation,
        _dupont,
        LocalDate(2026, 11, 3),
        LocalDate(2026, 11, 16),
      );

      expect(days, hasLength(14));
      expect(days.first.date, LocalDate(2026, 11, 3));
      expect(days.first.open, isTrue);
      expect(days.first.slots, isEmpty);
      expect(days[2].slots, [ClinicInstant.parse('2026-11-05T16:30:00+01:00')]);
      expect(days[2].slots.single.offset, const Duration(hours: 1));
      expect(days[5].date, LocalDate(2026, 11, 8));
      expect(days[5].open, isFalse);
      expect(days[6].slots, hasLength(26));
      expect(days.last.date, LocalDate(2026, 11, 16));
    });

    test('the next window (capture)', () async {
      harness.backend.on(
        'GET',
        '$query&from=2026-11-17&to=2026-11-30',
        PortalReply.fixture(
          'clinics.paris.booking.availability.next.get.200.json',
        ),
      );

      final days = await repository.availability(
        _paris,
        _consultation,
        _dupont,
        LocalDate(2026, 11, 17),
        LocalDate(2026, 11, 30),
      );

      expect(days.first.date, LocalDate(2026, 11, 17));
      expect(
        days.first.slots.first.toIso8601String(),
        '2026-11-17T09:00:00+01:00',
      );
      expect(days.last.date, LocalDate(2026, 11, 30));
    });

    test('a past start or a too long window (captures): a '
        'ValidationFailure naming the field', () async {
      harness.backend
        ..on(
          'GET',
          '$query&from=2026-11-02&to=2026-11-15',
          PortalReply.fixture(
            'clinics.paris.booking.availability.past.get.422.json',
            status: 422,
          ),
        )
        ..on(
          'GET',
          '$query&from=2026-11-03&to=2026-11-30',
          PortalReply.fixture(
            'clinics.paris.booking.availability.too-long.get.422.json',
            status: 422,
          ),
        );

      await expectLater(
        repository.availability(
          _paris,
          _consultation,
          _dupont,
          LocalDate(2026, 11, 2),
          LocalDate(2026, 11, 15),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.propertyPath,
            'propertyPath',
            'from',
          ),
        ),
      );
      await expectLater(
        repository.availability(
          _paris,
          _consultation,
          _dupont,
          LocalDate(2026, 11, 3),
          LocalDate(2026, 11, 30),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.propertyPath,
            'propertyPath',
            'to',
          ),
        ),
      );
    });
  });

  group('book', () {
    test("Oslo (capture): the body with the slot's wire startAt, the "
        'Idempotency-Key, the appointment', () async {
      harness.backend.on(
        'POST',
        '$_base/appointments',
        PortalReply.fixture(
          'clinics.paris.appointments.post.201.json',
          status: 201,
        ),
      );

      final appointment = await repository.book(
        _paris,
        _request(const ExistingPet(_oslo, 'Oslo')),
        _key,
      );

      final request = harness.backend.requests.single;
      expect(request.headers['Idempotency-Key'], 'booking-intent-1');
      expect(
        utf8.decode(request.body),
        '{"petId":"$_oslo","motifId":"${_consultation.value}",'
        '"practitionerId":"${_dupont.value}",'
        '"startAt":"2026-11-09T10:00:00+01:00"}',
      );
      expect(appointment.id, _booked);
      expect(
        appointment.startAt.toIso8601String(),
        '2026-11-09T10:00:00+01:00',
      );
      expect(appointment.durationMinutes, 30);
      expect(appointment.petId, _oslo);
      expect(appointment.petName, 'Oslo');
      expect(appointment.motifId, _consultation);
      expect(appointment.motifLabel, 'Consultation');
      expect(appointment.practitionerId, _dupont);
      expect(appointment.practitionerName, 'Dr Marc Dupont');
      expect(appointment.status, AppointmentStatus.confirmed);
      expect(appointment.source, AppointmentSource.portal);
      expect(
        appointment.cancellableUntil?.toIso8601String(),
        '2026-11-08T10:00:00+01:00',
      );
      expect(appointment.questionnaire, QuestionnaireStatus.notStarted);
      expect(appointment.relatedCareItem, isNull);
    });

    test('a replay (capture, other key order and spaces): the same '
        'appointment', () async {
      harness.backend.on(
        'POST',
        '$_base/appointments',
        PortalReply.fixture(
          'clinics.paris.appointments.replay.post.201.json',
          status: 201,
        ),
      );

      final replay = await repository.book(
        _paris,
        _request(const ExistingPet(_oslo, 'Oslo')),
        _key,
      );

      expect(replay.id, _booked);
      expect(replay.startAt.toIso8601String(), '2026-11-09T10:00:00+01:00');
      expect(replay.status, AppointmentStatus.confirmed);
    });

    test('a motif the clinic confirms (capture): pending', () async {
      harness.backend.on(
        'POST',
        '$_base/appointments',
        PortalReply.fixture(
          'clinics.paris.appointments.pending.post.201.json',
          status: 201,
        ),
      );

      final pending = await repository.book(
        _paris,
        _request(const ExistingPet(_oslo, 'Oslo'), at: '2026-11-13T09:00'),
        _key,
      );

      expect(pending.status, AppointmentStatus.pendingClinicConfirmation);
      expect(pending.isPending, isTrue);
      expect(pending.practitionerName, 'Dr Éric Rousseau');
    });

    test('a new pet (capture): with-new-pet, its name and species', () async {
      harness.backend.on(
        'POST',
        '$_base/appointments/with-new-pet',
        PortalReply.fixture(
          'clinics.paris.appointments.with-new-pet.post.201.json',
          status: 201,
        ),
      );

      final appointment = await repository.book(
        _paris,
        _request(const NewPet('Plume', Species.cat)),
        _key,
      );

      final request = harness.backend.requests.single;
      expect(request.headers['Idempotency-Key'], 'booking-intent-1');
      expect(
        utf8.decode(request.body),
        '{"newPet":{"name":"Plume","species":"cat"},'
        '"motifId":"${_consultation.value}",'
        '"practitionerId":"${_dupont.value}",'
        '"startAt":"2026-11-09T10:00:00+01:00"}',
      );
      expect(appointment.petName, 'Plume');
      expect(appointment.petId, '01a1a299-610a-7b88-a603-b3c27ddde688');
      expect(appointment.motifLabel, 'Vaccination');
    });

    test('every species of a new pet; none sent for an unknown one', () async {
      final sent = <Object?>[];
      harness.backend.onRequest('POST', '$_base/appointments/with-new-pet', (
        request,
      ) {
        sent.add(
          (_jsonOf(request)['newPet']! as Map<String, Object?>)['species'],
        );
        return PortalReply.fixture(
          'clinics.paris.appointments.with-new-pet.post.201.json',
          status: 201,
        );
      });

      for (final species in Species.values) {
        await repository.book(_paris, _request(NewPet('Plume', species)), _key);
      }

      expect(sent, ['dog', 'cat', 'nac', 'other', null]);
    });

    test('the failures (captures): slot taken, key reused, new pet '
        'refused', () async {
      harness.backend
        ..on(
          'POST',
          '$_base/appointments',
          PortalReply.fixture(
            'clinics.paris.appointments.slot-taken.post.409.json',
            status: 409,
          ),
        )
        ..on(
          'POST',
          '$_base/appointments/with-new-pet',
          PortalReply.fixture(
            'clinics.paris.appointments.with-new-pet.validation.post.422.json',
            status: 422,
          ),
        );

      await expectLater(
        repository.book(
          _paris,
          _request(const ExistingPet(_oslo, 'Oslo')),
          _key,
        ),
        throwsA(
          isA<ConflictFailure>().having(
            (failure) => failure.code,
            'code',
            'slot_taken',
          ),
        ),
      );
      await expectLater(
        repository.book(_paris, _request(const NewPet('', Species.cat)), _key),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.propertyPath,
            'propertyPath',
            'newPet.name',
          ),
        ),
      );

      harness.backend.on(
        'POST',
        '$_base/appointments',
        PortalReply.fixture(
          'clinics.paris.appointments.key-reused.post.422.json',
          status: 422,
        ),
      );
      await expectLater(
        repository.book(
          _paris,
          _request(const ExistingPet(_oslo, 'Oslo')),
          _key,
        ),
        throwsA(
          isA<BusinessFailure>().having(
            (failure) => failure.code,
            'code',
            'idempotency_key_reused',
          ),
        ),
      );
    });
  });

  group('appointments', () {
    test('upcoming (capture): a clinic booking without motif id, two portal '
        'ones; scope sent, no limit', () async {
      harness.backend.on(
        'GET',
        '$_base/appointments?scope=upcoming',
        PortalReply.fixture(
          'clinics.paris.appointments.upcoming.booked.get.200.json',
        ),
      );

      final page = await repository.appointments(
        _paris,
        AppointmentScope.upcoming,
      );

      expect(page.nextCursor, isNull);
      expect(page.items, hasLength(3));
      final clinicBooked = page.items.first;
      expect(clinicBooked.source, AppointmentSource.clinic);
      expect(clinicBooked.motifId, isNull);
      expect(clinicBooked.motifLabel, 'Rendez-vous');
      expect(clinicBooked.questionnaire, QuestionnaireStatus.submitted);
      expect(
        clinicBooked.startAt.toIso8601String(),
        '2026-11-11T10:30:00+01:00',
      );
      expect(page.items[1].id, _booked);
      expect(page.items[1].source, AppointmentSource.portal);
      expect(page.items[1].questionnaire, QuestionnaireStatus.notStarted);
    });

    test('past, page after page (captures): the cursor sent back', () async {
      final first = jsonDecode(
        File(
          '$portalFixtures/clinics.paris.appointments.past.page1.get.200.json',
        ).readAsStringSync(),
      ) as Map<String, Object?>;
      final cursor = first['nextCursor']! as String;
      harness.backend
        ..on(
          'GET',
          '$_base/appointments?scope=past',
          PortalReply.fixture(
            'clinics.paris.appointments.past.page1.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$_base/appointments?scope=past&cursor=$cursor',
          PortalReply.fixture(
            'clinics.paris.appointments.past.page2.get.200.json',
          ),
        );

      final page1 = await repository.appointments(
        _paris,
        AppointmentScope.past,
      );
      final page2 = await repository.appointments(
        _paris,
        AppointmentScope.past,
        cursor: page1.nextCursor,
      );

      expect(page1.nextCursor, cursor);
      expect(page1.items.map((item) => item.status), [
        AppointmentStatus.cancelledByClient,
        AppointmentStatus.cancelledByClient,
      ]);
      expect(page1.items.first.cancellableUntil, isNull);
      expect(page2.items.single.status, AppointmentStatus.cancelledByClinic);
      expect(page2.nextCursor, isNull);
    });

    test('the older captures of both scopes', () async {
      harness.backend
        ..on(
          'GET',
          '$_base/appointments?scope=upcoming',
          PortalReply.fixture(
            'clinics.paris.appointments.upcoming.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$_base/appointments?scope=past',
          PortalReply.fixture('clinics.paris.appointments.past.get.200.json'),
        )
        ..on(
          'GET',
          '$api/clinics/${_lyon.value}/appointments?scope=upcoming',
          PortalReply.fixture(
            'clinics.lyon.appointments.upcoming.get.200.json',
          ),
        );

      expect(
        (await repository.appointments(
          _paris,
          AppointmentScope.upcoming,
        )).items,
        hasLength(2),
      );
      expect(
        (await repository.appointments(_paris, AppointmentScope.past)).items,
        hasLength(1),
      );
      expect(
        (await repository.appointments(
          _lyon,
          AppointmentScope.upcoming,
        )).nextCursor,
        isNull,
      );
    });

    test('every status, source and questionnaire status; unknown kept; no '
        'pet, no practitioner name', () async {
      const statuses = [
        'confirmed',
        'pending_clinic_confirmation',
        'cancelled_by_client',
        'cancelled_by_clinic',
        'declined',
        'completed',
        'no_show',
        'archived',
      ];
      harness.backend.on(
        'GET',
        '$_base/appointments?scope=past',
        _edited('clinics.paris.appointments.past.page2.get.200.json', (body) {
          final map = body! as Map<String, Object?>;
          final item =
              (map['items']! as List<Object?>).single! as Map<String, Object?>;
          map['items'] = [
            for (final (index, status) in statuses.indexed)
              {
                ...item,
                'status': status,
                'source': index == 0 ? 'kiosk' : item['source'],
                'questionnaireStatus': index == 0
                    ? 'draft'
                    : item['questionnaireStatus'],
                'pet': index == 0 ? null : item['pet'],
                'practitioner': index == 0
                    ? {'id': 'x', 'displayName': null}
                    : item['practitioner'],
              },
          ];
        }),
      );

      final items = (await repository.appointments(
        _paris,
        AppointmentScope.past,
      )).items;

      expect(items.map((item) => item.status), [
        AppointmentStatus.confirmed,
        AppointmentStatus.pendingClinicConfirmation,
        AppointmentStatus.cancelledByClient,
        AppointmentStatus.cancelledByClinic,
        AppointmentStatus.declined,
        AppointmentStatus.completed,
        AppointmentStatus.noShow,
        AppointmentStatus.unknown,
      ]);
      expect(items.first.source, AppointmentSource.unknown);
      expect(items.first.questionnaire, QuestionnaireStatus.unknown);
      expect(items.first.petId, isNull);
      expect(items.first.petName, isNull);
      expect(items.first.practitionerId, const PractitionerId('x'));
      expect(items.first.practitionerName, isNull);
    });

    test(
      'the failures: 400 cursor_invalid, 404 clinic gone, no answer',
      () async {
        harness.backend
          ..on(
            'GET',
            '$_base/appointments?scope=past&cursor=stale',
            problem('cursor_invalid', 400),
          )
          ..on(
            'GET',
            '$_base/appointments?scope=upcoming',
            PortalReply.fixture(
              'clinics.unknown.home.get.404.json',
              status: 404,
            ),
          );

        await expectLater(
          repository.appointments(
            _paris,
            AppointmentScope.past,
            cursor: 'stale',
          ),
          throwsA(
            isA<BusinessFailure>().having(
              (failure) => failure.code,
              'code',
              'cursor_invalid',
            ),
          ),
        );
        await expectLater(
          repository.appointments(_paris, AppointmentScope.upcoming),
          throwsA(isA<NotFoundFailure>()),
        );
        await expectLater(
          repository.appointments(_lyon, AppointmentScope.upcoming),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });

  group('appointment', () {
    test('one (capture), then one with the care item its motif covers '
        '(capture); every care status', () async {
      harness.backend
        ..on(
          'GET',
          '$_base/appointments/${_booked.value}',
          PortalReply.fixture('clinics.paris.appointment.get.200.json'),
        )
        ..on(
          'GET',
          '$_base/appointments/related',
          PortalReply.fixture(
            'clinics.paris.appointment.related-care.get.200.json',
          ),
        );

      final appointment = await repository.appointment(_paris, _booked);
      final related = await repository.appointment(
        _paris,
        const AppointmentId('related'),
      );

      expect(
        appointment.startAt.toIso8601String(),
        '2026-11-09T10:00:00+01:00',
      );
      expect(appointment.relatedCareItem, isNull);
      final care = related.relatedCareItem!;
      expect(care.kind, 'vaccination');
      expect(care.label, 'CHPL');
      expect(care.dueOn, LocalDate(2027, 9, 5));
      expect(care.status, CareStatus.booked);
      expect(related.motifLabel, 'Vaccination');

      final statuses = <CareStatus>[];
      for (final status in ['overdue', 'due_soon', 'up_to_date', 'archived']) {
        harness.backend.on(
          'GET',
          '$_base/appointments/related',
          _edited('clinics.paris.appointment.related-care.get.200.json', (
            body,
          ) {
            ((body! as Map<String, Object?>)['relatedCareItem']!
                    as Map<String, Object?>)['status'] =
                status;
          }),
        );
        statuses.add(
          (await repository.appointment(
            _paris,
            const AppointmentId('related'),
          )).relatedCareItem!.status,
        );
      }
      expect(statuses, [
        CareStatus.overdue,
        CareStatus.dueSoon,
        CareStatus.upToDate,
        CareStatus.unknown,
      ]);
    });

    test('404 (capture): a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        '$_base/appointments/gone',
        PortalReply.fixture(
          'clinics.paris.appointment.not-found.get.404.json',
          status: 404,
        ),
      );

      await expectLater(
        repository.appointment(_paris, const AppointmentId('gone')),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('reschedule', () {
    const path =
        '$_base/appointments/01a1a297-4a0a-7093-83f7-14de2798613e'
        '/reschedule';

    test('(capture): the body, the moved appointment', () async {
      harness.backend.on(
        'POST',
        path,
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.post.200.json',
        ),
      );

      final moved = await repository.reschedule(
        _paris,
        _booked,
        startAt: ClinicInstant.parse('2026-11-11T10:30:00+01:00'),
        practitionerId: _dupont,
      );

      expect(
        utf8.decode(harness.backend.requests.single.body),
        '{"startAt":"2026-11-11T10:30:00+01:00",'
        '"practitionerId":"${_dupont.value}"}',
      );
      expect(moved.startAt.toIso8601String(), '2026-11-11T10:30:00+01:00');
      expect(
        moved.cancellableUntil?.toIso8601String(),
        '2026-11-10T10:30:00+01:00',
      );
    });

    test('the failures (captures): slot taken, not modifiable', () async {
      harness.backend.on(
        'POST',
        path,
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.slot-taken.post.409.json',
          status: 409,
        ),
      );
      final startAt = ClinicInstant.parse('2026-11-11T10:30:00+01:00');

      await expectLater(
        repository.reschedule(
          _paris,
          _booked,
          startAt: startAt,
          practitionerId: _dupont,
        ),
        throwsA(
          isA<ConflictFailure>().having(
            (failure) => failure.code,
            'code',
            'slot_taken',
          ),
        ),
      );

      harness.backend.on(
        'POST',
        path,
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.not-modifiable.post.422.json',
          status: 422,
        ),
      );
      await expectLater(
        repository.reschedule(
          _paris,
          _booked,
          startAt: startAt,
          practitionerId: _dupont,
        ),
        throwsA(
          isA<BusinessFailure>().having(
            (failure) => failure.code,
            'code',
            'appointment_not_modifiable',
          ),
        ),
      );
    });
  });

  group('cancel', () {
    const path =
        '$_base/appointments/01a1a297-4a0a-7093-83f7-14de2798613e'
        '/cancel';

    test('(capture): every reason sent, the cancelled appointment', () async {
      final reasons = <Object?>[];
      harness.backend.onRequest('POST', path, (request) {
        reasons.add(_jsonOf(request)['reason']);
        return PortalReply.fixture(
          'clinics.paris.appointment.cancel.post.200.json',
        );
      });

      final cancelled = [
        for (final reason in CancellationReason.values)
          await repository.cancel(_paris, _booked, reason),
      ];

      expect(reasons, [
        'unavailable',
        'no_longer_needed',
        'seen_elsewhere',
        'other',
      ]);
      expect(cancelled.first.status, AppointmentStatus.cancelledByClient);
      expect(cancelled.first.cancellableUntil, isNull);
    });

    test('422 (capture): a ValidationFailure on the reason', () async {
      harness.backend.on(
        'POST',
        path,
        PortalReply.fixture(
          'clinics.paris.appointment.cancel.validation.post.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.cancel(_paris, _booked, CancellationReason.other),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.message,
            'message',
            "Motif d'annulation obligatoire.",
          ),
        ),
      );
    });
  });

  test('the five other views keep a value this app does not know '
      '(status, source, questionnaire, care status) and their nulls', () async {
    void unknown(Object? body) {
      final map = body! as Map<String, Object?>;
      map['status'] = 'archived';
      map['source'] = 'kiosk';
      map['questionnaireStatus'] = 'draft';
      map['pet'] = null;
      map['relatedCareItem'] = {
        'kind': 'dental',
        'label': 'Détartrage',
        'dueOn': '2027-01-10',
        'status': 'planned',
      };
    }

    const appointment =
        '$_base/appointments/01a1a297-4a0a-7093-83f7-14de2798613e';
    harness.backend
      ..on(
        'POST',
        '$_base/appointments',
        _edited(
          'clinics.paris.appointments.post.201.json',
          unknown,
          status: 201,
        ),
      )
      ..on(
        'POST',
        '$_base/appointments/with-new-pet',
        _edited(
          'clinics.paris.appointments.with-new-pet.post.201.json',
          unknown,
          status: 201,
        ),
      )
      ..on(
        'GET',
        appointment,
        _edited('clinics.paris.appointment.get.200.json', unknown),
      )
      ..on(
        'POST',
        '$appointment/reschedule',
        _edited('clinics.paris.appointment.reschedule.post.200.json', unknown),
      )
      ..on(
        'POST',
        '$appointment/cancel',
        _edited('clinics.paris.appointment.cancel.post.200.json', unknown),
      );
    final startAt = ClinicInstant.parse('2026-11-11T10:30:00+01:00');

    final views = [
      await repository.book(
        _paris,
        _request(const ExistingPet(_oslo, 'Oslo')),
        _key,
      ),
      await repository.book(
        _paris,
        _request(const NewPet('Plume', Species.cat)),
        _key,
      ),
      await repository.appointment(_paris, _booked),
      await repository.reschedule(
        _paris,
        _booked,
        startAt: startAt,
        practitionerId: _dupont,
      ),
      await repository.cancel(_paris, _booked, CancellationReason.other),
    ];

    for (final view in views) {
      expect(view.status, AppointmentStatus.unknown);
      expect(view.source, AppointmentSource.unknown);
      expect(view.questionnaire, QuestionnaireStatus.unknown);
      expect(view.petId, isNull);
      expect(view.petName, isNull);
      expect(view.relatedCareItem?.kind, 'dental');
      expect(view.relatedCareItem?.status, CareStatus.unknown);
      expect(view.relatedCareItem?.dueOn, LocalDate(2027, 1, 10));
    }
  });

  group('calendar', () {
    const path =
        '$_base/appointments/01a1a297-4a0a-7093-83f7-14de2798613e'
        '/calendar.ics';

    test('(capture): the exact bytes, CRLF kept, as text/calendar', () async {
      final bytes = File(
        '$portalFixtures/clinics.paris.appointment.calendar.get.200.ics',
      ).readAsBytesSync();
      harness.backend.on(
        'GET',
        path,
        PortalReply.bytes(bytes, contentType: 'text/calendar; charset=utf-8'),
      );

      final file = await repository.calendar(_paris, _booked);

      expect(file.bytes, bytes);
      expect(utf8.decode(file.bytes), contains('\r\n'));
      expect(file.contentType, 'text/calendar');
      expect(file.fileName, 'rendez-vous.ics');
      expect(
        harness.backend.requests.single.headers['Accept'],
        'text/calendar',
      );
    });

    test('a cancelled appointment (capture): a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        path,
        PortalReply.fixture(
          'clinics.paris.appointment.calendar.cancelled.get.404.json',
          status: 404,
        ),
      );

      await expectLater(
        repository.calendar(_paris, _booked),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
