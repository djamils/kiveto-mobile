// The deletion sheet on the fake backend and the captures: what the
// deletion does, the code by SMS, the 6 digits never sent without the tap,
// the 202 closing the session with its SnackBar; a wrong code on the boxes
// (the session kept), a quota, the resend, « Garder mon compte ».

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _otp = '$api/me/deletion-request/otp';
const _deletion = '$api/me/deletion-request';
const _challenge = '01a1a364-f91f-7dd0-8637-861f9ac73106';
const _resend = '$api/auth/otp/$_challenge/resend';
const _phone = '+33 6 •• •• •• 40';

/// [_phone] as the sentences show it: on one line.
final String _shownPhone = _phone.replaceAll(' ', '\u00a0');

/// 30 s before the `resendAvailableAt` of
/// `me.deletion-request.otp.post.202.json`.
final _beforeResend = DateTime.utc(2026, 11, 3, 21, 51, 6);

class _Host extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              unawaited(showAccountDeletionSheet(context, maskedPhone: _phone)),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

FakePortalBackend _backend() => FakePortalBackend()
  ..on(
    'POST',
    _otp,
    PortalReply.fixture('me.deletion-request.otp.post.202.json', status: 202),
  )
  ..on('POST', _deletion, PortalReply.empty(202));

KivetoButton _button(WidgetTester tester, String label) =>
    tester.widget<KivetoButton>(find.widgetWithText(KivetoButton, label));

