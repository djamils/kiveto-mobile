import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

/// The id of a pet, as the Portal API sends it.
extension type const PetId(String value);

/// The sex of a pet; [unknown] when the clinic did not record it (or for a
/// value this app does not know yet).
enum Sex { male, female, unknown }

/// Whether a pet is neutered; [unknown] when the clinic did not record it.
enum Sterilization { intact, neutered, unknown }

/// Whether a pet is still followed; [unknown] for a status this app does
/// not know yet.
enum LifeStatus { alive, deceased, missing, unknown }

/// A pet of the owner in a clinic (`GET /clinics/{c}/pets`): alive first,
/// then by name, deceased and missing ones included.
final class PetSummary {
  const new({
    required this.id,
    required this.name,
    required this.species,
    required this.initial,
    this.breed,
    this.sex = Sex.unknown,
    this.sterilization = Sterilization.unknown,
    this.birthDate,
    this.lifeStatus = LifeStatus.alive,
  });

  final PetId id;
  final String name;
  final Species species;

  /// As the clinic wrote it (`Labrador retriever`).
  final String? breed;
  final Sex sex;
  final Sterilization sterilization;
  final LocalDate? birthDate;

  /// The letter of its avatar, chosen by the server.
  final String initial;
  final LifeStatus lifeStatus;
}

/// The last weighing of a pet.
final class PetWeight {
  const new({required this.grams, required this.at});

  final int grams;
  final LocalDate at;
}

/// The sheet of a pet (`GET /clinics/{c}/pets/{id}`): its summary and what
/// only the sheet carries.
final class Pet {
  const new({
    required this.summary,
    this.lastWeight,
    this.chipNumberMasked,
    this.referentVet,
  });

  final PetSummary summary;

  /// The most recent weighing (the sheet's or a closed consultation's).
  final PetWeight? lastWeight;

  /// As the server masks it (`•••• 0446`): shown as received.
  final String? chipNumberMasked;

  /// The vet of the last report shared with the owner (`Dr Lucie Bernard`).
  final String? referentVet;

  PetId get id => summary.id;
  String get name => summary.name;
}
