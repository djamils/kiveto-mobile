// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_logout_post400_response.dart'
    as _i3;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_logout_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class LogoutResponse {
  const LogoutResponse();
}

@_i1.immutable
class LogoutResponse204 extends LogoutResponse {
  const LogoutResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LogoutResponse204;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class LogoutResponse401 extends LogoutResponse {
  const LogoutResponse401();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LogoutResponse401;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class LogoutResponse400 extends LogoutResponse {
  const LogoutResponse400({required this.body});

  final _i3.ApiPortalV1AuthLogoutPost400Response body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LogoutResponse400 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LogoutResponse422 extends LogoutResponse {
  const LogoutResponse422({required this.body});

  final _i4.ApiPortalV1AuthLogoutPost422Response body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LogoutResponse422 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}
