// Slice 1 in the real app (router, seams, PortalHttp on the fake backend):
// welcome → code → the destination of each branch, the restart signed in,
// the clinic-less account, the seams while /me reloads, the home's header
// from /me, the logout.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/clinic_listing/clinic_listing.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/portal_api/fake_portal_backend.dart';
import '../../support/portal_api/portal_http_harness.dart';

const _request = '$api/auth/otp/request';
const _verify = '$api/auth/otp/verify';
const _me = '$api/me';
const _terms = '$api/legal/terms/current';
const _logout = '$api/auth/logout';
const _refresh = '$api/auth/refresh';
const _parisHome = '$api/clinics/01960000-0000-7000-8000-000000000001/home';
const _lyonHome = '$api/clinics/01960000-0000-7000-8000-000000000101/home';

String _location(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .toString();

/// Scrolls the account screen (6) down to « Se déconnecter » and taps it.
Future<void> _tapSignOut(WidgetTester tester) async {
  final button = find.text('Se déconnecter');
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find
        .descendant(
          of: find.byType(AccountPage),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(button);
}

/// The routes of a sign-in by code whose verification answers [verify].
FakePortalBackend _signInBackend(PortalReply verify, {String me = 'me.get'}) =>
    FakePortalBackend()
      ..on(
        'POST',
        _request,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      )
      ..on('POST', _verify, verify)
      ..on('GET', _me, PortalReply.fixture('$me.200.json'))
      ..on(
        'GET',
        _parisHome,
        PortalReply.fixture('clinics.paris.home.get.200.json'),
      )
      ..on(
        'GET',
        _terms,
        PortalReply.fixture('legal.terms.current.get.200.json'),
      );

PortalReply _tokens(String name) => PortalReply.json(
  jsonEncode({
    'accessToken': name,
    'accessTokenExpiresAt': '2026-11-03T10:38:48+00:00',
    'refreshToken': 'refresh-$name',
    'refreshTokenExpiresAt': '2027-02-01T10:23:48+00:00',
    'account': {
      'id': 'acc',
      'firstName': 'Julien',
      'lastName': 'Girard',
      'email': null,
      'emailVerified': false,
      'maskedPhone': '+33 6 •• •• •• 78',
      'address': null,
    },
  }),
);

/// 7 → 8: the number typed, the code requested, the code typed.
Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '0612345678');
  await tester.pump();
  await tester.tap(find.text('Recevoir mon code'));
  await tester.pumpAndSettle();
  expect(find.byType(CodePage), findsOneWidget);
  await tester.enterText(find.byType(TextField), '123456');
  await tester.pumpAndSettle();
}

