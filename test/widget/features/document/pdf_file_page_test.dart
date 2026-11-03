// The in-app PDF viewer: loading, the PDF (a fake view: no PDFium in
// flutter test), /me read again once a document shows, the 404 and the
// other failures, a viewer closed before its file arrived, openPdfFile.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _file = '$api/clinics/$_paris/documents/d/file';
const _me = '$api/me';

/// What the fake PDF view received, in order.
final _shown = <(Uint8List, String)>[];

Widget _fakePdfView(BuildContext context, Uint8List bytes, String source) {
  _shown.add((bytes, source));
  return Center(child: Text('pdf:${bytes.length}'));
}

/// A page with one button that runs [open] with its context.
class _Opener extends StatelessWidget {
  const new(this.open);

  final void Function(BuildContext context) open;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: KivetoButton.primary(
        label: 'open',
        onPressed: () => open(context),
      ),
    ),
  );
}

void main() {
  setUp(_shown.clear);

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend,
    void Function(BuildContext context) open,
  ) async {
    final container = await pumpPage(
      tester,
      _Opener(open),
      session: await memorySession(pair('A')),
      backend: backend,
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        pdfViewBuilderProvider.overrideWithValue(_fakePdfView),
      ],
    );
    await tester.tap(find.text('open'));
    return container;
  }

  testWidgets('a document: loading, then its PDF; /me read again, onRead', (
    tester,
  ) async {
    final gate = Completer<void>();
    var read = 0;
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
      ..onRequest('GET', _file, (request) async {
        await gate.future;
        return PortalReply.bytes(const [1, 2, 3]);
      });
    final container = await pump(
      tester,
      backend,
      (context) => unawaited(
        openDocumentFile(
          context,
          clinicId: const ClinicId(_paris),
          documentId: const DocumentId('d'),
          title: 'Facture PAR-2026-000067',
          onRead: () => read++,
        ),
      ),
    );
    container.listen(meProvider, (_, _) {});
    // A spinner while the file comes: no pumpAndSettle.
    await pumpBriefly(tester);
    final meCalls = backend.requestsTo(_me).length;

    expect(find.text('Facture PAR-2026-000067'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(read, 0);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('pdf:3'), findsOneWidget);
    expect(_shown.single.$1, [1, 2, 3]);
    expect(read, 1);
    expect(backend.requestsTo(_me), hasLength(meCalls + 1));

    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    expect(find.byType(PdfFilePage), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('each file shown gets its own source name', (tester) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
      ..on('GET', _file, PortalReply.bytes(const [1]));
    await pump(
      tester,
      backend,
      (context) => unawaited(
        openDocumentFile(
          context,
          clinicId: const ClinicId(_paris),
          documentId: const DocumentId('d'),
          title: 'Document',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final sources = {for (final (_, source) in _shown) source};
    expect(sources, hasLength(2));
  });

  testWidgets('404: « Document indisponible », no retry', (tester) async {
    final backend = FakePortalBackend()
      ..on('GET', _file, problem('not_found', 404));
    await pump(
      tester,
      backend,
      (context) => unawaited(
        openDocumentFile(
          context,
          clinicId: const ClinicId(_paris),
          documentId: const DocumentId('d'),
          title: 'Document',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Document indisponible'), findsOneWidget);
    expect(
      find.text(
        "Ce document a été retiré ou n'est pas encore prêt. "
        'Réessayez plus tard.',
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsNothing);
    expect(backend.requestsTo(_me), isEmpty);
  });

  testWidgets('another failure: the error and a retry that loads it', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
      ..on('GET', _file, problem('service_unavailable', 503));
    await pump(
      tester,
      backend,
      (context) => unawaited(
        openDocumentFile(
          context,
          clinicId: const ClinicId(_paris),
          documentId: const DocumentId('d'),
          title: 'Document',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Réessayer'), findsOneWidget);

    backend.on('GET', _file, PortalReply.bytes(const [9, 9]));
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('pdf:2'), findsOneWidget);
    expect(backend.requestsTo(_file), hasLength(2));
  });

  testWidgets('closed before the file arrived: no read, no /me', (
    tester,
  ) async {
    final gate = Completer<void>();
    var read = 0;
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
      ..onRequest('GET', _file, (request) async {
        await gate.future;
        return PortalReply.bytes(const [1]);
      });
    await pump(
      tester,
      backend,
      (context) => unawaited(
        openDocumentFile(
          context,
          clinicId: const ClinicId(_paris),
          documentId: const DocumentId('d'),
          title: 'Document',
          onRead: () => read++,
        ),
      ),
    );
    await pumpBriefly(tester);

    await tester.tap(find.bySemanticsLabel('Retour'));
    await tester.pumpAndSettle();
    gate.complete();
    await tester.pumpAndSettle();

    expect(read, 0);
    expect(backend.requestsTo(_me), isEmpty);
    expect(_shown, isEmpty);
  });

  testWidgets('openPdfFile: another file of the API, as a list of bytes', (
    tester,
  ) async {
    final backend = FakePortalBackend();
    await pump(
      tester,
      backend,
      (context) => unawaited(
        openPdfFile(
          context,
          title: 'Carnet de vaccination',
          load: (ref) async => const PortalFile([7, 8, 9, 10]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Carnet de vaccination'), findsOneWidget);
    expect(find.text('pdf:4'), findsOneWidget);
    expect(_shown.single.$1, isA<Uint8List>());
    expect(backend.requests, isEmpty);
  });

  testWidgets('the default view is pdfrx, with its render failure in '
      'French', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final build = container.read(pdfViewBuilderProvider);
    PdfViewer? viewer;

    // The banner the viewer would show, not the viewer itself: no PDFium
    // in flutter test.
    await pumpKit(
      tester,
      Builder(
        builder: (context) {
          final view = viewer = build(
            context,
            Uint8List.fromList(const [1, 2]),
            'source',
          ) as PdfViewer;
          return view.params.errorBannerBuilder!(
            context,
            StateError('not a PDF'),
            null,
            view.documentRef,
          );
        },
      ),
    );

    expect(viewer, isA<PdfViewer>());
    expect(viewer!.documentRef.key.toString(), contains('source'));
    expect(find.text("Impossible d'afficher ce document."), findsOneWidget);
  });
}
