import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The names of the owner's pets in a clinic, to name the pets of a
/// document; throws an `ApiFailure` (shared/domain).
abstract interface class PetNameRepository {
  /// `GET /clinics/{c}/pets`: name by pet id.
  Future<Map<String, String>> petNames(ClinicId clinicId);
}
