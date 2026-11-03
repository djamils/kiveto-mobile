// « Historique » on the fake backend and the captures: Pepito's visits and
// their chips (a chip opens the document's file), a visit without vet or
// document, no visit, the next page failing then retried, a stale cursor
// reloading the first page, the first page failing (and its retry in
// flight), an empty first page with a next one, a session change.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/consultation/consultation.dart';
import 'package:kiveto_mobile/features/consultation/presentation/pet_timeline_section.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _me = '$api/me';
const _pets = '$api/clinics/$_paris/pets';
const _pepito = '01a19a10-21af-748a-b841-690b02e4fe18';
const _oscar = '01a19a10-20d7-77bd-bbad-d251136402fc';

/// The `nextCursor` of a capture.
String _cursorOf(String fixture) =>
    (jsonDecode(File('$portalFixtures/$fixture').readAsStringSync())
            as Map<String, Object?>)['nextCursor']!
        as String;

final String _cursor = _cursorOf(
  'clinics.paris.pet.timeline.garnier-oscar.get.200.json',
);
final String _page2 = '$_pets/$_oscar/timeline?cursor=$_cursor';

/// A PDF view without PDFium: the size of what it received.
Widget _fakePdfView(BuildContext context, List<int> bytes, String source) =>
    Center(child: Text('pdf:${bytes.length}'));

final Uint8List _pdfBytes = File('$portalFixtures/files.documents.get.200.pdf')
    .readAsBytesSync();

FakePortalBackend _backend() => FakePortalBackend()
  ..on('GET', _me, PortalReply.fixture('me.garnier.get.200.json'))
  ..on(
    'GET',
    '$_pets/$_pepito/timeline',
    PortalReply.fixture(
      'clinics.paris.pet.timeline.garnier-pepito.get.200.json',
    ),
  )
  ..on(
    'GET',
    '$_pets/$_oscar/timeline',
    PortalReply.fixture(
      'clinics.paris.pet.timeline.garnier-oscar.get.200.json',
    ),
  );

