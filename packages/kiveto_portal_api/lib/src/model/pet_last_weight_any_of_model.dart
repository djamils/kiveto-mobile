// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/pet_weight_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class $RawPetLastWeightAnyOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawPetLastWeightAnyOfModel({this.petWeightView});

  factory $RawPetLastWeightAnyOfModel.fromJson(_i3.Object? json) {
    _i4.PetWeightView? _$decodedpetWeightView;

    try {
      _$decodedpetWeightView = _i4.PetWeightView.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedpetWeightView = null;
    }

    if (_$decodedpetWeightView == null) {
      throw _i1.JsonDecodingException(
        r'Invalid JSON for $RawPetLastWeightAnyOfModel: all variants failed to decode',
      );
    }
    return $RawPetLastWeightAnyOfModel(petWeightView: _$decodedpetWeightView);
  }

  factory $RawPetLastWeightAnyOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    _i4.PetWeightView? _$decodedpetWeightView;

    try {
      _$decodedpetWeightView = _i4.PetWeightView.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedpetWeightView = null;
    }

    if (_$decodedpetWeightView == null) {
      throw _i1.SimpleDecodingException(
        r'Invalid simple value for $RawPetLastWeightAnyOfModel: all variants failed to decode',
      );
    }
    return $RawPetLastWeightAnyOfModel(petWeightView: _$decodedpetWeightView);
  }

  factory $RawPetLastWeightAnyOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    _i4.PetWeightView? _$decodedpetWeightView;

    try {
      _$decodedpetWeightView = _i4.PetWeightView.fromForm(
        value,
        explode: explode,
      );
    } on _i3.Object catch (_) {
      _$decodedpetWeightView = null;
    }

    if (_$decodedpetWeightView == null) {
      throw _i1.FormDecodingException(
        r'Invalid form value for $RawPetLastWeightAnyOfModel: all variants failed to decode',
      );
    }
    return $RawPetLastWeightAnyOfModel(petWeightView: _$decodedpetWeightView);
  }

  final _i4.PetWeightView? petWeightView;

  _i1.EncodingShape get currentEncodingShape {
    final _$shapes = <_i1.EncodingShape>{};
    if (this.petWeightView != null) {
      _$shapes.add(this.petWeightView!.currentEncodingShape);
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
    if (this.petWeightView != null) {
      final _i3.Object? _$petWeightViewJson = this.petWeightView!.toJson();
      if (_$petWeightViewJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$petWeightViewJson);
      } else {
        _$values.add(_$petWeightViewJson);
      }
    }
    if (_$values.isEmpty && _$mapValues.isEmpty) return null;
    if (_$values.isNotEmpty && _$mapValues.isNotEmpty) {
      throw _i1.EncodingException(
        r'Mixed encoding not supported for $RawPetLastWeightAnyOfModel: cannot encode both simple and complex values',
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
    if (this.petWeightView != null) {
      _$mapValues.add(
        this.petWeightView!.parameterProperties(allowEmpty: allowEmpty),
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
    if (this.petWeightView != null) {
      final _$petWeightViewSimple = this.petWeightView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$petWeightViewSimple);
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
    if (this.petWeightView != null) {
      final _$petWeightViewForm = this.petWeightView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$petWeightViewForm);
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
    if (this.petWeightView != null) {
      final _$petWeightViewLabel = this.petWeightView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$petWeightViewLabel);
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
    if (this.petWeightView != null) {
      final _$petWeightViewMatrix = this.petWeightView!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$petWeightViewMatrix);
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
    if (this.petWeightView != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode $RawPetLastWeightAnyOfModel: contains complex type',
      );
    }
    throw _i1.EncodingException(
      r'Cannot uriEncode $RawPetLastWeightAnyOfModel: no value set',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawPetLastWeightAnyOfModel &&
        other.petWeightView == this.petWeightView;
  }

  @_i3.override
  _i3.int get hashCode => this.petWeightView.hashCode;

  $RawPetLastWeightAnyOfModel Function({_i4.PetWeightView? petWeightView})
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? petWeightView = _sentinel}) =>
        $RawPetLastWeightAnyOfModel(
          petWeightView: _i3.identical(petWeightView, _sentinel)
              ? this.petWeightView
              : (petWeightView as _i4.PetWeightView?),
        );
  }
}

typedef PetLastWeightAnyOfModel = $RawPetLastWeightAnyOfModel?;
