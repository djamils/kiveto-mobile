// PortalHomeRepository on the real chain and the captures: Julien's Paris
// and Lyon homes, Garnier's Paris home, every enum of the contract (unknown
// kept), the null wrappers (no appointment, no pet on it, no practitioner
// name, no birth date, no invoice), the 404 of a clinic and a network
// failure.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/home/infrastructure/portal_home_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _paris = ClinicId('01960000-0000-7000-8000-000000000001');
const _lyon = ClinicId('01960000-0000-7000-8000-000000000101');
const _parisHome = '$api/clinics/01960000-0000-7000-8000-000000000001/home';

/// Julien's Paris capture with [change] applied to its body.
PortalReply _parisWith(void Function(Map<String, Object?> body) change) {
  final body = jsonDecode(
    File('$portalFixtures/clinics.paris.home.get.200.json').readAsStringSync(),
  ) as Map<String, Object?>;
  change(body);
  return PortalReply.json(jsonEncode(body));
}

Map<String, Object?> _appointmentOf(Map<String, Object?> body) =>
    body['nextAppointment']! as Map<String, Object?>;

void main() {
  late PortalHarness harness;
  late PortalHomeRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalHomeRepository(harness.http.server, harness.failures);
  });

  test('Julien, Paris (capture): the next appointment, Oslo, two care '
      'items, two invoices', () async {
    harness.backend.on(
      'GET',
      _parisHome,
      PortalReply.fixture('clinics.paris.home.get.200.json'),
    );

    final home = await repository.overview(_paris);

    final appointment = home.nextAppointment!;
    expect(appointment.id, '01a19a12-6840-7d19-bf1f-7604a862c028');
    expect(
      appointment.startAt,
      ClinicInstant.parse('2026-11-11T10:30:00+01:00'),
    );
    expect(appointment.startAt.offset, const Duration(hours: 1));
    expect(appointment.petName, 'Oslo');
    expect(appointment.motifLabel, 'Rendez-vous');
    expect(appointment.practitionerName, 'Dr Éric Rousseau');
    expect(appointment.status, AppointmentState.confirmed);
    expect(appointment.questionnaire, QuestionnaireState.submitted);

    final oslo = home.pets.single;
    expect(oslo.id, '01a19a0f-128f-7a54-b39c-e01a30ee66d2');
    expect(oslo.name, 'Oslo');
    expect(oslo.initial, 'O');
    expect(oslo.species, Species.dog);
    expect(oslo.birthDate, LocalDate(2020, 3, 2));

    final [chpl, rage] = home.careItems;
    expect(chpl.petId, '01a19a0f-128f-7a54-b39c-e01a30ee66d2');
    expect(chpl.petName, 'Oslo');
    expect(chpl.label, 'CHPL');
    expect(chpl.dueOn, LocalDate(2027, 9, 5));
    expect(chpl.status, CareStatus.upToDate);
    expect(rage.label, 'Rage');

    final [first, second] = home.latestDocuments;
    expect(first.id, '01a19a12-65aa-78e6-b439-fe4e297698d8');
    expect(first.kind, DocumentKind.invoice);
    expect(first.title, 'Facture PAR-2026-000067');
    expect(first.petIds, ['01a19a0f-128f-7a54-b39c-e01a30ee66d2']);
    expect(first.issuedAt, ClinicInstant.parse('2026-10-24T09:40:00+02:00'));
    expect(first.invoice!.total, Money(5200, 'EUR'));
    expect(first.invoice!.paymentStatus, PaymentStatus.paid);
    expect(second.title, 'Facture PAR-2026-000066');
    expect(second.invoice!.total, Money(7800, 'EUR'));

    final request = harness.backend.requests.single;
    expect(request.pathWithQuery, _parisHome);
    expect(bearerOf(request), 'Bearer A');
  });

  test('Julien, Lyon (capture): no appointment, Pixel, nothing else', () async {
    harness.backend.on(
      'GET',
      '$api/clinics/${_lyon.value}/home',
      PortalReply.fixture('clinics.lyon.home.get.200.json'),
    );

    final home = await repository.overview(_lyon);

    expect(home.nextAppointment, isNull);
    expect(home.pets.single.name, 'Pixel');
    expect(home.pets.single.species, Species.cat);
    expect(home.careItems, isEmpty);
    expect(home.latestDocuments, isEmpty);
  });

  test('Garnier, Paris (capture): four pets, three overdue care items, a '
      'prescription and an unpaid invoice', () async {
    harness.backend.on(
      'GET',
      _parisHome,
      PortalReply.fixture('clinics.paris.home.garnier.get.200.json'),
    );

    final home = await repository.overview(_paris);

    expect(home.nextAppointment!.petName, 'Oscar');
    expect(home.nextAppointment!.practitionerName, 'Dr Lucie Bernard');
    expect(home.pets.map((pet) => (pet.name, pet.species)), [
      ('Coco', Species.nac),
      ('Nala', Species.cat),
      ('Oscar', Species.dog),
      ('Pepito', Species.dog),
    ]);
    expect(home.careItems.map((item) => item.status), [
      CareStatus.overdue,
      CareStatus.overdue,
      CareStatus.overdue,
    ]);
    expect(home.careItems.first.dueOn, LocalDate(2026, 10, 13));
    final [prescription, invoice] = home.latestDocuments;
    expect(prescription.kind, DocumentKind.prescription);
    expect(prescription.title, 'Ordonnance ORD-2026-000036');
    expect(prescription.invoice, isNull);
    expect(invoice.invoice!.paymentStatus, PaymentStatus.unpaid);
    expect(invoice.invoice!.total, Money(9600, 'EUR'));
  });

  test('every appointment and questionnaire status: the ones the home '
      'shows, any other one', () async {
    const statuses = [
      ('confirmed', AppointmentState.confirmed),
      (
        'pending_clinic_confirmation',
        AppointmentState.pendingClinicConfirmation,
      ),
      ('cancelled_by_client', AppointmentState.other),
      ('cancelled_by_clinic', AppointmentState.other),
      ('declined', AppointmentState.other),
      ('completed', AppointmentState.other),
      ('no_show', AppointmentState.other),
      ('rescheduled', AppointmentState.other),
    ];
    const questionnaires = [
      ('not_started', QuestionnaireState.notStarted),
      ('submitted', QuestionnaireState.submitted),
      ('unknown', QuestionnaireState.unknown),
      ('expired', QuestionnaireState.unknown),
    ];
    for (final (status, expected) in statuses) {
      harness.backend.on(
        'GET',
        _parisHome,
        _parisWith((body) => _appointmentOf(body)['status'] = status),
      );
      final home = await repository.overview(_paris);
      expect(home.nextAppointment!.status, expected, reason: status);
    }
    for (final (status, expected) in questionnaires) {
      harness.backend.on(
        'GET',
        _parisHome,
        _parisWith(
          (body) => _appointmentOf(body)['questionnaireStatus'] = status,
        ),
      );
      final home = await repository.overview(_paris);
      expect(home.nextAppointment!.questionnaire, expected, reason: status);
    }
  });

  test('an appointment without pet nor practitioner name', () async {
    harness.backend.on(
      'GET',
      _parisHome,
      _parisWith((body) {
        final appointment = _appointmentOf(body);
        appointment['pet'] = null;
        (appointment['practitioner']! as Map<String, Object?>)['displayName'] =
            null;
      }),
    );

    final appointment = (await repository.overview(_paris)).nextAppointment!;

    expect(appointment.petName, isNull);
    expect(appointment.practitionerName, isNull);
  });

  test('every species, care status, kind and payment; unknown ones kept; '
      'no birth date', () async {
    harness.backend.on(
      'GET',
      _parisHome,
      _parisWith((body) {
        final pet =
            (body['pets']! as List<Object?>).first! as Map<String, Object?>;
        body['pets'] = [
          for (final species in ['dog', 'cat', 'nac', 'other', 'unknown', 'x'])
            {...pet, 'species': species, 'birthDate': null},
        ];
        final care =
            (body['careItems']! as List<Object?>).first!
                as Map<String, Object?>;
        body['careItems'] = [
          for (final status in [
            'booked',
            'overdue',
            'due_soon',
            'up_to_date',
            'unknown',
            'postponed',
          ])
            {
              ...care,
              'status': status,
              'pet': {'id': null, 'name': 'Moka'},
            },
        ];
        final document =
            (body['latestDocuments']! as List<Object?>).first!
                as Map<String, Object?>;
        body['latestDocuments'] = [
          for (final kind in [
            'report',
            'prescription',
            'lab_result',
            'certificate',
            'vaccination_record',
          ])
            {...document, 'type': kind, 'invoice': null},
          for (final status in [
            'unpaid',
            'partially_paid',
            'paid',
            'credited',
            'unknown',
            'refunded',
          ])
            {
              ...document,
              'invoice': {
                'total': {'amount': 100, 'currency': 'EUR'},
                'paymentStatus': status,
              },
            },
        ];
      }),
    );

    final home = await repository.overview(_paris);

    expect(home.pets.map((pet) => pet.species), [
      Species.dog,
      Species.cat,
      Species.nac,
      Species.other,
      Species.unknown,
      Species.unknown,
    ]);
    expect(home.pets.map((pet) => pet.birthDate), everyElement(isNull));
    expect(home.careItems.map((item) => item.status), [
      CareStatus.booked,
      CareStatus.overdue,
      CareStatus.dueSoon,
      CareStatus.upToDate,
      CareStatus.unknown,
      CareStatus.unknown,
    ]);
    expect(home.careItems.first.petId, isNull);
    expect(home.careItems.first.petName, 'Moka');
    expect(home.latestDocuments.take(5).map((d) => (d.kind, d.invoice)), [
      (DocumentKind.report, null),
      (DocumentKind.prescription, null),
      (DocumentKind.labResult, null),
      (DocumentKind.certificate, null),
      (DocumentKind.unknown, null),
    ]);
    expect(home.latestDocuments.skip(5).map((d) => d.invoice!.paymentStatus), [
      PaymentStatus.unpaid,
      PaymentStatus.partiallyPaid,
      PaymentStatus.paid,
      PaymentStatus.credited,
      PaymentStatus.unknown,
      PaymentStatus.unknown,
    ]);
  });

  test('404 (capture): the link with the clinic is gone', () async {
    harness.backend.on(
      'GET',
      _parisHome,
      PortalReply.fixture('clinics.unknown.home.get.404.json', status: 404),
    );

    await expectLater(
      repository.overview(_paris),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('no answer: a NetworkFailure', () async {
    await expectLater(
      repository.overview(_paris),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
