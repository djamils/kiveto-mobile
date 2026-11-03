// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/document_list.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class ListDocumentsResponse {
  const ListDocumentsResponse();
}

@_i1.immutable
class ListDocumentsResponse200 extends ListDocumentsResponse {
  const ListDocumentsResponse200({required this.body});

  final _i2.DocumentList body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDocumentsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListDocumentsResponse400 extends ListDocumentsResponse {
  const ListDocumentsResponse400();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDocumentsResponse400;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListDocumentsResponse401 extends ListDocumentsResponse {
  const ListDocumentsResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDocumentsResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListDocumentsResponse404 extends ListDocumentsResponse {
  const ListDocumentsResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDocumentsResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListDocumentsResponse422 extends ListDocumentsResponse {
  const ListDocumentsResponse422();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDocumentsResponse422;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
