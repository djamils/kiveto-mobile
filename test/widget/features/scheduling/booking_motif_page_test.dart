// Screen 13 on the captures: Paris's motifs for Oslo (none chosen), a
// suggested one first and chosen, a new pet (no petId), the emergency
// callout and its call, a clinic without phone, booking closed, no motif,
// a failure and its retry.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_motif_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

/// The motifs capture with Vaccination suggested.
PortalReply _vaccinationSuggested() =>
    editedReply('clinics.paris.booking.motifs.get.200.json', (body) {
      final vaccination = (body! as List<Object?>)[1]! as Map<String, Object?>;
      vaccination['suggested'] = true;
      vaccination['suggestionReason'] = 'Rappel de vaccin à prévoir';
    });

void main() {
  late List<String> exits;
  late List<Uri> calls;

  setUp(() {
    exits = [];
    calls = [];
  });

  Widget page() => BookingMotifPage(
    onContinue: (context) => exits.add('continue'),
    onBack: (context) => exits.add('back'),
    onClose: (context) => exits.add('close'),
  );

  KivetoRadioCard card(WidgetTester tester, String title) => tester
      .widget<KivetoRadioCard>(find.widgetWithText(KivetoRadioCard, title));

  testWidgets('Oslo, Paris: step 2, the three motifs with their length and '
      'description, none chosen; the emergency callout calls the clinic', (
    tester,
  ) async {
    final backend = julienBackend();
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      overrides: [
        phoneDialerProvider.overrideWithValue((uri) async {
          calls.add(uri);
          return true;
        }),
      ],
    );

    expect(find.text('Étape 2 sur 4'), findsOneWidget);
    expect(find.text('Quel est le motif ?'), findsOneWidget);
    expect(
      find.text('Pour Oslo · Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
    expect(
      find.text(
        '30 min · Un problème de santé, un avis, un contrôle de routine.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('20 min · Primo-vaccination ou rappel annuel.'),
      findsOneWidget,
    );
    for (final title in ['Consultation', 'Vaccination', 'Contrôle / suivi']) {
      expect(card(tester, title).selected, isFalse);
    }
    expect(find.text('Rappel à faire'), findsNothing);
    expect(find.text('Motif'), findsOneWidget);
    expect(find.text('Choisissez un motif'), findsOneWidget);
    expect(enabled(tester, 'Continuer'), isFalse);
    expect(backend.requestsTo('$motifsPath?petId=$osloId'), hasLength(1));
    expect(
      find.text('Urgence ? Ne réservez pas en ligne, appelez la clinique.'),
      findsOneWidget,
    );

    await tapVisible(tester, find.text('Appeler'));
    expect(calls, [Uri.parse('tel:+33142551890')]);

    await tester.tap(iconButton(LucideGlyph.chevronLeft));
    await tester.tap(iconButton(LucideGlyph.x));
    expect(exits, ['back', 'close']);
  });

  testWidgets('a motif chosen: the bar names it; « Continuer » keeps it in '
      'the draft', (tester) async {
    final container = await pumpStep(
      tester,
      page(),
      backend: julienBackend(),
      pet: oslo,
    );

    await tester.tap(find.text('Consultation'));
    await tester.pumpAndSettle();
    expect(card(tester, 'Consultation').selected, isTrue);
    expect(find.text('Consultation'), findsNWidgets(2));

    await tester.tap(button('Continuer'));
    await tester.pumpAndSettle();
    expect(exits, ['continue']);
    expect(
      container.read(bookingWizardProvider).draft.motif?.id,
      const MotifId(consultationId),
    );
  });

  testWidgets('a suggested motif: first, « Rappel à faire », its reason, '
      'chosen', (tester) async {
    final backend = julienBackend()
      ..on('GET', '$motifsPath?petId=$osloId', _vaccinationSuggested());
    await pumpStep(tester, page(), backend: backend, pet: oslo);

    final titles = tester
        .widgetList<KivetoRadioCard>(find.byType(KivetoRadioCard))
        .map((card) => card.title);
    expect(titles, ['Vaccination', 'Consultation', 'Contrôle / suivi']);
    expect(find.widgetWithText(StatusPill, 'Rappel à faire'), findsOneWidget);
    expect(find.text('20 min · Rappel de vaccin à prévoir'), findsOneWidget);
    expect(card(tester, 'Vaccination').selected, isTrue);
    expect(enabled(tester, 'Continuer'), isTrue);
  });

  testWidgets('a new pet: the motifs without petId', (tester) async {
    final backend = julienBackend();
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: const NewPet('Plume', Species.cat),
    );

    expect(backend.requestsTo(motifsPath), hasLength(1));
    expect(
      find.text('Pour Plume · Clinique Vétérinaire de Paris'),
      findsOneWidget,
    );
  });

  testWidgets('a clinic without phone: the callout without a button', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on('GET', '$api/me', meWithParis((paris) => paris['phone'] = null));
    await pumpStep(tester, page(), backend: backend, pet: oslo);

    expect(
      find.text(
        'Urgence ? Ne réservez pas en ligne, appelez directement la clinique.',
      ),
      findsOneWidget,
    );
    expect(find.text('Appeler'), findsNothing);
  });

  testWidgets('no app takes the call: a snack bar', (tester) async {
    await pumpStep(
      tester,
      page(),
      backend: julienBackend(),
      pet: oslo,
      overrides: [
        phoneDialerProvider.overrideWithValue(
          (uri) async => throw StateError('no dialer'),
        ),
      ],
    );

    await tapVisible(tester, find.text('Appeler'));
    expect(find.text("Impossible de lancer l'appel."), findsOneWidget);
  });

  testWidgets('booking closed (422 booking_not_open)', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        '$motifsPath?petId=$osloId',
        problem('booking_not_open', 422),
      );
    await pumpStep(tester, page(), backend: backend, pet: oslo);
    expect(find.text('Réservation en ligne indisponible'), findsOneWidget);
  });

  testWidgets('a failure and its retry; no motif', (tester) async {
    final backend = julienBackend()
      ..on('GET', '$motifsPath?petId=$osloId', problem('oops', 503));
    final container = await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
    );
    expect(find.byType(ErrorView), findsOneWidget);
    backend.on('GET', '$motifsPath?petId=$osloId', PortalReply.json('[]'));
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun motif en ligne'), findsOneWidget);
    expect(container.read(bookingWizardProvider).draft.pet, oslo);
  });
}
