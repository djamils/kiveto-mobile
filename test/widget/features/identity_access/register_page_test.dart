// Screen 9: the verified number, the names, the optional email, the terms;
// the registration and its refusals.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/register_page.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/terms_consent.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _register = '$api/auth/register';
const _terms = '$api/legal/terms/current';

/// The current terms after a change.
const _newTerms =
    '{"version":"2026-11-01","url":"http://portal.kiveto.local/cgu"}';

final _grant = RegistrationGrant(
  token: 'reg',
  expiresAt: DateTime.utc(2026, 11, 3, 10, 38),
);

FakePortalBackend _backend([PortalReply? register]) {
  final backend = FakePortalBackend()
    ..on(
      'GET',
      _terms,
      PortalReply.fixture('legal.terms.current.get.200.json'),
    );
  if (register != null) backend.on('POST', _register, register);
  return backend;
}

Future<(ProviderContainer, List<String>, SessionManager)> _pump(
  WidgetTester tester, {
  FakePortalBackend? backend,
  bool flow = true,
  List<Uri>? opened,
  bool opens = true,
}) async {
  final exits = <String>[];
  final session = await memorySession();
  final container = await pumpPage(
    tester,
    RegisterPage(onRestart: (_) => exits.add('restart')),
    session: session,
    backend: backend ?? _backend(),
    overrides: [
      linkLauncherProvider.overrideWithValue((url) async {
        opened?.add(url);
        return opens;
      }),
    ],
    prepare: flow
        ? (container) => container
              .read(registrationFlowProvider.notifier)
              .start(
                _grant,
                PhoneNumber.fromNational(
                  countryCode: '+33',
                  national: '612345678',
                )!,
              )
        : null,
  );
  return (container, exits, session);
}

Finder _field(String label) => find.widgetWithText(KivetoTextField, label);

Future<void> _fill(
  WidgetTester tester, {
  String first = 'Sarah',
  String last = 'Bernard',
  String email = '',
}) async {
  await tester.enterText(
    find.descendant(of: _field('Prénom'), matching: find.byType(TextField)),
    first,
  );
  await tester.enterText(
    find.descendant(of: _field('Nom'), matching: find.byType(TextField)),
    last,
  );
  await tester.enterText(
    find.descendant(of: _field('Email'), matching: find.byType(TextField)),
    email,
  );
  await tester.pump();
}

Future<void> _accept(WidgetTester tester) async {
  await tester.tap(find.byType(KivetoCheckbox));
  await tester.pump();
}

KivetoButton _cta(WidgetTester tester) => tester.widget<KivetoButton>(
  find.widgetWithText(KivetoButton, 'Créer mon compte'),
);

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.text('Créer mon compte'));
  await pumpBriefly(tester);
}

String? _errorOf(WidgetTester tester, String label) =>
    tester.widget<KivetoTextField>(_field(label)).errorText;

