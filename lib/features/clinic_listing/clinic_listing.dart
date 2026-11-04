// The public API of clinic_listing: the directory's screens, the clinic
// search (10, the landing of an account without a clinic, with the
// clinics' records at its phone number) and a clinic's sheet (11, whose
// « Motif » block starts scheduling's new-client booking). Their exits are
// callbacks: the feature never imports app/.

export 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_page.dart'
    show ClinicListingPage;
export 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_search_page.dart'
    show ClinicSearchPage;
