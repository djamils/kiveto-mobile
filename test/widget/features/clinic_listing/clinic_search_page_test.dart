// Screen 10 on the captures: the greeting, the record at the account's
// phone (accepted, gone, failed) and the pending link, the directory (by
// name, typed with its debounce, refused, empty, failed), « Autour de
// moi » (the position, its failures), the pages (the next one, its
// failure, a stale cursor), a clinic not on Kiveto and its call, the exit.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_card.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_providers.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_search_page.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/link_suggestion_callouts.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart'
    show phoneDialerProvider;
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _listings = '$api/clinic-listings';
const _suggestions = '$api/me/link-suggestions';
const _suggestionId =
    '6594e0c558ef0df770974b30a390e79f2ce8e3d5152ca9b22310d9d651f92ee4';
const _lyon = '01a19a12-79bb-7408-9051-a42bd37f652d';

PortalReply _edited(String fixture, void Function(Object? body) change) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body));
}

String _cursor() =>
    (jsonDecode(
          File('$portalFixtures/clinic-listings.page1.get.200.json')
              .readAsStringSync(),
        ) as Map<String, Object?>)['nextCursor']!
        as String;

/// A clinic-less account with a pending link to Lyon, the record of Paris
/// at its phone, the whole directory.
FakePortalBackend _backend() => FakePortalBackend()
  ..on('GET', '$api/me', PortalReply.fixture('me.pending-link.get.200.json'))
  ..on(
    'GET',
    _suggestions,
    PortalReply.fixture('me.link-suggestions.get.200.json'),
  )
  ..on('GET', _listings, PortalReply.fixture('clinic-listings.get.200.json'));

Finder _card(String name) => find.byWidgetPredicate(
  (widget) => widget is ClinicCard && widget.clinic.name == name,
);

