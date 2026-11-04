// Slice 4 in the real app (router, shell, seams, PortalHttp on the fake
// backend): the booking from the home (12 → 13 → 3 → 14, one POST with the
// draft's key and the slot's wire startAt, the home following without a
// refresh), closing the wizard from the Rendez-vous tab (a new draft, a new
// key), the Rendez-vous tab (cards, past pages, another clinic), a
// reschedule then a cancellation followed by the lists and the home, and
// the .ics handed to the share sheet.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/portal_api/fake_portal_backend.dart';
import '../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _lyon = '01960000-0000-7000-8000-000000000101';
const _oslo = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _consultation = '01a19a10-d467-7bc2-9344-790c64b6ab03';
const _dupont = '01a19a0e-23cd-70de-a551-46681e052884';
const _booked = '01a1a297-4a0a-7093-83f7-14de2798613e';
const _base = '$api/clinics/$_paris';
const _availability =
    '$_base/booking/availability?motifId=$_consultation'
    '&practitionerId=$_dupont&from=2026-11-03&to=2026-11-16';

String _location(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .toString();

/// The pushed match on top of the current configuration.
String _top(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;

/// Numbered keys: `key-1`, `key-2`…
final class _Keys {
  int count = 0;

  IdempotencyKey next() => IdempotencyKey('key-${++count}');
}

/// The capture [fixture] with [change] applied to its JSON body.
String _edited(
  String fixture,
  void Function(Map<String, Object?> body) change,
) {
  final body = jsonDecode(
    File('$portalFixtures/$fixture').readAsStringSync(),
  ) as Map<String, Object?>;
  change(body);
  return jsonEncode(body);
}

/// Julien's Paris home, then (after a change) one whose next appointment
/// is the one booked.
FakePortalBackend _julien({required bool Function() booked}) {
  final backend = FakePortalBackend()
    ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
    ..on(
      'GET',
      '$_base/pets',
      PortalReply.fixture('clinics.paris.pets.get.200.json'),
    )
    ..on(
      'GET',
      '$_base/booking/motifs?petId=$_oslo',
      PortalReply.fixture('clinics.paris.booking.motifs.get.200.json'),
    )
    ..on(
      'GET',
      '$_base/booking/practitioners?motifId=$_consultation',
      PortalReply.fixture('clinics.paris.booking.practitioners.get.200.json'),
    )
    ..on(
      'GET',
      _availability,
      PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
    )
    ..on(
      'POST',
      '$_base/appointments',
      PortalReply.fixture(
        'clinics.paris.appointments.post.201.json',
        status: 201,
      ),
    )
    ..onRequest('GET', '$_base/home', (request) {
      if (!booked()) {
        return PortalReply.fixture('clinics.paris.home.get.200.json');
      }
      final appointment = jsonDecode(
        File('$portalFixtures/clinics.paris.appointments.post.201.json')
            .readAsStringSync(),
      ) as Map<String, Object?>;
      return PortalReply.json(
        _edited('clinics.paris.home.get.200.json', (body) {
          body['nextAppointment'] = appointment;
        }),
      );
    });
  return backend;
}

/// The icon button drawing [glyph].
Finder _iconButton(LucideGlyph glyph) => find.byWidgetPredicate(
  (widget) => widget is KivetoIconButton && widget.glyph == glyph,
);

/// The `nextCursor` of the first page of the past appointments.
String _pastCursor() =>
    (jsonDecode(
          File(
            '$portalFixtures/clinics.paris.appointments.past.page1.get.200.json',
          ).readAsStringSync(),
        ) as Map<String, Object?>)['nextCursor']!
        as String;

/// [text] in the upcoming card of [appointmentId].
Finder _inCard(String appointmentId, String text) => find.descendant(
  of: find.byKey(
    ValueKey((AppointmentScope.upcoming, AppointmentId(appointmentId))),
  ),
  matching: find.text(text),
);

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapInFlow(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('from the home: Oslo, Consultation, Dr Marc Dupont, Monday '
      "10:00, confirmed; one POST with the draft's key and the slot's "
      'startAt; « Plus tard » shows the home with the new appointment, and '
      'the Rendez-vous tab its card', (tester) async {
    final keys = _Keys();
    var booked = false;
    final backend = _julien(booked: () => booked)
      ..onRequest('POST', '$_base/appointments', (request) {
        booked = true;
        return PortalReply.fixture(
          'clinics.paris.appointments.post.201.json',
          status: 201,
        );
      })
      ..onRequest('GET', '$_base/appointments?scope=upcoming', (request) {
        final created = jsonDecode(
          File('$portalFixtures/clinics.paris.appointments.post.201.json')
              .readAsStringSync(),
        );
        return PortalReply.json(
          jsonEncode({
            'items': [if (booked) created],
            'nextCursor': null,
          }),
        );
      });
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      overrides: [bookingKeyFactoryProvider.overrideWithValue(keys.next)],
    );
    expect(find.text('Mer. 11 nov. · 10:30'), findsOneWidget);

    await _tapVisible(tester, find.text('Prendre rendez-vous'));
    expect(find.text('Étape 1 sur 4'), findsOneWidget);
    expect(find.text('Oslo'), findsWidgets);
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Étape 2 sur 4'), findsOneWidget);
    await tester.tap(find.text('Consultation'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Étape 3 sur 4'), findsOneWidget);
    await _tapInFlow(tester, find.byKey(const ValueKey('day-2026-11-09')));
    await _tapInFlow(
      tester,
      find.byKey(const ValueKey('slot-2026-11-09T10:00:00+01:00')),
    );
    expect(find.text('Lun. 9 nov. à 10:00'), findsOneWidget);
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Étape 4 sur 4'), findsOneWidget);
    expect(find.text('Lundi 9 novembre à 10:00'), findsOneWidget);
    final key = container.read(bookingWizardProvider).draft.key;
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    final posts = backend.requests.where((request) => request.method == 'POST');
    expect(posts, hasLength(1));
    expect(posts.single.headers['Idempotency-Key'], key.value);
    expect(
      (jsonDecode(utf8.decode(posts.single.body))
          as Map<String, Object?>)['startAt'],
      '2026-11-09T10:00:00+01:00',
    );
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);

    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.home);
    expect(find.text('Lun. 9 nov. · 10:00'), findsOneWidget);
    expect(backend.requestsTo('$_base/home'), hasLength(2));

    await tester.tap(find.text('Rendez-vous'));
    await tester.pumpAndSettle();
    expect(_location(container), AppRoutes.appointments);
    expect(_inCard(_booked, '10:00 · Oslo'), findsOneWidget);
    expect(_inCard(_booked, 'Consultation'), findsOneWidget);
  });

  testWidgets('the steps go back: the chips and backs of steps 2 to 4, '
      '« Modifier » of the recap and of a pet refused, the slot taken from '
      'step 4 to step 3, X to the home; then the questionnaire', (
    tester,
  ) async {
    // Refused (the pet), then the slot taken, then booked.
    var posts = 0;
    final backend = _julien(booked: () => false)
      ..onRequest('POST', '$_base/appointments', (request) {
        posts++;
        return switch (posts) {
          1 => problem('pet_not_bookable', 422),
          2 => PortalReply.fixture(
            'clinics.paris.appointments.slot-taken.post.409.json',
            status: 409,
          ),
          _ => PortalReply.fixture(
            'clinics.paris.appointments.post.201.json',
            status: 201,
          ),
        };
      })
      // The questionnaire (15) of the appointment booked.
      ..on(
        'GET',
        '$_base/appointments/$_booked',
        PortalReply.fixture('clinics.paris.appointment.get.200.json'),
      )
      ..on(
        'GET',
        '$_base/appointments/$_booked/questionnaire',
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.get.200.json',
        ),
      );
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
    );
    Future<void> next() async {
      await _tapInFlow(tester, find.widgetWithText(KivetoButton, 'Continuer'));
    }

    Future<void> back() async {
      await _tapInFlow(tester, _iconButton(LucideGlyph.chevronLeft));
    }

    void onStep(int step) {
      for (var i = 1; i <= 4; i++) {
        expect(
          find.text('Étape $i sur 4'),
          i == step ? findsOneWidget : findsNothing,
          reason: 'step $step',
        );
      }
    }

    await _tapVisible(tester, find.text('Prendre rendez-vous'));
    await next();
    await tester.tap(find.text('Consultation'));
    await tester.pumpAndSettle();
    await next();
    onStep(3);

    // Step 3: the pet chip to step 1; step 2: back to step 1.
    await tester.tap(find.widgetWithText(KivetoSummaryChip, 'Oslo'));
    await tester.pumpAndSettle();
    onStep(1);
    await next();
    await back();
    onStep(1);

    // Step 3: the motif chip and back, to step 2.
    await next();
    await next();
    await tester.tap(
      find.widgetWithText(KivetoSummaryChip, 'Consultation · 30 min'),
    );
    await tester.pumpAndSettle();
    onStep(2);
    await next();
    await back();
    onStep(2);
    await next();

    // Step 4: « Modifier » and back, to step 3.
    await _tapInFlow(tester, find.byKey(const ValueKey('day-2026-11-09')));
    await _tapInFlow(
      tester,
      find.byKey(const ValueKey('slot-2026-11-09T10:00:00+01:00')),
    );
    await next();
    onStep(4);
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    onStep(3);
    await next();
    await back();
    onStep(3);
    await next();

    // A pet refused: « Modifier » of the callout, to step 1.
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();
    expect(
      find.text('Cet animal ne peut plus prendre rendez-vous en ligne.'),
      findsOneWidget,
    );
    await _tapInFlow(tester, find.text('Modifier').last);
    onStep(1);

    // The slot taken: back on step 3, the warning.
    await next();
    await next();
    await next();
    onStep(4);
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();
    onStep(3);
    expect(
      find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
      findsOneWidget,
    );

    await _tapInFlow(tester, _iconButton(LucideGlyph.x));
    expect(_location(container), AppRoutes.home);
    onStep(0);
    // The home as it was left (scrolled to the booking button).
    expect(find.text('Prendre rendez-vous'), findsOneWidget);

    // Booked, then « Remplir le questionnaire maintenant ».
    await _tapVisible(tester, find.text('Prendre rendez-vous'));
    await next();
    await tester.tap(find.text('Consultation'));
    await tester.pumpAndSettle();
    await next();
    await _tapInFlow(tester, find.byKey(const ValueKey('day-2026-11-09')));
    await _tapInFlow(
      tester,
      find.byKey(const ValueKey('slot-2026-11-09T10:15:00+01:00')),
    );
    await next();
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);
    await tester.tap(find.text('Remplir le questionnaire maintenant'));
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.questionnaire(_booked));
    expect(find.text('Avant la consultation'), findsOneWidget);
    expect(
      find.text(
        'Oslo · Consultation · lun.\u00a09\u00a0nov.\u00a0à\u00a010:00',
      ),
      findsOneWidget,
    );
    expect(posts, 3);
  });

  testWidgets('from the Rendez-vous tab: X on step 2 shows the tab again; a '
      'new wizard starts empty with a new key', (tester) async {
    final keys = _Keys();
    final backend = _julien(booked: () => false)
      ..on(
        'GET',
        '$_base/appointments?scope=upcoming',
        PortalReply.fixture(
          'clinics.paris.appointments.upcoming.booked.get.200.json',
        ),
      );
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      initialLocation: AppRoutes.appointments,
      overrides: [bookingKeyFactoryProvider.overrideWithValue(keys.next)],
    );

    await tester.tap(_iconButton(LucideGlyph.plus));
    await tester.pumpAndSettle();
    final first = container.read(bookingWizardProvider).draft.key;
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 2 sur 4'), findsOneWidget);
    expect(container.read(bookingWizardProvider).draft.pet?.name, 'Oslo');

    await tester.tap(_iconButton(LucideGlyph.x));
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.appointments);
    expect(find.byType(AppointmentsPage), findsOneWidget);
    expect(find.text('Étape 2 sur 4'), findsNothing);
    expect(find.text('Étape 1 sur 4'), findsNothing);

    await tester.tap(_iconButton(LucideGlyph.plus));
    await tester.pumpAndSettle();
    final draft = container.read(bookingWizardProvider).draft;
    expect(draft.pet, isNull);
    expect(draft.key, isNot(first));

    // X on step 4, the four steps stacked over the tab: the tab again.
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Consultation'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();
    await _tapInFlow(tester, find.byKey(const ValueKey('day-2026-11-09')));
    await _tapInFlow(
      tester,
      find.byKey(const ValueKey('slot-2026-11-09T10:00:00+01:00')),
    );
    await _tapInFlow(tester, find.widgetWithText(KivetoButton, 'Continuer'));
    expect(find.text('Étape 4 sur 4'), findsOneWidget);

    await _tapInFlow(tester, _iconButton(LucideGlyph.x));

    expect(_location(container), AppRoutes.appointments);
    expect(find.byType(AppointmentsPage), findsOneWidget);
    for (var step = 1; step <= 4; step++) {
      expect(find.text('Étape $step sur 4'), findsNothing);
    }
  });

  testWidgets('the Rendez-vous tab: the upcoming cards, the past ones page '
      "after page, then Lyon's lists after a clinic switch", (tester) async {
    final page1 = jsonDecode(
      File('$portalFixtures/clinics.paris.appointments.past.page1.get.200.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    final backend = _julien(booked: () => false)
      ..on(
        'GET',
        '$_base/appointments?scope=upcoming',
        PortalReply.fixture(
          'clinics.paris.appointments.upcoming.booked.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_base/appointments?scope=past',
        PortalReply.fixture(
          'clinics.paris.appointments.past.page1.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_base/appointments?scope=past&cursor=${page1['nextCursor']}',
        PortalReply.fixture(
          'clinics.paris.appointments.past.page2.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$api/clinics/$_lyon/appointments?scope=upcoming',
        PortalReply.json('{"items":[],"nextCursor":null}'),
      )
      ..on(
        'GET',
        '$api/clinics/$_lyon/home',
        PortalReply.fixture('clinics.lyon.home.get.200.json'),
      );
    final store = InMemoryActiveClinicStore();
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      activeClinicStore: store,
      initialLocation: AppRoutes.appointments,
    );

    expect(find.text('10:30 · Oslo'), findsNWidgets(2));
    expect(find.text('Confirmé'), findsWidgets);
    expect(find.text('Reporter'), findsWidgets);

    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('Annulé par la clinique'), findsOneWidget);
    expect(find.text('Annulé'), findsNWidgets(2));

    await tester.tap(find.text('À venir'));
    await tester.pumpAndSettle();
    await store.write('01a19a10-d011-70c8-8daf-26e4db824374', _lyon);
    await container
        .read(activeClinicProvider.notifier)
        .select(const ClinicId(_lyon));
    await tester.pumpAndSettle();

    expect(find.text('Aucun rendez-vous à venir'), findsOneWidget);
    expect(
      backend.requestsTo('$api/clinics/$_lyon/appointments?scope=upcoming'),
      hasLength(1),
    );
  });

  testWidgets('« Reporter » then « Annuler »: POST reschedule, POST cancel '
      'with the reason; the lists and the home follow; the .ics reaches the '
      'share sheet', (tester) async {
    final shared = <PortalFile>[];
    var cancelled = false;
    final backend = _julien(booked: () => cancelled)
      ..onRequest('GET', '$_base/appointments?scope=upcoming', (request) {
        if (!cancelled) {
          return PortalReply.fixture(
            'clinics.paris.appointments.upcoming.booked.get.200.json',
          );
        }
        return PortalReply.json(
          _edited('clinics.paris.appointments.upcoming.booked.get.200.json', (
            body,
          ) {
            (body['items']! as List<Object?>).removeAt(1);
          }),
        );
      })
      // After the cancellation the past list holds it (`cancelled_by_client`).
      ..onRequest('GET', '$_base/appointments?scope=past', (request) {
        return cancelled
            ? PortalReply.fixture(
                'clinics.paris.appointments.past.page1.get.200.json',
              )
            : PortalReply.json('{"items":[],"nextCursor":null}');
      })
      ..on(
        'GET',
        '$_base/appointments?scope=past&cursor=${_pastCursor()}',
        PortalReply.fixture(
          'clinics.paris.appointments.past.page2.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_base/appointments/$_booked',
        PortalReply.fixture('clinics.paris.appointment.get.200.json'),
      )
      ..on(
        'GET',
        '$_base/booking/practitioners?motifId=$_consultation',
        PortalReply.fixture('clinics.paris.booking.practitioners.get.200.json'),
      )
      ..on(
        'POST',
        '$_base/appointments/$_booked/reschedule',
        PortalReply.fixture(
          'clinics.paris.appointment.reschedule.post.200.json',
        ),
      )
      ..onRequest('POST', '$_base/appointments/$_booked/cancel', (request) {
        cancelled = true;
        return PortalReply.fixture(
          'clinics.paris.appointment.cancel.post.200.json',
        );
      })
      ..on(
        'GET',
        '$_base/appointments/$_booked/calendar.ics',
        PortalReply.bytes(
          File('$portalFixtures/clinics.paris.appointment.calendar.get.200.ics')
              .readAsBytesSync(),
          contentType: 'text/calendar; charset=utf-8',
        ),
      );
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      initialLocation: AppRoutes.appointments,
      overrides: [
        calendarSharerProvider.overrideWithValue((file, _) async {
          shared.add(file);
        }),
      ],
    );

    // « Passés » read before the cancellation: nothing yet.
    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun rendez-vous passé'), findsOneWidget);
    await tester.tap(find.text('À venir'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo('$_base/home'), hasLength(1));

    // The calendar of the portal booking (the second card).
    await _tapInFlow(tester, _inCard(_booked, 'Ajouter à mon calendrier'));
    expect(shared.single.fileName, 'rendez-vous-2026-11-11.ics');
    expect(shared.single.contentType, 'text/calendar');
    expect(
      shared.single.bytes,
      File('$portalFixtures/clinics.paris.appointment.calendar.get.200.ics')
          .readAsBytesSync(),
    );

    // « Reporter plutôt » of the sheet: the reschedule on top; back to the
    // tab.
    await _tapInFlow(tester, _inCard(_booked, 'Annuler'));
    await _tapInFlow(tester, find.text('Reporter plutôt'));
    expect(find.text('Annuler ce rendez-vous ?'), findsNothing);
    expect(_top(container), AppRoutes.reschedule(_booked));
    await tester.tap(_iconButton(LucideGlyph.chevronLeft));
    await tester.pumpAndSettle();
    expect(_top(container), AppRoutes.appointments);

    await _tapInFlow(tester, _inCard(_booked, 'Reporter'));
    expect(_top(container), AppRoutes.reschedule(_booked));
    expect(find.text('Reporter le rendez-vous'), findsOneWidget);
    expect(
      find.text('Oslo · Consultation · actuellement lun. 9 nov. à 10:00'),
      findsOneWidget,
    );
    // The 11th is on the second week of the window.
    await _tapInFlow(tester, find.bySemanticsLabel('Semaine suivante'));
    await _tapInFlow(tester, find.byKey(const ValueKey('day-2026-11-11')));
    await _tapInFlow(
      tester,
      find.byKey(const ValueKey('slot-2026-11-11T10:30:00+01:00')),
    );
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();

    final reschedule = backend.requestsTo(
      '$_base/appointments/$_booked/reschedule',
    );
    expect(
      utf8.decode(reschedule.single.body),
      '{"startAt":"2026-11-11T10:30:00+01:00","practitionerId":"$_dupont"}',
    );
    expect(find.text('Rendez-vous reporté'), findsOneWidget);
    await tester.tap(find.text('Retour à mes rendez-vous'));
    await tester.pumpAndSettle();
    expect(_location(container), AppRoutes.appointments);
    expect(
      backend.requestsTo('$_base/appointments?scope=upcoming'),
      hasLength(2),
    );
    // The home read again after the reschedule.
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo('$_base/home'), hasLength(2));
    await tester.tap(find.text('Rendez-vous'));
    await tester.pumpAndSettle();

    await _tapInFlow(tester, _inCard(_booked, 'Annuler'));
    expect(find.text('Annuler ce rendez-vous ?'), findsOneWidget);
    await tester.tap(find.text('Empêchement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler le rendez-vous'));
    await tester.pumpAndSettle();

    final cancel = backend.requestsTo('$_base/appointments/$_booked/cancel');
    expect(utf8.decode(cancel.single.body), '{"reason":"unavailable"}');
    expect(find.text('Rendez-vous annulé'), findsOneWidget);
    await tester.tap(find.text('Retour à mes rendez-vous'));
    await tester.pumpAndSettle();

    expect(find.text('Rendez-vous annulé'), findsNothing);
    // The cancelled one left the upcoming list for the past one.
    expect(_inCard(_booked, 'Annuler'), findsNothing);
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    // The cancelled appointment, under « Passés ».
    final past = find.byKey(
      const ValueKey((AppointmentScope.past, AppointmentId(_booked))),
    );
    expect(past, findsOneWidget);
    expect(
      find.descendant(of: past, matching: find.text('Annulé')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: past, matching: find.text('Consultation')),
      findsOneWidget,
    );
    // The home read again after the cancellation.
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo('$_base/home'), hasLength(3));
    expect(find.text('Lun. 9 nov. · 10:00'), findsOneWidget);
  });
}
