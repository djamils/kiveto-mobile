// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/clinic_listing_detail.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetClinicListingResponse {
  const GetClinicListingResponse();
}

@_i1.immutable
class GetClinicListingResponse200 extends GetClinicListingResponse {
  const GetClinicListingResponse200({required this.body});

  final _i2.ClinicListingDetail body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetClinicListingResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetClinicListingResponse404 extends GetClinicListingResponse {
  const GetClinicListingResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetClinicListingResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetClinicListingResponse429 extends GetClinicListingResponse {
  const GetClinicListingResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetClinicListingResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
