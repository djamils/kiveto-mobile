// Screen 1 on the fake backend and the captures: Julien's Paris and Lyon
// homes, Garnier's Paris home, the questionnaire and the status pills, the
// clinic gone and the other failures, /me failing, the exits, a document
// opened, pull-to-refresh, the clinic switcher.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/features/home/home.dart';
import 'package:kiveto_mobile/features/home/presentation/pet_cards.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _lyon = '01960000-0000-7000-8000-000000000101';
const _julien = '01a19a10-d011-70c8-8daf-26e4db824374';
const _me = '$api/me';
const _parisHome = '$api/clinics/$_paris/home';
const _lyonHome = '$api/clinics/$_lyon/home';
const _oslo = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';

/// Julien's Paris capture with [change] applied to its next appointment.
PortalReply _appointmentWith(void Function(Map<String, Object?> view) change) {
  final body = jsonDecode(
    File('$portalFixtures/clinics.paris.home.get.200.json').readAsStringSync(),
  ) as Map<String, Object?>;
  change(body['nextAppointment']! as Map<String, Object?>);
  return PortalReply.json(jsonEncode(body));
}

/// Julien signed in: his /me, both homes.
FakePortalBackend _julienBackend() => FakePortalBackend()
  ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    _parisHome,
    PortalReply.fixture('clinics.paris.home.get.200.json'),
  )
  ..on('GET', _lyonHome, PortalReply.fixture('clinics.lyon.home.get.200.json'));

/// A PDF view without PDFium: the size of what it received.
Widget _fakePdfView(BuildContext context, List<int> bytes, String source) =>
    Center(child: Text('pdf:${bytes.length}'));

final Uint8List _pdfBytes = File('$portalFixtures/files.documents.get.200.pdf')
    .readAsBytesSync();

