// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/invitation_otp_challenge_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_otp_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_otp_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse();
}

@_i1.immutable
class RequestInvitationOtpResponse202 extends RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse202({required this.body});

  final _i2.InvitationOtpChallengeView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestInvitationOtpResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestInvitationOtpResponse404 extends RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestInvitationOtpResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestInvitationOtpResponse410 extends RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse410();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestInvitationOtpResponse410;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestInvitationOtpResponse429 extends RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestInvitationOtpResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestInvitationOtpResponse400 extends RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse400({required this.body});

  final _i4.ApiPortalV1InvitationsOtpPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestInvitationOtpResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestInvitationOtpResponse422 extends RequestInvitationOtpResponse {
  const RequestInvitationOtpResponse422({required this.body});

  final _i5.ApiPortalV1InvitationsOtpPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestInvitationOtpResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
