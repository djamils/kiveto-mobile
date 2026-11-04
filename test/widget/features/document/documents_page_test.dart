// Screen 5 on the fake backend and the captures: Julien's Paris invoices,
// Lyon's empty list, Garnier's pages and prescriptions, the filters, the
// meta lines, the renewal controls, opening a file (the badge follows /me,
// the dot goes), the link gone, a clinic switch.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/document/presentation/document_card.dart';
import 'package:kiveto_mobile/features/document/presentation/documents_providers.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _lyon = '01960000-0000-7000-8000-000000000101';
const _julien = '01a19a10-d011-70c8-8daf-26e4db824374';
const _me = '$api/me';
const _documents = '$api/clinics/$_paris/documents';
const _pets = '$api/clinics/$_paris/pets';
const _invoice67 = '01a19a12-65aa-78e6-b439-fe4e297698d8';

/// The `nextCursor` of a capture.
String _cursorOf(String fixture) =>
    (jsonDecode(File('$portalFixtures/$fixture').readAsStringSync())
            as Map<String, Object?>)['nextCursor']!
        as String;

/// `GET /me` of Julien with [unread] unread documents in Paris.
PortalReply _meWith(int unread) {
  final body = jsonDecode(
    File('$portalFixtures/me.get.200.json').readAsStringSync(),
  ) as Map<String, Object?>;
  ((body['clinics']! as List<Object?>).first!
          as Map<String, Object?>)['unreadDocuments'] =
      unread;
  return PortalReply.json(jsonEncode(body));
}

/// Julien's Paris capture with a newer (read) invoice first, « Facture
/// PAR-2026-000068 »: a document published after the first load.
PortalReply _withNewInvoice() {
  final body = jsonDecode(
    File('$portalFixtures/clinics.paris.documents.get.200.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;
  final items = body['items']! as List<Object?>;
  body['items'] = [
    {
      ...items.first! as Map<String, Object?>,
      'id': '01a19a12-ffff-7000-8000-000000000068',
      'title': 'Facture PAR-2026-000068',
      'unread': false,
    },
    ...items,
  ];
  return PortalReply.json(jsonEncode(body));
}

/// Julien signed in, Paris active: his invoices and Oslo.
FakePortalBackend _julienBackend() => FakePortalBackend()
  ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    _documents,
    PortalReply.fixture('clinics.paris.documents.get.200.json'),
  )
  ..on('GET', _pets, PortalReply.fixture('clinics.paris.pets.get.200.json'));

/// Garnier's documents and pets served for Paris.
FakePortalBackend _garnierBackend() => FakePortalBackend()
  ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    _documents,
    PortalReply.fixture('clinics.paris.documents.garnier.get.200.json'),
  )
  ..on(
    'GET',
    _pets,
    PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
  );

/// A PDF view without PDFium: the size of what it received.
Widget _fakePdfView(BuildContext context, List<int> bytes, String source) =>
    Center(child: Text('pdf:${bytes.length}'));

final Uint8List _pdfBytes = File('$portalFixtures/files.documents.get.200.pdf')
    .readAsBytesSync();

/// The file of [documentId] in Paris: its 302, then the capture's PDF.
void _serveFile(FakePortalBackend backend, String documentId) {
  final signed = '/files/documents/$documentId?_hash=x';
  backend
    ..on(
      'GET',
      '$_documents/$documentId/file',
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
      PortalReply.bytes(_pdfBytes, contentType: 'application/pdf'),
    );
}

Finder _card(String title) => find.ancestor(
  // textContaining: the title is matched within its text.
  of: find.textContaining(title),
  matching: find.byType(DocumentCard),
);

Finder _dotOf(String title) =>
    find.descendant(of: _card(title), matching: find.byType(UnreadDot));

int _items(ProviderContainer container, [DocumentKind? kind]) =>
    switch (container.read(documentListProvider(kind))) {
      AsyncData(:final value) => value.items.length,
      _ => -1,
    };

