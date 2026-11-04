// The e-mail change sheet on the fake backend and the captures: the three
// steps (the address, the SMS code on its 6th digit, the code sent to the
// address on its 6th digit), the success; the titles by the account's
// e-mail; the refusals on their field (a wrong code, a refused address back
// on step 1, email_taken, a quota), « Modifier l'adresse », the resend
// after the countdown, a sheet closed before the end.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _otp = '$api/me/email-change/otp';
const _change = '$api/me/email-change';
const _verify = '$api/me/email-change/verify';

/// The challenges of the captures.
const _smsChallenge = '01a1a363-dc7d-7157-9dfb-7ad4ffa5945e';
const _emailChallenge = '01a1a364-15fd-71ad-9a43-0146dbcad996';
const _resend = '$api/auth/otp/$_smsChallenge/resend';
const _phone = '+33 6 •• •• •• 78';

/// [_phone] as the sentences show it: on one line.
final String _shownPhone = _phone.replaceAll(' ', '\u00a0');

/// 30 s before the `resendAvailableAt` of `me.email-change.otp.post.202.json`.
final _beforeResend = DateTime.utc(2026, 11, 3, 21, 49, 53);

Map<String, Object?> _body(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

/// A page with « open », which shows the sheet; [events] records
/// `verified` (its `onVerified`) and `closed` (the sheet gone).
class _Host extends StatelessWidget {
  const new({required this.events, this.email, this.verified = false});

  final List<String> events;
  final String? email;
  final bool verified;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            await showEmailChangeSheet(
              context,
              currentEmail: email,
              verified: verified,
              maskedPhone: _phone,
              onVerified: () => events.add('verified'),
            );
            events.add('closed');
          },
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
    PortalReply.fixture('me.email-change.otp.post.202.json', status: 202),
  )
  ..on(
    'POST',
    _change,
    PortalReply.fixture('me.email-change.post.202.json', status: 202),
  )
  ..on(
    'POST',
    _verify,
    PortalReply.fixture('me.email-change.verify.post.200.json'),
  );

KivetoButton _button(WidgetTester tester, String label) =>
    tester.widget<KivetoButton>(find.widgetWithText(KivetoButton, label));

String? _codeError(WidgetTester tester) =>
    tester.widget<KivetoOtpField>(find.byType(KivetoOtpField)).errorText;

