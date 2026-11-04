// Screen 2 on the fake backend and the captures: Oscar's sheet (switcher,
// identity grid, care items, history page after page), Nala and Filou,
// Julien's Oslo through the Animaux tab, a pet of another clinic, no pet,
// the parts failing on their own, the booklet, the exits, pull-to-refresh,
// the switcher's choice across navigations and refreshes, another session.

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
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_change_sheet.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _me = '$api/me';
const _pets = '$api/clinics/$_paris/pets';
const _requests = '$api/clinics/$_paris/requests?limit=50';
const _oscar = '01a19a10-20d7-77bd-bbad-d251136402fc';
const _nala = '01a19a10-214a-7baa-93c9-96d75aad7892';
const _filou = '01a19a10-2291-7c4a-a837-900159faa98f';
const _oslo = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _pepito = '01a19a10-21af-748a-b841-690b02e4fe18';

/// The `nextCursor` of a capture.
String _cursorOf(String fixture) =>
    (jsonDecode(File('$portalFixtures/$fixture').readAsStringSync())
            as Map<String, Object?>)['nextCursor']!
        as String;

final String _oscarCursor = _cursorOf(
  'clinics.paris.pet.timeline.garnier-oscar.get.200.json',
);

/// The capture [fixture] with [change] applied to its JSON body.
PortalReply _edited(String fixture, void Function(Object? body) change) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body));
}

const _noVisit = 'clinics.paris.pet.timeline.get.200.json';

/// Garnier signed in, Paris active: her pets, Oscar's, Nala's and Filou's
/// sheets, care items and visits, her requests (none pending for them).
FakePortalBackend _garnier() => FakePortalBackend()
  ..on('GET', _me, PortalReply.fixture('me.garnier.get.200.json'))
  ..on(
    'GET',
    _requests,
    PortalReply.fixture('clinics.paris.requests.garnier.get.200.json'),
  )
  ..on(
    'GET',
    _pets,
    PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
  )
  ..on(
    'GET',
    '$_pets/$_oscar',
    PortalReply.fixture('clinics.paris.pet.garnier-oscar.get.200.json'),
  )
  ..on(
    'GET',
    '$_pets/$_oscar/care-items',
    PortalReply.fixture(
      'clinics.paris.pet.care-items.garnier-oscar.get.200.json',
    ),
  )
  ..on(
    'GET',
    '$_pets/$_oscar/timeline',
    PortalReply.fixture(
      'clinics.paris.pet.timeline.garnier-oscar.get.200.json',
    ),
  )
  ..on(
    'GET',
    '$_pets/$_oscar/timeline?cursor=$_oscarCursor',
    PortalReply.fixture(
      'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
    ),
  )
  ..on(
    'GET',
    '$_pets/$_nala',
    PortalReply.fixture('clinics.paris.pet.garnier-nala.get.200.json'),
  )
  ..on(
    'GET',
    '$_pets/$_nala/care-items',
    PortalReply.fixture(
      'clinics.paris.pet.care-items.garnier-nala.get.200.json',
    ),
  )
  ..on('GET', '$_pets/$_nala/timeline', PortalReply.fixture(_noVisit))
  ..on(
    'GET',
    '$_pets/$_filou',
    PortalReply.fixture('clinics.paris.pet.garnier-filou.get.200.json'),
  )
  ..on('GET', '$_pets/$_filou/care-items', PortalReply.json('[]'))
  ..on('GET', '$_pets/$_filou/timeline', PortalReply.fixture(_noVisit));

/// Julien signed in, Paris active: Oslo, his weight change pending.
FakePortalBackend _julien() => FakePortalBackend()
  ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    _requests,
    PortalReply.fixture('clinics.paris.requests.get.200.json'),
  )
  ..on('GET', _pets, PortalReply.fixture('clinics.paris.pets.get.200.json'))
  ..on(
    'GET',
    '$_pets/$_oslo',
    PortalReply.fixture('clinics.paris.pet.get.200.json'),
  )
  ..on(
    'GET',
    '$_pets/$_oslo/care-items',
    PortalReply.fixture('clinics.paris.pet.care-items.get.200.json'),
  )
  ..on('GET', '$_pets/$_oslo/timeline', PortalReply.fixture(_noVisit));

