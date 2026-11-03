import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';

/// The pets of the owner in a clinic; throws an `ApiFailure`
/// (shared/domain).
abstract interface class PetRepository {
  /// `GET /clinics/{c}/pets`.
  Future<List<PetSummary>> pets(ClinicId clinicId);

  /// `GET /clinics/{c}/pets/{id}`.
  Future<Pet> pet(ClinicId clinicId, PetId petId);

  /// `GET /clinics/{c}/pets/{id}/care-items`, by due date (empty for a
  /// deceased or missing pet).
  Future<List<CareItem>> careItems(ClinicId clinicId, PetId petId);

  /// The vaccination booklet, a PDF
  /// (`GET /clinics/{c}/pets/{id}/vaccination-booklet`).
  Future<PortalFile> vaccinationBooklet(ClinicId clinicId, PetId petId);
}
