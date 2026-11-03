// The prescription sheet of screen 5, on the captures: ORD-05's date, vet,
// pet and line, « Voir l'ordonnance », the renewal control, the 404 and the
// other failures.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/document/presentation/document_card.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/features/document/presentation/prescription_sheet.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _documents = '$api/clinics/$_paris/documents';
const _prescriptions = '$api/clinics/$_paris/prescriptions';
const _ord05 = '01a19a10-3d12-7911-83f9-9050f5a06273';
const _ord05Document = '01a19a12-5eb3-7749-a364-be83f658ee76';
const _ord36 = '01a19a12-8b44-7c87-b043-5d82ad91c574';

Widget _fakePdfView(BuildContext context, List<int> bytes, String source) =>
    Center(child: Text('pdf:${bytes.length}'));

/// Garnier's prescriptions as the list of Paris.
FakePortalBackend _backend() => FakePortalBackend()
  ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    _documents,
    PortalReply.fixture('clinics.paris.documents.prescriptions.get.200.json'),
  )
  ..on(
    'GET',
    '$api/clinics/$_paris/pets',
    PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
  );

void main() {
  late List<String> renewals;

  setUp(() => renewals = []);

  Future<void> pump(WidgetTester tester, FakePortalBackend backend) async {
    await pumpPage(
      tester,
      Builder(
        builder: (context) => DocumentsPage(
          onRequestRenewal: (context, id) {
            // The page's context, still mounted: the sheet is closed.
            expect(context.mounted, isTrue);
            renewals.add(id);
          },
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
  }

  Future<void> showCard(WidgetTester tester, String title) =>
      tester.scrollUntilVisible(
        find.textContaining(title),
        300,
        scrollable: find.byType(Scrollable).first,
      );

  Future<void> openCard(WidgetTester tester, String title) async {
    await showCard(tester, title);
    await tester.tap(find.textContaining(title));
    await tester.pumpAndSettle();
  }

  testWidgets('ORD-05: its date, vet, pet and line; « Renouvellement '
      "demandé »; « Voir l'ordonnance » over the sheet", (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_prescriptions/$_ord05',
        PortalReply.fixture('clinics.paris.prescriptions.get.200.json'),
      )
      ..on(
        'GET',
        '$_documents/$_ord05Document/file',
        PortalReply.bytes(const [1, 2], contentType: 'application/pdf'),
      );
    await pump(tester, backend);

    await openCard(tester, 'Ordonnance ORD-2026-000005');

    final sheet = find.byType(PrescriptionSheet);
    expect(sheet, findsOneWidget);
    Finder inSheet(Finder finder) =>
        find.descendant(of: sheet, matching: finder);
    expect(inSheet(find.text('Ordonnance du 22 déc. 2025')), findsOneWidget);
    expect(inSheet(find.text('Dr Rousseau · Oscar')), findsOneWidget);
    expect(
      inSheet(find.text('Meloxidyl 1 mg/mL suspension buvable')),
      findsOneWidget,
    );
    expect(
      inSheet(
        find.text('Qté 2 · 0,1 mg/kg, 1×/j, pendant 60 jours, voie per os'),
      ),
      findsOneWidget,
    );
    expect(inSheet(find.text('Renouvellement demandé')), findsOneWidget);
    expect(inSheet(find.text('Demander un renouvellement')), findsNothing);

    await tester.tap(inSheet(find.text("Voir l'ordonnance")));
    await tester.pumpAndSettle();

    expect(find.byType(PdfFilePage), findsOneWidget);
    expect(find.text('pdf:2'), findsOneWidget);
    expect(
      backend.requestsTo('$_documents/$_ord05Document/file'),
      hasLength(1),
    );

    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    expect(find.byType(PrescriptionSheet), findsOneWidget);
  });

  testWidgets('ORD-36 (renewable, no request): the button closes the sheet '
      'and asks for screen 17', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_prescriptions/$_ord36',
        PortalReply.fixture(
          'clinics.paris.prescriptions.renewable.get.200.json',
        ),
      );
    await pump(tester, backend);

    await openCard(tester, 'Ordonnance ORD-2026-000036');
    expect(find.text('Ordonnance du 2 nov. 2026'), findsOneWidget);
    expect(find.text('Dr Rousseau · Pepito'), findsOneWidget);
    expect(
      find.text('Qté 1 · 0,1 mg/kg, 1×/j, pendant 10 jours, voie per os'),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(PrescriptionSheet),
        matching: find.text('Demander un renouvellement'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrescriptionSheet), findsNothing);
    expect(renewals, [_ord36]);
  });

  testWidgets('404: « Ordonnance indisponible »', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_prescriptions/$_ord05',
        PortalReply.fixture(
          'clinics.paris.prescriptions.not-found.get.404.json',
          status: 404,
        ),
      );
    await pump(tester, backend);

    await openCard(tester, 'Ordonnance ORD-2026-000005');

    expect(find.text('Ordonnance ORD-2026-000005'), findsWidgets);
    expect(find.text('Ordonnance indisponible'), findsOneWidget);
    expect(
      find.text("Cette ordonnance n'est plus disponible."),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsNothing);
  });

  testWidgets('another failure: a retry that reads it again', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_prescriptions/$_ord05',
        problem('service_unavailable', 503),
      );
    await pump(tester, backend);

    await openCard(tester, 'Ordonnance ORD-2026-000005');
    expect(find.text('Réessayer'), findsOneWidget);

    backend.on(
      'GET',
      '$_prescriptions/$_ord05',
      PortalReply.fixture('clinics.paris.prescriptions.get.200.json'),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Ordonnance du 22 déc. 2025'), findsOneWidget);
    expect(backend.requestsTo('$_prescriptions/$_ord05'), hasLength(2));
  });

  testWidgets('loading: the document title over a spinner', (tester) async {
    final gate = Completer<void>();
    final backend = _backend()
      ..onRequest('GET', '$_prescriptions/$_ord05', (request) async {
        await gate.future;
        return PortalReply.fixture('clinics.paris.prescriptions.get.200.json');
      });
    await pump(tester, backend);

    await showCard(tester, 'Ordonnance ORD-2026-000005');
    await tester.tap(find.text('Ordonnance ORD-2026-000005'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.descendant(
        of: find.byType(KivetoSheet),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ordonnance du 22 déc. 2025'), findsOneWidget);
  });

  testWidgets('a prescription document without its summary opens its file', (
    tester,
  ) async {
    final backend = _backend()
      ..on(
        'GET',
        _documents,
        PortalReply.json(
          '{"items":[{"id":"d","type":"prescription","title":"Ordonnance '
          'ancienne","petIds":[],"issuedAt":"2024-01-02T10:00:00+01:00",'
          '"unread":false,"invoice":null,"prescription":null}],'
          '"nextCursor":null}',
        ),
      )
      ..on('GET', '$_documents/d/file', PortalReply.bytes(const [1]));
    await pump(tester, backend);

    expect(find.byType(RenewalControlView), findsNothing);
    await openCard(tester, 'Ordonnance ancienne');

    expect(find.byType(PrescriptionSheet), findsNothing);
    expect(find.byType(PdfFilePage), findsOneWidget);
  });

  testWidgets("ORD-36 (unread): « Voir l'ordonnance » from its sheet, then "
      'back twice: its dot is gone', (tester) async {
    const ord36Document = '01a19ef8-2277-7616-baa3-340aca185367';
    final backend = _backend()
      ..on(
        'GET',
        '$_prescriptions/$_ord36',
        PortalReply.fixture(
          'clinics.paris.prescriptions.renewable.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_documents/$ord36Document/file',
        PortalReply.bytes(const [1, 2, 3], contentType: 'application/pdf'),
      );
    await pump(tester, backend);
    Finder dot() => find.descendant(
      of: find.ancestor(
        of: find.textContaining('Ordonnance ORD-2026-000036'),
        matching: find.byType(DocumentCard),
      ),
      matching: find.byType(UnreadDot),
    );
    expect(dot(), findsOneWidget);

    await openCard(tester, 'Ordonnance ORD-2026-000036');
    await tester.tap(find.text("Voir l'ordonnance"));
    await tester.pumpAndSettle();
    expect(find.text('pdf:3'), findsOneWidget);
    expect(backend.requestsTo('$_documents/$ord36Document/file'), hasLength(1));

    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    expect(find.byType(PrescriptionSheet), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(PrescriptionSheet), findsNothing);
    expect(dot(), findsNothing);
  });

  testWidgets('a retry in flight shows the loading view, not the error and '
      'its retry', (tester) async {
    var calls = 0;
    final held = Completer<void>();
    final backend = _backend()
      ..onRequest('GET', '$_prescriptions/$_ord05', (request) async {
        if (calls++ == 0) return problem('service_unavailable', 503);
        await held.future;
        return PortalReply.fixture('clinics.paris.prescriptions.get.200.json');
      });
    await pump(tester, backend);
    await openCard(tester, 'Ordonnance ORD-2026-000005');
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(PrescriptionSheet),
        matching: find.byType(LoadingView),
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsNothing);

    held.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ordonnance du 22 déc. 2025'), findsOneWidget);
  });
}
