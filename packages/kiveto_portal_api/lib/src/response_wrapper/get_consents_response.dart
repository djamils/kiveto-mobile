// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/consents.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetConsentsResponse {
  const GetConsentsResponse();
}

@_i1.immutable
class GetConsentsResponse200 extends GetConsentsResponse {
  const GetConsentsResponse200({required this.body});

  final _i2.Consents body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetConsentsResponse401 extends GetConsentsResponse {
  const GetConsentsResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentsResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetConsentsResponse404 extends GetConsentsResponse {
  const GetConsentsResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentsResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
