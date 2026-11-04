// Screen 11 on the captures: Lyon (open now on the device's clock, the new
// client's motifs, the emergency number, the hours grid), a motif chosen
// (the listing draft), Paris (not online), Vercors (no new client, no
// phone, no hours), the motifs refused (booking_not_open), empty or
// failed, the sheet gone (404) or failed, the known client (its booking on
// the confirmed clinic of the same name, its record).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_page.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/opening_hours_grid.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_booking.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart'
    show phoneDialerProvider;
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _lyon = '01a19a12-79bb-7408-9051-a42bd37f652d';
const _paris = '01a19a11-0518-78b1-9eea-49198a26a6a7';
const _vercors = '01a19a12-79dd-76b5-980f-ef11ab1a74e5';
const _listings = '$api/clinic-listings';
const _parisClinic = '01960000-0000-7000-8000-000000000001';
const _lyonClinic = '01960000-0000-7000-8000-000000000101';
const _lyonMotifs = '$_listings/$_lyon/booking/motifs';

PortalReply _edited(String fixture, void Function(Object? body) change) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body));
}

FakePortalBackend _backend({String me = 'me.no-clinic.get.200.json'}) =>
    FakePortalBackend()
      ..on('GET', '$api/me', PortalReply.fixture(me))
      ..on(
        'GET',
        '$_listings/$_lyon',
        PortalReply.fixture('clinic-listings.lyon.get.200.json'),
      )
      ..on(
        'GET',
        '$_listings/$_paris',
        PortalReply.fixture('clinic-listings.paris.get.200.json'),
      )
      ..on(
        'GET',
        '$_listings/$_vercors',
        PortalReply.fixture('clinic-listings.vercors.get.200.json'),
      )
      ..on(
        'GET',
        _lyonMotifs,
        PortalReply.fixture('clinic-listings.lyon.booking.motifs.get.200.json'),
      );