void main() {
  testWidgets('without its flow: back to the start', (tester) async {
    final (_, exits, _) = await _pump(tester, flow: false);

    expect(exits, ['restart']);
  });

  testWidgets('the layout; the button waits for both names and the terms '
      '(the email is optional)', (tester) async {
    await _pump(tester);

    expect(find.text('06 12 34 56 78 vérifié'), findsOneWidget);
    expect(find.text('Créez votre compte'), findsOneWidget);
    expect(find.text('Prénom'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(
      find.text('Pour recevoir vos documents et confirmations.'),
      findsOneWidget,
    );
    expect(
      find.text(
        "J'accepte les conditions d'utilisation et la politique de "
        'confidentialité.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Vos animaux seront ajoutés'), findsOneWidget);
    expect(_cta(tester).onPressed, isNull);

    await _fill(tester, last: ' ');
    await _accept(tester);
    expect(_cta(tester).onPressed, isNull);

    await _fill(tester);
    expect(_cta(tester).onPressed, isNotNull);

    await _accept(tester);
    expect(_cta(tester).onPressed, isNull);
  });

  testWidgets('the account is created: names trimmed, a blank email sent '
      'null, the terms version; the session opens', (tester) async {
    final backend = _backend(
      PortalReply.fixture('auth.register.post.201.json', status: 201),
    );
    final (container, exits, session) = await _pump(tester, backend: backend);

    await _fill(tester, first: ' Test ', last: 'Capture', email: '  ');
    await _accept(tester);
    await _submit(tester);

    expect(jsonDecode(utf8.decode(backend.requestsTo(_register).single.body)), {
      'registrationToken': 'reg',
      'firstName': 'Test',
      'lastName': 'Capture',
      'email': null,
      'termsVersion': '2026-10-29',
    });
    expect(session.status, SessionStatus.signedIn);
    expect(container.read(registrationFlowProvider), isNull);
    expect(exits, isEmpty);
  });

  testWidgets('an email typed is sent', (tester) async {
    final backend = _backend(
      PortalReply.fixture('auth.register.post.201.json', status: 201),
    );
    await _pump(tester, backend: backend);

    await _fill(tester, email: 'sarah@example.com');
    await _accept(tester);
    await _submit(tester);

    expect(
      (jsonDecode(utf8.decode(backend.requestsTo(_register).single.body))
          as Map<String, Object?>)['email'],
      'sarah@example.com',
    );
  });

  testWidgets('validation_failed: the server message under its field, '
      'cleared on edit; another field in the general message', (tester) async {
    final backend = _backend(
      PortalReply.json(
        jsonEncode({
          'type': 'validation_failed',
          'status': 422,
          'violations': [
            {'propertyPath': 'firstName', 'message': 'Prénom trop long.'},
            {'propertyPath': 'email', 'message': 'Email invalide.'},
            {'propertyPath': 'termsVersion', 'message': 'Version absente.'},
          ],
        }),
        status: 422,
      ),
    );
    final (_, _, session) = await _pump(tester, backend: backend);

    await _fill(tester);
    await _accept(tester);
    await _submit(tester);

    expect(_errorOf(tester, 'Prénom'), 'Prénom trop long.');
    expect(_errorOf(tester, 'Email'), 'Email invalide.');
    expect(_errorOf(tester, 'Nom'), isNull);
    expect(
      find.textContaining('Certaines informations ne sont pas valides'),
      findsOneWidget,
    );
    expect(session.status, SessionStatus.signedOut);

    await tester.enterText(
      find.descendant(of: _field('Prénom'), matching: find.byType(TextField)),
      'Sara',
    );
    await tester.pump();
    expect(_errorOf(tester, 'Prénom'), isNull);
    expect(_errorOf(tester, 'Email'), 'Email invalide.');
  });

  testWidgets('validation_failed on the fields only: no general message', (
    tester,
  ) async {
    final backend = _backend(
      PortalReply.json(
        jsonEncode({
          'type': 'validation_failed',
          'status': 422,
          'violations': [
            {'propertyPath': 'lastName', 'message': 'Nom trop long.'},
            // Two violations of one field: still no general message.
            {'propertyPath': 'lastName', 'message': 'Nom invalide.'},
          ],
        }),
        status: 422,
      ),
    );
    await _pump(tester, backend: backend);

    await _fill(tester);
    await _accept(tester);
    await _submit(tester);

    expect(_errorOf(tester, 'Nom'), 'Nom invalide.');
    expect(
      find.textContaining('Certaines informations ne sont pas valides'),
      findsNothing,
    );
  });

  for (final (reply, message) in [
    (
      problem('onboarding_invalid', 401),
      'Votre vérification a expiré. Reconnectez-vous avec votre numéro.',
    ),
    (
      problem('account_exists', 409),
      'Un compte existe déjà pour ce numéro. Connectez-vous avec votre numéro.',
    ),
  ]) {
    testWidgets('$message + "Recommencer"', (tester) async {
      final (container, exits, _) = await _pump(
        tester,
        backend: _backend(reply),
      );

      await _fill(tester);
      await _accept(tester);
      await _submit(tester);

      expect(find.text(message), findsOneWidget);
      await tester.tap(find.text('Recommencer'));
      expect(exits, ['restart']);
      expect(container.read(registrationFlowProvider), isNull);
    });
  }

  testWidgets('terms_outdated (capture): the terms reloaded, the box '
      'unchecked, the message; no registration until the new terms are '
      'loaded, then with their version', (tester) async {
    final reloaded = Completer<PortalReply>();
    var termsCalls = 0;
    var registers = 0;
    final backend = FakePortalBackend()
      ..onRequest('GET', _terms, (_) async {
        termsCalls++;
        return termsCalls == 1
            ? PortalReply.fixture('legal.terms.current.get.200.json')
            : await reloaded.future;
      })
      ..onRequest('POST', _register, (_) {
        registers++;
        return registers == 1
            ? PortalReply.fixture(
                'auth.register.terms-outdated.post.422.json',
                status: 422,
              )
            : PortalReply.fixture('auth.register.post.201.json', status: 201);
      });
    await _pump(tester, backend: backend);

    await _fill(tester);
    await _accept(tester);
    await _submit(tester);

    expect(
      find.text(
        "Les conditions d'utilisation ont changé : relisez-les, puis "
        'acceptez-les à nouveau.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<KivetoCheckbox>(find.byType(KivetoCheckbox)).value,
      isFalse,
    );
    expect(termsCalls, 2);
    expect(find.text('Recommencer'), findsNothing);

    // Ticked again while the new terms load: the button waits.
    await _accept(tester);
    expect(
      tester.widget<KivetoCheckbox>(find.byType(KivetoCheckbox)).value,
      isTrue,
    );
    expect(_cta(tester).onPressed, isNull);

    reloaded.complete(PortalReply.json(_newTerms));
    await tester.pumpAndSettle();
    expect(_cta(tester).onPressed, isNotNull);
    await _submit(tester);

    expect(
      (jsonDecode(utf8.decode(backend.requestsTo(_register).last.body))
          as Map<String, Object?>)['termsVersion'],
      '2026-11-01',
    );
  });

  for (final (reply, message) in [
    (
      problem('account_disabled', 403),
      'Ce compte est désactivé. Contactez votre clinique.',
    ),
    (problem('rate_limited', 429), 'Réessayez dans quelques minutes.'),
  ]) {
    testWidgets(message, (tester) async {
      await _pump(tester, backend: _backend(reply));

      await _fill(tester);
      await _accept(tester);
      await _submit(tester);

      expect(find.text(message), findsOneWidget);
      expect(find.text('Recommencer'), findsNothing);

      // An edit clears the message.
      await tester.enterText(
        find.descendant(of: _field('Nom'), matching: find.byType(TextField)),
        'Martin',
      );
      await tester.pump();
      expect(find.text(message), findsNothing);
    });
  }

  testWidgets('back: the flow is cleared, back to the start', (tester) async {
    final (container, exits, _) = await _pump(tester);

    await tester.tap(find.byType(KivetoIconButton));

    expect(exits, ['restart']);
    expect(container.read(registrationFlowProvider), isNull);
  });

  group('the terms links', () {
    testWidgets('open the terms page', (tester) async {
      final opened = <Uri>[];
      await _pump(tester, opened: opened);

      await tester.tapOnText(
        find.textRange.ofSubstring("conditions d'utilisation"),
      );
      await tester.tapOnText(
        find.textRange.ofSubstring('politique de confidentialité'),
      );
      await tester.pumpAndSettle();

      expect(opened, [
        Uri.parse('http://portal.kiveto.local/cgu'),
        Uri.parse('http://portal.kiveto.local/cgu'),
      ]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a page that cannot open: a snackbar', (tester) async {
      await _pump(tester, opened: [], opens: false);

      await tester.tapOnText(
        find.textRange.ofSubstring("conditions d'utilisation"),
      );
      await tester.pump();

      expect(
        find.text("Impossible d'ouvrir les conditions d'utilisation."),
        findsOneWidget,
      );
    });

    testWidgets('terms that cannot load: the box disabled, a retry', (
      tester,
    ) async {
      var calls = 0;
      final backend = FakePortalBackend()
        ..onRequest('GET', _terms, (_) {
          calls++;
          return calls == 1
              ? problem('service_unavailable', 503)
              : PortalReply.fixture('legal.terms.current.get.200.json');
        });
      await _pump(tester, backend: backend);

      expect(
        tester.widget<KivetoCheckbox>(find.byType(KivetoCheckbox)).onChanged,
        isNull,
      );
      expect(
        find.text(
          "Impossible de charger les conditions d'utilisation. Réessayer",
          findRichText: true,
        ),
        findsOneWidget,
      );
      // The links have no page yet.
      await tester.tapOnText(
        find.textRange.ofSubstring("conditions d'utilisation").first,
      );
      await tester.pump();
      expect(
        find.text("Impossible d'ouvrir les conditions d'utilisation."),
        findsOneWidget,
      );

      await tester.tapOnText(find.textRange.ofSubstring('Réessayer'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<KivetoCheckbox>(find.byType(KivetoCheckbox)).onChanged,
        isNotNull,
      );
      expect(find.textContaining('Impossible de charger'), findsNothing);
    });
  });
}
