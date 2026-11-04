import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [ClinicListingRepository] on the generated `ClinicListingApi`: the only
/// clinic_listing code that sees the generated DTOs.
final class PortalClinicListingRepository implements ClinicListingRepository {
  new(api.Server server, this._failures) : _api = api.ClinicListingApi(server);

  final api.ClinicListingApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<ClinicListingPage> search(ListingQuery query, {String? cursor}) async {
    final near = query.near;
    return switch (await _api.listClinicListings(
      q: query.q,
      lat: near?.latitude,
      lng: near?.longitude,
      cursor: cursor,
    )) {
      TonikSuccess(value: api.ListClinicListingsResponse200(:final body)) =>
        ClinicListingPage(
          items: [for (final view in body.items) _summary(view)],
          nextCursor: body.nextCursor,
        ),
      final other => throw apiFailureOf(other, _failures),
    };
  }

  @override
  Future<ClinicListingDetail> listing(ListingId id) async =>
      switch (await _api.getClinicListing(listingId: id.value)) {
        TonikSuccess(value: api.GetClinicListingResponse200(:final body)) =>
          ClinicListingDetail(
            id: ListingId(body.id),
            name: body.name,
            address: _address(body.address?.listingAddressView),
            phone: body.phone,
            timezone: body.timezone,
            openingHours: [
              for (final range in body.openingHours)
                OpeningHours(
                  day: range.day,
                  opensAt: _time(range.opensAt),
                  closesAt: _time(range.closesAt),
                ),
            ],
            acceptsNewClients: body.acceptsNewClients,
            onlineBooking: body.onlineBooking,
            tags: body.tags,
          ),
        final other => throw apiFailureOf(other, _failures),
      };

  static ClinicListingSummary _summary(api.ClinicListingSummaryView view) =>
      ClinicListingSummary(
        id: ListingId(view.id),
        name: view.name,
        address: _address(view.address?.listingAddressView),
        phone: view.phone,
        distanceM: view.distanceM,
        onKiveto: view.onKiveto,
        onlineBooking: view.onlineBooking,
        tags: view.tags,
        nextAvailableAt: switch (view.nextAvailableAt) {
          final DateTime at => clinicInstantOf(at),
          null => null,
        },
      );

  static ListingAddress? _address(api.ListingAddressView? view) =>
      switch (view) {
        final api.ListingAddressView address => ListingAddress(
          line: address.line,
          postalCode: address.postalCode,
          city: address.city,
        ),
        null => null,
      };

  /// An opening time `HH:MM`; anything else is an answer this app cannot
  /// read.
  static ClockTime _time(String wire) =>
      ClockTime.parse(wire) ??
      (throw ServerFailure(detail: 'opening time "$wire"'));
}
