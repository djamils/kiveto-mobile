// The sheets of screen 6, opened from the page on the fake backend and the
// captures: the profile form (the merge patch, « Profil enregistré. », the
// refused fields, other failures), the consent history (two pages,
// Marchand's approximate rows, empty, the errors), the data exports
// (Marchand's ready and expired, the download to the share sheet, a gone
// export, a pending one refreshed, a request and its quota).
//
// Every instant of the captures is moved to midday UTC: its day holds in
// any test zone.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/presentation/account_providers.dart';
import 'package:kiveto_mobile/features/client/presentation/consent_history_sheet.dart';
import 'package:kiveto_mobile/features/client/presentation/data_export_sheet.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _me = '$api/me';
const _consents = '$api/clinics/$_parisId/consents';
const _history = '$_consents/history';
const _exports = '$api/me/data-exports';
const _readyId = '01a19a12-815b-7b5d-95f5-7c7adcb2e774';

String _midday(String fixture) =>
    File('$portalFixtures/$fixture')
        .readAsStringSync()
        .replaceAll(RegExp(r'T\d\d:\d\d:\d\d\+00:00'), 'T12:00:00+00:00');

PortalReply _reply(String fixture, {int status = 200}) =>
    PortalReply.json(_midday(fixture), status: status);

FakePortalBackend _julienBackend() => FakePortalBackend()
  ..on('GET', _me, _reply('me.get.200.json'))
  ..on('GET', _consents, _reply('clinics.paris.consents.get.200.json'));

int _gets(FakePortalBackend backend, String path) =>
    backend.requestsTo(path).where((request) => request.method == 'GET').length;

/// The text field labelled [label].
Finder _field(String label) => find.descendant(
  of: find.widgetWithText(KivetoTextField, label),
  matching: find.byType(TextField),
);

String? _errorOf(WidgetTester tester, String label) => tester
    .widget<KivetoTextField>(find.widgetWithText(KivetoTextField, label))
    .errorText;

