// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

/// A motif the clinic opens to online booking, in the clinic's order;
/// [suggested] when the pet has a care item of the motif's kind due or
/// overdue (the server decides, [suggestionReason] says why).
final class BookingMotif {
  const new({
    required this.id,
    required this.label,
    required this.durationMin,
    this.description,
    this.suggested = false,
    this.suggestionReason,
  });

  final MotifId id;
  final String label;
  final String? description;
  final int durationMin;
  final bool suggested;
  final String? suggestionReason;

  @override
  String toString() => 'BookingMotif(${id.value}, $label)';
}

/// A practitioner bookable online for a motif.
final class Practitioner {
  const new({required this.id, this.displayName});

  final PractitionerId id;

  /// « Dr Marc Dupont »; null when the clinic gave no name.
  final String? displayName;

  @override
  String toString() => 'Practitioner(${id.value})';
}

/// One clinic-local day of an availability window: [open] (an opening
/// day within the horizon) and its bookable [slots], on the clinic's clock.
final class AvailabilityDay {
  const new({required this.date, required this.open, this.slots = const []});

  final LocalDate date;
  final bool open;
  final List<ClinicInstant> slots;
}

/// Who the appointment is for: a pet the clinic knows, or a new one.
sealed class BookingPet {
  const new();

  /// The pet's name, as shown.
  String get name;
}

/// A pet of the owner in the clinic (a plain id: the pets are another
/// feature's).
final class ExistingPet extends BookingPet {
  const new(this.petId, this.name);

  final String petId;

  @override
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ExistingPet && other.petId == petId && other.name == name;

  @override
  int get hashCode => Object.hash(petId, name);

  @override
  String toString() => 'ExistingPet($petId)';
}

/// A pet the clinic does not know yet, created by the booking.
final class NewPet extends BookingPet {
  const new(this.name, this.species);

  @override
  final String name;
  final Species species;

  @override
  bool operator ==(Object other) =>
      other is NewPet && other.name == name && other.species == species;

  @override
  int get hashCode => Object.hash(name, species);

  @override
  String toString() => 'NewPet($name, $species)';
}

/// A complete booking: who, why, with whom and when (the slot as the
/// availability answer gave it, its offset kept).
final class BookingRequest {
  const new({
    required this.pet,
    required this.motifId,
    required this.practitionerId,
    required this.startAt,
  });

  final BookingPet pet;
  final MotifId motifId;
  final PractitionerId practitionerId;
  final ClinicInstant startAt;
}
