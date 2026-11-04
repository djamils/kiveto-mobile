// Screen 0, the invitation link: the lookup, the code sent at once, the
// acceptance; the expired, invalid, used and missing links; the errors.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/portal_http.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/invitation_controller.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/invitation_page.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/keyboard.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _lookup = '$api/invitations/lookup';
const _otp = '$api/invitations/otp';
const _accept = '$api/invitations/accept';
const _terms = '$api/legal/terms/current';
const _token = 'ROUSSEL_TOKEN';

/// Roussel's lookup with [changes].
PortalReply _lookupWith(Map<String, Object?> changes) => PortalReply.json(
  jsonEncode({
    ...(jsonDecode(
      File('$portalFixtures/invitations.lookup.post.200.json')
          .readAsStringSync(),
    ) as Map<String, Object?>),
    ...changes,
  }),
);

PortalReply _accepted() => PortalReply.json(
  jsonEncode({
    'accessToken': 'A',
    'accessTokenExpiresAt': '2026-11-03T10:38:48+00:00',
    'refreshToken': 'refresh-A',
    'refreshTokenExpiresAt': '2027-02-01T10:23:48+00:00',
    'account': {
      'id': 'acc',
      'firstName': 'Antoine',
      'lastName': 'Roussel',
      'email': 'antoine.roussel@example.com',
      'emailVerified': false,
      'maskedPhone': '+33 6 •• •• •• 55',
      'address': null,
    },
  }),
);

/// The capture of `POST /invitations/otp`: resend 109 s after [testNow].
PortalReply _code() =>
    PortalReply.fixture('invitations.otp.post.202.json', status: 202);

FakePortalBackend _backend({PortalReply? lookup, PortalReply? accept}) {
  final backend = FakePortalBackend()
    ..on(
      'POST',
      _lookup,
      lookup ?? PortalReply.fixture('invitations.lookup.post.200.json'),
    )
    ..on('POST', _otp, _code())
    ..on(
      'GET',
      _terms,
      PortalReply.fixture('legal.terms.current.get.200.json'),
    );
  if (accept != null) backend.on('POST', _accept, accept);
  return backend;
}

Future<(List<String>, SessionManager)> _pump(
  WidgetTester tester, {
  String? token = _token,
  FakePortalBackend? backend,
  bool signedIn = false,
  FixedClock? clock,
}) async {
  final exits = <String>[];
  final session = await memorySession(signedIn ? pair('A') : null);
  await pumpPage(
    tester,
    InvitationPage(
      token: token,
      onDone: (_) => exits.add('home'),
      onSignIn: (_) => exits.add('sign-in'),
    ),
    session: session,
    backend: backend ?? _backend(),
    clock: clock,
  );
  return (exits, session);
}

Future<void> _typeCode(WidgetTester tester, String code) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(KivetoCodeField),
      matching: find.byType(TextField),
    ),
    code,
  );
  await tester.pump();
}

Future<void> _acceptTerms(WidgetTester tester) async {
  await tester.tap(find.byType(KivetoCheckbox));
  await tester.pump();
}

KivetoButton _cta(WidgetTester tester) => tester.widget<KivetoButton>(
  find.widgetWithText(KivetoButton, 'Activer mon espace'),
);

String? _codeError(WidgetTester tester) =>
    tester.widget<KivetoCodeField>(find.byType(KivetoCodeField)).errorText;

