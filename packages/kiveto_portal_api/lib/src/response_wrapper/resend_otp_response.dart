// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/resent_otp_challenge_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_otp_challenge_id_resend_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_otp_challenge_id_resend_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class ResendOtpResponse {
  const ResendOtpResponse();
}

@_i1.immutable
class ResendOtpResponse202 extends ResendOtpResponse {
  const ResendOtpResponse202({required this.body});

  final _i2.ResentOtpChallengeView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ResendOtpResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ResendOtpResponse404 extends ResendOtpResponse {
  const ResendOtpResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ResendOtpResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ResendOtpResponse422 extends ResendOtpResponse {
  const ResendOtpResponse422({required this.body});

  final _i4.ApiPortalV1AuthOtpChallengeIdResendPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ResendOtpResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ResendOtpResponse429 extends ResendOtpResponse {
  const ResendOtpResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ResendOtpResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ResendOtpResponse400 extends ResendOtpResponse {
  const ResendOtpResponse400({required this.body});

  final _i5.ApiPortalV1AuthOtpChallengeIdResendPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ResendOtpResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
