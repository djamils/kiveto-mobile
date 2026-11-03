// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/listing_booking_request_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinic_listings_listing_id_booking_appointments_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinic_listings_listing_id_booking_appointments_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse();
}

@_i1.immutable
class RequestListingAppointmentResponse201
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse201({required this.body});

  final _i2.ListingBookingRequestView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse201 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestListingAppointmentResponse400
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse400({required this.body});

  final _i4.ApiPortalV1ClinicListingsListingIdBookingAppointmentsPost400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse400 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestListingAppointmentResponse401
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestListingAppointmentResponse404
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestListingAppointmentResponse409
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse409();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse409;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestListingAppointmentResponse422
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse422({required this.body});

  final _i5.ApiPortalV1ClinicListingsListingIdBookingAppointmentsPost422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse422 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestListingAppointmentResponse429
    extends RequestListingAppointmentResponse {
  const RequestListingAppointmentResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestListingAppointmentResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
