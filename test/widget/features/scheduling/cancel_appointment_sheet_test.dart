// Screen 16 on the captures: the sheet over a vaccination (the care item
// it covers, read from the appointment), the reasons, « Annuler le
// rendez-vous » once a reason is chosen, « Reporter plutôt », « Garder mon
// rendez-vous »; the cancellation (its reason, the done view with or
// without the confirmation, the lists reloaded) and its failures.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/patient/patient.dart'
    show PetId, careItemsProvider;
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/cancel_appointment_sheet.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _vaccination = '01a1a299-fcaa-7cda-bf12-56fbb162037d';
const _cancel = '$parisBase/appointments/$_vaccination/cancel';
const _careItems = '$parisBase/pets/$osloId/care-items';

/// Oslo's vaccination of the 16th, as the list gives it (no care item).
Appointment _appointment({
  AppointmentStatus status = AppointmentStatus.confirmed,
  AppointmentSource source = AppointmentSource.portal,
  String? petName = 'Oslo',
}) => Appointment(
  id: const AppointmentId(_vaccination),
  startAt: ClinicInstant.parse('2026-11-16T11:00:00+01:00'),
  endAt: ClinicInstant.parse('2026-11-16T11:20:00+01:00'),
  petId: osloId,
  petName: petName,
  motifId: const MotifId(vaccinationId),
  motifLabel: 'Vaccination',
  practitionerId: const PractitionerId(rousseauId),
  practitionerName: 'Dr Éric Rousseau',
  status: status,
  source: source,
  cancellableUntil: ClinicInstant.parse('2026-11-15T11:00:00+01:00'),
  questionnaire: QuestionnaireStatus.notStarted,
);

