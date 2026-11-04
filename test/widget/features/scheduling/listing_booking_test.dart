// The new-client booking of a clinic of the directory on the Lyon captures:
// step 1 (no motif; the motif chip, the practitioners and the slots of the
// listing, the bar, a slot taken), step 2 (the new pet, the recap, the
// request with the draft's key and its success; every refusal: slot_taken,
// already_linked and the booking of the clinic of the same name, the
// request limit, booking_not_open, 404, 429, a name refused under its
// field; a network failure retried with the same key, a new name with a
// new one).

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_confirm_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_slot_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _lyonId = '01a19a12-79bb-7408-9051-a42bd37f652d';
const _lyon = ListingId(_lyonId);
const _base = '$api/clinic-listings/$_lyonId/booking';
const _consultationId = '01a19a10-d3d1-7031-bd42-3d901474af59';
const _lemoineId = '01a19a0e-29db-7550-a605-8ac512a656c1';
const _appointments = '$_base/appointments';
const _clinicName = 'Clinique Vétérinaire de Lyon';

/// The captures of Lyon's new-client requests.
const _fixtures = 'clinic-listings.lyon.booking.appointments';

const _consultation = BookingMotif(
  id: MotifId(_consultationId),
  label: 'Consultation',
  durationMin: 30,
);
const _lemoine = Practitioner(
  id: PractitionerId(_lemoineId),
  displayName: 'Dr Sarah Lemoine',
);
final _thursday13 = ClinicInstant.parse('2026-11-05T13:00:00+01:00');

/// Wednesday 4 November, 08:00 UTC: the first day of the captured window.
final _now = DateTime.utc(2026, 11, 4, 8);

const _availability =
    '$_base/availability?motifId=$_consultationId&practitionerId=$_lemoineId'
    '&from=2026-11-04&to=2026-11-17';

FakePortalBackend _backend() => FakePortalBackend()
  ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    '$_base/practitioners?motifId=$_consultationId',
    PortalReply.fixture(
      'clinic-listings.lyon.booking.practitioners.get.200.json',
    ),
  )
  ..on(
    'GET',
    _availability,
    PortalReply.fixture(
      'clinic-listings.lyon.booking.availability.get.200.json',
    ),
  );

