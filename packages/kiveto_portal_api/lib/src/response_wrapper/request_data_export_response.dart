// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/data_export_request_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_data_export_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_data_export_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RequestDataExportResponse {
  const RequestDataExportResponse();
}

@_i1.immutable
class RequestDataExportResponse202 extends RequestDataExportResponse {
  const RequestDataExportResponse202({required this.body});

  final _i2.DataExportRequestView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDataExportResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestDataExportResponse401 extends RequestDataExportResponse {
  const RequestDataExportResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDataExportResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestDataExportResponse429 extends RequestDataExportResponse {
  const RequestDataExportResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDataExportResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RequestDataExportResponse400 extends RequestDataExportResponse {
  const RequestDataExportResponse400({required this.body});

  final _i4.ApiPortalV1MeDataExportPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDataExportResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RequestDataExportResponse422 extends RequestDataExportResponse {
  const RequestDataExportResponse422({required this.body});

  final _i5.ApiPortalV1MeDataExportPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RequestDataExportResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
