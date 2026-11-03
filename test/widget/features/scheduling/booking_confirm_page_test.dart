// Screen 14 on the captures: the recap of Oslo / Consultation / Dupont /
// Monday 10:00, the booking (its body, its key), « Rendez-vous confirmé »
// and its exits, « Demande envoyée », a new pet, the failures (a new pet
// refused, the slot taken, no network and its retry with the same key, the
// business codes), the clinic without address, a questionnaire sent.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_confirm_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _book = '$parisBase/appointments';
const _bookNewPet = '$parisBase/appointments/with-new-pet';

void main() {
  late List<String> exits;
  late List<PortalFile> shared;

  setUp(() {
    exits = [];
    shared = [];
  });

  Widget page() => BookingConfirmPage(
    onDone: (context) => exits.add('done'),
    onFillQuestionnaire: (context, id) => exits.add('questionnaire $id'),
    onEditSlot: (context) => exits.add('slot'),
    onSlotTaken: (context) => exits.add('taken'),
    onEditPet: (context) => exits.add('pet'),
    onBack: (context) => exits.add('back'),
    onClose: (context) => exits.add('close'),
  );

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    BookingPet pet = oslo,
  }) => pumpStep(
    tester,
    page(),
    backend: backend,
    pet: pet,
    motif: consultation,
    practitioner: dupont,
    slot: monday10,
    overrides: [
      calendarSharerProvider.overrideWithValue((file) async {
        shared.add(file);
      }),
    ],
  );

  testWidgets('the recap: Oslo, « Consultation · 30 min », « Lundi 9 '
      'novembre à 10:00 » and « Modifier », Dupont, the clinic and its '
      'address, the reassurance lines', (tester) async {
    await pump(tester, julienBackend());

    expect(find.text('Étape 4 sur 4'), findsOneWidget);
    expect(find.text('Vérifiez et confirmez'), findsOneWidget);
    for (final text in [
      'Animal',
      'Oslo',
      'Motif',
      'Consultation · 30 min',
      'Date',
      'Lundi 9 novembre à 10:00',
      'Vétérinaire',
      'Dr Marc Dupont',
      'Clinique',
      'Clinique Vétérinaire de Paris',
      '18 rue des Abbesses, 75018 Paris',
      "Annulation et report en ligne jusqu'au délai fixé par la clinique",
      'Questionnaire de 2 min avant la visite',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    await tester.tap(find.text('Modifier'));
    await tester.tap(iconButton(LucideGlyph.chevronLeft));
    await tester.tap(iconButton(LucideGlyph.x));
    expect(exits, ['slot', 'back', 'close']);
  });

  testWidgets('confirmed (capture): one POST with the slot and the key; the '
      'success, the calendar, the questionnaire, « Plus tard », back; the '
      'lists and the care items reload', (tester) async {
    final backend = julienBackend()
      ..on(
        'POST',
        _book,
        PortalReply.fixture(
          'clinics.paris.appointments.post.201.json',
          status: 201,
        ),
      )
      ..on(
        'GET',
        '$parisBase/pets/$osloId/care-items',
        PortalReply.fixture('clinics.paris.pet.care-items.get.200.json'),
      )
      ..on(
        'GET',
        '$_book/$bookedId/calendar.ics',
        PortalReply.bytes(
          utf8.encode('BEGIN:VCALENDAR\r\nEND:VCALENDAR\r\n'),
          contentType: 'text/calendar',
        ),
      );
    final container = await pump(tester, backend);
    container.listen(careItemsProvider(const PetId(osloId)), (_, _) {});
    await tester.pumpAndSettle();
    final key = container.read(bookingWizardProvider).draft.key;

    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    final post = backend.requestsTo(_book).single;
    expect(post.headers['Idempotency-Key'], key.value);
    expect(
      utf8.decode(post.body),
      '{"petId":"$osloId","motifId":"$consultationId",'
      '"practitionerId":"$dupontId","startAt":"2026-11-09T10:00:00+01:00"}',
    );
    expect(container.read(appointmentsRevisionProvider), 1);
    expect(
      backend.requestsTo('$parisBase/pets/$osloId/care-items'),
      hasLength(2),
    );
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);
    expect(
      find.text(
        'Lundi 9 novembre à 10:00\nOslo · Consultation · Dr Marc Dupont',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Une confirmation vous a été envoyée.\n'
        "Annulation en ligne possible jusqu'au dim. 8 nov. à 10:00.",
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Ajouter à mon calendrier'));
    await tester.pumpAndSettle();
    expect(shared.single.fileName, 'rendez-vous-2026-11-09.ics');
    expect(shared.single.contentType, 'text/calendar');

    await tester.tap(find.text('Remplir le questionnaire maintenant'));
    await tester.tap(find.text('Plus tard'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(exits, ['questionnaire $bookedId', 'done', 'done']);

    // Done: a second tap sends nothing.
    expect(
      await container.read(bookingWizardProvider.notifier).confirm(),
      BookingOutcome.ignored,
    );
  });

  testWidgets('a confirmation on its way: no exit and no choice changes '
      'the draft, no second POST; its answer for the draft sent; once '
      'booked, no choice either', (tester) async {
    final answer = Completer<PortalReply>();
    final backend = julienBackend()
      ..onRequest('POST', _book, (request) => answer.future);
    final container = await pump(tester, backend);
    final draft = container.read(bookingWizardProvider).draft;

    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pump();
    final wizard = container.read(bookingWizardProvider.notifier)
      ..choosePet(const NewPet('Plume', Species.cat))
      ..chooseMotif(
        const BookingMotif(
          id: MotifId(vaccinationId),
          label: 'Vaccination',
          durationMin: 20,
        ),
      )
      ..choosePractitioner(const Practitioner(id: PractitionerId(rousseauId)))
      ..chooseSlot(dupont, ClinicInstant.parse('2026-11-09T10:15:00+01:00'));

    expect(container.read(bookingWizardProvider).draft, same(draft));
    expect(
      container.read(bookingWizardProvider).submission,
      isA<BookingSubmitting>(),
    );
    expect(await wizard.confirm(), BookingOutcome.ignored);

    // Back, X, « Modifier » and the system back stay on the recap.
    await tester.tap(iconButton(LucideGlyph.chevronLeft));
    await tester.tap(iconButton(LucideGlyph.x));
    await tester.tap(find.text('Modifier'));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(exits, isEmpty);
    expect(find.text('Vérifiez et confirmez'), findsOneWidget);

    answer.complete(
      PortalReply.fixture(
        'clinics.paris.appointments.post.201.json',
        status: 201,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);
    expect(backend.requestsTo(_book), hasLength(1));
    expect(container.read(bookingWizardProvider).draft, same(draft));

    // Booked: a late choice (from a step left under the success) keeps the
    // booking done, its key and its draft.
    wizard.chooseSlot(dupont, ClinicInstant.parse('2026-11-09T10:30:00+01:00'));
    final done = container.read(bookingWizardProvider);
    expect(done.draft, same(draft));
    expect(done.submission, isA<BookingDone>());
  });

  testWidgets('a motif the clinic confirms (capture): « Demande envoyée », '
      'no confirmation promised', (tester) async {
    final backend = julienBackend()
      ..on(
        'POST',
        _book,
        PortalReply.fixture(
          'clinics.paris.appointments.pending.post.201.json',
          status: 201,
        ),
      );
    await pump(tester, backend);

    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    expect(find.text('Demande envoyée'), findsOneWidget);
    expect(
      find.text(
        'La clinique doit confirmer ce rendez-vous. Vous le retrouverez dans '
        'vos rendez-vous.\n'
        "Annulation en ligne possible jusqu'au jeu. 12 nov. à 09:00.",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Une confirmation'), findsNothing);
  });

  testWidgets('a new pet (capture): its line, with-new-pet, the pets read '
      'again', (tester) async {
    final backend = julienBackend()
      ..on(
        'POST',
        _bookNewPet,
        PortalReply.fixture(
          'clinics.paris.appointments.with-new-pet.post.201.json',
          status: 201,
        ),
      );
    final container = await pump(
      tester,
      backend,
      pet: const NewPet('Plume', Species.cat),
    );
    container.listen(petsProvider, (_, _) {});
    await tester.pumpAndSettle();
    final reads = backend.requestsTo('$parisBase/pets').length;

    expect(find.text('Plume'), findsOneWidget);
    expect(find.text('Nouvel animal · Chat'), findsOneWidget);
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    expect(
      (jsonDecode(utf8.decode(backend.requestsTo(_bookNewPet).single.body))
          as Map<String, Object?>)['newPet'],
      {'name': 'Plume', 'species': 'cat'},
    );
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);
    expect(backend.requestsTo('$parisBase/pets'), hasLength(reads + 1));
  });

  testWidgets('a new pet refused (capture): the violation and « Modifier »', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on(
        'POST',
        _bookNewPet,
        PortalReply.fixture(
          'clinics.paris.appointments.with-new-pet.validation.post.422.json',
          status: 422,
        ),
      );
    await pump(tester, backend, pet: const NewPet('Plume', Species.cat));

    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    expect(find.text("Le nom de l'animal est obligatoire."), findsOneWidget);
    await tapVisible(tester, find.text('Modifier').last);
    expect(exits, ['pet']);
  });

  testWidgets('the slot taken (capture): back to the slot step', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on(
        'POST',
        _book,
        PortalReply.fixture(
          'clinics.paris.appointments.slot-taken.post.409.json',
          status: 409,
        ),
      );
    final container = await pump(tester, backend);

    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    expect(exits, ['taken']);
    final state = container.read(bookingWizardProvider);
    expect(state.slotTaken, isTrue);
    expect(state.draft.isTaken(monday10), isTrue);
  });

  testWidgets('no network: the message and « Réessayer », the same key '
      'again', (tester) async {
    final backend = julienBackend();
    final container = await pump(tester, backend);
    final key = container.read(bookingWizardProvider).draft.key;

    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();
    expect(
      find.text('Vérifiez votre connexion Internet, puis réessayez.'),
      findsOneWidget,
    );

    backend.on(
      'POST',
      _book,
      PortalReply.fixture(
        'clinics.paris.appointments.replay.post.201.json',
        status: 201,
      ),
    );
    await tapVisible(tester, find.text('Réessayer'));

    expect(
      backend.requests
          .where((request) => request.method == 'POST')
          .map((request) => request.headers['Idempotency-Key']),
      [key.value, key.value],
    );
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);
  });

  for (final (name, reply, message, edit) in [
    (
      'pet_not_bookable',
      problem('pet_not_bookable', 422),
      'Cet animal ne peut plus prendre rendez-vous en ligne.',
      true,
    ),
    (
      'booking_not_open',
      problem('booking_not_open', 422),
      "La réservation en ligne n'est pas ouverte pour ce motif. Contactez la "
          'clinique.',
      false,
    ),
    (
      'not_found',
      problem('not_found', 404),
      "Ce choix n'est plus disponible. Recommencez la réservation.",
      false,
    ),
    (
      'idempotency_key_reused (capture)',
      PortalReply.fixture(
        'clinics.paris.appointments.key-reused.post.422.json',
        status: 422,
      ),
      "Cette action n'a pas pu aboutir.",
      false,
    ),
  ]) {
    testWidgets('$name: its message${edit ? ' and « Modifier »' : ''}', (
      tester,
    ) async {
      final backend = julienBackend()..on('POST', _book, reply);
      await pump(tester, backend);

      await tester.tap(find.text('Confirmer le rendez-vous'));
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(find.text('Modifier'), findsNWidgets(edit ? 2 : 1));
      expect(find.text('Réessayer'), findsNothing);
    });
  }

  testWidgets('a clinic without address; a questionnaire already sent: « '
      "Retour à l'accueil »", (tester) async {
    final backend = julienBackend()
      ..on('GET', '$api/me', meWithParis((paris) => paris['address'] = null))
      ..on(
        'POST',
        _book,
        editedReply(
          'clinics.paris.appointments.post.201.json',
          (body) => (body! as Map<String, Object?>)['questionnaireStatus'] =
              'submitted',
          status: 201,
        ),
      );
    await pump(tester, backend);

    expect(find.text('Clinique Vétérinaire de Paris'), findsOneWidget);
    expect(find.textContaining('rue des Abbesses'), findsNothing);
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();

    expect(find.text('Remplir le questionnaire maintenant'), findsNothing);
    expect(find.text('Plus tard'), findsNothing);
    await tester.tap(find.text("Retour à l'accueil"));
    expect(exits, ['done']);
  });
}
