// The redirects (pure table, then on a pumped router), the invitation deep
// link, the shell: tabs with their own stack, badge and initials seams.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/kit_gallery_page.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';

import '../../../support/fakes.dart';

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

    test('signed in: the sign-in pages go home', () {
      for (final path in [
        AppRoutes.welcome,
        AppRoutes.signInCode,
        AppRoutes.register,
      ]) {
        expect(_redirect(path), AppRoutes.home);
      }
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
  });

  test('the paths of the routes with ids', () {
    expect(AppRoutes.cancelAppointment('a'), '/appointments/a/cancel');
    expect(AppRoutes.reschedule('a'), '/appointments/a/reschedule');
  });

  group('the pumped router', () {
    testWidgets('signed out: /home shows the welcome page; signing in goes '
        'home; signing out goes back', (tester) async {
      final session = await memorySession();
      final container = await pumpKivetoApp(tester, session: session);

      expect(_location(container), AppRoutes.welcome);
      expect(find.text('Bienvenue'), findsOneWidget);

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
        overrides: [hasConfirmedClinicProvider.overrideWithValue(false)],
      );

      expect(_location(container), AppRoutes.clinics);
      expect(find.text('Trouver une clinique'), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);
    });

    for (final signedIn in [false, true]) {
      testWidgets(
        'the invitation link (${signedIn ? 'signed in' : 'signed '
                  'out'}) says a link arrived, never the token',
        (tester) async {
          await pumpKivetoApp(
            tester,
            session: await memorySession(signedIn ? pair('A') : null),
            initialLocation: '/invitation#t=abc',
          );

          expect(find.text("Lien d'invitation reçu."), findsOneWidget);
          expect(find.textContaining('abc'), findsNothing);
        },
      );
    }

    testWidgets('/invitation without a fragment: no link', (tester) async {
      await pumpKivetoApp(tester, initialLocation: AppRoutes.invitation);

      expect(find.text("Aucun lien d'invitation."), findsOneWidget);
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

      await tester.tap(find.text("Ouvrir le kit d'interface"));
      await tester.pumpAndSettle();

      expect(find.byType(KitGalleryPage), findsOneWidget);
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
        (AppRoutes.onboardingInvitations, 'Vos invitations'),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(find.text(title), findsWidgets, reason: path);
      }

      await session(container).signOut();
      await tester.pumpAndSettle();
      for (final (path, title) in [
        (AppRoutes.signInCode, 'Entrez le code reçu'),
        (AppRoutes.register, 'Créez votre compte'),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget, reason: path);
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
