// The domain of patient: a pet's summary and its defaults, the sheet
// delegating to its summary, a weighing, a care item.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

void main() {
  test('a summary: what the clinic did not record defaults to unknown', () {
    const pet = PetSummary(
      id: PetId('p'),
      name: 'Moka',
      species: Species.dog,
      initial: 'M',
    );

    expect(pet.id, const PetId('p'));
    expect(pet.name, 'Moka');
    expect(pet.species, Species.dog);
    expect(pet.initial, 'M');
    expect(pet.breed, isNull);
    expect(pet.sex, Sex.unknown);
    expect(pet.sterilization, Sterilization.unknown);
    expect(pet.birthDate, isNull);
    expect(pet.lifeStatus, LifeStatus.alive);
  });

  test('a sheet: its summary, its weighing, chip and vet', () {
    final summary = PetSummary(
      id: const PetId('oscar'),
      name: 'Oscar',
      species: Species.dog,
      initial: 'O',
      breed: 'Labrador retriever',
      sex: Sex.male,
      sterilization: Sterilization.neutered,
      birthDate: LocalDate(2015, 8, 2),
      lifeStatus: LifeStatus.deceased,
    );
    final weight = PetWeight(grams: 34900, at: LocalDate(2026, 9, 27));
    final pet = Pet(
      summary: summary,
      lastWeight: weight,
      chipNumberMasked: '•••• 0446',
      referentVet: 'Dr Lucie Bernard',
    );

    expect(pet.id, const PetId('oscar'));
    expect(pet.name, 'Oscar');
    expect(pet.summary, same(summary));
    expect(pet.summary.breed, 'Labrador retriever');
    expect(pet.summary.lifeStatus, LifeStatus.deceased);
    expect(pet.lastWeight!.grams, 34900);
    expect(pet.lastWeight!.at, LocalDate(2026, 9, 27));
    expect(pet.chipNumberMasked, '•••• 0446');
    expect(pet.referentVet, 'Dr Lucie Bernard');
    expect(
      Pet(summary: summary).lastWeight,
      isNull,
      reason: 'no weighing, chip or vet by default',
    );
  });

  test('a care item', () {
    final item = CareItem(
      kind: 'vaccination',
      label: 'CHPPiL',
      lastDoneOn: LocalDate(2026, 4, 16),
      dueOn: LocalDate(2027, 4, 16),
      status: CareStatus.upToDate,
    );

    expect(item.kind, 'vaccination');
    expect(item.label, 'CHPPiL');
    expect(item.lastDoneOn, LocalDate(2026, 4, 16));
    expect(item.dueOn, LocalDate(2027, 4, 16));
    expect(item.status, CareStatus.upToDate);
  });
}
