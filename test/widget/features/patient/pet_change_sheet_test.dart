// The change request sheet of screen 2 on the fake backend and the
// captures: the fields and their inputs (the weight and its day, the
// sterilization by sex, the chip number, another change and its note),
// « Envoyer la demande » once a field has a value, the request sent and
// « Demande envoyée » (the pending requests read again), the server's
// refusals under their field or in the callout (validation, pet_not_eligible
// of a deceased pet, 404, 429), the retry of a network failure with the same
// key and a new key once the content changed, the contract's caps.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_change_sheet.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_providers.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _osloId = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _filouId = '01a19a10-2291-7c4a-a837-900159faa98f';
const _requests = '$api/clinics/$_parisId/requests?limit=50';

String _changes(String petId) =>
    '$api/clinics/$_parisId/pets/$petId/change-requests';

PetSummary _pet({
  String id = _osloId,
  String name = 'Oslo',
  Sex sex = Sex.unknown,
  LifeStatus lifeStatus = LifeStatus.alive,
}) => PetSummary(
  id: PetId(id),
  name: name,
  species: Species.dog,
  initial: name.substring(0, 1),
  sex: sex,
  lifeStatus: lifeStatus,
);

/// A page with a button opening the sheet of [pet].
Widget _opener(PetSummary pet) => Builder(
  builder: (context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => showPetChangeSheet(
          context,
          pet: pet,
          clinicId: const ClinicId(_parisId),
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

/// The 202 of a change request (capture).
PortalReply _accepted() => PortalReply.fixture(
  'clinics.paris.pet.change-requests.post.202.json',
  status: 202,
);

Finder _chip(String label) => find.widgetWithText(KivetoChoiceChip, label);

/// The text field labelled [label].
Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is KivetoTextField && widget.label == label,
);

Finder _send() => find.widgetWithText(KivetoButton, 'Envoyer la demande');

bool _canSend(WidgetTester tester) =>
    tester.widget<KivetoButton>(_send()).onPressed != null;

void main() {
  late List<String> keys;

  setUp(() => keys = []);

  /// The sheet of [pet] open on [backend] (Julien signed in, Paris active),
  /// keys `key-1`, `key-2`…; the pending requests kept read.
  Future<ProviderContainer> open(
    WidgetTester tester,
    FakePortalBackend backend, {
    PetSummary? pet,
  }) async {
    backend
      ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
      ..on(
        'GET',
        _requests,
        PortalReply.fixture('clinics.paris.requests.get.200.json'),
      );
    final container = await pumpPage(
      tester,
      _opener(pet ?? _pet()),
      backend: backend,
      session: await memorySession(pair('A')),
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        idempotencyKeyFactoryProvider.overrideWithValue(() {
          keys.add('key-${keys.length + 1}');
          return IdempotencyKey(keys.last);
        }),
      ],
    );
    container.listen(petChangeRequestsProvider, (_, _) {});
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String label, String text) async {
    await tester.enterText(_field(label), text);
    await tester.pumpAndSettle();
  }

  testWidgets('the sheet: its title, the pet, the fields; « Envoyer la '
      'demande » once a field has a value', (tester) async {
    await open(tester, FakePortalBackend());

    expect(find.text('Signaler une modification'), findsOneWidget);
    expect(
      find.text(
        'Pour Oslo. La clinique vérifie chaque modification avant de mettre '
        'à jour la fiche.',
      ),
      findsOneWidget,
    );
    expect(find.text('Que faut-il modifier\u00a0?'), findsOneWidget);
    for (final label in ['Nom', 'Poids', 'Stérilisation', 'Puce', 'Autre']) {
      expect(_chip(label), findsOneWidget, reason: label);
    }
    expect(
      find.text('Précision pour la clinique (facultatif)', findRichText: true),
      findsOneWidget,
    );
    expect(_canSend(tester), isFalse);

    await tester.tap(_chip('Nom'));
    await tester.pumpAndSettle();
    expect(_field('Nouveau nom'), findsOneWidget);
    expect(_canSend(tester), isFalse);

    await type(tester, 'Nouveau nom', '   ');
    expect(_canSend(tester), isFalse);
    await type(tester, 'Nouveau nom', 'Oslo II');
    expect(_canSend(tester), isTrue);
  });

  testWidgets('a weight (capture): sent with the key, « Demande envoyée »; '
      'the pending requests read again; « Fermer » closes', (tester) async {
    final backend = FakePortalBackend()
      ..on('POST', _changes(_osloId), _accepted());
    await open(tester, backend);

    await tester.tap(_chip('Poids'));
    await tester.pumpAndSettle();
    expect(find.text('Nouveau poids (kg)'), findsOneWidget);
    expect(find.text('Ex.\u00a0: 12,4'), findsOneWidget);
    expect(find.text('Pesé le'), findsOneWidget);
    expect(find.text("Aujourd'hui"), findsOneWidget);
    await type(tester, 'Nouveau poids (kg)', ' 12,4 ');
    await tester.enterText(
      _field('Précision pour la clinique'),
      'Pesé chez nous',
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, _send());

    final post = backend.requestsTo(_changes(_osloId)).single;
    expect(post.headers['Idempotency-Key'], 'key-1');
    expect(_jsonOf(post), {
      'field': 'weight',
      'proposedValue': '12,4',
      'measuredOn': null,
      'note': 'Pesé chez nous',
    });
    expect(find.text('Demande envoyée'), findsOneWidget);
    expect(
      find.text(
        'La clinique vérifiera la modification avant de mettre à jour la '
        'fiche.',
      ),
      findsOneWidget,
    );
    expect(backend.requestsTo(_requests), hasLength(2));

    await tester.tap(find.widgetWithText(KivetoButton, 'Fermer'));
    await tester.pumpAndSettle();
    expect(find.byType(PetChangeSheet), findsNothing);
  });

  testWidgets('« Pesé le »: the day picked (until today) is sent', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('POST', _changes(_osloId), _accepted());
    await open(tester, backend);
    await tester.tap(_chip('Poids'));
    await tester.pumpAndSettle();
    await type(tester, 'Nouveau poids (kg)', '12,4');

    await tapVisible(tester, find.text("Aujourd'hui"));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('2 nov. 2026'), findsOneWidget);
    await tapVisible(tester, _send());
    expect(
      _jsonOf(backend.requestsTo(_changes(_osloId)).single)['measuredOn'],
      '2026-11-02',
    );
  });

  testWidgets('a day picked for a weight is not sent with another field', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('POST', _changes(_osloId), _accepted());
    await open(tester, backend);
    await tester.tap(_chip('Poids'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text("Aujourd'hui"));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('2 nov. 2026'), findsOneWidget);

    await tester.tap(_chip('Nom'));
    await tester.pumpAndSettle();
    await type(tester, 'Nouveau nom', 'Oslo II');
    await tapVisible(tester, _send());

    final body = _jsonOf(backend.requestsTo(_changes(_osloId)).single);
    expect(body['field'], 'name');
    expect(body['measuredOn'], isNull);
  });

  testWidgets('the sterilization chips by sex; the value sent by code', (
    tester,
  ) async {
    final backend = FakePortalBackend()
      ..on('POST', _changes(_osloId), _accepted());
    await open(tester, backend);
    await tester.tap(_chip('Stérilisation'));
    await tester.pumpAndSettle();

    expect(_chip('Stérilisé(e)'), findsOneWidget);
    expect(_chip('Non stérilisé(e)'), findsOneWidget);
    expect(_canSend(tester), isFalse);
    await tester.tap(_chip('Non stérilisé(e)'));
    await tester.pumpAndSettle();
    await tapVisible(tester, _send());

    final body = _jsonOf(backend.requestsTo(_changes(_osloId)).single);
    expect(body['field'], 'sterilization');
    expect(body['proposedValue'], 'intact');
  });

  for (final (sex, neutered, intact) in [
    (Sex.male, 'Castré', 'Non castré'),
    (Sex.female, 'Stérilisée', 'Non stérilisée'),
  ]) {
    testWidgets('a ${sex.name} pet: « $neutered » / « $intact »', (
      tester,
    ) async {
      await open(tester, FakePortalBackend(), pet: _pet(sex: sex));
      await tester.tap(_chip('Stérilisation'));
      await tester.pumpAndSettle();

      expect(_chip(neutered), findsOneWidget);
      expect(_chip(intact), findsOneWidget);
    });
  }

  testWidgets('the chip number and its help; another change, its note not '
      'optional; the values sent', (tester) async {
    final backend = FakePortalBackend();
    final bodies = <Map<String, Object?>>[];
    backend.onRequest('POST', _changes(_osloId), (request) {
      bodies.add(_jsonOf(request));
      return _accepted();
    });
    await open(tester, backend);

    await tester.tap(_chip('Puce'));
    await tester.pumpAndSettle();
    expect(
      find.text("Les 15 chiffres inscrits sur la carte d'identification."),
      findsOneWidget,
    );
    await type(tester, 'Numéro de puce', '250268731000453');

    await tester.tap(_chip('Autre'));
    await tester.pumpAndSettle();
    expect(_field('Numéro de puce'), findsNothing);
    expect(find.text('Ex.\u00a0: nouvelle allergie'), findsOneWidget);
    expect(find.text('Précisions pour la clinique'), findsOneWidget);
    expect(
      find.text('Expliquez la modification à la clinique.'),
      findsOneWidget,
    );
    await type(tester, 'Ce qui a changé', 'Allergie au vermifuge');
    await tapVisible(tester, _send());

    expect(bodies.single['field'], 'other');
    expect(bodies.single['proposedValue'], 'Allergie au vermifuge');
    expect(bodies.single['note'], isNull);
  });

  group('refusals', () {
    testWidgets('a weight out of range (422, capture): the message under the '
        'weight; a missing note (capture): under the note', (tester) async {
      final backend = FakePortalBackend()
        ..on(
          'POST',
          _changes(_osloId),
          PortalReply.fixture(
            'clinics.paris.pet.change-requests.validation.post.422.json',
            status: 422,
          ),
        );
      await open(tester, backend);
      await tester.tap(_chip('Poids'));
      await tester.pumpAndSettle();
      await type(tester, 'Nouveau poids (kg)', '200');
      await tapVisible(tester, _send());

      expect(
        find.text('Le poids doit être compris entre 0,05 et 150 kg.'),
        findsOneWidget,
      );
      expect(find.byType(KivetoCallout), findsNothing);

      backend.on(
        'POST',
        _changes(_osloId),
        PortalReply.fixture(
          'clinics.paris.pet.change-requests.note-missing.post.422.json',
          status: 422,
        ),
      );
      await tester.tap(_chip('Autre'));
      await tester.pumpAndSettle();
      await type(tester, 'Ce qui a changé', 'Allergie');
      await tapVisible(tester, _send());

      expect(find.text('Précisez votre demande dans la note.'), findsOneWidget);
      expect(
        find.text('Le poids doit être compris entre 0,05 et 150 kg.'),
        findsNothing,
      );
      expect(find.byType(KivetoCallout), findsNothing);
    });

    /// A 422 validation_failed on [path] with [message].
    PortalReply violation(String path, String message) => PortalReply.json(
      jsonEncode({
        'type': 'validation_failed',
        'title': 'Données invalides.',
        'status': 422,
        'violations': [
          {'propertyPath': path, 'message': message},
        ],
      }),
      status: 422,
    );

    testWidgets('a weighing day refused (422 on measuredOn): the message '
        'under « Pesé le », no callout', (tester) async {
      final backend = FakePortalBackend()
        ..on(
          'POST',
          _changes(_osloId),
          violation('measuredOn', 'La date de pesée est dans le futur.'),
        );
      await open(tester, backend);
      await tester.tap(_chip('Poids'));
      await tester.pumpAndSettle();
      await type(tester, 'Nouveau poids (kg)', '12,4');
      await tapVisible(tester, _send());

      expect(find.text('La date de pesée est dans le futur.'), findsOneWidget);
      expect(find.byType(KivetoCallout), findsNothing);
    });

    testWidgets('a sterilization refused (422 on proposedValue): the message '
        'under its chips, no callout', (tester) async {
      final backend = FakePortalBackend()
        ..on(
          'POST',
          _changes(_osloId),
          violation('proposedValue', 'Valeur de stérilisation inconnue.'),
        );
      await open(tester, backend);
      await tester.tap(_chip('Stérilisation'));
      await tester.pumpAndSettle();
      await tester.tap(_chip('Stérilisé(e)'));
      await tester.pumpAndSettle();
      await tapVisible(tester, _send());

      expect(find.text('Valeur de stérilisation inconnue.'), findsOneWidget);
      expect(find.byType(KivetoCallout), findsNothing);
    });

    testWidgets('the server fails (503): « Réessayer » sends the same key', (
      tester,
    ) async {
      var failing = true;
      final backend = FakePortalBackend()
        ..onRequest(
          'POST',
          _changes(_osloId),
          (_) => failing ? problem('service_unavailable', 503) : _accepted(),
        );
      await open(tester, backend);
      await tester.tap(_chip('Nom'));
      await tester.pumpAndSettle();
      await type(tester, 'Nouveau nom', 'Oslo II');
      await tapVisible(tester, _send());
      final retry = find.widgetWithText(KivetoButton, 'Réessayer');
      expect(retry, findsOneWidget);

      failing = false;
      await tapVisible(tester, retry);

      expect(
        [
          for (final request in backend.requestsTo(_changes(_osloId)))
            request.headers['Idempotency-Key'],
        ],
        ['key-1', 'key-1'],
      );
      expect(find.text('Demande envoyée'), findsOneWidget);
    });

    testWidgets('a violation no field shows: in the callout; an edit clears '
        'it', (tester) async {
      final backend = FakePortalBackend()
        ..on(
          'POST',
          _changes(_osloId),
          PortalReply.json(
            jsonEncode({
              'type': 'validation_failed',
              'title': 'Données invalides.',
              'status': 422,
              'violations': [
                {'propertyPath': 'field', 'message': 'Champ inconnu.'},
              ],
            }),
            status: 422,
          ),
        );
      await open(tester, backend);
      await tester.tap(_chip('Nom'));
      await tester.pumpAndSettle();
      await type(tester, 'Nouveau nom', 'Oslo II');
      await tapVisible(tester, _send());

      expect(
        find.descendant(
          of: find.byType(KivetoCallout),
          matching: find.text('Champ inconnu.'),
        ),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsNothing);

      await type(tester, 'Nouveau nom', 'Oslo III');
      expect(find.text('Champ inconnu.'), findsNothing);
    });

    for (final (name, reply, message) in [
      (
        'a deceased pet (422 pet_not_eligible, capture)',
        PortalReply.fixture(
          'clinics.paris.pet.change-requests.not-eligible.post.422.json',
          status: 422,
        ),
        "Cet animal ne peut plus faire l'objet d'une demande de "
            'modification\u00a0: contactez la clinique.',
      ),
      (
        'a pet gone (404)',
        problem('not_found', 404),
        "Cet animal n'est plus suivi par cette clinique.",
      ),
      (
        'too many requests (429)',
        problem('rate_limited', 429),
        "Vous avez envoyé beaucoup de demandes aujourd'hui. Réessayez "
            'demain ou contactez la clinique.',
      ),
    ]) {
      testWidgets('$name: its message, no retry', (tester) async {
        final backend = FakePortalBackend()
          ..on('POST', _changes(_filouId), reply);
        await open(
          tester,
          backend,
          pet: _pet(
            id: _filouId,
            name: 'Filou',
            sex: Sex.male,
            lifeStatus: LifeStatus.deceased,
          ),
        );
        await tester.tap(_chip('Poids'));
        await tester.pumpAndSettle();
        await type(tester, 'Nouveau poids (kg)', '5');
        await tapVisible(tester, _send());

        expect(
          find.descendant(
            of: find.byType(KivetoCallout),
            matching: find.text(message),
          ),
          findsOneWidget,
        );
        expect(find.text('Réessayer'), findsNothing);
        expect(find.text('Demande envoyée'), findsNothing);
      });
    }

    testWidgets('no answer: « Réessayer » sends the same key; a changed '
        'value, a new key', (tester) async {
      var offline = true;
      final backend = FakePortalBackend()
        ..onRequest(
          'POST',
          _changes(_osloId),
          (_) => offline ? throw StateError('offline') : _accepted(),
        );
      await open(tester, backend);
      await tester.tap(_chip('Poids'));
      await tester.pumpAndSettle();
      await type(tester, 'Nouveau poids (kg)', '12,4');
      await tapVisible(tester, _send());

      expect(
        find.text('Vérifiez votre connexion Internet, puis réessayez.'),
        findsOneWidget,
      );
      await tapVisible(tester, find.widgetWithText(KivetoButton, 'Réessayer'));
      await tapVisible(tester, _send());

      await type(tester, 'Nouveau poids (kg)', '12,5');
      offline = false;
      await tapVisible(tester, _send());

      expect(
        [
          for (final request in backend.requestsTo(_changes(_osloId)))
            request.headers['Idempotency-Key'],
        ],
        ['key-1', 'key-1', 'key-1', 'key-2'],
      );
      expect(find.text('Demande envoyée'), findsOneWidget);
    });
  });

  testWidgets("the contract's caps: 120 for a value, 500 for the note", (
    tester,
  ) async {
    await open(tester, FakePortalBackend());
    await tester.tap(_chip('Nom'));
    await tester.pumpAndSettle();

    await type(tester, 'Nouveau nom', 'a' * 130);
    await tester.enterText(_field('Précision pour la clinique'), 'b' * 510);
    await tester.pumpAndSettle();

    final inputs = tester.widgetList<TextField>(find.byType(TextField));
    expect(inputs.map((input) => input.controller!.text.length), [120, 500]);
  });
}