Future<void> _acceptTerms(WidgetTester tester) async {
  final box = find.byType(KivetoCheckbox);
  await tester.ensureVisible(box);
  await tester.pumpAndSettle();
  await tester.tap(box);
  await tester.pump();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('welcome → code → home: the first name, the active clinic, '
      'the seams', (tester) async {
    final backend = _signInBackend(
      PortalReply.fixture('auth.otp.verify.authenticated.post.200.json'),
    );
    final session = await memorySession();
    final container = await pumpKivetoApp(
      tester,
      session: session,
      backend: backend,
    );
    expect(_location(container), AppRoutes.welcome);

    await _signIn(tester);

    expect(_location(container), AppRoutes.home);
    expect(session.status, SessionStatus.signedIn);
    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(find.text('Clinique Vétérinaire de Paris'), findsOneWidget);
    expect(find.text('Mer. 11 nov. · 10:30'), findsOneWidget);
    expect(find.text('JG'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(container.read(hasConfirmedClinicProvider), isTrue);
  });

  testWidgets('signed in with pending invitations: the code page is not '
      'unmounted by the redirect, the invitations follow; "Plus tard" goes '
      'home', (tester) async {
    final authenticated = jsonDecode(
      File('$portalFixtures/auth.otp.verify.authenticated.post.200.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    final backend = _signInBackend(
      PortalReply.json(
        jsonEncode({
          ...authenticated,
          'pendingInvitations': [
            {
              'invitationId': 'i1',
              'clinic': {
                'name': 'Clinique Vétérinaire de Lyon',
                'city': 'Lyon',
              },
            },
          ],
          'onboardingToken': 'onb',
          'onboardingTokenExpiresAt': '2026-11-03T10:38:35+00:00',
        }),
      ),
    );
    final container = await pumpKivetoApp(tester, backend: backend);

    await _signIn(tester);

    expect(_location(container), AppRoutes.onboardingInvitations);
    expect(
      find.text('Invitation : Clinique Vétérinaire de Lyon'),
      findsOneWidget,
    );

    await _tapVisible(tester, find.text('Plus tard'));
    expect(_location(container), AppRoutes.home);
  });

  testWidgets('invited: the invitations signed out; accepted, home', (
    tester,
  ) async {
    final backend =
        _signInBackend(
          PortalReply.fixture(
            'auth.otp.verify.invitation-pending.post.200.json',
          ),
        )..on(
          'POST',
          '$api/invitations/01a19a10-d14e-7ed1-8251-a40291ac5ce9/accept',
          _tokens('A'),
        );
    final session = await memorySession();
    final container = await pumpKivetoApp(
      tester,
      session: session,
      backend: backend,
    );

    await _signIn(tester);
    expect(_location(container), AppRoutes.onboardingInvitations);
    expect(session.status, SessionStatus.signedOut);

    await _acceptTerms(tester);
    await _tapVisible(tester, find.text('Activer mon espace'));

    expect(session.status, SessionStatus.signedIn);
    expect(_location(container), AppRoutes.home);
    expect(find.text('Bonjour Julien'), findsOneWidget);
  });

  testWidgets('no account: the registration; created, the router goes home '
      'then to the clinic search (no clinic)', (tester) async {
    final backend =
        _signInBackend(
          PortalReply.fixture(
            'auth.otp.verify.registration-required.post.200.json',
          ),
          me: 'me.no-clinic.get',
        )..on(
          'POST',
          '$api/auth/register',
          PortalReply.fixture('auth.register.post.201.json', status: 201),
        );
    final session = await memorySession();
    final container = await pumpKivetoApp(
      tester,
      session: session,
      backend: backend,
    );

    await _signIn(tester);
    expect(_location(container), AppRoutes.register);
    expect(find.text('06 12 34 56 78 vérifié'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.widgetWithText(KivetoTextField, 'Prénom'),
        matching: find.byType(TextField),
      ),
      'Test',
    );
    await tester.enterText(
      find.descendant(
        of: find.widgetWithText(KivetoTextField, 'Nom'),
        matching: find.byType(TextField),
      ),
      'Capture',
    );
    await _acceptTerms(tester);
    await _tapVisible(tester, find.text('Créer mon compte'));

    expect(session.status, SessionStatus.signedIn);
    expect(_location(container), AppRoutes.clinics);
    expect(find.byType(ClinicSearchPage), findsOneWidget);
  });

  testWidgets('"Modifier" on the code page: back to the welcome page, the '
      'number kept', (tester) async {
    final backend = _signInBackend(problem('otp_invalid', 422));
    final container = await pumpKivetoApp(tester, backend: backend);
    await tester.enterText(find.byType(TextField), '612345678');
    await tester.pump();
    await tester.tap(find.text('Recevoir mon code'));
    await tester.pumpAndSettle();

    await tester.tapOnText(find.textRange.ofSubstring('Modifier'));
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.welcome);
    expect(find.text('6 12 34 56 78'), findsWidgets);
    expect(
      tester
          .widget<KivetoButton>(
            find.widgetWithText(KivetoButton, 'Recevoir mon code'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('a pasted invitation link opens the invitation page', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        '$api/invitations/lookup',
        PortalReply.fixture('invitations.lookup.post.200.json'),
      )
      ..on(
        'POST',
        '$api/invitations/otp',
        PortalReply.fixture('invitations.otp.post.202.json', status: 202),
      )
      ..on(
        'GET',
        _terms,
        PortalReply.fixture('legal.terms.current.get.200.json'),
      );
    final container = await pumpKivetoApp(tester, backend: backend);

    await tester.tapOnText(
      find.textRange.ofSubstring("J'ai un lien d'invitation"),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      ),
      'https://portal.kiveto.local/invitation#t=ROUSSEL_TOKEN',
    );
    await tester.tap(find.text("Ouvrir l'invitation"));
    await tester.pumpAndSettle();

    expect(Uri.parse(_location(container)).path, AppRoutes.invitation);
    expect(
      find.text('Invitation : Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
    expect(
      utf8.decode(backend.requestsTo('$api/invitations/lookup').single.body),
      '{"token":"ROUSSEL_TOKEN"}',
    );
  });

  testWidgets('a restart signed in: the shell, /me loaded, no sign-in', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'));
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
    );

    expect(_location(container), AppRoutes.home);
    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(bearerOf(backend.requestsTo(_me).single), 'Bearer A');
  });

  testWidgets('a clinic-less account (capture): /home goes to /clinics', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.no-clinic.get.200.json'));
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
    );

    expect(container.read(hasConfirmedClinicProvider), isFalse);
    expect(_location(container), AppRoutes.clinics);
    expect(find.text('TC'), findsOneWidget);
    expect(container.read(unreadDocumentsCountProvider), 0);
  });

  testWidgets('the home: the stored clinic of this account, its badge; no '
      'first name: "Bonjour"', (tester) async {
    final me = jsonDecode(
      File('$portalFixtures/me.get.200.json').readAsStringSync(),
    ) as Map<String, Object?>;
    (me['account']! as Map<String, Object?>)['firstName'] = null;
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.json(jsonEncode(me)))
      ..on(
        'GET',
        _lyonHome,
        PortalReply.fixture('clinics.lyon.home.get.200.json'),
      );
    await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      activeClinicStore: InMemoryActiveClinicStore(
        choices: {
          '01a19a10-d011-70c8-8daf-26e4db824374':
              '01960000-0000-7000-8000-000000000101',
        },
      ),
    );

    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.text('Clinique Vétérinaire de Lyon'), findsOneWidget);
    expect(find.text('Pixel'), findsOneWidget);
    expect(backend.requestsTo(_lyonHome), hasLength(1));
    expect(find.text('G'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('the home: /me fails, an error view; retry', (tester) async {
    var calls = 0;
    final backend = FakePortalBackend()
      ..onRequest('GET', _me, (_) {
        calls++;
        return calls == 1
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('me.get.200.json');
      })
      ..on(
        'GET',
        _parisHome,
        PortalReply.fixture('clinics.paris.home.get.200.json'),
      );
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
    );
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(container.read(hasConfirmedClinicProvider), isNull);

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(find.text('Oslo'), findsOneWidget);
  });

  testWidgets('/me loading after a session change: the seams are unknown, '
      "never the previous account's", (tester) async {
    var gate = Completer<void>()..complete();
    final backend = FakePortalBackend()
      ..onRequest('GET', _me, (request) async {
        await gate.future;
        return bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('me.get.200.json')
            : PortalReply.fixture('me.no-clinic.get.200.json');
      });
    final session = await memorySession(pair('A'));
    final container = await pumpKivetoApp(
      tester,
      session: session,
      backend: backend,
    );
    expect(container.read(hasConfirmedClinicProvider), isTrue);
    expect(container.read(accountInitialsProvider), 'JG');

    gate = Completer<void>();
    unawaited(session.open(pair('B')));
    await tester.pump();

    expect(container.read(hasConfirmedClinicProvider), isNull);
    expect(container.read(accountInitialsProvider), isNull);
    expect(container.read(unreadDocumentsCountProvider), 0);

    gate.complete();
    await tester.pumpAndSettle();
    expect(container.read(hasConfirmedClinicProvider), isFalse);
    expect(container.read(accountInitialsProvider), 'TC');
    expect(_location(container), AppRoutes.clinics);
  });

  group('the logout', () {
    testWidgets('an expired access token: one refresh, the body replayed, '
        'signed out on the welcome page', (tester) async {
      // The refreshed pair of the capture.
      final refreshedAccess =
          (jsonDecode(
                File('$portalFixtures/auth.refresh.post.200.json')
                    .readAsStringSync(),
              ) as Map<String, Object?>)['accessToken']!
              as String;
      final backend = FakePortalBackend()
        ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
        ..onRequest(
          'POST',
          _logout,
          (request) => bearerOf(request) == 'Bearer $refreshedAccess'
              ? PortalReply.empty(204)
              : problem('token_expired', 401),
        )
        ..on(
          'POST',
          _refresh,
          PortalReply.fixture('auth.refresh.post.200.json'),
        );
      final session = await memorySession(pair('A'));
      final container = await pumpKivetoApp(
        tester,
        session: session,
        backend: backend,
        initialLocation: AppRoutes.account,
      );

      await _tapSignOut(tester);
      await tester.pumpAndSettle();

      expect(backend.requestsTo(_refresh), hasLength(1));
      expect(
        utf8.decode(backend.requestsTo(_refresh).single.body),
        '{"refreshToken":"refresh-A"}',
      );
      final logouts = backend.requestsTo(_logout);
      expect(logouts.map(bearerOf), ['Bearer A', 'Bearer $refreshedAccess']);
      expect(logouts.map((request) => utf8.decode(request.body)).toSet(), {
        '{"refreshToken":"refresh-A"}',
      });
      expect(session.status, SessionStatus.signedOut);
      expect(_location(container), AppRoutes.welcome);
      expect(find.byType(WelcomePage), findsOneWidget);
    });

    for (final (name, reply) in [
      (
        'a refused refresh (capture)',
        PortalReply.fixture('auth.refresh.post.401.json', status: 401),
      ),
      ('a server down', problem('service_unavailable', 503)),
    ]) {
      testWidgets('$name: still signed out on the welcome page', (
        tester,
      ) async {
        final backend = FakePortalBackend()
          ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
          ..on('POST', _logout, problem('token_expired', 401))
          ..on('POST', _refresh, reply);
        final session = await memorySession(pair('A'));
        final container = await pumpKivetoApp(
          tester,
          session: session,
          backend: backend,
          initialLocation: AppRoutes.account,
        );

        await _tapSignOut(tester);
        await tester.pumpAndSettle();

        expect(session.status, SessionStatus.signedOut);
        expect(_location(container), AppRoutes.welcome);
      });
    }

    testWidgets('the button is loading while the logout runs', (tester) async {
      final answer = Completer<PortalReply>();
      final backend = FakePortalBackend()
        ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
        ..onRequest('POST', _logout, (_) => answer.future);
      await pumpKivetoApp(
        tester,
        session: await memorySession(pair('A')),
        backend: backend,
        initialLocation: AppRoutes.account,
      );

      await _tapSignOut(tester);
      await tester.pump();

      expect(
        tester
            .widget<KivetoButton>(
              find.widgetWithText(KivetoButton, 'Se déconnecter'),
            )
            .loading,
        isTrue,
      );
      answer.complete(PortalReply.empty(204));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
    });
  });

  testWidgets('the account deletion (screen 6): the 202 closes the session, '
      'no logout is sent, the welcome page shows the confirmation', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
      ..on(
        'POST',
        '$api/me/deletion-request/otp',
        PortalReply.fixture(
          'me.deletion-request.otp.post.202.json',
          status: 202,
        ),
      )
      ..on('POST', '$api/me/deletion-request', PortalReply.empty(202));
    final session = await memorySession(pair('A'));
    final container = await pumpKivetoApp(
      tester,
      session: session,
      backend: backend,
      initialLocation: AppRoutes.account,
    );

    final row = find.text('Demander la suppression de mon compte');
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: find
          .descendant(
            of: find.byType(AccountPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    expect(backend.requestsTo('$api/me/deletion-request'), isEmpty);

    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();

    expect(session.status, SessionStatus.signedOut);
    expect(backend.requestsTo('$api/me/deletion-request'), hasLength(1));
    expect(backend.requestsTo(_logout), isEmpty);
    expect(_location(container), AppRoutes.welcome);
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(
      find.text(
        'Votre demande de suppression est enregistrée : votre compte '
        'est désactivé.',
      ),
      findsOneWidget,
    );
  });
}
