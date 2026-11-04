// Screen 4 with the account's booking requests (captures): a pending one to
// come, the declined ones (expired, refused) and their pills, a confirmed
// one left out, their failure and retry (the appointments unaffected), a
// reload after a change, and the account without a clinic (its requests,
// then « Aucune clinique rattachée », no plus button).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_request_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointments_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';

import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _requests = '$api/me/booking-requests?limit=50';
const _upcoming = '$parisBase/appointments?scope=upcoming';
const _past = '$parisBase/appointments?scope=past';

FakePortalBackend _backend(String requests) => julienBackend()
  ..on('GET', _requests, PortalReply.fixture(requests))
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
    PortalReply.fixture('clinics.paris.appointments.past.page2.get.200.json'),
  );

Finder _request(String text) => find.descendant(
  of: find.byType(AppointmentRequestCard),
  matching: find.text(text),
);

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    SessionManager? session,
  }) => pumpStep(
    tester,
    AppointmentsPage(
      onBook: (context) => exits.add('book'),
      onReschedule: (context, id) => exits.add('reschedule $id'),
      onFillQuestionnaire: (context, id) => exits.add('questionnaire $id'),
      onFindClinic: (context) => exits.add('clinics'),
    ),
    backend: backend,
    session: session,
  );

  testWidgets('a pending request to come (capture): under « Demandes de '
      'rendez-vous », before the appointments; not in « Passés »', (
    tester,
  ) async {
    await pump(tester, _backend('me.booking-requests.pending.get.200.json'));

    expect(find.text('Demandes de rendez-vous'), findsOneWidget);
    expect(_request('14:00 · Capture'), findsOneWidget);
    expect(_request('En attente'), findsOneWidget);
    expect(_request('Consultation'), findsOneWidget);
    expect(_request('Clinique Vétérinaire de Lyon'), findsOneWidget);
    expect(
      _request('La clinique doit confirmer votre demande.'),
      findsOneWidget,
    );
    expect(_request('JEU'), findsOneWidget);
    expect(_request('12'), findsOneWidget);
    expect(
      tester
          .widget<StatusPill>(find.widgetWithText(StatusPill, 'En attente'))
          .tone,
      StatusTone.neutral,
    );
    // The requests come first.
    expect(
      tester.getTopLeft(find.byType(AppointmentRequestCard)).dy,
      lessThan(tester.getTopLeft(find.text('10:30 · Oslo').first).dy),
    );

    await tester.tap(find.text('Passés'));
    await tester.pumpAndSettle();
    expect(find.text('Demandes de rendez-vous'), findsNothing);
  });

  testWidgets('declined (capture): expired and refused, the soonest first, '
      'their pills and lines', (tester) async {
    await pump(tester, _backend('me.booking-requests.declined.get.200.json'));

    final cards = tester
        .widgetList<AppointmentRequestCard>(find.byType(AppointmentRequestCard))
        .map((card) => card.request.startAt.toIso8601String());
    expect(cards, [
      '2026-11-05T09:00:00+01:00',
      '2026-11-09T09:00:00+01:00',
      '2026-11-10T09:00:00+01:00',
    ]);
    expect(_request('Expirée'), findsNWidgets(2));
    expect(_request('Refusée'), findsOneWidget);
    expect(
      tester
          .widget<StatusPill>(find.widgetWithText(StatusPill, 'Refusée'))
          .tone,
      StatusTone.danger,
    );
    expect(
      _request('Sans réponse de la clinique à temps, la demande a expiré.'),
      findsNWidgets(2),
    );
    expect(
      _request("La clinique n'a pas pu confirmer ce rendez-vous."),
      findsOneWidget,
    );
  });

  testWidgets('a confirmed request of the active clinic is left out (its '
      'appointment shows)', (tester) async {
    await pump(
      tester,
      _backend('me.booking-requests.confirmed.get.200.json')..on(
        'GET',
        _requests,
        editedReply('me.booking-requests.confirmed.get.200.json', (body) {
          final request =
              ((body! as Map<String, Object?>)['items']! as List<Object?>)
                      .single!
                  as Map<String, Object?>;
          // Paris is the active clinic.
          (request['clinic']! as Map<String, Object?>)['name'] =
              ' clinique vétérinaire de PARIS';
        }),
      ),
    );

    expect(find.text('Demandes de rendez-vous'), findsNothing);
    expect(find.byType(AppointmentRequestCard), findsNothing);
  });

  testWidgets('a confirmed request of another clinic (capture: Lyon, Paris '
      'active): kept, « Confirmée », where its appointment is', (tester) async {
    await pump(tester, _backend('me.booking-requests.confirmed.get.200.json'));

    expect(find.text('Demandes de rendez-vous'), findsOneWidget);
    expect(_request('09:00 · Gaïa'), findsOneWidget);
    expect(
      tester
          .widget<StatusPill>(find.widgetWithText(StatusPill, 'Confirmée'))
          .tone,
      StatusTone.success,
    );
    expect(
      _request(
        'Le rendez-vous apparaît dans les rendez-vous de cette clinique.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('another session: the requests read again with its tokens, '
      "the first account's gone", (tester) async {
    final session = await memorySession(pair('A'));
    final backend = _backend('me.booking-requests.pending.get.200.json')
      ..onRequest(
        'GET',
        _requests,
        (request) => PortalReply.fixture(
          bearerOf(request) == 'Bearer A'
              ? 'me.booking-requests.pending.get.200.json'
              : 'me.booking-requests.get.200.json',
        ),
      );
    await pump(tester, backend, session: session);
    expect(_request('14:00 · Capture'), findsOneWidget);

    await session.open(pair('B'));
    await tester.pumpAndSettle();

    expect(bearerOf(backend.requestsTo(_requests).last), 'Bearer B');
    expect(find.byType(AppointmentRequestCard), findsNothing);
  });

  testWidgets('the requests failed: a danger callout and a retry, the '
      'appointments shown', (tester) async {
    final backend = _backend('me.booking-requests.pending.get.200.json')
      ..on('GET', _requests, problem('service_unavailable', 503));
    await pump(tester, backend);

    expect(
      find.text('Impossible de charger vos demandes de rendez-vous.'),
      findsOneWidget,
    );
    expect(find.text('10:30 · Oslo'), findsWidgets);

    backend.on(
      'GET',
      _requests,
      PortalReply.fixture('me.booking-requests.pending.get.200.json'),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(KivetoCallout),
        matching: find.text('Réessayer'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_request('14:00 · Capture'), findsOneWidget);
  });

  testWidgets('a change elsewhere (the revision bumped): the requests read '
      'again, without a manual refresh', (tester) async {
    final backend = _backend('me.booking-requests.get.200.json');
    final container = await pump(tester, backend);
    expect(find.byType(AppointmentRequestCard), findsNothing);

    backend.on(
      'GET',
      _requests,
      PortalReply.fixture('me.booking-requests.pending.get.200.json'),
    );
    container.read(appointmentsRevisionProvider.notifier).bump();
    await tester.pumpAndSettle();

    expect(_request('En attente'), findsOneWidget);
  });

  testWidgets('pull-to-refresh reads /me and the requests again', (
    tester,
  ) async {
    final backend = _backend('me.booking-requests.pending.get.200.json');
    await pump(tester, backend);
    expect(backend.requestsTo(_requests), hasLength(1));
    expect(backend.requestsTo('$api/me'), hasLength(1));

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_requests), hasLength(2));
    expect(backend.requestsTo('$api/me'), hasLength(2));
  });

  testWidgets('no clinic: the requests, then « Aucune clinique rattachée » '
      'and « Trouver une clinique »; no plus button', (tester) async {
    await pump(
      tester,
      _backend(
        'me.booking-requests.pending.get.200.json',
      )..on('GET', '$api/me', PortalReply.fixture('me.no-clinic.get.200.json')),
    );

    expect(iconButton(LucideGlyph.plus), findsNothing);
    expect(_request('14:00 · Capture'), findsOneWidget);
    expect(find.text('Aucune clinique rattachée'), findsOneWidget);
    expect(
      find.text('Trouvez une clinique pour prendre un premier rendez-vous.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(KivetoPageHeader, 'Rendez-vous'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(KivetoButton, 'Trouver une clinique'));
    expect(exits, ['clinics']);
  });

  test(
    'the pill and the line of a status or reason this app does not know',
    () {
      final l10n = AppLocalizationsFr();
      AppointmentRequest request(
        AppointmentRequestStatus status, [
        DeclineReason? reason,
      ]) => AppointmentRequest(
        id: const AppointmentRequestId('r'),
        clinicName: 'C',
        motifLabel: 'M',
        startAt: ClinicInstant.parse('2026-11-12T14:00:00+01:00'),
        status: status,
        declineReason: reason,
      );

      expect(
        appointmentRequestPill(l10n, request(AppointmentRequestStatus.unknown)),
        ('En attente', StatusTone.neutral),
      );
      expect(
        appointmentRequestLine(l10n, request(AppointmentRequestStatus.unknown)),
        isNull,
      );
      final unknown = request(
        AppointmentRequestStatus.declined,
        DeclineReason.unknown,
      );
      expect(appointmentRequestPill(l10n, unknown), (
        'Refusée',
        StatusTone.neutral,
      ));
      expect(appointmentRequestLine(l10n, unknown), isNull);
      // Refused without a reason: refused.
      final refused = request(AppointmentRequestStatus.declined);
      expect(appointmentRequestPill(l10n, refused), (
        'Refusée',
        StatusTone.danger,
      ));
      expect(
        appointmentRequestLine(l10n, refused),
        "La clinique n'a pas pu confirmer ce rendez-vous.",
      );
      for (final reason in [
        DeclineReason.cancelled,
        DeclineReason.accountDeleted,
      ]) {
        final cancelled = request(AppointmentRequestStatus.declined, reason);
        expect(appointmentRequestPill(l10n, cancelled), (
          'Annulée',
          StatusTone.danger,
        ));
        expect(
          appointmentRequestLine(l10n, cancelled),
          'La demande a été annulée.',
        );
      }
    },
  );
}
