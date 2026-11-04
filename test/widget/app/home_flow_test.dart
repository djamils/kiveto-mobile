// Slice 3 in the real app (router, shell, seams, PortalHttp on the fake
// backend): the home under the bottom nav, its exits (a pet's sheet in the
// Animaux tab and back home, the appointments and documents tabs, the
// booking over the shell), the questionnaire filled from the home (slice 6:
// back on the appointments, its banner and the home's button gone), the
// change request sheet of a pet, and switching to Lyon (the home, the pets,
// the documents, the badge, a restart).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/home/home.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/portal_api/fake_portal_backend.dart';
import '../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _lyon = '01960000-0000-7000-8000-000000000101';
const _julienId = '01a19a10-d011-70c8-8daf-26e4db824374';
const _oslo = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _pixel = '01a19a10-d1df-75fb-acf1-2987bfc236b8';
const _appointment = '01a19a12-6840-7d19-bf1f-7604a862c028';
const _me = '$api/me';

String _location(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .toString();

/// The pushed match on top of the current configuration.
String _top(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;

/// The capture [fixture] with [change] applied to its JSON body.
PortalReply _edited(
  String fixture,
  void Function(Map<String, Object?> body) change,
) {
  final body = jsonDecode(
    File('$portalFixtures/$fixture').readAsStringSync(),
  ) as Map<String, Object?>;
  change(body);
  return PortalReply.json(jsonEncode(body));
}

/// Julien's Paris home with its questionnaire not started.
PortalReply _questionnaireToFill() {
  final body = jsonDecode(
    File('$portalFixtures/clinics.paris.home.get.200.json').readAsStringSync(),
  ) as Map<String, Object?>;
  (body['nextAppointment']! as Map<String, Object?>)['questionnaireStatus'] =
      'not_started';
  return PortalReply.json(jsonEncode(body));
}

/// Julien signed in: his /me, and for both clinics the home, the pets, the
/// pet's sheet, care items and visits, the documents, the requests.
FakePortalBackend _julien() {
  final backend = FakePortalBackend()
    ..on('GET', _me, PortalReply.fixture('me.get.200.json'));
  for (final (clinic, name, pet) in [
    (_paris, 'paris', _oslo),
    (_lyon, 'lyon', _pixel),
  ]) {
    final base = '$api/clinics/$clinic';
    backend
      ..on(
        'GET',
        '$base/home',
        PortalReply.fixture('clinics.$name.home.get.200.json'),
      )
      ..on(
        'GET',
        '$base/pets',
        PortalReply.fixture('clinics.$name.pets.get.200.json'),
      )
      ..on(
        'GET',
        '$base/pets/$pet',
        PortalReply.fixture('clinics.$name.pet.get.200.json'),
      )
      ..on(
        'GET',
        '$base/pets/$pet/care-items',
        PortalReply.fixture('clinics.$name.pet.care-items.get.200.json'),
      )
      ..on(
        'GET',
        '$base/pets/$pet/timeline',
        PortalReply.fixture('clinics.$name.pet.timeline.get.200.json'),
      )
      ..on(
        'GET',
        '$base/documents',
        PortalReply.fixture('clinics.$name.documents.get.200.json'),
      )
      ..on(
        'GET',
        '$base/requests?limit=50',
        clinic == _paris
            ? PortalReply.fixture('clinics.paris.requests.get.200.json')
            : PortalReply.json('{"items":[],"nextCursor":null}'),
      );
  }
  return backend;
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Julien, Paris: the home under the bottom nav, Accueil '
      'active; a pet card opens its sheet in the Animaux tab, back goes '
      'home', (tester) async {
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: _julien(),
    );

    expect(_location(container), AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Bonjour Julien'), findsOneWidget);
    expect(find.text('Mer. 11 nov. · 10:30'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(
      tester.widget<KivetoBottomNav>(find.byType(KivetoBottomNav)).currentIndex,
      0,
    );

    await tester.tap(find.text('Oslo'));
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.pet(_oslo));
    expect(tester.widget<PetPage>(find.byType(PetPage)).petId, _oslo);
    expect(find.text('Chien · Labrador'), findsOneWidget);
    // A sibling of /pets: nothing under it.
    expect(container.read(routerProvider).canPop(), isFalse);

    await tester.tap(find.byType(KivetoIconButton).first);
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.home);
    expect(find.text('Bonjour Julien'), findsOneWidget);
  });

  testWidgets('« Gérer » opens the Rendez-vous tab, « Tout voir » the '
      'Documents tab, « Prendre rendez-vous » pushes the booking over the '
      'shell', (tester) async {
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: _julien(),
    );

    await tester.tap(find.text('Gérer'));
    await tester.pumpAndSettle();
    expect(_location(container), AppRoutes.appointments);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Tout voir'));
    expect(_location(container), AppRoutes.documents);
    expect(find.byType(DocumentsPage), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Prendre rendez-vous'));
    expect(_top(container), AppRoutes.bookingPet);
    expect(find.text('Pour quel animal ?'), findsOneWidget);
    expect(find.text('Accueil'), findsNothing);
  });

  testWidgets('« Remplir le questionnaire » pushes the questionnaire; once '
      'sent, the appointments without its banner, the home without its '
      'button', (tester) async {
    const base = '$api/clinics/$_paris';
    const questionnaire = '$base/appointments/$_appointment/questionnaire';
    var sent = false;
    final backend = _julien()
      ..onRequest(
        'GET',
        '$base/home',
        (_) => sent
            ? PortalReply.fixture('clinics.paris.home.get.200.json')
            : _questionnaireToFill(),
      )
      ..on(
        'GET',
        '$base/appointments/$_appointment',
        _edited('clinics.paris.appointment.get.200.json', (body) {
          body['id'] = _appointment;
          body['startAt'] = '2026-11-11T10:30:00+01:00';
          body['endAt'] = '2026-11-11T11:00:00+01:00';
          (body['motif']! as Map<String, Object?>)['label'] = 'Rendez-vous';
        }),
      )
      ..on(
        'GET',
        questionnaire,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.get.200.json',
        ),
      )
      ..onRequest('PUT', questionnaire, (_) {
        sent = true;
        return PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.put.200.json',
        );
      })
      ..on(
        'GET',
        '$base/appointments?scope=upcoming',
        _edited('clinics.paris.appointments.upcoming.get.200.json', (body) {
          for (final item in body['items']! as List<Object?>) {
            (item! as Map<String, Object?>)['questionnaireStatus'] =
                'submitted';
          }
        }),
      );
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
    );

    await tester.tap(find.text('Remplir le questionnaire'));
    await tester.pumpAndSettle();

    expect(_top(container), AppRoutes.questionnaire(_appointment));
    expect(find.text('Avant la consultation'), findsOneWidget);
    expect(
      find.text('Oslo · Rendez-vous · mer. 11 nov. à 10:30'),
      findsOneWidget,
    );
    expect(find.text('Rien de particulier'), findsOneWidget);

    await _tapVisible(tester, find.text('Non'));
    await _tapVisible(tester, find.text('Calme'));
    await tester.tap(find.text('Envoyer à la clinique'));
    await tester.pumpAndSettle();

    expect(_location(container), AppRoutes.appointments);
    expect(find.text('Questionnaire envoyé à la clinique.'), findsOneWidget);
    expect(find.text('Questionnaire à compléter'), findsNothing);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(find.text('Remplir le questionnaire'), findsNothing);
    expect(backend.requestsTo('$base/home'), hasLength(2));
  });

  testWidgets('the Animaux tab: the first pet; « Signaler une '
      'modification » opens its change request sheet', (tester) async {
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: _julien(),
    );

    await tester.tap(find.text('Animaux'));
    await tester.pumpAndSettle();
    expect(_location(container), AppRoutes.pets);
    expect(find.text('Oslo'), findsOneWidget);

    await tester.tap(find.text('Signaler une modification'));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('Signaler une modification'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.text(
          'Pour Oslo. La clinique vérifie chaque modification avant de '
          'mettre à jour la fiche.',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('switching to Lyon: the home, the Animaux tab and the '
      'Documents tab follow, the badge too; the choice survives a '
      'restart', (tester) async {
    final store = InMemoryActiveClinicStore();
    final backend = _julien();
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
      activeClinicStore: store,
    );
    expect(container.read(unreadDocumentsCountProvider), 1);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Clinique Vétérinaire de Paris'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Clinique Vétérinaire de Lyon'),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.choices, {_julienId: _lyon});
    expect(find.text('Clinique Vétérinaire de Lyon'), findsOneWidget);
    expect(find.text('Pixel'), findsOneWidget);
    expect(backend.requestsTo('$api/clinics/$_lyon/home'), hasLength(1));
    expect(container.read(unreadDocumentsCountProvider), 0);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.text('Animaux'));
    await tester.pumpAndSettle();
    expect(find.text('Pixel'), findsOneWidget);
    expect(find.text('Chat · Chartreux · Mâle'), findsOneWidget);
    expect(backend.requestsTo('$api/clinics/$_lyon/pets'), hasLength(1));

    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();
    expect(backend.requestsTo('$api/clinics/$_lyon/documents'), hasLength(1));
    expect(backend.requestsTo('$api/clinics/$_paris/documents'), isEmpty);
    expect(
      find.text('Partagés par Clinique Vétérinaire de Lyon'),
      findsOneWidget,
    );

    // A restart: a new app on the same store.
    final restarted = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.get.200.json'))
      ..on(
        'GET',
        '$api/clinics/$_lyon/home',
        PortalReply.fixture('clinics.lyon.home.get.200.json'),
      );
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: restarted,
      activeClinicStore: store,
    );

    expect(find.text('Clinique Vétérinaire de Lyon'), findsOneWidget);
    expect(find.text('Pixel'), findsOneWidget);
  });

  testWidgets("a pet card opened again after a switcher pick: that pet's "
      'sheet, not the pick', (tester) async {
    const oscar = '01a19a10-20d7-77bd-bbad-d251136402fc';
    const pets = '$api/clinics/$_paris/pets';
    final backend = FakePortalBackend()
      ..on('GET', _me, PortalReply.fixture('me.garnier.get.200.json'))
      ..on(
        'GET',
        '$api/clinics/$_paris/home',
        PortalReply.fixture('clinics.paris.home.garnier.get.200.json'),
      )
      ..on(
        'GET',
        pets,
        PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
      )
      ..on(
        'GET',
        '$pets/$oscar',
        PortalReply.fixture('clinics.paris.pet.garnier-oscar.get.200.json'),
      );
    await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: backend,
    );
    PetId shown() => tester
        .widget<KivetoSegmentedControl<PetId>>(
          find.byType(KivetoSegmentedControl<PetId>),
        )
        .selected;

    await tester.tap(find.text('Oscar'));
    await tester.pumpAndSettle();
    expect(shown(), const PetId(oscar));
    await tester.tap(
      find.descendant(
        of: find.byType(KivetoSegmentedControl<PetId>),
        matching: find.text('Coco'),
      ),
    );
    await tester.pumpAndSettle();
    expect(shown(), const PetId('01a19a10-221c-78b5-9b4f-9c333d05a6d0'));

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscar'));
    await tester.pumpAndSettle();

    expect(shown(), const PetId(oscar));
    expect(
      find.text('Chien · Labrador retriever · Mâle castré'),
      findsOneWidget,
    );
  });

  testWidgets('/pets/:petId reached by go_router: the pet page of that id', (
    tester,
  ) async {
    final container = await pumpKivetoApp(
      tester,
      session: await memorySession(pair('A')),
      backend: _julien(),
      initialLocation: AppRoutes.pet(_oslo),
    );

    expect(_location(container), AppRoutes.pet(_oslo));
    expect(find.text('Oslo'), findsOneWidget);
  });
}
