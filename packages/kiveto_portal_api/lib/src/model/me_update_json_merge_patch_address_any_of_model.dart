// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/profile_address.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class $RawMeUpdateJsonMergePatchAddressAnyOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawMeUpdateJsonMergePatchAddressAnyOfModel({this.profileAddress});

  factory $RawMeUpdateJsonMergePatchAddressAnyOfModel.fromJson(
    _i3.Object? json,
  ) {
    _i4.ProfileAddress? _$decodedprofileAddress;

    try {
      _$decodedprofileAddress = _i4.ProfileAddress.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedprofileAddress = null;
    }

    if (_$decodedprofileAddress == null) {
      throw _i1.JsonDecodingException(
        r'Invalid JSON for $RawMeUpdateJsonMergePatchAddressAnyOfModel: all variants failed to decode',
      );
    }
    return $RawMeUpdateJsonMergePatchAddressAnyOfModel(
      profileAddress: _$decodedprofileAddress,
    );
  }

  factory $RawMeUpdateJsonMergePatchAddressAnyOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    _i4.ProfileAddress? _$decodedprofileAddress;

    try {
      _$decodedprofileAddress = _i4.ProfileAddress.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedprofileAddress = null;
    }

    if (_$decodedprofileAddress == null) {
      throw _i1.SimpleDecodingException(
        r'Invalid simple value for $RawMeUpdateJsonMergePatchAddressAnyOfModel: all variants failed to decode',
      );
    }
    return $RawMeUpdateJsonMergePatchAddressAnyOfModel(
      profileAddress: _$decodedprofileAddress,
    );
  }

  factory $RawMeUpdateJsonMergePatchAddressAnyOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    _i4.ProfileAddress? _$decodedprofileAddress;

    try {
      _$decodedprofileAddress = _i4.ProfileAddress.fromForm(
        value,
        explode: explode,
      );
    } on _i3.Object catch (_) {
      _$decodedprofileAddress = null;
    }

    if (_$decodedprofileAddress == null) {
      throw _i1.FormDecodingException(
        r'Invalid form value for $RawMeUpdateJsonMergePatchAddressAnyOfModel: all variants failed to decode',
      );
    }
    return $RawMeUpdateJsonMergePatchAddressAnyOfModel(
      profileAddress: _$decodedprofileAddress,
    );
  }

  final _i4.ProfileAddress? profileAddress;

  _i1.EncodingShape get currentEncodingShape {
    final _$shapes = <_i1.EncodingShape>{};
    if (this.profileAddress != null) {
      _$shapes.add(this.profileAddress!.currentEncodingShape);
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
    if (this.profileAddress != null) {
      final _i3.Object? _$profileAddressJson = this.profileAddress!.toJson();
      if (_$profileAddressJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$profileAddressJson);
      } else {
        _$values.add(_$profileAddressJson);
      }
    }
    if (_$values.isEmpty && _$mapValues.isEmpty) return null;
    if (_$values.isNotEmpty && _$mapValues.isNotEmpty) {
      throw _i1.EncodingException(
        r'Mixed encoding not supported for $RawMeUpdateJsonMergePatchAddressAnyOfModel: cannot encode both simple and complex values',
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
    if (this.profileAddress != null) {
      _$mapValues.add(
        this.profileAddress!.parameterProperties(allowEmpty: allowEmpty),
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
    if (this.profileAddress != null) {
      final _$profileAddressSimple = this.profileAddress!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$profileAddressSimple);
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
    if (this.profileAddress != null) {
      final _$profileAddressForm = this.profileAddress!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$profileAddressForm);
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
    if (this.profileAddress != null) {
      final _$profileAddressLabel = this.profileAddress!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$profileAddressLabel);
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
    if (this.profileAddress != null) {
      final _$profileAddressMatrix = this.profileAddress!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$profileAddressMatrix);
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
    if (this.profileAddress != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode $RawMeUpdateJsonMergePatchAddressAnyOfModel: contains complex type',
      );
    }
    throw _i1.EncodingException(
      r'Cannot uriEncode $RawMeUpdateJsonMergePatchAddressAnyOfModel: no value set',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawMeUpdateJsonMergePatchAddressAnyOfModel &&
        other.profileAddress == this.profileAddress;
  }

  @_i3.override
  _i3.int get hashCode => this.profileAddress.hashCode;

  $RawMeUpdateJsonMergePatchAddressAnyOfModel Function({
    _i4.ProfileAddress? profileAddress,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? profileAddress = _sentinel}) =>
        $RawMeUpdateJsonMergePatchAddressAnyOfModel(
          profileAddress: _i3.identical(profileAddress, _sentinel)
              ? this.profileAddress
              : (profileAddress as _i4.ProfileAddress?),
        );
  }
}

typedef MeUpdateJsonMergePatchAddressAnyOfModel =
    $RawMeUpdateJsonMergePatchAddressAnyOfModel?;
