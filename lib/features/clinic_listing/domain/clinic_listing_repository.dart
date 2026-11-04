import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';

/// The directory of the clinics (Portal API, public). Every method throws
/// an `ApiFailure` on a failure; which clinics are listed, their order and
/// whether they take new clients online are the server's answers.
abstract interface class ClinicListingRepository {
  /// One page of the clinics matching [query] (by name, or by distance
  /// around its position); [cursor] reads the next page of the same query.
  Future<ClinicListingPage> search(ListingQuery query, {String? cursor});

  /// The sheet of a clinic of the directory.
  Future<ClinicListingDetail> listing(ListingId id);
}