/// The device's `HH:mm` of [instant].
String _localTime(DateTime instant) {
  final local = instant.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    List<Override> overrides = const [],
  }) async {
    await pumpPage(
      tester,
      AccountPage(onAddClinic: (_) {}),
      session: await memorySession(pair('A')),
      backend: backend,
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        ...overrides,
      ],
    );
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Opens the history sheet by its link (a span of the section's text).
  Future<void> openHistory(WidgetTester tester) async {
    final link = find.text(
      'Historique de mes consentements',
      findRichText: true,
    );
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tapOnText(
      find.textRange.ofSubstring('Historique de mes consentements'),
    );
    await tester.pumpAndSettle();
  }

  group('the profile sheet', () {
    testWidgets('prefilled; the names and the address in a merge patch; '
        'saved: closed, « Profil enregistré. », /me reloaded', (tester) async {
      final bodies = <Map<String, Object?>>[];
      final backend = _julienBackend()
        ..onRequest('PATCH', _me, (request) {
          bodies.add(
            jsonDecode(utf8.decode(request.body)) as Map<String, Object?>,
          );
          return PortalReply.fixture('me.patch.200.json');
        });
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));

      expect(find.text('Modifier mon profil'), findsOneWidget);
      expect(
        tester.widget<TextField>(_field('Prénom')).controller?.text,
        'Julien',
      );
      expect(
        tester.widget<TextField>(_field('Nom')).controller?.text,
        'Girard',
      );
      expect(
        find.text(
          'Ces informations ne modifient que votre profil Kiveto, pas les '
          "dossiers de vos cliniques. L'adresse peut être modifiée, pas "
          'supprimée.',
        ),
        findsOneWidget,
      );
      await tester.enterText(_field('Adresse'), ' 12 rue des Lices ');
      await tester.enterText(_field('Code postal'), '13006');
      await tester.enterText(_field('Ville'), 'Marseille');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(bodies, [
        {
          'firstName': 'Julien',
          'lastName': 'Girard',
          'address': {
            'streetLine1': '12 rue des Lices',
            'postalCode': '13006',
            'city': 'Marseille',
            'countryCode': 'FR',
          },
        },
      ]);
      expect(find.text('Modifier mon profil'), findsNothing);
      expect(find.text('Profil enregistré.'), findsOneWidget);
      expect(_gets(backend, _me), 2);
    });

    testWidgets('the names only: no address sent; an address with a second '
        'line prefilled as one street line', (tester) async {
      final me = jsonDecode(_midday('me.get.200.json')) as Map<String, Object?>;
      (me['account']! as Map<String, Object?>)['address'] = {
        'line1': '12 rue des Lices',
        'line2': 'Bât. B',
        'postalCode': null,
        'city': 'Marseille',
        'country': 'BE',
      };
      final bodies = <String>[];
      final backend = _julienBackend()
        ..on('GET', _me, PortalReply.json(jsonEncode(me)))
        ..onRequest('PATCH', _me, (request) {
          bodies.add(utf8.decode(request.body));
          return PortalReply.fixture('me.patch.200.json');
        });
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));
      expect(
        tester.widget<TextField>(_field('Adresse')).controller?.text,
        '12 rue des Lices, Bât. B',
      );
      await tester.enterText(_field('Adresse'), '');
      await tester.enterText(_field('Ville'), '');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(bodies, ['{"firstName":"Julien","lastName":"Girard"}']);
    });

    testWidgets('an edited address keeps its country (BE)', (tester) async {
      final me = jsonDecode(_midday('me.get.200.json')) as Map<String, Object?>;
      (me['account']! as Map<String, Object?>)['address'] = {
        'line1': '12 rue Royale',
        'line2': null,
        'postalCode': '1000',
        'city': 'Bruxelles',
        'country': 'BE',
      };
      final bodies = <Map<String, Object?>>[];
      final backend = _julienBackend()
        ..on('GET', _me, PortalReply.json(jsonEncode(me)))
        ..onRequest('PATCH', _me, (request) {
          bodies.add(
            jsonDecode(utf8.decode(request.body)) as Map<String, Object?>,
          );
          return PortalReply.fixture('me.patch.200.json');
        });
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));
      await tester.enterText(_field('Adresse'), '14 rue Royale');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(bodies.single['address'], {
        'streetLine1': '14 rue Royale',
        'postalCode': '1000',
        'city': 'Bruxelles',
        'countryCode': 'BE',
      });
    });

    testWidgets('the sheet closed while the server saves: /me still reloads '
        'once it did', (tester) async {
      final answer = Completer<PortalReply>();
      final backend = _julienBackend()
        ..onRequest('PATCH', _me, (_) => answer.future);
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      // Closed by the scrim while the PATCH runs.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Modifier mon profil'), findsNothing);
      expect(_gets(backend, _me), 1);

      answer.complete(PortalReply.fixture('me.patch.200.json'));
      await tester.pumpAndSettle();

      expect(_gets(backend, _me), 2);
    });

    testWidgets('refused fields (capture): each under its field, the sheet '
        'stays; typing clears its error', (tester) async {
      final backend = _julienBackend()
        ..on(
          'PATCH',
          _me,
          PortalReply.fixture('me.patch.fields.422.json', status: 422),
        );
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));
      await tester.enterText(_field('Prénom'), '');
      await tester.enterText(_field('Code postal'), '13006');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(
        _errorOf(tester, 'Prénom'),
        'Saisissez votre prénom (60 caractères au plus).',
      );
      expect(
        _errorOf(tester, 'Adresse'),
        'Saisissez la rue (255 caractères au plus).',
      );
      expect(
        _errorOf(tester, 'Ville'),
        'Saisissez la ville (255 caractères au plus).',
      );
      expect(_errorOf(tester, 'Nom'), isNull);
      expect(_errorOf(tester, 'Code postal'), isNull);
      expect(find.text('Modifier mon profil'), findsOneWidget);

      await tester.enterText(_field('Prénom'), 'Julien');
      await tester.pump();
      expect(_errorOf(tester, 'Prénom'), isNull);
      expect(_errorOf(tester, 'Ville'), isNotNull);
    });

    testWidgets('the other fields the server names: last name, postal code; '
        'an unknown path: the generic message', (tester) async {
      final backend = _julienBackend()
        ..on(
          'PATCH',
          _me,
          PortalReply.json(
            jsonEncode({
              'type': 'validation_failed',
              'status': 422,
              'violations': [
                {'propertyPath': 'lastName', 'message': 'x'},
                {'propertyPath': 'address.postalCode', 'message': 'x'},
                {'propertyPath': 'address.countryCode', 'message': 'x'},
              ],
            }),
            status: 422,
          ),
        );
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(
        _errorOf(tester, 'Nom'),
        'Saisissez votre nom (60 caractères au plus).',
      );
      expect(
        _errorOf(tester, 'Code postal'),
        'Le code postal comporte 20 caractères au plus.',
      );
      expect(
        find.text(
          'Certaines informations ne sont pas valides. Corrigez-les, puis '
          'réessayez.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('another failure: its message above the button', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on('PATCH', _me, problem('service_unavailable', 503));
      await pump(tester, backend);

      await open(tester, find.widgetWithText(KivetoButton, 'Modifier'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Le service rencontre un problème. Réessayez dans un instant.',
        ),
        findsOneWidget,
      );
      expect(find.text('Profil enregistré.'), findsNothing);
    });
  });

  group('the consent history', () {
    testWidgets('two pages (captures): the rows, « Afficher plus » with the '
        'cursor', (tester) async {
      final cursor =
          (jsonDecode(
                File(
                  '$portalFixtures/'
                  'clinics.paris.consents.history.page1.get.200.json',
                ).readAsStringSync(),
              ) as Map<String, Object?>)['nextCursor']!
              as String;
      final backend = _julienBackend()
        ..on(
          'GET',
          _history,
          _reply('clinics.paris.consents.history.page1.get.200.json'),
        )
        ..on(
          'GET',
          '$_history?cursor=$cursor',
          _reply('clinics.paris.consents.history.page2.get.200.json'),
        );
      await pump(tester, backend);

      await openHistory(tester);

      // The sheet's title (the link stays behind it) and the clinic.
      expect(find.text('Historique de mes consentements'), findsNWidgets(2));
      expect(find.text('Clinique Vétérinaire de Paris'), findsWidgets);
      expect(find.text('Actualités de la clinique · Email'), findsNWidgets(2));
      expect(find.text('Actualités de la clinique · SMS'), findsOneWidget);
      expect(find.text('Retiré le 3 nov. 2026 · Zoé Essai'), findsNWidgets(2));
      expect(find.text('Accordé le 3 nov. 2026 · Zoé Essai'), findsOneWidget);

      await tester.tap(find.text('Afficher plus'));
      await tester.pumpAndSettle();

      expect(find.text('Actualités de la clinique · SMS'), findsNWidgets(2));
      expect(find.text('Accordé le 3 nov. 2026 · Zoé Essai'), findsNWidgets(2));
      expect(find.text('Afficher plus'), findsNothing);
    });

    testWidgets("Marchand (capture): the clinic's and the approximate rows", (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on(
          'GET',
          _history,
          _reply('clinics.paris.consents.history.marchand.get.200.json'),
        );
      await pump(tester, backend);

      await openHistory(tester);

      expect(
        find.text('Accordé le 13 oct. 2026 · La clinique'),
        findsOneWidget,
      );
      expect(
        find.text('Accordé au plus tard le 1 juil. 2020 · Reprise'),
        findsNWidgets(4),
      );
      expect(find.text('Factures · SMS'), findsNWidgets(2));
      expect(find.text('Documents médicaux · Email'), findsOneWidget);
    });

    testWidgets('a withdrawal at an approximate date, an unknown action, an '
        'unknown kind left out; nothing: « Aucun changement enregistré. »', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on(
          'GET',
          _history,
          PortalReply.json(
            jsonEncode({
              'items': [
                for (final (kind, action) in [
                  ('billing', 'withdrawn'),
                  ('marketing', 'renewed'),
                  ('newsletters', 'granted'),
                ])
                  {
                    'kind': kind,
                    'channel': 'email',
                    'action': action,
                    'at': '2020-07-01T12:00:00+00:00',
                    'source': 'system',
                    'author': 'Reprise',
                    'approximate': true,
                  },
              ],
              'nextCursor': null,
            }),
          ),
        );
      await pump(tester, backend);

      await openHistory(tester);

      expect(
        find.text('Retiré au plus tard le 1 juil. 2020 · Reprise'),
        findsOneWidget,
      );
      expect(find.text('1 juil. 2020 · Reprise'), findsOneWidget);
      expect(find.textContaining(' · Email'), findsNWidgets(2));

      Navigator.of(tester.element(find.text('Factures · Email'))).pop();
      await tester.pumpAndSettle();
      backend.on(
        'GET',
        _history,
        PortalReply.json('{"items":[],"nextCursor":null}'),
      );
      await openHistory(tester);

      expect(find.text('Aucun changement enregistré.'), findsOneWidget);
    });

    testWidgets('a first page of unknown kinds only: no empty card, no '
        '« Aucun changement », « Afficher plus » reads the next', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on(
          'GET',
          _history,
          PortalReply.json(
            jsonEncode({
              'items': [
                {
                  'kind': 'newsletters',
                  'channel': 'email',
                  'action': 'granted',
                  'at': '2026-11-03T12:00:00+00:00',
                  'source': 'portal',
                  'author': 'Zoé Essai',
                  'approximate': false,
                },
              ],
              'nextCursor': 'next',
            }),
          ),
        )
        ..on(
          'GET',
          '$_history?cursor=next',
          _reply('clinics.paris.consents.history.page2.get.200.json'),
        );
      await pump(tester, backend);

      await openHistory(tester);

      final sheet = find.byType(ConsentHistorySheet);
      expect(
        find.descendant(of: sheet, matching: find.byType(KivetoCard)),
        findsNothing,
      );
      expect(find.text('Aucun changement enregistré.'), findsNothing);
      expect(find.text('Afficher plus'), findsOneWidget);

      await tester.tap(find.text('Afficher plus'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: sheet, matching: find.byType(KivetoCard)),
        findsOneWidget,
      );
      expect(find.text('Actualités de la clinique · SMS'), findsOneWidget);
    });

    testWidgets('a failure: the error view and its retry; a next page that '
        'fails: an inline retry', (tester) async {
      final backend = _julienBackend()
        ..on('GET', _history, problem('service_unavailable', 503));
      await pump(tester, backend);

      await openHistory(tester);
      expect(find.text('Service indisponible'), findsOneWidget);

      final page1 = jsonDecode(
        _midday('clinics.paris.consents.history.page1.get.200.json'),
      ) as Map<String, Object?>;
      page1['nextCursor'] = 'next';
      backend
        ..on('GET', _history, PortalReply.json(jsonEncode(page1)))
        ..on(
          'GET',
          '$_history?cursor=next',
          problem('service_unavailable', 503),
        );
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.text('Retiré le 3 nov. 2026 · Zoé Essai'), findsNWidgets(2));

      await tester.tap(find.text('Afficher plus'));
      await tester.pumpAndSettle();

      // The rows stay; the failure and its retry under them.
      expect(find.text('Retiré le 3 nov. 2026 · Zoé Essai'), findsNWidgets(2));
      expect(
        find.text(
          'Le service rencontre un problème. Réessayez dans un instant.',
        ),
        findsOneWidget,
      );
      expect(find.text('Afficher plus'), findsNothing);

      backend.on(
        'GET',
        '$_history?cursor=next',
        _reply('clinics.paris.consents.history.page2.get.200.json'),
      );
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(find.text('Actualités de la clinique · SMS'), findsNWidgets(2));
      expect(
        find.text(
          'Le service rencontre un problème. Réessayez dans un instant.',
        ),
        findsNothing,
      );
    });
  });

  group('the data exports', () {
    testWidgets(
      'Marchand (capture): ready until when, expired; « Télécharger » '
      'hands the ZIP to the share sheet',
      (tester) async {
        final shared = <PortalFile>[];
        const signed = '/files/exports/$_readyId?_hash=x';
        final zip = utf8.encode('PK zip');
        final backend = _julienBackend()
          ..on('GET', _exports, _reply('me.data-exports.marchand.get.200.json'))
          ..on(
            'GET',
            '$_exports/$_readyId/file',
            PortalReply.empty(
              302,
              headers: {
                'location': ['http://portal.test$signed'],
              },
            ),
          )
          ..on(
            'GET',
            signed,
            PortalReply.bytes(
              zip,
              contentType: 'application/zip',
              headers: {
                'content-disposition': [
                  'attachment; filename="kiveto-export.zip"',
                ],
              },
            ),
          );
        await pump(
          tester,
          backend,
          overrides: [
            dataExportSharerProvider.overrideWithValue(
              (file) async => shared.add(file),
            ),
          ],
        );

        await open(tester, find.text('Exporter mes données'));

        expect(
          find.text(
            'Un fichier ZIP avec votre compte, vos cliniques, vos rendez-vous '
            'et la liste de vos documents, disponible 48\u00a0h.',
          ),
          findsOneWidget,
        );
        expect(find.text('Export du 2 nov. 2026'), findsOneWidget);
        expect(find.widgetWithText(StatusPill, 'Prêt'), findsOneWidget);
        expect(
          find.text(
            "Disponible jusqu'au 4 nov. à "
            '${_localTime(DateTime.utc(2026, 11, 4, 12))}',
          ),
          findsOneWidget,
        );
        expect(find.text('Export du 27 oct. 2026'), findsOneWidget);
        expect(find.widgetWithText(StatusPill, 'Expiré'), findsOneWidget);
        expect(find.text('Actualiser'), findsNothing);
        expect(find.text('Télécharger'), findsOneWidget);

        await tester.tap(find.text('Télécharger'));
        await tester.pumpAndSettle();

        expect(shared.single.bytes, zip);
        expect(shared.single.fileName, 'kiveto-export.zip');
        expect(shared.single.contentType, 'application/zip');
      },
    );

    testWidgets('a gone export: « plus disponible », the list reloads; '
        'another failure: « Impossible de télécharger »', (tester) async {
      final backend = _julienBackend()
        ..on('GET', _exports, _reply('me.data-exports.marchand.get.200.json'))
        ..on('GET', '$_exports/$_readyId/file', problem('not_found', 404));
      await pump(
        tester,
        backend,
        overrides: [dataExportSharerProvider.overrideWithValue((_) async {})],
      );
      await open(tester, find.text('Exporter mes données'));

      await tester.tap(find.text('Télécharger'));
      await tester.pumpAndSettle();

      expect(find.text("Cet export n'est plus disponible."), findsOneWidget);
      expect(_gets(backend, _exports), 2);

      backend.on(
        'GET',
        '$_exports/$_readyId/file',
        problem('service_unavailable', 503),
      );
      await tester.tap(find.text('Télécharger'));
      await tester.pumpAndSettle();

      expect(
        find.text('Impossible de télécharger cet export.'),
        findsOneWidget,
      );
      expect(find.text("Cet export n'est plus disponible."), findsNothing);
    });

    testWidgets('each action clears the lines of the other: a request after '
        'a failed download, a download after a refused request', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on('GET', _exports, _reply('me.data-exports.marchand.get.200.json'))
        ..on(
          'GET',
          '$_exports/$_readyId/file',
          problem('service_unavailable', 503),
        )
        ..on(
          'POST',
          '$api/me/data-export',
          PortalReply.fixture('me.data-export.post.429.json', status: 429),
        );
      await pump(
        tester,
        backend,
        overrides: [dataExportSharerProvider.overrideWithValue((_) async {})],
      );
      await open(tester, find.text('Exporter mes données'));
      const failed = 'Impossible de télécharger cet export.';
      const quota = 'Vous avez déjà demandé un export ces dernières 24 heures.';

      await tester.tap(find.text('Télécharger'));
      await tester.pumpAndSettle();
      expect(find.text(failed), findsOneWidget);

      await tester.tap(find.text('Demander un export'));
      await tester.pumpAndSettle();
      expect(find.text(quota), findsOneWidget);
      expect(find.text(failed), findsNothing);

      await tester.tap(find.text('Télécharger'));
      await tester.pumpAndSettle();
      expect(find.text(failed), findsOneWidget);
      expect(find.text(quota), findsNothing);

      backend.on(
        'POST',
        '$api/me/data-export',
        PortalReply.fixture('me.data-export.post.202.json', status: 202),
      );
      await tester.tap(find.text('Demander un export'));
      await tester.pumpAndSettle();
      expect(
        find.text('Export demandé : il sera prêt dans quelques minutes.'),
        findsOneWidget,
      );
      expect(find.text(failed), findsNothing);

      await tester.tap(find.text('Télécharger'));
      await tester.pumpAndSettle();
      expect(
        find.text('Export demandé : il sera prêt dans quelques minutes.'),
        findsNothing,
      );
    });

    testWidgets("none: « Aucun export pour l'instant. »; requested: the "
        'notice, the pending export, « Actualiser » until it is ready', (
      tester,
    ) async {
      final backend = _julienBackend();
      backend
        ..on(
          'GET',
          _exports,
          PortalReply.fixture('me.data-exports.get.200.json'),
        )
        ..onRequest('POST', '$api/me/data-export', (_) {
          backend.on(
            'GET',
            _exports,
            _reply('me.data-exports.pending.get.200.json'),
          );
          return PortalReply.fixture(
            'me.data-export.post.202.json',
            status: 202,
          );
        });
      await pump(tester, backend);
      await open(tester, find.text('Exporter mes données'));

      expect(find.text("Aucun export pour l'instant."), findsOneWidget);

      await tester.tap(find.text('Demander un export'));
      await tester.pumpAndSettle();

      expect(
        find.text('Export demandé\u00a0: il sera prêt dans quelques minutes.'),
        findsOneWidget,
      );
      expect(find.text('Export du 3 nov. 2026'), findsOneWidget);
      expect(find.widgetWithText(StatusPill, 'En préparation'), findsOneWidget);
      expect(find.text('Télécharger'), findsNothing);

      backend.on('GET', _exports, _reply('me.data-exports.ready.get.200.json'));
      await tester.tap(find.text('Actualiser'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(StatusPill, 'Prêt'), findsOneWidget);
      expect(find.text('Actualiser'), findsNothing);
      expect(_gets(backend, _exports), 3);
    });

    testWidgets('the quota (capture): its message; another failure: its '
        'body; a failed export and an unknown status', (tester) async {
      final backend = _julienBackend()
        ..on(
          'GET',
          _exports,
          PortalReply.json(
            jsonEncode([
              for (final status in ['failed', 'archived'])
                {
                  'id': status,
                  'status': status,
                  'requestedAt': '2026-11-01T12:00:00+00:00',
                  'readyAt': null,
                  'expiresAt': null,
                },
            ]),
          ),
        )
        ..on(
          'POST',
          '$api/me/data-export',
          PortalReply.fixture(
            'me.data-export.post.429.json',
            status: 429,
            headers: {
              'retry-after': ['86400'],
            },
          ),
        );
      await pump(tester, backend);
      await open(tester, find.text('Exporter mes données'));

      expect(find.widgetWithText(StatusPill, 'Échec'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DataExportSheet),
          matching: find.byType(StatusPill),
        ),
        findsOneWidget,
      );
      expect(find.text('Export du 1 nov. 2026'), findsNWidgets(2));

      await tester.tap(find.text('Demander un export'));
      await tester.pumpAndSettle();
      expect(
        find.text('Vous avez déjà demandé un export ces dernières 24 heures.'),
        findsOneWidget,
      );

      backend.on(
        'POST',
        '$api/me/data-export',
        problem('service_unavailable', 503),
      );
      await tester.tap(find.text('Demander un export'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Le service rencontre un problème. Réessayez dans un instant.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the list in error: the error view and its retry', (
      tester,
    ) async {
      final backend = _julienBackend()
        ..on('GET', _exports, problem('service_unavailable', 503));
      await pump(tester, backend);
      await open(tester, find.text('Exporter mes données'));

      expect(find.text('Service indisponible'), findsOneWidget);

      backend.on(
        'GET',
        _exports,
        PortalReply.fixture('me.data-exports.get.200.json'),
      );
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.text("Aucun export pour l'instant."), findsOneWidget);
    });
  });

  test('the sharer seam is a function', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(dataExportSharerProvider), isA<Function>());
  });

  testWidgets('a slow download: its button loading, the others wait', (
    tester,
  ) async {
    final answer = Completer<PortalReply>();
    final backend = _julienBackend()
      ..on('GET', _exports, _reply('me.data-exports.marchand.get.200.json'))
      ..onRequest('GET', '$_exports/$_readyId/file', (_) => answer.future);
    await pump(
      tester,
      backend,
      overrides: [dataExportSharerProvider.overrideWithValue((_) async {})],
    );
    await open(tester, find.text('Exporter mes données'));

    await tester.tap(find.text('Télécharger'));
    await tester.pump();

    expect(
      tester
          .widget<KivetoButton>(
            find.widgetWithText(KivetoButton, 'Télécharger'),
          )
          .loading,
      isTrue,
    );
    answer.complete(PortalReply.bytes(const [1, 2]));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<KivetoButton>(
            find.widgetWithText(KivetoButton, 'Télécharger'),
          )
          .loading,
      isFalse,
    );
  });
}
