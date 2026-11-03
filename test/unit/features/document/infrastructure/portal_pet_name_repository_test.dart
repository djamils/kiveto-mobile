// PortalPetNameRepository on the real chain and the captures: the names of
// the pets of a clinic, by id.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_pet_name_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _paris = ClinicId('01960000-0000-7000-8000-000000000001');
const _pets = '$api/clinics/01960000-0000-7000-8000-000000000001/pets';

void main() {
  late PortalHarness harness;
  late PortalPetNameRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalPetNameRepository(harness.http.server, harness.failures);
  });

  test('Garnier (capture): five pets, the deceased one included', () async {
    harness.backend.on(
      'GET',
      _pets,
      PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
    );

    final names = await repository.petNames(_paris);

    expect(names, {
      '01a19a10-221c-78b5-9b4f-9c333d05a6d0': 'Coco',
      '01a19a10-214a-7baa-93c9-96d75aad7892': 'Nala',
      '01a19a10-20d7-77bd-bbad-d251136402fc': 'Oscar',
      '01a19a10-21af-748a-b841-690b02e4fe18': 'Pepito',
      '01a19a10-2291-7c4a-a837-900159faa98f': 'Filou',
    });
    expect(bearerOf(harness.backend.requests.single), 'Bearer A');
  });

  test('Julien (capture): Oslo', () async {
    harness.backend.on(
      'GET',
      _pets,
      PortalReply.fixture('clinics.paris.pets.get.200.json'),
    );

    expect(await repository.petNames(_paris), {
      '01a19a0f-128f-7a54-b39c-e01a30ee66d2': 'Oslo',
    });
  });

  test('404: a NotFoundFailure', () async {
    harness.backend.on('GET', _pets, problem('not_found', 404));

    await expectLater(
      repository.petNames(_paris),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('no answer: a NetworkFailure', () async {
    await expectLater(
      repository.petNames(_paris),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
