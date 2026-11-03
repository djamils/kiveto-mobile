// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/appointment_detail_view.dart'
    as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetAppointmentResponse {
  const GetAppointmentResponse();
}

@_i1.immutable
class GetAppointmentResponse200 extends GetAppointmentResponse {
  const GetAppointmentResponse200({required this.body});

  final _i2.AppointmentDetailView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAppointmentResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetAppointmentResponse401 extends GetAppointmentResponse {
  const GetAppointmentResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAppointmentResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetAppointmentResponse404 extends GetAppointmentResponse {
  const GetAppointmentResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetAppointmentResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
