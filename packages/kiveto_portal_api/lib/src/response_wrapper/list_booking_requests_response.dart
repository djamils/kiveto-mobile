// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/booking_requests.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_booking_requests_get404_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class ListBookingRequestsResponse {
  const ListBookingRequestsResponse();
}

@_i1.immutable
class ListBookingRequestsResponse200 extends ListBookingRequestsResponse {
  const ListBookingRequestsResponse200({required this.body});

  final _i2.BookingRequests body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListBookingRequestsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListBookingRequestsResponse400 extends ListBookingRequestsResponse {
  const ListBookingRequestsResponse400();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListBookingRequestsResponse400;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListBookingRequestsResponse401 extends ListBookingRequestsResponse {
  const ListBookingRequestsResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListBookingRequestsResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListBookingRequestsResponse404 extends ListBookingRequestsResponse {
  const ListBookingRequestsResponse404({required this.body});

  final _i4.ApiPortalV1MeBookingRequestsGet404Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListBookingRequestsResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
