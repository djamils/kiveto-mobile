// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/email_verification_challenge_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class RequestEmailChangeResponse {
  const RequestEmailChangeResponse();
}

@_i1.immutable
class RequestEmailChangeResponse202 extends RequestEmailChangeResponse {
  const RequestEmailChangeResponse202({required this.body});

  final _i2.EmailVerificationChallengeView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestEmailChangeResponse401 extends RequestEmailChangeResponse {
  const RequestEmailChangeResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestEmailChangeResponse422 extends RequestEmailChangeResponse {
  const RequestEmailChangeResponse422({required this.body});

  final _i4.ApiPortalV1MeEmailChangePost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestEmailChangeResponse400 extends RequestEmailChangeResponse {
  const RequestEmailChangeResponse400({required this.body});

  final _i5.ApiPortalV1MeEmailChangePost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestEmailChangeResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
