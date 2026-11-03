// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/listing_availability.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetListingAvailabilityResponse {
  const GetListingAvailabilityResponse();
}

@_i1.immutable
class GetListingAvailabilityResponse200 extends GetListingAvailabilityResponse {
  const GetListingAvailabilityResponse200({required this.body});

  final _i2.ListingAvailability body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetListingAvailabilityResponse200 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetListingAvailabilityResponse404 extends GetListingAvailabilityResponse {
  const GetListingAvailabilityResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetListingAvailabilityResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetListingAvailabilityResponse422 extends GetListingAvailabilityResponse {
  const GetListingAvailabilityResponse422();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetListingAvailabilityResponse422;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetListingAvailabilityResponse429 extends GetListingAvailabilityResponse {
  const GetListingAvailabilityResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetListingAvailabilityResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