void main() {
  late List<String> exits;
  late List<Uri> calls;

  setUp(() {
    exits = [];
    calls = [];
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    String listing = _lyon,
  }) async {
    final container = await pumpPage(
      tester,
      ClinicListingPage(
        listingId: listing,
        onBack: (context) => exits.add('back'),
        onChooseMotif: (context) => exits.add('motif'),
        onBookAsClient: (context) => exits.add('book'),
        onFindRecord: (context) => exits.add('record'),
      ),
      backend: backend,
      session: await memorySession(pair('A')),
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        phoneDialerProvider.overrideWithValue((uri) async {
          calls.add(uri);
          return true;
        }),
      ],
    );
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets("Lyon (capture): the header, open now on the device's clock, "
      'a new client by default, the motif, the emergency number, the '
      'hours', (tester) async {
    await pump(tester, _backend());

    expect(
      find.widgetWithText(KivetoDetailHeader, 'Clinique Vétérinaire de Lyon'),
      findsOneWidget,
    );
    expect(
      find.text('7 quai Saint-Antoine, Bâtiment B, 69002 Lyon'),
      findsOneWidget,
    );
    // Tuesday 3 November, mid-morning on the device: open until 19:00.
    expect(find.text('Ouvert · ferme à 19:00'), findsOneWidget);
    expect(find.text('Vous êtes'), findsOneWidget);
    expect(find.text('Déjà client'), findsOneWidget);
    expect(find.text('Nouveau client'), findsOneWidget);
    expect(
      find.text(
        "Vous décrirez votre animal à l'étape suivante. La clinique "
        'confirme les rendez-vous des nouveaux clients.',
      ),
      findsOneWidget,
    );
    expect(find.text('Motif'), findsOneWidget);
    expect(find.widgetWithText(KivetoListRow, 'Consultation'), findsOneWidget);
    expect(
      find.text(
        '30 min · Un problème de santé, un avis, un contrôle de '
        'routine.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Urgence ? Appelez directement la clinique au '
        '04 78 92 01 45.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Horaires'), findsOneWidget);
    final grid = find.byType(OpeningHoursGrid);
    for (final text in [
      'Lun – Ven',
      '08:30 – 19:00',
      'Samedi',
      '09:00 – 12:00',
      'Dimanche',
      'Fermé',
    ]) {
      expect(
        find.descendant(of: grid, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }

    await tester.tapOnText(find.textRange.ofSubstring('04 78'));
    await tester.pumpAndSettle();
    expect(calls, [Uri(scheme: 'tel', path: '+33478920145')]);

    await tester.tap(find.byType(KivetoIconButton).first);
    expect(exits, ['back']);
  });

  testWidgets('a motif tapped: it and the clinic name go into the listing '
      'draft, then the first step', (tester) async {
    final container = await pump(tester, _backend());

    await tester.tap(find.widgetWithText(KivetoListRow, 'Consultation'));
    await tester.pumpAndSettle();

    expect(exits, ['motif']);
    final booking = container.read(
      listingBookingProvider(const ListingId(_lyon)),
    );
    expect(booking.draft.motif?.label, 'Consultation');
    expect(booking.draft.motif?.durationMin, 30);
    expect(booking.draft.clinicId, isNull);
    expect(booking.clinicName, 'Clinique Vétérinaire de Lyon');
  });

  testWidgets('Paris (capture): not online for new clients, no motif read; '
      'its two ranges a day', (tester) async {
    final backend = _backend();
    await pump(tester, backend, listing: _paris);

    expect(
      find.text(
        'Cette clinique ne propose pas encore la prise de rendez-vous en '
        'ligne aux nouveaux clients.',
      ),
      findsOneWidget,
    );
    expect(
      backend.requests.where((r) => r.uri.path.endsWith('/booking/motifs')),
      isEmpty,
    );
    expect(find.text('Lun – Jeu'), findsOneWidget);
    expect(find.text('09:00 – 12:30'), findsOneWidget);
    expect(find.text('14:00 – 19:00'), findsOneWidget);
    expect(find.text('Vendredi'), findsOneWidget);

    await tester.tap(find.text('Appeler la clinique'));
    await tester.pumpAndSettle();
    expect(calls, [Uri(scheme: 'tel', path: '+33142551890')]);
  });

  testWidgets('Vercors (capture): no new client, no phone, no address, no '
      'hours', (tester) async {
    await pump(tester, _backend(), listing: _vercors);

    expect(
      find.text(
        "Cette clinique n'accepte pas de nouveaux clients pour le moment.",
      ),
      findsOneWidget,
    );
    expect(find.text('Appeler la clinique'), findsNothing);
    expect(find.text('Horaires'), findsNothing);
    expect(find.textContaining('Ouvert'), findsNothing);
    expect(find.textContaining('Fermé'), findsNothing);
  });

  testWidgets('the motifs refused (booking_not_open, capture): the info '
      'callout and the call', (tester) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        _lyonMotifs,
        PortalReply.fixture(
          'clinic-listings.paris.booking.motifs.get.422.json',
          status: 422,
        ),
      ),
    );

    expect(find.byType(KivetoCallout), findsOneWidget);
    expect(
      find.textContaining('ne propose pas encore la prise de rendez-vous'),
      findsOneWidget,
    );
    expect(find.text('Appeler la clinique'), findsOneWidget);
  });

  testWidgets('no motif open to new clients: « Aucun motif… »', (tester) async {
    await pump(
      tester,
      _backend()..on('GET', _lyonMotifs, PortalReply.json('[]')),
    );

    expect(
      find.text("Aucun motif n'est ouvert en ligne aux nouveaux clients."),
      findsOneWidget,
    );
  });

  testWidgets('the motifs failed: the error view and a retry', (tester) async {
    final backend = _backend()
      ..on('GET', _lyonMotifs, problem('service_unavailable', 503));
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);

    backend.on(
      'GET',
      _lyonMotifs,
      PortalReply.fixture('clinic-listings.lyon.booking.motifs.get.200.json'),
    );
    await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(KivetoListRow, 'Consultation'), findsOneWidget);
  });

  testWidgets('a clinic gone (404, capture): « Clinique introuvable », '
      'back', (tester) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        '$_listings/unknown',
        PortalReply.fixture(
          'clinic-listings.unknown.get.404.json',
          status: 404,
        ),
      ),
      listing: 'unknown',
    );

    expect(find.text('Clinique introuvable'), findsOneWidget);
    expect(
      find.text("Cette clinique n'est plus dans l'annuaire."),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsNothing);

    await tester.tap(find.byType(KivetoIconButton));
    expect(exits, ['back']);
  });

  testWidgets('the sheet failed: the error view and a retry', (tester) async {
    final backend = _backend()
      ..on('GET', '$_listings/$_lyon', problem('rate_limited', 429));
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);

    backend.on(
      'GET',
      '$_listings/$_lyon',
      PortalReply.fixture('clinic-listings.lyon.get.200.json'),
    );
    await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Ouvert · ferme à 19:00'), findsOneWidget);
  });

  testWidgets('a known client with a confirmed clinic: the hint, « Prendre '
      'rendez-vous » on the confirmed clinic of the same name, « Retrouver '
      'mon dossier »; no motif', (tester) async {
    final container = await pump(tester, _backend(me: 'me.get.200.json'));

    await tester.tap(find.text('Déjà client'));
    await tester.pumpAndSettle();

    expect(find.textContaining('rattachez-le'), findsOneWidget);
    expect(find.text('Motif'), findsNothing);
    await tester.tap(find.widgetWithText(KivetoButton, 'Prendre rendez-vous'));
    await tester.pumpAndSettle();

    expect(exits, ['book']);
    expect(switch (container.read(activeClinicProvider)) {
      AsyncData(:final value) => value?.clinicId,
      _ => null,
    }, const ClinicId('01960000-0000-7000-8000-000000000101'));

    await tester.tap(find.text('Retrouver mon dossier'));
    expect(exits, ['book', 'record']);

    await tester.tap(find.text('Nouveau client'));
    await tester.pumpAndSettle();
    expect(find.text('Motif'), findsOneWidget);
  });

  /// The active clinic's id, once read.
  ClinicId? activeOf(ProviderSubscription<AsyncValue<ClinicLink?>> active) =>
      switch (active.read()) {
        AsyncData(:final value) => value?.clinicId,
        _ => null,
      };

  testWidgets('a known client of a listing that matches no confirmed clinic '
      '(Vercors): the booking opens on the active clinic, unchanged', (
    tester,
  ) async {
    final container = await pump(
      tester,
      _backend(me: 'me.get.200.json'),
      listing: _vercors,
    );
    final active = container.listen(activeClinicProvider, (_, _) {});
    await tester.pumpAndSettle();
    expect(activeOf(active), const ClinicId(_parisClinic));

    await tester.tap(find.text('Déjà client'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Prendre rendez-vous'));
    await tester.pumpAndSettle();

    expect(exits, ['book']);
    expect(activeOf(active), const ClinicId(_parisClinic));
  });

  testWidgets('the name matched trimmed and case ignored: the clinic of the '
      'account switched', (tester) async {
    final container = await pump(
      tester,
      _backend(me: 'me.get.200.json')..on(
        'GET',
        '$_listings/$_lyon',
        _edited('clinic-listings.lyon.get.200.json', (body) {
          (body! as Map<String, Object?>)['name'] =
              '  clinique vétérinaire de LYON ';
        }),
      ),
    );
    final active = container.listen(activeClinicProvider, (_, _) {});
    await tester.pumpAndSettle();

    await tester.tap(find.text('Déjà client'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Prendre rendez-vous'));
    await tester.pumpAndSettle();

    expect(exits, ['book']);
    expect(activeOf(active), const ClinicId(_lyonClinic));
  });

  testWidgets('a known client without a confirmed clinic: only « Retrouver '
      'mon dossier »', (tester) async {
    await pump(tester, _backend());

    await tester.tap(find.text('Déjà client'));
    await tester.pumpAndSettle();

    expect(find.text('Prendre rendez-vous'), findsNothing);
    expect(find.text('Retrouver mon dossier'), findsOneWidget);
  });

  // Local times of the device, whatever its zone (Paris: two ranges Monday
  // to Thursday, one on Friday and Saturday).
  for (final (local, expected) in [
    (DateTime(2026, 11, 2, 13), 'Fermé · ouvre à 14:00'),
    (DateTime(2026, 11, 2, 20), 'Fermé · ouvre demain à 09:00'),
    (DateTime(2026, 11, 7, 15), 'Fermé · ouvre lundi à 09:00'),
  ]) {
    testWidgets('the status line on the device clock at $local: $expected', (
      tester,
    ) async {
      await pumpPage(
        tester,
        ClinicListingPage(
          listingId: _paris,
          onBack: (context) {},
          onChooseMotif: (context) {},
          onBookAsClient: (context) {},
          onFindRecord: (context) {},
        ),
        backend: _backend(),
        clock: FixedClock(local.toUtc()),
        session: await memorySession(pair('A')),
      );

      expect(find.text(expected), findsOneWidget);
    });
  }

  testWidgets('a malformed time keeps the sheet unreadable: the error view', (
    tester,
  ) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        '$_listings/$_lyon',
        _edited('clinic-listings.lyon.get.200.json', (body) {
          ((body! as Map<String, Object?>)['openingHours']! as List).first = {
            'day': 1,
            'opensAt': 'x',
            'closesAt': '19:00',
          };
        }),
      ),
    );

    expect(find.byType(ErrorView), findsOneWidget);
  });
}
