// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/owner_request_list.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class ListRequestsResponse {
  const ListRequestsResponse();
}

@_i1.immutable
class ListRequestsResponse200 extends ListRequestsResponse {
  const ListRequestsResponse200({required this.body});

  final _i2.OwnerRequestList body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListRequestsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListRequestsResponse400 extends ListRequestsResponse {
  const ListRequestsResponse400();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListRequestsResponse400;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListRequestsResponse401 extends ListRequestsResponse {
  const ListRequestsResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListRequestsResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListRequestsResponse404 extends ListRequestsResponse {
  const ListRequestsResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListRequestsResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
