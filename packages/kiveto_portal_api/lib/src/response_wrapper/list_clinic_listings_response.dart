// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/clinic_listings.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinic_listings_get404_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class ListClinicListingsResponse {
  const ListClinicListingsResponse();
}

@_i1.immutable
class ListClinicListingsResponse200 extends ListClinicListingsResponse {
  const ListClinicListingsResponse200({required this.body});

  final _i2.ClinicListings body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListClinicListingsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListClinicListingsResponse400 extends ListClinicListingsResponse {
  const ListClinicListingsResponse400();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListClinicListingsResponse400;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListClinicListingsResponse422 extends ListClinicListingsResponse {
  const ListClinicListingsResponse422();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListClinicListingsResponse422;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListClinicListingsResponse429 extends ListClinicListingsResponse {
  const ListClinicListingsResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListClinicListingsResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListClinicListingsResponse404 extends ListClinicListingsResponse {
  const ListClinicListingsResponse404({required this.body});

  final _i4.ApiPortalV1ClinicListingsGet404Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListClinicListingsResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
