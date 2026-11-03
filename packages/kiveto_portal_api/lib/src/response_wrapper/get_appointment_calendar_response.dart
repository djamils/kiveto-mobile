// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:meta/meta.dart' as _i1;

sealed class GetAppointmentCalendarResponse {
  const GetAppointmentCalendarResponse();
}

@_i1.immutable
class GetAppointmentCalendarResponse200 extends GetAppointmentCalendarResponse {
  const GetAppointmentCalendarResponse200({required this.body});

  final _i2.String body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is GetAppointmentCalendarResponse200 &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetAppointmentCalendarResponse404 extends GetAppointmentCalendarResponse {
  const GetAppointmentCalendarResponse404();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is GetAppointmentCalendarResponse404;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetAppointmentCalendarResponse401 extends GetAppointmentCalendarResponse {
  const GetAppointmentCalendarResponse401();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is GetAppointmentCalendarResponse401;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}
