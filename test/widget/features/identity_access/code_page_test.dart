// Screen 8: the number the code went to, the 6 boxes verified on the 6th
// digit, the branch of each answer, the errors under the boxes (cleared on
// the next digit), the resend after the countdown.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/code_page.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _verify = '$api/auth/otp/verify';
const _challenge = '01a1a0ee-b560-7aca-b883-0473f9c33042';
const _resend = '$api/auth/otp/$_challenge/resend';

final PhoneNumber _flowPhone = PhoneNumber.fromNational(
  countryCode: '+33',
  national: '612345678',
)!;

/// The challenge of `auth.otp.request.post.202.json`: resend 30 s after
/// [testNow].
final _flowChallenge = OtpChallenge(
  id: _challenge,
  expiresAt: DateTime.utc(2026, 11, 3, 10, 32, 40),
  resendAvailableAt: DateTime.utc(2026, 11, 3, 10, 23, 10),
);

final class _Exits {
  final taken = <String>[];
}

Future<(ProviderContainer, _Exits, SessionManager)> _pump(
  WidgetTester tester, {
  FakePortalBackend? backend,
  FixedClock? clock,
  bool flow = true,
}) async {
  final exits = _Exits();
  final session = await memorySession();
  final container = await pumpPage(
    tester,
    CodePage(
      onSignedIn: (_) => exits.taken.add('home'),
      onInvitations: (_) => exits.taken.add('invitations'),
      onRegister: (_) => exits.taken.add('register'),
      onRestart: (_) => exits.taken.add('restart'),
    ),
    session: session,
    backend: backend,
    clock: clock,
    prepare: flow
        ? (container) => container
              .read(signInFlowProvider.notifier)
              .start(_flowPhone, _flowChallenge)
        : null,
  );
  return (container, exits, session);
}

Future<void> _type(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField), code);
  await pumpBriefly(tester);
}

String? _otpError(WidgetTester tester) =>
    tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText;

