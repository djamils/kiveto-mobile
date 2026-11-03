// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/saved_questionnaire_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_appointment_id_questionnaire_put400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_appointment_id_questionnaire_put422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class SaveQuestionnaireResponse {
  const SaveQuestionnaireResponse();
}

@_i1.immutable
class SaveQuestionnaireResponse200 extends SaveQuestionnaireResponse {
  const SaveQuestionnaireResponse200({required this.body});

  final _i2.SavedQuestionnaireView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SaveQuestionnaireResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class SaveQuestionnaireResponse401 extends SaveQuestionnaireResponse {
  const SaveQuestionnaireResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SaveQuestionnaireResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class SaveQuestionnaireResponse404 extends SaveQuestionnaireResponse {
  const SaveQuestionnaireResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SaveQuestionnaireResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class SaveQuestionnaireResponse422 extends SaveQuestionnaireResponse {
  const SaveQuestionnaireResponse422({required this.body});

  final _i4.ApiPortalV1ClinicsClinicIdAppointmentsAppointmentIdQuestionnairePut422Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SaveQuestionnaireResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class SaveQuestionnaireResponse400 extends SaveQuestionnaireResponse {
  const SaveQuestionnaireResponse400({required this.body});

  final _i5.ApiPortalV1ClinicsClinicIdAppointmentsAppointmentIdQuestionnairePut400Response
  body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SaveQuestionnaireResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
