// Screen 7: the layout of the mockup, the number formatted and complete
// for its prefix, the code request and its refusals, the country sheet,
// the invitation link sheet, the phone pad closed by a drag on iOS.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/welcome_page.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/keyboard.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _request = '$api/auth/otp/request';

final class _Exits {
  final codeSent = <BuildContext>[];
  final tokens = <String>[];
  int kitGallery = 0;
}

KivetoButton _cta(WidgetTester tester) => tester.widget<KivetoButton>(
  find.widgetWithText(KivetoButton, 'Recevoir mon code'),
);

Finder get _phoneInput => find.byType(TextField);

Future<(ProviderContainer, _Exits)> _pump(
  WidgetTester tester, {
  FakePortalBackend? backend,
  bool kitGallery = false,
  void Function(ProviderContainer container)? prepare,
}) async {
  final exits = _Exits();
  final container = await pumpPage(
    tester,
    WelcomePage(
      onCodeSent: exits.codeSent.add,
      onInvitationLink: (_, token) => exits.tokens.add(token),
      onKitGallery: kitGallery ? (_) => exits.kitGallery++ : null,
    ),
    backend: backend,
    prepare: prepare,
  );
  return (container, exits);
}

void main() {
  testWidgets('the layout of the mockup; the button waits for a whole '
      'number', (tester) async {
    await _pump(tester);

    expect(find.text('Kiveto'), findsOneWidget);
    expect(
      find.text('La santé de vos animaux, avec votre clinique'),
      findsOneWidget,
    );
    expect(
      find.text('Rendez-vous en ligne, documents, rappels de vaccins.'),
      findsOneWidget,
    );
    expect(find.text('Numéro de mobile'), findsOneWidget);
    expect(find.text('+33'), findsOneWidget);
    expect(find.text('6 12 34 56 78'), findsOneWidget);
    expect(
      find.text('Vous recevrez un code par SMS. Pas de mot de passe.'),
      findsOneWidget,
    );
    expect(
      find.text('Votre clinique vous a envoyé une invitation ?'),
      findsOneWidget,
    );
    expect(find.textContaining('Ouvrez le lien reçu'), findsOneWidget);
    expect(find.text("J'ai un lien d'invitation"), findsOneWidget);
    expect(find.text("Ouvrir le kit d'interface"), findsNothing);
    expect(_cta(tester).onPressed, isNull);

    await tester.enterText(_phoneInput, '61234567');
    await tester.pump();
    expect(find.text('6 12 34 56 7'), findsOneWidget);
    expect(_cta(tester).onPressed, isNull);

    await tester.enterText(_phoneInput, '612345678');
    await tester.pump();
    expect(find.text('6 12 34 56 78'), findsWidgets);
    expect(_cta(tester).onPressed, isNotNull);

    await tester.enterText(_phoneInput, '0612345678');
    await tester.pump();
    expect(find.text('06 12 34 56 78'), findsOneWidget);
    expect(_cta(tester).onPressed, isNotNull);
  });

  testWidgets('the code is requested in E.164; the flow holds the number and '
      'the challenge', (tester) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        _request,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      );
    final (container, exits) = await _pump(tester, backend: backend);

    await tester.enterText(_phoneInput, '06 12 34 56 78');
    await tester.pump();
    await tester.tap(find.text('Recevoir mon code'));
    await tester.pumpAndSettle();

    expect(exits.codeSent, hasLength(1));
    expect(
      utf8.decode(backend.requestsTo(_request).single.body),
      '{"phone":"+33612345678"}',
    );
    final flow = container.read(signInFlowProvider)!;
    expect(flow.phone.e164, '+33612345678');
    expect(flow.challenge.id, '01a1a0ee-b560-7aca-b883-0473f9c33042');
  });

  testWidgets('a number pasted in international form: the prefix dropped, '
      'the right E.164 sent', (tester) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        _request,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      );
    await _pump(tester, backend: backend);

    await tester.enterText(_phoneInput, '0033 6 12 34 56 78');
    await tester.pump();
    expect(find.text('6 12 34 56 78'), findsWidgets);
    await tester.enterText(_phoneInput, '+33 6 12 34 56 78');
    await tester.pump();
    expect(find.text('6 12 34 56 78'), findsWidgets);
    await tester.tap(find.text('Recevoir mon code'));
    await tester.pumpAndSettle();

    expect(
      utf8.decode(backend.requestsTo(_request).single.body),
      '{"phone":"+33612345678"}',
    );
  });

  group('the refusals under the field; the button again; an edit clears '
      'them', () {
    for (final (name, reply, message) in [
      (
        'phone_not_supported',
        PortalReply.fixture(
          'auth.otp.request.phone-not-supported.post.422.json',
          status: 422,
        ),
        "Ce numéro de mobile n'est pas encore pris en charge par Kiveto.",
      ),
      (
        'validation_failed',
        PortalReply.fixture('auth.otp.request.post.422.json', status: 422),
        'Vérifiez votre numéro de mobile.',
      ),
      (
        'otp_rate_limited',
        PortalReply.fixture(
          'auth.otp.request.post.429.json',
          status: 429,
          headers: {
            'Retry-After': ['3599'],
          },
        ),
        'Trop de demandes de code. Réessayez dans 60 min.',
      ),
      (
        'otp_rate_limited without delay',
        PortalReply.fixture('auth.otp.request.post.429.json', status: 429),
        'Trop de demandes de code. Réessayez dans quelques minutes.',
      ),
    ]) {
      testWidgets(name, (tester) async {
        final backend = FakePortalBackend()..on('POST', _request, reply);
        final (_, exits) = await _pump(tester, backend: backend);

        await tester.enterText(_phoneInput, '612345678');
        await tester.pump();
        await tester.tap(find.text('Recevoir mon code'));
        await tester.pumpAndSettle();

        expect(find.text(message), findsOneWidget);
        expect(exits.codeSent, isEmpty);
        expect(_cta(tester).onPressed, isNotNull);

        await tester.enterText(_phoneInput, '612345679');
        await tester.pump();
        expect(find.text(message), findsNothing);
      });
    }

    testWidgets('network', (tester) async {
      await _pump(tester);

      await tester.enterText(_phoneInput, '612345678');
      await tester.pump();
      await tester.tap(find.text('Recevoir mon code'));
      await tester.pumpAndSettle();

      expect(
        find.text('Vérifiez votre connexion Internet, puis réessayez.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('the country sheet lists the prefixes; the one picked is '
      'shown, sets the length and the E.164 sent', (tester) async {
    final backend = FakePortalBackend()
      ..on(
        'POST',
        _request,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      );
    await _pump(tester, backend: backend);
    await tester.enterText(_phoneInput, '612345678');
    await tester.pump();

    await tester.tap(find.text('+33'));
    await tester.pumpAndSettle();

    expect(find.text('Indicatif du numéro'), findsOneWidget);
    for (final label in [
      '+33 France',
      '+262 La Réunion · Mayotte',
      '+590 Guadeloupe',
      '+594 Guyane',
      '+596 Martinique',
      '+508 Saint-Pierre-et-Miquelon',
      '+681 Wallis-et-Futuna',
      '+687 Nouvelle-Calédonie',
      '+689 Polynésie française',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await tester.tap(find.text('+687 Nouvelle-Calédonie'));
    await tester.pumpAndSettle();

    expect(find.text('+687'), findsOneWidget);
    // Pairs on another plan; at least 6 digits.
    expect(find.text('61 23 45 67 8'), findsOneWidget);
    await tester.enterText(_phoneInput, '75123');
    await tester.pump();
    expect(_cta(tester).onPressed, isNull);
    await tester.enterText(_phoneInput, '751234');
    await tester.pump();
    expect(_cta(tester).onPressed, isNotNull);

    await tester.tap(find.text('Recevoir mon code'));
    await tester.pumpAndSettle();
    expect(
      utf8.decode(backend.requestsTo(_request).single.body),
      '{"phone":"+687751234"}',
    );
  });

  testWidgets('the country sheet dismissed: nothing changes', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('+33'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('+33'), findsOneWidget);
  });

  testWidgets('the invitation link sheet: explains, refuses a text that is '
      'not a link, opens a pasted link', (tester) async {
    final (_, exits) = await _pump(tester);

    await tester.tapOnText(
      find.textRange.ofSubstring("J'ai un lien d'invitation"),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining("ouvre directement l'application"),
      findsOneWidget,
    );
    final field = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, 'bonjour');
    await tester.tap(find.text("Ouvrir l'invitation"));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("Ce lien n'est pas un lien d'invitation"),
      findsOneWidget,
    );

    await tester.enterText(
      field,
      ' https://portal.kiveto.local/invitation#t=ROUSSEL_TOKEN ',
    );
    await tester.pump();
    expect(
      find.textContaining("Ce lien n'est pas un lien d'invitation"),
      findsNothing,
    );
    await tester.tap(find.text("Ouvrir l'invitation"));
    await tester.pumpAndSettle();

    expect(exits.tokens, ['ROUSSEL_TOKEN']);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('the invitation link sheet dismissed: no exit', (tester) async {
    final (_, exits) = await _pump(tester);

    await tester.tapOnText(
      find.textRange.ofSubstring("J'ai un lien d'invitation"),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(exits.tokens, isEmpty);
  });

  testWidgets('back from the code page: the number and its prefix are '
      'kept', (tester) async {
    await _pump(
      tester,
      prepare: (container) => container
          .read(signInFlowProvider.notifier)
          .start(
            PhoneNumber.fromNational(
              countryCode: '+262',
              national: '692123456',
            )!,
            OtpChallenge(
              id: 'c1',
              expiresAt: testNow,
              resendAvailableAt: testNow,
            ),
          ),
    );

    expect(find.text('+262'), findsOneWidget);
    expect(find.text('6 92 12 34 56'), findsOneWidget);
    expect(_cta(tester).onPressed, isNotNull);
  });

  testWidgets(
    'iOS: the phone pad has no return key, a drag on the page closes it',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await _pump(tester);

      await expectDragClosesKeyboard(
        tester,
        field: _phoneInput,
        from: find.text('La santé de vos animaux, avec votre clinique'),
      );
    },
  );

  testWidgets('debug builds: the kit gallery link', (tester) async {
    final (_, exits) = await _pump(tester, kitGallery: true);

    final link = find.text("Ouvrir le kit d'interface");
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);

    expect(exits.kitGallery, 1);
  });
}
