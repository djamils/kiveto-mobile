// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';

/// Where a slot is booked: a clinic of the account (`/clinics/{c}/booking`,
/// a known client), or a clinic of the directory (`/clinic-listings/{l}/
/// booking`, a new client). The practitioners and the availability come
/// from the venue's routes.
sealed class BookingVenue {
  const new();
}

/// A clinic the account is linked to.
final class ClinicVenue extends BookingVenue {
  const new(this.clinicId);

  final ClinicId clinicId;

  @override
  bool operator ==(Object other) =>
      other is ClinicVenue && other.clinicId == clinicId;

  @override
  int get hashCode => Object.hash(ClinicVenue, clinicId);

  @override
  String toString() => 'ClinicVenue(${clinicId.value})';
}

/// A clinic of the directory, booked as a new client.
final class ListingVenue extends BookingVenue {
  const new(this.listingId);

  final ListingId listingId;

  @override
  bool operator ==(Object other) =>
      other is ListingVenue && other.listingId == listingId;

  @override
  int get hashCode => Object.hash(ListingVenue, listingId);

  @override
  String toString() => 'ListingVenue(${listingId.value})';
}
