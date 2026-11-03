// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/constraint_violation_violations_array_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Unprocessable entity
@_i2.immutable
class ConstraintViolation extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ConstraintViolation({
    required this.violations,
    this.status = statusDefault,
    this.detail,
    this.problemType,
    this.title,
    this.instance,
  });

  factory ConstraintViolation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ConstraintViolation: contains complex types',
    );
  }

  factory ConstraintViolation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ConstraintViolation');
    return ConstraintViolation(
      status: _$map.containsKey(r'status')
          ? _$map[r'status'].decodeJsonInt(
              context: r'ConstraintViolation.status',
            )
          : statusDefault,
      violations: _$map[r'violations']
          .decodeJsonList<_i3.Object?>(
            context: r'ConstraintViolation.violations',
          )
          .map(_i4.ConstraintViolationViolationsArrayModel.fromJson)
          .toList(),
      detail: _$map[r'detail'].decodeJsonString(
        context: r'ConstraintViolation.detail',
      ),
      problemType: _$map[r'type'].decodeJsonString(
        context: r'ConstraintViolation.type',
      ),
      title: _$map[r'title'].decodeJsonNullableString(
        context: r'ConstraintViolation.title',
      ),
      instance: _$map[r'instance'].decodeJsonNullableString(
        context: r'ConstraintViolation.instance',
      ),
    );
  }

  factory ConstraintViolation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ConstraintViolation: contains complex types',
    );
  }

  static const _i3.int statusDefault = 422;

  final _i3.int status;

  final _i3.List<_i4.ConstraintViolationViolationsArrayModel> violations;

  final _i3.String? detail;

  final _i3.String? problemType;

  final _i3.String? title;

  final _i3.String? instance;

  @_i3.override
  _i3.Object? toJson() => {
    r'status': this.status,
    r'violations': this.violations.map((e) => e.toJson()).toList(),
  };

  ConstraintViolation Function({
    _i3.int? status,
    _i3.List<_i4.ConstraintViolationViolationsArrayModel>? violations,
    _i3.String? detail,
    _i3.String? problemType,
    _i3.String? title,
    _i3.String? instance,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? status,
      _i3.List<_i4.ConstraintViolationViolationsArrayModel>? violations,
      _i3.Object? detail = _sentinel,
      _i3.Object? problemType = _sentinel,
      _i3.Object? title = _sentinel,
      _i3.Object? instance = _sentinel,
    }) => ConstraintViolation(
      status: status ?? this.status,
      violations: violations ?? this.violations,
      detail: _i3.identical(detail, _sentinel)
          ? this.detail
          : (detail as _i3.String?),
      problemType: _i3.identical(problemType, _sentinel)
          ? this.problemType
          : (problemType as _i3.String?),
      title: _i3.identical(title, _sentinel)
          ? this.title
          : (title as _i3.String?),
      instance: _i3.identical(instance, _sentinel)
          ? this.instance
          : (instance as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is ConstraintViolation &&
        other.status == this.status &&
        _$deepEquals.equals(other.violations, this.violations) &&
        other.detail == this.detail &&
        other.problemType == this.problemType &&
        other.title == this.title &&
        other.instance == this.instance;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.status,
      deepEquals.hash(this.violations),
      this.detail,
      this.problemType,
      this.title,
      this.instance,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for ConstraintViolation: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ConstraintViolation: complex types cannot be URI-encoded',
    );
  }
}
