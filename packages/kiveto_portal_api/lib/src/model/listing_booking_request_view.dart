// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/booking_request_pet_view.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/clinic_summary_view.dart' as _i4;
import 'package:kiveto_portal_api/src/model/listing_booking_booking_request_view_decline_reason_model.dart'
    as _i7;
import 'package:kiveto_portal_api/src/model/listing_booking_booking_request_view_status_model.dart'
    as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ListingBookingRequestView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ListingBookingRequestView({
    required this.id,
    required this.clinic,
    required this.pet,
    required this.motif,
    required this.startAt,
    required this.status,
    required this.declineReason,
    required this.appointmentId,
  });

  factory ListingBookingRequestView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ListingBookingRequestView: contains complex types',
    );
  }

  factory ListingBookingRequestView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ListingBookingRequestView');
    return ListingBookingRequestView(
      id: _$map[r'id'].decodeJsonString(
        context: r'ListingBookingRequestView.id',
      ),
      clinic: _i4.ClinicSummaryView.fromJson(_$map[r'clinic']),
      pet: _i5.BookingRequestPetView.fromJson(_$map[r'pet']),
      motif: _$map[r'motif'].decodeJsonString(
        context: r'ListingBookingRequestView.motif',
      ),
      startAt: _$map[r'startAt'].decodeJsonDateTime(
        context: r'ListingBookingRequestView.startAt',
      ),
      status: _i6.ListingBookingBookingRequestViewStatusModel.fromJson(
        _$map[r'status'],
      ),
      declineReason: _$map[r'declineReason'] == null
          ? null
          : _i7.ListingBookingBookingRequestViewDeclineReasonModel.fromJson(
              _$map[r'declineReason'],
            ),
      appointmentId: _$map[r'appointmentId'].decodeJsonNullableString(
        context: r'ListingBookingRequestView.appointmentId',
      ),
    );
  }

  factory ListingBookingRequestView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ListingBookingRequestView: contains complex types',
    );
  }

  final _i3.String id;

  final _i4.ClinicSummaryView clinic;

  final _i5.BookingRequestPetView pet;

  /// The motif's label.
  final _i3.String motif;

  final _i3.DateTime startAt;

  final _i6.ListingBookingBookingRequestViewStatusModel status;

  final _i7.ListingBookingBookingRequestViewDeclineReasonModel? declineReason;

  final _i3.String? appointmentId;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'clinic': this.clinic.toJson(),
    r'pet': this.pet.toJson(),
    r'motif': this.motif,
    r'startAt': this.startAt.toTimeZonedIso8601String(),
    r'status': this.status.toJson(),
    r'declineReason': this.declineReason?.toJson(),
    r'appointmentId': this.appointmentId,
  };

  ListingBookingRequestView Function({
    _i3.String? id,
    _i4.ClinicSummaryView? clinic,
    _i5.BookingRequestPetView? pet,
    _i3.String? motif,
    _i3.DateTime? startAt,
    _i6.ListingBookingBookingRequestViewStatusModel? status,
    _i7.ListingBookingBookingRequestViewDeclineReasonModel? declineReason,
    _i3.String? appointmentId,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i4.ClinicSummaryView? clinic,
      _i5.BookingRequestPetView? pet,
      _i3.String? motif,
      _i3.DateTime? startAt,
      _i6.ListingBookingBookingRequestViewStatusModel? status,
      _i3.Object? declineReason = _sentinel,
      _i3.Object? appointmentId = _sentinel,
    }) => ListingBookingRequestView(
      id: id ?? this.id,
      clinic: clinic ?? this.clinic,
      pet: pet ?? this.pet,
      motif: motif ?? this.motif,
      startAt: startAt ?? this.startAt,
      status: status ?? this.status,
      declineReason: _i3.identical(declineReason, _sentinel)
          ? this.declineReason
          : (declineReason
                as _i7.ListingBookingBookingRequestViewDeclineReasonModel?),
      appointmentId: _i3.identical(appointmentId, _sentinel)
          ? this.appointmentId
          : (appointmentId as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListingBookingRequestView &&
        other.id == this.id &&
        other.clinic == this.clinic &&
        other.pet == this.pet &&
        other.motif == this.motif &&
        other.startAt == this.startAt &&
        other.status == this.status &&
        other.declineReason == this.declineReason &&
        other.appointmentId == this.appointmentId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.clinic,
      this.pet,
      this.motif,
      this.startAt,
      this.status,
      this.declineReason,
      this.appointmentId,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for ListingBookingRequestView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i8.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ListingBookingRequestView: complex types cannot be URI-encoded',
    );
  }
}
