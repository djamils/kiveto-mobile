// Screen 6 on the fake backend and the captures: Julien's filled page (the
// profile, both clinics, Paris's consents, the data, the sign-out), the
// /me error, an unverified e-mail, Marchand's verified one, a pending link,
// a clinic switch, a consent toggled (its 200, 409, 422 and other
// refusals), the consents' 404, a clinic-less account, pull-to-refresh, the
// exit to the clinic search.
//
// Every instant of the captures is moved to midday UTC: its day holds in
// any test zone.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/presentation/clinic_row.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _lyonId = '01960000-0000-7000-8000-000000000101';
const _julien = '01a19a10-d011-70c8-8daf-26e4db824374';
const _me = '$api/me';
const _parisConsents = '$api/clinics/$_parisId/consents';
const _lyonConsents = '$api/clinics/$_lyonId/consents';

/// The capture [fixture] with every instant at midday UTC.
String _midday(String fixture) =>
    File('$portalFixtures/$fixture')
        .readAsStringSync()
        .replaceAll(RegExp(r'T\d\d:\d\d:\d\d\+00:00'), 'T12:00:00+00:00');

PortalReply _reply(String fixture) => PortalReply.json(_midday(fixture));

/// `GET /me` of [fixture] (at midday), changed by [change].
PortalReply _meWith(
  void Function(Map<String, Object?> account, List<Object?> clinics) change, {
  String fixture = 'me.get.200.json',
}) {
  final body = jsonDecode(_midday(fixture)) as Map<String, Object?>;
  change(
    body['account']! as Map<String, Object?>,
    body['clinics']! as List<Object?>,
  );
  return PortalReply.json(jsonEncode(body));
}

/// Paris's consents of Julien (capture) with [kind] on [channels].
PortalReply _consentsWith(String kind, List<String> channels) =>
    _consentsWithAll({kind: channels});

/// Paris's consents of Julien (capture) with each kind of [channels] on
/// its channels.
PortalReply _consentsWithAll(Map<String, List<String>> channels) {
  final body = jsonDecode(
    _midday('clinics.paris.consents.get.200.json'),
  ) as Map<String, Object?>;
  for (final consent
      in (body['consents']! as List<Object?>).cast<Map<String, Object?>>()) {
    if (channels[consent['kind']] case final kindChannels?) {
      consent['channels'] = kindChannels;
    }
  }
  return PortalReply.json(jsonEncode(body));
}

/// Julien signed in, Paris active, its consents.
FakePortalBackend _julienBackend() => FakePortalBackend()
  ..on('GET', _me, _reply('me.get.200.json'))
  ..on('GET', _parisConsents, _reply('clinics.paris.consents.get.200.json'));

int _gets(FakePortalBackend backend, String path) =>
    backend.requestsTo(path).where((request) => request.method == 'GET').length;

Finder _tile(ConsentKind kind, String channel) => find.descendant(
  of: find.byKey(ValueKey(kind)),
  matching: find.widgetWithText(KivetoCheckboxTile, channel),
);

KivetoCheckboxTile _tileOf(
  WidgetTester tester,
  ConsentKind kind,
  String channel,
) => tester.widget<KivetoCheckboxTile>(_tile(kind, channel));