/// A PDF view without PDFium: the size of what it received.
Widget _fakePdfView(BuildContext context, List<int> bytes, String source) =>
    Center(child: Text('pdf:${bytes.length}'));

final Uint8List _pdfBytes = File('$portalFixtures/files.documents.get.200.pdf')
    .readAsBytesSync();

int _visits(ProviderContainer container, String petId) =>
    switch (container.read(petTimelineProvider(petId))) {
      AsyncData(:final value) => value.items.length,
      _ => -1,
    };

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  /// The page on [backend]; with [route], the page follows its route
  /// (pet id, request) as the router would rebuild it.
  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    String? petId,
    ValueNotifier<(String?, Object?)>? route,
    SessionManager? session,
  }) async => await pumpPage(
    tester,
    ValueListenableBuilder<(String?, Object?)>(
      valueListenable: route ?? ValueNotifier((petId, null)),
      builder: (context, value, _) => PetPage(
        petId: value.$1,
        request: value.$2,
        onBack: (context) => exits.add('back'),
      ),
    ),
    session: session ?? await memorySession(pair('A')),
    backend: backend,
    overrides: [
      activeClinicStoreProvider.overrideWithValue(InMemoryActiveClinicStore()),
      pdfViewBuilderProvider.overrideWithValue(_fakePdfView),
    ],
  );

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -30000),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Oscar: the switcher, his identity, care items and the first '
      'visits; the next page read at the end, then no more', (tester) async {
    final backend = _garnier();
    final container = await pump(tester, backend, petId: _oscar);

    final switcher = tester.widget<KivetoSegmentedControl<PetId>>(
      find.byType(KivetoSegmentedControl<PetId>),
    );
    expect(switcher.segments.map((s) => s.label), [
      'Coco',
      'Nala',
      'Oscar',
      'Pepito',
      'Filou',
    ]);
    expect(switcher.selected, const PetId(_oscar));
    expect(
      find.ancestor(
        of: find.byType(KivetoSegmentedControl<PetId>),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
      ),
      findsOneWidget,
    );

    final avatar = tester.widget<InitialsAvatar>(find.byType(InitialsAvatar));
    expect(avatar.initials, 'O');
    expect(avatar.size, 64);
    expect(avatar.tone, AvatarTone.green);
    expect(find.text('Oscar'), findsNWidgets(2));
    expect(
      find.text('Chien · Labrador retriever · Mâle castré'),
      findsOneWidget,
    );
    expect(find.text('Né le'), findsOneWidget);
    expect(find.text('02/08/2015'), findsOneWidget);
    expect(find.text('Poids'), findsOneWidget);
    expect(find.text('34,9 kg · 27 sept.', findRichText: true), findsOneWidget);
    expect(find.text('Puce'), findsOneWidget);
    expect(find.text('•••• 0446'), findsOneWidget);
    expect(find.text('Suivi par'), findsOneWidget);
    expect(find.text('Dr Lucie Bernard'), findsOneWidget);
    expect(find.text('Signaler une modification'), findsOneWidget);
    expect(
      find.text('Vérifiée par la clinique avant mise à jour de la fiche.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('CHPPiL'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Vaccins et préventions'), findsOneWidget);
    expect(find.text('Carnet PDF'), findsOneWidget);
    expect(find.text('Vermifugation'), findsOneWidget);
    expect(find.text('À faire depuis le 13 oct.'), findsOneWidget);
    expect(find.text('En retard'), findsNWidgets(2));
    expect(find.text("Valide jusqu'au 16 avr. 2027"), findsNWidgets(3));
    expect(find.text('À jour'), findsNWidgets(3));

    await tester.scrollUntilVisible(
      find.text('Bilan thyroïdien'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('18 août 2026 · Dr Lucie Bernard'), findsOneWidget);
    final latest = tester.widget<TimelineItem>(
      find.ancestor(
        of: find.text('Bilan thyroïdien'),
        matching: find.byType(TimelineItem),
      ),
    );
    expect(latest.latest, isTrue);
    expect(
      find.descendant(
        of: find.byWidget(latest),
        matching: find.text('Compte-rendu'),
      ),
      findsOneWidget,
    );
    expect(_visits(container, _oscar), 20);
    expect(
      backend.requestsTo('$_pets/$_oscar/timeline?cursor=$_oscarCursor'),
      isEmpty,
    );

    await scrollToEnd(tester);
    await scrollToEnd(tester);

    expect(_visits(container, _oscar), 23);
    expect(
      backend.requestsTo('$_pets/$_oscar/timeline?cursor=$_oscarCursor'),
      hasLength(1),
    );
    expect(
      backend.requests.where((r) => r.uri.path.endsWith('/timeline')),
      hasLength(2),
    );
    expect(exits, isEmpty);
  });

  testWidgets('the switcher shows Nala without navigating: female, '
      'spayed, no chip, a care due in 6 days', (tester) async {
    final backend = _garnier();
    await pump(tester, backend, petId: _oscar);

    await tester.tap(find.text('Nala'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KivetoSegmentedControl<PetId>>(
            find.byType(KivetoSegmentedControl<PetId>),
          )
          .selected,
      const PetId(_nala),
    );
    expect(find.text('Chat · Européen · Femelle stérilisée'), findsOneWidget);
    expect(find.text('Née le'), findsOneWidget);
    expect(find.text('02/10/2022'), findsOneWidget);
    expect(find.text('4,25 kg · 6 août', findRichText: true), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Dr Éric Rousseau'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Typhus-Coryza'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Prochain avant le 9 nov.'), findsOneWidget);
    expect(find.text('Dans 6 j'), findsOneWidget);
    expect(
      tester
          .widget<StatusPill>(
            find.ancestor(
              of: find.text('Dans 6 j'),
              matching: find.byType(StatusPill),
            ),
          )
          .tone,
      StatusTone.warning,
    );
    await scrollToEnd(tester);
    expect(
      find.text('Aucune consultation partagée pour le moment.'),
      findsOneWidget,
    );
    expect(exits, isEmpty);
  });

  testWidgets('Filou, deceased: the neutral pill, no care item, no visit', (
    tester,
  ) async {
    await pump(tester, _garnier(), petId: _filou);

    expect(find.text('Filou'), findsNWidgets(2));
    expect(
      tester
          .widget<StatusPill>(
            find.ancestor(
              of: find.text('Décédé'),
              matching: find.byType(StatusPill),
            ),
          )
          .tone,
      StatusTone.neutral,
    );
    await scrollToEnd(tester);
    expect(find.text('Aucun soin préventif à suivre.'), findsOneWidget);
    expect(
      find.text('Aucune consultation partagée pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('Julien, the Animaux tab: Oslo, no switcher; unknown sex '
      'dropped, no chip nor vet', (tester) async {
    await pump(tester, _julien());

    expect(find.byType(KivetoSegmentedControl<PetId>), findsNothing);
    expect(find.text('Oslo'), findsOneWidget);
    expect(find.text('Chien · Labrador'), findsOneWidget);
    expect(find.text('Né le'), findsOneWidget);
    expect(find.text('02/03/2020'), findsOneWidget);
    expect(find.text('24,3 kg · 5 sept.', findRichText: true), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('Rage'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CHPL'), findsOneWidget);
    expect(find.text("Valide jusqu'au 5 sept. 2027"), findsNWidgets(2));
    expect(find.text('À jour'), findsNWidgets(2));
  });

  testWidgets('a pet the clinic does not list (another clinic): the first '
      'pet', (tester) async {
    await pump(tester, _julien(), petId: _oscar);

    expect(find.text('Oslo'), findsOneWidget);
    expect(find.text('Chien · Labrador'), findsOneWidget);
  });

  testWidgets('no pet: « Aucun animal » naming the clinic', (tester) async {
    final backend = _julien()..on('GET', _pets, PortalReply.json('[]'));
    await pump(tester, backend);

    expect(find.text('Aucun animal'), findsOneWidget);
    expect(
      find.text(
        'Les animaux suivis par Clinique Vétérinaire de Paris apparaîtront '
        'ici.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(KivetoIconButton));
    expect(exits, ['back']);
  });

  testWidgets('the sheet, the care items and the visits fail on their own, '
      'each with its retry; the rest of the page stays', (tester) async {
    final failing = {'sheet': true, 'care': true, 'visits': true};
    PortalHandler failingUntilFixed(String part, String fixture) =>
        (_) => failing[part]!
        ? problem('service_unavailable', 503)
        : PortalReply.fixture(fixture);
    final backend = _julien()
      ..onRequest(
        'GET',
        '$_pets/$_oslo',
        failingUntilFixed('sheet', 'clinics.paris.pet.get.200.json'),
      )
      ..onRequest(
        'GET',
        '$_pets/$_oslo/care-items',
        failingUntilFixed('care', 'clinics.paris.pet.care-items.get.200.json'),
      )
      ..onRequest(
        'GET',
        '$_pets/$_oslo/timeline',
        failingUntilFixed('visits', _noVisit),
      );
    await pump(tester, backend);

    expect(find.text('Oslo'), findsOneWidget);
    expect(find.text('Chien · Labrador'), findsOneWidget);
    expect(find.text('Signaler une modification'), findsOneWidget);
    expect(find.byType(ErrorView, skipOffstage: false), findsNWidgets(3));

    failing['sheet'] = false;
    await tester.tap(find.text('Réessayer').first);
    await tester.pumpAndSettle();
    expect(find.text('24,3 kg · 5 sept.', findRichText: true), findsOneWidget);
    expect(find.byType(ErrorView, skipOffstage: false), findsNWidgets(2));

    failing['care'] = false;
    await tester.ensureVisible(find.text('Réessayer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réessayer').first);
    await tester.pumpAndSettle();
    expect(find.text('CHPL'), findsOneWidget);

    failing['visits'] = false;
    await scrollToEnd(tester);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsNothing);
    expect(
      find.text('Aucune consultation partagée pour le moment.'),
      findsOneWidget,
    );
    expect(backend.requestsTo('$_pets/$_oslo'), hasLength(2));
    expect(backend.requestsTo('$_pets/$_oslo/care-items'), hasLength(2));
    expect(backend.requestsTo('$_pets/$_oslo/timeline'), hasLength(2));
  });

  testWidgets('the pets fail: an error and its retry', (tester) async {
    var fail = true;
    final backend = _julien()
      ..onRequest(
        'GET',
        _pets,
        (_) => fail
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('clinics.paris.pets.get.200.json'),
      );
    await pump(tester, backend);
    expect(find.text('Service indisponible'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Chien · Labrador'), findsOneWidget);
  });

  testWidgets('/me fails: the pets show its error; the retry reads /me '
      'again', (tester) async {
    var fail = true;
    final backend = _julien()
      ..onRequest(
        'GET',
        _me,
        (_) => fail
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('me.get.200.json'),
      );
    await pump(tester, backend);
    expect(find.text('Service indisponible'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Oslo'), findsOneWidget);
    expect(backend.requestsTo(_me), hasLength(2));
  });

  group('the booklet', () {
    const booklet = '$_pets/$_oscar/vaccination-booklet';
    const signed =
        '/api/portal/v1/files/booklets/$_paris/$_oscar/h?_expiration=1&_hash=x';

    Future<void> openBooklet(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Carnet PDF'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Carnet PDF'));
      await tester.pumpAndSettle();
    }

    testWidgets('« Carnet PDF »: the viewer over the page, the PDF of the '
        '302', (tester) async {
      final backend = _garnier()
        ..on(
          'GET',
          booklet,
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
      await pump(tester, backend, petId: _oscar);

      await openBooklet(tester);

      expect(find.text('Carnet de vaccination · Oscar'), findsOneWidget);
      expect(find.text('pdf:${_pdfBytes.length}'), findsOneWidget);
      expect(backend.requestsTo(booklet), hasLength(1));
      expect(backend.requestsTo(signed), hasLength(1));

      await tester.tap(find.byType(KivetoIconButton).last);
      await tester.pumpAndSettle();
      expect(find.byType(PdfFilePage), findsNothing);
      expect(exits, isEmpty);
    });

    testWidgets('503: « Service indisponible » and a retry; 404: « Document '
        'indisponible »', (tester) async {
      var answer = problem('service_unavailable', 503);
      final backend = _garnier()..onRequest('GET', booklet, (_) => answer);
      await pump(tester, backend, petId: _oscar);

      await openBooklet(tester);
      expect(find.text('Service indisponible'), findsOneWidget);

      answer = problem('not_found', 404);
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(find.text('Document indisponible'), findsOneWidget);
      expect(backend.requestsTo(booklet), hasLength(2));
    });
  });

  testWidgets('back is the exit; « Signaler une modification » opens the '
      'change request sheet of the pet shown', (tester) async {
    await pump(tester, _garnier(), petId: _oscar);

    await tester.tap(find.byType(KivetoIconButton));
    expect(exits, ['back']);

    await tester.tap(find.text('Signaler une modification'));
    await tester.pumpAndSettle();

    final sheet = find.byType(PetChangeSheet);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(
        of: sheet,
        matching: find.text(
          'Pour Oscar. La clinique vérifie chaque modification avant de '
          'mettre à jour la fiche.',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Filou, deceased: the button stays; the sheet shows the '
      "server's pet_not_eligible (capture)", (tester) async {
    final backend = _garnier()
      ..on(
        'POST',
        '$_pets/$_filou/change-requests',
        PortalReply.fixture(
          'clinics.paris.pet.change-requests.not-eligible.post.422.json',
          status: 422,
        ),
      );
    await pump(tester, backend, petId: _filou);

    await tester.tap(find.text('Signaler une modification'));
    await tester.pumpAndSettle();
    expect(find.byType(PetChangeSheet), findsOneWidget);

    await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Poids'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(KivetoTextField, 'Nouveau poids (kg)'),
      '5,2',
    );
    await tester.pumpAndSettle();
    final send = find.widgetWithText(KivetoButton, 'Envoyer la demande');
    await tester.ensureVisible(send);
    await tester.pumpAndSettle();
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Cet animal ne peut plus faire l'objet d'une demande de "
        'modification\u00a0: contactez la clinique.',
      ),
      findsOneWidget,
    );
    expect(backend.requestsTo('$_pets/$_filou/change-requests'), hasLength(1));
  });

  group('« Demandes en cours »', () {
    testWidgets("Julien: Oslo's weight waiting for the clinic", (tester) async {
      await pump(tester, _julien());

      expect(find.text('Demandes en cours'), findsOneWidget);
      expect(find.text('Poids\u00a0: 25,1\u00a0kg'), findsOneWidget);
      expect(find.text('Envoyée le 2\u00a0nov.\u00a02026'), findsOneWidget);
      expect(find.widgetWithText(StatusPill, 'En attente'), findsOneWidget);
    });

    testWidgets('Garnier: none for Oscar (his weight rejected, a '
        "renewal); Pepito's chip number, Coco's other change", (tester) async {
      final route = ValueNotifier<(String?, Object?)>((_oscar, null));
      await pump(tester, _garnier(), route: route);

      expect(find.text('Oscar'), findsWidgets);
      expect(find.text('Demandes en cours'), findsNothing);

      route.value = (_pepito, null);
      await tester.pumpAndSettle();
      expect(find.text('Demandes en cours'), findsOneWidget);
      expect(find.text('Puce\u00a0: 250268731000453'), findsOneWidget);

      route.value = ('01a19a10-221c-78b5-9b4f-9c333d05a6d0', null);
      await tester.pumpAndSettle();
      expect(find.text('Autre\u00a0: Allergie au vermifuge'), findsOneWidget);
      expect(find.text('Puce\u00a0: 250268731000453'), findsNothing);
    });

    testWidgets('the requests fail: a callout and its retry; the rest of '
        'the sheet stays', (tester) async {
      var failing = true;
      final backend = _julien()
        ..onRequest(
          'GET',
          _requests,
          (_) => failing
              ? problem('service_unavailable', 503)
              : PortalReply.fixture('clinics.paris.requests.get.200.json'),
        );
      await pump(tester, backend);

      expect(
        find.text("Impossible d'afficher vos demandes en cours."),
        findsOneWidget,
      );
      expect(find.text('Vaccins et préventions'), findsOneWidget);

      failing = false;
      await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
      await tester.pumpAndSettle();

      expect(
        find.text("Impossible d'afficher vos demandes en cours."),
        findsNothing,
      );
      expect(find.text('Poids\u00a0: 25,1\u00a0kg'), findsOneWidget);
      expect(backend.requestsTo(_requests), hasLength(2));
    });

    testWidgets('a weight sent from the sheet shows pending at once', (
      tester,
    ) async {
      var sent = false;
      final backend = _julien()
        ..onRequest('POST', '$_pets/$_oslo/change-requests', (_) {
          sent = true;
          return PortalReply.fixture(
            'clinics.paris.pet.change-requests.post.202.json',
            status: 202,
          );
        })
        ..onRequest(
          'GET',
          _requests,
          (_) => sent
              ? _edited(
                  'clinics.paris.requests.get.200.json',
                  (body) =>
                      ((body! as Map<String, Object?>)['items']!
                              as List<Object?>)
                          .insert(0, {
                            'id': '01a1a413-c972-7eb1-b861-3e83365ac982',
                            'kind': 'pet_change',
                            'petId': _oslo,
                            'field': 'weight',
                            'proposedValue': '26,2',
                            'prescriptionId': null,
                            'status': 'submitted',
                            'submittedAt': '2026-11-03T11:22:40+01:00',
                            'resolvedAt': null,
                            'resolutionMessage': null,
                            'resultingPrescriptionId': null,
                          }),
                )
              : PortalReply.fixture('clinics.paris.requests.get.200.json'),
        );
      await pump(tester, backend);

      await tester.tap(find.text('Signaler une modification'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Poids'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(KivetoTextField, 'Nouveau poids (kg)'),
        '26,2',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(KivetoButton, 'Envoyer la demande'));
      await tester.pumpAndSettle();
      expect(find.text('Demande envoyée'), findsOneWidget);

      await tester.tap(find.widgetWithText(KivetoButton, 'Fermer'));
      await tester.pumpAndSettle();

      expect(find.byType(PetChangeSheet), findsNothing);
      expect(find.text('Poids\u00a0: 26,2\u00a0kg'), findsOneWidget);
      expect(find.text('Poids\u00a0: 25,1\u00a0kg'), findsOneWidget);
      expect(find.text('Envoyée le 3\u00a0nov.\u00a02026'), findsOneWidget);
      expect(backend.requestsTo(_requests), hasLength(2));
    });
  });

  testWidgets('the sheet dismissed while the request is on its way: the '
      'requests read again once it answers, the new one pending', (
    tester,
  ) async {
    final answer = Completer<PortalReply>();
    var sent = false;
    final backend = _julien()
      ..onRequest('POST', '$_pets/$_oslo/change-requests', (_) {
        sent = true;
        return answer.future;
      })
      ..onRequest(
        'GET',
        _requests,
        (_) => sent
            ? _edited(
                'clinics.paris.requests.get.200.json',
                (body) =>
                    ((body! as Map<String, Object?>)['items']! as List<Object?>)
                        .insert(0, {
                          'id': '01a1a413-c972-7eb1-b861-3e83365ac982',
                          'kind': 'pet_change',
                          'petId': _oslo,
                          'field': 'name',
                          'proposedValue': 'Oslo II',
                          'prescriptionId': null,
                          'status': 'submitted',
                          'submittedAt': '2026-11-03T11:22:40+01:00',
                          'resolvedAt': null,
                          'resolutionMessage': null,
                          'resultingPrescriptionId': null,
                        }),
              )
            : PortalReply.fixture('clinics.paris.requests.get.200.json'),
      );
    await pump(tester, backend);

    await tester.tap(find.text('Signaler une modification'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Nom'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(KivetoTextField, 'Nouveau nom'),
      'Oslo II',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(KivetoButton, 'Envoyer la demande'));
    await tester.pump();

    // The scrim tapped: the sheet goes, the request is still on its way.
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    expect(find.byType(PetChangeSheet), findsNothing);
    expect(backend.requestsTo(_requests), hasLength(1));

    answer.complete(
      PortalReply.fixture(
        'clinics.paris.pet.change-requests.post.202.json',
        status: 202,
      ),
    );
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_requests), hasLength(2));
    expect(find.text('Nom\u00a0: Oslo II'), findsOneWidget);
  });

  testWidgets('pull-to-refresh reads the pets, the sheet, the care items, '
      'the requests and the visits again', (tester) async {
    final backend = _julien();
    await pump(tester, backend);

    await tester.fling(
      find.byType(CustomScrollView).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    for (final path in [
      _pets,
      '$_pets/$_oslo',
      '$_pets/$_oslo/care-items',
      _requests,
      '$_pets/$_oslo/timeline',
    ]) {
      expect(backend.requestsTo(path), hasLength(2), reason: path);
    }
    expect(backend.requestsTo(_me), hasLength(1));
  });

  testWidgets('a pet near the end of a long switcher is scrolled into '
      'view', (tester) async {
    final backend = _garnier()
      ..on(
        'GET',
        '$_pets/$_pepito/timeline',
        PortalReply.fixture(
          'clinics.paris.pet.timeline.garnier-pepito.get.200.json',
        ),
      );
    await pump(tester, backend, petId: _pepito);

    final scroll = tester.widget<SingleChildScrollView>(
      find.ancestor(
        of: find.byType(KivetoSegmentedControl<PetId>),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scroll.controller!.offset, greaterThan(0));
    expect(
      find
          .descendant(
            of: find.byType(KivetoSegmentedControl<PetId>),
            matching: find.text('Pepito'),
          )
          .hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('the pets answer 404 (link gone): the retry reads /me again', (
    tester,
  ) async {
    final backend = _julien()..on('GET', _pets, problem('not_found', 404));
    await pump(tester, backend);
    expect(backend.requestsTo(_me), hasLength(1));

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_me), hasLength(2));
    expect(backend.requestsTo(_pets), hasLength(2));
  });

  group("the switcher's choice", () {
    PetId shown(WidgetTester tester) => tester
        .widget<KivetoSegmentedControl<PetId>>(
          find.byType(KivetoSegmentedControl<PetId>),
        )
        .selected;

    testWidgets("another route's pet after a pick: that pet", (tester) async {
      final route = ValueNotifier<(String?, Object?)>((_oscar, null));
      await pump(tester, _garnier(), route: route);
      await tester.tap(find.text('Nala'));
      await tester.pumpAndSettle();
      expect(shown(tester), const PetId(_nala));

      route.value = (_filou, null);
      await tester.pumpAndSettle();

      expect(shown(tester), const PetId(_filou));
      expect(find.text('Décédé'), findsOneWidget);
    });

    testWidgets("a new navigation to the same pet: the route's pet again", (
      tester,
    ) async {
      final route = ValueNotifier<(String?, Object?)>((_oscar, Object()));
      await pump(tester, _garnier(), route: route);
      await tester.tap(find.text('Nala'));
      await tester.pumpAndSettle();
      expect(shown(tester), const PetId(_nala));

      route.value = (_oscar, Object());
      await tester.pumpAndSettle();

      expect(shown(tester), const PetId(_oscar));
      expect(
        find.text('Chien · Labrador retriever · Mâle castré'),
        findsOneWidget,
      );
    });

    testWidgets('a pull-to-refresh of the same list keeps the choice', (
      tester,
    ) async {
      final backend = _garnier();
      await pump(tester, backend, petId: _oscar);
      await tester.tap(find.text('Nala'));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(backend.requestsTo(_pets), hasLength(2));
      expect(shown(tester), const PetId(_nala));
      expect(find.text('Chat · Européen · Femelle stérilisée'), findsOneWidget);
    });
  });

  testWidgets('another session: the pets are read again with its tokens', (
    tester,
  ) async {
    final session = await memorySession(pair('A'));
    final backend = _julien()
      ..onRequest(
        'GET',
        _me,
        (request) => bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('me.garnier.get.200.json')
            : PortalReply.fixture('me.get.200.json'),
      )
      ..onRequest(
        'GET',
        _pets,
        (request) => bearerOf(request) == 'Bearer A'
            ? PortalReply.fixture('clinics.paris.pets.garnier.get.200.json')
            : PortalReply.fixture('clinics.paris.pets.get.200.json'),
      )
      ..on(
        'GET',
        '$_pets/$_oscar',
        PortalReply.fixture('clinics.paris.pet.garnier-oscar.get.200.json'),
      )
      ..on('GET', '$_pets/$_oscar/care-items', PortalReply.json('[]'))
      ..on('GET', '$_pets/$_oscar/timeline', PortalReply.fixture(_noVisit));
    await pump(tester, backend, petId: _oscar, session: session);
    expect(
      find.text('Chien · Labrador retriever · Mâle castré'),
      findsOneWidget,
    );

    await session.open(pair('B'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_pets).map(bearerOf), ['Bearer A', 'Bearer B']);
    expect(bearerOf(backend.requestsTo('$_pets/$_oslo').last), 'Bearer B');
    expect(find.text('Chien · Labrador'), findsOneWidget);
    expect(find.text('Oscar'), findsNothing);
    expect(find.byType(KivetoSegmentedControl<PetId>), findsNothing);
  });

  testWidgets('a retry in flight shows the skeleton, not the error and its '
      'retry', (tester) async {
    var calls = 0;
    final held = Completer<void>();
    final backend = _julien()
      ..onRequest('GET', _pets, (request) async {
        if (calls++ == 0) return problem('service_unavailable', 503);
        await held.future;
        return PortalReply.fixture('clinics.paris.pets.get.200.json');
      });
    await pump(tester, backend);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(find.byType(KivetoSkeleton), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);

    held.complete();
    await tester.pumpAndSettle();
    expect(find.text('Chien · Labrador'), findsOneWidget);
  });

  testWidgets('a clinic switch drops the choice: back on Paris, the '
      "route's pet", (tester) async {
    const lyon = '01960000-0000-7000-8000-000000000101';
    const pixel = '01a19a10-d1df-75fb-acf1-2987bfc236b8';
    const lyonPets = '$api/clinics/$lyon/pets';
    final backend = _garnier()
      ..on(
        'GET',
        lyonPets,
        PortalReply.fixture('clinics.lyon.pets.get.200.json'),
      )
      ..on(
        'GET',
        '$lyonPets/$pixel',
        PortalReply.fixture('clinics.lyon.pet.get.200.json'),
      )
      ..on(
        'GET',
        '$lyonPets/$pixel/care-items',
        PortalReply.fixture('clinics.lyon.pet.care-items.get.200.json'),
      )
      ..on(
        'GET',
        '$lyonPets/$pixel/timeline',
        PortalReply.fixture('clinics.lyon.pet.timeline.get.200.json'),
      );
    final container = await pump(tester, backend, petId: _oscar);
    await tester.tap(find.text('Nala'));
    await tester.pumpAndSettle();
    expect(find.text('Chat · Européen · Femelle stérilisée'), findsOneWidget);

    await container
        .read(activeClinicProvider.notifier)
        .select(const ClinicId(lyon));
    await tester.pumpAndSettle();
    expect(find.text('Pixel'), findsOneWidget);

    await container
        .read(activeClinicProvider.notifier)
        .select(const ClinicId(_paris));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KivetoSegmentedControl<PetId>>(
            find.byType(KivetoSegmentedControl<PetId>),
          )
          .selected,
      const PetId(_oscar),
    );
    expect(
      find.text('Chien · Labrador retriever · Mâle castré'),
      findsOneWidget,
    );
  });

  testWidgets('the sheet answers 404 (the pet left the list): the retry '
      'reads the pets and /me again', (tester) async {
    final backend = _julien()
      ..on(
        'GET',
        '$_pets/$_oslo',
        PortalReply.fixture(
          'clinics.paris.pet.not-found.get.404.json',
          status: 404,
        ),
      );
    await pump(tester, backend);
    expect(backend.requestsTo(_pets), hasLength(1));
    expect(backend.requestsTo(_me), hasLength(1));

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_pets), hasLength(2));
    expect(backend.requestsTo(_me), hasLength(2));
    expect(backend.requestsTo('$_pets/$_oslo'), hasLength(2));
  });

  for (final (part, path, done) in [
    ('the identity grid', '$_pets/$_oslo', 'clinics.paris.pet.get.200.json'),
    (
      'the care items',
      '$_pets/$_oslo/care-items',
      'clinics.paris.pet.care-items.get.200.json',
    ),
  ]) {
    testWidgets('a retry of $part in flight shows its loading, not the '
        'error and its retry', (tester) async {
      var calls = 0;
      final held = Completer<void>();
      final backend = _julien()
        ..onRequest('GET', path, (request) async {
          if (calls++ == 0) return problem('service_unavailable', 503);
          await held.future;
          return PortalReply.fixture(done);
        });
      await pump(tester, backend);
      await tester.ensureVisible(find.text('Réessayer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Réessayer'), findsNothing);

      held.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ErrorView), findsNothing);
      expect(backend.requestsTo(path), hasLength(2));
    });
  }
}
