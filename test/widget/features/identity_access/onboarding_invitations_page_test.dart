// The pending invitations of a verified number: one as a card, several as
// a choice; signed out (the first acceptance creates the account) or in
// ("Plus tard"); the refusals.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/onboarding_invitations_page.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _terms = '$api/legal/terms/current';

/// The current terms after a change.
const _newTerms =
    '{"version":"2026-11-01","url":"http://portal.kiveto.local/cgu"}';
String _accept(String id) => '$api/invitations/$id/accept';

const _paris = PendingInvitation(
  id: 'paris',
  clinicName: 'Clinique Vétérinaire de Paris',
  clinicCity: 'Paris',
);
const _lyon = PendingInvitation(
  id: 'lyon',
  clinicName: 'Clinique Vétérinaire de Lyon',
);
final _grant = OnboardingGrant(
  token: 'onb',
  expiresAt: DateTime.utc(2026, 11, 3, 10, 38),
);

PortalReply _accepted() => PortalReply.json(
  jsonEncode({
    'accessToken': 'A',
    'accessTokenExpiresAt': '2026-11-03T10:38:48+00:00',
    'refreshToken': 'refresh-A',
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

FakePortalBackend _backend() => FakePortalBackend()
  ..on('GET', _terms, PortalReply.fixture('legal.terms.current.get.200.json'));

Future<(ProviderContainer, List<String>, SessionManager)> _pump(
  WidgetTester tester, {
  FakePortalBackend? backend,
  List<PendingInvitation>? invitations,
  bool signedIn = false,
}) async {
  final exits = <String>[];
  final session = await memorySession(signedIn ? pair('A') : null);
  final container = await pumpPage(
    tester,
    OnboardingInvitationsPage(
      onDone: (_) => exits.add('home'),
      onRestart: (_) => exits.add('restart'),
    ),
    session: session,
    backend: backend ?? _backend(),
    prepare: invitations == null
        ? null
        : (container) => container
              .read(onboardingProvider.notifier)
              .start(
                grant: _grant,
                invitations: invitations,
                signedIn: signedIn,
              ),
  );
  return (container, exits, session);
}

Future<void> _acceptTerms(WidgetTester tester) async {
  await tester.tap(find.byType(KivetoCheckbox));
  await tester.pump();
}

KivetoButton _cta(WidgetTester tester) =>
    tester.widget<KivetoButton>(find.byType(KivetoButton));

void main() {
  testWidgets('without its flow, signed out: back to the start', (
    tester,
  ) async {
    final (_, exits, _) = await _pump(tester);

    expect(exits, ['restart']);
  });

  testWidgets('without its flow, signed in: home', (tester) async {
    final (_, exits, _) = await _pump(tester, signedIn: true);

    expect(exits, ['home']);
  });

  testWidgets('one invitation, signed out: the clinic card, the terms, '
      '"Activer mon espace"; accepted, the session opens, home', (
    tester,
  ) async {
    final backend = _backend()..on('POST', _accept('paris'), _accepted());
    final (container, exits, session) = await _pump(
      tester,
      backend: backend,
      invitations: [_paris],
    );

    expect(find.text('Kiveto'), findsOneWidget);
    expect(
      find.text('Invitation : Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
    expect(find.text('Activez votre espace'), findsOneWidget);
    expect(find.textContaining('Votre clinique vous invite'), findsOneWidget);
    expect(find.byType(KivetoCard), findsOneWidget);
    expect(find.text('Clinique Vétérinaire de Paris'), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('Plus tard'), findsNothing);
    expect(
      find.text("Pas maintenant ? Revenir à l'accueil", findRichText: true),
      findsOneWidget,
    );
    expect(_cta(tester).label, 'Activer mon espace');
    expect(_cta(tester).onPressed, isNull);

    await _acceptTerms(tester);
    expect(_cta(tester).onPressed, isNotNull);
    await tester.tap(find.text('Activer mon espace'));
    await pumpBriefly(tester);

    expect(
      jsonDecode(utf8.decode(backend.requestsTo(_accept('paris')).single.body)),
      {'onboardingToken': 'onb', 'termsVersion': '2026-10-29'},
    );
    expect(session.status, SessionStatus.signedIn);
    expect(exits, ['home']);
    expect(container.read(onboardingProvider), isNull);
  });

  testWidgets('signed out, "Revenir à l\'accueil": the flow cleared, back '
      'to the start', (tester) async {
    final (container, exits, _) = await _pump(tester, invitations: [_paris]);

    await tester.tapOnText(find.textRange.ofSubstring("Revenir à l'accueil"));

    expect(exits, ['restart']);
    expect(container.read(onboardingProvider), isNull);
  });

  testWidgets('several, signed in: a choice; one accepted, the others stay '
      'with a success line; "Plus tard" goes home', (tester) async {
    final backend = _backend()..on('POST', _accept('lyon'), _accepted());
    final (container, exits, _) = await _pump(
      tester,
      backend: backend,
      invitations: [_paris, _lyon],
      signedIn: true,
    );

    expect(find.text('2 invitations'), findsOneWidget);
    expect(find.byType(KivetoRadioCard), findsNWidgets(2));
    expect(
      tester
          .widget<KivetoRadioCard>(find.byType(KivetoRadioCard).first)
          .selected,
      isTrue,
    );
    expect(_cta(tester).label, 'Accepter cette invitation');
    expect(find.text('Plus tard'), findsOneWidget);
    expect(find.textContaining('Pas maintenant'), findsNothing);

    await tester.tap(find.text('Clinique Vétérinaire de Lyon'));
    await tester.pump();
    await _acceptTerms(tester);
    await tester.tap(find.text('Accepter cette invitation'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_accept('lyon')), hasLength(1));
    expect(
      find.text('Invitation acceptée : Clinique Vétérinaire de Lyon.'),
      findsOneWidget,
    );
    expect(
      find.text('Invitation : Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
    expect(_cta(tester).label, 'Accepter cette invitation');
    expect(exits, isEmpty);

    await tester.tap(find.text('Plus tard'));
    expect(exits, ['home']);
    expect(container.read(onboardingProvider), isNull);
  });

  testWidgets('an expired grant: the message, "Se reconnecter"', (
    tester,
  ) async {
    final backend = _backend()
      ..on('POST', _accept('paris'), problem('onboarding_invalid', 401));
    final (container, exits, _) = await _pump(
      tester,
      backend: backend,
      invitations: [_paris],
    );

    await _acceptTerms(tester);
    await tester.tap(find.text('Activer mon espace'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Votre vérification a expiré. Reconnectez-vous avec votre numéro.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Se reconnecter'));
    expect(exits, ['restart']);
    expect(container.read(onboardingProvider), isNull);
  });

  testWidgets('an invitation no longer available: removed, with the '
      'message; none left', (tester) async {
    final backend = _backend()
      ..on('POST', _accept('paris'), problem('invitation_invalid', 404));
    await _pump(tester, backend: backend, invitations: [_paris]);

    await _acceptTerms(tester);
    await tester.tap(find.text('Activer mon espace'));
    await tester.pumpAndSettle();

    expect(
      find.text("Cette invitation n'est plus disponible."),
      findsOneWidget,
    );
    expect(find.text('Aucune invitation en attente.'), findsOneWidget);
    expect(find.byType(KivetoButton), findsNothing);
    expect(find.text('Clinique Vétérinaire de Paris'), findsNothing);
  });

  testWidgets('terms_outdated: the terms reloaded, the box unchecked, the '
      'message; no acceptance until the new terms are loaded, then with '
      'their version', (tester) async {
    final reloaded = Completer<PortalReply>();
    var termsCalls = 0;
    var accepts = 0;
    final backend = FakePortalBackend()
      ..onRequest('GET', _terms, (_) async {
        termsCalls++;
        return termsCalls == 1
            ? PortalReply.fixture('legal.terms.current.get.200.json')
            : await reloaded.future;
      })
      ..onRequest('POST', _accept('paris'), (_) {
        accepts++;
        return accepts == 1
            ? PortalReply.fixture(
                'auth.register.terms-outdated.post.422.json',
                status: 422,
              )
            : _accepted();
      });
    final (_, exits, _) = await _pump(
      tester,
      backend: backend,
      invitations: [_paris],
    );

    await _acceptTerms(tester);
    await tester.tap(find.text('Activer mon espace'));
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
    expect(find.text('Se reconnecter'), findsNothing);

    // Ticked again while the new terms load: the button waits.
    await _acceptTerms(tester);
    expect(_cta(tester).onPressed, isNull);

    reloaded.complete(PortalReply.json(_newTerms));
    await tester.pumpAndSettle();
    expect(_cta(tester).onPressed, isNotNull);
    await tester.tap(find.text('Activer mon espace'));
    await pumpBriefly(tester);

    expect(
      (jsonDecode(utf8.decode(backend.requestsTo(_accept('paris')).last.body))
          as Map<String, Object?>)['termsVersion'],
      '2026-11-01',
    );
    expect(exits, ['home']);
  });

  testWidgets('a disabled account: the message', (tester) async {
    final backend = _backend()
      ..on('POST', _accept('paris'), problem('account_disabled', 403));
    final (_, exits, session) = await _pump(
      tester,
      backend: backend,
      invitations: [_paris],
    );

    await _acceptTerms(tester);
    await tester.tap(find.text('Activer mon espace'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ce compte est désactivé. Contactez votre clinique.'),
      findsOneWidget,
    );
    expect(session.status, SessionStatus.signedOut);
    expect(exits, isEmpty);
  });
}
