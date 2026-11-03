// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i8;

import 'package:dio/dio.dart' as _i11;
import 'package:kiveto_portal_api/src/model/listing_booking.dart' as _i14;
import 'package:kiveto_portal_api/src/operation/get_clinic_listing.dart' as _i3;
import 'package:kiveto_portal_api/src/operation/get_listing_availability.dart'
    as _i5;
import 'package:kiveto_portal_api/src/operation/list_clinic_listings.dart'
    as _i2;
import 'package:kiveto_portal_api/src/operation/list_listing_motifs.dart'
    as _i6;
import 'package:kiveto_portal_api/src/operation/list_listing_practitioners.dart'
    as _i7;
import 'package:kiveto_portal_api/src/operation/request_listing_appointment.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response_wrapper/get_clinic_listing_response.dart'
    as _i12;
import 'package:kiveto_portal_api/src/response_wrapper/get_listing_availability_response.dart'
    as _i15;
import 'package:kiveto_portal_api/src/response_wrapper/list_clinic_listings_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response_wrapper/list_listing_motifs_response.dart'
    as _i16;
import 'package:kiveto_portal_api/src/response_wrapper/list_listing_practitioners_response.dart'
    as _i17;
import 'package:kiveto_portal_api/src/response_wrapper/request_listing_appointment_response.dart'
    as _i13;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i9;

/// A practitioner a new client may book online for the motif; the route answers a plain JSON array of them.
class ClinicListingApi {
  ClinicListingApi(_i1.Server server)
    : _listClinicListings = _i2.ListClinicListings(
        server.baseUrl,
        () => server.dio,
      ),
      _getClinicListing = _i3.GetClinicListing(
        server.baseUrl,
        () => server.dio,
      ),
      _requestListingAppointment = _i4.RequestListingAppointment(
        server.baseUrl,
        () => server.dio,
      ),
      _getListingAvailability = _i5.GetListingAvailability(
        server.baseUrl,
        () => server.dio,
      ),
      _listListingMotifs = _i6.ListListingMotifs(
        server.baseUrl,
        () => server.dio,
      ),
      _listListingPractitioners = _i7.ListListingPractitioners(
        server.baseUrl,
        () => server.dio,
      );

  final _i2.ListClinicListings _listClinicListings;

  final _i3.GetClinicListing _getClinicListing;

  final _i4.RequestListingAppointment _requestListingAppointment;

  final _i5.GetListingAvailability _getListingAvailability;

  final _i6.ListListingMotifs _listListingMotifs;

  final _i7.ListListingPractitioners _listListingPractitioners;

  /// Rechercher une clinique de l'annuaire.
  /// Publique. Seules les cliniques Kiveto actives qui ont choisi de figurer dans l'annuaire. `q` (2 caractères au moins) cherche dans le nom et la ville. Avec `lat` et `lng` (ensemble) : tri par distance (150 km au plus), les cliniques sans coordonnées sont absentes de ce résultat seulement ; sinon tri par nom. Le curseur est lié à l'ordre et aux coordonnées de la recherche. `onlineBooking` est calculé en direct. `nextAvailableAt` est toujours `null` en v1.
  _i8.Future<
    _i9.TonikResult<_i10.ListClinicListingsResponse, _i11.Response<_i8.Object?>>
  >
  listClinicListings({
    _i8.String? q,
    _i8.num? lat,
    _i8.num? lng,
    _i8.String? cursor,
    _i8.int? limit,
    _i9.TonikCancellation? cancellation,
  }) async => this._listClinicListings(
    q: q,
    lat: lat,
    lng: lng,
    cursor: cursor,
    limit: limit,
    cancellation: cancellation,
  );

  /// La fiche d'une clinique de l'annuaire.
  /// Publique (servira les pages web indexables). `openingHours` : les plages de la semaine type, par jour ISO (1 = lundi) puis heure d'ouverture, en heure locale de la clinique (`timezone`) ; les fermetures exceptionnelles n'y figurent pas.
  _i8.Future<
    _i9.TonikResult<_i12.GetClinicListingResponse, _i11.Response<_i8.Object?>>
  >
  getClinicListing({
    required _i8.String listingId,
    _i9.TonikCancellation? cancellation,
  }) async =>
      this._getClinicListing(listingId: listingId, cancellation: cancellation);

  /// Demande un premier rendez-vous à une clinique de l'annuaire, en nouveau client.
  /// Authentifié (seule route non-GET sous `/clinic-listings`). Le créneau est réservé en attente de confirmation par la clinique (toujours manuelle pour un nouveau client) ; aucun lien avec la clinique n'est créé avant qu'elle confirme. Au plus 1 demande en attente par clinique et 3 en tout ; 10 demandes par 24 h. La demande se suit avec `GET /me/booking-requests`.
  _i8.Future<
    _i9.TonikResult<
      _i13.RequestListingAppointmentResponse,
      _i11.Response<_i8.Object?>
    >
  >
  requestListingAppointment({
    required _i14.ListingBooking body,
    required _i8.String listingId,
    required _i8.String idempotencyKey,
    _i9.TonikCancellation? cancellation,
  }) async => this._requestListingAppointment(
    body: body,
    listingId: listingId,
    idempotencyKey: idempotencyKey,
    cancellation: cancellation,
  );

  /// Les créneaux réservables en ligne par un nouveau client.
  /// Publique. Même forme et mêmes règles que `/clinics/{clinicId}/booking/availability`, mais un nouveau client est toujours validé par la clinique : seuls les créneaux au-delà du délai de confirmation sont proposés.
  _i8.Future<
    _i9.TonikResult<
      _i15.GetListingAvailabilityResponse,
      _i11.Response<_i8.Object?>
    >
  >
  getListingAvailability({
    required _i8.String listingId,
    required _i8.String motifId,
    required _i8.String practitionerId,
    required _i9.Date from,
    required _i9.Date to,
    _i9.TonikCancellation? cancellation,
  }) async => this._getListingAvailability(
    listingId: listingId,
    motifId: motifId,
    practitionerId: practitionerId,
    from: from,
    to: to,
    cancellation: cancellation,
  );

  /// Les motifs réservables en ligne par un nouveau client.
  /// Publique. Même forme que `/clinics/{clinicId}/booking/motifs`, dans l'ordre de la clinique : seuls les motifs ouverts en ligne aux nouveaux clients. Sans animal, `suggested` est toujours `false`.
  _i8.Future<
    _i9.TonikResult<_i16.ListListingMotifsResponse, _i11.Response<_i8.Object?>>
  >
  listListingMotifs({
    required _i8.String listingId,
    _i9.TonikCancellation? cancellation,
  }) async =>
      this._listListingMotifs(listingId: listingId, cancellation: cancellation);

  /// Les praticiens réservables en ligne par un nouveau client pour un motif.
  /// Publique. Même forme que `/clinics/{clinicId}/booking/practitioners`.
  _i8.Future<
    _i9.TonikResult<
      _i17.ListListingPractitionersResponse,
      _i11.Response<_i8.Object?>
    >
  >
  listListingPractitioners({
    required _i8.String listingId,
    required _i8.String motifId,
    _i9.TonikCancellation? cancellation,
  }) async => this._listListingPractitioners(
    listingId: listingId,
    motifId: motifId,
    cancellation: cancellation,
  );
}
