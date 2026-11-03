// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/deletion_otp_challenge_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_deletion_request_otp_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_deletion_request_otp_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestDeletionOtpResponse {
  const RequestDeletionOtpResponse();
}

@_i1.immutable
class RequestDeletionOtpResponse202 extends RequestDeletionOtpResponse {
  const RequestDeletionOtpResponse202({required this.body});

  final _i2.DeletionOtpChallengeView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDeletionOtpResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestDeletionOtpResponse401 extends RequestDeletionOtpResponse {
  const RequestDeletionOtpResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDeletionOtpResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestDeletionOtpResponse429 extends RequestDeletionOtpResponse {
  const RequestDeletionOtpResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDeletionOtpResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestDeletionOtpResponse400 extends RequestDeletionOtpResponse {
  const RequestDeletionOtpResponse400({required this.body});

  final _i4.ApiPortalV1MeDeletionRequestOtpPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDeletionOtpResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestDeletionOtpResponse422 extends RequestDeletionOtpResponse {
  const RequestDeletionOtpResponse422({required this.body});

  final _i5.ApiPortalV1MeDeletionRequestOtpPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDeletionOtpResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
