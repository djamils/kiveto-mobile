// Slice 7 through the real app, router and HTTP chain, on the captures: a
// clinic-less account lands on the clinic search (its greeting, its record
// suggested, the directory), its Animaux and Documents tabs say why they
// are empty, Rendez-vous lists its requests; then Lyon's sheet, a motif, a
// slot, a new pet, back to the slot and forth (the pet refilled), the
// request refused for its slot (back on the slot step), another slot, the
// request with the draft's Idempotency-Key, the success, and screen 4
// listing the request « En attente » without a manual refresh.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/features/clinic_listing/clinic_listing.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/portal_api/fake_portal_backend.dart';
import '../../support/portal_api/portal_http_harness.dart';
import '../features/scheduling/scheduling_support.dart' show Keys, tapVisible;

const _lyon = '01a19a12-79bb-7408-9051-a42bd37f652d';
const _listings = '$api/clinic-listings';
const _booking = '$_listings/$_lyon/booking';
const _consultation = '01a19a10-d3d1-7031-bd42-3d901474af59';
const _lemoine = '01a19a0e-29db-7550-a605-8ac512a656c1';
const _requests = '$api/me/booking-requests?limit=50';

Finder _nav(String label) => find.descendant(
  of: find.byType(KivetoBottomNav),
  matching: find.text(label),
);

void main() {
  testWidgets('a clinic-less account: the clinic search, the empty tabs, a '
      'new-client request sent with its key, then « En attente » on 4', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 3
      ..physicalSize = const Size(390 * 3, 1200 * 3);
    addTearDown(tester.view.reset);
    var sent = false;
    var posts = 0;
    final backend = FakePortalBackend()
      ..on('GET', '$api/me', PortalReply.fixture('me.no-clinic.get.200.json'))
      ..on(
        'GET',
        '$api/me/link-suggestions',
        PortalReply.fixture('me.link-suggestions.get.200.json'),
      )
      ..on(
        'GET',
        _listings,
        PortalReply.fixture('clinic-listings.get.200.json'),
      )
      ..onRequest(
        'GET',
        _requests,
        (request) => PortalReply.fixture(
          sent
              ? 'me.booking-requests.pending.get.200.json'
              : 'me.booking-requests.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_listings/$_lyon',
        PortalReply.fixture('clinic-listings.lyon.get.200.json'),
      )
      ..on(
        'GET',
        '$_booking/motifs',
        PortalReply.fixture('clinic-listings.lyon.booking.motifs.get.200.json'),
      )
      ..on(
        'GET',
        '$_booking/practitioners?motifId=$_consultation',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.practitioners.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_booking/availability?motifId=$_consultation'
            '&practitionerId=$_lemoine&from=2026-11-04&to=2026-11-17',
        PortalReply.fixture(
          'clinic-listings.lyon.booking.availability.get.200.json',
        ),
      )
      ..onRequest('POST', '$_booking/appointments', (request) {
        // The first request finds its slot taken.
        if (++posts == 1) {
          return PortalReply.fixture(
            'clinic-listings.lyon.booking.appointments.slot-taken.post.409'
            '.json',
            status: 409,
          );
        }
        sent = true;
        return PortalReply.fixture(
          'clinic-listings.lyon.booking.appointments.post.201.json',
          status: 201,
        );
      });
    final keys = Keys();
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      clock: FixedClock(DateTime.utc(2026, 11, 4, 8)),
      overrides: [bookingKeyFactoryProvider.overrideWithValue(keys.next)],
    );
    String location() => container
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();

    // The landing: /clinics.
    expect(location(), AppRoutes.clinics);
    expect(
      find.widgetWithText(KivetoPageHeader, 'Bonjour Test'),
      findsOneWidget,
    );
    expect(
      find.text('Clinique Vétérinaire de Paris a un dossier à votre numéro'),
      findsOneWidget,
    );
    expect(find.text('3 cliniques'), findsOneWidget);

    // The clinic tabs say why they are empty.
    for (final tab in ['Animaux', 'Documents']) {
      await tester.tap(_nav(tab));
      await tester.pumpAndSettle();
      expect(
        find.text('Aucune clinique rattachée'),
        findsOneWidget,
        reason: tab,
      );
      expect(
        find.widgetWithText(KivetoButton, 'Trouver une clinique'),
        findsOneWidget,
        reason: tab,
      );
    }
    await tester.tap(_nav('Rendez-vous'));
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.appointments);
    expect(find.text('Aucune clinique rattachée'), findsOneWidget);
    expect(find.text('Demandes de rendez-vous'), findsNothing);

    // The directory, Lyon's sheet, a motif.
    await tester.tap(_nav('Accueil'));
    await tester.pumpAndSettle();
    expect(find.byType(ClinicSearchPage), findsOneWidget);
    await tester.tap(find.text('Clinique Vétérinaire de Lyon'));
    await tester.pumpAndSettle();
    expect(find.byType(ClinicListingPage), findsOneWidget);
    await tester.tap(find.widgetWithText(KivetoListRow, 'Consultation'));
    await tester.pumpAndSettle();

    // Step 1: a slot.
    expect(find.byType(ListingSlotPage), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('slot-2026-11-05T13:00:00+01:00')),
    );
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();

    // Step 2: the new pet, the request.
    expect(find.byType(ListingConfirmPage), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(KivetoTextField),
        matching: find.byType(TextField),
      ),
      'Capture',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Chat'));
    await tester.pumpAndSettle();

    // Back on step 1: the slot kept; forth: the pet refilled.
    await tester.tap(find.byType(KivetoIconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Étape 1 sur 2'), findsOneWidget);
    expect(find.text('Jeu. 5 nov. à 13:00'), findsOneWidget);
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 2 sur 2'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Capture'), findsOneWidget);

    // The slot taken meanwhile: back on step 1, its warning.
    await tester.tap(find.widgetWithText(KivetoButton, 'Envoyer la demande'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 1 sur 2'), findsOneWidget);
    expect(
      find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
      findsOneWidget,
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('slot-2026-11-05T13:15:00+01:00')),
    );
    await tester.tap(find.widgetWithText(KivetoButton, 'Continuer'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Capture'), findsOneWidget);
    await tester.tap(find.widgetWithText(KivetoButton, 'Envoyer la demande'));
    await tester.pumpAndSettle();

    final sentPosts = backend.requestsTo('$_booking/appointments');
    expect(sentPosts, hasLength(2));
    // Another slot, another intent: another key.
    expect(
      sentPosts.first.headers['Idempotency-Key'],
      isNot(sentPosts.last.headers['Idempotency-Key']),
    );
    final post = sentPosts.last;
    expect(post.headers['Idempotency-Key'], 'key-${keys.count}');
    expect(
      (jsonDecode(utf8.decode(post.body)) as Map<String, Object?>)['startAt'],
      '2026-11-05T13:15:00+01:00',
    );
    expect(
      (jsonDecode(utf8.decode(post.body)) as Map<String, Object?>)['newPet'],
      {'name': 'Capture', 'species': 'cat'},
    );
    expect(find.text('Demande envoyée'), findsOneWidget);

    // Screen 4 follows, without a refresh.
    await tester.tap(find.widgetWithText(KivetoButton, 'Voir mes rendez-vous'));
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.appointments);
    expect(find.text('Demandes de rendez-vous'), findsOneWidget);
    expect(find.text('14:00 · Capture'), findsOneWidget);
    expect(find.widgetWithText(StatusPill, 'En attente'), findsOneWidget);
    expect(find.text('Aucune clinique rattachée'), findsOneWidget);
  });
}
