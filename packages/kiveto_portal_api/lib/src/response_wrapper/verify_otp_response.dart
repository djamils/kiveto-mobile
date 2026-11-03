// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/otp_verification_result.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_otp_verify_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_otp_verify_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class VerifyOtpResponse {
  const VerifyOtpResponse();
}

@_i1.immutable
class VerifyOtpResponse200 extends VerifyOtpResponse {
  const VerifyOtpResponse200({required this.body});

  final _i2.OtpVerificationResult body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyOtpResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class VerifyOtpResponse403 extends VerifyOtpResponse {
  const VerifyOtpResponse403();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyOtpResponse403;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class VerifyOtpResponse422 extends VerifyOtpResponse {
  const VerifyOtpResponse422({required this.body});

  final _i4.ApiPortalV1AuthOtpVerifyPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyOtpResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class VerifyOtpResponse400 extends VerifyOtpResponse {
  const VerifyOtpResponse400({required this.body});

  final _i5.ApiPortalV1AuthOtpVerifyPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyOtpResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
