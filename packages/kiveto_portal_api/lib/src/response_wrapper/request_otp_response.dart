// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/otp_challenge_view.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_otp_request_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_otp_request_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class RequestOtpResponse {
  const RequestOtpResponse();
}

@_i1.immutable
class RequestOtpResponse202 extends RequestOtpResponse {
  const RequestOtpResponse202({required this.body});

  final _i2.OtpChallengeView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestOtpResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestOtpResponse422 extends RequestOtpResponse {
  const RequestOtpResponse422({required this.body});

  final _i4.ApiPortalV1AuthOtpRequestPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestOtpResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestOtpResponse429 extends RequestOtpResponse {
  const RequestOtpResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestOtpResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestOtpResponse400 extends RequestOtpResponse {
  const RequestOtpResponse400({required this.body});

  final _i5.ApiPortalV1AuthOtpRequestPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestOtpResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
