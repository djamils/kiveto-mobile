// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/session_tokens.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_refresh_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_refresh_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RefreshSessionResponse {
  const RefreshSessionResponse();
}

@_i1.immutable
class RefreshSessionResponse200 extends RefreshSessionResponse {
  const RefreshSessionResponse200({required this.body});

  final _i2.SessionTokens body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshSessionResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RefreshSessionResponse401 extends RefreshSessionResponse {
  const RefreshSessionResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshSessionResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RefreshSessionResponse400 extends RefreshSessionResponse {
  const RefreshSessionResponse400({required this.body});

  final _i4.ApiPortalV1AuthRefreshPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshSessionResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RefreshSessionResponse422 extends RefreshSessionResponse {
  const RefreshSessionResponse422({required this.body});

  final _i5.ApiPortalV1AuthRefreshPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshSessionResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