void main() {
  late List<String> exits;
  late Keys keys;

  setUp(() {
    exits = [];
    keys = Keys();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget page,
    FakePortalBackend backend, {
    bool motif = true,
    bool slot = true,
  }) async {
    final container = await pumpPage(
      tester,
      page,
      backend: backend,
      clock: FixedClock(_now),
      session: await memorySession(pair('A')),
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        bookingKeyFactoryProvider.overrideWithValue(keys.next),
      ],
    );
    final booking = container.read(listingBookingProvider(_lyon).notifier);
    if (motif) booking.start(_consultation, clinicName: _clinicName);
    if (slot) booking.chooseSlot(_lemoine, _thursday13);
    await tester.pumpAndSettle();
    return container;
  }

  group('step 1, the slot', () {
    Widget page() => ListingSlotPage(
      listingId: _lyonId,
      onContinue: (context) => exits.add('continue'),
      onEditMotif: (context) => exits.add('motif'),
      onBack: (context) => exits.add('back'),
      onClose: (context) => exits.add('close'),
    );

    testWidgets("no motif chosen: « Choisissez d'abord un motif. » and back", (
      tester,
    ) async {
      await pump(tester, page(), _backend(), motif: false, slot: false);

      expect(find.text('Étape 1 sur 2'), findsOneWidget);
      expect(find.text("Choisissez d'abord un motif."), findsOneWidget);
      expect(find.byType(StickySummaryBar), findsNothing);

      await tester.tap(find.text('Retour'));
      expect(exits, ['back']);
    });

    testWidgets('the motif chip, the practitioners and slots of the listing, '
        'the bar; a slot chosen, « Continuer »', (tester) async {
      final container = await pump(tester, page(), _backend(), slot: false);

      expect(find.text('Étape 1 sur 2'), findsOneWidget);
      expect(find.text('Choisissez un créneau'), findsOneWidget);
      expect(find.text('Créneau'), findsOneWidget);
      expect(find.text('À choisir'), findsOneWidget);
      expect(enabled(tester, 'Continuer'), isFalse);
      expect(
        find.widgetWithText(KivetoChoiceChip, 'Dr Sarah Lemoine'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(KivetoChoiceChip, 'Dr Éric Rousseau'),
        findsOneWidget,
      );

      await tapVisible(
        tester,
        find.byKey(const ValueKey('slot-2026-11-05T13:00:00+01:00')),
      );

      expect(find.text('Jeu. 5 nov. à 13:00'), findsOneWidget);
      final draft = container.read(listingBookingProvider(_lyon)).draft;
      expect(draft.practitioner?.id, _lemoine.id);
      expect(draft.slot, _thursday13);
      await tester.tap(button('Continuer'));
      await tapVisible(
        tester,
        find.widgetWithText(KivetoSummaryChip, 'Consultation · 30 min'),
      );
      expect(exits, ['continue', 'motif']);
    });

    testWidgets('after a slot taken: the availability read again, the slot '
        'struck in its day, the warning', (tester) async {
      final backend = _backend()
        ..on(
          'POST',
          _appointments,
          PortalReply.fixture(
            '$_fixtures.slot-taken.post.409.json',
            status: 409,
          ),
        );
      final container = await pump(tester, page(), backend);
      // The fresh answer no longer has Thursday 13:00.
      backend.on(
        'GET',
        _availability,
        editedReply('clinic-listings.lyon.booking.availability.get.200.json', (
          body,
        ) {
          final thursday =
              ((body! as Map<String, Object?>)['days']! as List<Object?>)[1]!
                  as Map<String, Object?>;
          (thursday['slots']! as List<Object?>).removeAt(0);
        }),
      );
      final booking = container.read(listingBookingProvider(_lyon).notifier)
        ..setPet('Capture', Species.cat);
      final outcome = booking.confirm();
      await tester.pumpAndSettle();
      expect(await outcome, ListingOutcome.slotTaken);

      expect(
        find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('13:00, déjà pris'), findsOneWidget);
      expect(backend.requestsTo(_availability), hasLength(2));
      expect(find.text('À choisir'), findsOneWidget);
      expect(enabled(tester, 'Continuer'), isFalse);
    });
  });

  group('step 2, the pet and the request', () {
    Widget page() => ListingConfirmPage(
      listingId: _lyonId,
      onSeeAppointments: (context) => exits.add('appointments'),
      onBackToDirectory: (context) => exits.add('directory'),
      onSlotTaken: (context) => exits.add('slot taken'),
      onBookAsClient: (context) => exits.add('book'),
      onBack: (context) => exits.add('back'),
      onClose: (context) => exits.add('close'),
    );

    Future<void> fill(WidgetTester tester, {String name = 'Capture'}) async {
      await tester.enterText(
        find.descendant(
          of: find.byType(KivetoTextField),
          matching: find.byType(TextField),
        ),
        name,
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Chat'));
      await tester.pumpAndSettle();
    }

    Future<void> send(WidgetTester tester) async {
      await tester.tap(button('Envoyer la demande'));
      await tester.pumpAndSettle();
    }

    testWidgets("no slot chosen: « Choisissez d'abord un créneau. »", (
      tester,
    ) async {
      await pump(tester, page(), _backend(), slot: false);

      expect(find.text("Choisissez d'abord un créneau."), findsOneWidget);
      expect(find.text("Choisissez d'abord un motif."), findsNothing);
      await tester.tap(find.text('Retour'));
      expect(exits, ['back']);
    });

    testWidgets('the step, the recap, « Envoyer » once named and a species; '
        'sent with the key: « Demande envoyée », screen 4 reloads', (
      tester,
    ) async {
      final backend = _backend()
        ..on(
          'POST',
          _appointments,
          PortalReply.fixture('$_fixtures.post.201.json', status: 201),
        );
      final container = await pump(tester, page(), backend);

      expect(find.text('Étape 2 sur 2'), findsOneWidget);
      expect(find.text('Votre animal'), findsOneWidget);
      expect(find.text("Nom de l'animal"), findsOneWidget);
      for (final (label, value) in [
        ('Clinique', _clinicName),
        ('Motif', 'Consultation · 30 min'),
        ('Date', 'Jeudi 5 novembre à 13:00'),
        ('Vétérinaire', 'Dr Sarah Lemoine'),
      ]) {
        expect(
          find.descendant(
            of: find.widgetWithText(KivetoKeyValueRow, label),
            matching: find.text(value),
          ),
          findsOneWidget,
          reason: label,
        );
      }
      expect(
        find.text(
          'La clinique confirme les rendez-vous des nouveaux clients. Vous '
          'suivez votre demande dans Rendez-vous.',
        ),
        findsOneWidget,
      );
      expect(enabled(tester, 'Envoyer la demande'), isFalse);

      await tester.enterText(find.byType(TextField), 'Capture');
      await tester.pump();
      expect(enabled(tester, 'Envoyer la demande'), isFalse);
      await fill(tester);
      expect(enabled(tester, 'Envoyer la demande'), isTrue);
      final revision = container.read(appointmentsRevisionProvider);

      await send(tester);

      final sent = backend.requestsTo(_appointments).single;
      expect(sent.headers['Idempotency-Key'], 'key-${keys.count}');
      expect(jsonDecode(utf8.decode(sent.body)), {
        'newPet': {'name': 'Capture', 'species': 'cat'},
        'motifId': _consultationId,
        'practitionerId': _lemoineId,
        'startAt': '2026-11-05T13:00:00+01:00',
      });
      expect(container.read(appointmentsRevisionProvider), revision + 1);
      expect(find.byType(SuccessView), findsOneWidget);
      expect(find.text('Demande envoyée'), findsOneWidget);
      expect(
        find.text(
          'La clinique doit confirmer votre rendez-vous du '
          'jeu. 12 nov. à 14:00.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Vous suivez votre demande dans Rendez-vous. Si la clinique ne peut '
          'pas la confirmer, vous en êtes informé.',
        ),
        findsOneWidget,
      );

      await tester.tap(button('Voir mes rendez-vous'));
      await tester.tap(find.text("Retour à l'annuaire"));
      expect(exits, ['appointments', 'directory']);
    });

    testWidgets('back on the step: the pet of the draft refilled; what is '
        'typed is kept outside the draft, its key unchanged', (tester) async {
      final container = await pumpPage(
        tester,
        page(),
        backend: _backend(),
        clock: FixedClock(_now),
        session: await memorySession(pair('A')),
        overrides: [bookingKeyFactoryProvider.overrideWithValue(keys.next)],
        prepare: (container) {
          // Kept alive while the step is not shown yet.
          container.listen(listingBookingProvider(_lyon), (_, _) {});
          container.read(listingBookingProvider(_lyon).notifier)
            ..start(_consultation, clinicName: _clinicName)
            ..chooseSlot(_lemoine, _thursday13)
            ..setPet('Capture', Species.cat);
        },
      );
      final key = container.read(listingBookingProvider(_lyon)).draft.key;

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'Capture',
      );
      expect(
        tester
            .widget<KivetoChoiceChip>(
              find.widgetWithText(KivetoChoiceChip, 'Chat'),
            )
            .selected,
        isTrue,
      );
      expect(enabled(tester, 'Envoyer la demande'), isTrue);

      await tester.enterText(find.byType(TextField), 'Capturé');
      await tester.pump();
      await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Chien'));
      await tester.pump();
      final state = container.read(listingBookingProvider(_lyon));
      expect(state.typed, (name: 'Capturé', species: Species.dog));
      expect(state.draft.pet, const NewPet('Capture', Species.cat));
      expect(state.draft.key, key);
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(container.read(listingBookingProvider(_lyon)).typed, (
        name: '',
        species: Species.dog,
      ));
      expect(enabled(tester, 'Envoyer la demande'), isFalse);
    });

    testWidgets('back on the step: what was typed wins over the pet sent', (
      tester,
    ) async {
      await pumpPage(
        tester,
        page(),
        backend: _backend(),
        clock: FixedClock(_now),
        session: await memorySession(pair('A')),
        overrides: [bookingKeyFactoryProvider.overrideWithValue(keys.next)],
        prepare: (container) {
          container.listen(listingBookingProvider(_lyon), (_, _) {});
          container.read(listingBookingProvider(_lyon).notifier)
            ..start(_consultation, clinicName: _clinicName)
            ..chooseSlot(_lemoine, _thursday13)
            ..setPet('Capture', Species.cat)
            ..keepTyped('Pixel', null);
        },
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'Pixel',
      );
      expect(enabled(tester, 'Envoyer la demande'), isFalse);
    });

    testWidgets('sent: the system back gives the directory exit; a second '
        'confirmation sends nothing', (tester) async {
      final container = await pump(
        tester,
        page(),
        _backend()..on(
          'POST',
          _appointments,
          PortalReply.fixture('$_fixtures.post.201.json', status: 201),
        ),
      );
      await fill(tester);
      await send(tester);
      expect(find.text('Demande envoyée'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(exits, ['directory']);

      final again = container
          .read(listingBookingProvider(_lyon).notifier)
          .confirm();
      await tester.pumpAndSettle();
      expect(await again, ListingOutcome.ignored);
    });

    testWidgets('a request on its way: no exit, no choice changes the draft, '
        'no second POST; its answer for the draft sent', (tester) async {
      final answer = Completer<PortalReply>();
      final backend = _backend()
        ..onRequest('POST', _appointments, (request) => answer.future);
      final container = await pump(tester, page(), backend);
      await fill(tester);

      await tester.tap(button('Envoyer la demande'));
      await tester.pump();
      final draft = container.read(listingBookingProvider(_lyon)).draft;
      expect(draft.pet, const NewPet('Capture', Species.cat));
      final booking = container.read(listingBookingProvider(_lyon).notifier)
        ..start(
          const BookingMotif(
            id: MotifId('other'),
            label: 'Vaccination',
            durationMin: 20,
          ),
          clinicName: _clinicName,
        )
        ..choosePractitioner(const Practitioner(id: PractitionerId('p')))
        ..chooseSlot(_lemoine, ClinicInstant.parse('2026-11-05T13:15:00+01:00'))
        ..setPet('Plume', Species.dog);

      expect(container.read(listingBookingProvider(_lyon)).draft, same(draft));
      expect(
        container.read(listingBookingProvider(_lyon)).submission,
        isA<ListingSending>(),
      );
      final second = booking.confirm();
      await tester.pump();
      expect(await second, ListingOutcome.ignored);

      // Back, X and the system back stay on the step.
      await tester.tap(iconButton(LucideGlyph.chevronLeft));
      await tester.tap(iconButton(LucideGlyph.x));
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(exits, isEmpty);
      expect(find.text('Votre animal'), findsOneWidget);

      answer.complete(
        PortalReply.fixture('$_fixtures.post.201.json', status: 201),
      );
      await tester.pumpAndSettle();
      expect(find.text('Demande envoyée'), findsOneWidget);
      expect(backend.requestsTo(_appointments), hasLength(1));
      expect(container.read(listingBookingProvider(_lyon)).draft, same(draft));
    });

    testWidgets('a network failure: its message and « Réessayer » with the '
        'same key; a new name, a new key', (tester) async {
      var answers = 0;
      final backend = _backend()
        ..onRequest('POST', _appointments, (request) {
          answers++;
          return answers < 3
              ? problem('service_unavailable', 503)
              : PortalReply.fixture('$_fixtures.post.201.json', status: 201);
        });
      await pump(tester, page(), backend);
      await fill(tester);

      await send(tester);
      expect(find.byType(KivetoCallout), findsOneWidget);
      await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
      await tester.pumpAndSettle();
      expect(find.byType(KivetoCallout), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Capturé');
      await tester.pump();
      await send(tester);

      final sent = backend.requestsTo(_appointments);
      final sentKeys = [
        for (final request in sent) request.headers['Idempotency-Key'],
      ];
      expect(sentKeys, hasLength(3));
      expect(sentKeys[1], sentKeys[0]);
      expect(sentKeys[2], isNot(sentKeys[0]));
      expect((jsonDecode(utf8.decode(sent.last.body)) as Map)['newPet'], {
        'name': 'Capturé',
        'species': 'cat',
      });
      expect(find.text('Demande envoyée'), findsOneWidget);
    });

    testWidgets('a network failure, the name edited then put back: the '
        'retry sends the same key', (tester) async {
      var answers = 0;
      final backend = _backend()
        ..onRequest('POST', _appointments, (request) {
          answers++;
          return answers < 2
              ? problem('service_unavailable', 503)
              : PortalReply.fixture('$_fixtures.post.201.json', status: 201);
        });
      await pump(tester, page(), backend);
      await fill(tester);
      await send(tester);
      expect(find.byType(KivetoCallout), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Captur');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Capture');
      await tester.pump();
      // The species tapped again changes nothing either.
      await tester.tap(find.widgetWithText(KivetoChoiceChip, 'Chat'));
      await tester.pump();
      expect(find.byType(KivetoCallout), findsOneWidget);
      await tester.tap(find.widgetWithText(KivetoButton, 'Réessayer'));
      await tester.pumpAndSettle();

      final sentKeys = [
        for (final request in backend.requestsTo(_appointments))
          request.headers['Idempotency-Key'],
      ];
      expect(sentKeys, hasLength(2));
      expect(sentKeys.last, sentKeys.first);
      expect(find.text('Demande envoyée'), findsOneWidget);
    });

    testWidgets('the slot taken (409, capture): marked taken, back to the '
        'slot step', (tester) async {
      final container = await pump(
        tester,
        page(),
        _backend()..on(
          'POST',
          _appointments,
          PortalReply.fixture(
            '$_fixtures.slot-taken.post.409.json',
            status: 409,
          ),
        ),
      );
      await fill(tester);
      await send(tester);

      expect(exits, ['slot taken']);
      final state = container.read(listingBookingProvider(_lyon));
      expect(state.slotTaken, isTrue);
      expect(state.draft.slot, isNull);
      expect(state.draft.isTaken(_thursday13), isTrue);
    });

    testWidgets('already a client (422 already_linked, capture): the '
        'callout offers « Prendre rendez-vous », on the confirmed clinic of '
        'the same name', (tester) async {
      final container = await pump(
        tester,
        page(),
        _backend()..on(
          'POST',
          _appointments,
          PortalReply.fixture(
            '$_fixtures.already-linked.post.422.json',
            status: 422,
          ),
        ),
      );
      await fill(tester);
      await send(tester);

      expect(
        find.text(
          'Vous êtes déjà client de cette clinique : prenez rendez-vous '
          'depuis votre espace.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.widgetWithText(KivetoButton, 'Prendre rendez-vous'),
      );
      await tester.pumpAndSettle();

      expect(exits, ['book']);
      expect(switch (container.read(activeClinicProvider)) {
        AsyncData(:final value) => value?.clinicId,
        _ => null,
      }, const ClinicId('01960000-0000-7000-8000-000000000101'));
    });

    testWidgets('already a client while /me still had the link pending: /me '
        'read again, then the clinic of the same name active', (tester) async {
      var confirmed = false;
      final backend = _backend()
        ..onRequest(
          'GET',
          '$api/me',
          (request) => PortalReply.fixture(
            confirmed ? 'me.get.200.json' : 'me.pending-link.get.200.json',
          ),
        )
        ..onRequest('POST', _appointments, (request) {
          // The clinic confirmed the link meanwhile.
          confirmed = true;
          return PortalReply.fixture(
            '$_fixtures.already-linked.post.422.json',
            status: 422,
          );
        });
      final container = await pump(tester, page(), backend);
      final active = container.listen(activeClinicProvider, (_, _) {});
      await tester.pumpAndSettle();
      expect(switch (active.read()) {
        AsyncData(:final value) => value,
        _ => const Object(),
      }, isNull);
      final reads = backend.requestsTo('$api/me').length;
      await fill(tester);
      await send(tester);

      await tester.tap(
        find.widgetWithText(KivetoButton, 'Prendre rendez-vous'),
      );
      await tester.pumpAndSettle();

      expect(backend.requestsTo('$api/me').length, greaterThan(reads));
      expect(exits, ['book']);
      expect(switch (active.read()) {
        AsyncData(:final value) => value?.clinicId,
        _ => null,
      }, const ClinicId('01960000-0000-7000-8000-000000000101'));
    });

    testWidgets('refused on another property (422 on startAt): its message '
        'above the button', (tester) async {
      await pump(
        tester,
        page(),
        _backend()..on(
          'POST',
          _appointments,
          PortalReply.json(
            jsonEncode({
              'type': 'validation_failed',
              'title': 'Données invalides.',
              'status': 422,
              'violations': [
                {
                  'propertyPath': 'startAt',
                  'message': 'Ce créneau ne correspond à aucun horaire.',
                },
              ],
            }),
            status: 422,
          ),
        ),
      );
      await fill(tester);
      await send(tester);

      expect(
        find.descendant(
          of: find.byType(KivetoCallout),
          matching: find.text('Ce créneau ne correspond à aucun horaire.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('too many requests pending (422 booking_request_limit, '
        'capture): « Voir mes rendez-vous »', (tester) async {
      await pump(
        tester,
        page(),
        _backend()..on(
          'POST',
          _appointments,
          PortalReply.fixture('$_fixtures.limit.post.422.json', status: 422),
        ),
      );
      // The test font draws every letter 1 em wide: the long action of the
      // callout leaves its text a narrow column, taller than a phone.
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      await fill(tester);
      await send(tester);

      expect(
        find.text(
          'Vous avez déjà des demandes de rendez-vous en attente\u00a0: '
          'attendez la réponse des cliniques.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(KivetoCallout),
          matching: find.text('Voir mes rendez-vous'),
        ),
      );
      expect(exits, ['appointments']);
    });

    for (final (reply, message) in [
      (
        problem('booking_not_open', 422),
        'Cette clinique ne prend plus de demandes en ligne de nouveaux '
            'clients.',
      ),
      (
        problem('not_found', 404),
        "Cette clinique ou ce créneau n'est plus disponible.",
      ),
      (
        problem('rate_limited', 429),
        'Trop de demandes en peu de temps : réessayez plus tard.',
      ),
    ]) {
      testWidgets('refused: $message', (tester) async {
        await pump(
          tester,
          page(),
          _backend()..on('POST', _appointments, reply),
        );
        await fill(tester);
        await send(tester);

        expect(find.text(message), findsOneWidget);
        expect(find.text('Réessayer'), findsNothing);
      });
    }

    testWidgets('the name refused (422 validation_failed, capture): under '
        'the field, no callout', (tester) async {
      await pump(
        tester,
        page(),
        _backend()..on(
          'POST',
          _appointments,
          PortalReply.fixture(
            '$_fixtures.validation.post.422.json',
            status: 422,
          ),
        ),
      );
      await fill(tester);
      await send(tester);

      expect(find.text("Le nom de l'animal est obligatoire."), findsOneWidget);
      expect(find.byType(KivetoCallout), findsNothing);

      // Edited: the server's word on the name sent goes.
      await tester.enterText(find.byType(TextField), 'Capture 2');
      await tester.pump();
      expect(find.text("Le nom de l'animal est obligatoire."), findsNothing);
    });

    testWidgets('a name over 80 characters: said, « Envoyer » disabled', (
      tester,
    ) async {
      await pump(tester, page(), _backend());
      await fill(tester, name: 'x' * 81);

      expect(find.text('80 caractères au plus.'), findsOneWidget);
      expect(enabled(tester, 'Envoyer la demande'), isFalse);
    });
  });
}
