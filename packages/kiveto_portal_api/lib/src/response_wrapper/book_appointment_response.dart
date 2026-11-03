// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/booked_appointment_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class BookAppointmentResponse {
  const BookAppointmentResponse();
}

@_i1.immutable
class BookAppointmentResponse201 extends BookAppointmentResponse {
  const BookAppointmentResponse201({required this.body});

  final _i2.BookedAppointmentView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentResponse201 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class BookAppointmentResponse400 extends BookAppointmentResponse {
  const BookAppointmentResponse400({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdAppointmentsPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class BookAppointmentResponse401 extends BookAppointmentResponse {
  const BookAppointmentResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class BookAppointmentResponse404 extends BookAppointmentResponse {
  const BookAppointmentResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class BookAppointmentResponse409 extends BookAppointmentResponse {
  const BookAppointmentResponse409();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentResponse409;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class BookAppointmentResponse422 extends BookAppointmentResponse {
  const BookAppointmentResponse422({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdAppointmentsPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