int _visits(ProviderContainer container, String petId) =>
    switch (container.read(petTimelineProvider(petId))) {
      AsyncData(:final value) => value.items.length,
      _ => -1,
    };

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend,
    String petId, {
    SessionManager? session,
  }) async => await pumpPage(
    tester,
    Scaffold(
      body: CustomScrollView(slivers: [PetTimelineSection(petId: petId)]),
    ),
    session: session ?? await memorySession(pair('A')),
    backend: backend,
    overrides: [
      activeClinicStoreProvider.overrideWithValue(InMemoryActiveClinicStore()),
      pdfViewBuilderProvider.overrideWithValue(_fakePdfView),
    ],
  );

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -30000));
    await tester.pumpAndSettle();
  }

  testWidgets('Pepito: the date and vet, the title, the chips; the latest '
      'dot brand, the others grey, no line after the last', (tester) async {
    await pump(tester, _backend(), _pepito);

    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('31 août 2026 · Dr Éric Rousseau'), findsOneWidget);
    expect(find.text('Boiterie'), findsOneWidget);
    expect(find.text('Compte-rendu'), findsNWidgets(3));
    expect(find.text('Ordonnance'), findsOneWidget);
    expect(find.text('2 juin 2026 · Dr Marc Dupont'), findsOneWidget);
    final items = tester
        .widgetList<TimelineItem>(find.byType(TimelineItem))
        .toList();
    expect(items.map((item) => item.latest), [true, false, false]);
    expect(items.map((item) => item.last), [false, false, true]);
    Color dotOf(int index) =>
        (tester
                    .widgetList<Container>(
                      find.descendant(
                        of: find.byWidget(items[index]),
                        matching: find.byType(Container),
                      ),
                    )
                    .first
                    .decoration!
                as BoxDecoration)
            .color!;
    expect(dotOf(0), KivetoColors.brand);
    expect(dotOf(1), KivetoColors.timelineDot);
  });

  testWidgets('a chip opens its document in the viewer, titled with its '
      'kind and the visit', (tester) async {
    const prescription = '01a19a12-5f05-71e1-80ea-fa29aaa18349';
    const file = '$api/clinics/$_paris/documents/$prescription/file';
    final backend = _backend()
      ..on(
        'GET',
        file,
        PortalReply.empty(
          302,
          headers: {
            'location': ['http://portal.test/files/x?_hash=y'],
          },
        ),
      )
      ..on(
        'GET',
        '/files/x?_hash=y',
        PortalReply.bytes(_pdfBytes, contentType: 'application/pdf'),
      )
      ..on('GET', _me, PortalReply.fixture('me.garnier.get.200.json'));
    await pump(tester, backend, _pepito);

    await tester.tap(find.text('Ordonnance'));
    await tester.pumpAndSettle();

    expect(find.byType(PdfFilePage), findsOneWidget);
    expect(find.text('Ordonnance · Boiterie'), findsOneWidget);
    expect(find.text('pdf:${_pdfBytes.length}'), findsOneWidget);
    expect(backend.requestsTo(file), hasLength(1));
  });

  testWidgets('a visit without vet nor document; no visit at all', (
    tester,
  ) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_pets/p/timeline',
        PortalReply.json(
          jsonEncode({
            'items': [
              {
                'visitId': 'v',
                'date': '2026-01-18T10:00:00+01:00',
                'vet': null,
                'title': 'Bilan sanguin',
                'documents': <Object?>[],
              },
            ],
            'nextCursor': null,
          }),
        ),
      )
      ..on(
        'GET',
        '$_pets/none/timeline',
        PortalReply.fixture('clinics.paris.pet.timeline.get.200.json'),
      );
    await pump(tester, backend, 'p');

    expect(find.text('18 janvier 2026'), findsOneWidget);
    expect(find.text('Bilan sanguin'), findsOneWidget);
    expect(find.text('Aucun document partagé'), findsOneWidget);

    await pump(tester, backend, 'none');
    expect(
      find.text('Aucune consultation partagée pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('the next page fails: the visits stay, « Impossible de '
      'charger la suite. » and a retry', (tester) async {
    var fail = true;
    final backend = _backend()
      ..onRequest(
        'GET',
        _page2,
        (_) => fail
            ? problem('service_unavailable', 503)
            : PortalReply.fixture(
                'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
              ),
      );
    final container = await pump(tester, backend, _oscar);
    expect(_visits(container, _oscar), 20);

    await scrollToEnd(tester);
    expect(find.text('Impossible de charger la suite.'), findsOneWidget);
    expect(_visits(container, _oscar), 20);
    expect(backend.requestsTo(_page2), hasLength(1));

    fail = false;
    await scrollToEnd(tester);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger la suite.'), findsNothing);
    expect(_visits(container, _oscar), 23);
    expect(backend.requestsTo(_page2), hasLength(2));
  });

  testWidgets('400 cursor_invalid: the history reloads from its first page', (
    tester,
  ) async {
    var stale = true;
    final backend = _backend()
      ..onRequest('GET', _page2, (_) {
        // Once: a reload answers fresh cursors.
        if (!stale) {
          return PortalReply.fixture(
            'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
          );
        }
        stale = false;
        return PortalReply.fixture(
          'clinics.paris.pet.timeline.cursor-invalid.get.400.json',
          status: 400,
        );
      });
    final container = await pump(tester, backend, _oscar);

    await scrollToEnd(tester);
    expect(stale, isFalse);
    await scrollToEnd(tester);

    expect(backend.requestsTo('$_pets/$_oscar/timeline'), hasLength(2));
    expect(_visits(container, _oscar), 23);
    expect(find.text('Impossible de charger la suite.'), findsNothing);
  });

  testWidgets('the first page fails: an error and its retry', (tester) async {
    var fail = true;
    final backend = _backend()
      ..onRequest(
        'GET',
        '$_pets/$_pepito/timeline',
        (_) => fail
            ? problem('service_unavailable', 503)
            : PortalReply.fixture(
                'clinics.paris.pet.timeline.garnier-pepito.get.200.json',
              ),
      );
    await pump(tester, backend, _pepito);
    expect(find.text('Service indisponible'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Boiterie'), findsOneWidget);
  });

  testWidgets('a next page answering after a session change is dropped', (
    tester,
  ) async {
    final held = Completer<PortalReply>();
    final backend = _backend()
      ..onRequest(
        'GET',
        _page2,
        (request) => bearerOf(request) == 'Bearer A'
            ? held.future
            : PortalReply.fixture(
                'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
              ),
      );
    final session = await memorySession(pair('A'));
    final container = await pump(tester, backend, _oscar, session: session);
    // The next page is held: its spinner turns, no settling.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -30000));
    await pumpBriefly(tester);
    expect(backend.requestsTo(_page2), hasLength(1));

    await session.open(pair('B'));
    await pumpBriefly(tester);
    held.complete(
      PortalReply.fixture(
        'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
      ),
    );
    await tester.pumpAndSettle();

    final requests = backend.requestsTo('$_pets/$_oscar/timeline');
    expect(requests.map(bearerOf), ['Bearer A', 'Bearer B']);
    // The answer for the previous session is not appended: no visit twice.
    final visits = switch (container.read(petTimelineProvider(_oscar))) {
      AsyncData(:final value) => [for (final e in value.items) e.visitId],
      _ => const <String>[],
    };
    // B's list read its own next page; A's answer came after and was dropped.
    expect(backend.requestsTo(_page2).map(bearerOf), ['Bearer A', 'Bearer B']);
    expect(visits, hasLength(23));
    expect(visits.toSet(), hasLength(23));
  });

  testWidgets('an empty first page with a next one reads on', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_pets/p/timeline',
        PortalReply.json('{"items":[],"nextCursor":"c1"}'),
      )
      ..on(
        'GET',
        '$_pets/p/timeline?cursor=c1',
        PortalReply.fixture(
          'clinics.paris.pet.timeline.garnier-pepito.get.200.json',
        ),
      );
    await pump(tester, backend, 'p');

    expect(
      find.text('Aucune consultation partagée pour le moment.'),
      findsNothing,
    );
    expect(backend.requestsTo('$_pets/p/timeline?cursor=c1'), hasLength(1));
    expect(find.text('Boiterie'), findsOneWidget);
  });

  testWidgets('a retry in flight shows the loading view, not the error and '
      'its retry', (tester) async {
    var calls = 0;
    final held = Completer<void>();
    final backend = _backend()
      ..onRequest('GET', '$_pets/$_pepito/timeline', (request) async {
        if (calls++ == 0) return problem('service_unavailable', 503);
        await held.future;
        return PortalReply.fixture(
          'clinics.paris.pet.timeline.garnier-pepito.get.200.json',
        );
      });
    await pump(tester, backend, _pepito);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);

    held.complete();
    await tester.pumpAndSettle();
    expect(find.text('Boiterie'), findsOneWidget);
  });

  testWidgets('a next page answering after a clinic switch is dropped', (
    tester,
  ) async {
    const lyon = '01960000-0000-7000-8000-000000000101';
    final held = Completer<void>();
    final backend = _backend()
      ..onRequest('GET', _page2, (request) async {
        await held.future;
        return PortalReply.fixture(
          'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
        );
      })
      ..on(
        'GET',
        '$api/clinics/$lyon/pets/$_oscar/timeline',
        PortalReply.fixture('clinics.lyon.pet.timeline.get.200.json'),
      );
    final container = await pump(tester, backend, _oscar);
    // The next page is held: its spinner turns, no settling.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -30000));
    await pumpBriefly(tester);
    expect(backend.requestsTo(_page2), hasLength(1));

    unawaited(
      container
          .read(activeClinicProvider.notifier)
          .select(const ClinicId(lyon)),
    );
    await tester.pumpAndSettle();
    held.complete();
    await tester.pumpAndSettle();

    expect(_visits(container, _oscar), 0);
    expect(
      find.text('Aucune consultation partagée pour le moment.'),
      findsOneWidget,
    );
    expect(find.text('Bilan thyroïdien'), findsNothing);
  });
}
