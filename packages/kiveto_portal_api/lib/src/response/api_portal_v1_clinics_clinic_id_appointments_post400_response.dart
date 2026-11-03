// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/problem_details.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

@_i1.immutable
sealed class ApiPortalV1ClinicsClinicIdAppointmentsPost400Response {
  const ApiPortalV1ClinicsClinicIdAppointmentsPost400Response();
}

@_i1.immutable
class ApiPortalV1ClinicsClinicIdAppointmentsPost400ResponseProblemJson
    extends ApiPortalV1ClinicsClinicIdAppointmentsPost400Response {
  const ApiPortalV1ClinicsClinicIdAppointmentsPost400ResponseProblemJson({
    required this.body,
  });

  final _i2.ProblemDetails body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other
            is ApiPortalV1ClinicsClinicIdAppointmentsPost400ResponseProblemJson &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ApiPortalV1ClinicsClinicIdAppointmentsPost400ResponseJson
    extends ApiPortalV1ClinicsClinicIdAppointmentsPost400Response {
  const ApiPortalV1ClinicsClinicIdAppointmentsPost400ResponseJson({
    required this.body,
  });

  final _i2.ProblemDetails body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ApiPortalV1ClinicsClinicIdAppointmentsPost400ResponseJson &&
        other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
