// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/appointment_list.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class ListAppointmentsResponse {
  const ListAppointmentsResponse();
}

@_i1.immutable
class ListAppointmentsResponse200 extends ListAppointmentsResponse {
  const ListAppointmentsResponse200({required this.body});

  final _i2.AppointmentList body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListAppointmentsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListAppointmentsResponse400 extends ListAppointmentsResponse {
  const ListAppointmentsResponse400();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListAppointmentsResponse400;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListAppointmentsResponse401 extends ListAppointmentsResponse {
  const ListAppointmentsResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListAppointmentsResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListAppointmentsResponse404 extends ListAppointmentsResponse {
  const ListAppointmentsResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListAppointmentsResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListAppointmentsResponse422 extends ListAppointmentsResponse {
  const ListAppointmentsResponse422();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListAppointmentsResponse422;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
