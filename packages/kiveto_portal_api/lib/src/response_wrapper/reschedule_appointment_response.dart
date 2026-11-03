// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/rescheduled_appointment_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_appointment_id_reschedule_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_appointment_id_reschedule_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse();
}

@_i1.immutable
class RescheduleAppointmentResponse200 extends RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse200({required this.body});

  final _i2.RescheduledAppointmentView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RescheduleAppointmentResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RescheduleAppointmentResponse401 extends RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RescheduleAppointmentResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RescheduleAppointmentResponse404 extends RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RescheduleAppointmentResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RescheduleAppointmentResponse409 extends RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse409();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RescheduleAppointmentResponse409;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RescheduleAppointmentResponse422 extends RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse422({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdAppointmentsAppointmentIdReschedulePost422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RescheduleAppointmentResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RescheduleAppointmentResponse400 extends RescheduleAppointmentResponse {
  const RescheduleAppointmentResponse400({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdAppointmentsAppointmentIdReschedulePost400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RescheduleAppointmentResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
