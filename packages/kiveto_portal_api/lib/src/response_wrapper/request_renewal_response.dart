// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/renewal_request_created_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_prescriptions_prescription_id_renewal_requests_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_prescriptions_prescription_id_renewal_requests_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestRenewalResponse {
  const RequestRenewalResponse();
}

@_i1.immutable
class RequestRenewalResponse202 extends RequestRenewalResponse {
  const RequestRenewalResponse202({required this.body});

  final _i2.RenewalRequestCreatedView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestRenewalResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestRenewalResponse400 extends RequestRenewalResponse {
  const RequestRenewalResponse400({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdPrescriptionsPrescriptionIdRenewalRequestsPost400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestRenewalResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestRenewalResponse401 extends RequestRenewalResponse {
  const RequestRenewalResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestRenewalResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestRenewalResponse404 extends RequestRenewalResponse {
  const RequestRenewalResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestRenewalResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestRenewalResponse422 extends RequestRenewalResponse {
  const RequestRenewalResponse422({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdPrescriptionsPrescriptionIdRenewalRequestsPost422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestRenewalResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestRenewalResponse429 extends RequestRenewalResponse {
  const RequestRenewalResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestRenewalResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
