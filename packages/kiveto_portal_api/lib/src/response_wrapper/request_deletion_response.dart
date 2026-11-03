// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:kiveto_portal_api/src/response/api_portal_v1_me_deletion_request_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_deletion_request_post422_response.dart'
    as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class RequestDeletionResponse {
  const RequestDeletionResponse();
}

@_i1.immutable
class RequestDeletionResponse202 extends RequestDeletionResponse {
  const RequestDeletionResponse202();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RequestDeletionResponse202;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestDeletionResponse401 extends RequestDeletionResponse {
  const RequestDeletionResponse401();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RequestDeletionResponse401;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestDeletionResponse422 extends RequestDeletionResponse {
  const RequestDeletionResponse422({required this.body});

  final _i3.ApiPortalV1MeDeletionRequestPost422Response body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RequestDeletionResponse422 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestDeletionResponse400 extends RequestDeletionResponse {
  const RequestDeletionResponse400({required this.body});

  final _i4.ApiPortalV1MeDeletionRequestPost400Response body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RequestDeletionResponse400 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}
