// The generated Portal API client (packages/kiveto_portal_api) on real
// responses of the backend: every contract fixture of
// test/support/fixtures/portal_api/ decodes through the generated API
// classes, on a real Dio whose adapter is the fake backend. Spot checks of
// what the app relies on: the clinic UTC offsets kept, `Date` for
// `YYYY-MM-DD`, non-null required fields, `null` kept where nullable, the
// errors as typed values, and the request lines the client sends.

import 'dart:convert';

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

    test('404 problem+json decodes as a typed Error, missing nullable keys '
        'read as null', () async {
      // The real 404 body of an unknown clinic: no `detail`, no `instance`.
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
