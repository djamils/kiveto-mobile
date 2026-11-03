// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/email_change_otp_challenge_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_otp_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_otp_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestEmailChangeOtpResponse {
  const RequestEmailChangeOtpResponse();
}

@_i1.immutable
class RequestEmailChangeOtpResponse202 extends RequestEmailChangeOtpResponse {
  const RequestEmailChangeOtpResponse202({required this.body});

  final _i2.EmailChangeOtpChallengeView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeOtpResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestEmailChangeOtpResponse401 extends RequestEmailChangeOtpResponse {
  const RequestEmailChangeOtpResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeOtpResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestEmailChangeOtpResponse429 extends RequestEmailChangeOtpResponse {
  const RequestEmailChangeOtpResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeOtpResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestEmailChangeOtpResponse400 extends RequestEmailChangeOtpResponse {
  const RequestEmailChangeOtpResponse400({required this.body});

  final _i4.ApiPortalV1MeEmailChangeOtpPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeOtpResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestEmailChangeOtpResponse422 extends RequestEmailChangeOtpResponse {
  const RequestEmailChangeOtpResponse422({required this.body});

  final _i5.ApiPortalV1MeEmailChangeOtpPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeOtpResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