void main() {
  testWidgets('without its flow: back to the start', (tester) async {
    final (_, exits, _) = await _pump(tester, flow: false);

    expect(exits.taken, ['restart']);
  });

  testWidgets('the layout: the number, the boxes, the countdown', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Entrez le code reçu'), findsOneWidget);
    expect(
      find.text(
        'Envoyé par SMS au 06 12 34 56 78. Modifier',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Code de vérification'), findsOneWidget);
    expect(find.text('Valable 10 minutes.'), findsOneWidget);
    expect(find.text('Renvoyer le SMS dans 0:30'), findsOneWidget);
    final buttons = tester.widgetList<KivetoTextButton>(
      find.byType(KivetoTextButton),
    );
    expect(buttons.map((b) => b.label), [
      'Renvoyer le SMS dans 0:30',
      'Recevoir le code par email',
    ]);
    expect(buttons.every((b) => b.onPressed == null), isTrue);
    expect(find.textContaining("Vous n'avez pas reçu"), findsNothing);
    expect(
      tester
          .widget<KivetoButton>(find.widgetWithText(KivetoButton, 'Valider'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('back and "Modifier" go back to the welcome page', (
    tester,
  ) async {
    final (_, exits, _) = await _pump(tester);

    await tester.tap(find.byType(KivetoIconButton));
    await tester.tapOnText(find.textRange.ofSubstring('Modifier'));
    // The system back button.
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();

    expect(exits.taken, ['restart', 'restart', 'restart']);
  });

  testWidgets('a wrong code then the right one: the error shows, clears on '
      'the next digit, the right code opens the session and goes home', (
    tester,
  ) async {
    var attempts = 0;
    final backend = FakePortalBackend()
      ..onRequest('POST', _verify, (request) {
        attempts++;
        return attempts == 1
            ? PortalReply.fixture(
                'auth.otp.verify.otp-invalid.post.422.json',
                status: 422,
              )
            : PortalReply.fixture(
                'auth.otp.verify.authenticated.post.200.json',
              );
      });
    final (container, exits, session) = await _pump(tester, backend: backend);

    await _type(tester, '000000');

    expect(_otpError(tester), 'Code incorrect. Vérifiez-le, puis réessayez.');
    expect(
      find.text('Code incorrect. Vérifiez-le, puis réessayez.'),
      findsOneWidget,
    );
    expect(find.text('Valable 10 minutes.'), findsNothing);
    expect(session.status, SessionStatus.signedOut);

    await _type(tester, '4');
    expect(_otpError(tester), isNull);
    expect(find.text('Valable 10 minutes.'), findsOneWidget);

    await _type(tester, '481234');

    expect(exits.taken, ['home']);
    expect(session.status, SessionStatus.signedIn);
    expect(container.read(signInFlowProvider), isNull);
    expect(
      backend.requestsTo(_verify).map((r) => jsonDecode(utf8.decode(r.body))),
      [
        {'challengeId': _challenge, 'code': '000000'},
        {'challengeId': _challenge, 'code': '481234'},
      ],
    );
  });

  testWidgets('while verifying: "Valider" is loading', (tester) async {
    final answer = Completer<PortalReply>();
    final backend = FakePortalBackend()
      ..onRequest('POST', _verify, (_) => answer.future);
    await _pump(tester, backend: backend);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(
      tester
          .widget<KivetoButton>(find.widgetWithText(KivetoButton, 'Valider'))
          .loading,
      isTrue,
    );
    answer.complete(problem('otp_invalid', 422));
    await tester.pumpAndSettle();
    expect(backend.requestsTo(_verify), hasLength(1));
  });

  testWidgets('while verifying: back, "Modifier" and the system back stay, '
      'and neither resend is offered (countdown over)', (tester) async {
    final answer = Completer<PortalReply>();
    final clock = FixedClock(testNow);
    final backend = FakePortalBackend()
      ..onRequest('POST', _verify, (_) => answer.future);
    final (_, exits, _) = await _pump(tester, backend: backend, clock: clock);
    clock.instant = DateTime.utc(2026, 11, 3, 10, 23, 10);
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    final resends = tester.widgetList<KivetoTextButton>(
      find.byType(KivetoTextButton),
    );
    expect(resends.map((button) => button.label), [
      'Renvoyer le SMS',
      'Recevoir le code par email',
    ]);
    expect(resends.every((button) => button.onPressed == null), isTrue);

    await tester.tap(find.byType(KivetoIconButton));
    await tester.tapOnText(find.textRange.ofSubstring('Modifier'));
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pump();
    expect(exits.taken, isEmpty);

    answer.complete(problem('otp_invalid', 422));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(KivetoIconButton));
    expect(exits.taken, ['restart']);
  });

  testWidgets('while a resend runs: no verification, "Valider" disabled', (
    tester,
  ) async {
    final resent = Completer<PortalReply>();
    final clock = FixedClock(testNow);
    final backend = FakePortalBackend()
      ..onRequest('POST', _resend, (_) => resent.future)
      ..on(
        'POST',
        _verify,
        PortalReply.fixture(
          'auth.otp.verify.otp-invalid.post.422.json',
          status: 422,
        ),
      );
    await _pump(tester, backend: backend, clock: clock);
    clock.instant = DateTime.utc(2026, 11, 3, 10, 23, 10);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Renvoyer le SMS'));
    await tester.pump();

    // The 6th digit completes the code: no verification during the resend.
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(backend.requestsTo(_verify), isEmpty);
    expect(
      tester
          .widget<KivetoButton>(find.widgetWithText(KivetoButton, 'Valider'))
          .onPressed,
      isNull,
    );

    resent.complete(
      PortalReply.json(
        jsonEncode({
          'challengeId': _challenge,
          'expiresAt': '2026-11-03T10:33:10+00:00',
          'resendAvailableAt': '2026-11-03T10:23:40+00:00',
        }),
        status: 202,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<KivetoButton>(find.widgetWithText(KivetoButton, 'Valider'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('signed in with pending invitations: the session opens, then '
      'the invitations (signed-in variant)', (tester) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        _verify,
        PortalReply.json(
          jsonEncode({
            ...(jsonDecode(
              File(
                '$portalFixtures/auth.otp.verify.authenticated.post.200.json',
              ).readAsStringSync(),
            ) as Map<String, Object?>),
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
    final (container, exits, session) = await _pump(tester, backend: backend);

    await _type(tester, '123456');

    expect(exits.taken, ['invitations']);
    expect(session.status, SessionStatus.signedIn);
    final onboarding = container.read(onboardingProvider)!;
    expect(onboarding.signedIn, isTrue);
    expect(onboarding.grant.token, 'onb');
    expect(
      onboarding.invitations.single.clinicName,
      'Clinique Vétérinaire de Lyon',
    );
  });

  testWidgets('invited: no session, the invitations (signed out)', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        _verify,
        PortalReply.fixture('auth.otp.verify.invitation-pending.post.200.json'),
      );
    final (container, exits, session) = await _pump(tester, backend: backend);

    await _type(tester, '123456');

    expect(exits.taken, ['invitations']);
    expect(session.status, SessionStatus.signedOut);
    final onboarding = container.read(onboardingProvider)!;
    expect(onboarding.signedIn, isFalse);
    expect(
      onboarding.invitations.single.clinicName,
      'Clinique Vétérinaire de Paris',
    );
  });

  testWidgets('no account: the registration, with the number', (tester) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        _verify,
        PortalReply.fixture(
          'auth.otp.verify.registration-required.post.200.json',
        ),
      );
    final (container, exits, session) = await _pump(tester, backend: backend);

    await _type(tester, '123456');

    expect(exits.taken, ['register']);
    expect(session.status, SessionStatus.signedOut);
    final registration = container.read(registrationFlowProvider)!;
    expect(registration.phone, _flowPhone);
    expect(
      registration.grant.token,
      't7OYpg5LsCy88SrpM_qqvW3DEiOgYeFmKWvQSInRp4w',
    );
  });

  group('the verification errors under the boxes', () {
    for (final (reply, message) in [
      (
        problem('otp_expired', 422),
        'Ce code a expiré. Demandez-en un nouveau.',
      ),
      (
        problem('otp_attempts_exceeded', 422),
        "Trop d'essais. Demandez un nouveau code.",
      ),
      (
        problem('account_disabled', 403),
        'Ce compte est désactivé. Contactez votre clinique.',
      ),
      (
        problem('otp_rate_limited', 429),
        'Trop de demandes de code. Réessayez dans quelques minutes.',
      ),
    ]) {
      testWidgets(message, (tester) async {
        final backend = FakePortalBackend()..on('POST', _verify, reply);
        final (_, exits, _) = await _pump(tester, backend: backend);

        await _type(tester, '123456');

        expect(_otpError(tester), message);
        expect(exits.taken, isEmpty);
      });
    }

    testWidgets('network', (tester) async {
      await _pump(tester);

      await _type(tester, '123456');

      expect(
        _otpError(tester),
        'Vérifiez votre connexion Internet, puis réessayez.',
      );
    });
  });

  group('the resend', () {
    Future<void> countdownOver(WidgetTester tester, FixedClock clock) async {
      clock.instant = DateTime.utc(2026, 11, 3, 10, 23, 10);
      await tester.pump(const Duration(seconds: 1));
    }

    PortalReply resent() => PortalReply.json(
      jsonEncode({
        'challengeId': _challenge,
        'expiresAt': '2026-11-03T10:33:10+00:00',
        'resendAvailableAt': '2026-11-03T10:23:40+00:00',
      }),
      status: 202,
    );

    testWidgets('the countdown ticks, then both resends and the footnote', (
      tester,
    ) async {
      final clock = FixedClock(testNow);
      await _pump(tester, clock: clock);

      clock.instant = testNow.add(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Renvoyer le SMS dans 0:24'), findsOneWidget);

      await countdownOver(tester, clock);

      expect(find.text('Renvoyer le SMS'), findsOneWidget);
      final buttons = tester.widgetList<KivetoTextButton>(
        find.byType(KivetoTextButton),
      );
      expect(buttons.every((b) => b.onPressed != null), isTrue);
      expect(
        find.text(
          "Vous n'avez pas reçu de code ? Réessayez dans quelques minutes.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('by SMS: a new challenge, a new countdown, a confirmation', (
      tester,
    ) async {
      final clock = FixedClock(testNow);
      final backend = FakePortalBackend()..on('POST', _resend, resent());
      final (container, _, _) = await _pump(
        tester,
        backend: backend,
        clock: clock,
      );
      await countdownOver(tester, clock);

      await tester.tap(find.text('Renvoyer le SMS'));
      await tester.pumpAndSettle();

      expect(jsonDecode(utf8.decode(backend.requestsTo(_resend).single.body)), {
        'channel': 'sms',
      });
      expect(find.text('Nouveau code envoyé par SMS.'), findsOneWidget);
      expect(find.text('Renvoyer le SMS dans 0:30'), findsOneWidget);
      expect(
        container.read(signInFlowProvider)!.challenge.resendAvailableAt,
        DateTime.utc(2026, 11, 3, 10, 23, 40),
      );
    });

    testWidgets('by email: the conditional confirmation', (tester) async {
      final clock = FixedClock(testNow);
      final backend = FakePortalBackend()..on('POST', _resend, resent());
      await _pump(tester, backend: backend, clock: clock);
      await countdownOver(tester, clock);

      await tester.tap(find.text('Recevoir le code par email'));
      await tester.pumpAndSettle();

      expect(jsonDecode(utf8.decode(backend.requestsTo(_resend).single.body)), {
        'channel': 'email',
      });
      expect(
        find.text(
          'Si un email vérifié est associé à votre compte, le code vous y a '
          'été envoyé.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a request no longer valid (capture): the message and '
        '"Recommencer"', (tester) async {
      final clock = FixedClock(testNow);
      final backend = FakePortalBackend()
        ..on(
          'POST',
          _resend,
          PortalReply.fixture('auth.otp.resend.post.404.json', status: 404),
        );
      final (_, exits, _) = await _pump(tester, backend: backend, clock: clock);
      await countdownOver(tester, clock);

      await tester.tap(find.text('Renvoyer le SMS'));
      await tester.pumpAndSettle();

      expect(
        find.text("Cette demande de code n'est plus valable. Recommencez."),
        findsOneWidget,
      );
      await tester.tap(find.text('Recommencer'));
      expect(exits.taken, ['restart']);
    });

    testWidgets('a quota: the minutes', (tester) async {
      final clock = FixedClock(testNow);
      final backend = FakePortalBackend()
        ..on(
          'POST',
          _resend,
          PortalReply.fixture(
            'auth.otp.request.post.429.json',
            status: 429,
            headers: {
              'Retry-After': ['120'],
            },
          ),
        );
      await _pump(tester, backend: backend, clock: clock);
      await countdownOver(tester, clock);

      await tester.tap(find.text('Renvoyer le SMS'));
      await tester.pumpAndSettle();

      expect(
        find.text('Trop de demandes de code. Réessayez dans 2 min.'),
        findsOneWidget,
      );
      expect(find.text('Recommencer'), findsNothing);
    });
  });
}
