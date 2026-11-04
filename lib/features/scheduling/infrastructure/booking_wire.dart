import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

// What the two booking repositories share with the wire: a clinic of the
// account (`/clinics/{c}/booking`) and a clinic of the directory
// (`/clinic-listings/{l}/booking`) answer the same shapes under their own
// generated classes (motifs, practitioners), or the same classes
// (availability days, the new pet).

/// A motif of either booking, from its view's fields.
BookingMotif bookingMotifOf({
  required String id,
  required String label,
  required int durationMin,
  required bool suggested,
  String? description,
  String? suggestionReason,
}) => BookingMotif(
  id: MotifId(id),
  label: label,
  description: description,
  durationMin: durationMin,
  suggested: suggested,
  suggestionReason: suggestionReason,
);

/// A practitioner of either booking, from its view's fields.
Practitioner practitionerOf({required String id, String? displayName}) =>
    Practitioner(id: PractitionerId(id), displayName: displayName);

/// A day of an availability window, its slots on the clinic's clock.
AvailabilityDay availabilityDayOf(api.AvailabilityDayView day) =>
    AvailabilityDay(
      date: localDateOf(day.date),
      open: day.open,
      slots: [for (final slot in day.slots) clinicInstantOf(slot.startAt)],
    );

/// A slot sent back as the availability answer gave it: its instant with
/// the clinic's offset (`2026-11-09T10:00:00+01:00`), never rebuilt from a
/// UTC `DateTime`.
OffsetDateTime slotWire(ClinicInstant slot) =>
    OffsetDateTime.from(slot.instant, offset: slot.offset);

/// A `format: date` parameter.
Date dateWire(LocalDate date) => Date(date.year, date.month, date.day);

/// A new pet described with a booking; no species sent for a species this
/// app does not know (the server records it as unknown).
api.NewPet newPetWire(NewPet pet) => api.NewPet(
  name: pet.name,
  species: switch (pet.species) {
    Species.dog => api.NewPetSpeciesModel.dog,
    Species.cat => api.NewPetSpeciesModel.cat,
    Species.nac => api.NewPetSpeciesModel.nac,
    Species.other => api.NewPetSpeciesModel.other,
    Species.unknown => null,
  },
);

/// The value of [values] named like the wire's [value] (the generated
/// enums name theirs like the domain's); [unknown] for a name it lacks —
/// never the generated `toJson` of `unknown`, which throws.
T sameName<T extends Enum>(List<T> values, Enum value, T unknown) =>
    values.asNameMap()[value.name] ?? unknown;
