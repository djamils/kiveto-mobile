// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i2;

sealed class DownloadDataExportResponse {
  const DownloadDataExportResponse();
}

@_i1.immutable
class DownloadDataExportResponse200 extends DownloadDataExportResponse {
  const DownloadDataExportResponse200({required this.body});

  final _i2.TonikFile body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is DownloadDataExportResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class DownloadDataExportResponse404 extends DownloadDataExportResponse {
  const DownloadDataExportResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is DownloadDataExportResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
