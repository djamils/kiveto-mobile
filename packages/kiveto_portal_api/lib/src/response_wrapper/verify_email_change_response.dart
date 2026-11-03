// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/verified_email_account_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_verify_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_verify_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class VerifyEmailChangeResponse {
  const VerifyEmailChangeResponse();
}

@_i1.immutable
class VerifyEmailChangeResponse200 extends VerifyEmailChangeResponse {
  const VerifyEmailChangeResponse200({required this.body});

  final _i2.VerifiedEmailAccountView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyEmailChangeResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class VerifyEmailChangeResponse401 extends VerifyEmailChangeResponse {
  const VerifyEmailChangeResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyEmailChangeResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class VerifyEmailChangeResponse422 extends VerifyEmailChangeResponse {
  const VerifyEmailChangeResponse422({required this.body});

  final _i4.ApiPortalV1MeEmailChangeVerifyPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyEmailChangeResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class VerifyEmailChangeResponse400 extends VerifyEmailChangeResponse {
  const VerifyEmailChangeResponse400({required this.body});

  final _i5.ApiPortalV1MeEmailChangeVerifyPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VerifyEmailChangeResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
