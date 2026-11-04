// The generated Portal API client (packages/kiveto_portal_api) on real
// responses of the backend: every contract fixture of
// test/support/fixtures/portal_api/ decodes through the generated API
// classes, on a real Dio whose adapter is the fake backend. Spot checks of
// what the app relies on: the clinic UTC offsets kept, `Date` for
// `YYYY-MM-DD`, non-null required fields, `null` kept where nullable, the
// errors as typed values, and the request lines the client sends.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../support/portal_api/fake_portal_backend.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _lyon = '01960000-0000-7000-8000-000000000101';
const _unknownClinic = '01900000-0000-7000-8000-000000000000';
const _oslo = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _api = '/api/portal/v1';

/// The decoded value of a successful call; fails with the client's error
/// otherwise (an unrouted request, a decoding failure).
T _value<T>(TonikResult<T, Response<Object?>> result) => switch (result) {
  TonikSuccess(:final value) => value,
  TonikError(:final error, :final type) => fail(
    'expected a decoded response, got TonikError($type): $error',
  ),
};

/// The 2xx-only `validateStatus` phase 5 sets first in its chain (tonik
/// accepts every status by default, so errors are values, never a
/// `DioException` an interceptor could see).
Interceptor _successOnly() => InterceptorsWrapper(
  onRequest: (options, handler) {
    options.validateStatus = (status) =>
        status != null && status >= 200 && status < 300;
    handler.next(options);
  },
);

