// The redirects (pure table, then on a pumped router), the invitation deep
// link (and the iOS dev link the engine pushes), the shell: tabs with their
// own stack, badge and initials seams.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/kit_gallery_page.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/clinic_listing/clinic_listing.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';

String? _redirect(
  String location, {
  bool signedIn = true,
  bool? clinic = true,
}) => redirectFor(
  location: Uri.parse(location),
  signedIn: signedIn,
  hasConfirmedClinic: clinic,
);

String _location(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .toString();

void main() {
  group('redirectFor', () {
    test('/ goes home or to the welcome page', () {
      expect(_redirect('/'), AppRoutes.home);
      expect(_redirect(''), AppRoutes.home);
      expect(_redirect('/', signedIn: false), AppRoutes.welcome);
    });

    test('signed out: the public pages stay, the rest goes to welcome', () {
      for (final path in [
        AppRoutes.welcome,
        AppRoutes.signInCode,
        AppRoutes.register,
        AppRoutes.onboardingInvitations,
        AppRoutes.invitation,
        AppRoutes.kitGallery,
      ]) {
        expect(_redirect(path, signedIn: false), isNull, reason: path);
      }
      for (final path in [
        AppRoutes.home,
        AppRoutes.account,
        AppRoutes.pet('x'),
        AppRoutes.clinics,
        AppRoutes.bookingPet,
      ]) {
        expect(_redirect(path, signedIn: false), AppRoutes.welcome);
      }
    });

    test('signed in: the sign-in pages go home, except the code page (it '
        'navigates itself once the session opens)', () {
      for (final path in [AppRoutes.welcome, AppRoutes.register]) {
        expect(_redirect(path), AppRoutes.home);
      }
      expect(_redirect(AppRoutes.signInCode), isNull);
      expect(_redirect(AppRoutes.home), isNull);
      expect(_redirect(AppRoutes.invitation), isNull);
      expect(_redirect(AppRoutes.onboardingInvitations), isNull);
    });

    test('signed in without a confirmed clinic: the home, the booking and '
        'the pages under the clinic tabs go to /clinics; the tab roots, the '
        'directory and its new-client booking stay', () {
      for (final path in [
        AppRoutes.home,
        AppRoutes.pet('x'),
        AppRoutes.questionnaire('a'),
        AppRoutes.reschedule('a'),
        AppRoutes.prescriptionRenewal('p'),
        AppRoutes.bookingPet,
        AppRoutes.bookingConfirm,
        '/booking',
      ]) {
        expect(_redirect(path, clinic: false), AppRoutes.clinics, reason: path);
      }
      for (final path in [
        AppRoutes.pets,
        AppRoutes.appointments,
        AppRoutes.documents,
        AppRoutes.account,
        AppRoutes.clinics,
        AppRoutes.clinicListing('l'),
        AppRoutes.listingSlot('l'),
        AppRoutes.listingConfirm('l'),
        AppRoutes.invitation,
        AppRoutes.onboardingInvitations,
        AppRoutes.kitGallery,
        '/homework',
        '/petsitter',
      ]) {
        expect(_redirect(path, clinic: false), isNull, reason: path);
      }
    });

    test('a clinic not known yet does not redirect', () {
      expect(_redirect(AppRoutes.home, clinic: null), isNull);
      expect(_redirect(AppRoutes.bookingSlot, clinic: null), isNull);
    });
  });

  test('invitationTokenFrom reads #t= only', () {
    expect(
      invitationTokenFrom(
        Uri.parse('https://portal.kiveto.local/invitation#t=abc'),
      ),
      'abc',
    );
    expect(invitationTokenFrom(Uri.parse('/invitation#t=a%2Bb&x=1')), 'a+b');
    expect(invitationTokenFrom(Uri.parse('/invitation')), isNull);
    expect(invitationTokenFrom(Uri.parse('/invitation#t=')), isNull);
    expect(invitationTokenFrom(Uri.parse('/invitation?t=abc')), isNull);
    // A malformed encoding is no token.
    expect(invitationTokenFrom(Uri.parse('/invitation#t=%FF')), isNull);
  });

  test('invitationLink keeps the token in the fragment', () {
    final link = AppRoutes.invitationLink('a+b/c');

    expect(link, startsWith('${AppRoutes.invitation}#t='));
    expect(Uri.parse(link).path, AppRoutes.invitation);
    expect(Uri.parse(link).query, isEmpty);
    expect(invitationTokenFrom(Uri.parse(link)), 'a+b/c');
  });

  test('the paths of the routes with ids', () {
    expect(AppRoutes.questionnaire('a'), '/appointments/a/questionnaire');
    expect(AppRoutes.reschedule('a'), '/appointments/a/reschedule');
    // An id is one encoded path segment.
    expect(AppRoutes.pet('a/b c'), '/pets/a%2Fb%20c');
    expect(AppRoutes.clinicListing('x?y'), '/clinic-listings/x%3Fy');
    expect(AppRoutes.listingSlot('l'), '/clinic-listings/l/booking/slot');
    expect(AppRoutes.listingConfirm('l'), '/clinic-listings/l/booking/confirm');
  });

  testWidgets('an encoded id reaches its page decoded', (tester) async {
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      initialLocation: AppRoutes.pet('a/b'),
    );

    expect(tester.widget<PetPage>(find.byType(PetPage)).petId, 'a/b');
    final match = container
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration;
    expect(match.pathParameters['petId'], 'a/b');
  });

  group('the pumped router', () {
    testWidgets('signed out: /home shows the welcome page; signing in goes '
        'home; signing out goes back', (tester) async {
      final session = await memorySession();
      final container = await pumpKivetoApp(tester, session: session);

      expect(_location(container), AppRoutes.welcome);
      expect(find.byType(WelcomePage), findsOneWidget);

      await session.open(pair('A'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.home);
      expect(find.text('Accueil'), findsWidgets);

      await session.signOut();
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.welcome);
    });

    testWidgets(
      'the clinic seam, unknown then false: /home moves to /clinics',
      (tester) async {
        final container = await pumpKivetoApp(
          tester,
          session: await memorySession(pair('A')),
          seams: false,
          overrides: [
            hasConfirmedClinicProvider.overrideWith(
              (ref) => ref.watch(_clinicSeam),
            ),
          ],
        );
        expect(_location(container), AppRoutes.home);

        container.read(_clinicSeam.notifier).noConfirmedClinic();
        await tester.pumpAndSettle();

        expect(_location(container), AppRoutes.clinics);
        expect(find.byType(ClinicSearchPage), findsOneWidget);
      },
    );

    testWidgets('no confirmed clinic: home redirects to /clinics, with the '
        'Accueil tab active', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        seams: false,
        overrides: [hasConfirmedClinicProvider.overrideWithValue(false)],
      );

      expect(_location(container), AppRoutes.clinics);
      expect(find.byType(ClinicSearchPage), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);
    });

    testWidgets('no confirmed clinic: Animaux and Documents say why they are '
        'empty, « Trouver une clinique » goes to /clinics; Rendez-vous is its '
        'page', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        seams: false,
        overrides: [hasConfirmedClinicProvider.overrideWithValue(false)],
      );
      final router = container.read(routerProvider);

      for (final (path, title, body) in [
        (
          AppRoutes.pets,
          'Animaux',
          "Vos animaux apparaîtront ici dès qu'une clinique vous aura "
              'rattaché.',
        ),
        (
          AppRoutes.documents,
          'Documents',
          'Les documents partagés par votre clinique apparaîtront ici.',
        ),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(_location(container), path);
        expect(find.byType(PetPage), findsNothing);
        expect(find.byType(DocumentsPage), findsNothing);
        expect(find.widgetWithText(KivetoPageHeader, title), findsOneWidget);
        expect(find.text('Aucune clinique rattachée'), findsOneWidget);
        expect(find.text(body), findsOneWidget);

        await tester.tap(
          find.widgetWithText(KivetoButton, 'Trouver une clinique'),
        );
        await tester.pumpAndSettle();
        expect(_location(container), AppRoutes.clinics, reason: path);
      }

      router.go(AppRoutes.appointments);
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.appointments);
      expect(find.byType(AppointmentsPage), findsOneWidget);

      // Under a tab: still the clinic search.
      router.go(AppRoutes.pet('moka'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.clinics);
    });

    testWidgets('a clinic not known yet: the tabs show their feature page', (
      tester,
    ) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        seams: false,
        overrides: [hasConfirmedClinicProvider.overrideWithValue(null)],
      );
      final router = container.read(routerProvider)..go(AppRoutes.pets);
      await tester.pumpAndSettle();
      expect(find.byType(PetPage), findsOneWidget);

      router.go(AppRoutes.documents);
      await tester.pumpAndSettle();
      expect(find.byType(DocumentsPage), findsOneWidget);
      expect(find.text('Aucune clinique rattachée'), findsNothing);
    });

    for (final signedIn in [false, true]) {
      testWidgets('the invitation link (${signedIn ? 'signed in' : 'signed '
                    'out'}) opens the invitation page with its token, sent in '
          'the lookup body only, never shown', (tester) async {
        final backend = FakePortalBackend()
          ..on(
            'POST',
            '/api/portal/v1/invitations/lookup',
            PortalReply.fixture('invitations.lookup.post.200.json'),
          )
          ..on(
            'POST',
            '/api/portal/v1/invitations/otp',
            PortalReply.fixture('invitations.otp.post.202.json', status: 202),
          );
        final container = await pumpKivetoApp(
          tester,
          session: await memorySession(signedIn ? pair('A') : null),
          backend: backend,
          initialLocation: '/invitation#t=abc',
        );

        expect(_location(container), '/invitation#t=abc');
        expect(find.byType(InvitationPage), findsOneWidget);
        expect(
          find.text('Invitation : Clinique Vétérinaire de Paris'),
          findsOneWidget,
        );
        expect(find.textContaining('abc'), findsNothing);
        final lookup = backend
            .requestsTo('/api/portal/v1/invitations/lookup')
            .single;
        expect(utf8.decode(lookup.body), '{"token":"abc"}');
        expect(lookup.uri.toString(), isNot(contains('abc')));
      });

      testWidgets('the iOS dev link (${signedIn ? 'signed in' : 'signed '
                    'out'}): the engine pushes the whole URL '
          'kiveto-dev://portal.kiveto.local/invitation#t=abc, the invitation '
          'page reads its token, sent in the lookup body only, never '
          'shown', (tester) async {
        final backend = FakePortalBackend()
          ..on(
            'POST',
            '/api/portal/v1/invitations/lookup',
            PortalReply.fixture('invitations.lookup.post.200.json'),
          )
          ..on(
            'POST',
            '/api/portal/v1/invitations/otp',
            PortalReply.fixture('invitations.otp.post.202.json', status: 202),
          );
        await pumpKivetoApp(
          tester,
          session: await memorySession(signedIn ? pair('A') : null),
          backend: backend,
        );
        expect(find.byType(InvitationPage), findsNothing);

        // What the iOS engine sends for a URL opened in the app (cold or
        // warm): `location` is the URL's absoluteString.
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          SystemChannels.navigation.name,
          SystemChannels.navigation.codec.encodeMethodCall(
            const MethodCall('pushRouteInformation', <String, Object?>{
              'location': 'kiveto-dev://portal.kiveto.local/invitation#t=abc',
              'state': null,
            }),
          ),
          (_) {},
        );
        await tester.pumpAndSettle();

        expect(find.byType(InvitationPage), findsOneWidget);
        expect(
          find.text('Invitation : Clinique Vétérinaire de Paris'),
          findsOneWidget,
        );
        expect(find.textContaining('abc'), findsNothing);
        final lookup = backend
            .requestsTo('/api/portal/v1/invitations/lookup')
            .single;
        expect(utf8.decode(lookup.body), '{"token":"abc"}');
        expect(lookup.uri.toString(), isNot(contains('abc')));
      });
    }

    testWidgets('a second invitation link while the first is shown: the '
        'same page reads the new token', (tester) async {
      final backend = FakePortalBackend()
        ..onRequest(
          'POST',
          '/api/portal/v1/invitations/lookup',
          (request) => utf8.decode(request.body) == '{"token":"PERRIN_TOKEN"}'
              ? PortalReply.fixture(
                  'invitations.lookup.expired.post.410.json',
                  status: 410,
                )
              : PortalReply.fixture('invitations.lookup.post.200.json'),
        )
        ..on(
          'POST',
          '/api/portal/v1/invitations/otp',
          PortalReply.fixture('invitations.otp.post.202.json', status: 202),
        )
        ..on(
          'GET',
          '/api/portal/v1/legal/terms/current',
          PortalReply.fixture('legal.terms.current.get.200.json'),
        );
      final container = await pumpKivetoApp(
        tester,
        backend: backend,
        initialLocation: '/invitation#t=PERRIN_TOKEN',
      );
      expect(find.text('Invitation expirée'), findsOneWidget);
      final page = tester.state<State>(find.byType(InvitationPage));

      container.read(routerProvider).go('/invitation#t=ROUSSEL_TOKEN');
      await tester.pumpAndSettle();

      // The same page (go_router keys it by path), updated with the token.
      expect(tester.state<State>(find.byType(InvitationPage)), same(page));

      expect(find.text('Invitation expirée'), findsNothing);
      expect(
        find.text('Invitation : Clinique Vétérinaire de Paris'),
        findsOneWidget,
      );
      final lookups = backend.requestsTo('/api/portal/v1/invitations/lookup');
      expect(lookups.map((request) => utf8.decode(request.body)), [
        '{"token":"PERRIN_TOKEN"}',
        '{"token":"ROUSSEL_TOKEN"}',
      ]);
      expect(
        utf8.decode(
          backend.requestsTo('/api/portal/v1/invitations/otp').single.body,
        ),
        '{"token":"ROUSSEL_TOKEN"}',
      );
    });

    testWidgets('/invitation without a fragment: the invalid link state', (
      tester,
    ) async {
      await pumpKivetoApp(tester, initialLocation: AppRoutes.invitation);

      expect(find.text("Lien d'invitation invalide"), findsOneWidget);
    });

    testWidgets('/invitation with a malformed token: the invalid link state', (
      tester,
    ) async {
      await pumpKivetoApp(tester, initialLocation: '/invitation#t=%FF');

      expect(find.text("Lien d'invitation invalide"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('each tab keeps its own stack; the active tab goes back to '
        'its root', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        initialLocation: AppRoutes.pet('moka'),
      );
      expect(tester.widget<PetPage>(find.byType(PetPage)).petId, 'moka');

      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.home);

      await tester.tap(find.text('Animaux'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.pet('moka'));
      expect(tester.widget<PetPage>(find.byType(PetPage)).petId, 'moka');

      await tester.tap(find.text('Animaux'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.pets);
      expect(tester.widget<PetPage>(find.byType(PetPage)).petId, isNull);
    });

    testWidgets('the back button of a page pushed in a tab pops it', (
      tester,
    ) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
      );
      await tester.tap(find.text('Animaux'));
      await tester.pumpAndSettle();
      unawaitedPush(container, AppRoutes.pet('moka'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(KivetoIconButton));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.pets);
    });

    testWidgets('the booking reached directly: back (and close) goes home', (
      tester,
    ) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        initialLocation: AppRoutes.bookingPet,
      );
      expect(find.byType(BookingPetPage), findsOneWidget);
      expect(find.text('Pour quel animal ?'), findsOneWidget);
      expect(find.text('Accueil'), findsNothing);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is KivetoIconButton &&
              widget.glyph == LucideGlyph.chevronLeft,
        ),
      );
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.home);

      container.read(routerProvider).go(AppRoutes.bookingConfirm);
      await tester.pumpAndSettle();
      expect(find.byType(BookingConfirmPage), findsOneWidget);
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is KivetoIconButton && widget.glyph == LucideGlyph.x,
        ),
      );
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.home);
    });

    testWidgets('the scheduling routes build their pages', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
      );
      final router = container.read(routerProvider);
      for (final (path, page) in [
        (AppRoutes.appointments, AppointmentsPage),
        (AppRoutes.bookingMotif, BookingMotifPage),
        (AppRoutes.bookingSlot, BookingSlotPage),
        (AppRoutes.bookingConfirm, BookingConfirmPage),
        (AppRoutes.reschedule('a'), ReschedulePage),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(find.byType(page), findsOneWidget, reason: path);
      }

      // The reschedule reached directly: back shows the Rendez-vous tab.
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is KivetoIconButton &&
              widget.glyph == LucideGlyph.chevronLeft,
        ),
      );
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.appointments);
      expect(find.byType(AppointmentsPage), findsOneWidget);
    });

    testWidgets('the badge and initials seams; no badge on Documents', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        seams: false,
        overrides: [
          unreadDocumentsCountProvider.overrideWithValue(2),
          accountInitialsProvider.overrideWithValue('SB'),
        ],
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('SB'), findsOneWidget);
      expect(find.bySemanticsLabel('Documents, 2 nouveaux'), findsOneWidget);

      await tester.tap(find.text('Documents').last);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsNothing);
      expect(find.bySemanticsLabel('Documents, 2 nouveaux'), findsNothing);
      handle.dispose();
    });

    testWidgets('the account tab: « Ajouter une clinique » goes to the clinic '
        'search', (tester) async {
      final backend = FakePortalBackend()
        ..on(
          'GET',
          '/api/portal/v1/me',
          PortalReply.fixture('me.get.200.json'),
        );
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        backend: backend,
        initialLocation: AppRoutes.account,
      );

      final link = find.text('Ajouter une clinique', findRichText: true);
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.clinics);
    });

    testWidgets('the account tab signs out', (tester) async {
      final session = await memorySession(pair('A'));
      final container = await pumpKivetoApp(
        tester,
        session: session,
        initialLocation: AppRoutes.account,
      );

      // /me fails (no route): the error view, then the button.
      await tester.ensureVisible(find.text('Se déconnecter'));
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      expect(session.status, SessionStatus.signedOut);
      expect(_location(container), AppRoutes.welcome);
    });

    testWidgets('an unknown location: a way back home', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        initialLocation: '/nowhere',
      );
      expect(find.text('Page introuvable'), findsOneWidget);

      await tester.tap(find.text("Revenir à l'accueil"));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.home);
    });

    testWidgets('debug: the welcome page opens the kit gallery', (
      tester,
    ) async {
      await pumpKivetoApp(tester);

      final link = find.text("Ouvrir le kit d'interface");
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(find.byType(KitGalleryPage), findsOneWidget);
    });

    testWidgets('the flow pages opened without their flow go back to their '
        'start', (tester) async {
      final container = await pumpKivetoApp(tester);
      final router = container.read(routerProvider);
      for (final path in [AppRoutes.signInCode, AppRoutes.register]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(_location(container), AppRoutes.welcome, reason: path);
      }
      router.go(AppRoutes.onboardingInvitations);
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.welcome);

      await session(container).open(pair('A'));
      await tester.pumpAndSettle();
      router.go(AppRoutes.onboardingInvitations);
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.home);
    });

    testWidgets('the directory routes build their pages, over the shell for '
        'the sheet and its booking', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
      );
      final router = container.read(routerProvider);
      for (final (path, page, shell) in [
        (AppRoutes.clinics, ClinicSearchPage, true),
        (AppRoutes.clinicListing('l'), ClinicListingPage, false),
        (AppRoutes.listingSlot('l'), ListingSlotPage, false),
        (AppRoutes.listingConfirm('l'), ListingConfirmPage, false),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(find.byType(page), findsOneWidget, reason: path);
        expect(
          find.text('Accueil'),
          shell ? findsOneWidget : findsNothing,
          reason: path,
        );
      }

      // The booking reached directly: close pops back to the sheet, whose
      // back goes to the clinic search.
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is KivetoIconButton && widget.glyph == LucideGlyph.x,
        ),
      );
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.clinicListing('l'));
      expect(find.byType(ClinicListingPage), findsOneWidget);

      await tester.tap(find.byType(KivetoIconButton).first);
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.clinics);
    });

    testWidgets('/appointments/:id/questionnaire is screen 15 over the '
        'shell; back pops it, else the Rendez-vous tab', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        initialLocation: AppRoutes.questionnaire('a'),
      );

      expect(find.byType(QuestionnairePage), findsOneWidget);
      expect(find.text('Accueil'), findsNothing);

      await tester.tap(find.byType(KivetoIconButton).first);
      await tester.pumpAndSettle();
      expect(
        container
            .read(routerProvider)
            .routerDelegate
            .currentConfiguration
            .uri
            .toString(),
        AppRoutes.appointments,
      );
    });

    testWidgets('/documents/prescriptions/:id/renewal is screen 17 over the '
        'shell; back pops it, else the Documents tab', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        initialLocation: AppRoutes.prescriptionRenewal('p'),
      );

      expect(find.byType(RenewalPage), findsOneWidget);
      expect(find.text('Accueil'), findsNothing);

      await tester.tap(find.byType(KivetoIconButton).first);
      await tester.pumpAndSettle();
      expect(
        container
            .read(routerProvider)
            .routerDelegate
            .currentConfiguration
            .uri
            .toString(),
        AppRoutes.documents,
      );
    });

    testWidgets('/documents is the documents page; its renewal button pushes '
        'screen 17 over the shell; once sent, back on the documents, the '
        "card's sheet shows « Renouvellement demandé »", (tester) async {
      const base = '/api/portal/v1/clinics/$_parisId';
      const ord36 = '01a19a12-8b44-7c87-b043-5d82ad91c574';
      var sent = false;
      final backend = FakePortalBackend()
        ..on('GET', '/api/portal/v1/me', PortalReply.fixture('me.get.200.json'))
        ..onRequest('GET', '$base/documents', (_) {
          final body = jsonDecode(
            File(
              '$portalFixtures/'
              'clinics.paris.documents.prescriptions.get.200.json',
            ).readAsStringSync(),
          ) as Map<String, Object?>;
          if (sent) {
            final first =
                (body['items']! as List<Object?>).first!
                    as Map<String, Object?>;
            (first['prescription']!
                as Map<String, Object?>)['renewalStatus'] = {
              'status': 'submitted',
              'requestId': '01a19a12-87fc-7cd1-a51e-c25f03efc697',
              'resultingPrescriptionId': null,
            };
          }
          return PortalReply.json(jsonEncode(body));
        })
        ..on(
          'GET',
          '$base/prescriptions/$ord36',
          PortalReply.fixture(
            'clinics.paris.prescriptions.renewable.get.200.json',
          ),
        )
        ..onRequest('POST', '$base/prescriptions/$ord36/renewal-requests', (_) {
          sent = true;
          return PortalReply.fixture(
            'clinics.paris.prescriptions.renewal-requests.post.202.json',
            status: 202,
          );
        })
        ..on(
          'GET',
          '/api/portal/v1/clinics/$_parisId/pets',
          PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
        );
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        backend: backend,
        initialLocation: AppRoutes.documents,
      );

      expect(find.byType(DocumentsPage), findsOneWidget);
      expect(
        find.text('Partagés par Clinique Vétérinaire de Paris'),
        findsOneWidget,
      );

      await tester.tap(find.text('Demander un renouvellement').first);
      await tester.pumpAndSettle();

      // A push: the location stays /documents, the pushed match is last.
      expect(
        container
            .read(routerProvider)
            .routerDelegate
            .currentConfiguration
            .last
            .matchedLocation,
        AppRoutes.prescriptionRenewal('01a19a12-8b44-7c87-b043-5d82ad91c574'),
      );
      expect(find.byType(RenewalPage), findsOneWidget);
      expect(find.text('Demander un renouvellement'), findsOneWidget);
      expect(find.text('Accueil'), findsNothing);

      await tester.tap(find.text('Ça va mieux'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer la demande'));
      await tester.pumpAndSettle();
      expect(find.text('Demande envoyée'), findsOneWidget);

      await tester.tap(find.text('Retour aux documents'));
      await tester.pumpAndSettle();
      expect(find.byType(RenewalPage), findsNothing);
      expect(find.byType(DocumentsPage), findsOneWidget);
      expect(backend.requestsTo('$base/documents'), hasLength(2));

      await tester.tap(find.textContaining('Ordonnance ORD-2026-000036'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Renouvellement demandé'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Demander un renouvellement'),
        ),
        findsNothing,
      );
    });
  });
}

const _parisId = '01960000-0000-7000-8000-000000000001';

/// A seam the test changes after the start, like slice 1 after `GET /me`.
final _clinicSeam = NotifierProvider<_ClinicSeam, bool?>(_ClinicSeam.new);

final class _ClinicSeam extends Notifier<bool?> {
  @override
  bool? build() => null;

  /// `GET /me` answered: no confirmed clinic.
  void noConfirmedClinic() => state = false;
}

void unawaitedPush(ProviderContainer container, String location) {
  container.read(routerProvider).push<void>(location).ignore();
}

SessionManager session(ProviderContainer container) =>
    container.read(sessionManagerProvider);
