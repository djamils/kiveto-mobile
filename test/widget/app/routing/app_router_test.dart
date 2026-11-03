// The redirects (pure table, then on a pumped router), the invitation deep
// link, the shell: tabs with their own stack, badge and initials seams.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/kit_gallery_page.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
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

    test('signed in without a confirmed clinic: the clinic-scoped pages go '
        'to /clinics', () {
      for (final path in [
        AppRoutes.home,
        AppRoutes.pets,
        AppRoutes.pet('x'),
        AppRoutes.appointments,
        AppRoutes.questionnaire('a'),
        AppRoutes.documents,
        AppRoutes.prescriptionRenewal('p'),
        AppRoutes.bookingPet,
        AppRoutes.bookingConfirm,
      ]) {
        expect(_redirect(path, clinic: false), AppRoutes.clinics, reason: path);
      }
      for (final path in [
        AppRoutes.account,
        AppRoutes.clinics,
        AppRoutes.clinicListing('l'),
        AppRoutes.invitation,
        AppRoutes.onboardingInvitations,
        AppRoutes.kitGallery,
        '/homework',
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
    expect(AppRoutes.cancelAppointment('a'), '/appointments/a/cancel');
    expect(AppRoutes.reschedule('a'), '/appointments/a/reschedule');
    // An id is one encoded path segment.
    expect(AppRoutes.pet('a/b c'), '/pets/a%2Fb%20c');
    expect(AppRoutes.clinicListing('x?y'), '/clinic-listings/x%3Fy');
  });

  testWidgets('an encoded id reaches its page decoded', (tester) async {
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      initialLocation: AppRoutes.pet('a/b'),
    );

    expect(find.text('Fiche animal'), findsOneWidget);
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
        expect(find.text('Trouver une clinique'), findsOneWidget);
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
      expect(find.text('Trouver une clinique'), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);
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
      expect(find.text('Fiche animal'), findsOneWidget);

      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.home);

      await tester.tap(find.text('Animaux'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.pet('moka'));
      expect(find.text('Fiche animal'), findsOneWidget);

      await tester.tap(find.text('Animaux'));
      await tester.pumpAndSettle();
      expect(_location(container), AppRoutes.pets);
      expect(find.text('Mes animaux'), findsOneWidget);
    });

    testWidgets('the back button of a pushed page pops it', (tester) async {
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

    testWidgets('a full-screen flow reached directly: back goes home', (
      tester,
    ) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        initialLocation: AppRoutes.bookingPet,
      );
      expect(find.text('Pour quel animal ?'), findsOneWidget);
      expect(find.text('Accueil'), findsNothing);

      await tester.tap(find.byType(KivetoIconButton));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.home);
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

    testWidgets('the account tab signs out', (tester) async {
      final session = await memorySession(pair('A'));
      final container = await pumpKivetoApp(
        tester,
        session: session,
        initialLocation: AppRoutes.account,
      );

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

    testWidgets('every placeholder route builds', (tester) async {
      final container = await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
      );
      final router = container.read(routerProvider);
      for (final (path, title) in [
        (AppRoutes.appointments, 'Rendez-vous'),
        (AppRoutes.documents, 'Documents'),
        (AppRoutes.questionnaire('a'), 'Avant la consultation'),
        (AppRoutes.cancelAppointment('a'), 'Annuler le rendez-vous'),
        (AppRoutes.reschedule('a'), 'Reporter le rendez-vous'),
        (AppRoutes.prescriptionRenewal('p'), 'Demander un renouvellement'),
        (AppRoutes.bookingMotif, 'Quel est le motif ?'),
        (AppRoutes.bookingSlot, 'Choisissez un créneau'),
        (AppRoutes.bookingConfirm, 'Vérifiez et confirmez'),
        (AppRoutes.clinicListing('l'), 'Fiche clinique'),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(find.text(title), findsWidgets, reason: path);
      }
    });
  });
}

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