ClinicRow _row(WidgetTester tester, String name) =>
    tester.widget<ClinicRow>(find.widgetWithText(ClinicRow, name));

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  /// The page on a view tall enough to build every section.
  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    SessionManager? session,
    InMemoryActiveClinicStore? store,
    List<Override> overrides = const [],
  }) async {
    final container = await pumpPage(
      tester,
      AccountPage(onAddClinic: (_) => exits.add('clinics')),
      session: session ?? await memorySession(pair('A')),
      backend: backend,
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          store ?? InMemoryActiveClinicStore(),
        ),
        ...overrides,
      ],
    );
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  testWidgets('Julien (captures): the profile, both clinics, the consents '
      'of Paris, the data, the sign-out, in the order of mockup 06', (
    tester,
  ) async {
    await pump(tester, _julienBackend());

    expect(find.text('Compte'), findsOneWidget);
    expect(find.text('JG'), findsOneWidget);
    expect(find.text('Julien Girard'), findsOneWidget);
    expect(find.text('+33 6 •• •• •• 78'), findsOneWidget);
    expect(find.text('À vérifier'), findsNothing);
    expect(find.text('Aucune adresse renseignée'), findsOneWidget);
    expect(find.widgetWithText(KivetoButton, 'Modifier'), findsOneWidget);
    expect(find.text('Ajouter une adresse e-mail'), findsOneWidget);

    expect(find.text('Mes cliniques'), findsOneWidget);
    expect(
      find.text('Ajouter une clinique', findRichText: true),
      findsOneWidget,
    );
    final paris = _row(tester, 'Clinique Vétérinaire de Paris');
    expect(paris.active, isTrue);
    expect(paris.meta, 'Oslo · rattachée le 2 sept.');
    expect(paris.onTap, isNull);
    expect(
      find.descendant(
        of: find.widgetWithText(ClinicRow, 'Clinique Vétérinaire de Paris'),
        matching: find.widgetWithText(StatusPill, 'Active'),
      ),
      findsOneWidget,
    );
    final lyon = _row(tester, 'Clinique Vétérinaire de Lyon');
    expect(lyon.active, isFalse);
    expect(lyon.pending, isFalse);
    expect(lyon.meta, 'Pixel · rattachée le 21 oct.');
    expect(lyon.onTap, isNotNull);

    expect(find.text('Consentements'), findsOneWidget);
    expect(
      find.text(
        'Pour Clinique Vétérinaire de Paris. Modifiable à tout moment.',
      ),
      findsOneWidget,
    );
    final tops = [
      for (final kind in ConsentKind.known)
        tester.getTopLeft(find.byKey(ValueKey(kind))).dy,
    ];
    expect(tops, [...tops]..sort());
    for (final title in [
      'Confirmations et rappels de RDV',
      'Rappels de soins',
      'Actualités de la clinique',
      'Documents médicaux',
      'Factures',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(
      find.text(
        'Vaccins, antiparasitaires, contrôles. Accordé le 3 oct. 2026.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Avis de factures et de paiements. Toujours envoyés\u00a0: '
        'choisissez au moins un canal. Accordé le 2 sept. 2026.',
      ),
      findsOneWidget,
    );
    for (final kind in ConsentKind.known) {
      expect(_tileOf(tester, kind, 'SMS').value, isTrue);
      expect(_tileOf(tester, kind, 'Email').value, isFalse);
      expect(_tileOf(tester, kind, 'SMS').onChanged, isNotNull);
    }
    expect(
      find.widgetWithText(KivetoLinkButton, 'Historique de mes consentements'),
      findsOneWidget,
    );

    expect(find.text('Mes données'), findsOneWidget);
    expect(find.text('Exporter mes données'), findsOneWidget);
    expect(find.text('Demander la suppression de mon compte'), findsOneWidget);
    expect(
      find.text(
        'Les factures restent conservées par la clinique selon ses '
        'obligations légales.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(KivetoButton, 'Se déconnecter'), findsOneWidget);

    // Mockup 06's order.
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('Compte'), lessThan(top('Julien Girard')));
    expect(top('Julien Girard'), lessThan(top('Mes cliniques')));
    expect(top('Mes cliniques'), lessThan(top('Consentements')));
    expect(top('Consentements'), lessThan(top('Mes données')));
    expect(top('Mes données'), lessThan(top('Se déconnecter')));
  });

  testWidgets('/me in error: the error view and its retry, the sign-out '
      'still there', (tester) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, problem('service_unavailable', 503));
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(find.text('Mes cliniques'), findsNothing);
    expect(find.widgetWithText(KivetoButton, 'Se déconnecter'), findsOneWidget);

    backend
      ..on('GET', _me, _reply('me.get.200.json'))
      ..on(
        'GET',
        _parisConsents,
        _reply('clinics.paris.consents.get.200.json'),
      );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Julien Girard'), findsOneWidget);
  });

  testWidgets('an unverified e-mail: « À vérifier », « Vérifier mon adresse '
      'e-mail » opens the sheet with the address', (tester) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        _me,
        _meWith((account, _) {
          account
            ..['email'] = 'julien@example.com'
            ..['emailVerified'] = false;
        }),
      );
    await pump(tester, backend);

    expect(find.text('julien@example.com · +33 6 •• •• •• 78'), findsOneWidget);
    expect(find.widgetWithText(StatusPill, 'À vérifier'), findsOneWidget);
    expect(find.text('Ajouter une adresse e-mail'), findsNothing);

    await tap(tester, find.text('Vérifier mon adresse e-mail'));
    await tester.pumpAndSettle();

    // The sheet's title (the row stays behind it).
    expect(find.text('Vérifier mon adresse e-mail'), findsNWidgets(2));
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(KivetoTextField, 'Adresse e-mail'),
        matching: find.byType(TextField),
      ),
    );
    expect(field.controller?.text, 'julien@example.com');
  });

  testWidgets('Marchand (capture): a verified e-mail, three clinics, many '
      'pets', (tester) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, _reply('me.marchand.get.200.json'))
      ..on(
        'GET',
        _parisConsents,
        _reply('clinics.paris.consents.marchand.get.200.json'),
      );
    await pump(tester, backend);

    expect(find.text('TM'), findsOneWidget);
    expect(find.text('Thierry Marchand'), findsOneWidget);
    expect(
      find.text('thierry.marchand@orange.fr · +33 6 •• •• •• 80'),
      findsOneWidget,
    );
    expect(find.text('À vérifier'), findsNothing);
    expect(find.text("Changer d'adresse e-mail"), findsOneWidget);
    expect(
      _row(tester, 'Clinique Vétérinaire de Paris').meta,
      'Gaston, Minette, Réglisse, Tigrou, Brio, Sésame · rattachée le 16 avr.',
    );
    expect(
      _row(tester, 'Clinique du Vercors').meta,
      'Névé · rattachée le 28 oct.',
    );
    expect(
      _tileOf(tester, ConsentKind.appointmentReminders, 'Email').value,
      isTrue,
    );
    expect(
      _tileOf(tester, ConsentKind.clinicalDocuments, 'SMS').value,
      isFalse,
    );
  });

  testWidgets('an address, tags, no name; a pending link: grey, « En '
      'attente », not tappable', (tester) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        _me,
        _meWith((account, clinics) {
          account
            ..['firstName'] = null
            ..['lastName'] = ' '
            ..['address'] = {
              'line1': '12 rue des Lices',
              'line2': 'Bât. B',
              'postalCode': '13006',
              'city': 'Marseille',
              'country': 'FR',
            };
          (clinics[0]! as Map<String, Object?>)['tags'] = ['urgences'];
          (clinics[1]! as Map<String, Object?>)
            ..['linkStatus'] = 'pending'
            ..['linkedAt'] = null;
        }),
      );
    await pump(tester, backend);

    // No name: the phone, an avatar without initials.
    expect(find.text('?'), findsOneWidget);
    expect(find.text('+33 6 •• •• •• 78'), findsNWidgets(2));
    expect(
      find.text('12 rue des Lices, Bât. B, 13006 Marseille'),
      findsOneWidget,
    );
    expect(
      _row(tester, 'Clinique Vétérinaire de Paris').meta,
      'Oslo · urgences · rattachée le 2 sept.',
    );
    final lyon = _row(tester, 'Clinique Vétérinaire de Lyon');
    expect(lyon.pending, isTrue);
    expect(lyon.active, isFalse);
    expect(lyon.onTap, isNull);
    expect(lyon.meta, 'En attente de confirmation par la clinique');
    expect(
      find.descendant(
        of: find.widgetWithText(ClinicRow, 'Clinique Vétérinaire de Lyon'),
        matching: find.widgetWithText(StatusPill, 'En attente'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('an address without postal code', (tester) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        _me,
        _meWith((account, _) {
          account['address'] = {
            'line1': '7 quai Saint-Antoine',
            'line2': null,
            'postalCode': null,
            'city': 'Lyon',
            'country': 'FR',
          };
        }),
      );
    await pump(tester, backend);

    expect(find.text('7 quai Saint-Antoine, Lyon'), findsOneWidget);
  });

  testWidgets('a tap on Lyon: Lyon active, kept for the account, /me '
      'reloaded, the consents of Lyon', (tester) async {
    final store = InMemoryActiveClinicStore();
    final backend = _julienBackend()
      ..on(
        'GET',
        _lyonConsents,
        _reply('clinics.paris.consents.marchand.get.200.json'),
      );
    await pump(tester, backend, store: store);

    await tap(tester, find.text('Clinique Vétérinaire de Lyon'));
    await tester.pumpAndSettle();

    expect(_row(tester, 'Clinique Vétérinaire de Lyon').active, isTrue);
    expect(_row(tester, 'Clinique Vétérinaire de Paris').active, isFalse);
    expect(store.choices, {_julien: _lyonId});
    expect(_gets(backend, _me), 2);
    expect(_gets(backend, _lyonConsents), 1);
    expect(
      find.text('Pour Clinique Vétérinaire de Lyon. Modifiable à tout moment.'),
      findsOneWidget,
    );
    expect(_tileOf(tester, ConsentKind.marketing, 'Email').value, isTrue);
  });

  group('a consent toggled', () {
    testWidgets('marketing email on: shown at once, the kind disabled until '
        'the server answers; then the stored consents (capture), /me '
        'reloaded', (tester) async {
      final answer = Completer<PortalReply>();
      final bodies = <String>[];
      final backend = _julienBackend()
        ..onRequest('PUT', '$_parisConsents/marketing', (request) {
          bodies.add(utf8.decode(request.body));
          return answer.future;
        });
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'Email'));
      await tester.pump();

      expect(_tileOf(tester, ConsentKind.marketing, 'Email').value, isTrue);
      expect(_tileOf(tester, ConsentKind.marketing, 'Email').onChanged, isNull);
      expect(_tileOf(tester, ConsentKind.marketing, 'SMS').onChanged, isNull);
      expect(_tileOf(tester, ConsentKind.billing, 'SMS').onChanged, isNotNull);

      answer.complete(_reply('clinics.paris.consents.marketing.put.200.json'));
      await tester.pumpAndSettle();

      expect(bodies, ['{"channels":["sms","email"]}']);
      expect(_tileOf(tester, ConsentKind.marketing, 'SMS').value, isTrue);
      expect(_tileOf(tester, ConsentKind.marketing, 'Email').value, isTrue);
      expect(
        _tileOf(tester, ConsentKind.marketing, 'Email').onChanged,
        isNotNull,
      );
      // The server's state: the capture's other kinds are not granted.
      expect(_tileOf(tester, ConsentKind.billing, 'SMS').value, isFalse);
      expect(_gets(backend, _me), 2);
      expect(_gets(backend, _parisConsents), 1);
    });

    testWidgets('two kinds at once: the first answer keeps the change asked '
        'for the second, still disabled; then the second answer', (
      tester,
    ) async {
      final marketing = Completer<PortalReply>();
      final billing = Completer<PortalReply>();
      final backend = _julienBackend()
        ..onRequest('PUT', '$_parisConsents/marketing', (_) => marketing.future)
        ..onRequest('PUT', '$_parisConsents/billing', (_) => billing.future);
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'Email'));
      await tester.pump();
      await tap(tester, _tile(ConsentKind.billing, 'Email'));
      await tester.pump();

      // The server stored marketing; its answer does not have billing's
      // change yet.
      marketing.complete(_consentsWith('marketing', ['sms', 'email']));
      await tester.pumpAndSettle();

      expect(_tileOf(tester, ConsentKind.marketing, 'Email').value, isTrue);
      expect(
        _tileOf(tester, ConsentKind.marketing, 'Email').onChanged,
        isNotNull,
      );
      expect(_tileOf(tester, ConsentKind.billing, 'Email').value, isTrue);
      expect(_tileOf(tester, ConsentKind.billing, 'Email').onChanged, isNull);
      expect(_tileOf(tester, ConsentKind.billing, 'SMS').onChanged, isNull);

      billing.complete(
        _consentsWithAll({
          'marketing': ['sms', 'email'],
          'billing': ['email'],
        }),
      );
      await tester.pumpAndSettle();

      // The server's answer: billing on email only.
      expect(_tileOf(tester, ConsentKind.billing, 'Email').value, isTrue);
      expect(_tileOf(tester, ConsentKind.billing, 'SMS').value, isFalse);
      expect(
        _tileOf(tester, ConsentKind.billing, 'Email').onChanged,
        isNotNull,
      );
      expect(_tileOf(tester, ConsentKind.marketing, 'Email').value, isTrue);
      expect(_gets(backend, _me), 3);
    });

    testWidgets('a clinic switch while a change is on its way: its answer is '
        "dropped, the header and the tiles stay Lyon's", (tester) async {
      final answer = Completer<PortalReply>();
      final backend = _julienBackend()
        ..onRequest('PUT', '$_parisConsents/marketing', (_) => answer.future)
        ..on(
          'GET',
          _lyonConsents,
          _reply('clinics.paris.consents.marchand.get.200.json'),
        );
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'SMS'));
      await tester.pump();
      await tap(tester, find.text('Clinique Vétérinaire de Lyon'));
      await tester.pumpAndSettle();
      const lyon =
          'Pour Clinique Vétérinaire de Lyon. Modifiable à tout moment.';
      expect(find.text(lyon), findsOneWidget);

      answer.complete(_consentsWith('marketing', []));
      await tester.pumpAndSettle();

      expect(find.text(lyon), findsOneWidget);
      // Lyon's consents (Marchand's capture), not Paris's answer.
      expect(_tileOf(tester, ConsentKind.marketing, 'SMS').value, isFalse);
      expect(_tileOf(tester, ConsentKind.marketing, 'Email').value, isTrue);
      expect(
        _tileOf(tester, ConsentKind.marketing, 'Email').onChanged,
        isNotNull,
      );
      expect(
        _tileOf(tester, ConsentKind.appointmentReminders, 'Email').value,
        isTrue,
      );
    });

    testWidgets('marketing SMS off: an empty channel list', (tester) async {
      final bodies = <String>[];
      final backend = _julienBackend()
        ..onRequest('PUT', '$_parisConsents/marketing', (request) {
          bodies.add(utf8.decode(request.body));
          return _consentsWith('marketing', []);
        });
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'SMS'));
      await tester.pumpAndSettle();

      expect(bodies, ['{"channels":[]}']);
      expect(_tileOf(tester, ConsentKind.marketing, 'SMS').value, isFalse);
      expect(
        find.text('Conseils saisonniers, horaires, nouveautés.'),
        findsOneWidget,
      );
    });

    testWidgets('billing emptied (capture): the 422 puts the tile back and '
        'asks to keep one channel', (tester) async {
      final backend = _julienBackend()
        ..on(
          'PUT',
          '$_parisConsents/billing',
          PortalReply.fixture(
            'clinics.paris.consents.billing-empty.put.422.json',
            status: 422,
          ),
        );
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.billing, 'SMS'));
      await tester.pumpAndSettle();

      expect(_tileOf(tester, ConsentKind.billing, 'SMS').value, isTrue);
      expect(_tileOf(tester, ConsentKind.billing, 'SMS').onChanged, isNotNull);
      expect(
        find.text(
          'Ces messages sont envoyés dans tous les cas\u00a0: gardez au '
          'moins un canal.',
        ),
        findsOneWidget,
      );
      expect(_gets(backend, _me), 1);
    });

    testWidgets('409 conflict: the consents reload, the SnackBar says why', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on('PUT', '$_parisConsents/marketing', problem('conflict', 409));
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'SMS'));
      await tester.pumpAndSettle();

      expect(_gets(backend, _parisConsents), 2);
      expect(_tileOf(tester, ConsentKind.marketing, 'SMS').value, isTrue);
      expect(
        find.text(
          'Vos consentements ont changé entre-temps\u00a0: vérifiez-les, '
          'puis réessayez.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('another refusal: the tile back, the failure in the '
        'SnackBar', (tester) async {
      final backend = _julienBackend()
        ..on(
          'PUT',
          '$_parisConsents/marketing',
          problem('service_unavailable', 503),
        );
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'SMS'));
      await tester.pumpAndSettle();

      expect(_tileOf(tester, ConsentKind.marketing, 'SMS').value, isTrue);
      expect(
        find.text(
          'Le service rencontre un problème. Réessayez dans un instant.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a 422 on a kind not sent anyway: the generic message', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on(
          'PUT',
          '$_parisConsents/marketing',
          PortalReply.fixture(
            'clinics.paris.consents.billing-empty.put.422.json',
            status: 422,
          ),
        );
      await pump(tester, backend);

      await tap(tester, _tile(ConsentKind.marketing, 'SMS'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Certaines informations ne sont pas valides. Corrigez-les, puis '
          'réessayez.',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('the consents in 404: their own message, a retry', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on('GET', _parisConsents, problem('not_found', 404));
    await pump(tester, backend);

    expect(find.text('Consentements indisponibles'), findsOneWidget);
    expect(
      find.text(
        'Les consentements de cette clinique ne sont pas disponibles pour '
        "l'instant.",
      ),
      findsOneWidget,
    );
    expect(find.text('Historique de mes consentements'), findsNothing);

    backend.on(
      'GET',
      _parisConsents,
      _reply('clinics.paris.consents.get.200.json'),
    );
    await tap(tester, find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Consentements indisponibles'), findsNothing);
    expect(_tileOf(tester, ConsentKind.billing, 'SMS').value, isTrue);
  });

  testWidgets('a clinic-less account (capture): no clinic, no consents', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, _reply('me.no-clinic.get.200.json'));
    await pump(tester, backend);

    expect(find.text('Test Capture'), findsOneWidget);
    expect(
      find.text("Aucune clinique rattachée pour l'instant."),
      findsOneWidget,
    );
    expect(find.text('Consentements'), findsNothing);
    expect(find.text('Mes données'), findsOneWidget);
    expect(backend.requests.map((request) => request.uri.path), [_me]);
  });

  testWidgets('pull to refresh: /me and the consents again; every tile '
      'disabled while the consents reload', (tester) async {
    final backend = _julienBackend();
    await pump(tester, backend);
    final reload = Completer<PortalReply>();
    backend.onRequest('GET', _parisConsents, (_) => reload.future);

    // A quarter of the (tall) view at least arms the indicator.
    await tester.fling(find.byType(ListView), const Offset(0, 1000), 1000);
    await tester.pumpAndSettle();

    expect(_gets(backend, _me), 2);
    expect(_gets(backend, _parisConsents), 2);
    for (final kind in ConsentKind.known) {
      expect(_tileOf(tester, kind, 'SMS').value, isTrue);
      expect(_tileOf(tester, kind, 'SMS').onChanged, isNull);
      expect(_tileOf(tester, kind, 'Email').onChanged, isNull);
    }

    reload.complete(_reply('clinics.paris.consents.get.200.json'));
    await tester.pumpAndSettle();

    for (final kind in ConsentKind.known) {
      expect(_tileOf(tester, kind, 'SMS').onChanged, isNotNull);
    }
  });

  testWidgets('« Ajouter une clinique »: the exit to the clinic search', (
    tester,
  ) async {
    await pump(tester, _julienBackend());

    await tap(tester, find.text('Ajouter une clinique', findRichText: true));
    await tester.pumpAndSettle();

    expect(exits, ['clinics']);
  });

  testWidgets('« Demander la suppression de mon compte » opens the deletion '
      'sheet', (tester) async {
    await pump(tester, _julienBackend());

    await tap(tester, find.text('Demander la suppression de mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer mon compte\u00a0?'), findsOneWidget);
    expect(
      find.text('Un code de confirmation va être envoyé au +33 6 •• •• •• 78.'),
      findsOneWidget,
    );
  });

  testWidgets('a verified e-mail from the sheet reloads /me', (tester) async {
    final backend = _julienBackend()
      ..on(
        'POST',
        '$_me/email-change/otp',
        PortalReply.fixture('me.email-change.otp.post.202.json', status: 202),
      )
      ..on(
        'POST',
        '$_me/email-change',
        PortalReply.fixture('me.email-change.post.202.json', status: 202),
      )
      ..on(
        'POST',
        '$_me/email-change/verify',
        PortalReply.fixture('me.email-change.verify.post.200.json'),
      );
    await pump(tester, backend);

    await tap(tester, find.text('Ajouter une adresse e-mail'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'julien@example.com');
    await tester.pump();
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    expect(_gets(backend, _me), 1);
    await tester.enterText(find.byType(TextField), '654321');
    await tester.pumpAndSettle();

    // Reloaded once the server verified it, before « Terminer ».
    expect(find.text('Adresse e-mail vérifiée'), findsOneWidget);
    expect(_gets(backend, _me), 2);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail vérifiée'), findsNothing);
    expect(_gets(backend, _me), 2);
  });

  testWidgets('the sheet closed while the server verifies the e-mail: /me '
      'still reloads once it did', (tester) async {
    final verify = Completer<PortalReply>();
    final backend = _julienBackend()
      ..on(
        'POST',
        '$_me/email-change/otp',
        PortalReply.fixture('me.email-change.otp.post.202.json', status: 202),
      )
      ..on(
        'POST',
        '$_me/email-change',
        PortalReply.fixture('me.email-change.post.202.json', status: 202),
      )
      ..onRequest('POST', '$_me/email-change/verify', (_) => verify.future);
    await pump(tester, backend);

    await tap(tester, find.text('Ajouter une adresse e-mail'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'julien@example.com');
    await tester.pump();
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '654321');
    await tester.pump();

    // Closed by the scrim while the verification runs.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text("Vérifier l'adresse"), findsNothing);
    expect(_gets(backend, _me), 1);

    verify.complete(
      PortalReply.fixture('me.email-change.verify.post.200.json'),
    );
    await tester.pumpAndSettle();

    expect(_gets(backend, _me), 2);
  });

  testWidgets('« Se déconnecter » signs out', (tester) async {
    final session = await memorySession(pair('A'));
    final backend = _julienBackend()
      ..on('POST', '$api/auth/logout', PortalReply.empty(204));
    await pump(tester, backend, session: session);

    await tap(tester, find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(session.status, SessionStatus.signedOut);
    expect(backend.requestsTo('$api/auth/logout'), hasLength(1));
  });
}
