// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/updated_account_view.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_patch400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_patch422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class UpdateMeResponse {
  const UpdateMeResponse();
}

@_i1.immutable
class UpdateMeResponse200 extends UpdateMeResponse {
  const UpdateMeResponse200({required this.body});

  final _i2.UpdatedAccountView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateMeResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class UpdateMeResponse401 extends UpdateMeResponse {
  const UpdateMeResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateMeResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class UpdateMeResponse404 extends UpdateMeResponse {
  const UpdateMeResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateMeResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class UpdateMeResponse422 extends UpdateMeResponse {
  const UpdateMeResponse422({required this.body});

  final _i4.ApiPortalV1MePatch422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateMeResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class UpdateMeResponse400 extends UpdateMeResponse {
  const UpdateMeResponse400({required this.body});

  final _i5.ApiPortalV1MePatch400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateMeResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
