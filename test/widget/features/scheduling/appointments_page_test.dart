// Screen 4 on the captures: the upcoming C-28 cards (the clinic's booking
// without « Reporter », the portal one with the questionnaire banner), the
// window over, a pending one, the past ones page after page, the failures
// of a next page (a retry, a stale cursor), the empty tabs, the failures
// of the list (a 404 says the clinic is gone), the calendar, the exits.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointments_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _upcoming = '$parisBase/appointments?scope=upcoming';
const _past = '$parisBase/appointments?scope=past';
const _clinicBooked = '01a19a12-6840-7d19-bf1f-7604a862c028';

String _cursor() =>
    (jsonDecode(
          File(
            '$portalFixtures/clinics.paris.appointments.past.page1.get.200.json',
          ).readAsStringSync(),
        ) as Map<String, Object?>)['nextCursor']!
        as String;

Finder _card(String id) => find.byWidgetPredicate(
  (widget) => widget is AppointmentCard && widget.appointment.id.value == id,
);

Finder _inCard(String id, String text) =>
    find.descendant(of: _card(id), matching: find.text(text));

FakePortalBackend _backend() => julienBackend()
  ..on(
    'GET',
    _upcoming,
    PortalReply.fixture(
      'clinics.paris.appointments.upcoming.booked.get.200.json',
    ),
  )
  ..on(
    'GET',
    _past,
    PortalReply.fixture('clinics.paris.appointments.past.page1.get.200.json'),
  )
  ..on(
    'GET',
    '$_past&cursor=${_cursor()}',
    PortalReply.fixture('clinics.paris.appointments.past.page2.get.200.json'),
  );

