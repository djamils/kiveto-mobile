// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/updated_consents.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_consents_kind_put400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_consents_kind_put422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class UpdateConsentResponse {
  const UpdateConsentResponse();
}

@_i1.immutable
class UpdateConsentResponse200 extends UpdateConsentResponse {
  const UpdateConsentResponse200({required this.body});

  final _i2.UpdatedConsents body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateConsentResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class UpdateConsentResponse401 extends UpdateConsentResponse {
  const UpdateConsentResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateConsentResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class UpdateConsentResponse404 extends UpdateConsentResponse {
  const UpdateConsentResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateConsentResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class UpdateConsentResponse409 extends UpdateConsentResponse {
  const UpdateConsentResponse409();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateConsentResponse409;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class UpdateConsentResponse422 extends UpdateConsentResponse {
  const UpdateConsentResponse422({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdConsentsKindPut422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateConsentResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class UpdateConsentResponse400 extends UpdateConsentResponse {
  const UpdateConsentResponse400({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdConsentsKindPut400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateConsentResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
