// PortalPetRepository on the real chain and the captures: Julien's and
// Garnier's pets, Oscar's, Nala's, Filou's and Oslo's sheets, their care
// items, every enum of the list and of the sheet (unknown kept, the
// generator's second `unknown` too), the null wrappers, the 404 and a
// network failure, the booklet through its 302 and its PDF bytes.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/infrastructure/portal_pet_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _paris = ClinicId(_parisId);
const _pets = '$api/clinics/$_parisId/pets';
const _oscar = PetId('01a19a10-20d7-77bd-bbad-d251136402fc');
const _nala = PetId('01a19a10-214a-7baa-93c9-96d75aad7892');
const _filou = PetId('01a19a10-2291-7c4a-a837-900159faa98f');
const _oslo = PetId('01a19a0f-128f-7a54-b39c-e01a30ee66d2');

/// One pet of the list, as the contract sends it, with [changes].
Map<String, Object?> _summary(Map<String, Object?> changes) => {
  'id': 'p',
  'name': 'Moka',
  'species': 'dog',
  'breed': null,
  'sex': 'male',
  'sterilization': 'intact',
  'birthDate': null,
  'initial': 'M',
  'lifeStatus': 'alive',
  ...changes,
};

/// A sheet, as the contract sends it, with [changes].
Map<String, Object?> _sheet(Map<String, Object?> changes) => {
  ..._summary({}),
  'lastWeight': null,
  'chipNumberMasked': null,
  'referentVet': null,
  ...changes,
};

Map<String, Object?> _care(String status) => {
  'kind': 'vaccination',
  'label': 'Rage',
  'lastDoneOn': '2026-04-16',
  'dueOn': '2027-04-16',
  'status': status,
};

