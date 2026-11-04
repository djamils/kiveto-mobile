// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';

/// How the pet does with the treatment, as the owner tells the vet.
enum PetCondition { improved, noImprovement, adverseEffects }

/// A renewal request as the owner fills it (screen 17): the content of one
/// intent, whose `Idempotency-Key` stays while it is equal.
final class RenewalRequestDraft {
  const new({required this.condition, this.note});

  final PetCondition condition;

  /// « Précision pour le vétérinaire »; none when left blank.
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is RenewalRequestDraft &&
      other.condition == condition &&
      other.note == note;

  @override
  int get hashCode => Object.hash(condition, note);
}

/// The request the server recorded: its id and status (a second request
/// while one is open answers the open one).
final class RenewalReceipt {
  const new({required this.requestId, required this.status});

  final String requestId;
  final RenewalStatus status;
}

/// The renewal of a prescription (Portal API); throws an `ApiFailure`
/// (shared/domain). Whether a prescription may be renewed online and how
/// many requests a day are allowed are the server's answers.
abstract interface class RenewalRepository {
  /// `POST …/prescriptions/{id}/renewal-requests` with [key] (the same key
  /// for every retry of the same [draft]).
  Future<RenewalReceipt> requestRenewal(
    ClinicId clinicId,
    PrescriptionId prescriptionId,
    RenewalRequestDraft draft,
    IdempotencyKey key,
  );
}
