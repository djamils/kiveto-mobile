// The reschedule on the captures: the appointment of the 9th and its line,
// Dupont chosen, a slot of the 11th, the POST and « Rendez-vous reporté »;
// the slot taken meanwhile (struck, the warning, reloaded), the refusals,
// no network, the appointment gone (404), one that may not move.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/patient/patient.dart'
    show PetId, careItemsProvider;
import 'package:kiveto_mobile/features/scheduling/presentation/reschedule_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _appointment = '$parisBase/appointments/$bookedId';
const _reschedule = '$_appointment/reschedule';
const _careItems = '$parisBase/pets/$osloId/care-items';

Finder _slot(String startAt) => find.byKey(ValueKey('slot-$startAt'));

FakePortalBackend _backend() => julienBackend()
  ..on(
    'GET',
    _appointment,
    PortalReply.fixture('clinics.paris.appointment.get.200.json'),
  )
  ..on(
    'GET',
    _careItems,
    PortalReply.fixture('clinics.paris.pet.care-items.get.200.json'),
  );

void main() {
  late List<String> exits;
  late List<PortalFile> shared;
  // The global rect each share received (the iPad popover anchor).
  late List<Rect> origins;

  setUp(() {
    exits = [];
    shared = [];
    origins = [];
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend,
  ) => pumpStep(
    tester,
    ReschedulePage(
      appointmentId: bookedId,
      onBack: (context) => exits.add('back'),
      onDone: (context) => exits.add('done'),
    ),
    backend: backend,
    overrides: [
      calendarSharerProvider.overrideWithValue((file, origin) async {
        shared.add(file);
        origins.add(origin);
      }),
    ],
  );

  /// The 11th at 10:30, on the second week.
  Future<void> chooseWednesday(WidgetTester tester) async {
    await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    await tapVisible(tester, find.byKey(const ValueKey('day-2026-11-11')));
    await tapVisible(tester, _slot('2026-11-11T10:30:00+01:00'));
  }

  testWidgets('moved (captures): the title, the current slot, Dupont chosen; '
      'the body; « Rendez-vous reporté », the calendar, back to the list', (
    tester,
  ) async {
    final backend = _backend()
      ..on(
        'POST',
        _reschedule,
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.post.200.json',
        ),
      )
      ..on(
        'GET',
        '$_appointment/calendar.ics',
        PortalReply.bytes(
          utf8.encode('BEGIN:VCALENDAR\r\nEND:VCALENDAR\r\n'),
          contentType: 'text/calendar',
        ),
      );
    final container = await pump(tester, backend);
    container.listen(careItemsProvider(const PetId(osloId)), (_, _) {});
    await tester.pumpAndSettle();

    expect(find.text('Reporter le rendez-vous'), findsOneWidget);
    expect(
      find.text('Oslo · Consultation · actuellement lun. 9 nov. à 10:00'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<KivetoChoiceChip>(
            find.widgetWithText(KivetoChoiceChip, 'Dr Marc Dupont'),
          )
          .selected,
      isTrue,
    );
    expect(find.text('Nouveau créneau'), findsOneWidget);
    expect(find.text('Choisissez un créneau'), findsOneWidget);
    expect(enabled(tester, 'Confirmer'), isFalse);

    await chooseWednesday(tester);
    expect(find.text('Mer. 11 nov. à 10:30'), findsOneWidget);
    await tester.tap(button('Confirmer'));
    await tester.pumpAndSettle();

    expect(
      utf8.decode(backend.requestsTo(_reschedule).single.body),
      '{"startAt":"2026-11-11T10:30:00+01:00","practitionerId":"$dupontId"}',
    );
    expect(find.text('Rendez-vous reporté'), findsOneWidget);
    expect(container.read(appointmentsRevisionProvider), 1);
    expect(backend.requestsTo(_careItems), hasLength(2));
    expect(
      find.text(
        'Mercredi 11 novembre à 10:30\nOslo · Consultation · Dr Marc Dupont',
      ),
      findsOneWidget,
    );
    expect(
      find.text("Annulation en ligne possible jusqu'au mar. 10 nov. à 10:30."),
      findsOneWidget,
    );

    final buttonRect = tester.getRect(
      find.widgetWithText(KivetoButton, 'Ajouter à mon calendrier'),
    );
    await tester.tap(find.text('Ajouter à mon calendrier'));
    await tester.pumpAndSettle();
    expect(shared.single.fileName, 'rendez-vous-2026-11-11.ics');
    // The tapped button's global rect: the share sheet's anchor on iPad.
    expect(origins.single, buttonRect);
    expect(buttonRect.isEmpty, isFalse);

    await tester.tap(find.text('Retour à mes rendez-vous'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(exits, ['done', 'done']);
  });

  testWidgets('the slot taken meanwhile (capture): struck, the warning, the '
      'availability read again', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _reschedule,
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.slot-taken.post.409.json',
          status: 409,
        ),
      );
    await pump(tester, backend);
    await chooseWednesday(tester);
    backend.on(
      'GET',
      availabilityPath('2026-11-03', '2026-11-16'),
      editedReply('clinics.paris.booking.availability.get.200.json', (body) {
        final wednesday =
            ((body! as Map<String, Object?>)['days']! as List<Object?>)[8]!
                as Map<String, Object?>;
        (wednesday['slots']! as List<Object?>).removeAt(6);
      }),
    );

    await tester.tap(button('Confirmer'));
    await tester.pumpAndSettle();

    expect(
      find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('10:30, déjà pris'), findsOneWidget);
    expect(
      backend.requestsTo(availabilityPath('2026-11-03', '2026-11-16')),
      hasLength(2),
    );
    expect(enabled(tester, 'Confirmer'), isFalse);

    // Another practitioner forgets the slots taken.
    backend.on(
      'GET',
      availabilityPath('2026-11-03', '2026-11-16', practitioner: rousseauId),
      PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
    );
    await tapVisible(tester, find.text('Dr Éric Rousseau'));
    expect(find.bySemanticsLabel('10:30, déjà pris'), findsNothing);
    expect(
      find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
      findsNothing,
    );
  });

  testWidgets('moved, still pending (edited capture): the clinic confirms '
      'the new slot', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _reschedule,
        editedReply(
          'clinics.paris.appointment.reschedule.post.200.json',
          (body) => (body! as Map<String, Object?>)['status'] =
              'pending_clinic_confirmation',
        ),
      );
    await pump(tester, backend);
    await chooseWednesday(tester);

    await tester.tap(button('Confirmer'));
    await tester.pumpAndSettle();

    expect(find.text('Rendez-vous reporté'), findsOneWidget);
    expect(
      find.text(
        'La clinique doit confirmer le nouveau créneau.\n'
        "Annulation en ligne possible jusqu'au mar. 10 nov. à 10:30.",
      ),
      findsOneWidget,
    );
  });

  for (final (name, reply, message, retry, reloads, reread) in [
    (
      'not modifiable (capture)',
      PortalReply.fixture(
        'clinics.paris.appointment.reschedule.not-modifiable.post.422.json',
        status: 422,
      ),
      'Ce rendez-vous ne peut plus être modifié.',
      false,
      1,
      true,
    ),
    (
      'the window closed',
      problem('cancellation_window_closed', 422),
      "Le délai d'annulation en ligne est dépassé : contactez la clinique.",
      false,
      1,
      true,
    ),
    (
      // The appointment gone, or the slot or practitioner no longer
      // offered for its motif.
      'not found (404)',
      problem('not_found', 404),
      "Ce créneau n'est plus proposé pour ce rendez-vous. Choisissez-en un "
          'autre.',
      false,
      1,
      true,
    ),
    (
      'booking closed',
      problem('booking_not_open', 422),
      "La réservation en ligne n'est pas ouverte pour ce motif. Contactez la "
          'clinique.',
      false,
      0,
      true,
    ),
    (
      'the server down',
      problem('service_unavailable', 503),
      'Le service rencontre un problème. Réessayez dans un instant.',
      true,
      0,
      false,
    ),
  ]) {
    testWidgets('$name: its message', (tester) async {
      final backend = _backend()..on('POST', _reschedule, reply);
      final container = await pump(tester, backend);
      await chooseWednesday(tester);

      await tester.tap(button('Confirmer'));
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(container.read(appointmentsRevisionProvider), reloads);
      // Refused for good: the appointment read again.
      expect(backend.requestsTo(_appointment), hasLength(reread ? 2 : 1));
      expect(find.text('Réessayer'), retry ? findsOneWidget : findsNothing);
      if (reply.status == 404) {
        // The practitioners read again, the slot dropped.
        expect(backend.requestsTo(practitionersPath), hasLength(2));
        expect(find.text('Choisissez un créneau'), findsOneWidget);
        expect(enabled(tester, 'Confirmer'), isFalse);
      }
      if (retry) {
        await tapVisible(tester, find.text('Réessayer'));
        expect(backend.requestsTo(_reschedule), hasLength(2));
      }
    });
  }

  testWidgets('moved after the page was left: the lists still reload', (
    tester,
  ) async {
    final answer = Completer<PortalReply>();
    final backend = _backend()
      ..onRequest('POST', _reschedule, (request) => answer.future);
    final container = await pump(tester, backend);
    await chooseWednesday(tester);
    await tester.tap(button('Confirmer'));
    await tester.pump();

    // Back while the move is on its way, then the page is gone.
    await tester.tap(iconButton(LucideGlyph.chevronLeft));
    expect(exits, ['back']);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const SizedBox()),
    );
    answer.complete(
      PortalReply.fixture('clinics.paris.appointment.reschedule.post.200.json'),
    );
    await tester.pumpAndSettle();

    expect(container.read(appointmentsRevisionProvider), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the appointment gone (404, capture): « Rendez-vous '
      'introuvable », back', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        _appointment,
        PortalReply.fixture(
          'clinics.paris.appointment.not-found.get.404.json',
          status: 404,
        ),
      );
    await pump(tester, backend);

    expect(find.text('Rendez-vous introuvable'), findsOneWidget);
    await tester.tap(iconButton(LucideGlyph.chevronLeft));
    expect(exits, ['back']);
  });

  testWidgets('a failure, then booked by the clinic: it may not move online', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on('GET', _appointment, problem('oops', 503));
    await pump(tester, backend);
    expect(find.text('Réessayer'), findsOneWidget);

    backend.on(
      'GET',
      _appointment,
      editedReply(
        'clinics.paris.appointment.get.200.json',
        (body) => (body! as Map<String, Object?>)['source'] = 'clinic',
      ),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ce rendez-vous ne peut pas être reporté en ligne.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Retour'));
    expect(exits, ['back']);
  });
}