void main() {
  late SessionManager session;

  Future<void> open(
    WidgetTester tester,
    FakePortalBackend backend, {
    FixedClock? clock,
  }) async {
    session = await memorySession(pair('A'));
    await pumpPage(
      tester,
      const _Host(),
      session: session,
      backend: backend,
      clock: clock ?? FixedClock(_beforeResend),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> requestCode(WidgetTester tester) async {
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
  }

  testWidgets('what the deletion does, then the code; the 6th digit only '
      'enables « Supprimer mon compte »; its tap: 202, the session closed, '
      'the SnackBar', (tester) async {
    final backend = _backend();
    await open(tester, backend);

    expect(find.text('Supprimer mon compte\u00a0?'), findsOneWidget);
    const disabled =
        'Votre compte est désactivé dès la confirmation\u00a0: vous ne '
        'pourrez plus vous connecter.';
    const clinics =
        'Vos cliniques conservent votre dossier, vos factures et vos '
        'ordonnances.';
    for (final line in [
      disabled,
      'Vos informations de compte et vos exports sont effacés.',
      clinics,
    ]) {
      expect(find.textContaining(line), findsOneWidget);
    }
    expect(
      find.text('Un code de confirmation va être envoyé au $_shownPhone.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(KivetoButton, 'Garder mon compte'), findsOne);

    await requestCode(tester);

    expect(backend.requestsTo(_otp), hasLength(1));
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
    expect(find.text('Code de confirmation'), findsOneWidget);
    expect(find.text('Renvoyer le code dans 0:30'), findsOneWidget);
    expect(_button(tester, 'Supprimer mon compte').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_deletion), isEmpty);
    expect(_button(tester, 'Supprimer mon compte').onPressed, isNotNull);

    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();

    expect(jsonDecode(utf8.decode(backend.requestsTo(_deletion).single.body)), {
      'challengeId': _challenge,
      'code': '123456',
    });
    expect(session.status, SessionStatus.signedOut);
    expect(backend.requestsTo('$api/auth/logout'), isEmpty);
    expect(find.text('Supprimer mon compte\u00a0?'), findsNothing);
    expect(
      find.text(
        'Votre demande de suppression est enregistrée\u00a0: votre compte '
        'est désactivé.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('while the deletion is sent: loading, « Garder mon compte » '
      'disabled', (tester) async {
    final answer = Completer<PortalReply>();
    final backend = _backend()
      ..onRequest('POST', _deletion, (_) => answer.future);
    await open(tester, backend);
    await requestCode(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pump();

    expect(_button(tester, 'Supprimer mon compte').loading, isTrue);
    expect(_button(tester, 'Garder mon compte').onPressed, isNull);
    answer.complete(PortalReply.empty(202));
    await tester.pumpAndSettle();
    expect(session.status, SessionStatus.signedOut);
  });

  testWidgets('a wrong code (capture): on the boxes, the session kept, a '
      'new try possible', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _deletion,
        PortalReply.fixture(
          'me.deletion-request.otp-invalid.post.422.json',
          status: 422,
        ),
      );
    await open(tester, backend);
    await requestCode(tester);
    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText,
      'Code incorrect. Vérifiez-le, puis réessayez.',
    );
    expect(session.status, SessionStatus.signedIn);
    expect(find.textContaining('Votre demande de suppression'), findsNothing);
    expect(_button(tester, 'Supprimer mon compte').onPressed, isNull);
    // A wrong code leaves the challenge usable: no new code offered.
    expect(find.text('Recevoir un nouveau code'), findsNothing);

    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    expect(
      tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText,
      isNull,
    );
  });

  testWidgets('the code request refused: its message; still on step 1', (
    tester,
  ) async {
    final backend = _backend()
      ..on('POST', _otp, problem('otp_rate_limited', 429));
    await open(tester, backend);

    await requestCode(tester);

    expect(
      find.text('Trop de demandes de code. Réessayez dans quelques minutes.'),
      findsOneWidget,
    );
    expect(find.text('Recevoir un code'), findsOneWidget);
  });

  testWidgets('the countdown over: « Renvoyer le code », the new challenge '
      'used; a refused resend on the boxes', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _resend,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      );
    await open(
      tester,
      backend,
      clock: FixedClock(_beforeResend.add(const Duration(minutes: 1))),
    );
    await requestCode(tester);

    await tester.tap(find.text('Renvoyer le code'));
    await tester.pumpAndSettle();

    expect(
      utf8.decode(backend.requestsTo(_resend).single.body),
      '{"channel":"sms"}',
    );
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();
    expect(
      (jsonDecode(utf8.decode(backend.requestsTo(_deletion).single.body))
          as Map<String, Object?>)['challengeId'],
      '01a1a0ee-b560-7aca-b883-0473f9c33042',
    );
  });

  testWidgets('a refused resend (capture, otp_challenge_not_found): on the '
      'boxes; « Recevoir un nouveau code »: a new challenge, step 2 '
      'again', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _resend,
        PortalReply.fixture('auth.otp.resend.post.404.json', status: 404),
      );
    await open(
      tester,
      backend,
      clock: FixedClock(_beforeResend.add(const Duration(minutes: 1))),
    );
    await requestCode(tester);

    await tester.tap(find.text('Renvoyer le code'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText,
      "Cette demande de code n'est plus valable. Recommencez.",
    );

    await tester.tap(find.text('Recevoir un nouveau code'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_otp), hasLength(2));
    expect(find.text('Recevoir un nouveau code'), findsNothing);
    expect(
      tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText,
      isNull,
    );
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
  });

  testWidgets('an expired code: « Recevoir un nouveau code » (still there '
      'after typing), a new challenge, the deletion on it; a refused new '
      'code on the boxes', (tester) async {
    final backend = _backend()
      ..on('POST', _deletion, problem('otp_expired', 422));
    await open(tester, backend);
    await requestCode(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText,
      'Ce code a expiré. Demandez-en un nouveau.',
    );
    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    expect(find.text('Recevoir un nouveau code'), findsOneWidget);
    // One way on: the resend of the spent challenge is gone.
    expect(find.textContaining('Renvoyer le code'), findsNothing);

    backend.on('POST', _otp, problem('otp_rate_limited', 429));
    await tester.tap(find.text('Recevoir un nouveau code'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText,
      'Trop de demandes de code. Réessayez dans quelques minutes.',
    );
    expect(find.text('Recevoir un nouveau code'), findsOneWidget);

    backend
      ..on(
        'POST',
        _otp,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      )
      ..on('POST', _deletion, PortalReply.empty(202));
    await tester.tap(find.text('Recevoir un nouveau code'));
    await tester.pumpAndSettle();
    expect(find.text('Recevoir un nouveau code'), findsNothing);
    expect(find.textContaining('Renvoyer le code'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '654321');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();

    expect(jsonDecode(utf8.decode(backend.requestsTo(_deletion).last.body)), {
      'challengeId': '01a1a0ee-b560-7aca-b883-0473f9c33042',
      'code': '654321',
    });
    expect(session.status, SessionStatus.signedOut);
  });

  for (final code in ['otp_expired', 'otp_attempts_exceeded']) {
    testWidgets('a spent code ($code): 6 new digits leave « Supprimer mon '
        'compte » disabled; nothing sent', (tester) async {
      final backend = _backend()..on('POST', _deletion, problem(code, 422));
      await open(tester, backend);
      await requestCode(tester);
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(KivetoButton, 'Supprimer mon compte'),
      );
      await tester.pumpAndSettle();
      expect(backend.requestsTo(_deletion), hasLength(1));

      await tester.enterText(find.byType(TextField), '654321');
      await tester.pumpAndSettle();

      expect(_button(tester, 'Supprimer mon compte').onPressed, isNull);
      expect(find.text('Recevoir un nouveau code'), findsOneWidget);
      expect(find.textContaining('Renvoyer le code'), findsNothing);
      await tester.tap(
        find.widgetWithText(KivetoButton, 'Supprimer mon compte'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(backend.requestsTo(_deletion), hasLength(1));
      expect(session.status, SessionStatus.signedIn);
    });
  }

  for (final step in ['before', 'after']) {
    testWidgets('« Garder mon compte » $step the code: closed, nothing '
        'deleted', (tester) async {
      final backend = _backend();
      await open(tester, backend);
      if (step == 'after') await requestCode(tester);

      await tester.tap(find.text('Garder mon compte'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer mon compte\u00a0?'), findsNothing);
      expect(backend.requestsTo(_deletion), isEmpty);
      expect(session.status, SessionStatus.signedIn);
    });
  }
}
