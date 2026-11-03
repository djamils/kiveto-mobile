// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:meta/meta.dart' as _i1;

sealed class GetDocumentFileResponse {
  const GetDocumentFileResponse();
}

@_i1.immutable
class GetDocumentFileResponse302 extends GetDocumentFileResponse {
  const GetDocumentFileResponse302();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is GetDocumentFileResponse302;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetDocumentFileResponse404 extends GetDocumentFileResponse {
  const GetDocumentFileResponse404();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is GetDocumentFileResponse404;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetDocumentFileResponse401 extends GetDocumentFileResponse {
  const GetDocumentFileResponse401();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is GetDocumentFileResponse401;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}