void main() {
  testWidgets(
    'iOS: the number pad has no return key, a drag on the page closes it',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await _pump(tester);

      await expectDragClosesKeyboard(
        tester,
        field: find.byType(KivetoCodeField),
        from: find.text('Code reçu par SMS au +33 6 •• •• •• 55'),
      );
    },
  );

  testWidgets('a valid link (Roussel): the clinic, the pets, the read-only '
      'email, the code sent at once to the masked mobile; accepted, the '
      'session opens, home', (tester) async {
    final backend = _backend(accept: _accepted());
    final (exits, session) = await _pump(tester, backend: backend);

    expect(find.text('Kiveto'), findsOneWidget);
    expect(
      find.text('Invitation : Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
    expect(
      find.text('Activez votre espace pour suivre Ulysse'),
      findsOneWidget,
    );
    expect(
      find.text('Rendez-vous, documents et rappels de soins, au même endroit.'),
      findsOneWidget,
    );
    final email = tester.widget<KivetoTextField>(
      find.widgetWithText(KivetoTextField, 'Email'),
    );
    expect(email.readOnly, isTrue);
    expect(email.controller?.text, 'antoine.roussel@gmail.com');
    expect(find.text('Renseigné par la clinique.'), findsOneWidget);
    expect(find.text('Code reçu par SMS au +33 6 •• •• •• 55'), findsOneWidget);
    expect(find.text('6 chiffres'), findsOneWidget);
    expect(find.text('Renvoyer le code dans 1:49'), findsOneWidget);
    expect(
      find.text(
        'Déjà un compte Kiveto ? Rattacher cette clinique',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(jsonDecode(utf8.decode(backend.requestsTo(_otp).single.body)), {
      'token': _token,
    });
    expect(find.textContaining(_token), findsNothing);
    expect(_cta(tester).onPressed, isNull);

    await _typeCode(tester, '123456');
    expect(_cta(tester).onPressed, isNull);
    await _acceptTerms(tester);
    expect(_cta(tester).onPressed, isNotNull);

    await _activate(tester);
    await pumpBriefly(tester);

    expect(jsonDecode(utf8.decode(backend.requestsTo(_accept).single.body)), {
      'token': _token,
      'challengeId': '01a1a0ef-e80b-7435-83d5-132dfd62759a',
      'code': '123456',
      'termsVersion': '2026-10-29',
    });
    expect(session.status, SessionStatus.signedIn);
    expect(exits, ['home']);
  });

  testWidgets('"Rattacher cette clinique" (signed out) goes to the sign-in', (
    tester,
  ) async {
    final (exits, _) = await _pump(tester);
    await tester.ensureVisible(
      find.textContaining('Rattacher', findRichText: true),
    );
    await tester.pumpAndSettle();

    await tester.tapOnText(
      find.textRange.ofSubstring('Rattacher cette clinique'),
    );

    expect(exits, ['sign-in']);
  });

  for (final signedIn in [false, true]) {
    testWidgets('the system back (${signedIn ? 'signed in' : 'signed out'}) '
        'leaves through ${signedIn ? 'the home' : 'the sign-in'}, not out '
        'of the app', (tester) async {
      final (exits, _) = await _pump(tester, signedIn: signedIn);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(InvitationPage), findsOneWidget);
      expect(exits, [if (signedIn) 'home' else 'sign-in']);
    });
  }

  testWidgets('a missing link: the system back leaves through the sign-in', (
    tester,
  ) async {
    final (exits, _) = await _pump(tester, token: null);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(exits, ['sign-in']);
  });

  testWidgets('signed in: no "Rattacher cette clinique", a way back home', (
    tester,
  ) async {
    final (exits, _) = await _pump(tester, signedIn: true);

    expect(find.textContaining('Déjà un compte'), findsNothing);
    expect(find.text('Activer mon espace'), findsOneWidget);
    final back = find.widgetWithText(KivetoLinkButton, "Revenir à l'accueil");
    await tester.ensureVisible(back);
    await tester.pumpAndSettle();
    await tester.tap(back);

    expect(exits, ['home']);
  });

  testWidgets('while a code is being sent, no acceptance; while an '
      'acceptance runs, no resend', (tester) async {
    final code = Completer<PortalReply>();
    final accept = Completer<PortalReply>();
    var codes = 0;
    final backend = _backend()
      ..onRequest('POST', _otp, (_) {
        codes++;
        return codes == 1 ? _code() : code.future;
      })
      ..onRequest('POST', _accept, (_) => accept.future);
    final clock = FixedClock(testNow);
    await _pump(tester, backend: backend, clock: clock);
    await _typeCode(tester, '123456');
    await _acceptTerms(tester);

    // The countdown over: a new code requested, still in flight.
    clock.instant = DateTime.utc(2026, 11, 3, 10, 24, 29);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Renvoyer le code'));
    await tester.pump();
    expect(_cta(tester).onPressed, isNull);
    code.complete(_code());
    await tester.pumpAndSettle();

    clock.instant = DateTime.utc(2026, 11, 3, 10, 30);
    await tester.pump(const Duration(seconds: 1));
    expect(_cta(tester).onPressed, isNotNull);
    await _activate(tester);
    await tester.pump();
    final resend = tester.widget<KivetoTextButton>(
      find.widgetWithText(KivetoTextButton, 'Renvoyer le code'),
    );
    expect(resend.onPressed, isNull);
    accept.complete(problem('otp_invalid', 422));
    await tester.pumpAndSettle();
  });

  group('the controller: an answer arriving after the invitation closed is '
      'dropped', () {
    late ProviderSubscription<InvitationState> listening;

    Future<(ProviderContainer, FakePortalBackend)> start() async {
      final backend = FakePortalBackend();
      final session = await memorySession();
      final http = PortalHttp.create(
        config: ApiConfig(baseUrl: Uri.parse('http://portal.test')),
        session: session,
        deviceId: 'device-test',
        adapter: backend,
      );
      addTearDown(http.close);
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          sessionManagerProvider.overrideWithValue(session),
          portalHttpProvider.overrideWithValue(http),
          apiConfigProvider.overrideWithValue(
            ApiConfig(baseUrl: Uri.parse('http://portal.test')),
          ),
        ],
      );
      addTearDown(container.dispose);
      listening = container.listen(invitationControllerProvider, (_, _) {});
      return (container, backend);
    }

    for (final answer in [
      PortalReply.fixture('invitations.otp.post.202.json', status: 202),
      problem('otp_rate_limited', 429),
    ]) {
      test('a code answer (${answer.status})', () async {
        final (container, backend) = await start();
        final code = Completer<PortalReply>();
        var lookups = 0;
        backend
          ..onRequest('POST', _lookup, (_) {
            lookups++;
            return lookups == 1
                ? PortalReply.fixture('invitations.lookup.post.200.json')
                : problem('invitation_expired', 410);
          })
          ..onRequest('POST', _otp, (_) => code.future);
        final controller = container.read(
          invitationControllerProvider.notifier,
        );

        final first = controller.open(_token);
        await pumpEventQueue();
        expect(
          container.read(invitationControllerProvider),
          isA<InvitationReady>().having((s) => s.sendingCode, 'sending', true),
        );
        // The same link read again: expired meanwhile.
        await controller.open(_token);
        code.complete(answer);

        await expectLater(first, completes);
        expect(
          container.read(invitationControllerProvider),
          isA<InvitationClosed>().having(
            (s) => s.reason,
            'reason',
            InvitationClosedReason.expired,
          ),
        );
      });
    }

    test('an acceptance answer', () async {
      final (container, backend) = await start();
      final accept = Completer<PortalReply>();
      var lookups = 0;
      backend
        ..onRequest('POST', _lookup, (_) {
          lookups++;
          return lookups == 1
              ? PortalReply.fixture('invitations.lookup.post.200.json')
              : problem('invitation_already_used', 410);
        })
        ..on('POST', _otp, _code())
        ..onRequest('POST', _accept, (_) => accept.future);
      final controller = container.read(invitationControllerProvider.notifier);
      await controller.open(_token);

      final accepting = controller.accept(
        code: '123456',
        termsVersion: '2026-10-29',
      );
      await pumpEventQueue();
      await controller.open(_token);
      accept.complete(problem('otp_invalid', 422));

      expect(await accepting, isFalse);
      expect(
        container.read(invitationControllerProvider),
        isA<InvitationClosed>(),
      );
    });

    for (final answer in [
      PortalReply.fixture('invitations.otp.post.202.json', status: 202),
      problem('otp_rate_limited', 429),
    ]) {
      test('the page left while the code request runs (${answer.status}): '
          'the answer is dropped', () async {
        final (container, backend) = await start();
        final code = Completer<PortalReply>();
        backend
          ..on(
            'POST',
            _lookup,
            PortalReply.fixture('invitations.lookup.post.200.json'),
          )
          ..onRequest('POST', _otp, (_) => code.future);
        final opening = container
            .read(invitationControllerProvider.notifier)
            .open(_token);
        await pumpEventQueue();

        listening.close();
        await pumpEventQueue();
        expect(container.exists(invitationControllerProvider), isFalse);
        code.complete(answer);

        await expectLater(opening, completes);
      });
    }

    test('the page left while the acceptance runs: the refusal is '
        'dropped', () async {
      final (container, backend) = await start();
      final accept = Completer<PortalReply>();
      backend
        ..on(
          'POST',
          _lookup,
          PortalReply.fixture('invitations.lookup.post.200.json'),
        )
        ..on('POST', _otp, _code())
        ..onRequest('POST', _accept, (_) => accept.future);
      final controller = container.read(invitationControllerProvider.notifier);
      await controller.open(_token);
      final accepting = controller.accept(
        code: '123456',
        termsVersion: '2026-10-29',
      );
      await pumpEventQueue();

      listening.close();
      await pumpEventQueue();
      expect(container.exists(invitationControllerProvider), isFalse);
      accept.complete(problem('otp_invalid', 422));

      expect(await accepting, isFalse);
    });
  });

  group('the link being read, or unreadable: a way out (no back on a '
      'page reached by a link)', () {
    for (final signedIn in [false, true]) {
      final (label, exit) = signedIn
          ? ("Revenir à l'accueil", 'home')
          : ('Se connecter avec mon numéro', 'sign-in');

      testWidgets('loading, ${signedIn ? 'signed in' : 'signed out'}: '
          '"$label"', (tester) async {
        final lookup = Completer<PortalReply>();
        final backend = _backend()
          ..onRequest('POST', _lookup, (_) => lookup.future);
        final exits = <String>[];
        await pumpPage(
          tester,
          InvitationPage(
            token: _token,
            onDone: (_) => exits.add('home'),
            onSignIn: (_) => exits.add('sign-in'),
          ),
          session: await memorySession(signedIn ? pair('A') : null),
          backend: backend,
          settle: false,
        );
        await tester.pump();

        expect(find.byType(LoadingView), findsOneWidget);
        await tester.tap(find.widgetWithText(KivetoLinkButton, label));
        expect(exits, [exit]);

        lookup.complete(problem('invitation_invalid', 404));
        await tester.pumpAndSettle();
      });

      testWidgets('unreadable, ${signedIn ? 'signed in' : 'signed out'}: '
          'the retry and "$label"', (tester) async {
        final (exits, _) = await _pump(
          tester,
          backend: _backend(lookup: problem('service_unavailable', 503)),
          signedIn: signedIn,
        );

        expect(find.text('Service indisponible'), findsOneWidget);
        expect(find.text('Réessayer'), findsOneWidget);
        await tester.tap(find.widgetWithText(KivetoLinkButton, label));
        expect(exits, [exit]);
      });
    }
  });

  testWidgets('no pet, no email: the generic title, no email field', (
    tester,
  ) async {
    await _pump(
      tester,
      backend: _backend(lookup: _lookupWith({'petNames': [], 'email': null})),
    );

    expect(find.text('Activez votre espace'), findsOneWidget);
    expect(find.widgetWithText(KivetoTextField, 'Email'), findsNothing);
  });

  testWidgets('several pets: "A, B et C"', (tester) async {
    await _pump(
      tester,
      backend: _backend(
        lookup: _lookupWith({
          'petNames': ['Moka', 'Oslo', 'Pistache'],
        }),
      ),
    );

    expect(
      find.text('Activez votre espace pour suivre Moka, Oslo et Pistache'),
      findsOneWidget,
    );
  });

  group('a link that cannot be used', () {
    for (final (name, reply, title, body) in [
      (
        'expired (PERRIN, capture)',
        PortalReply.fixture(
          'invitations.lookup.expired.post.410.json',
          status: 410,
        ),
        'Invitation expirée',
        "Ce lien n'est plus valable. Demandez à votre clinique de vous "
            'renvoyer une invitation.',
      ),
      (
        'invalid (capture)',
        PortalReply.fixture(
          'invitations.lookup.invalid.post.404.json',
          status: 404,
        ),
        "Lien d'invitation invalide",
        'Ce lien est incomplet ou a été remplacé par un envoi plus récent. '
            'Utilisez le dernier lien reçu, ou connectez-vous avec votre '
            'numéro.',
      ),
      (
        'already used',
        problem('invitation_already_used', 410),
        'Invitation déjà utilisée',
        'Cette invitation a déjà été acceptée. Connectez-vous avec votre '
            'numéro pour retrouver votre espace.',
      ),
    ]) {
      testWidgets('$name: its explanation, "Se connecter avec mon numéro"', (
        tester,
      ) async {
        final (exits, _) = await _pump(
          tester,
          backend: _backend(lookup: reply),
        );

        expect(find.text(title), findsOneWidget);
        expect(find.text(body), findsOneWidget);
        await tester.tap(find.text('Se connecter avec mon numéro'));
        expect(exits, ['sign-in']);
      });
    }

    testWidgets('missing (no #t=), signed in: "Revenir à l\'accueil"', (
      tester,
    ) async {
      final backend = _backend();
      final (exits, _) = await _pump(
        tester,
        token: null,
        backend: backend,
        signedIn: true,
      );

      expect(find.text("Lien d'invitation invalide"), findsOneWidget);
      expect(backend.requests, isEmpty);
      await tester.tap(find.text("Revenir à l'accueil"));
      expect(exits, ['home']);
    });

    testWidgets('closed at the code request', (tester) async {
      final backend = _backend()
        ..on('POST', _otp, problem('invitation_expired', 410));
      await _pump(tester, backend: backend);

      expect(find.text('Invitation expirée'), findsOneWidget);
    });

    testWidgets('closed at the acceptance', (tester) async {
      await _pump(
        tester,
        backend: _backend(accept: problem('invitation_already_used', 410)),
      );

      await _typeCode(tester, '123456');
      await _acceptTerms(tester);
      await _activate(tester);
      await tester.pumpAndSettle();

      expect(find.text('Invitation déjà utilisée'), findsOneWidget);
    });
  });

  testWidgets('a lookup that fails (network, 5xx): an error view with a '
      'retry', (tester) async {
    var calls = 0;
    final backend = _backend()
      ..onRequest('POST', _lookup, (_) {
        calls++;
        return calls == 1
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('invitations.lookup.post.200.json');
      });
    await _pump(tester, backend: backend);

    expect(find.text('Service indisponible'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(
      find.text('Invitation : Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
  });

  testWidgets('a wrong code: under the field, cleared on edit', (tester) async {
    await _pump(
      tester,
      backend: _backend(
        accept: PortalReply.fixture(
          'auth.otp.verify.otp-invalid.post.422.json',
          status: 422,
        ),
      ),
    );

    await _typeCode(tester, '000000');
    await _acceptTerms(tester);
    await _activate(tester);
    await tester.pumpAndSettle();

    expect(_codeError(tester), 'Code incorrect. Vérifiez-le, puis réessayez.');

    await _typeCode(tester, '00000');
    expect(_codeError(tester), isNull);
  });

  testWidgets('terms_outdated: reloaded, unchecked, the message; no '
      'acceptance until the new terms are loaded, then with their version', (
    tester,
  ) async {
    final reloaded = Completer<PortalReply>();
    var termsCalls = 0;
    var accepts = 0;
    final backend = _backend()
      ..onRequest('GET', _terms, (_) async {
        termsCalls++;
        return termsCalls == 1
            ? PortalReply.fixture('legal.terms.current.get.200.json')
            : await reloaded.future;
      })
      ..onRequest('POST', _accept, (_) {
        accepts++;
        return accepts == 1
            ? PortalReply.fixture(
                'auth.register.terms-outdated.post.422.json',
                status: 422,
              )
            : _accepted();
      });
    final (exits, _) = await _pump(tester, backend: backend);

    await _typeCode(tester, '123456');
    await _acceptTerms(tester);
    await _activate(tester);
    await tester.pumpAndSettle();

    expect(
      find.textContaining("Les conditions d'utilisation ont changé"),
      findsOneWidget,
    );
    expect(
      tester.widget<KivetoCheckbox>(find.byType(KivetoCheckbox)).value,
      isFalse,
    );
    expect(termsCalls, 2);
    expect(_codeError(tester), isNull);

    // Ticked again while the new terms load: the button waits.
    await _acceptTerms(tester);
    expect(_cta(tester).onPressed, isNull);

    reloaded.complete(
      PortalReply.json(
        '{"version":"2026-11-01","url":"http://portal.kiveto.local/cgu"}',
      ),
    );
    await tester.pumpAndSettle();
    expect(_cta(tester).onPressed, isNotNull);
    await _activate(tester);
    await pumpBriefly(tester);

    expect(
      (jsonDecode(utf8.decode(backend.requestsTo(_accept).last.body))
          as Map<String, Object?>)['termsVersion'],
      '2026-11-01',
    );
    expect(exits, ['home']);
  });

  testWidgets('a quota on the code request: shown with the resend control, '
      'which sends a new code', (tester) async {
    var calls = 0;
    final backend = _backend()
      ..onRequest('POST', _otp, (_) {
        calls++;
        return calls == 1
            ? PortalReply.fixture(
                'auth.otp.request.post.429.json',
                status: 429,
                headers: {
                  'Retry-After': ['600'],
                },
              )
            : _code();
      });
    await _pump(tester, backend: backend);

    expect(
      find.text('Trop de demandes de code. Réessayez dans 10 min.'),
      findsOneWidget,
    );
    expect(_cta(tester).onPressed, isNull);

    await tester.tap(find.text('Renvoyer le code'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Trop de demandes'), findsNothing);
    expect(find.text('Nouveau code envoyé par SMS.'), findsOneWidget);
    expect(find.text('Renvoyer le code dans 1:49'), findsOneWidget);
  });

  testWidgets('the resend after the countdown', (tester) async {
    final clock = FixedClock(testNow);
    final backend = _backend();
    await _pump(tester, backend: backend, clock: clock);

    clock.instant = DateTime.utc(2026, 11, 3, 10, 24, 29);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Renvoyer le code'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_otp), hasLength(2));
    expect(find.text('Nouveau code envoyé par SMS.'), findsOneWidget);
  });
}

/// Taps "Activer mon espace" (scrolled into view).
Future<void> _activate(WidgetTester tester) async {
  final button = find.text('Activer mon espace');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
}