void main() {
  late List<String> exits;
  late List<PortalFile> shared;

  setUp(() {
    exits = [];
    shared = [];
  });

  Widget page() => AppointmentsPage(
    onBook: (context) => exits.add('book'),
    onReschedule: (context, id) => exits.add('reschedule $id'),
    onFillQuestionnaire: (context, id) => exits.add('questionnaire $id'),
  );

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    DateTime? now,
  }) => pumpStep(
    tester,
    page(),
    backend: backend,
    clock: now == null ? null : FixedClock(now),
    overrides: [
      calendarSharerProvider.overrideWithValue((file) async {
        shared.add(file);
      }),
    ],
  );

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle();
  }

  testWidgets("upcoming (capture): the header, the tabs, the clinic's "
      'booking (« Annuler » alone, its window) and the portal one (the '
      'questionnaire, « Reporter »)', (tester) async {
    await pump(tester, _backend());

    expect(
      find.widgetWithText(KivetoPageHeader, 'Rendez-vous'),
      findsOneWidget,
    );
    expect(iconButton(LucideGlyph.plus), findsOneWidget);
    expect(find.text('À venir'), findsOneWidget);
    expect(find.text('Passés'), findsOneWidget);

    expect(_inCard(_clinicBooked, 'MER'), findsOneWidget);
    // The tile reads the whole day out.
    expect(
      find.descendant(
        of: _card(_clinicBooked),
        matching: find.bySemanticsLabel(RegExp('^Mercredi 11 novembre')),
      ),
      findsOneWidget,
    );
    expect(_inCard(_clinicBooked, '11'), findsOneWidget);
    expect(_inCard(_clinicBooked, 'nov.'), findsOneWidget);
    expect(_inCard(_clinicBooked, '10:30 · Oslo'), findsOneWidget);
    expect(_inCard(_clinicBooked, 'Confirmé'), findsOneWidget);
    expect(_inCard(_clinicBooked, 'Rendez-vous'), findsOneWidget);
    expect(
      _inCard(
        _clinicBooked,
        'Dr Éric Rousseau · Clinique Vétérinaire de Paris',
      ),
      findsOneWidget,
    );
    expect(_inCard(_clinicBooked, 'Annuler'), findsOneWidget);
    expect(_inCard(_clinicBooked, 'Reporter'), findsNothing);
    expect(_inCard(_clinicBooked, 'Questionnaire à compléter'), findsNothing);
    expect(
      _inCard(
        _clinicBooked,
        "Annulation en ligne possible jusqu'au mar. 10 nov. à 10:30.",
      ),
      findsOneWidget,
    );
    expect(_inCard(_clinicBooked, 'Ajouter à mon calendrier'), findsOneWidget);

    expect(_inCard(bookedId, 'Questionnaire à compléter'), findsOneWidget);
    expect(
      _inCard(bookedId, '2 min · motif, symptômes, traitements en cours'),
      findsOneWidget,
    );
    expect(_inCard(bookedId, 'Reporter'), findsOneWidget);
    expect(_inCard(bookedId, 'Annuler'), findsOneWidget);

    await tester.tap(iconButton(LucideGlyph.plus));
    await tapVisible(tester, _inCard(bookedId, 'Questionnaire à compléter'));
    await tapVisible(tester, _inCard(bookedId, 'Reporter'));
    expect(exits, ['book', 'questionnaire $bookedId', 'reschedule $bookedId']);
  });

  testWidgets('the window over: no action, « contactez la clinique »', (
    tester,
  ) async {
    await pump(tester, _backend(), now: DateTime.utc(2026, 11, 12, 10));

    expect(find.text('Annuler'), findsNothing);
    expect(find.text('Reporter'), findsNothing);
    expect(
      _inCard(
        _clinicBooked,
        "Le délai d'annulation en ligne est dépassé : contactez la clinique.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('a pending appointment: neutral, « En attente », the clinic '
      'confirms', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        _upcoming,
        PortalReply.json(
          jsonEncode({
            'items': [
              jsonDecode(
                File(
                  '$portalFixtures/clinics.paris.appointments.pending.post.201.json',
                ).readAsStringSync(),
              ),
            ],
            'nextCursor': null,
          }),
        ),
      );
    await pump(tester, backend);

    expect(find.widgetWithText(StatusPill, 'En attente'), findsOneWidget);
    expect(
      find.text('En attente de confirmation par la clinique'),
      findsOneWidget,
    );
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Reporter'), findsOneWidget);
  });

  testWidgets('past (captures): page after page, neutral, no action', (
    tester,
  ) async {
    final backend = _backend();
    await pump(tester, backend);

    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    expect(find.widgetWithText(StatusPill, 'Annulé'), findsNWidgets(2));
    expect(
      find.widgetWithText(StatusPill, 'Annulé par la clinique'),
      findsOneWidget,
    );
    expect(find.byType(AppointmentCard), findsNWidgets(3));
    expect(find.text('Annuler'), findsNothing);
    expect(find.text('Ajouter à mon calendrier'), findsNothing);
    expect(backend.requestsTo('$_past&cursor=${_cursor()}'), hasLength(1));
  });

  testWidgets('a next page that fails: the cards stay, a retry; a stale '
      'cursor reloads the first page', (tester) async {
    final backend = _backend()
      ..on('GET', '$_past&cursor=${_cursor()}', problem('oops', 503));
    await pump(tester, backend);
    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    expect(find.text('Impossible de charger la suite.'), findsOneWidget);
    expect(find.byType(AppointmentCard), findsNWidgets(2));

    // Stale once, then the second page.
    var stale = true;
    backend.onRequest('GET', '$_past&cursor=${_cursor()}', (request) {
      if (stale) {
        stale = false;
        return problem('cursor_invalid', 400);
      }
      return PortalReply.fixture(
        'clinics.paris.appointments.past.page2.get.200.json',
      );
    });
    await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    expect(backend.requestsTo(_past), hasLength(2));
    expect(
      find.widgetWithText(StatusPill, 'Annulé par la clinique'),
      findsOneWidget,
    );
  });

  testWidgets('a next page answering after a clinic switch is dropped', (
    tester,
  ) async {
    final held = Completer<void>();
    final backend = _backend()
      ..onRequest('GET', '$_past&cursor=${_cursor()}', (request) async {
        await held.future;
        return PortalReply.fixture(
          'clinics.paris.appointments.past.page2.get.200.json',
        );
      })
      ..on(
        'GET',
        '$api/clinics/$lyonId/appointments?scope=past',
        PortalReply.json('{"items":[],"nextCursor":null}'),
      )
      ..on(
        'GET',
        '$api/clinics/$lyonId/appointments?scope=upcoming',
        PortalReply.json('{"items":[],"nextCursor":null}'),
      );
    final container = await pump(tester, backend);
    // The next page is on its way as soon as its end row shows (a spinner:
    // no pumpAndSettle).
    await tester.tap(find.text('Passés'));
    await pumpBriefly(tester);
    expect(backend.requestsTo('$_past&cursor=${_cursor()}'), hasLength(1));

    unawaited(
      container
          .read(activeClinicProvider.notifier)
          .select(const ClinicId(lyonId)),
    );
    await tester.pumpAndSettle();
    held.complete();
    await tester.pumpAndSettle();

    expect(find.text('Aucun rendez-vous passé'), findsOneWidget);
    expect(_card('01a19a12-682c-7440-a2d4-48953f1bcc94'), findsNothing);
    expect(find.byType(AppointmentCard), findsNothing);
  });

  testWidgets('an empty first page with a next one: no empty state, the '
      'next page read', (tester) async {
    final backend = julienBackend()
      ..on('GET', _upcoming, PortalReply.json('{"items":[],"nextCursor":null}'))
      ..on('GET', _past, PortalReply.json('{"items":[],"nextCursor":"c1"}'))
      ..on(
        'GET',
        '$_past&cursor=c1',
        PortalReply.fixture(
          'clinics.paris.appointments.past.page2.get.200.json',
        ),
      );
    await pump(tester, backend);

    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();

    expect(find.text('Aucun rendez-vous passé'), findsNothing);
    expect(backend.requestsTo('$_past&cursor=c1'), hasLength(1));
    expect(_card('01a19a12-682c-7440-a2d4-48953f1bcc94'), findsOneWidget);
  });

  testWidgets('empty tabs: « Aucun rendez-vous à venir » and « Prendre '
      'rendez-vous », « Aucun rendez-vous passé »', (tester) async {
    final backend = julienBackend()
      ..on('GET', _upcoming, PortalReply.json('{"items":[],"nextCursor":null}'))
      ..on('GET', _past, PortalReply.json('{"items":[],"nextCursor":null}'));
    await pump(tester, backend);

    expect(find.text('Aucun rendez-vous à venir'), findsOneWidget);
    await tester.tap(find.text('Prendre rendez-vous'));
    expect(exits, ['book']);

    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun rendez-vous passé'), findsOneWidget);
  });

  testWidgets('the list fails: the error and its retry; a 404 says the '
      'clinic is gone', (tester) async {
    final backend = julienBackend()..on('GET', _upcoming, problem('oops', 503));
    await pump(tester, backend);
    expect(find.byType(ErrorView), findsOneWidget);
    int meReads() => backend.requestsTo('$api/me').length;
    final reads = meReads();

    backend.on(
      'GET',
      _upcoming,
      PortalReply.fixture('clinics.unknown.home.get.404.json', status: 404),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    // A 503: the list again, not /me.
    expect(meReads(), reads);
    expect(find.text('Clinique indisponible'), findsOneWidget);
    expect(
      find.text("Votre accès à cette clinique n'est plus actif."),
      findsOneWidget,
    );

    backend.on(
      'GET',
      _upcoming,
      PortalReply.fixture(
        'clinics.paris.appointments.upcoming.booked.get.200.json',
      ),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    // A 404: /me says which clinics remain.
    expect(meReads(), reads + 1);
    expect(_card(_clinicBooked), findsOneWidget);
  });

  testWidgets('pull-to-refresh reads the lists again', (tester) async {
    final backend = _backend();
    await pump(tester, backend);

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_upcoming), hasLength(2));
  });

  testWidgets('the calendar: the .ics shared; a cancelled one (404, '
      'capture) says it could not', (tester) async {
    const calendar = '$parisBase/appointments/$bookedId/calendar.ics';
    final backend = _backend()
      ..on(
        'GET',
        calendar,
        PortalReply.bytes(
          File('$portalFixtures/clinics.paris.appointment.calendar.get.200.ics')
              .readAsBytesSync(),
          contentType: 'text/calendar; charset=utf-8',
        ),
      );
    await pump(tester, backend);

    await tapVisible(tester, _inCard(bookedId, 'Ajouter à mon calendrier'));
    expect(shared.single.fileName, 'rendez-vous-2026-11-11.ics');

    backend.on(
      'GET',
      calendar,
      PortalReply.fixture(
        'clinics.paris.appointment.calendar.cancelled.get.404.json',
        status: 404,
      ),
    );
    await tapVisible(tester, _inCard(bookedId, 'Ajouter à mon calendrier'));
    expect(
      find.text("Impossible d'ajouter ce rendez-vous à votre calendrier."),
      findsOneWidget,
    );
  });
}
