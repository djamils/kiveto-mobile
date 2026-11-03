// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/me_update.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

@_i1.immutable
sealed class ApiPortalV1MePatchBodyRequestBody {
  const ApiPortalV1MePatchBodyRequestBody();
}

@_i1.immutable
class ApiPortalV1MePatchBodyRequestBodyJson
    extends ApiPortalV1MePatchBodyRequestBody {
  const ApiPortalV1MePatchBodyRequestBodyJson(this.value);

  final _i2.MeUpdate value;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ApiPortalV1MePatchBodyRequestBodyJson &&
        other.value == this.value;
  }

  @_i3.override
  _i3.int get hashCode => this.value.hashCode;
}

@_i1.immutable
class ApiPortalV1MePatchBodyRequestBodyMergePatchJson
    extends ApiPortalV1MePatchBodyRequestBody {
  const ApiPortalV1MePatchBodyRequestBodyMergePatchJson(this.value);

  final _i2.MeUpdate value;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ApiPortalV1MePatchBodyRequestBodyMergePatchJson &&
        other.value == this.value;
  }

  @_i3.override
  _i3.int get hashCode => this.value.hashCode;
}
