// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/booked_with_new_pet_appointment_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_with_new_pet_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_with_new_pet_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse();
}

@_i1.immutable
class BookAppointmentWithNewPetResponse201
    extends BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse201({required this.body});

  final _i2.BookedWithNewPetAppointmentView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentWithNewPetResponse201 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class BookAppointmentWithNewPetResponse400
    extends BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse400({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdAppointmentsWithNewPetPost400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentWithNewPetResponse400 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class BookAppointmentWithNewPetResponse401
    extends BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentWithNewPetResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class BookAppointmentWithNewPetResponse404
    extends BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentWithNewPetResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class BookAppointmentWithNewPetResponse409
    extends BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse409();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentWithNewPetResponse409;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class BookAppointmentWithNewPetResponse422
    extends BookAppointmentWithNewPetResponse {
  const BookAppointmentWithNewPetResponse422({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdAppointmentsWithNewPetPost422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookAppointmentWithNewPetResponse422 &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
