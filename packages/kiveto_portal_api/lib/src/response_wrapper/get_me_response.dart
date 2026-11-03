// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/me.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_get404_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class GetMeResponse {
  const GetMeResponse();
}

@_i1.immutable
class GetMeResponse200 extends GetMeResponse {
  const GetMeResponse200({required this.body});

  final _i2.Me body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetMeResponse401 extends GetMeResponse {
  const GetMeResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetMeResponse404 extends GetMeResponse {
  const GetMeResponse404({required this.body});

  final _i4.ApiPortalV1MeGet404Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
