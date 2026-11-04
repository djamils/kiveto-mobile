import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/new_client_booking_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/booking_wire.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [NewClientBookingRepository] on the generated `ClinicListingApi` (the
/// directory's booking routes) and `AccountApi` (the account's requests).
///
/// The request answered by a booking and the requests listed come in two
/// view classes of one shape, each with its own enum classes: both hand
/// their fields to one mapper, which reads the enums by name.
final class PortalNewClientBookingRepository
    implements NewClientBookingRepository {
  new(api.Server server, this._failures)
    : _listings = api.ClinicListingApi(server),
      _account = api.AccountApi(server);

  final api.ClinicListingApi _listings;
  final api.AccountApi _account;
  final ApiFailureMapper _failures;

  @override
  Future<List<BookingMotif>> motifs(ListingId listingId) async =>
      switch (await _listings.listListingMotifs(listingId: listingId.value)) {
        TonikSuccess(value: api.ListListingMotifsResponse200(:final body)) => [
          for (final motif in body)
            bookingMotifOf(
              id: motif.id,
              label: motif.label,
              description: motif.description,
              durationMin: motif.durationMin,
              suggested: motif.suggested,
              suggestionReason: motif.suggestionReason,
            ),
        ],
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<List<Practitioner>> practitioners(
    ListingId listingId,
    MotifId motifId,
  ) async => switch (await _listings.listListingPractitioners(
    listingId: listingId.value,
    motifId: motifId.value,
  )) {
    TonikSuccess(value: api.ListListingPractitionersResponse200(:final body)) =>
      [
        for (final practitioner in body)
          practitionerOf(
            id: practitioner.id,
            displayName: practitioner.displayName,
          ),
      ],
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<List<AvailabilityDay>> availability(
    ListingId listingId,
    MotifId motifId,
    PractitionerId practitionerId,
    LocalDate from,
    LocalDate to,
  ) async => switch (await _listings.getListingAvailability(
    listingId: listingId.value,
    motifId: motifId.value,
    practitionerId: practitionerId.value,
    from: dateWire(from),
    to: dateWire(to),
  )) {
    TonikSuccess(value: api.GetListingAvailabilityResponse200(:final body)) => [
      for (final day in body.days) availabilityDayOf(day),
    ],
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<AppointmentRequest> request(
    ListingId listingId,
    BookingRequest request,
    IdempotencyKey key,
  ) async {
    final pet = switch (request.pet) {
      final NewPet pet => pet,
      ExistingPet() => throw ArgumentError.value(
        request.pet,
        'request.pet',
        'a new client books for a new pet',
      ),
    };
    return switch (await _listings.requestListingAppointment(
      listingId: listingId.value,
      idempotencyKey: key.value,
      body: api.ListingBooking(
        newPet: newPetWire(pet),
        motifId: request.motifId.value,
        practitionerId: request.practitionerId.value,
        startAt: slotWire(request.startAt),
      ),
    )) {
      TonikSuccess(
        value: api.RequestListingAppointmentResponse201(:final body),
      ) =>
        _request(
          id: body.id,
          clinic: body.clinic,
          pet: body.pet,
          motif: body.motif,
          startAt: body.startAt,
          status: body.status,
          declineReason: body.declineReason,
          appointmentId: body.appointmentId,
        ),
      final other => throw apiFailureOf(other, _failures),
    };
  }

  @override
  Future<AppointmentRequestPage> requests({String? cursor, int? limit}) async =>
      switch (await _account.listBookingRequests(
        cursor: cursor,
        limit: limit,
      )) {
        TonikSuccess(value: api.ListBookingRequestsResponse200(:final body)) =>
          AppointmentRequestPage(
            items: [
              for (final view in body.items)
                _request(
                  id: view.id,
                  clinic: view.clinic,
                  pet: view.pet,
                  motif: view.motif,
                  startAt: view.startAt,
                  status: view.status,
                  declineReason: view.declineReason,
                  appointmentId: view.appointmentId,
                ),
            ],
            nextCursor: body.nextCursor,
          ),
        final other => throw apiFailureOf(other, _failures),
      };

  /// One request, whichever view it came in; its enums read by name.
  static AppointmentRequest _request({
    required String id,
    required api.ClinicSummaryView clinic,
    required api.BookingRequestPetView pet,
    required String motif,
    required DateTime startAt,
    required Enum status,
    required Enum? declineReason,
    required String? appointmentId,
  }) => AppointmentRequest(
    id: AppointmentRequestId(id),
    clinicName: clinic.name,
    clinicCity: clinic.city,
    petName: pet.name,
    petSpecies: switch (pet.species) {
      final Enum species => sameName(Species.values, species, Species.unknown),
      null => null,
    },
    motifLabel: motif,
    startAt: clinicInstantOf(startAt),
    status: sameName(
      AppointmentRequestStatus.values,
      status,
      AppointmentRequestStatus.unknown,
    ),
    declineReason: switch (declineReason) {
      final Enum reason => sameName(
        DeclineReason.values,
        reason,
        DeclineReason.unknown,
      ),
      null => null,
    },
    appointmentId: switch (appointmentId) {
      final String id => AppointmentId(id),
      null => null,
    },
  );
}
