// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

/// What a change request asks the clinic to modify on the pet's sheet;
/// [unknown] for a field this app does not know yet.
enum PetChangeField { name, weight, sterilization, chipNumber, other, unknown }

/// Where a request of the owner stands: [submitted] while the clinic has
/// not answered; [closed] without an answer (link revoked, pet archived…);
/// [unknown] for a status this app does not know yet.
enum PortalRequestStatus { submitted, done, rejected, closed, unknown }

/// The proposed value of a `sterilization` change, by state (the only two
/// the clinic takes).
const Map<Sterilization, String> sterilizationValues = {
  Sterilization.neutered: 'neutered',
  Sterilization.intact: 'intact',
};

/// A change request as the owner fills it (the sheet of screen 2): the
/// content of one intent, whose `Idempotency-Key` stays while it is equal.
/// The clinic checks every value (the weight's range, the chip's 15
/// digits…): the server answers.
final class PetChangeDraft {
  const new({
    required this.field,
    required this.proposedValue,
    this.measuredOn,
    this.note,
  });

  final PetChangeField field;

  /// As the owner typed it (« 12,4 » for a weight), or a value of
  /// [sterilizationValues].
  final String proposedValue;

  /// When a new weight was measured (none: the day of the request).
  final LocalDate? measuredOn;

  /// « Précision pour la clinique ».
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is PetChangeDraft &&
      other.field == field &&
      other.proposedValue == proposedValue &&
      other.measuredOn == measuredOn &&
      other.note == note;

  @override
  int get hashCode => Object.hash(field, proposedValue, measuredOn, note);
}

/// A change request of the owner (`GET /clinics/{c}/requests`, kind
/// `pet_change`), as the clinic keeps it.
final class PetChangeRequest {
  const new({
    required this.id,
    required this.petId,
    required this.field,
    required this.status,
    required this.submittedAt,
    this.proposedValue,
  });

  final String id;
  final PetId petId;
  final PetChangeField field;
  final String? proposedValue;
  final PortalRequestStatus status;
  final ClinicInstant submittedAt;

  /// The clinic has not answered yet.
  bool get isPending => status == PortalRequestStatus.submitted;
}

/// The change requests of the owner (Portal API); every method throws an
/// `ApiFailure` (shared/domain). The clinic applies a change by hand; the
/// rules per field, the quotas and which pets may change are the server's.
abstract interface class PetChangeRepository {
  /// `POST /clinics/{c}/pets/{id}/change-requests` with [key] (the same key
  /// for every retry of the same [draft]); the id of the request.
  Future<String> requestChange(
    ClinicId clinicId,
    PetId petId,
    PetChangeDraft draft,
    IdempotencyKey key,
  );

  /// The change requests of the owner in the clinic, newest first (the
  /// first page of `GET /clinics/{c}/requests`, 50 requests; the renewals
  /// left out).
  Future<List<PetChangeRequest>> changeRequests(ClinicId clinicId);
}
