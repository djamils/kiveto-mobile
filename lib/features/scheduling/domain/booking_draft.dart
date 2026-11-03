import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';

/// The booking wizard's intent (screens 12 → 13 → 3 → 14): the clinic, the
/// pet, the motif, the practitioner and the slot chosen so far, and the
/// `Idempotency-Key` of that intent.
///
/// One key per intent: every retry of the same content sends the same key
/// (a network failure, a refresh replay); any change of the clinic, the
/// pet (or the new pet's name or species), the motif, the practitioner or
/// the slot makes a new intent, so a new key. A downstream choice depends
/// on the upstream ones: a new motif clears the practitioner and the slot,
/// a new practitioner the slot, a new clinic everything.
final class BookingDraft {
  new _({
    required this.key,
    required this._newKey,
    this.clinicId,
    this.pet,
    this.motif,
    this.practitioner,
    this.slot,
    this.takenSlots = const {},
  });

  /// An empty draft for [clinicId], with a first key from [newKey].
  factory start(
    ClinicId? clinicId, {
    IdempotencyKey Function() newKey = IdempotencyKey.generate,
  }) => BookingDraft._(key: newKey(), newKey: newKey, clinicId: clinicId);

  final ClinicId? clinicId;
  final BookingPet? pet;
  final BookingMotif? motif;
  final Practitioner? practitioner;
  final ClinicInstant? slot;

  /// The slots another booking took while this one was on its way
  /// (`409 slot_taken`): the slot picker strikes them out.
  final Set<ClinicInstant> takenSlots;

  /// The `Idempotency-Key` of this intent.
  final IdempotencyKey key;

  final IdempotencyKey Function() _newKey;

  /// Whether [slot] was taken (compared by instant, whatever its offset).
  bool isTaken(ClinicInstant slot) =>
      takenSlots.any((taken) => taken.isAtSameMomentAs(slot));

  /// The booking to send, once every choice is made; null before.
  BookingRequest? get request {
    final (pet, motif, practitioner, slot) = (
      this.pet,
      this.motif,
      this.practitioner,
      this.slot,
    );
    if (pet == null || motif == null || practitioner == null || slot == null) {
      return null;
    }
    return BookingRequest(
      pet: pet,
      motifId: motif.id,
      practitionerId: practitioner.id,
      startAt: slot,
    );
  }

  /// Another clinic: a new draft, every choice dropped.
  BookingDraft withClinic(ClinicId? clinicId) => clinicId == this.clinicId
      ? this
      : BookingDraft.start(clinicId, newKey: _newKey);

  /// Another pet (or the new pet's name or species changed); the motif,
  /// practitioner and slot stay.
  BookingDraft withPet(BookingPet? pet) => pet == this.pet
      ? this
      : BookingDraft._(
          key: _newKey(),
          newKey: _newKey,
          clinicId: clinicId,
          pet: pet,
          motif: motif,
          practitioner: practitioner,
          slot: slot,
          takenSlots: takenSlots,
        );

  /// Another motif: the practitioner and the slot are dropped.
  BookingDraft withMotif(BookingMotif? motif) => motif?.id == this.motif?.id
      ? this
      : BookingDraft._(
          key: _newKey(),
          newKey: _newKey,
          clinicId: clinicId,
          pet: pet,
          motif: motif,
        );

  /// Another practitioner: the slot (and the slots seen taken) dropped.
  BookingDraft withPractitioner(Practitioner? practitioner) =>
      practitioner?.id == this.practitioner?.id
      ? this
      : BookingDraft._(
          key: _newKey(),
          newKey: _newKey,
          clinicId: clinicId,
          pet: pet,
          motif: motif,
          practitioner: practitioner,
        );

  /// Another slot.
  BookingDraft withSlot(ClinicInstant? slot) => slot == this.slot
      ? this
      : BookingDraft._(
          key: _newKey(),
          newKey: _newKey,
          clinicId: clinicId,
          pet: pet,
          motif: motif,
          practitioner: practitioner,
          slot: slot,
          takenSlots: takenSlots,
        );

  /// [slot] was taken meanwhile: kept as taken, and no longer the chosen
  /// slot if it was (the next choice brings a new key).
  BookingDraft markTaken(ClinicInstant slot) {
    final chosen = this.slot;
    return BookingDraft._(
      key: key,
      newKey: _newKey,
      clinicId: clinicId,
      pet: pet,
      motif: motif,
      practitioner: practitioner,
      slot: chosen != null && chosen.isAtSameMomentAs(slot) ? null : chosen,
      takenSlots: isTaken(slot) ? takenSlots : {...takenSlots, slot},
    );
  }
}
