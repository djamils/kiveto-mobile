// Screen 12 on the captures: Julien's pets (Oslo chosen), the clinic chip
// and its switcher, a new pet (name and species), no pet followed, the
// deceased left out, the failures; the draft and its key across a /me
// reload, a clinic switch and another session.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_pet_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  Widget page() => BookingPetPage(
    onContinue: (context) => exits.add('continue'),
    onClose: (context) => exits.add('close'),
  );

  KivetoRadioCard card(WidgetTester tester, String title) => tester
      .widget<KivetoRadioCard>(find.widgetWithText(KivetoRadioCard, title));

  testWidgets('Julien, Paris: step 1, the clinic chip, Oslo chosen, « Un '
      'autre animal », the footnote; « Continuer » books for Oslo', (
    tester,
  ) async {
    final container = await pumpStep(tester, page(), backend: julienBackend());

    expect(find.text('Étape 1 sur 4'), findsOneWidget);
    expect(find.text('Pour quel animal ?'), findsOneWidget);
    final chip = tester.widget<KivetoSummaryChip>(
      find.byType(KivetoSummaryChip),
    );
    expect(chip.label, 'Clinique Vétérinaire de Paris');
    expect(chip.trailingGlyph, LucideGlyph.chevronDown);
    expect(find.text('Chien · Labrador · 6 ans'), findsOneWidget);
    expect(card(tester, 'Oslo').selected, isTrue);
    expect(find.text('Un autre animal'), findsOneWidget);
    expect(
      find.text(
        'Un nouvel animal est ajouté à votre dossier dès la réservation ; '
        'la clinique complète sa fiche lors de la visite.',
      ),
      findsOneWidget,
    );
    expect(find.text('Rendez-vous pour'), findsOneWidget);
    expect(find.text('Oslo'), findsNWidgets(2));
    final key = container.read(bookingWizardProvider).draft.key;

    await tester.tap(button('Continuer'));
    await tester.pumpAndSettle();

    expect(exits, ['continue']);
    final draft = container.read(bookingWizardProvider).draft;
    expect(draft.pet, oslo);
    expect(draft.clinicId, const ClinicId(parisId));
    expect(draft.key, isNot(key));

    // Back on the step and on again with the same pet: the same intent.
    await tester.tap(button('Continuer'));
    await tester.pumpAndSettle();
    expect(container.read(bookingWizardProvider).draft.key, draft.key);
  });

  testWidgets('the chip opens the clinic switcher (2 clinics); back and '
      'close leave', (tester) async {
    await pumpStep(tester, page(), backend: julienBackend());

    await tester.tap(find.byType(KivetoSummaryChip));
    await tester.pumpAndSettle();
    expect(find.text('Changer de clinique'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(iconButton(LucideGlyph.chevronLeft));
    await tester.tap(iconButton(LucideGlyph.x));
    expect(exits, ['close', 'close']);
  });

  testWidgets('one confirmed clinic: the chip is plain', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$api/me',
        editedReply('me.get.200.json', (body) {
          final clinics =
              (body! as Map<String, Object?>)['clinics']! as List<Object?>;
          (clinics.last! as Map<String, Object?>)['linkStatus'] = 'pending';
        }),
      );
    await pumpStep(tester, page(), backend: backend);

    final chip = tester.widget<KivetoSummaryChip>(
      find.byType(KivetoSummaryChip),
    );
    expect(chip.trailingGlyph, isNull);
    expect(chip.onPressed, isNull);
  });

  testWidgets('« Un autre animal »: the name and the species, then « '
      'Continuer » with the new pet; back to Oslo', (tester) async {
    final container = await pumpStep(tester, page(), backend: julienBackend());

    await tester.tap(find.text('Un autre animal'));
    await tester.pumpAndSettle();
    expect(card(tester, 'Oslo').selected, isFalse);
    expect(find.text("Nom de l'animal"), findsOneWidget);
    for (final species in ['Chien', 'Chat', 'NAC', 'Autre']) {
      expect(find.widgetWithText(KivetoChoiceChip, species), findsOneWidget);
    }
    expect(find.text('Nouvel animal'), findsOneWidget);
    expect(enabled(tester, 'Continuer'), isFalse);

    await tester.enterText(find.byType(TextField), '  Plume ');
    await tester.pumpAndSettle();
    expect(find.text('Plume'), findsOneWidget);
    expect(enabled(tester, 'Continuer'), isFalse);
    await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Chat'));
    await tester.pumpAndSettle();
    expect(enabled(tester, 'Continuer'), isTrue);

    await tester.tap(button('Continuer'));
    await tester.pumpAndSettle();
    expect(
      container.read(bookingWizardProvider).draft.pet,
      const NewPet('Plume', Species.cat),
    );

    // A name over 80 characters is refused.
    await tester.enterText(find.byType(TextField), 'P' * 81);
    await tester.pumpAndSettle();
    expect(enabled(tester, 'Continuer'), isFalse);
    expect(find.text('80 caractères au plus.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'P' * 80);
    await tester.pumpAndSettle();
    expect(enabled(tester, 'Continuer'), isTrue);
    expect(find.text('80 caractères au plus.'), findsNothing);

    await tester.tap(find.text('Oslo'));
    await tester.pumpAndSettle();
    expect(card(tester, 'Oslo').selected, isTrue);
    expect(find.text("Nom de l'animal"), findsNothing);
  });

  testWidgets('no pet followed (capture): the new pet form, already open', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$parisBase/pets',
        PortalReply.fixture('clinics.paris.pets.empty.get.200.json'),
      );
    await pumpStep(tester, page(), backend: backend);

    expect(find.byType(KivetoRadioCard), findsNothing);
    expect(find.text("Nom de l'animal"), findsOneWidget);
    expect(find.text('Nouvel animal'), findsOneWidget);
  });

  testWidgets('a missing pet is not listed', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$parisBase/pets',
        editedReply('clinics.paris.pets.get.200.json', (body) {
          final pets = body! as List<Object?>;
          pets.add({
            ...pets.single! as Map<String, Object?>,
            'id': 'missing-pet',
            'name': 'Filou',
            'initial': 'F',
            'lifeStatus': 'missing',
          });
        }),
      );
    await pumpStep(tester, page(), backend: backend);

    expect(find.text('Filou'), findsNothing);
    expect(find.byType(KivetoRadioCard), findsOneWidget);
    expect(card(tester, 'Oslo').selected, isTrue);
  });

  testWidgets('a deceased pet is not listed (Garnier, capture)', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$parisBase/pets',
        PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
      );
    await pumpStep(tester, page(), backend: backend);

    expect(find.text('Oscar'), findsWidgets);
    expect(find.text('Filou'), findsNothing);
    expect(find.byType(KivetoRadioCard), findsNWidgets(4));
  });

  testWidgets('the pets fail: an error and a retry; a 404 says the clinic is '
      'gone', (tester) async {
    final backend = julienBackend()
      ..on('GET', '$parisBase/pets', problem('service_unavailable', 503));
    await pumpStep(tester, page(), backend: backend);
    expect(find.byType(ErrorView), findsOneWidget);
    int meReads() => backend.requestsTo('$api/me').length;
    final reads = meReads();

    backend.on(
      'GET',
      '$parisBase/pets',
      PortalReply.fixture('clinics.unknown.home.get.404.json', status: 404),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(meReads(), reads);
    expect(find.text('Clinique indisponible'), findsOneWidget);

    backend.on(
      'GET',
      '$parisBase/pets',
      PortalReply.fixture('clinics.paris.pets.get.200.json'),
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    // After the 404, /me says which clinics remain.
    expect(meReads(), reads + 1);
    expect(card(tester, 'Oslo').selected, isTrue);
  });

  testWidgets('the draft: kept while /me reloads; another clinic or another '
      'session starts over with a new key', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$api/clinics/$lyonId/pets',
        PortalReply.fixture('clinics.lyon.pets.get.200.json'),
      );
    final session = await memorySession(pair('A'));
    final container = await pumpStep(
      tester,
      page(),
      backend: backend,
      session: session,
    );
    await tester.tap(button('Continuer'));
    await tester.pumpAndSettle();
    final draft = container.read(bookingWizardProvider).draft;
    expect(draft.pet, oslo);

    container.invalidate(meProvider);
    await tester.pumpAndSettle();
    expect(container.read(bookingWizardProvider).draft, same(draft));

    // A new pet on its way, then another clinic: the form starts over.
    await tester.tap(find.text('Un autre animal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plume');
    await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Chat'));
    await tester.pumpAndSettle();
    // The field and the bar.
    expect(find.text('Plume'), findsNWidgets(2));

    await container
        .read(activeClinicProvider.notifier)
        .select(const ClinicId(lyonId));
    await tester.pumpAndSettle();
    final lyon = container.read(bookingWizardProvider).draft;
    expect(lyon.clinicId, const ClinicId(lyonId));
    expect(lyon.pet, isNull);
    expect(lyon.key, isNot(draft.key));
    expect(card(tester, 'Pixel').selected, isTrue);
    expect(find.text("Nom de l'animal"), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Plume'), findsNothing);
    expect(find.text('Pixel'), findsNWidgets(2));
    await tester.tap(find.text('Un autre animal'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    expect(
      tester
          .widget<KivetoChoiceChip>(
            find.widgetWithText(KivetoChoiceChip, 'Chat'),
          )
          .selected,
      isFalse,
    );

    await session.open(pair('B'));
    await tester.pumpAndSettle();
    expect(container.read(bookingWizardProvider).draft.key, isNot(lyon.key));
  });
}
