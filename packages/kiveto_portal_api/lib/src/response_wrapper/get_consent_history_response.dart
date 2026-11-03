// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/consent_history.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetConsentHistoryResponse {
  const GetConsentHistoryResponse();
}

@_i1.immutable
class GetConsentHistoryResponse200 extends GetConsentHistoryResponse {
  const GetConsentHistoryResponse200({required this.body});

  final _i2.ConsentHistory body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentHistoryResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetConsentHistoryResponse400 extends GetConsentHistoryResponse {
  const GetConsentHistoryResponse400();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentHistoryResponse400;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetConsentHistoryResponse401 extends GetConsentHistoryResponse {
  const GetConsentHistoryResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentHistoryResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetConsentHistoryResponse404 extends GetConsentHistoryResponse {
  const GetConsentHistoryResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetConsentHistoryResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