void main() {
  late List<String> events;

  setUp(() => events = []);

  Future<void> open(
    WidgetTester tester,
    FakePortalBackend backend, {
    String? email,
    bool verified = false,
    FixedClock? clock,
  }) async {
    await pumpPage(
      tester,
      _Host(events: events, email: email, verified: verified),
      session: await memorySession(pair('A')),
      backend: backend,
      clock: clock ?? FixedClock(_beforeResend),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  /// Step 1 → 2 with [email].
  Future<void> requestCode(WidgetTester tester, String email) async {
    await type(tester, email);
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
  }

  testWidgets('no e-mail yet: the address, the SMS code, the code sent to the '
      'address, verified at once (onVerified), then closed', (tester) async {
    final backend = _backend();
    await open(tester, backend);

    expect(find.text('Ajouter une adresse e-mail'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(
      find.text('Pour confirmer, un code va être envoyé au $_shownPhone.'),
      findsOneWidget,
    );
    expect(_button(tester, 'Recevoir un code').onPressed, isNull);

    await type(tester, '  ');
    expect(_button(tester, 'Recevoir un code').onPressed, isNull);
    await requestCode(tester, ' zoe.essai@example.com ');

    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
    expect(find.text('Code de confirmation'), findsOneWidget);
    expect(find.text('Valable 10 minutes.'), findsOneWidget);
    expect(find.text('Renvoyer le code dans 0:30'), findsOneWidget);
    expect(_button(tester, 'Continuer').onPressed, isNull);

    await type(tester, '123456');

    expect(_body(backend.requestsTo(_change).single), {
      'challengeId': _smsChallenge,
      'code': '123456',
      'email': 'zoe.essai@example.com',
    });
    expect(
      find.text('Saisissez le code envoyé à zoe.essai@example.com.'),
      findsOneWidget,
    );
    expect(_button(tester, "Vérifier l'adresse").onPressed, isNull);

    await type(tester, '654321');

    expect(_body(backend.requestsTo(_verify).single), {
      'challengeId': _emailChallenge,
      'code': '654321',
    });
    expect(find.text('Adresse e-mail vérifiée'), findsOneWidget);
    expect(
      find.text(
        'zoe.essai@example.com est vérifiée\u00a0: vous pourrez y recevoir '
        'vos codes de connexion.',
      ),
      findsOneWidget,
    );
    expect(events, ['verified']);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail vérifiée'), findsNothing);
    expect(events, ['verified', 'closed']);
  });

  testWidgets('while a code is checked: its button loading, one request '
      'only', (tester) async {
    final backend = _backend();
    await open(tester, backend);
    await requestCode(tester, 'zoe.essai@example.com');

    // The 6th digit sent the code: the button waits for the answer.
    final hold = Completer<PortalReply>();
    backend.onRequest('POST', _change, (_) => hold.future);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(_button(tester, 'Continuer').loading, isTrue);
    hold.complete(
      PortalReply.fixture('me.email-change.post.202.json', status: 202),
    );
    await tester.pumpAndSettle();
    expect(backend.requestsTo(_change), hasLength(1));

    final verify = Completer<PortalReply>();
    backend.onRequest('POST', _verify, (_) => verify.future);
    await tester.enterText(find.byType(TextField), '654321');
    await tester.pump();
    expect(_button(tester, "Vérifier l'adresse").loading, isTrue);
    verify.complete(
      PortalReply.fixture('me.email-change.verify.post.200.json'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adresse e-mail vérifiée'), findsOneWidget);
  });

  testWidgets('an unverified e-mail: « Vérifier mon adresse e-mail », the '
      "address prefilled; a verified one: « Changer d'adresse e-mail », "
      'empty', (tester) async {
    await open(tester, _backend(), email: 'julien@example.com');

    expect(find.text('Vérifier mon adresse e-mail'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'julien@example.com',
    );
    expect(_button(tester, 'Recevoir un code').onPressed, isNotNull);
  });

  testWidgets("a verified e-mail: « Changer d'adresse e-mail », empty", (
    tester,
  ) async {
    await open(tester, _backend(), email: 'julien@example.com', verified: true);

    expect(find.text("Changer d'adresse e-mail"), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('a wrong SMS code (capture): on the boxes, cleared; a refused '
      'address (capture): back to the address, its error, the address '
      'kept', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _change,
        PortalReply.fixture(
          'me.email-change.otp-invalid.post.422.json',
          status: 422,
        ),
      );
    await open(tester, backend);
    await requestCode(tester, 'zoe@');

    await type(tester, '000000');

    expect(_codeError(tester), 'Code incorrect. Vérifiez-le, puis réessayez.');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    expect(_codeError(tester), isNull);

    backend.on(
      'POST',
      _change,
      PortalReply.fixture(
        'me.email-change.validation.post.422.json',
        status: 422,
      ),
    );
    await type(tester, '123456');

    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(
      tester.widget<KivetoTextField>(find.byType(KivetoTextField)).errorText,
      "Vérifiez l'adresse e-mail saisie.",
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'zoe@',
    );

    // Typing clears the error; the SMS code was not spent: « Recevoir un
    // code » goes back to it without a new SMS, the same code goes on.
    await type(tester, 'zoe@example.com');
    expect(
      tester.widget<KivetoTextField>(find.byType(KivetoTextField)).errorText,
      isNull,
    );
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo(_otp), hasLength(1));
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
    expect(_codeError(tester), isNull);

    backend.on(
      'POST',
      _change,
      PortalReply.fixture('me.email-change.post.202.json', status: 202),
    );
    await type(tester, '123456');

    expect(_body(backend.requestsTo(_change).last), {
      'challengeId': _smsChallenge,
      'code': '123456',
      'email': 'zoe@example.com',
    });
    expect(
      find.text('Saisissez le code envoyé à zoe@example.com.'),
      findsOneWidget,
    );
  });

  testWidgets("an expired SMS code: « Modifier l'adresse » drops it, "
      '« Recevoir un code » asks for a new one', (tester) async {
    final backend = _backend()
      ..on('POST', _change, problem('otp_expired', 422));
    await open(tester, backend);
    await requestCode(tester, 'zoe.essai@example.com');

    await type(tester, '123456');
    expect(_codeError(tester), 'Ce code a expiré. Demandez-en un nouveau.');

    await tester.tap(find.text("Modifier l'adresse"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_otp), hasLength(2));
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
  });

  testWidgets('a spent SMS code: no resend, « Continuer » disabled with 6 '
      'digits; « Recevoir un nouveau code »: a refusal on the boxes, then '
      'one new code on step 2, its challenge used', (tester) async {
    final backend = _backend()
      ..on('POST', _change, problem('otp_expired', 422));
    await open(tester, backend);
    await requestCode(tester, 'zoe.essai@example.com');
    await type(tester, '123456');
    expect(_codeError(tester), 'Ce code a expiré. Demandez-en un nouveau.');

    expect(find.textContaining('Renvoyer le code'), findsNothing);
    await type(tester, '654321');
    expect(_button(tester, 'Continuer').onPressed, isNull);
    expect(backend.requestsTo(_change), hasLength(1));

    backend.on('POST', _otp, problem('otp_rate_limited', 429));
    await tester.tap(find.text('Recevoir un nouveau code'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_otp), hasLength(2));
    expect(
      _codeError(tester),
      'Trop de demandes de code. Réessayez dans quelques minutes.',
    );
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
    expect(find.text('Recevoir un nouveau code'), findsOneWidget);

    backend
      ..on(
        'POST',
        _otp,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      )
      ..on(
        'POST',
        _change,
        PortalReply.fixture('me.email-change.post.202.json', status: 202),
      );
    await tester.tap(find.text('Recevoir un nouveau code'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_otp), hasLength(3));
    expect(find.text('Recevoir un nouveau code'), findsNothing);
    expect(_codeError(tester), isNull);
    expect(find.text('Renvoyer le code'), findsOneWidget);
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );

    await type(tester, '111222');

    expect(_body(backend.requestsTo(_change).last), {
      'challengeId': '01a1a0ee-b560-7aca-b883-0473f9c33042',
      'code': '111222',
      'email': 'zoe.essai@example.com',
    });
    expect(
      find.text('Saisissez le code envoyé à zoe.essai@example.com.'),
      findsOneWidget,
    );
  });

  testWidgets('a kept SMS code past its expiresAt: « Recevoir un code » asks '
      'for a new one', (tester) async {
    final clock = FixedClock(_beforeResend);
    final backend = _backend()
      ..on(
        'POST',
        _change,
        PortalReply.fixture(
          'me.email-change.validation.post.422.json',
          status: 422,
        ),
      );
    await open(tester, backend, clock: clock);
    await requestCode(tester, 'zoe@');
    await type(tester, '123456');
    // Back on the address, the challenge kept.
    expect(find.text('Adresse e-mail'), findsOneWidget);

    // The `expiresAt` of `me.email-change.otp.post.202.json` passed.
    clock.instant = DateTime.utc(2026, 11, 3, 21, 59, 53);
    await requestCode(tester, 'zoe@example.com');

    expect(backend.requestsTo(_otp), hasLength(2));
    expect(
      find.text('Saisissez le code envoyé au $_shownPhone.'),
      findsOneWidget,
    );
  });

  testWidgets('the code request refused: its message under the text; the '
      'address field still there', (tester) async {
    final backend = _backend()
      ..on('POST', _otp, problem('otp_rate_limited', 429));
    await open(tester, backend);

    await requestCode(tester, 'zoe@example.com');

    expect(
      find.text('Trop de demandes de code. Réessayez dans quelques minutes.'),
      findsOneWidget,
    );
    expect(find.text('Adresse e-mail'), findsOneWidget);

    await type(tester, 'zoe@example.fr');
    expect(
      find.text('Trop de demandes de code. Réessayez dans quelques minutes.'),
      findsNothing,
    );
  });

  testWidgets('email_taken on the verification: its message on the boxes, '
      "« Modifier l'adresse » back to the address", (tester) async {
    final backend = _backend()
      ..on('POST', _verify, problem('email_taken', 422));
    await open(tester, backend);
    await requestCode(tester, 'zoe.essai@example.com');
    await type(tester, '123456');

    await type(tester, '654321');

    expect(
      _codeError(tester),
      'Cette adresse e-mail est déjà utilisée par un autre compte.',
    );
    expect(find.text('Adresse e-mail vérifiée'), findsNothing);

    await tester.tap(find.text("Modifier l'adresse"));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'zoe.essai@example.com',
    );

    // The SMS code was spent on step 2: a new one is asked for.
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo(_otp), hasLength(2));
  });

  testWidgets('a wrong e-mail code (capture): on the boxes', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        _verify,
        PortalReply.fixture(
          'me.email-change.verify.otp-invalid.post.422.json',
          status: 422,
        ),
      );
    await open(tester, backend);
    await requestCode(tester, 'zoe.essai@example.com');
    await type(tester, '123456');

    await type(tester, '000000');

    expect(_codeError(tester), 'Code incorrect. Vérifiez-le, puis réessayez.');
  });

  testWidgets("« Modifier l'adresse » on the SMS code step: the code kept, "
      '« Recevoir un code » back to it without a new SMS', (tester) async {
    final backend = _backend();
    await open(tester, backend);
    await requestCode(tester, 'zoe.essai@example.com');

    await tester.tap(find.text("Modifier l'adresse"));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail'), findsOneWidget);

    await requestCode(tester, 'zoe@example.fr');

    expect(backend.requestsTo(_otp), hasLength(1));
    await type(tester, '123456');
    expect(_body(backend.requestsTo(_change).single), {
      'challengeId': _smsChallenge,
      'code': '123456',
      'email': 'zoe@example.fr',
    });
  });

  testWidgets('the countdown over: « Renvoyer le code » by SMS, the new '
      'challenge; a refused resend on the boxes', (tester) async {
    final clock = FixedClock(_beforeResend.add(const Duration(seconds: 30)));
    final backend = _backend()
      ..on(
        'POST',
        _resend,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      );
    await open(tester, backend, clock: clock);
    await requestCode(tester, 'zoe.essai@example.com');

    final resend = tester.widget<KivetoTextButton>(
      find.widgetWithText(KivetoTextButton, 'Renvoyer le code'),
    );
    expect(resend.onPressed, isNotNull);

    await tester.tap(find.text('Renvoyer le code'));
    await tester.pumpAndSettle();

    expect(_body(backend.requestsTo(_resend).single), {'channel': 'sms'});
    // The new challenge (its countdown runs again from the capture's).
    await type(tester, '123456');
    expect(
      _body(backend.requestsTo(_change).single)['challengeId'],
      '01a1a0ee-b560-7aca-b883-0473f9c33042',
    );
  });

  testWidgets('a refused resend (capture): on the boxes; the challenge gone, '
      "« Modifier l'adresse » then asks for a new code", (tester) async {
    final clock = FixedClock(_beforeResend.add(const Duration(minutes: 1)));
    final backend = _backend()
      ..on(
        'POST',
        _resend,
        PortalReply.fixture('auth.otp.resend.post.404.json', status: 404),
      );
    await open(tester, backend, clock: clock);
    await requestCode(tester, 'zoe.essai@example.com');

    await tester.tap(find.text('Renvoyer le code'));
    await tester.pumpAndSettle();

    expect(
      _codeError(tester),
      "Cette demande de code n'est plus valable. Recommencez.",
    );

    await tester.tap(find.text("Modifier l'adresse"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo(_otp), hasLength(2));
  });

  testWidgets('closed before the end: never verified', (tester) async {
    await open(tester, _backend());

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(events, ['closed']);
  });
}
