// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ConstraintViolationViolationsArrayModel
    extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ConstraintViolationViolationsArrayModel({
    required this.propertyPath,
    required this.message,
    this.code,
    this.hint,
    this.payload,
  });

  factory ConstraintViolationViolationsArrayModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ConstraintViolationViolationsArrayModel: contains complex types',
    );
  }

  factory ConstraintViolationViolationsArrayModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(
      context: r'ConstraintViolationViolationsArrayModel',
    );
    return ConstraintViolationViolationsArrayModel(
      propertyPath: _$map[r'propertyPath'].decodeJsonString(
        context: r'ConstraintViolationViolationsArrayModel.propertyPath',
      ),
      message: _$map[r'message'].decodeJsonString(
        context: r'ConstraintViolationViolationsArrayModel.message',
      ),
      code: _$map[r'code'].decodeJsonNullableString(
        context: r'ConstraintViolationViolationsArrayModel.code',
      ),
      hint: _$map[r'hint'].decodeJsonNullableString(
        context: r'ConstraintViolationViolationsArrayModel.hint',
      ),
      payload: _$map[r'payload'].decodeJsonNullableMap(
        (v) => v,
        context: r'ConstraintViolationViolationsArrayModel.payload',
      ),
    );
  }

  factory ConstraintViolationViolationsArrayModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ConstraintViolationViolationsArrayModel: contains complex types',
    );
  }

  /// The property path of the violation
  final _i3.String propertyPath;

  /// The message associated with the violation
  final _i3.String message;

  /// The code of the violation
  final _i3.String? code;

  /// An extra hint to understand the violation
  final _i3.String? hint;

  /// The serialized payload of the violation
  final _i3.Map<_i3.String, _i3.Object?>? payload;

  @_i3.override
  _i3.Object? toJson() => {
    r'propertyPath': this.propertyPath,
    r'message': this.message,
    if (this.code != null) r'code': this.code,
    if (this.hint != null) r'hint': this.hint,
    if (this.payload != null)
      r'payload': this.payload?.map(
        (k, v) => _i3.MapEntry(
          k,
          _i1.encodeUnknownJson(
            v,
            context: r'ConstraintViolationViolationsArrayModel.payload',
          ),
        ),
      ),
  };

  ConstraintViolationViolationsArrayModel Function({
    _i3.String? propertyPath,
    _i3.String? message,
    _i3.String? code,
    _i3.String? hint,
    _i3.Map<_i3.String, _i3.Object?>? payload,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? propertyPath,
      _i3.String? message,
      _i3.Object? code = _sentinel,
      _i3.Object? hint = _sentinel,
      _i3.Object? payload = _sentinel,
    }) => ConstraintViolationViolationsArrayModel(
      propertyPath: propertyPath ?? this.propertyPath,
      message: message ?? this.message,
      code: _i3.identical(code, _sentinel) ? this.code : (code as _i3.String?),
      hint: _i3.identical(hint, _sentinel) ? this.hint : (hint as _i3.String?),
      payload: _i3.identical(payload, _sentinel)
          ? this.payload
          : (payload as _i3.Map<_i3.String, _i3.Object?>?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i4.DeepCollectionEquality();
    return other is ConstraintViolationViolationsArrayModel &&
        other.propertyPath == this.propertyPath &&
        other.message == this.message &&
        other.code == this.code &&
        other.hint == this.hint &&
        _$deepEquals.equals(other.payload, this.payload);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i4.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.propertyPath,
      this.message,
      this.code,
      this.hint,
      deepEquals.hash(this.payload),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for ConstraintViolationViolationsArrayModel: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ConstraintViolationViolationsArrayModel: complex types cannot be URI-encoded',
    );
  }
}
