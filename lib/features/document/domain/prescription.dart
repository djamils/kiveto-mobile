import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';

/// A published prescription and its lines (`GET …/prescriptions/{id}`).
final class Prescription {
  const new({
    required this.id,
    required this.issuedAt,
    required this.vet,
    required this.pet,
    this.lines = const [],
  });

  final PrescriptionId id;
  final ClinicInstant issuedAt;

  /// As the clinic names the prescriber (`Dr Rousseau`).
  final String vet;
  final PetReference pet;
  final List<PrescriptionLine> lines;

  @override
  String toString() => 'Prescription(${id.value}, ${lines.length} lines)';
}

/// The pet of a prescription; [id] is null when the pet left the clinic's
/// files.
final class PetReference {
  const new({required this.name, this.id});

  final String? id;
  final String name;
}

/// One line of a prescription, as the clinic wrote it.
final class PrescriptionLine {
  const new({
    required this.label,
    required this.quantity,
    required this.posologySummary,
  });

  /// `Meloxidyl 1 mg/mL suspension buvable`.
  final String label;

  /// `2`.
  final String quantity;

  /// `0,1 mg/kg, 1×/j, pendant 60 jours, voie per os`.
  final String posologySummary;
}
