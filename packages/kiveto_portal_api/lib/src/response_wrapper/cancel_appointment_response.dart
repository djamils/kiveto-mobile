// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/cancelled_appointment_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_appointment_id_cancel_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_appointment_id_cancel_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class CancelAppointmentResponse {
  const CancelAppointmentResponse();
}

@_i1.immutable
class CancelAppointmentResponse200 extends CancelAppointmentResponse {
  const CancelAppointmentResponse200({required this.body});

  final _i2.CancelledAppointmentView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CancelAppointmentResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CancelAppointmentResponse401 extends CancelAppointmentResponse {
  const CancelAppointmentResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CancelAppointmentResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class CancelAppointmentResponse404 extends CancelAppointmentResponse {
  const CancelAppointmentResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CancelAppointmentResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class CancelAppointmentResponse422 extends CancelAppointmentResponse {
  const CancelAppointmentResponse422({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdAppointmentsAppointmentIdCancelPost422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CancelAppointmentResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CancelAppointmentResponse400 extends CancelAppointmentResponse {
  const CancelAppointmentResponse400({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdAppointmentsAppointmentIdCancelPost400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CancelAppointmentResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
