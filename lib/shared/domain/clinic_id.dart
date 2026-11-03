/// The id of a clinic, as the Portal API sends it.
///
/// The convention for typed ids: an extension type over the wire string,
/// declared in the owning feature's `domain/` (`PetId` in `patient`), or
/// here when several features share it. Ids are never parsed or validated
/// client-side: the infrastructure wraps the string it receives.
extension type const ClinicId(String value);