void main() {
  late List<String> renewals;

  setUp(() => renewals = []);

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    InMemoryActiveClinicStore? store,
    SessionManager? session,
  }) async {
    final signedIn = session ?? await memorySession(pair('A'));
    return await pumpPage(
      tester,
      DocumentsPage(onRequestRenewal: (context, id) => renewals.add(id)),
      session: signedIn,
      backend: backend,
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          store ?? InMemoryActiveClinicStore(),
        ),
        pdfViewBuilderProvider.overrideWithValue(_fakePdfView),
      ],
    );
  }

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -20000));
    await tester.pumpAndSettle();
  }

  testWidgets('Julien, Paris: the header, both invoices with their total, '
      'payment and day; the first one unread', (tester) async {
    await pump(tester, _julienBackend());

    expect(find.text('Documents'), findsOneWidget);
    expect(
      find.text('Partagés par Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
    for (final chip in [
      'Tous',
      'Comptes-rendus',
      'Ordonnances',
      'Factures',
      'Résultats',
    ]) {
      expect(find.widgetWithText(KivetoFilterChip, chip), findsOneWidget);
    }
    expect(
      tester
          .widget<KivetoFilterChip>(
            find.widgetWithText(KivetoFilterChip, 'Tous'),
          )
          .selected,
      isTrue,
    );
    expect(find.byType(DocumentCard), findsNWidgets(2));
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
    expect(find.text('52,00 € · Payée · 24 oct.'), findsOneWidget);
    expect(find.text('Facture PAR-2026-000066'), findsOneWidget);
    expect(find.text('78,00 € · Payée · 5 sept.'), findsOneWidget);
    expect(find.text('€'), findsNWidgets(2));
    expect(_dotOf('Facture PAR-2026-000067'), findsOneWidget);
    expect(_dotOf('Facture PAR-2026-000066'), findsNothing);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Nouveau'), findsOneWidget);
    // Each open button says which document it opens.
    expect(
      find.bySemanticsLabel('Ouvrir Facture PAR-2026-000067'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Ouvrir Facture PAR-2026-000066'),
      findsOneWidget,
    );
    semantics.dispose();
    // An invoice has no renewal control.
    expect(find.text('Demander un renouvellement'), findsNothing);
  });

  testWidgets('Lyon: the empty state names the clinic', (tester) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        '$api/clinics/$_lyon/documents',
        PortalReply.fixture('clinics.lyon.documents.get.200.json'),
      )
      ..on(
        'GET',
        '$api/clinics/$_lyon/pets',
        PortalReply.fixture('clinics.lyon.pets.get.200.json'),
      );

    await pump(
      tester,
      backend,
      store: InMemoryActiveClinicStore(choices: {_julien: _lyon}),
    );

    expect(
      find.text('Partagés par Clinique Vétérinaire de Lyon'),
      findsOneWidget,
    );
    expect(find.text('Aucun document'), findsOneWidget);
    expect(
      find.text(
        'Les documents partagés par Clinique Vétérinaire de Lyon '
        'apparaîtront ici.',
      ),
      findsOneWidget,
    );
    expect(backend.requestsTo(_documents), isEmpty);
  });

  testWidgets('Garnier: 20, 40, then 51 cards as the list scrolls; no '
      'request after the last page', (tester) async {
    final cursor1 = _cursorOf('clinics.paris.documents.garnier.get.200.json');
    final cursor2 = _cursorOf(
      'clinics.paris.documents.garnier-page2.get.200.json',
    );
    final backend = _garnierBackend()
      ..on(
        'GET',
        '$_documents?cursor=$cursor1',
        PortalReply.fixture(
          'clinics.paris.documents.garnier-page2.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_documents?cursor=$cursor2',
        PortalReply.fixture(
          'clinics.paris.documents.garnier-page3.get.200.json',
        ),
      );
    final container = await pump(tester, backend);
    expect(_items(container), 20);
    expect(
      backend.requests.where((r) => r.uri.path == _documents),
      hasLength(1),
    );

    await scrollToEnd(tester);
    expect(_items(container), 40);

    await scrollToEnd(tester);
    expect(_items(container), 51);

    await scrollToEnd(tester);
    expect(find.text('Compte rendu du 18/11/2023'), findsOneWidget);
    expect(_items(container), 51);
    expect(
      backend.requests
          .where((r) => r.uri.path == _documents)
          .map((r) => r.pathWithQuery),
      [
        _documents,
        '$_documents?cursor=$cursor1',
        '$_documents?cursor=$cursor2',
      ],
    );
  });

  testWidgets('a next page that fails keeps the items, says so and retries', (
    tester,
  ) async {
    final cursor1 = _cursorOf('clinics.paris.documents.garnier.get.200.json');
    final backend = _garnierBackend()
      ..on(
        'GET',
        '$_documents?cursor=$cursor1',
        PortalReply.json('{"type":"service_unavailable"}', status: 503),
      );
    final container = await pump(tester, backend);

    await scrollToEnd(tester);

    expect(_items(container), 20);
    expect(find.text('Impossible de charger la suite.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(backend.requestsTo('$_documents?cursor=$cursor1'), hasLength(1));

    backend.on(
      'GET',
      '$_documents?cursor=$cursor1',
      PortalReply.fixture('clinics.paris.documents.garnier-page2.get.200.json'),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(_items(container), 40);
    expect(find.text('Impossible de charger la suite.'), findsNothing);
  });

  testWidgets('400 cursor_invalid reloads the list from its first page', (
    tester,
  ) async {
    final cursor1 = _cursorOf('clinics.paris.documents.garnier.get.200.json');
    var stale = true;
    final backend = _garnierBackend()
      ..onRequest('GET', '$_documents?cursor=$cursor1', (request) {
        if (stale) {
          stale = false;
          return PortalReply.fixture(
            'clinics.paris.documents.cursor-invalid.get.400.json',
            status: 400,
          );
        }
        return PortalReply.fixture(
          'clinics.paris.documents.garnier-page2.get.200.json',
        );
      });
    final container = await pump(tester, backend);

    await scrollToEnd(tester);
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_documents), hasLength(2));
    expect(backend.requestsTo('$_documents?cursor=$cursor1'), hasLength(2));
    expect(_items(container), 40);
    expect(find.text('Impossible de charger la suite.'), findsNothing);
  });

  testWidgets('the filters: ?type=prescription, five cards; « Tous » again '
      'is the list kept; an empty filter has its own title', (tester) async {
    final backend = _garnierBackend()
      ..on(
        'GET',
        '$_documents?type=prescription',
        PortalReply.fixture(
          'clinics.paris.documents.prescriptions.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_documents?type=lab_result',
        PortalReply.fixture('clinics.lyon.documents.get.200.json'),
      );
    final container = await pump(tester, backend);

    await tester.tap(find.text('Ordonnances'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo('$_documents?type=prescription'), hasLength(1));
    expect(_items(container, DocumentKind.prescription), 5);
    expect(find.textContaining('Ordonnance ORD-2026-000036'), findsOneWidget);
    expect(find.textContaining('Compte rendu du 31/08/2026'), findsNothing);
    expect(find.text('Rx'), findsWidgets);

    await tester.tap(find.text('Tous'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Compte rendu du 31/08/2026'), findsOneWidget);
    expect(backend.requestsTo(_documents), hasLength(1));

    await tester.tap(find.text('Résultats'));
    await tester.pumpAndSettle();

    expect(find.text("Aucun résultat d'analyse"), findsOneWidget);
    expect(
      find.text(
        'Les documents partagés par Clinique Vétérinaire de Paris '
        'apparaîtront ici.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the meta lines: pets and date, validity, total and payment '
      '(invoices never name the pets)', (tester) async {
    await pump(tester, _garnierBackend());

    expect(find.text("Pepito · valable jusqu'au 2 nov. 2027"), findsOneWidget);
    expect(find.text('96,00 € · Non payée · 31 août'), findsOneWidget);
    expect(find.text('Pepito · 31 août 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Oscar · 18 août 2026'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Facture PAR-2026-000022'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('138,80 € · Payée · 10 juil.'), findsOneWidget);
  });

  testWidgets('the pet names cannot be read: the meta lines go without', (
    tester,
  ) async {
    final backend = _garnierBackend()
      ..on('GET', _pets, problem('not_found', 404));

    await pump(tester, backend);

    expect(find.text("valable jusqu'au 2 nov. 2027"), findsOneWidget);
    expect(find.text('31 août 2026'), findsOneWidget);
    expect(find.textContaining('Pepito'), findsNothing);
  });

  testWidgets('the renewal controls follow the server: a button (none, '
      'rejected), « demandé » (submitted), « traité » (done)', (tester) async {
    final backend = _garnierBackend()
      ..on(
        'GET',
        _documents,
        PortalReply.fixture(
          'clinics.paris.documents.prescriptions.get.200.json',
        ),
      );
    await pump(tester, backend);
    await tester.scrollUntilVisible(
      find.text('Ordonnance ORD-2026-000005'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Demander un renouvellement'), findsNWidgets(2));
    expect(find.text('Renouvellement traité'), findsNWidgets(2));
    expect(find.text('Renouvellement demandé'), findsOneWidget);
    expect(
      find.descendant(
        of: _card('Ordonnance ORD-2026-000005'),
        matching: find.widgetWithText(StatusPill, 'Renouvellement demandé'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: _card('Ordonnance ORD-2026-000007'),
        matching: find.text('Demander un renouvellement'),
      ),
    );
    await tester.pumpAndSettle();

    expect(renewals, ['01a19a10-6293-72cf-accb-5def9186a59b']);
  });

  testWidgets('the open button: the PDF over the page, /me read again, the '
      'dot gone; the list not reloaded', (tester) async {
    final backend = _julienBackend();
    _serveFile(backend, _invoice67);
    await pump(tester, backend);
    expect(backend.requestsTo(_me), hasLength(1));

    await tester.tap(
      find.descendant(
        of: _card('Facture PAR-2026-000067'),
        matching: find.bySemanticsLabel('Ouvrir Facture PAR-2026-000067'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PdfFilePage), findsOneWidget);
    expect(find.text('pdf:${_pdfBytes.length}'), findsOneWidget);
    expect(backend.requestsTo('$_documents/$_invoice67/file'), hasLength(1));
    expect(backend.requestsTo(_me), hasLength(2));

    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();

    expect(find.byType(PdfFilePage), findsNothing);
    expect(_dotOf('Facture PAR-2026-000067'), findsNothing);
    expect(backend.requestsTo(_documents), hasLength(1));
  });

  testWidgets('a tap on a card that is no prescription opens its file', (
    tester,
  ) async {
    final backend = _julienBackend();
    _serveFile(backend, '01a19a12-6573-7e17-b233-c8c4a13d9ee8');
    await pump(tester, backend);

    await tester.tap(find.text('Facture PAR-2026-000066'));
    await tester.pumpAndSettle();

    expect(find.byType(PdfFilePage), findsOneWidget);
    expect(find.text('Facture PAR-2026-000066'), findsWidgets);
  });

  testWidgets('read from a filter: the dot goes from « Tous » as well', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        '$_documents?type=invoice',
        PortalReply.fixture('clinics.paris.documents.get.200.json'),
      );
    _serveFile(backend, _invoice67);
    await pump(tester, backend);
    await tester.tap(find.text('Factures'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Facture PAR-2026-000067'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    expect(_dotOf('Facture PAR-2026-000067'), findsNothing);

    await tester.tap(find.text('Tous'));
    await tester.pumpAndSettle();

    expect(_dotOf('Facture PAR-2026-000067'), findsNothing);
    expect(backend.requestsTo(_documents), hasLength(1));
  });

  testWidgets('the link is gone (404): its own message; the retry reads /me '
      'and the list again', (tester) async {
    final backend = _julienBackend()
      ..on('GET', _documents, problem('not_found', 404));
    await pump(tester, backend);

    expect(find.text('Documents indisponibles'), findsOneWidget);
    expect(
      find.text(
        "Votre accès aux documents de cette clinique n'est plus actif.",
      ),
      findsOneWidget,
    );

    backend.on(
      'GET',
      _documents,
      PortalReply.fixture('clinics.paris.documents.get.200.json'),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_me), hasLength(2));
    expect(backend.requestsTo(_documents), hasLength(2));
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
  });

  testWidgets('another failure: the generic error and a retry of the list', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on('GET', _documents, problem('service_unavailable', 503));
    await pump(tester, backend);

    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Documents indisponibles'), findsNothing);

    backend.on(
      'GET',
      _documents,
      PortalReply.fixture('clinics.paris.documents.get.200.json'),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_me), hasLength(1));
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
  });

  testWidgets('/me failed: the retry reads /me again, then the list', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on('GET', _me, problem('service_unavailable', 503));
    await pump(tester, backend);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(backend.requestsTo(_documents), isEmpty);

    backend.on('GET', _me, PortalReply.fixture('me.get.200.json'));
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
  });

  testWidgets('the active clinic switches to Lyon: its list, its empty state', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        '$api/clinics/$_lyon/documents',
        PortalReply.fixture('clinics.lyon.documents.get.200.json'),
      )
      ..on(
        'GET',
        '$api/clinics/$_lyon/pets',
        PortalReply.fixture('clinics.lyon.pets.get.200.json'),
      );
    final container = await pump(tester, backend);
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);

    unawaited(
      container
          .read(activeClinicProvider.notifier)
          .select(const ClinicId(_lyon)),
    );
    await tester.pumpAndSettle();

    expect(backend.requestsTo('$api/clinics/$_lyon/documents'), hasLength(1));
    expect(find.textContaining('Facture PAR-2026-000067'), findsNothing);
    expect(
      find.text('Partagés par Clinique Vétérinaire de Lyon'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Les documents partagés par Clinique Vétérinaire de Lyon '
        'apparaîtront ici.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('in the app: the Documents badge follows /me once the unread '
      'invoice is opened', (tester) async {
    var meCalls = 0;
    final backend = _julienBackend()
      ..onRequest('GET', _me, (request) => _meWith(meCalls++ == 0 ? 1 : 0));
    _serveFile(backend, _invoice67);
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      overrides: [pdfViewBuilderProvider.overrideWithValue(_fakePdfView)],
      initialLocation: AppRoutes.home,
    );
    expect(container.read(unreadDocumentsCountProvider), 1);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Documents').last);
    await tester.pumpAndSettle();
    expect(find.byType(DocumentsPage), findsOneWidget);

    await tester.tap(find.textContaining('Facture PAR-2026-000067'));
    await tester.pumpAndSettle();

    expect(find.byType(PdfFilePage), findsOneWidget);
    // Over the bottom navigation.
    expect(find.text('Accueil'), findsNothing);
    expect(backend.requestsTo(_me), hasLength(2));
    expect(container.read(unreadDocumentsCountProvider), 0);

    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);
    expect(backend.requestsTo(_documents), hasLength(1));
  });

  Future<void> pull(WidgetTester tester) async {
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('pull to refresh: the first page again, a new document shows', (
    tester,
  ) async {
    final backend = _julienBackend();
    await pump(tester, backend);
    expect(find.text('Facture PAR-2026-000068'), findsNothing);

    backend.on('GET', _documents, _withNewInvoice());

    await pull(tester);

    expect(backend.requestsTo(_documents), hasLength(2));
    expect(backend.requestsTo(_me), hasLength(2));
    expect(find.text('Facture PAR-2026-000068'), findsOneWidget);
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
  });

  testWidgets('the pet names failed: the lines go without them; a refresh '
      'reads them again', (tester) async {
    final backend = _garnierBackend()
      ..on('GET', _pets, problem('service_unavailable', 503));
    await pump(tester, backend);
    expect(find.text('31 août 2026'), findsOneWidget);

    backend.on(
      'GET',
      _pets,
      PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
    );
    await pull(tester);

    expect(backend.requestsTo(_pets), hasLength(2));
    expect(find.text('Pepito · 31 août 2026'), findsOneWidget);
  });

  testWidgets('an empty first page with a next one reads on', (tester) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        _documents,
        PortalReply.json('{"items":[],"nextCursor":"c1"}'),
      )
      ..on(
        'GET',
        '$_documents?cursor=c1',
        PortalReply.fixture('clinics.paris.documents.get.200.json'),
      );

    await pump(tester, backend);

    expect(find.text('Aucun document'), findsNothing);
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
    expect(backend.requestsTo('$_documents?cursor=c1'), hasLength(1));
  });

  testWidgets('another session: the list is read again with its tokens', (
    tester,
  ) async {
    final session = await memorySession(pair('A'));
    final backend = _julienBackend()
      ..onRequest(
        'GET',
        _documents,
        (request) => bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('clinics.paris.documents.get.200.json')
            : PortalReply.fixture('clinics.lyon.documents.get.200.json'),
      );
    await pump(tester, backend, session: session);
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);

    await session.open(pair('B'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Facture PAR-2026-000067'), findsNothing);
    expect(bearerOf(backend.requestsTo(_documents).last), 'Bearer B');
  });

  testWidgets('a next page answering after a clinic switch is dropped', (
    tester,
  ) async {
    final cursor1 = _cursorOf('clinics.paris.documents.garnier.get.200.json');
    final held = Completer<void>();
    final backend = _garnierBackend()
      ..onRequest('GET', '$_documents?cursor=$cursor1', (request) async {
        await held.future;
        return PortalReply.fixture(
          'clinics.paris.documents.garnier-page2.get.200.json',
        );
      })
      ..on(
        'GET',
        '$api/clinics/$_lyon/documents',
        PortalReply.fixture('clinics.lyon.documents.get.200.json'),
      )
      ..on(
        'GET',
        '$api/clinics/$_lyon/pets',
        PortalReply.fixture('clinics.lyon.pets.get.200.json'),
      );
    final container = await pump(tester, backend);
    // The next page is on its way (a spinner: no pumpAndSettle).
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -20000));
    await pumpBriefly(tester);
    expect(backend.requestsTo('$_documents?cursor=$cursor1'), hasLength(1));

    unawaited(
      container
          .read(activeClinicProvider.notifier)
          .select(const ClinicId(_lyon)),
    );
    await tester.pumpAndSettle();
    held.complete();
    await tester.pumpAndSettle();

    expect(find.text('Aucun document'), findsOneWidget);
    expect(find.textContaining('Compte rendu'), findsNothing);
    expect(find.textContaining('Ordonnance ORD'), findsNothing);
    expect(find.textContaining('Facture PAR'), findsNothing);
  });

  testWidgets('a retry in flight shows the loading view, not the error and '
      'its retry', (tester) async {
    var calls = 0;
    final held = Completer<void>();
    final backend = _julienBackend()
      ..onRequest('GET', _documents, (request) async {
        if (calls++ == 0) return problem('service_unavailable', 503);
        await held.future;
        return PortalReply.fixture('clinics.paris.documents.get.200.json');
      });
    await pump(tester, backend);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);

    held.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining('Facture PAR-2026-000067'), findsOneWidget);
  });

  testWidgets('a document opened from another page (the home) loses its dot '
      'in the documents list too', (tester) async {
    final backend = _julienBackend();
    _serveFile(backend, _invoice67);
    await pumpPage(
      tester,
      Scaffold(
        body: Column(
          children: [
            Expanded(child: DocumentsPage(onRequestRenewal: (context, id) {})),
            Builder(
              builder: (context) => KivetoButton.primary(
                label: 'home',
                onPressed: () => unawaited(
                  openDocumentFile(
                    context,
                    clinicId: const ClinicId(_paris),
                    documentId: const DocumentId(_invoice67),
                    title: 'Facture PAR-2026-000067',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      session: await memorySession(pair('A')),
      backend: backend,
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        pdfViewBuilderProvider.overrideWithValue(_fakePdfView),
      ],
    );
    expect(_dotOf('Facture PAR-2026-000067'), findsOneWidget);

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.byType(PdfFilePage), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();

    expect(_dotOf('Facture PAR-2026-000067'), findsNothing);
    expect(backend.requestsTo(_documents), hasLength(1));
  });

  testWidgets('another session: the pet names are read again with its '
      'tokens', (tester) async {
    final session = await memorySession(pair('A'));
    final renamed = File(
      '$portalFixtures/clinics.paris.pets.garnier.get.200.json',
    ).readAsStringSync().replaceAll('Pepito', 'Pipo');
    final backend = _garnierBackend()
      ..onRequest(
        'GET',
        _pets,
        (request) => bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('clinics.paris.pets.garnier.get.200.json')
            : PortalReply.json(renamed),
      );
    await pump(tester, backend, session: session);
    expect(find.text('Pepito · 31 août 2026'), findsOneWidget);

    await session.open(pair('B'));
    await tester.pumpAndSettle();

    expect(bearerOf(backend.requestsTo(_pets).last), 'Bearer B');
    expect(find.text('Pipo · 31 août 2026'), findsOneWidget);
  });

  testWidgets('the retry reads the pet names again', (tester) async {
    final backend = _garnierBackend()
      ..on('GET', _documents, problem('service_unavailable', 503))
      ..on('GET', _pets, problem('service_unavailable', 503));
    await pump(tester, backend);
    expect(find.text('Réessayer'), findsOneWidget);

    backend
      ..on(
        'GET',
        _documents,
        PortalReply.fixture('clinics.paris.documents.garnier.get.200.json'),
      )
      ..on(
        'GET',
        _pets,
        PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
      );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_pets), hasLength(2));
    expect(find.text('Pepito · 31 août 2026'), findsOneWidget);
  });

  testWidgets('a document read keeps the pages to come', (tester) async {
    final cursor1 = _cursorOf('clinics.paris.documents.garnier.get.200.json');
    final backend = _garnierBackend()
      ..on(
        'GET',
        '$_documents?cursor=$cursor1',
        PortalReply.fixture(
          'clinics.paris.documents.garnier-page2.get.200.json',
        ),
      );
    _serveFile(backend, '01a19a12-5e9c-79ba-b135-8b49222892b6');
    final container = await pump(tester, backend);
    expect(_dotOf('Facture PAR-2026-000025'), findsOneWidget);

    await tester.tap(find.textContaining('Facture PAR-2026-000025'));
    await tester.pumpAndSettle();
    expect(find.byType(PdfFilePage), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    expect(_dotOf('Facture PAR-2026-000025'), findsNothing);

    await scrollToEnd(tester);

    expect(_items(container), 40);
    expect(backend.requestsTo('$_documents?cursor=$cursor1'), hasLength(1));
  });

  testWidgets('pull to refresh reloads every filter, the hidden ones too', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        '$_documents?type=invoice',
        PortalReply.fixture('clinics.paris.documents.get.200.json'),
      );
    await pump(tester, backend);
    await tester.tap(find.text('Factures'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tous'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo('$_documents?type=invoice'), hasLength(1));

    backend.on('GET', '$_documents?type=invoice', _withNewInvoice());
    await pull(tester);
    await tester.tap(find.text('Factures'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo('$_documents?type=invoice'), hasLength(2));
    expect(find.text('Facture PAR-2026-000068'), findsOneWidget);
  });
}