void main() {
  late PortalHarness harness;
  late PortalPetRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalPetRepository(
      harness.http.server,
      PortalFileDownloader(harness.http.dio, devConfig, harness.failures),
      harness.failures,
    );
  });

  group('pets', () {
    test('Garnier, Paris (capture): five pets, alive first, Filou '
        'deceased', () async {
      harness.backend.on(
        'GET',
        _pets,
        PortalReply.fixture('clinics.paris.pets.garnier.get.200.json'),
      );

      final pets = await repository.pets(_paris);

      expect(pets.map((pet) => pet.name), [
        'Coco',
        'Nala',
        'Oscar',
        'Pepito',
        'Filou',
      ]);
      final [coco, nala, oscar, pepito, filou] = pets;
      expect(coco.species, Species.nac);
      expect(coco.breed, 'Lapin bélier');
      expect(coco.sex, Sex.male);
      expect(coco.sterilization, Sterilization.unknown);
      expect(coco.birthDate, LocalDate(2021, 11, 2));
      expect(coco.initial, 'C');
      expect(nala.id, _nala);
      expect(nala.species, Species.cat);
      expect(nala.sex, Sex.female);
      expect(nala.sterilization, Sterilization.neutered);
      expect(oscar.id, _oscar);
      expect(oscar.species, Species.dog);
      expect(pepito.sterilization, Sterilization.intact);
      expect(pepito.lifeStatus, LifeStatus.alive);
      expect(filou.id, _filou);
      expect(filou.lifeStatus, LifeStatus.deceased);
      final request = harness.backend.requests.single;
      expect(request.pathWithQuery, _pets);
      expect(bearerOf(request), 'Bearer A');
    });

    test(
      'Julien, Paris (capture): Oslo, sex and sterilization unknown',
      () async {
        harness.backend.on(
          'GET',
          _pets,
          PortalReply.fixture('clinics.paris.pets.get.200.json'),
        );

        final oslo = (await repository.pets(_paris)).single;

        expect(oslo.id, _oslo);
        expect(oslo.name, 'Oslo');
        expect(oslo.breed, 'Labrador');
        expect(oslo.sex, Sex.unknown);
        expect(oslo.sterilization, Sterilization.unknown);
      },
    );

    test('every species, sex, sterilization and life status; unknown '
        'ones kept', () async {
      harness.backend.on(
        'GET',
        _pets,
        PortalReply.json(
          jsonEncode([
            _summary({'species': 'cat', 'sex': 'female'}),
            _summary({'species': 'other', 'lifeStatus': 'missing'}),
            _summary({
              'species': 'unknown',
              'sex': 'unknown',
              'sterilization': 'unknown',
              'lifeStatus': 'unknown',
            }),
            _summary({
              'species': 'dragon',
              'sex': 'both',
              'sterilization': 'chemical',
              'lifeStatus': 'adopted',
            }),
          ]),
        ),
      );

      final pets = await repository.pets(_paris);

      expect(pets.map((pet) => pet.species), [
        Species.cat,
        Species.other,
        Species.unknown,
        Species.unknown,
      ]);
      expect(pets.map((pet) => pet.sex), [
        Sex.female,
        Sex.male,
        Sex.unknown,
        Sex.unknown,
      ]);
      expect(pets.map((pet) => pet.sterilization), [
        Sterilization.intact,
        Sterilization.intact,
        Sterilization.unknown,
        Sterilization.unknown,
      ]);
      expect(pets.map((pet) => pet.lifeStatus), [
        LifeStatus.alive,
        LifeStatus.missing,
        LifeStatus.unknown,
        LifeStatus.unknown,
      ]);
      expect(pets.first.breed, isNull);
      expect(pets.first.birthDate, isNull);
    });

    test('no answer: a NetworkFailure', () async {
      await expectLater(
        repository.pets(_paris),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('pet', () {
    test('Oscar (capture): his weighing, chip and vet', () async {
      harness.backend.on(
        'GET',
        '$_pets/${_oscar.value}',
        PortalReply.fixture('clinics.paris.pet.garnier-oscar.get.200.json'),
      );

      final pet = await repository.pet(_paris, _oscar);

      expect(pet.id, _oscar);
      expect(pet.name, 'Oscar');
      final summary = pet.summary;
      expect(summary.species, Species.dog);
      expect(summary.breed, 'Labrador retriever');
      expect(summary.sex, Sex.male);
      expect(summary.sterilization, Sterilization.neutered);
      expect(summary.birthDate, LocalDate(2015, 8, 2));
      expect(summary.initial, 'O');
      expect(summary.lifeStatus, LifeStatus.alive);
      expect(pet.lastWeight!.grams, 34900);
      expect(pet.lastWeight!.at, LocalDate(2026, 9, 27));
      expect(pet.chipNumberMasked, '•••• 0446');
      expect(pet.referentVet, 'Dr Lucie Bernard');
    });

    test('Nala (capture): a spayed female, no chip', () async {
      harness.backend.on(
        'GET',
        '$_pets/${_nala.value}',
        PortalReply.fixture('clinics.paris.pet.garnier-nala.get.200.json'),
      );

      final pet = await repository.pet(_paris, _nala);

      expect(pet.summary.species, Species.cat);
      expect(pet.summary.sex, Sex.female);
      expect(pet.lastWeight!.grams, 4250);
      expect(pet.chipNumberMasked, isNull);
      expect(pet.referentVet, 'Dr Éric Rousseau');
    });

    test('Filou (capture): deceased, no weighing', () async {
      harness.backend.on(
        'GET',
        '$_pets/${_filou.value}',
        PortalReply.fixture('clinics.paris.pet.garnier-filou.get.200.json'),
      );

      final pet = await repository.pet(_paris, _filou);

      expect(pet.summary.lifeStatus, LifeStatus.deceased);
      expect(pet.lastWeight, isNull);
      expect(pet.referentVet, isNull);
    });

    test('Oslo (capture): sex and sterilization unknown', () async {
      harness.backend.on(
        'GET',
        '$_pets/${_oslo.value}',
        PortalReply.fixture('clinics.paris.pet.get.200.json'),
      );

      final pet = await repository.pet(_paris, _oslo);

      expect(pet.summary.sex, Sex.unknown);
      expect(pet.summary.sterilization, Sterilization.unknown);
      expect(pet.lastWeight!.grams, 24300);
      expect(pet.lastWeight!.at, LocalDate(2026, 9, 5));
    });

    test('every enum of the sheet; unknown ones kept', () async {
      final sheets = [
        _sheet({'species': 'cat', 'sex': 'female'}),
        _sheet({'species': 'nac', 'lifeStatus': 'missing'}),
        _sheet({'species': 'other', 'lifeStatus': 'deceased'}),
        _sheet({
          'species': 'unknown',
          'sex': 'unknown',
          'sterilization': 'unknown',
          'lifeStatus': 'unknown',
        }),
        _sheet({
          'species': 'dragon',
          'sex': 'both',
          'sterilization': 'chemical',
          'lifeStatus': 'adopted',
          'birthDate': '2020-02-29',
        }),
        _sheet({'sterilization': 'neutered'}),
      ];
      for (var i = 0; i < sheets.length; i++) {
        harness.backend.on(
          'GET',
          '$_pets/p$i',
          PortalReply.json(jsonEncode(sheets[i])),
        );
      }

      final pets = [
        for (var i = 0; i < sheets.length; i++)
          (await repository.pet(_paris, PetId('p$i'))).summary,
      ];

      expect(pets.map((pet) => pet.species), [
        Species.cat,
        Species.nac,
        Species.other,
        Species.unknown,
        Species.unknown,
        Species.dog,
      ]);
      expect(pets.map((pet) => pet.sex), [
        Sex.female,
        Sex.male,
        Sex.male,
        Sex.unknown,
        Sex.unknown,
        Sex.male,
      ]);
      expect(pets.map((pet) => pet.sterilization), [
        Sterilization.intact,
        Sterilization.intact,
        Sterilization.intact,
        Sterilization.unknown,
        Sterilization.unknown,
        Sterilization.neutered,
      ]);
      expect(pets.map((pet) => pet.lifeStatus), [
        LifeStatus.alive,
        LifeStatus.missing,
        LifeStatus.deceased,
        LifeStatus.unknown,
        LifeStatus.unknown,
        LifeStatus.alive,
      ]);
      expect(pets.first.birthDate, isNull);
      expect(pets[4].birthDate, LocalDate(2020, 2, 29));
    });

    test('404 (capture): a pet of another clinic, a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        '$_pets/gone',
        PortalReply.fixture(
          'clinics.paris.pet.not-found.get.404.json',
          status: 404,
        ),
      );

      await expectLater(
        repository.pet(_paris, const PetId('gone')),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('the ids are one encoded path segment each', () async {
      harness.backend.on(
        'GET',
        '$api/clinics/a%2Fb/pets/c%20d',
        PortalReply.json(jsonEncode(_sheet({}))),
      );

      final pet = await repository.pet(
        const ClinicId('a/b'),
        const PetId('c d'),
      );

      expect(pet.name, 'Moka');
    });
  });

  group('careItems', () {
    test('Oscar (capture): overdue first, then up to date', () async {
      harness.backend.on(
        'GET',
        '$_pets/${_oscar.value}/care-items',
        PortalReply.fixture(
          'clinics.paris.pet.care-items.garnier-oscar.get.200.json',
        ),
      );

      final items = await repository.careItems(_paris, _oscar);

      expect(items.map((item) => item.label), [
        'Vermifugation',
        'Simparica · 1 mois',
        'CHPPiL',
        'Leptospirose',
        'Rage',
      ]);
      final first = items.first;
      expect(first.kind, 'internal_parasite');
      expect(first.lastDoneOn, LocalDate(2026, 7, 15));
      expect(first.dueOn, LocalDate(2026, 10, 13));
      expect(first.status, CareStatus.overdue);
      expect(items[2].status, CareStatus.upToDate);
      expect(items[2].dueOn, LocalDate(2027, 4, 16));
    });

    test('Nala (capture): due soon', () async {
      harness.backend.on(
        'GET',
        '$_pets/${_nala.value}/care-items',
        PortalReply.fixture(
          'clinics.paris.pet.care-items.garnier-nala.get.200.json',
        ),
      );

      final item = (await repository.careItems(_paris, _nala)).single;

      expect(item.label, 'Typhus-Coryza');
      expect(item.status, CareStatus.dueSoon);
      expect(item.dueOn, LocalDate(2026, 11, 9));
    });

    test('Lyon (capture): nothing to follow', () async {
      const lyon = ClinicId('01960000-0000-7000-8000-000000000101');
      const pixel = PetId('01a19a10-d1df-75fb-acf1-2987bfc236b8');
      harness.backend.on(
        'GET',
        '$api/clinics/${lyon.value}/pets/${pixel.value}/care-items',
        PortalReply.fixture('clinics.lyon.pet.care-items.get.200.json'),
      );

      expect(await repository.careItems(lyon, pixel), isEmpty);
    });

    test('every status; an unknown one kept', () async {
      harness.backend.on(
        'GET',
        '$_pets/p/care-items',
        PortalReply.json(
          jsonEncode([
            _care('booked'),
            _care('overdue'),
            _care('due_soon'),
            _care('up_to_date'),
            _care('unknown'),
            _care('postponed'),
          ]),
        ),
      );

      final items = await repository.careItems(_paris, const PetId('p'));

      expect(items.map((item) => item.status), [
        CareStatus.booked,
        CareStatus.overdue,
        CareStatus.dueSoon,
        CareStatus.upToDate,
        CareStatus.unknown,
        CareStatus.unknown,
      ]);
    });

    test('404: a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        '$_pets/gone/care-items',
        problem('not_found', 404),
      );

      await expectLater(
        repository.careItems(_paris, const PetId('gone')),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('vaccinationBooklet', () {
    const booklet =
        '$_pets/01a19a10-20d7-77bd-bbad-d251136402fc'
        '/vaccination-booklet';
    // The captured shape of the backend's signed URL (valid 5 min).
    const signed =
        '$api/files/booklets/$_parisId/01a19a10-20d7-77bd-bbad-d251136402fc/'
        '8f14e45fceea167a5a36dedd4bea2543'
        '?_expiration=1793710624&_hash=Qm9va2xldC1oYXNo';

    test('the 302 to the signed URL, then the PDF bytes', () async {
      final pdf = File('$portalFixtures/files.documents.get.200.pdf')
          .readAsBytesSync();
      harness.backend
        ..on(
          'GET',
          booklet,
          PortalReply.empty(
            302,
            headers: {
              'location': ['http://portal.kiveto.local:81$signed'],
            },
          ),
        )
        ..on(
          'GET',
          signed,
          PortalReply.bytes(
            pdf,
            contentType: 'application/pdf',
            headers: {
              'content-disposition': [
                'inline; filename="carnet-de-vaccination.pdf"',
              ],
            },
          ),
        );

      final file = await repository.vaccinationBooklet(_paris, _oscar);

      expect(file.bytes, pdf);
      expect(file.contentType, 'application/pdf');
      expect(file.fileName, 'carnet-de-vaccination.pdf');
      final [first, second] = harness.backend.requests;
      expect(first.pathWithQuery, booklet);
      expect(bearerOf(first), 'Bearer A');
      // Rewritten from the dev host to the dev base URL, query kept.
      expect(second.uri.toString(), 'http://10.0.2.2:81$signed');
      expect(second.headers, isNot(contains('Authorization')));
    });

    test('the ids are one encoded path segment each', () async {
      harness.backend.on(
        'GET',
        '$api/clinics/a%2Fb/pets/c%20d/vaccination-booklet',
        PortalReply.bytes(const [1, 2]),
      );

      final file = await repository.vaccinationBooklet(
        const ClinicId('a/b'),
        const PetId('c d'),
      );

      expect(file.bytes, [1, 2]);
      expect(file.contentType, isNull);
      expect(file.fileName, isNull);
    });

    test('503: a ServerFailure; 404: a NotFoundFailure', () async {
      harness.backend.on('GET', booklet, problem('service_unavailable', 503));
      await expectLater(
        repository.vaccinationBooklet(_paris, _oscar),
        throwsA(isA<ServerFailure>()),
      );

      harness.backend.on('GET', booklet, problem('not_found', 404));
      await expectLater(
        repository.vaccinationBooklet(_paris, _oscar),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
