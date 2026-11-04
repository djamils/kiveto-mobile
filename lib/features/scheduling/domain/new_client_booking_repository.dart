import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

/// The booking of a clinic of the directory as a new client, and the
/// account's booking requests (Portal API). Every method throws an
/// `ApiFailure` on a failure; which motifs and slots are open to new
/// clients, whether the account may ask (already a client, too many
/// requests pending) and the clinic's answer are the server's.
abstract interface class NewClientBookingRepository {
  /// The motifs the clinic opens online to new clients, in its order.
  Future<List<BookingMotif>> motifs(ListingId listingId);

  /// The practitioners bookable online by a new client for [motifId].
  Future<List<Practitioner>> practitioners(
    ListingId listingId,
    MotifId motifId,
  );

  /// One day per clinic-local date from [from] to [to] (both included, 14
  /// days at most).
  Future<List<AvailabilityDay>> availability(
    ListingId listingId,
    MotifId motifId,
    PractitionerId practitionerId,
    LocalDate from,
    LocalDate to,
  );

  /// Asks the clinic for [request] (its pet must be a [NewPet], described
  /// with the request: [ArgumentError] otherwise), sent with [key]: a
  /// retry with the same key answers the same request.
  Future<AppointmentRequest> request(
    ListingId listingId,
    BookingRequest request,
    IdempotencyKey key,
  );

  /// One page of the account's booking requests; [cursor] reads the next
  /// one, [limit] its size (the server's default without).
  Future<AppointmentRequestPage> requests({String? cursor, int? limit});
}
