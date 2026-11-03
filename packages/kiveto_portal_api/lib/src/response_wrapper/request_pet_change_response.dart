// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/portal_request_created_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_pets_pet_id_change_requests_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_pets_pet_id_change_requests_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestPetChangeResponse {
  const RequestPetChangeResponse();
}

@_i1.immutable
class RequestPetChangeResponse202 extends RequestPetChangeResponse {
  const RequestPetChangeResponse202({required this.body});

  final _i2.PortalRequestCreatedView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestPetChangeResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestPetChangeResponse400 extends RequestPetChangeResponse {
  const RequestPetChangeResponse400({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdPetsPetIdChangeRequestsPost400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestPetChangeResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestPetChangeResponse401 extends RequestPetChangeResponse {
  const RequestPetChangeResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestPetChangeResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestPetChangeResponse404 extends RequestPetChangeResponse {
  const RequestPetChangeResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestPetChangeResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestPetChangeResponse422 extends RequestPetChangeResponse {
  const RequestPetChangeResponse422({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdPetsPetIdChangeRequestsPost422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestPetChangeResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestPetChangeResponse429 extends RequestPetChangeResponse {
  const RequestPetChangeResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestPetChangeResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
