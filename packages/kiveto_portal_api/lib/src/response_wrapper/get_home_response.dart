// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/home.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetHomeResponse {
  const GetHomeResponse();
}

@_i1.immutable
class GetHomeResponse200 extends GetHomeResponse {
  const GetHomeResponse200({required this.body});

  final _i2.Home body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetHomeResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetHomeResponse401 extends GetHomeResponse {
  const GetHomeResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetHomeResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetHomeResponse404 extends GetHomeResponse {
  const GetHomeResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetHomeResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
