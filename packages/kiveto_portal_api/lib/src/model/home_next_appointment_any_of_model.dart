// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/appointment_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class $RawHomeNextAppointmentAnyOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawHomeNextAppointmentAnyOfModel({this.appointmentView});

  factory $RawHomeNextAppointmentAnyOfModel.fromJson(_i3.Object? json) {
    _i4.AppointmentView? _$decodedappointmentView;

    try {
      _$decodedappointmentView = _i4.AppointmentView.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedappointmentView = null;
    }

    if (_$decodedappointmentView == null) {
      throw _i1.JsonDecodingException(
        r'Invalid JSON for $RawHomeNextAppointmentAnyOfModel: all variants failed to decode',
      );
    }
    return $RawHomeNextAppointmentAnyOfModel(
      appointmentView: _$decodedappointmentView,
    );
  }

  factory $RawHomeNextAppointmentAnyOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    _i4.AppointmentView? _$decodedappointmentView;

    try {
      _$decodedappointmentView = _i4.AppointmentView.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedappointmentView = null;
    }

    if (_$decodedappointmentView == null) {
      throw _i1.SimpleDecodingException(
        r'Invalid simple value for $RawHomeNextAppointmentAnyOfModel: all variants failed to decode',
      );
    }
    return $RawHomeNextAppointmentAnyOfModel(
      appointmentView: _$decodedappointmentView,
    );
  }

  factory $RawHomeNextAppointmentAnyOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    _i4.AppointmentView? _$decodedappointmentView;

    try {
      _$decodedappointmentView = _i4.AppointmentView.fromForm(
        value,
        explode: explode,
      );
    } on _i3.Object catch (_) {
      _$decodedappointmentView = null;
    }

    if (_$decodedappointmentView == null) {
      throw _i1.FormDecodingException(
        r'Invalid form value for $RawHomeNextAppointmentAnyOfModel: all variants failed to decode',
      );
    }
    return $RawHomeNextAppointmentAnyOfModel(
      appointmentView: _$decodedappointmentView,
    );
  }

  final _i4.AppointmentView? appointmentView;

  _i1.EncodingShape get currentEncodingShape {
    final _$shapes = <_i1.EncodingShape>{};
    if (this.appointmentView != null) {
      _$shapes.add(this.appointmentView!.currentEncodingShape);
    }
    if (_$shapes.isEmpty) {
      throw _i3.StateError('At least one field must be non-null in anyOf');
    }
    if (_$shapes.length > 1) return _i1.EncodingShape.mixed;
    return _$shapes.first;
  }

  @_i3.override
  _i3.Object? toJson() {
    final _$values = <_i3.Object?>{};
    final _$mapValues = <_i3.Map<_i3.String, _i3.Object?>>[];
    if (this.appointmentView != null) {
      final _i3.Object? _$appointmentViewJson = this.appointmentView!.toJson();
      if (_$appointmentViewJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$appointmentViewJson);
      } else {
        _$values.add(_$appointmentViewJson);
      }
    }
    if (_$values.isEmpty && _$mapValues.isEmpty) return null;
    if (_$values.isNotEmpty && _$mapValues.isNotEmpty) {
      throw _i1.EncodingException(
        r'Mixed encoding not supported for $RawHomeNextAppointmentAnyOfModel: cannot encode both simple and complex values',
      );
    }
    if (_$values.isNotEmpty) {
      return _$values.first;
    }
    if (_$mapValues.isNotEmpty) {
      final _$map = <_i3.String, _i3.Object?>{};
      for (final _$m in _$mapValues) {
        _i1.mergeJsonObject(_$map, _$m);
      }
      return _$map;
    }
    return null;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.appointmentView != null) {
      _$mapValues.add(
        this.appointmentView!.parameterProperties(allowEmpty: allowEmpty),
      );
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map;
  }

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.appointmentView != null) {
      final _$appointmentViewSimple = this.appointmentView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$appointmentViewSimple);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toSimple(
      explode: explode,
      allowEmpty: allowEmpty,
      literal: literal,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toForm(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
    _i3.Map<_i3.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.appointmentView != null) {
      final _$appointmentViewForm = this.appointmentView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$appointmentViewForm);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toForm(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
      fieldEncodings: fieldEncodings,
      textEncoding: textEncoding,
    );
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.appointmentView != null) {
      final _$appointmentViewLabel = this.appointmentView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$appointmentViewLabel);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toLabel(explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.appointmentView != null) {
      final _$appointmentViewMatrix = this.appointmentView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$appointmentViewMatrix);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toMatrix(paramName, explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toDeepObject(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toDeepObject(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toPipeDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toPipeDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toSpaceDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toSpaceDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    if (this.appointmentView != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode $RawHomeNextAppointmentAnyOfModel: contains complex type',
      );
    }
    throw _i1.EncodingException(
      r'Cannot uriEncode $RawHomeNextAppointmentAnyOfModel: no value set',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawHomeNextAppointmentAnyOfModel &&
        other.appointmentView == this.appointmentView;
  }

  @_i3.override
  _i3.int get hashCode => this.appointmentView.hashCode;

  $RawHomeNextAppointmentAnyOfModel Function({
    _i4.AppointmentView? appointmentView,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? appointmentView = _sentinel}) =>
        $RawHomeNextAppointmentAnyOfModel(
          appointmentView: _i3.identical(appointmentView, _sentinel)
              ? this.appointmentView
              : (appointmentView as _i4.AppointmentView?),
        );
  }
}

typedef HomeNextAppointmentAnyOfModel = $RawHomeNextAppointmentAnyOfModel?;
