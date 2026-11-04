/// The id of a clinic of the directory (a listing), as the Portal API sends
/// it (`/clinic-listings/{listingId}`). Not a `ClinicId`: a listing is the
/// directory's view of a clinic, the account's clinics have their own ids.
/// Shared by the directory (clinic_listing) and the new-client booking
/// (scheduling).
extension type const ListingId(String value);
