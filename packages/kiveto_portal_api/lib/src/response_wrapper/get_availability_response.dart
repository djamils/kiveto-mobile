// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/booking_availability.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetAvailabilityResponse {
  const GetAvailabilityResponse();
}

@_i1.immutable
class GetAvailabilityResponse200 extends GetAvailabilityResponse {
  const GetAvailabilityResponse200({required this.body});

  final _i2.BookingAvailability body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAvailabilityResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetAvailabilityResponse401 extends GetAvailabilityResponse {
  const GetAvailabilityResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAvailabilityResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetAvailabilityResponse404 extends GetAvailabilityResponse {
  const GetAvailabilityResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAvailabilityResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetAvailabilityResponse422 extends GetAvailabilityResponse {
  const GetAvailabilityResponse422();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAvailabilityResponse422;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