Finder _row(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(KivetoListRow));

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    InMemoryActiveClinicStore? store,
    SessionManager? session,
  }) async => await pumpPage(
    tester,
    HomePage(
      onOpenPet: (context, id) => exits.add('pet:$id'),
      onManageAppointments: (context) => exits.add('appointments'),
      onFillQuestionnaire: (context, id) => exits.add('questionnaire:$id'),
      onBook: (context) => exits.add('book'),
      onSeeAllDocuments: (context) => exits.add('documents'),
    ),
    session: session ?? await memorySession(pair('A')),
    backend: backend,
    overrides: [
      activeClinicStoreProvider.overrideWithValue(
        store ?? InMemoryActiveClinicStore(),
      ),
      pdfViewBuilderProvider.overrideWithValue(_fakePdfView),
    ],
  );

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Julien, Paris: the header, the confirmed appointment, Oslo, '
      'two care items, two invoices; no bell', (tester) async {
    await pump(tester, _julienBackend());

    expect(find.text('Clinique Vétérinaire de Paris'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is KivetoIcon && widget.glyph == LucideGlyph.chevronDown,
      ),
      findsOneWidget,
    );
    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is KivetoIcon && widget.glyph == LucideGlyph.bell,
      ),
      findsNothing,
    );

    expect(find.text('PROCHAIN RENDEZ-VOUS'), findsOneWidget);
    final pill = tester.widget<StatusPill>(
      find.ancestor(
        of: find.text('Confirmé'),
        matching: find.byType(StatusPill),
      ),
    );
    expect(pill.tone, StatusTone.onBrand);
    expect(find.text('Mer. 11 nov. · 10:30'), findsOneWidget);
    expect(find.text('Oslo — Rendez-vous · Dr Éric Rousseau'), findsOneWidget);
    expect(find.text('Remplir le questionnaire'), findsNothing);
    final manage = tester.widget<KivetoButton>(
      find.widgetWithText(KivetoButton, 'Gérer'),
    );
    expect(manage.expand, isTrue);

    expect(find.text('Mes animaux'), findsOneWidget);
    expect(find.byType(PetCard), findsOneWidget);
    expect(
      tester.getSize(find.byType(PetCard)).width,
      390 - 2 * 20,
      reason: 'one pet: full width',
    );
    expect(find.text('Oslo'), findsOneWidget);
    expect(find.text('Chien · 6 ans'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Derniers documents'), 200);
    await tester.pumpAndSettle();
    expect(find.text('À prévoir'), findsOneWidget);
    expect(find.text('Échéances de soins'), findsOneWidget);
    expect(find.text('Oslo — CHPL'), findsOneWidget);
    expect(find.text('Oslo — Rage'), findsOneWidget);
    expect(find.text('Avant le 5 sept. 2027'), findsNWidgets(2));
    expect(find.text('À jour'), findsNWidgets(2));
    expect(find.text('Prendre rendez-vous'), findsOneWidget);
    expect(find.text('Tout voir'), findsOneWidget);
    expect(find.text('Facture PAR-2026-000067'), findsOneWidget);
    expect(find.text('52,00 € · Payée'), findsOneWidget);
    expect(find.text('Facture PAR-2026-000066'), findsOneWidget);
    expect(find.text('78,00 € · Payée'), findsOneWidget);
    final tile = tester.widget<KivetoLeadingTile>(
      find.descendant(
        of: _row('Facture PAR-2026-000067'),
        matching: find.byType(KivetoLeadingTile),
      ),
    );
    expect(tile.colors, KivetoColorSets.green);
    expect(tile.text, '€');
    expect(exits, isEmpty);
  });

  testWidgets('Julien, Lyon: no appointment, Pixel, « À prévoir » with the '
      'booking button only, no documents section', (tester) async {
    await pump(
      tester,
      _julienBackend(),
      store: InMemoryActiveClinicStore(choices: {_julien: _lyon}),
    );

    expect(find.text('Clinique Vétérinaire de Lyon'), findsOneWidget);
    expect(find.text('PROCHAIN RENDEZ-VOUS'), findsNothing);
    expect(find.text('Pixel'), findsOneWidget);
    expect(find.text('Chat · 4 ans'), findsOneWidget);
    expect(find.text('À prévoir'), findsOneWidget);
    expect(find.byType(KivetoListRow), findsNothing);
    expect(find.text('Prendre rendez-vous'), findsOneWidget);
    expect(find.text('Derniers documents'), findsNothing);
  });

  testWidgets('Garnier, Paris: her next appointment, four pets two per row, '
      'three overdue care items, a prescription and an unpaid invoice', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.garnier.get.200.json'))
      ..on(
        'GET',
        _parisHome,
        PortalReply.fixture('clinics.paris.home.garnier.get.200.json'),
      );
    await pump(tester, backend);

    expect(find.text('Bonjour Sophie'), findsOneWidget);
    expect(find.text('Jeu. 5 nov. · 09:00'), findsOneWidget);
    expect(find.text('Oscar — Rendez-vous · Dr Lucie Bernard'), findsOneWidget);
    expect(find.byType(PetCard), findsNWidgets(4));
    for (final (name, meta) in [
      ('Coco', 'NAC · 5 ans'),
      ('Nala', 'Chat · 4 ans'),
      ('Oscar', 'Chien · 11 ans'),
      ('Pepito', 'Chien · 2 ans'),
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
      expect(find.text(meta), findsOneWidget, reason: name);
    }
    final coco = tester.getRect(
      find.ancestor(of: find.text('Coco'), matching: find.byType(PetCard)),
    );
    final nala = tester.getRect(
      find.ancestor(of: find.text('Nala'), matching: find.byType(PetCard)),
    );
    final oscar = tester.getRect(
      find.ancestor(of: find.text('Oscar'), matching: find.byType(PetCard)),
    );
    expect(nala.top, coco.top, reason: 'two per row');
    expect(nala.left, coco.right + 10);
    expect(oscar.top, greaterThan(coco.bottom));
    expect(
      tester
          .widget<InitialsAvatar>(
            find.descendant(
              of: find.ancestor(
                of: find.text('Nala'),
                matching: find.byType(PetCard),
              ),
              matching: find.byType(InitialsAvatar),
            ),
          )
          .tone,
      AvatarTone.orange,
    );

    await tester.scrollUntilVisible(find.text('Derniers documents'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Oscar — Vermifugation'), findsOneWidget);
    expect(find.text('Avant le 13 oct.'), findsOneWidget);
    expect(find.text('Oscar — Simparica · 1 mois'), findsOneWidget);
    expect(find.text('Pepito — Vermifugation'), findsOneWidget);
    expect(find.text('En retard'), findsNWidgets(3));
    expect(
      tester
          .widgetList<StatusPill>(find.byType(StatusPill))
          .where((pill) => pill.label == 'En retard')
          .map((pill) => pill.tone),
      everyElement(StatusTone.danger),
    );
    expect(find.text('Ordonnance ORD-2026-000036'), findsOneWidget);
    expect(find.text('Pepito · 2 nov.'), findsOneWidget);
    final rx = tester.widget<KivetoLeadingTile>(
      find.descendant(
        of: _row('Ordonnance ORD-2026-000036'),
        matching: find.byType(KivetoLeadingTile),
      ),
    );
    expect(rx.colors, KivetoColorSets.orange);
    expect(rx.text, 'Rx');
    expect(find.text('Facture PAR-2026-000025'), findsOneWidget);
    expect(find.text('96,00 € · Non payée'), findsOneWidget);
  });

  testWidgets('a questionnaire not started: « Remplir le questionnaire » '
      'and « Gérer »; the exits', (tester) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        _parisHome,
        _appointmentWith((view) => view['questionnaireStatus'] = 'not_started'),
      );
    await pump(tester, backend);

    expect(find.text('Remplir le questionnaire'), findsOneWidget);
    expect(
      tester
          .widget<KivetoButton>(find.widgetWithText(KivetoButton, 'Gérer'))
          .expand,
      isFalse,
    );

    await tester.tap(find.text('Remplir le questionnaire'));
    await tester.tap(find.text('Gérer'));
    await tester.tap(find.text('Oslo'));
    await tapVisible(tester, find.text('Prendre rendez-vous'));
    await tapVisible(tester, find.text('Tout voir'));

    expect(exits, [
      'questionnaire:01a19a12-6840-7d19-bf1f-7604a862c028',
      'appointments',
      'pet:$_oslo',
      'book',
      'documents',
    ]);
  });

  testWidgets('pending: « En attente »; another status: no pill', (
    tester,
  ) async {
    final backend = _julienBackend()
      ..on(
        'GET',
        _parisHome,
        _appointmentWith((view) {
          view['status'] = 'pending_clinic_confirmation';
          view['pet'] = null;
          (view['practitioner']! as Map<String, Object?>)['displayName'] = null;
        }),
      );
    await pump(tester, backend);

    expect(find.text('En attente'), findsOneWidget);
    expect(find.text('Rendez-vous'), findsOneWidget);

    backend.on(
      'GET',
      _parisHome,
      _appointmentWith((view) => view['status'] = 'completed'),
    );
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('PROCHAIN RENDEZ-VOUS'), findsOneWidget);
    expect(find.text('En attente'), findsNothing);
    expect(find.text('Confirmé'), findsNothing);
  });

  testWidgets('a document row opens its file in the viewer', (tester) async {
    const file =
        '$api/clinics/$_paris/documents/01a19a12-65aa-78e6-b439-fe4e297698d8/file';
    final backend = _julienBackend()
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
      );
    await pump(tester, backend);

    await tapVisible(tester, find.text('Facture PAR-2026-000067'));

    expect(find.byType(PdfFilePage), findsOneWidget);
    expect(find.text('pdf:${_pdfBytes.length}'), findsOneWidget);
    expect(backend.requestsTo(file), hasLength(1));
    // The read is counted: /me again (the badge).
    expect(backend.requestsTo(_me), hasLength(2));
  });

  testWidgets('the home answers 404: « Clinique indisponible »; the retry '
      'reads /me and the home again', (tester) async {
    var gone = true;
    final backend = _julienBackend()
      ..onRequest(
        'GET',
        _parisHome,
        (_) => gone
            ? PortalReply.fixture(
                'clinics.unknown.home.get.404.json',
                status: 404,
              )
            : PortalReply.fixture('clinics.paris.home.get.200.json'),
      );
    await pump(tester, backend);

    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(find.text('Clinique indisponible'), findsOneWidget);
    expect(
      find.text("Votre accès à cette clinique n'est plus actif."),
      findsOneWidget,
    );

    gone = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Oslo'), findsOneWidget);
    expect(backend.requestsTo(_me), hasLength(2));
    expect(backend.requestsTo(_parisHome), hasLength(2));
  });

  testWidgets('another failure: its error and a retry of the home only', (
    tester,
  ) async {
    var fail = true;
    final backend = _julienBackend()
      ..onRequest(
        'GET',
        _parisHome,
        (_) => fail
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('clinics.paris.home.get.200.json'),
      );
    await pump(tester, backend);
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(find.text('Bonjour Julien'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Oslo'), findsOneWidget);
    expect(backend.requestsTo(_me), hasLength(1));
  });

  testWidgets('/me fails: no header, its error; the retry reads /me', (
    tester,
  ) async {
    var fail = true;
    final backend = _julienBackend()
      ..onRequest(
        'GET',
        _me,
        (_) => fail
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('me.get.200.json'),
      );
    await pump(tester, backend);
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(find.textContaining('Bonjour'), findsNothing);

    fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(find.text('Oslo'), findsOneWidget);
  });

  testWidgets('no first name: « Bonjour »', (tester) async {
    final me = jsonDecode(
      File('$portalFixtures/me.get.200.json').readAsStringSync(),
    ) as Map<String, Object?>;
    (me['account']! as Map<String, Object?>)['firstName'] = ' ';
    final backend = _julienBackend()
      ..on('GET', _me, PortalReply.json(jsonEncode(me)));
    await pump(tester, backend);

    expect(find.text('Bonjour'), findsOneWidget);
  });

  testWidgets('pull-to-refresh reads /me and the home again', (tester) async {
    final backend = _julienBackend();
    await pump(tester, backend);

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_me), hasLength(2));
    expect(backend.requestsTo(_parisHome), hasLength(2));
  });

  group('the clinic switcher', () {
    testWidgets('the sheet lists both clinics; Lyon becomes the active '
        'clinic, kept on this device; the home reads Lyon', (tester) async {
      final handle = tester.ensureSemantics();
      final store = InMemoryActiveClinicStore();
      final backend = _julienBackend();
      await pump(tester, backend, store: store);
      expect(
        find.bySemanticsLabel(
          'Changer de clinique, actuellement Clinique Vétérinaire de Paris',
        ),
        findsOneWidget,
      );
      handle.dispose();

      await tester.tap(find.text('Clinique Vétérinaire de Paris'));
      await tester.pumpAndSettle();

      expect(find.text('Changer de clinique'), findsOneWidget);
      final sheet = find.byType(BottomSheet);
      final dots = tester
          .widgetList<StatusDot>(
            find.descendant(of: sheet, matching: find.byType(StatusDot)),
          )
          .map((dot) => dot.active);
      expect(dots, [true, false]);
      expect(
        find.descendant(of: sheet, matching: find.text('Active')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Lyon')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is KivetoIcon &&
                widget.glyph == LucideGlyph.chevronRight,
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: sheet,
          matching: find.text('Clinique Vétérinaire de Lyon'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(store.choices, {_julien: _lyon});
      expect(backend.requestsTo(_lyonHome), hasLength(1));
      expect(find.text('Clinique Vétérinaire de Lyon'), findsOneWidget);
      expect(find.text('Pixel'), findsOneWidget);
    });

    testWidgets('the active clinic tapped: the sheet closes, nothing '
        'changes', (tester) async {
      final store = InMemoryActiveClinicStore();
      await pump(tester, _julienBackend(), store: store);

      await tester.tap(find.text('Clinique Vétérinaire de Paris'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Clinique Vétérinaire de Paris'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(store.choices, isEmpty);
      expect(find.text('Oslo'), findsOneWidget);
    });

    testWidgets('one confirmed clinic: its name is plain text, no chevron, '
        'not tappable', (tester) async {
      final me = jsonDecode(
        File('$portalFixtures/me.get.200.json').readAsStringSync(),
      ) as Map<String, Object?>;
      ((me['clinics']! as List<Object?>)[1]!
              as Map<String, Object?>)['linkStatus'] =
          'pending';
      final backend = _julienBackend()
        ..on('GET', _me, PortalReply.json(jsonEncode(me)));
      final handle = tester.ensureSemantics();
      await pump(tester, backend);

      expect(find.text('Clinique Vétérinaire de Paris'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Changer de clinique, actuellement Clinique Vétérinaire de Paris',
        ),
        findsNothing,
      );
      handle.dispose();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is KivetoIcon && widget.glyph == LucideGlyph.chevronDown,
        ),
        findsNothing,
      );
      await tester.tap(find.text('Clinique Vétérinaire de Paris'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  testWidgets('three pets: two on the first row, the third on the left at '
      'half width', (tester) async {
    final body = jsonDecode(
      File('$portalFixtures/clinics.paris.home.garnier.get.200.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    (body['pets']! as List<Object?>).removeLast();
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.garnier.get.200.json'))
      ..on('GET', _parisHome, PortalReply.json(jsonEncode(body)));
    await pump(tester, backend);

    expect(find.byType(PetCard), findsNWidgets(3));
    Rect card(String name) => tester.getRect(
      find.ancestor(of: find.text(name), matching: find.byType(PetCard)),
    );
    final coco = card('Coco');
    final nala = card('Nala');
    final oscar = card('Oscar');
    expect(nala.top, coco.top);
    expect(oscar.top, greaterThan(coco.bottom));
    expect(oscar.left, coco.left);
    expect(oscar.width, coco.width);
    expect(oscar.width, (390 - 2 * 20 - 10) / 2);
  });

  testWidgets('another session: the home is read again with its tokens', (
    tester,
  ) async {
    final session = await memorySession(pair('A'));
    final backend = _julienBackend()
      ..onRequest(
        'GET',
        _me,
        (request) => bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('me.garnier.get.200.json')
            : PortalReply.fixture('me.get.200.json'),
      )
      ..onRequest(
        'GET',
        _parisHome,
        (request) => bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('clinics.paris.home.garnier.get.200.json')
            : PortalReply.fixture('clinics.paris.home.get.200.json'),
      );
    await pump(tester, backend, session: session);
    expect(find.text('Bonjour Sophie'), findsOneWidget);
    expect(find.text('Pepito'), findsOneWidget);

    await session.open(pair('B'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_parisHome).map(bearerOf), [
      'Bearer A',
      'Bearer B',
    ]);
    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(find.text('Oslo'), findsOneWidget);
    expect(find.text('Pepito'), findsNothing);
    expect(find.text('Jeu. 5 nov. · 09:00'), findsNothing);
  });

  testWidgets('a retry in flight shows the skeleton, not the error and its '
      'retry', (tester) async {
    var calls = 0;
    final held = Completer<void>();
    final backend = _julienBackend()
      ..onRequest('GET', _parisHome, (request) async {
        if (calls++ == 0) return problem('service_unavailable', 503);
        await held.future;
        return PortalReply.fixture('clinics.paris.home.get.200.json');
      });
    await pump(tester, backend);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(find.byType(KivetoSkeleton), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
    expect(find.text('Bonjour Julien'), findsOneWidget);

    held.complete();
    await tester.pumpAndSettle();
    expect(find.text('Oslo'), findsOneWidget);
  });

  testWidgets('the switcher lists the confirmed clinics only', (tester) async {
    final me = jsonDecode(
      File('$portalFixtures/me.get.200.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final clinics = me['clinics']! as List<Object?>;
    clinics.add({
      ...clinics.first! as Map<String, Object?>,
      'clinicId': '01960000-0000-7000-8000-000000000201',
      'name': 'Clinique Vétérinaire de Nice',
      'city': 'Nice',
      'linkStatus': 'pending',
    });
    final backend = _julienBackend()
      ..on('GET', _me, PortalReply.json(jsonEncode(me)));
    await pump(tester, backend);

    await tester.tap(find.text('Clinique Vétérinaire de Paris'));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(
      find.descendant(of: sheet, matching: find.byType(StatusDot)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('Clinique Vétérinaire de Nice'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('Clinique Vétérinaire de Lyon'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('no pet: no « Mes animaux » section', (tester) async {
    final body = jsonDecode(
      File('$portalFixtures/clinics.paris.home.get.200.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    body['pets'] = <Object?>[];
    final backend = _julienBackend()
      ..on('GET', _parisHome, PortalReply.json(jsonEncode(body)));
    await pump(tester, backend);

    expect(find.text('PROCHAIN RENDEZ-VOUS'), findsOneWidget);
    expect(find.text('Mes animaux'), findsNothing);
    expect(find.byType(PetCard), findsNothing);
    expect(find.text('À prévoir'), findsOneWidget);
  });
}