/// A page with a button opening the sheet over [appointment].
Widget _opener(Appointment appointment, List<String> exits) => Builder(
  builder: (context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => showCancelAppointmentSheet(
          context,
          appointment,
          clinicId: const ClinicId(parisId),
          onReschedule: () => exits.add('reschedule'),
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

FakePortalBackend _backend() => julienBackend()
  ..on(
    'GET',
    '$parisBase/appointments/$_vaccination',
    PortalReply.fixture('clinics.paris.appointment.related-care.get.200.json'),
  )
  ..on(
    'GET',
    _careItems,
    PortalReply.fixture('clinics.paris.pet.care-items.get.200.json'),
  );

/// Keeps Oslo's care items read (a pet sheet open under the list).
void _watchCareItems(ProviderContainer container) =>
    container.listen(careItemsProvider(const PetId(osloId)), (_, _) {});

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  Future<ProviderContainer> open(
    WidgetTester tester,
    FakePortalBackend backend, {
    Appointment? appointment,
  }) async {
    final container = await pumpStep(
      tester,
      _opener(appointment ?? _appointment(), exits),
      backend: backend,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return container;
  }

  bool confirmEnabled(WidgetTester tester) =>
      tester.widget<KivetoButton>(button('Annuler le rendez-vous')).onPressed !=
      null;

  testWidgets('a vaccination (capture): the title, the appointment, the care '
      'item it covers, the reasons; « Annuler le rendez-vous » once a reason '
      'is chosen', (tester) async {
    await open(tester, _backend());

    expect(find.text('Annuler ce rendez-vous ?'), findsOneWidget);
    expect(
      find.text('Lun. 16 nov. · 11:00 · Oslo — Vaccination'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Le rappel CHPL est à faire avant le 5 sept. 2027 pour Oslo. '
        'Reporter évite un retard de vaccination.',
      ),
      findsOneWidget,
    );
    expect(find.text("Raison de l'annulation"), findsOneWidget);
    for (final reason in [
      'Empêchement',
      'Plus nécessaire',
      'Vu ailleurs',
      'Autre',
    ]) {
      expect(find.text(reason), findsOneWidget);
    }
    expect(confirmEnabled(tester), isFalse);
    expect(find.text('Reporter plutôt'), findsOneWidget);
    expect(find.text('Garder mon rendez-vous'), findsOneWidget);

    await tester.tap(find.text('Vu ailleurs'));
    await tester.pumpAndSettle();
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('« Garder mon rendez-vous » closes; « Reporter plutôt » closes '
      'and moves it', (tester) async {
    await open(tester, _backend());

    await tester.tap(find.text('Garder mon rendez-vous'));
    await tester.pumpAndSettle();
    expect(find.text('Annuler ce rendez-vous ?'), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Reporter plutôt'));
    expect(find.text('Annuler ce rendez-vous ?'), findsNothing);
    expect(exits, ['reschedule']);
  });

  testWidgets(
    'cancelled (capture): the reason sent, « Rendez-vous annulé », '
    'the confirmation of a confirmed one, back to the list; the lists reload',
    (tester) async {
      final backend = _backend()
        ..on(
          'POST',
          _cancel,
          PortalReply.fixture('clinics.paris.appointment.cancel.post.200.json'),
        );
      final container = await open(tester, backend);
      _watchCareItems(container);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Empêchement'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Annuler le rendez-vous'));

      expect(
        utf8.decode(backend.requestsTo(_cancel).single.body),
        '{"reason":"unavailable"}',
      );
      expect(container.read(appointmentsRevisionProvider), 1);
      expect(backend.requestsTo(_careItems), hasLength(2));
      expect(find.text('Rendez-vous annulé'), findsOneWidget);
      expect(
        find.text(
          'La clinique a été prévenue. Une confirmation vous est envoyée.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Retour à mes rendez-vous'));
      await tester.pumpAndSettle();
      expect(find.text('Rendez-vous annulé'), findsNothing);
    },
  );

  testWidgets('a pending one, booked by the clinic, without care item: no '
      'confirmation promised, no « Reporter plutôt », no warning', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$parisBase/appointments/$_vaccination',
        PortalReply.fixture('clinics.paris.appointment.get.200.json'),
      )
      ..on(
        'POST',
        _cancel,
        PortalReply.fixture('clinics.paris.appointment.cancel.post.200.json'),
      );
    await open(
      tester,
      backend,
      appointment: _appointment(
        status: AppointmentStatus.pendingClinicConfirmation,
        source: AppointmentSource.clinic,
      ),
    );

    expect(find.textContaining('Reporter évite'), findsNothing);
    expect(find.text('Reporter plutôt'), findsNothing);
    await tester.tap(find.text('Autre'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Annuler le rendez-vous'));

    // No confirmation promised for a request the clinic had not confirmed.
    expect(find.text('La clinique a été prévenue.'), findsOneWidget);
    expect(find.textContaining('confirmation'), findsNothing);
  });

  testWidgets('an appointment without pet: its line without name, no '
      'warning', (tester) async {
    await open(tester, _backend(), appointment: _appointment(petName: null));

    expect(find.text('Lun. 16 nov. · 11:00 — Vaccination'), findsOneWidget);
    expect(find.textContaining('Reporter évite'), findsNothing);
  });

  testWidgets('cancelled after the sheet was closed: the lists and the care '
      'items still reload', (tester) async {
    final answer = Completer<PortalReply>();
    final backend = _backend()
      ..onRequest('POST', _cancel, (request) => answer.future);
    final container = await open(tester, backend);
    _watchCareItems(container);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Empêchement'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Annuler le rendez-vous'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler le rendez-vous'));
    await tester.pump();
    await tester.tap(find.text('Garder mon rendez-vous'));
    await tester.pumpAndSettle();
    expect(find.text('Annuler ce rendez-vous ?'), findsNothing);

    answer.complete(
      PortalReply.fixture('clinics.paris.appointment.cancel.post.200.json'),
    );
    await tester.pumpAndSettle();

    expect(container.read(appointmentsRevisionProvider), 1);
    expect(backend.requestsTo(_careItems), hasLength(2));
  });

  for (final (name, reply, message, reloads, cleared) in [
    (
      'the window closed',
      problem('cancellation_window_closed', 422),
      "Le délai d'annulation en ligne est dépassé : contactez la clinique.",
      1,
      true,
    ),
    (
      'not modifiable',
      problem('appointment_not_modifiable', 422),
      'Ce rendez-vous ne peut plus être modifié.',
      1,
      true,
    ),
    (
      'gone (404)',
      problem('not_found', 404),
      "Ce rendez-vous n'est plus disponible.",
      1,
      true,
    ),
    (
      'no reason (capture)',
      PortalReply.fixture(
        'clinics.paris.appointment.cancel.validation.post.422.json',
        status: 422,
      ),
      "Motif d'annulation obligatoire.",
      0,
      false,
    ),
  ]) {
    testWidgets('$name: its message in the sheet', (tester) async {
      final backend = _backend()..on('POST', _cancel, reply);
      final container = await open(tester, backend);

      await tester.tap(find.text('Plus nécessaire'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Annuler le rendez-vous'));

      expect(find.text(message), findsOneWidget);
      expect(find.text('Annuler ce rendez-vous ?'), findsOneWidget);
      expect(container.read(appointmentsRevisionProvider), reloads);
      // Refused for good: no reason left to send again.
      expect(confirmEnabled(tester), !cleared);
    });
  }

  testWidgets('no network: the message and « Réessayer », the same reason '
      'sent again', (tester) async {
    final backend = _backend();
    await open(tester, backend);
    await tester.tap(find.text('Empêchement'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Annuler le rendez-vous'));
    expect(
      find.text('Vérifiez votre connexion Internet, puis réessayez.'),
      findsOneWidget,
    );
    // Worth a retry: the reason stays.
    expect(confirmEnabled(tester), isTrue);

    backend.on(
      'POST',
      _cancel,
      PortalReply.fixture('clinics.paris.appointment.cancel.post.200.json'),
    );
    await tapVisible(tester, find.text('Réessayer'));
    expect(find.text('Rendez-vous annulé'), findsOneWidget);
    expect(
      backend.requestsTo(_cancel).map((request) => utf8.decode(request.body)),
      ['{"reason":"unavailable"}', '{"reason":"unavailable"}'],
    );
  });
}
