// PortalPetChangeRepository on the real chain and the captures of
// 2026-11-04: a change request sent (body, Idempotency-Key, measuredOn as a
// date), every field by code, the refusals (422 validation_failed on the
// value and on the note, pet_not_eligible, idempotency_key_reused, 429,
// 404, no answer); the requests of Julien and Garnier (the renewals left
// out, every status), every enum unknown kept.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_change.dart';
import 'package:kiveto_mobile/features/patient/infrastructure/portal_pet_change_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _paris = ClinicId(_parisId);
const _osloId = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const _oslo = PetId(_osloId);
const _oscar = PetId('01a19a10-20d7-77bd-bbad-d251136402fc');
const _pepito = PetId('01a19a10-21af-748a-b841-690b02e4fe18');
const _changes = '$api/clinics/$_parisId/pets/$_osloId/change-requests';
const _requests = '$api/clinics/$_parisId/requests?limit=50';
const _key = IdempotencyKey('change-intent-1');

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

/// Garnier's requests (capture) with [change] applied to its items.
PortalReply _garnierEdited(void Function(List<Object?> items) change) {
  final body = jsonDecode(
    File('$portalFixtures/clinics.paris.requests.garnier.get.200.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;
  change(body['items']! as List<Object?>);
  return PortalReply.json(jsonEncode(body));
}

void main() {
  late PortalHarness harness;
  late PortalPetChangeRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalPetChangeRepository(
      harness.http.server,
      harness.failures,
    );
  });

  Future<Object?> send(PetChangeDraft draft) => repository
      .requestChange(_paris, _oslo, draft, _key)
      .then<Object?>((id) => id, onError: (Object error) => error);

  group('requestChange', () {
    test('202 (capture): a weight, its day and note sent with the key; the '
        "request's id", () async {
      harness.backend.on(
        'POST',
        _changes,
        PortalReply.fixture(
          'clinics.paris.pet.change-requests.post.202.json',
          status: 202,
        ),
      );

      final id = await repository.requestChange(
        _paris,
        _oslo,
        PetChangeDraft(
          field: PetChangeField.weight,
          proposedValue: '12,4',
          measuredOn: LocalDate(2026, 11, 2),
          note: 'Pesé à la maison',
        ),
        _key,
      );

      final request = harness.backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Idempotency-Key'], 'change-intent-1');
      expect(_jsonOf(request), {
        'field': 'weight',
        'proposedValue': '12,4',
        'measuredOn': '2026-11-02',
        'note': 'Pesé à la maison',
      });
      expect(id, '01a1a413-c972-7eb1-b861-3e83365ac982');
    });

    test('every other field by its code; no day, no note', () async {
      final bodies = <Map<String, Object?>>[];
      harness.backend.onRequest('POST', _changes, (request) {
        bodies.add(_jsonOf(request));
        return PortalReply.fixture(
          'clinics.paris.pet.change-requests.post.202.json',
          status: 202,
        );
      });

      for (final (field, value) in [
        (PetChangeField.name, 'Oslo II'),
        (PetChangeField.sterilization, 'neutered'),
        (PetChangeField.chipNumber, '250268731000453'),
        (PetChangeField.other, 'Allergie au vermifuge'),
      ]) {
        await repository.requestChange(
          _paris,
          _oslo,
          PetChangeDraft(field: field, proposedValue: value),
          _key,
        );
      }

      expect(bodies.map((body) => body['field']), [
        'name',
        'sterilization',
        'chip_number',
        'other',
      ]);
      expect(bodies[1]['proposedValue'], 'neutered');
      expect(bodies.first['measuredOn'], isNull);
      expect(bodies.first['note'], isNull);
    });

    test('an unknown field cannot be sent: nothing goes', () async {
      expect(
        await send(
          const PetChangeDraft(
            field: PetChangeField.unknown,
            proposedValue: 'x',
          ),
        ),
        isArgumentError,
      );
      expect(harness.backend.requests, isEmpty);
    });

    for (final (fixture, path, message) in [
      (
        'clinics.paris.pet.change-requests.validation.post.422.json',
        'proposedValue',
        'Le poids doit être compris entre 0,05 et 150 kg.',
      ),
      (
        'clinics.paris.pet.change-requests.note-missing.post.422.json',
        'note',
        'Précisez votre demande dans la note.',
      ),
    ]) {
      test('422 validation_failed (capture): the violation of $path', () async {
        harness.backend.on(
          'POST',
          _changes,
          PortalReply.fixture(fixture, status: 422),
        );

        final failure = await send(
          const PetChangeDraft(
            field: PetChangeField.weight,
            proposedValue: '200',
          ),
        );

        expect(failure, isA<ValidationFailure>());
        final violation = (failure! as ValidationFailure).violations.single;
        expect(violation.propertyPath, path);
        expect(violation.message, message);
      });
    }

    for (final (fixture, code) in [
      (
        'clinics.paris.pet.change-requests.not-eligible.post.422.json',
        'pet_not_eligible',
      ),
      (
        'clinics.paris.pet.change-requests.key-reused.post.422.json',
        'idempotency_key_reused',
      ),
    ]) {
      test('422 $code (capture): a BusinessFailure with its code', () async {
        harness.backend.on(
          'POST',
          _changes,
          PortalReply.fixture(fixture, status: 422),
        );

        final failure = await send(
          const PetChangeDraft(field: PetChangeField.name, proposedValue: 'A'),
        );

        expect(
          failure,
          isA<BusinessFailure>().having((f) => f.code, 'code', code),
        );
      });
    }

    for (final (name, reply, matcher) in [
      ('429', problem('rate_limited', 429), isA<RateLimitedFailure>()),
      ('404', problem('not_found', 404), isA<NotFoundFailure>()),
    ]) {
      test('$name: its failure', () async {
        harness.backend.on('POST', _changes, reply);

        expect(
          await send(
            const PetChangeDraft(
              field: PetChangeField.name,
              proposedValue: 'A',
            ),
          ),
          matcher,
        );
      });
    }

    test('no answer: a NetworkFailure', () async {
      expect(
        await send(
          const PetChangeDraft(field: PetChangeField.name, proposedValue: 'A'),
        ),
        isA<NetworkFailure>(),
      );
    });
  });

  group('changeRequests', () {
    test(
      "Julien (capture): Oslo's weight pending; the first 50 asked",
      () async {
        harness.backend.on(
          'GET',
          _requests,
          PortalReply.fixture('clinics.paris.requests.get.200.json'),
        );

        final requests = await repository.changeRequests(_paris);

        expect(harness.backend.requests.single.pathWithQuery, _requests);
        final weight = requests.single;
        expect(weight.id, '01a19a12-9218-7410-8faf-72a15ed8ba17');
        expect(weight.petId, _oslo);
        expect(weight.field, PetChangeField.weight);
        expect(weight.proposedValue, '25,1');
        expect(weight.status, PortalRequestStatus.submitted);
        expect(weight.isPending, isTrue);
        expect(
          weight.submittedAt,
          ClinicInstant.parse('2026-11-02T03:24:30+01:00'),
        );
      },
    );

    test('Garnier (capture): her three change requests, newest first, the '
        'renewals left out; a rejection', () async {
      harness.backend.on(
        'GET',
        _requests,
        PortalReply.fixture('clinics.paris.requests.garnier.get.200.json'),
      );

      final requests = await repository.changeRequests(_paris);

      expect(requests.map((request) => request.field), [
        PetChangeField.weight,
        PetChangeField.other,
        PetChangeField.chipNumber,
      ]);
      final rejected = requests.first;
      expect(rejected.petId, _oscar);
      expect(rejected.status, PortalRequestStatus.rejected);
      expect(rejected.proposedValue, '41,5');
      expect(requests[1].proposedValue, 'Allergie au vermifuge');
      expect(requests.last.petId, _pepito);
      expect(requests.last.proposedValue, '250268731000453');
      expect(requests.where((request) => request.isPending), hasLength(2));
    });

    test('every field and status of the contract, unknown kept', () async {
      harness.backend.on(
        'GET',
        _requests,
        _garnierEdited((items) {
          void set(int index, Object? field, String status) {
            final item = items[index]! as Map<String, Object?>;
            item['field'] = field;
            item['status'] = status;
          }

          set(0, 'name', 'done');
          set(1, 'sterilization', 'closed');
          set(2, 'colour', 'archived');
          items.add({
            ...(items[0]! as Map<String, Object?>),
            'id': 'r-null',
            'field': null,
            'status': 'submitted',
          });
        }),
      );

      final requests = await repository.changeRequests(_paris);

      expect(
        [for (final request in requests) (request.field, request.status)],
        [
          (PetChangeField.name, PortalRequestStatus.done),
          (PetChangeField.sterilization, PortalRequestStatus.closed),
          (PetChangeField.unknown, PortalRequestStatus.unknown),
          (PetChangeField.unknown, PortalRequestStatus.submitted),
        ],
      );
    });

    test('404 (link gone): a NotFoundFailure', () async {
      harness.backend.on('GET', _requests, problem('not_found', 404));

      await expectLater(
        repository.changeRequests(_paris),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
