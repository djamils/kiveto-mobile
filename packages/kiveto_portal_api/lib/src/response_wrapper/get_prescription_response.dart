// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/prescription.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetPrescriptionResponse {
  const GetPrescriptionResponse();
}

@_i1.immutable
class GetPrescriptionResponse200 extends GetPrescriptionResponse {
  const GetPrescriptionResponse200({required this.body});

  final _i2.Prescription body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetPrescriptionResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetPrescriptionResponse401 extends GetPrescriptionResponse {
  const GetPrescriptionResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetPrescriptionResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetPrescriptionResponse404 extends GetPrescriptionResponse {
  const GetPrescriptionResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetPrescriptionResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