void main() {
  late List<String> opened;
  late List<Uri> calls;

  setUp(() {
    opened = [];
    calls = [];
  });

  /// The page on a tall phone (the mockup's frame is 1000 high): every card
  /// and the footer are built.
  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    DeviceLocator? locate,
    bool callAnswered = true,
  }) async {
    final container = await pumpPage(
      tester,
      ClinicSearchPage(onOpenListing: (context, id) => opened.add(id)),
      backend: backend,
      session: await memorySession(pair('A')),
      overrides: [
        if (locate != null) deviceLocationProvider.overrideWithValue(locate),
        phoneDialerProvider.overrideWithValue((uri) async {
          calls.add(uri);
          return callAnswered;
        }),
      ],
    );
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();
  }

  testWidgets('first view: the greeting, the record found, the pending link, '
      'the directory by name in the server order', (tester) async {
    final backend = _backend();
    await pump(tester, backend);

    expect(
      find.widgetWithText(KivetoPageHeader, 'Bonjour Test'),
      findsOneWidget,
    );
    expect(
      find.text('Trouvez votre clinique pour prendre rendez-vous.'),
      findsOneWidget,
    );
    expect(
      find.text('Clinique Vétérinaire de Paris a un dossier à votre numéro'),
      findsOneWidget,
    );
    expect(
      find.text('Rattachez-le pour retrouver vos animaux et votre historique.'),
      findsOneWidget,
    );
    expect(find.text('Rattacher ce dossier'), findsOneWidget);
    expect(
      find.text('Rattachement demandé : Clinique Vétérinaire de Lyon'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PendingLinkCallout),
        matching: find.text('En attente'),
      ),
      findsOneWidget,
    );
    expect(find.byType(KivetoSearchField), findsOneWidget);
    expect(find.text('Nom ou ville'), findsOneWidget);
    expect(find.text('Autour de moi'), findsOneWidget);
    expect(find.text('3 cliniques'), findsOneWidget);
    expect(
      tester
          .widgetList<ClinicCard>(find.byType(ClinicCard))
          .map((card) => card.clinic.name),
      [
        'Clinique du Vercors',
        'Clinique Vétérinaire de Lyon',
        'Clinique Vétérinaire de Paris',
      ],
    );
    expect(
      find.descendant(
        of: _card('Clinique du Vercors'),
        matching: find.text('Rurale'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _card('Clinique Vétérinaire de Lyon'),
        matching: find.text(
          '7 quai Saint-Antoine, Bâtiment B, 69002 Lyon · Équidés · NAC',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _card('Clinique Vétérinaire de Lyon'),
        matching: find.widgetWithText(StatusPill, 'RDV en ligne'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(StatusPill, 'RDV en ligne'), findsOneWidget);
    // No next slot in v1.
    expect(find.textContaining('Prochain créneau'), findsNothing);
    expect(backend.requestsTo(_listings), hasLength(1));

    await tester.tap(_card('Clinique Vétérinaire de Lyon'));
    expect(opened, [_lyon]);
  });

  testWidgets('without a first name: « Bonjour »', (tester) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        '$api/me',
        _edited('me.no-clinic.get.200.json', (body) {
          ((body! as Map<String, Object?>)['account']!
                  as Map<String, Object?>)['firstName'] =
              null;
        }),
      ),
    );

    expect(find.widgetWithText(KivetoPageHeader, 'Bonjour'), findsOneWidget);
    expect(find.byType(PendingLinkCallout), findsNothing);
  });

  testWidgets('the records cannot be checked: a danger callout and a retry, '
      'the directory shown', (tester) async {
    final backend = _backend()
      ..on('GET', _suggestions, problem('service_unavailable', 503));
    await pump(tester, backend);

    expect(
      find.text('Impossible de vérifier les dossiers à votre numéro.'),
      findsOneWidget,
    );
    expect(find.text('3 cliniques'), findsOneWidget);

    backend.on(
      'GET',
      _suggestions,
      PortalReply.fixture('me.link-suggestions.empty.get.200.json'),
    );
    await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de vérifier les dossiers à votre numéro.'),
      findsNothing,
    );
    expect(find.byType(LinkSuggestionCallout), findsNothing);
  });

  testWidgets('« Rattacher ce dossier »: the POST, then /me and the records '
      'read again; the pending link replaces the record', (tester) async {
    final accepted = Completer<void>();
    final backend = _backend()
      ..on('GET', '$api/me', PortalReply.fixture('me.no-clinic.get.200.json'))
      ..onRequest('POST', '$_suggestions/$_suggestionId/accept', (
        request,
      ) async {
        await accepted.future;
        return PortalReply.fixture(
          'me.link-suggestions.accept.post.202.json',
          status: 202,
        );
      });
    await pump(tester, backend);
    expect(find.byType(PendingLinkCallout), findsNothing);

    await tester.tap(find.text('Rattacher ce dossier'));
    await tester.pump();
    final button = tester.widget<KivetoButton>(
      find.descendant(
        of: find.byType(LinkSuggestionCallout),
        matching: find.byType(KivetoButton),
      ),
    );
    expect(button.loading, isTrue);

    backend
      ..on(
        'GET',
        '$api/me',
        _edited('me.pending-link.get.200.json', (body) {
          (((body! as Map<String, Object?>)['clinics']! as List).first
                  as Map<String, Object?>)['name'] =
              'Clinique Vétérinaire de Paris';
        }),
      )
      ..on(
        'GET',
        _suggestions,
        PortalReply.fixture('me.link-suggestions.empty.get.200.json'),
      );
    accepted.complete();
    await tester.pumpAndSettle();

    expect(
      backend.requestsTo('$_suggestions/$_suggestionId/accept'),
      hasLength(1),
    );
    expect(backend.requestsTo('$api/me'), hasLength(2));
    expect(backend.requestsTo(_suggestions), hasLength(2));
    expect(find.byType(LinkSuggestionCallout), findsNothing);
    expect(
      find.text('Rattachement demandé : Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
  });

  testWidgets("a record no longer offered: « Ce dossier n'est plus "
      'proposé. », the records read again', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        '$_suggestions/$_suggestionId/accept',
        PortalReply.fixture(
          'me.link-suggestions.accept.unknown.post.404.json',
          status: 404,
        ),
      );
    await pump(tester, backend);
    backend.on(
      'GET',
      _suggestions,
      PortalReply.fixture('me.link-suggestions.empty.get.200.json'),
    );

    await tester.tap(find.text('Rattacher ce dossier'));
    await tester.pumpAndSettle();

    expect(find.text("Ce dossier n'est plus proposé."), findsOneWidget);
    expect(backend.requestsTo(_suggestions), hasLength(2));
    expect(find.byType(LinkSuggestionCallout), findsNothing);
  });

  testWidgets('another failure of the acceptance: its message, the record '
      'kept', (tester) async {
    final backend = _backend()
      ..on(
        'POST',
        '$_suggestions/$_suggestionId/accept',
        problem('rate_limited', 429),
      );
    await pump(tester, backend);

    await tester.tap(find.text('Rattacher ce dossier'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(LinkSuggestionCallout), findsOneWidget);
  });

  testWidgets('typing searches once settled: q trimmed, the results '
      'replace the list; cleared, the whole directory again', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_listings?q=Lyon',
        PortalReply.fixture('clinic-listings.search.get.200.json'),
      );
    await pump(tester, backend);

    await tester.enterText(find.byType(TextField), 'Ly');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), ' Lyon ');
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();

    expect(find.text('1 clinique'), findsOneWidget);
    expect(_card('Clinique Vétérinaire de Lyon'), findsOneWidget);
    expect(_card('Clinique du Vercors'), findsNothing);
    // Nothing sent for « Ly »: the typing had not settled.
    expect(
      backend.requests.where((request) => request.uri.path == _listings),
      hasLength(2),
    );

    await type(tester, '');
    expect(find.text('3 cliniques'), findsOneWidget);
  });

  testWidgets("a short query: the server's message in place of the results", (
    tester,
  ) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        '$_listings?q=a',
        PortalReply.fixture(
          'clinic-listings.validation.get.422.json',
          status: 422,
        ),
      ),
    );

    await type(tester, 'a');

    expect(find.text('Saisissez au moins 2 caractères.'), findsOneWidget);
    expect(find.byType(ClinicCard), findsNothing);
  });

  testWidgets('nothing found: « Aucune clinique trouvée »', (tester) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        '$_listings?q=Zz',
        PortalReply.fixture('clinic-listings.search-empty.get.200.json'),
      ),
    );

    await type(tester, 'Zz');

    expect(find.text('Aucune clinique trouvée'), findsOneWidget);
    expect(
      find.text('Essayez un autre nom ou une autre ville.'),
      findsOneWidget,
    );
  });

  testWidgets('the directory failed: the error view and a retry', (
    tester,
  ) async {
    final backend = _backend()
      ..on('GET', _listings, problem('rate_limited', 429));
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);

    backend.on(
      'GET',
      _listings,
      PortalReply.fixture('clinic-listings.get.200.json'),
    );
    await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('3 cliniques'), findsOneWidget);
  });

  testWidgets('« Autour de moi »: « Localisation… » while it reads, then the '
      'search by distance with the text, « à proximité », the km; tapped '
      'again, the name order', (tester) async {
    final position = Completer<GeoPoint>();
    final backend = _backend()
      ..on(
        'GET',
        '$_listings?q=Paris',
        PortalReply.fixture('clinic-listings.search-empty.get.200.json'),
      )
      ..on(
        'GET',
        '$_listings?q=Paris&lat=48.88&lng=2.33',
        PortalReply.fixture('clinic-listings.near.get.200.json'),
      );
    await pump(tester, backend, locate: () => position.future);
    await type(tester, 'Paris');

    await tester.tap(find.text('Autour de moi'));
    await tester.pump();
    expect(find.text('Localisation…'), findsOneWidget);
    expect(
      tester
          .widget<KivetoSummaryChip>(find.byType(KivetoSummaryChip))
          .onPressed,
      isNull,
    );

    position.complete(const GeoPoint(48.88, 2.33));
    await tester.pumpAndSettle();

    expect(find.text('1 clinique à proximité'), findsOneWidget);
    expect(
      find.text(
        '18 rue des Abbesses, 75018 Paris · 2,1 km · Chats · Chiens · '
        'NAC · Urgences · Dentisterie · Imagerie · Comportement · '
        'Ostéopathie',
      ),
      findsOneWidget,
    );
    final chip = tester.widget<KivetoSummaryChip>(
      find.byType(KivetoSummaryChip),
    );
    expect(chip.label, 'Autour de moi');
    expect(chip.trailingGlyph, isNotNull);

    await tester.tap(find.byType(KivetoSummaryChip));
    await tester.pumpAndSettle();
    expect(find.text('Aucune clinique trouvée'), findsOneWidget);
    expect(
      tester
          .widget<KivetoSummaryChip>(find.byType(KivetoSummaryChip))
          .trailingGlyph,
      isNull,
    );
  });

  for (final (problem, message) in [
    (
      LocationProblem.denied,
      "Autorisez l'accès à votre position pour voir les cliniques autour de "
          'vous.',
    ),
    (
      LocationProblem.deniedForever,
      "L'accès à votre position est refusé pour Kiveto : autorisez-le dans "
          'les réglages du téléphone.',
    ),
    (
      LocationProblem.disabled,
      'Activez la localisation de votre téléphone pour voir les cliniques '
          'autour de vous.',
    ),
    (
      LocationProblem.failed,
      "Votre position n'a pas pu être déterminée. Réessayez.",
    ),
  ]) {
    testWidgets('no position ($problem): its SnackBar, the search unchanged', (
      tester,
    ) async {
      final backend = _backend();
      await pump(
        tester,
        backend,
        locate: () async => throw LocationFailure(problem),
      );

      await tester.tap(find.text('Autour de moi'));
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(find.text('3 cliniques'), findsOneWidget);
      expect(find.text('Autour de moi'), findsOneWidget);
      expect(backend.requestsTo(_listings), hasLength(1));
    });
  }

  testWidgets('page after page: the footer reads the next page; its failure '
      'and retry; a stale cursor reloads the first page', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        _listings,
        PortalReply.fixture('clinic-listings.page1.get.200.json'),
      )
      ..on(
        'GET',
        '$_listings?cursor=${_cursor()}',
        problem('service_unavailable', 503),
      );
    await pump(tester, backend);

    expect(find.text('Impossible de charger la suite.'), findsOneWidget);
    expect(find.byType(ClinicCard), findsNWidgets(2));
    // No total in the API: a next page remains.
    expect(find.text('Plus de 2 cliniques'), findsOneWidget);

    backend.on(
      'GET',
      '$_listings?cursor=${_cursor()}',
      PortalReply.fixture('clinic-listings.page2.get.200.json'),
    );
    await tester.ensureVisible(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(find.byType(ClinicCard), findsNWidgets(3));
    expect(find.text('3 cliniques'), findsOneWidget);
    expect(find.text('Impossible de charger la suite.'), findsNothing);
  });

  testWidgets('a stale cursor: the search read again from its first page', (
    tester,
  ) async {
    var firstPages = 0;
    final backend = _backend()
      ..onRequest('GET', _listings, (request) {
        firstPages++;
        return PortalReply.fixture(
          firstPages == 1
              ? 'clinic-listings.page1.get.200.json'
              : 'clinic-listings.get.200.json',
        );
      })
      ..on(
        'GET',
        '$_listings?cursor=${_cursor()}',
        PortalReply.fixture(
          'clinic-listings.cursor-invalid.get.400.json',
          status: 400,
        ),
      );
    await pump(tester, backend);

    expect(firstPages, 2);
    expect(find.text('3 cliniques'), findsOneWidget);
  });

  testWidgets('a clinic not on Kiveto: dashed, « Pas encore sur Kiveto », '
      '« Appeler » dials it, not tappable; a refused call says so', (
    tester,
  ) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        _listings,
        _edited('clinic-listings.get.200.json', (body) {
          final items = (body! as Map<String, Object?>)['items']! as List;
          (items[2] as Map<String, Object?>)['onKiveto'] = false;
        }),
      ),
      callAnswered: false,
    );
    final paris = _card('Clinique Vétérinaire de Paris');

    expect(
      find.descendant(of: paris, matching: find.byType(KivetoDashedBorder)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: paris, matching: find.text('Pas encore sur Kiveto')),
      findsOneWidget,
    );
    await tester.ensureVisible(paris);
    await tester.tap(
      find.descendant(
        of: paris,
        matching: find.text('Clinique Vétérinaire de Paris'),
      ),
    );
    expect(opened, isEmpty);

    final call = find.descendant(of: paris, matching: find.text('Appeler'));
    await tester.ensureVisible(call);
    await tester.pumpAndSettle();
    await tester.tap(call);
    await tester.pumpAndSettle();

    expect(calls, [Uri(scheme: 'tel', path: '+33142551890')]);
    expect(find.text("Impossible de lancer l'appel."), findsOneWidget);
  });

  testWidgets('a next slot from the server: « Prochain créneau : … »', (
    tester,
  ) async {
    await pump(
      tester,
      _backend()..on(
        'GET',
        _listings,
        _edited('clinic-listings.get.200.json', (body) {
          final items = (body! as Map<String, Object?>)['items']! as List;
          (items[1] as Map<String, Object?>)['nextAvailableAt'] =
              '2026-11-05T13:00:00+01:00';
        }),
      ),
    );

    expect(
      find.descendant(
        of: _card('Clinique Vétérinaire de Lyon'),
        matching: find.text('Prochain créneau : Jeu. 5 nov. · 13:00'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Prochain créneau'), findsOneWidget);
  });

  testWidgets('around a position: « Plus de … à proximité » while a page '
      'remains; nothing within reach says to search by name', (tester) async {
    var near = 'clinic-listings.page1.get.200.json';
    final backend = _backend()
      ..onRequest(
        'GET',
        '$_listings?lat=48.88&lng=2.33',
        (request) => PortalReply.fixture(near),
      )
      ..on(
        'GET',
        '$_listings?lat=48.88&lng=2.33&cursor=${_cursor()}',
        problem('service_unavailable', 503),
      );
    await pump(
      tester,
      backend,
      locate: () async => const GeoPoint(48.88, 2.33),
    );

    await tester.tap(find.text('Autour de moi'));
    await tester.pumpAndSettle();
    expect(find.text('Plus de 2 cliniques à proximité'), findsOneWidget);

    near = 'clinic-listings.search-empty.get.200.json';
    await tester.fling(
      find.byType(CustomScrollView),
      // A quarter of the tall view is the refresh distance.
      const Offset(0, 800),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune clinique trouvée'), findsOneWidget);
    expect(
      find.text(
        "Aucune clinique de l'annuaire autour de vous. Touchez "
        '« Autour de moi » pour chercher par nom.',
      ),
      findsOneWidget,
    );
    expect(find.text('Essayez un autre nom ou une autre ville.'), findsNothing);
  });

  testWidgets('pull-to-refresh: /me, the records and the search read again', (
    tester,
  ) async {
    final backend = _backend();
    await pump(tester, backend);

    await tester.fling(
      find.byType(CustomScrollView),
      // A quarter of the tall view is the refresh distance.
      const Offset(0, 800),
      1000,
    );
    await tester.pumpAndSettle();

    expect(backend.requestsTo('$api/me'), hasLength(2));
    expect(backend.requestsTo(_suggestions), hasLength(2));
    expect(backend.requestsTo(_listings), hasLength(2));
  });

  testWidgets('a position that cannot be read still searches the text typed '
      'just before', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        '$_listings?q=Lyon',
        PortalReply.fixture('clinic-listings.search.get.200.json'),
      );
    await pump(
      tester,
      backend,
      locate: () async => throw const LocationFailure(LocationProblem.failed),
    );

    await tester.enterText(find.byType(TextField), 'Lyon');
    await tester.pump();
    await tester.tap(find.text('Autour de moi'));
    await tester.pumpAndSettle();

    expect(backend.requestsTo('$_listings?q=Lyon'), hasLength(1));
    expect(find.text('1 clinique'), findsOneWidget);
  });
}