void main() {
  late FakePortalBackend backend;
  late CustomServer server;

  setUp(() {
    backend = FakePortalBackend();
    server = portalServer(backend);
  });

  group('GET /me', () {
    test(
      'decodes the account and its clinics, offsets and nulls kept',
      () async {
        backend.on('GET', '$_api/me', PortalReply.fixture('me.get.200.json'));

        final result = await AccountApi(server).getMe();
        final me = switch (_value(result)) {
          GetMeResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };

        expect(me.account.id, '01a19a10-d011-70c8-8daf-26e4db824374');
        expect(me.account.firstName, 'Julien');
        expect(me.account.lastName, 'Girard');
        expect(me.account.email, isNull);
        expect(me.account.emailVerified, isFalse);
        expect(me.account.maskedPhone, '+33 6 •• •• •• 78');
        expect(me.account.address?.addressView, isNull);

        expect(me.clinics.map((clinic) => clinic.clinicId), [_paris, _lyon]);
        final paris = me.clinics.first;
        expect(paris.name, 'Clinique Vétérinaire de Paris');
        expect(paris.timezone, 'Europe/Paris');
        expect(paris.linkStatus, ClinicLinkViewLinkStatusModel.confirmed);
        expect(paris.petNames, ['Oslo']);
        expect(paris.tags, isEmpty);
        expect(paris.unreadDocuments, 1);
        expect(paris.phone, '+33142551890');
        final address = paris.address!.clinicAddressView!;
        expect(address.line, '18 rue des Abbesses');
        expect(address.postalCode, '75018');
        expect(address.city, 'Paris');
        expect(me.clinics.last.phone, '+33478920145');
        final linkedAt = paris.linkedAt!;
        expect(linkedAt.isUtc, isTrue);
        expect(linkedAt.timeZoneOffset, Duration.zero);
        expect(linkedAt, DateTime.utc(2026, 9, 2, 2, 22, 35));

        final request = backend.requests.single;
        expect(request.method, 'GET');
        expect(request.uri.toString(), 'http://portal.test$_api/me');
        expect(
          request.headers['Accept'],
          'application/json,application/problem+json',
        );
      },
    );

    test('401 problem+json is a typed value without body', () async {
      backend.on(
        'GET',
        '$_api/me',
        PortalReply.fixture('me.get.401.json', status: 401),
      );

      final result = await AccountApi(server).getMe();

      final response = switch (result) {
        TonikSuccess(value: GetMeResponse401(), :final response) => response,
        _ => fail('expected GetMeResponse401, got $result'),
      };
      expect(
        utf8.decode(response.data! as List<int>),
        contains('"type":"unauthorized"'),
      );
    });

    test('404 problem+json decodes as a typed ProblemDetails (the contract '
        'Error), missing nullable keys read as null', () async {
      // The real 404 body of an unknown clinic (no `detail`, no `instance`),
      // served on GET /me: the home 404 has no schema, the /me 404 is typed
      // with the same problem+json shape (the backend's error normaliser).
      backend.on(
        'GET',
        '$_api/me',
        PortalReply.fixture('clinics.unknown.home.get.404.json', status: 404),
      );

      final result = await AccountApi(server).getMe();

      final problem = switch (_value(result)) {
        GetMeResponse404(
          body: ApiPortalV1MeGet404ResponseProblemJson(:final body),
        ) =>
          body,
        final other => fail('unexpected $other'),
      };
      expect(problem.problemType, 'not_found');
      expect(problem.status, 404);
      expect(problem.title, 'Ressource introuvable.');
      expect(problem.detail, isNull);
      expect(problem.instance, isNull);
    });

    test('with a 2xx-only validateStatus, a 401 is a TonikError carrying the '
        'DioException', () async {
      backend.on(
        'GET',
        '$_api/me',
        PortalReply.fixture('me.get.401.json', status: 401),
      );
      server = portalServer(backend, interceptors: [_successOnly()]);

      final result = await AccountApi(server).getMe();

      final error = switch (result) {
        TonikError(:final error) => error,
        TonikSuccess() => fail('expected a TonikError, got $result'),
      };
      expect(error, isA<DioException>());
      final exception = error as DioException;
      expect(exception.type, DioExceptionType.badResponse);
      expect(exception.response?.statusCode, 401);
      expect(
        utf8.decode(exception.response!.data! as List<int>),
        contains('"type":"unauthorized"'),
      );
    });
  });

  group('the clinic routes of both clinics', () {
    for (final (clinic, name) in [(_paris, 'paris'), (_lyon, 'lyon')]) {
      test('$name: home, pets, upcoming appointments, documents', () async {
        final base = '$_api/clinics/$clinic';
        backend
          ..on(
            'GET',
            '$base/home',
            PortalReply.fixture('clinics.$name.home.get.200.json'),
          )
          ..on(
            'GET',
            '$base/pets',
            PortalReply.fixture('clinics.$name.pets.get.200.json'),
          )
          ..on(
            'GET',
            '$base/appointments?scope=upcoming',
            PortalReply.fixture(
              'clinics.$name.appointments.upcoming.get.200.json',
            ),
          )
          ..on(
            'GET',
            '$base/documents',
            PortalReply.fixture('clinics.$name.documents.get.200.json'),
          );

        final pets = PetsApi(server);
        final home = switch (_value(await pets.getHome(clinicId: clinic))) {
          GetHomeResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
        final petList = switch (_value(await pets.listPets(clinicId: clinic))) {
          ListPetsResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
        final appointments = switch (_value(
          // scope defaults to upcoming, sent as ?scope=upcoming.
          await SchedulingApi(server).listAppointments(clinicId: clinic),
        )) {
          ListAppointmentsResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
        final documents = switch (_value(
          await DocumentsApi(server).listDocuments(clinicId: clinic),
        )) {
          ListDocumentsResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };

        expect(backend.requests.map((request) => request.pathWithQuery), [
          '$base/home',
          '$base/pets',
          '$base/appointments?scope=upcoming',
          '$base/documents',
        ]);
        expect(home.pets, hasLength(1));
        expect(petList.single.id, home.pets.single.id);
        expect(appointments.nextCursor, isNull);
        expect(documents.nextCursor, isNull);

        if (clinic == _lyon) {
          expect(home.nextAppointment?.appointmentView, isNull);
          expect(home.careItems, isEmpty);
          expect(home.latestDocuments, isEmpty);
          expect(petList.single.name, 'Pixel');
          expect(petList.single.species, PetSummarySpeciesModel.cat);
          expect(petList.single.birthDate, Date(2022, 2, 11));
          expect(appointments.items, isEmpty);
          expect(documents.items, isEmpty);
          return;
        }

        // The next appointment keeps the clinic's wall clock and offset.
        final next = home.nextAppointment!.appointmentView!;
        expect(next.startAt.hour, 10);
        expect(next.startAt.minute, 30);
        expect(next.startAt.timeZoneOffset, const Duration(hours: 1));
        expect(next.startAt.isUtc, isFalse);
        expect(
          next.startAt.isAtSameMomentAs(DateTime.utc(2026, 11, 11, 9, 30)),
          isTrue,
        );
        // Round trips: toIso8601String() keeps the offset and adds the
        // milliseconds; the JSON encoding of the client has none.
        expect(next.startAt.toIso8601String(), '2026-11-11T10:30:00.000+01:00');
        expect(
          next.startAt.toTimeZonedIso8601String(),
          '2026-11-11T10:30:00+01:00',
        );
        expect(
          next.cancellableUntil?.toTimeZonedIso8601String(),
          '2026-11-10T10:30:00+01:00',
        );
        expect(next.status, AppointmentViewStatusModel.confirmed);
        expect(next.source, AppointmentViewSourceModel.clinic);
        expect(next.motif.id, isNull);
        expect(next.motif.label, 'Rendez-vous');
        expect(next.pet?.petReferenceView?.name, 'Oslo');
        expect(next.relatedCareItem?.relatedCareItemView, isNull);
        expect(next.practitioner.displayName, 'Dr Éric Rousseau');

        final oslo = home.pets.single;
        expect(oslo.id, _oslo);
        expect(oslo.birthDate, Date(2020, 3, 2));
        expect(oslo.birthDate.toString(), '2020-03-02');
        expect(oslo.species, PetSummarySpeciesModel.dog);
        expect(oslo.breed, 'Labrador');
        expect(home.careItems.map((item) => item.label), ['CHPL', 'Rage']);
        expect(home.careItems.first.dueOn, Date(2027, 9, 5));
        expect(home.latestDocuments, hasLength(2));

        expect(appointments.items.map((item) => item.source), [
          AppointmentViewSourceModel.clinic,
          AppointmentViewSourceModel.portal,
        ]);
        expect(
          appointments.items.last.questionnaireStatus,
          AppointmentViewQuestionnaireStatusModel.notStarted,
        );

        final invoice = documents.items.first;
        expect(invoice.kind, DocumentViewTypeModel.invoice);
        expect(invoice.title, 'Facture PAR-2026-000067');
        expect(invoice.petIds, [_oslo]);
        expect(invoice.unread, isTrue);
        expect(invoice.issuedAt.timeZoneOffset, const Duration(hours: 2));
        expect(
          invoice.issuedAt.toTimeZonedIso8601String(),
          '2026-10-24T09:40:00+02:00',
        );
        final summary = invoice.invoice!.invoiceSummaryView!;
        expect(summary.total.amount, 5200);
        expect(summary.total.currency, 'EUR');
        expect(
          summary.paymentStatus,
          InvoiceSummaryViewPaymentStatusModel.paid,
        );
        expect(invoice.prescription?.prescriptionSummaryView, isNull);
      });
    }

    test('404 problem+json on an unknown clinic is a typed value', () async {
      backend.on(
        'GET',
        '$_api/clinics/$_unknownClinic/home',
        PortalReply.fixture('clinics.unknown.home.get.404.json', status: 404),
      );

      final result = await PetsApi(server).getHome(clinicId: _unknownClinic);

      expect(_value(result), isA<GetHomeResponse404>());
    });
  });

  group('the other captured routes', () {
    test('past appointments, consents, requests of Paris', () async {
      const base = '$_api/clinics/$_paris';
      backend
        ..on(
          'GET',
          '$base/appointments?scope=past',
          PortalReply.fixture('clinics.paris.appointments.past.get.200.json'),
        )
        ..on(
          'GET',
          '$base/consents',
          PortalReply.fixture('clinics.paris.consents.get.200.json'),
        )
        ..on(
          'GET',
          '$base/requests',
          PortalReply.fixture('clinics.paris.requests.get.200.json'),
        );

      final past = switch (_value(
        await SchedulingApi(server).listAppointments(
          clinicId: _paris,
          scope: ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.past,
        ),
      )) {
        ListAppointmentsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final consents = switch (_value(
        await ConsentsApi(server).getConsents(clinicId: _paris),
      )) {
        GetConsentsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final requests = switch (_value(
        await RequestsApi(server).listRequests(clinicId: _paris),
      )) {
        ListRequestsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };

      final cancelled = past.items.single;
      expect(cancelled.status, AppointmentViewStatusModel.cancelledByClinic);
      expect(cancelled.cancellableUntil, isNull);

      expect(consents.preferredChannel, ConsentsPreferredChannelModel.sms);
      expect(consents.consents, hasLength(5));
      expect(
        consents.consents.first.kind,
        ConsentViewKindModel.appointmentReminders,
      );
      expect(consents.consents.first.grantedAt?.isUtc, isTrue);

      final change = requests.items.single;
      expect(change.kind, PortalRequestViewKindModel.petChange);
      expect(change.field, PortalRequestViewFieldModel.weight);
      expect(change.proposedValue, '25,1');
      expect(change.resolvedAt, isNull);
      expect(
        change.submittedAt.toTimeZonedIso8601String(),
        '2026-11-02T03:24:30+01:00',
      );
      expect(requests.nextCursor, isNull);
    });

    test('booking requests, data exports, link suggestions of /me', () async {
      backend
        ..on(
          'GET',
          '$_api/me/booking-requests',
          PortalReply.fixture('me.booking-requests.get.200.json'),
        )
        ..on(
          'GET',
          '$_api/me/data-exports',
          PortalReply.fixture('me.data-exports.get.200.json'),
        )
        ..on(
          'GET',
          '$_api/me/link-suggestions',
          PortalReply.fixture('me.link-suggestions.get.200.json'),
        );
      final account = AccountApi(server);

      final bookings = switch (_value(await account.listBookingRequests())) {
        ListBookingRequestsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final exports = switch (_value(await account.listDataExports())) {
        ListDataExportsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final suggestions = switch (_value(await account.listLinkSuggestions())) {
        ListLinkSuggestionsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };

      expect(bookings.items, isEmpty);
      expect(bookings.nextCursor, isNull);
      expect(exports, isEmpty);
      final suggestion = suggestions.single;
      expect(suggestion.clinic.name, 'Clinique Vétérinaire de Paris');
      expect(suggestion.clinic.city, 'Paris');
      expect(
        suggestion.matchedOn,
        LinkSuggestionsLinkSuggestionViewMatchedOnModel.phone,
      );
    });
  });

  group('the scheduling captures (slice 4)', () {
    const base = '$_api/clinics/$_paris';
    const consultation = '01a19a10-d467-7bc2-9344-790c64b6ab03';
    const dupont = '01a19a0e-23cd-70de-a551-46681e052884';
    const booked = '01a1a297-4a0a-7093-83f7-14de2798613e';
    const availability =
        '$base/booking/availability?motifId=$consultation'
        '&practitionerId=$dupont';

    test('motifs, practitioners, availability windows; the 422 of a past '
        'or too long window are typed values', () async {
      final scheduling = SchedulingApi(server);
      backend
        ..on(
          'GET',
          '$base/booking/motifs?petId=$_oslo',
          PortalReply.fixture('clinics.paris.booking.motifs.get.200.json'),
        )
        ..on(
          'GET',
          '$_api/clinics/$_lyon/booking/motifs',
          PortalReply.fixture('clinics.lyon.booking.motifs.get.200.json'),
        )
        ..on(
          'GET',
          '$base/booking/practitioners?motifId=$consultation',
          PortalReply.fixture(
            'clinics.paris.booking.practitioners.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$availability&from=2026-11-03&to=2026-11-16',
          PortalReply.fixture(
            'clinics.paris.booking.availability.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$availability&from=2026-11-17&to=2026-11-30',
          PortalReply.fixture(
            'clinics.paris.booking.availability.next.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$availability&from=2026-11-02&to=2026-11-15',
          PortalReply.fixture(
            'clinics.paris.booking.availability.past.get.422.json',
            status: 422,
          ),
        )
        ..on(
          'GET',
          '$availability&from=2026-11-03&to=2026-11-30',
          PortalReply.fixture(
            'clinics.paris.booking.availability.too-long.get.422.json',
            status: 422,
          ),
        );

      final paris = switch (_value(
        await scheduling.listMotifs(clinicId: _paris, petId: _oslo),
      )) {
        ListMotifsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final lyon = switch (_value(
        await scheduling.listMotifs(clinicId: _lyon),
      )) {
        ListMotifsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final practitioners = switch (_value(
        await scheduling.listPractitioners(
          clinicId: _paris,
          motifId: consultation,
        ),
      )) {
        ListPractitionersResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      Future<GetAvailabilityResponse> window(Date from, Date to) async {
        final result = await scheduling.getAvailability(
          clinicId: _paris,
          motifId: consultation,
          practitionerId: dupont,
          from: from,
          to: to,
        );
        // A local: the return context would infer a FutureOr.
        final value = _value(result);
        return value;
      }

      final first = switch (await window(
        Date(2026, 11, 3),
        Date(2026, 11, 16),
      )) {
        GetAvailabilityResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final next = switch (await window(
        Date(2026, 11, 17),
        Date(2026, 11, 30),
      )) {
        GetAvailabilityResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };

      expect(paris.map((motif) => motif.label), [
        'Consultation',
        'Vaccination',
        'Contrôle / suivi',
      ]);
      expect(paris.first.suggestionReason, isNull);
      expect(lyon, hasLength(3));
      expect(practitioners.first.displayName, 'Dr Marc Dupont');
      expect(first.days, hasLength(14));
      expect(first.days.first.date, Date(2026, 11, 3));
      expect(first.days[5].open, isFalse);
      expect(
        first.days[2].slots.single.startAt.toTimeZonedIso8601String(),
        '2026-11-05T16:30:00+01:00',
      );
      expect(next.days.first.date, Date(2026, 11, 17));
      expect(
        await window(Date(2026, 11, 2), Date(2026, 11, 15)),
        isA<GetAvailabilityResponse422>(),
      );
      expect(
        await window(Date(2026, 11, 3), Date(2026, 11, 30)),
        isA<GetAvailabilityResponse422>(),
      );
    });

    test('the bookings: known pet, replay, pending, new pet; slot taken, key '
        'reused, new pet refused', () async {
      final scheduling = SchedulingApi(server);
      Future<BookAppointmentResponse> book(String fixture, int status) async {
        backend.on(
          'POST',
          '$base/appointments',
          PortalReply.fixture(fixture, status: status),
        );
        final result = await scheduling.bookAppointment(
          clinicId: _paris,
          idempotencyKey: 'key',
          body: AppointmentBooking(
            petId: _oslo,
            motifId: consultation,
            practitionerId: dupont,
            startAt: OffsetDateTime.parse('2026-11-09T10:00:00+01:00'),
          ),
        );
        // A local: the return context would infer a FutureOr.
        final value = _value(result);
        return value;
      }

      final created = switch (await book(
        'clinics.paris.appointments.post.201.json',
        201,
      )) {
        BookAppointmentResponse201(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final replay = switch (await book(
        'clinics.paris.appointments.replay.post.201.json',
        201,
      )) {
        BookAppointmentResponse201(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final pending = switch (await book(
        'clinics.paris.appointments.pending.post.201.json',
        201,
      )) {
        BookAppointmentResponse201(:final body) => body,
        final other => fail('unexpected $other'),
      };

      expect(created.id, booked);
      expect(
        created.startAt.toTimeZonedIso8601String(),
        '2026-11-09T10:00:00+01:00',
      );
      expect(
        created.status,
        AppointmentBookingAppointmentViewStatusModel.confirmed,
      );
      expect(replay.id, created.id);
      expect(
        pending.status,
        AppointmentBookingAppointmentViewStatusModel.pendingClinicConfirmation,
      );
      expect(
        await book('clinics.paris.appointments.slot-taken.post.409.json', 409),
        isA<BookAppointmentResponse409>(),
      );
      // A problem body without violations does not decode as the typed
      // 422 (its schema requires them): the app reads it on the strict
      // chain, where it is a TonikError carrying the response.
      backend.on(
        'POST',
        '$base/appointments',
        PortalReply.fixture(
          'clinics.paris.appointments.key-reused.post.422.json',
          status: 422,
        ),
      );
      final reused =
          await SchedulingApi(
            portalServer(backend, interceptors: [_successOnly()]),
          ).bookAppointment(
            clinicId: _paris,
            idempotencyKey: 'key',
            body: AppointmentBooking(
              petId: _oslo,
              motifId: consultation,
              practitionerId: dupont,
              startAt: OffsetDateTime.parse('2026-11-09T10:00:00+01:00'),
            ),
          );
      expect(switch (reused) {
        TonikError(:final DioException error) => error.response?.statusCode,
        _ => null,
      }, 422);

      for (final (fixture, status) in [
        ('clinics.paris.appointments.with-new-pet.post.201.json', 201),
        (
          'clinics.paris.appointments.with-new-pet.validation.post.422.json',
          422,
        ),
      ]) {
        backend.on(
          'POST',
          '$base/appointments/with-new-pet',
          PortalReply.fixture(fixture, status: status),
        );
        final result = _value(
          await scheduling.bookAppointmentWithNewPet(
            clinicId: _paris,
            idempotencyKey: 'key',
            body: AppointmentBookingWithNewPet(
              newPet: const NewPet(
                name: 'Plume',
                species: NewPetSpeciesModel.cat,
              ),
              motifId: consultation,
              practitionerId: dupont,
              startAt: OffsetDateTime.parse('2026-11-16T10:00:00+01:00'),
            ),
          ),
        );
        switch (result) {
          case BookAppointmentWithNewPetResponse201(:final body):
            expect(body.pet?.petReferenceView?.name, 'Plume');
          case BookAppointmentWithNewPetResponse422():
            expect(status, 422);
          default:
            fail('unexpected $result');
        }
      }
    });

    test('the lists, one appointment and its care item, a 404', () async {
      final scheduling = SchedulingApi(server);
      final page1 = jsonDecode(
        File(
          '$portalFixtures/'
          'clinics.paris.appointments.past.page1.get.200.json',
        ).readAsStringSync(),
      ) as Map<String, Object?>;
      backend
        ..on(
          'GET',
          '$base/appointments?scope=upcoming',
          PortalReply.fixture(
            'clinics.paris.appointments.upcoming.booked.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$base/appointments?scope=past',
          PortalReply.fixture(
            'clinics.paris.appointments.past.page1.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$base/appointments?scope=past&cursor=${page1['nextCursor']}',
          PortalReply.fixture(
            'clinics.paris.appointments.past.page2.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$base/appointments/$booked',
          PortalReply.fixture('clinics.paris.appointment.get.200.json'),
        )
        ..on(
          'GET',
          '$base/appointments/related',
          PortalReply.fixture(
            'clinics.paris.appointment.related-care.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$base/appointments/gone',
          PortalReply.fixture(
            'clinics.paris.appointment.not-found.get.404.json',
            status: 404,
          ),
        );

      Future<AppointmentList> list(
        ApiPortalV1ClinicsClinicIdAppointmentsParametersModel scope, {
        String? cursor,
      }) async => switch (_value(
        await scheduling.listAppointments(
          clinicId: _paris,
          scope: scope,
          cursor: cursor,
        ),
      )) {
        ListAppointmentsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final upcoming = await list(
        ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.upcoming,
      );
      final past1 = await list(
        ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.past,
      );
      final past2 = await list(
        ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.past,
        cursor: past1.nextCursor,
      );
      Future<GetAppointmentResponse> read(String id) async {
        final result = await scheduling.getAppointment(
          clinicId: _paris,
          appointmentId: id,
        );
        // A local: the return context would infer a FutureOr.
        final value = _value(result);
        return value;
      }

      final one = switch (await read(booked)) {
        GetAppointmentResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final related = switch (await read('related')) {
        GetAppointmentResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };

      expect(upcoming.items, hasLength(3));
      expect(upcoming.items.first.motif.id, isNull);
      expect(upcoming.items.first.source, AppointmentViewSourceModel.clinic);
      expect(past1.items, hasLength(2));
      expect(past1.nextCursor, page1['nextCursor']);
      expect(
        past2.items.single.status,
        AppointmentViewStatusModel.cancelledByClinic,
      );
      expect(past2.nextCursor, isNull);
      expect(one.relatedCareItem?.relatedCareItemView, isNull);
      final care = related.relatedCareItem!.relatedCareItemView!;
      expect(care.kind, 'vaccination');
      expect(care.dueOn, Date(2027, 9, 5));
      expect(care.status, RelatedCareItemViewStatusModel.booked);
      expect(await read('gone'), isA<GetAppointmentResponse404>());
    });

    test('reschedule, cancel, calendar: their answers and refusals', () async {
      final scheduling = SchedulingApi(server);
      const appointment = '$base/appointments/$booked';
      Future<RescheduleAppointmentResponse> reschedule(
        String fixture,
        int status,
      ) async {
        backend.on(
          'POST',
          '$appointment/reschedule',
          PortalReply.fixture(fixture, status: status),
        );
        final result = await scheduling.rescheduleAppointment(
          clinicId: _paris,
          appointmentId: booked,
          body: AppointmentReschedule(
            startAt: OffsetDateTime.parse('2026-11-11T10:30:00+01:00'),
            practitionerId: dupont,
          ),
        );
        // A local: the return context would infer a FutureOr.
        final value = _value(result);
        return value;
      }

      Future<CancelAppointmentResponse> cancel(
        String fixture,
        int status,
      ) async {
        backend.on(
          'POST',
          '$appointment/cancel',
          PortalReply.fixture(fixture, status: status),
        );
        final result = await scheduling.cancelAppointment(
          clinicId: _paris,
          appointmentId: booked,
          body: const AppointmentCancellation(
            reason: AppointmentCancellationReasonModel.unavailable,
          ),
        );
        // A local: the return context would infer a FutureOr.
        final value = _value(result);
        return value;
      }

      final moved = switch (await reschedule(
        'clinics.paris.appointment.reschedule.post.200.json',
        200,
      )) {
        RescheduleAppointmentResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final cancelled = switch (await cancel(
        'clinics.paris.appointment.cancel.post.200.json',
        200,
      )) {
        CancelAppointmentResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final ics = File(
        '$portalFixtures/clinics.paris.appointment.calendar.get.200.ics',
      ).readAsBytesSync();
      backend.on(
        'GET',
        '$appointment/calendar.ics',
        PortalReply.bytes(ics, contentType: 'text/calendar; charset=utf-8'),
      );
      final calendar = switch (_value(
        await scheduling.getAppointmentCalendar(
          clinicId: _paris,
          appointmentId: booked,
        ),
      )) {
        GetAppointmentCalendarResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };

      expect(
        moved.startAt.toTimeZonedIso8601String(),
        '2026-11-11T10:30:00+01:00',
      );
      expect(
        await reschedule(
          'clinics.paris.appointment.reschedule.slot-taken.post.409.json',
          409,
        ),
        isA<RescheduleAppointmentResponse409>(),
      );
      // Without violations: on the strict chain (see the bookings).
      backend.on(
        'POST',
        '$appointment/reschedule',
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.not-modifiable.post.422.json',
          status: 422,
        ),
      );
      final refused =
          await SchedulingApi(
            portalServer(backend, interceptors: [_successOnly()]),
          ).rescheduleAppointment(
            clinicId: _paris,
            appointmentId: booked,
            body: AppointmentReschedule(
              startAt: OffsetDateTime.parse('2026-11-11T10:30:00+01:00'),
              practitionerId: dupont,
            ),
          );
      expect(switch (refused) {
        TonikError(:final DioException error) => error.response?.statusCode,
        _ => null,
      }, 422);
      expect(
        cancelled.status,
        AppointmentCancellationAppointmentViewStatusModel.cancelledByClient,
      );
      expect(cancelled.cancellableUntil, isNull);
      expect(
        await cancel(
          'clinics.paris.appointment.cancel.validation.post.422.json',
          422,
        ),
        isA<CancelAppointmentResponse422>(),
      );
      expect(utf8.encode(calendar), ics);
      expect(calendar, startsWith('BEGIN:VCALENDAR\r\n'));

      backend.on(
        'GET',
        '$appointment/calendar.ics',
        PortalReply.fixture(
          'clinics.paris.appointment.calendar.cancelled.get.404.json',
          status: 404,
        ),
      );
      expect(
        _value(
          await scheduling.getAppointmentCalendar(
            clinicId: _paris,
            appointmentId: booked,
          ),
        ),
        isA<GetAppointmentCalendarResponse404>(),
      );
    });

    test('a client with no pet followed (capture)', () async {
      backend.on(
        'GET',
        '$base/pets',
        PortalReply.fixture('clinics.paris.pets.empty.get.200.json'),
      );

      expect(switch (_value(await PetsApi(server).listPets(clinicId: _paris))) {
        ListPetsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      }, isEmpty);
    });
  });

  group('the requests captures (slice 6)', () {
    const base = '$_api/clinics/$_paris';
    const appointment = '01a1a297-4a0a-7093-83f7-14de2798613e';
    const questionnaire = '$base/appointments/$appointment/questionnaire';
    const fixtures = 'clinics.paris.appointment.questionnaire';
    const prescription = '01a19a12-8b44-7c87-b043-5d82ad91c574';
    const renewal = '$base/prescriptions/$prescription/renewal-requests';
    const changes = '$base/pets/$_oslo/change-requests';

    /// The status of a refusal on the strict chain (a problem body without
    /// violations does not decode as the typed 422: the app reads it as a
    /// TonikError carrying the response).
    int? strictStatus(TonikResult<Object?, Response<Object?>> result) =>
        switch (result) {
          TonikError(:final DioException error) => error.response?.statusCode,
          _ => null,
        };

    test('the questionnaire: not started, submitted, closed with and '
        'without answers, saved; the 404 of a cancelled appointment and the '
        '422 of a violation are typed values, the 422 of a closed one a '
        'refusal', () async {
      final requests = RequestsApi(server);
      Future<QuestionnaireView> read(String fixture) async {
        backend.on('GET', questionnaire, PortalReply.fixture(fixture));
        return switch (_value(
          await requests.getQuestionnaire(
            clinicId: _paris,
            appointmentId: appointment,
          ),
        )) {
          GetQuestionnaireResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
      }

      final notStarted = await read('$fixtures.get.200.json');
      final submitted = await read('$fixtures.submitted.get.200.json');
      final locked = await read('$fixtures.locked.get.200.json');
      final lockedEmpty = await read(
        '$fixtures.locked-not-started.get.200.json',
      );

      expect(
        notStarted.version,
        QuestionnaireQuestionnaireViewVersionModel.one,
      );
      expect(
        notStarted.status,
        QuestionnaireQuestionnaireViewStatusModel.notStarted,
      );
      expect(notStarted.answers?.questionnaireAnswersView, isNull);
      expect(notStarted.updatedAt, isNull);
      expect(notStarted.editable, isTrue);
      final answers = submitted.answers?.questionnaireAnswersView;
      expect(answers?.symptoms, [
        QuestionnaireAnswersViewSymptomsArrayModel.cough,
        QuestionnaireAnswersViewSymptomsArrayModel.itching,
      ]);
      expect(answers?.ongoingTreatment.has, isTrue);
      expect(
        answers?.ongoingTreatment.details,
        'Antibiotique, 1 comprimé matin et soir',
      );
      expect(
        answers?.temperament,
        QuestionnaireAnswersViewTemperamentModel.stressed,
      );
      expect(
        submitted.updatedAt?.toTimeZonedIso8601String(),
        '2026-11-04T02:00:06+01:00',
      );
      expect(locked.editable, isFalse);
      expect(
        locked.updatedAt?.toTimeZonedIso8601String(),
        '2026-10-20T21:30:00+02:00',
      );
      expect(
        locked.answers?.questionnaireAnswersView?.ongoingTreatment.details,
        isNull,
      );
      expect(lockedEmpty.editable, isFalse);
      expect(lockedEmpty.answers?.questionnaireAnswersView, isNull);

      backend.on(
        'GET',
        questionnaire,
        PortalReply.fixture('$fixtures.cancelled.get.404.json', status: 404),
      );
      expect(
        _value(
          await requests.getQuestionnaire(
            clinicId: _paris,
            appointmentId: appointment,
          ),
        ),
        isA<GetQuestionnaireResponse404>(),
      );

      Future<TonikResult<SaveQuestionnaireResponse, Response<Object?>>> save(
        RequestsApi api,
        String fixture,
        int status,
      ) {
        backend.on(
          'PUT',
          questionnaire,
          PortalReply.fixture(fixture, status: status),
        );
        return api.saveQuestionnaire(
          clinicId: _paris,
          appointmentId: appointment,
          body: const QuestionnaireUpdate(
            version: QuestionnaireUpdateVersionModel.one,
            symptoms: [QuestionnaireUpdateSymptomsArrayModel.none],
            ongoingTreatment: $RawQuestionnaireUpdateOngoingTreatmentAnyOfModel(
              ongoingTreatment: OngoingTreatment(has: false),
            ),
            temperament: QuestionnaireUpdateTemperamentModel.calm,
          ),
        );
      }

      final saved = switch (_value(
        await save(requests, '$fixtures.put.200.json', 200),
      )) {
        SaveQuestionnaireResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(
        saved.status,
        QuestionnaireUpdateQuestionnaireViewStatusModel.submitted,
      );
      expect(saved.answers?.questionnaireAnswersView?.notes, isNotNull);
      expect(
        _value(await save(requests, '$fixtures.validation.put.422.json', 422)),
        isA<SaveQuestionnaireResponse422>(),
      );
      final strict = RequestsApi(
        portalServer(backend, interceptors: [_successOnly()]),
      );
      expect(
        strictStatus(await save(strict, '$fixtures.locked.put.422.json', 422)),
        422,
      );
    });

    test('a change request: 202; the 422 of a violation typed, the other '
        'refusals on the strict chain', () async {
      Future<TonikResult<RequestPetChangeResponse, Response<Object?>>> send(
        RequestsApi api,
        String fixture,
        int status,
      ) {
        backend.on(
          'POST',
          changes,
          PortalReply.fixture(fixture, status: status),
        );
        return api.requestPetChange(
          clinicId: _paris,
          petId: _oslo,
          idempotencyKey: 'key',
          body: PetChangeRequestCreation(
            field: PetChangeRequestCreationFieldModel.weight,
            proposedValue: '12,4',
            measuredOn: Date(2026, 11, 2),
          ),
        );
      }

      final requests = RequestsApi(server);
      expect(switch (_value(
        await send(
          requests,
          'clinics.paris.pet.change-requests.post.202.json',
          202,
        ),
      )) {
        RequestPetChangeResponse202(:final body) => body.requestId,
        final other => fail('unexpected $other'),
      }, '01a1a413-c972-7eb1-b861-3e83365ac982');
      expect(jsonDecode(utf8.decode(backend.requestsTo(changes).single.body)), {
        'field': 'weight',
        'proposedValue': '12,4',
        'measuredOn': '2026-11-02',
        'note': null,
      });
      expect(
        backend.requestsTo(changes).single.headers['Idempotency-Key'],
        'key',
      );
      for (final fixture in [
        'clinics.paris.pet.change-requests.validation.post.422.json',
        'clinics.paris.pet.change-requests.note-missing.post.422.json',
      ]) {
        expect(
          _value(await send(requests, fixture, 422)),
          isA<RequestPetChangeResponse422>(),
          reason: fixture,
        );
      }
      final strict = RequestsApi(
        portalServer(backend, interceptors: [_successOnly()]),
      );
      for (final fixture in [
        'clinics.paris.pet.change-requests.not-eligible.post.422.json',
        'clinics.paris.pet.change-requests.key-reused.post.422.json',
      ]) {
        expect(
          strictStatus(await send(strict, fixture, 422)),
          422,
          reason: fixture,
        );
      }
    });

    test('a renewal request: 202 and its status; the 422 refusal on the '
        'strict chain', () async {
      Future<TonikResult<RequestRenewalResponse, Response<Object?>>> send(
        RequestsApi api,
        String fixture,
        int status,
      ) {
        backend.on(
          'POST',
          renewal,
          PortalReply.fixture(fixture, status: status),
        );
        return api.requestRenewal(
          clinicId: _paris,
          prescriptionId: prescription,
          idempotencyKey: 'key',
          body: const RenewalRequestCreation(
            petCondition: RenewalRequestCreationPetConditionModel.improved,
          ),
        );
      }

      final created = switch (_value(
        await send(
          RequestsApi(server),
          'clinics.paris.prescriptions.renewal-requests.post.202.json',
          202,
        ),
      )) {
        RequestRenewalResponse202(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(created.requestId, '01a19a12-87fc-7cd1-a51e-c25f03efc697');
      expect(
        created.status,
        RenewalRequestCreationRenewalRequestCreatedViewStatusModel.submitted,
      );
      expect(
        strictStatus(
          await send(
            RequestsApi(portalServer(backend, interceptors: [_successOnly()])),
            'clinics.paris.prescriptions.renewal-requests.'
            'not-renewable.post.422.json',
            422,
          ),
        ),
        422,
      );
    });

    test("Garnier's requests: both kinds, every status, the clinic's "
        'answers', () async {
      backend.on(
        'GET',
        '$base/requests',
        PortalReply.fixture('clinics.paris.requests.garnier.get.200.json'),
      );

      final list = switch (_value(
        await RequestsApi(server).listRequests(clinicId: _paris),
      )) {
        ListRequestsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };

      expect(list.items, hasLength(7));
      expect(list.items.map((item) => item.kind).toSet(), {
        PortalRequestViewKindModel.petChange,
        PortalRequestViewKindModel.prescriptionRenewal,
      });
      expect(list.items.map((item) => item.status).toSet(), {
        PortalRequestViewStatusModel.submitted,
        PortalRequestViewStatusModel.done,
        PortalRequestViewStatusModel.rejected,
      });
      expect(list.items.map((item) => item.field).take(3), [
        PortalRequestViewFieldModel.weight,
        PortalRequestViewFieldModel.other,
        PortalRequestViewFieldModel.chipNumber,
      ]);
      final renewalDone = list.items[3];
      expect(renewalDone.field, isNull);
      expect(renewalDone.prescriptionId, isNotNull);
      expect(
        renewalDone.resultingPrescriptionId,
        '01a19a12-8b44-7c87-b043-5d82ad91c574',
      );
      expect(renewalDone.resolutionMessage, startsWith('Nouvelle ordonnance'));
      expect(
        list.items.first.resolvedAt?.toTimeZonedIso8601String(),
        '2026-11-02T03:24:29+01:00',
      );
      expect(list.nextCursor, isNull);
    });
  });

  group('the clinic listing captures (slice 7)', () {
    const listings = '$_api/clinic-listings';
    const lyonListing = '01a19a12-79bb-7408-9051-a42bd37f652d';
    const parisListing = '01a19a11-0518-78b1-9eea-49198a26a6a7';
    const vercorsListing = '01a19a12-79dd-76b5-980f-ef11ab1a74e5';
    const consultation = '01a19a10-d3d1-7031-bd42-3d901474af59';
    const lemoine = '01a19a0e-29db-7550-a605-8ac512a656c1';

    /// The status of a refusal on the strict chain (a problem body without
    /// violations does not decode as the typed 422).
    int? strictStatus(TonikResult<Object?, Response<Object?>> result) =>
        switch (result) {
          TonikError(:final DioException error) => error.response?.statusCode,
          _ => null,
        };

    test('the search: by name, by place (distance), page after page; the '
        '422 of a short query and the 400 of a stale cursor are typed '
        'values', () async {
      final api = ClinicListingApi(server);
      Future<ClinicListings> read(String fixture) async {
        backend.on('GET', listings, PortalReply.fixture(fixture));
        return switch (_value(await api.listClinicListings())) {
          ListClinicListingsResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
      }

      final all = await read('clinic-listings.get.200.json');
      expect(all.items.map((listing) => listing.name), [
        'Clinique du Vercors',
        'Clinique Vétérinaire de Lyon',
        'Clinique Vétérinaire de Paris',
      ]);
      final vercors = all.items.first;
      expect(vercors.address?.listingAddressView, isNull);
      expect(vercors.phone, isNull);
      expect(vercors.distanceM, isNull);
      expect(vercors.onKiveto, isTrue);
      expect(vercors.onlineBooking, isFalse);
      expect(vercors.tags, ['Rurale']);
      expect(vercors.nextAvailableAt, isNull);
      final lyon = all.items[1];
      final address = lyon.address!.listingAddressView!;
      expect(address.line, '7 quai Saint-Antoine, Bâtiment B');
      expect(address.postalCode, '69002');
      expect(address.city, 'Lyon');
      expect(lyon.phone, '+33478920145');
      expect(lyon.onlineBooking, isTrue);
      expect(all.nextCursor, isNull);

      final near = await read('clinic-listings.near.get.200.json');
      expect(near.items.single.id, parisListing);
      expect(near.items.single.distanceM, 2074);
      expect((await read('clinic-listings.search.get.200.json')).items, [
        isA<ClinicListingSummaryView>().having((l) => l.id, 'id', lyonListing),
      ]);
      expect(
        (await read('clinic-listings.search-empty.get.200.json')).items,
        isEmpty,
      );
      final first = await read('clinic-listings.page1.get.200.json');
      expect(first.items, hasLength(2));
      expect(first.nextCursor, isNotNull);
      final second = await read('clinic-listings.page2.get.200.json');
      expect(second.items.single.id, parisListing);
      expect(second.nextCursor, isNull);

      for (final (fixture, status) in [
        ('clinic-listings.validation.get.422.json', 422),
        ('clinic-listings.coordinates.get.422.json', 422),
        ('clinic-listings.cursor-invalid.get.400.json', 400),
      ]) {
        backend.on(
          'GET',
          '$listings?q=a',
          PortalReply.fixture(
            fixture,
            status: status,
            contentType: 'application/problem+json',
          ),
        );
        final result = _value(await api.listClinicListings(q: 'a'));
        expect(
          result,
          status == 400
              ? isA<ListClinicListingsResponse400>()
              : isA<ListClinicListingsResponse422>(),
        );
      }
      expect(
        backend.requests.last.uri.toString(),
        'http://portal.test$listings?q=a',
      );
    });

    test('a clinic: address, hours by ISO day (split days kept), no address '
        'nor hours; the 404 of an unknown one', () async {
      final api = ClinicListingApi(server);
      Future<ClinicListingDetail> read(String id, String fixture) async {
        backend.on('GET', '$listings/$id', PortalReply.fixture(fixture));
        return switch (_value(await api.getClinicListing(listingId: id))) {
          GetClinicListingResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
      }

      final lyon = await read(lyonListing, 'clinic-listings.lyon.get.200.json');
      expect(lyon.name, 'Clinique Vétérinaire de Lyon');
      expect(lyon.timezone, 'Europe/Paris');
      expect(lyon.acceptsNewClients, isTrue);
      expect(lyon.onlineBooking, isTrue);
      expect(lyon.openingHours, hasLength(6));
      expect(lyon.openingHours.last.day, 6);
      expect(lyon.openingHours.last.opensAt, '09:00');
      expect(lyon.openingHours.last.closesAt, '12:00');
      final paris = await read(
        parisListing,
        'clinic-listings.paris.get.200.json',
      );
      expect(paris.onlineBooking, isFalse);
      expect(
        paris.openingHours
            .where((hours) => hours.day == 1)
            .map((hours) => '${hours.opensAt}-${hours.closesAt}'),
        ['09:00-12:30', '14:00-19:00'],
      );
      final vercors = await read(
        vercorsListing,
        'clinic-listings.vercors.get.200.json',
      );
      expect(vercors.address?.listingAddressView, isNull);
      expect(vercors.phone, isNull);
      expect(vercors.openingHours, isEmpty);
      expect(vercors.acceptsNewClients, isFalse);

      const unknown = '01a19a12-0000-7000-8000-000000000000';
      backend.on(
        'GET',
        '$listings/$unknown',
        PortalReply.fixture(
          'clinic-listings.unknown.get.404.json',
          status: 404,
          contentType: 'application/problem+json',
        ),
      );
      expect(
        _value(await api.getClinicListing(listingId: unknown)),
        isA<GetClinicListingResponse404>(),
      );
    });

    test('the new-client booking reads: motifs, practitioners, availability; '
        'the 422s of a clinic closed to new clients, of no motif', () async {
      final api = ClinicListingApi(server);
      backend
        ..on(
          'GET',
          '$listings/$lyonListing/booking/motifs',
          PortalReply.fixture(
            'clinic-listings.lyon.booking.motifs.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$listings/$parisListing/booking/motifs',
          PortalReply.fixture(
            'clinic-listings.paris.booking.motifs.get.422.json',
            status: 422,
            contentType: 'application/problem+json',
          ),
        )
        ..on(
          'GET',
          '$listings/$lyonListing/booking/practitioners?motifId=$consultation',
          PortalReply.fixture(
            'clinic-listings.lyon.booking.practitioners.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$listings/$lyonListing/booking/availability?motifId=$consultation'
              '&practitionerId=$lemoine&from=2026-11-04&to=2026-11-17',
          PortalReply.fixture(
            'clinic-listings.lyon.booking.availability.get.200.json',
          ),
        );

      final motifs = switch (_value(
        await api.listListingMotifs(listingId: lyonListing),
      )) {
        ListListingMotifsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(motifs.single.id, consultation);
      expect(motifs.single.label, 'Consultation');
      expect(motifs.single.durationMin, 30);
      expect(motifs.single.suggested, isFalse);
      expect(
        motifs.single.description,
        'Un problème de santé, un avis, un contrôle de routine.',
      );
      expect(
        _value(await api.listListingMotifs(listingId: parisListing)),
        isA<ListListingMotifsResponse422>(),
      );
      final practitioners = switch (_value(
        await api.listListingPractitioners(
          listingId: lyonListing,
          motifId: consultation,
        ),
      )) {
        ListListingPractitionersResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(practitioners.map((p) => p.displayName), [
        'Dr Sarah Lemoine',
        'Dr Éric Rousseau',
      ]);
      final availability = switch (_value(
        await api.getListingAvailability(
          listingId: lyonListing,
          motifId: consultation,
          practitionerId: lemoine,
          from: Date(2026, 11, 4),
          to: Date(2026, 11, 17),
        ),
      )) {
        GetListingAvailabilityResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(availability.days, hasLength(14));
      expect(availability.days.first.slots, isEmpty);
      expect(availability.days[4].open, isFalse);
      final slot = availability.days[1].slots.first.startAt;
      expect(slot.toTimeZonedIso8601String(), '2026-11-05T13:00:00+01:00');

      backend.on(
        'GET',
        '$listings/$lyonListing/booking/practitioners?motifId=',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.practitioners.validation.get.422.json',
          status: 422,
          contentType: 'application/problem+json',
        ),
      );
      final missing = await ClinicListingApi(
        portalServer(backend, interceptors: [_successOnly()]),
      ).listListingPractitioners(listingId: lyonListing, motifId: '');
      expect(strictStatus(missing), 422);
    });

    test('a new-client booking: 201 pending, its replay; slot taken, the '
        'refusals of a linked client, of a second request, of a reused or '
        'missing key, of a nameless pet', () async {
      const path = '$listings/$lyonListing/booking/appointments';
      const fixtures = 'clinic-listings.lyon.booking.appointments';
      final body = ListingBooking(
        newPet: const NewPet(name: 'Capture', species: NewPetSpeciesModel.cat),
        motifId: consultation,
        practitionerId: lemoine,
        startAt: OffsetDateTime.parse('2026-11-12T14:00:00+01:00'),
      );
      Future<TonikResult<RequestListingAppointmentResponse, Response<Object?>>>
      request(String fixture, int status, {CustomServer? on}) async {
        backend.on(
          'POST',
          path,
          PortalReply.fixture(
            fixture,
            status: status,
            contentType: status < 300
                ? 'application/json'
                : 'application/problem+json',
          ),
        );
        return await ClinicListingApi(on ?? server).requestListingAppointment(
          listingId: lyonListing,
          idempotencyKey: 'key-1',
          body: body,
        );
      }

      final created = switch (_value(
        await request('$fixtures.post.201.json', 201),
      )) {
        RequestListingAppointmentResponse201(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(created.id, '01a1a496-639e-7512-a3b9-e5c2596e2c3d');
      expect(created.clinic.name, 'Clinique Vétérinaire de Lyon');
      expect(created.clinic.city, 'Lyon');
      expect(created.pet.name, 'Capture');
      expect(created.pet.species, BookingRequestPetViewSpeciesModel.cat);
      expect(created.motif, 'Consultation');
      expect(
        created.startAt.toTimeZonedIso8601String(),
        '2026-11-12T14:00:00+01:00',
      );
      expect(
        created.status,
        ListingBookingBookingRequestViewStatusModel.pending,
      );
      expect(created.declineReason, isNull);
      expect(created.appointmentId, isNull);
      final sent = backend.requests.last;
      expect(sent.headers['Idempotency-Key'], 'key-1');
      expect(jsonDecode(utf8.decode(sent.body)), {
        'newPet': {'name': 'Capture', 'species': 'cat'},
        'motifId': consultation,
        'practitionerId': lemoine,
        'startAt': '2026-11-12T14:00:00+01:00',
      });

      // The replay answers the stored body (spaced, raw UTF-8).
      final replay = switch (_value(
        await request('$fixtures.replay.post.201.json', 201),
      )) {
        RequestListingAppointmentResponse201(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(replay.id, created.id);
      expect(replay.clinic.name, 'Clinique Vétérinaire de Lyon');

      expect(
        _value(await request('$fixtures.slot-taken.post.409.json', 409)),
        isA<RequestListingAppointmentResponse409>(),
      );
      // A violation is a typed 422 (its body names the field).
      switch (await request('$fixtures.validation.post.422.json', 422)) {
        case TonikSuccess(
          value: RequestListingAppointmentResponse422(),
          :final response,
        ):
          expect(
            utf8.decode(response.data! as List<int>),
            contains('"propertyPath":"newPet.name"'),
          );
        case final other:
          fail('unexpected $other');
      }
      final missingKey = _value(
        await request('$fixtures.key-missing.post.400.json', 400),
      );
      expect(missingKey, isA<RequestListingAppointmentResponse400>());

      // Business refusals carry no violations: on the strict chain they are
      // TonikErrors carrying the response, which the app maps by `type`.
      final strict = portalServer(backend, interceptors: [_successOnly()]);
      for (final fixture in ['already-linked', 'limit', 'key-reused']) {
        final result = await request(
          '$fixtures.$fixture.post.422.json',
          422,
          on: strict,
        );
        expect(strictStatus(result), 422, reason: fixture);
        final data = switch (result) {
          TonikError(:final DioException error) => error.response?.data,
          _ => null,
        };
        expect(
          utf8.decode(data! as List<int>),
          contains(switch (fixture) {
            'already-linked' => '"type":"already_linked"',
            'limit' => '"type":"booking_request_limit"',
            _ => '"type":"idempotency_key_reused"',
          }),
        );
      }
    });

    test('the booking requests: pending, declined (expired, declined), '
        'confirmed with its appointment', () async {
      final account = AccountApi(server);
      Future<BookingRequests> read(String fixture) async {
        backend.on(
          'GET',
          '$_api/me/booking-requests',
          PortalReply.fixture(fixture),
        );
        return switch (_value(await account.listBookingRequests())) {
          ListBookingRequestsResponse200(:final body) => body,
          final other => fail('unexpected $other'),
        };
      }

      final pending = (await read('me.booking-requests.pending.get.200.json'))
          .items
          .single;
      expect(pending.status, BookingRequestViewStatusModel.pending);
      expect(pending.declineReason, isNull);
      final declined = await read('me.booking-requests.declined.get.200.json');
      expect(declined.items.map((item) => item.declineReason), [
        BookingRequestViewDeclineReasonModel.expired,
        BookingRequestViewDeclineReasonModel.declined,
        BookingRequestViewDeclineReasonModel.expired,
      ]);
      expect(declined.items.first.pet.name, 'Biscotte');
      expect(
        declined.items.first.startAt.toTimeZonedIso8601String(),
        '2026-11-10T09:00:00+01:00',
      );
      final confirmed = (await read(
        'me.booking-requests.confirmed.get.200.json',
      )).items.single;
      expect(confirmed.status, BookingRequestViewStatusModel.confirmed);
      expect(confirmed.appointmentId, '01a19a12-9db0-7703-80f3-d1f2f41e32e5');
      expect(confirmed.pet.species, BookingRequestPetViewSpeciesModel.dog);
    });

    test('a link suggestion accepted: 202 pending, the 404 of an unknown one, '
        '/me with the pending link, no suggestion left', () async {
      final account = AccountApi(server);
      const id =
          '25ee8fbda0546a36b8f686d0504b04b343c4a8a0851fb2b523e621361b972cd6';
      backend
        ..on(
          'POST',
          '$_api/me/link-suggestions/$id/accept',
          PortalReply.fixture(
            'me.link-suggestions.accept.post.202.json',
            status: 202,
          ),
        )
        ..on(
          'GET',
          '$_api/me',
          PortalReply.fixture('me.pending-link.get.200.json'),
        )
        ..on(
          'GET',
          '$_api/me/link-suggestions',
          PortalReply.fixture('me.link-suggestions.empty.get.200.json'),
        );

      final accepted = switch (_value(
        await account.acceptLinkSuggestion(suggestionId: id),
      )) {
        AcceptLinkSuggestionResponse202(:final body) => body,
        final other => fail('unexpected $other'),
      };
      expect(
        accepted.linkStatus,
        LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel
            .pending,
      );
      final me = switch (_value(await account.getMe())) {
        GetMeResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      };
      final link = me.clinics.single;
      expect(link.linkStatus, ClinicLinkViewLinkStatusModel.pending);
      expect(link.linkedAt, isNull);
      expect(link.petNames, isEmpty);
      expect(link.unreadDocuments, 0);
      expect(switch (_value(await account.listLinkSuggestions())) {
        ListLinkSuggestionsResponse200(:final body) => body,
        final other => fail('unexpected $other'),
      }, isEmpty);

      const unknown =
          '0000000000000000000000000000000000000000000000000000000000000000';
      backend.on(
        'POST',
        '$_api/me/link-suggestions/$unknown/accept',
        PortalReply.fixture(
          'me.link-suggestions.accept.unknown.post.404.json',
          status: 404,
          contentType: 'application/problem+json',
        ),
      );
      final missing = await AccountApi(
        portalServer(backend, interceptors: [_successOnly()]),
      ).acceptLinkSuggestion(suggestionId: unknown);
      expect(strictStatus(missing), 404);
    });
  });

  group('PATCH /me', () {
    test('sends a merge-patch body; 422 problem+json is a typed '
        'ConstraintViolation', () async {
      backend.on(
        'PATCH',
        '$_api/me',
        PortalReply.fixture('me.patch.422.json', status: 422),
      );

      final result = await AccountApi(server).updateMe(
        body: const ApiPortalV1MePatchBodyRequestBodyMergePatchJson(
          MeUpdate(firstName: ''),
        ),
      );

      final problem = switch (_value(result)) {
        UpdateMeResponse422(
          body: ApiPortalV1MePatch422ResponseProblemJson(:final body),
        ) =>
          body,
        final other => fail('unexpected $other'),
      };
      expect(problem.status, 422);
      expect(problem.problemType, 'validation_failed');
      expect(problem.title, 'Données invalides.');
      final violation = problem.violations.single;
      expect(violation.propertyPath, 'firstName');
      expect(violation.message, 'Le prénom ne peut pas être vide.');
      expect(violation.code, 'c1051bb4-d103-4f74-8988-acbcafc7fdc3');

      final request = backend.requests.single;
      expect(request.method, 'PATCH');
      expect(request.contentType, 'application/merge-patch+json');
      expect(
        jsonDecode(utf8.decode(request.body)),
        containsPair('firstName', ''),
      );
    });

    test('with a 2xx-only validateStatus, a 422 is a TonikError carrying the '
        'DioException and the problem+json bytes', () async {
      backend.on(
        'PATCH',
        '$_api/me',
        PortalReply.fixture('me.patch.422.json', status: 422),
      );
      server = portalServer(backend, interceptors: [_successOnly()]);

      final result = await AccountApi(server).updateMe(
        body: const ApiPortalV1MePatchBodyRequestBodyMergePatchJson(
          MeUpdate(firstName: ''),
        ),
      );

      final error = switch (result) {
        TonikError(:final error) => error,
        TonikSuccess() => fail('expected a TonikError, got $result'),
      };
      final exception = error as DioException;
      expect(exception.type, DioExceptionType.badResponse);
      expect(exception.response?.statusCode, 422);
      final problem = jsonDecode(
        utf8.decode(exception.response!.data! as List<int>),
      ) as Map<String, Object?>;
      expect(problem['type'], 'validation_failed');
    });
  });

  group('requests', () {
    test('a booking startAt built from a slot value keeps its offset and has '
        'no fractional seconds', () {
      final slot = OffsetDateTime.parse('2026-11-04T13:30:00+01:00');
      final booking = AppointmentBooking(
        petId: _oslo,
        motifId: '01a19a10-d467-7bc2-9344-790c64b6ab03',
        practitionerId: '01a19a0e-1afe-7116-ad21-672cf69c5366',
        startAt: slot,
      );

      final json = booking.toJson()! as Map<String, Object?>;

      expect(json['startAt'], '2026-11-04T13:30:00+01:00');
    });

    test(
      'the documents filter is named kind in Dart, sent as ?type=',
      () async {
        backend.on(
          'GET',
          '$_api/clinics/$_paris/documents?type=invoice',
          PortalReply.fixture('clinics.paris.documents.get.200.json'),
        );

        final result = await DocumentsApi(server).listDocuments(
          clinicId: _paris,
          kind: ApiPortalV1ClinicsClinicIdDocumentsParametersModel.invoice,
        );

        expect(_value(result), isA<ListDocumentsResponse200>());
        expect(
          backend.requests.single.pathWithQuery,
          '$_api/clinics/$_paris/documents?type=invoice',
        );
      },
    );

    test('bookAppointment sends the slot startAt as received and the '
        'Idempotency-Key header', () async {
      backend.on(
        'POST',
        '$_api/clinics/$_paris/appointments',
        PortalReply.fixture('me.patch.422.json', status: 422),
      );

      await SchedulingApi(server).bookAppointment(
        clinicId: _paris,
        idempotencyKey: 'booking-intent-1',
        body: AppointmentBooking(
          petId: _oslo,
          motifId: '01a19a10-d467-7bc2-9344-790c64b6ab03',
          practitionerId: '01a19a0e-1afe-7116-ad21-672cf69c5366',
          startAt: OffsetDateTime.parse('2026-11-04T13:30:00+01:00'),
        ),
      );

      final request = backend.requests.single;
      expect(request.headers['Idempotency-Key'], 'booking-intent-1');
      expect(request.contentType, startsWith('application/json'));
      final body =
          jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;
      expect(body['startAt'], '2026-11-04T13:30:00+01:00');
      expect(body['petId'], _oslo);
    });

    test(
      'an unrouted request fails with its method, URI and the routes',
      () async {
        backend.on('GET', '$_api/me', PortalReply.json('{}'));

        final result = await PetsApi(server).getHome(clinicId: _paris);

        final error = switch (result) {
          TonikError(:final error) => error,
          TonikSuccess() => fail('expected a TonikError, got $result'),
        };
        expect(
          '${(error as DioException).error}',
          allOf(
            contains(
              'unrouted GET http://portal.test$_api/clinics/$_paris/home',
            ),
            contains('routes: GET $_api/me'),
          ),
        );
      },
    );
  });
}
