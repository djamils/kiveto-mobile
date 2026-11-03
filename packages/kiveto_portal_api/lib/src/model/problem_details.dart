// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A representation of common errors.
@_i2.immutable
class ProblemDetails extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ProblemDetails({
    this.title,
    this.detail,
    this.status = statusDefault,
    this.instance,
    this.problemType,
  });

  factory ProblemDetails.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'title', r'detail', r'status', r'instance', r'type'},
      listKeys: {},
      context: r'ProblemDetails',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ProblemDetails(
      title: _$values[r'title'].decodeSimpleNullableString(
        context: r'ProblemDetails.title',
      ),
      detail: _$values[r'detail'].decodeSimpleNullableString(
        context: r'ProblemDetails.detail',
      ),
      status: _$values.containsKey(r'status')
          ? _$values[r'status'].decodeSimpleNullableInt(
              context: r'ProblemDetails.status',
            )
          : statusDefault,
      instance: _$values[r'instance'].decodeSimpleNullableString(
        context: r'ProblemDetails.instance',
      ),
      problemType: _$values[r'type'].decodeSimpleString(
        context: r'ProblemDetails.type',
      ),
    );
  }

  factory ProblemDetails.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ProblemDetails');
    return ProblemDetails(
      title: _$map[r'title'].decodeJsonNullableString(
        context: r'ProblemDetails.title',
      ),
      detail: _$map[r'detail'].decodeJsonNullableString(
        context: r'ProblemDetails.detail',
      ),
      status: _$map.containsKey(r'status')
          ? _$map[r'status'].decodeJsonNullableInt(
              context: r'ProblemDetails.status',
            )
          : statusDefault,
      instance: _$map[r'instance'].decodeJsonNullableString(
        context: r'ProblemDetails.instance',
      ),
      problemType: _$map[r'type'].decodeJsonString(
        context: r'ProblemDetails.type',
      ),
    );
  }

  factory ProblemDetails.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'title', r'detail', r'status', r'instance', r'type'},
      listKeys: {},
      context: r'ProblemDetails',
    );
    return ProblemDetails(
      title: _$values[r'title'].decodeFormNullableString(
        context: r'ProblemDetails.title',
      ),
      detail: _$values[r'detail'].decodeFormNullableString(
        context: r'ProblemDetails.detail',
      ),
      status: _$values.containsKey(r'status')
          ? _$values[r'status'].decodeFormNullableInt(
              context: r'ProblemDetails.status',
            )
          : statusDefault,
      instance: _$values[r'instance'].decodeFormNullableString(
        context: r'ProblemDetails.instance',
      ),
      problemType: _$values[r'type'].decodeFormString(
        context: r'ProblemDetails.type',
      ),
    );
  }

  static const _i3.int? statusDefault = 400;

  /// A short, human-readable summary of the problem.
  final _i3.String? title;

  /// A human-readable explanation specific to this occurrence of the problem.
  final _i3.String? detail;

  /// **Example**:
  /// ```json
  /// 404
  /// ```
  final _i3.int? status;

  /// A URI reference that identifies the specific occurrence of the problem. It may or may not yield further information if dereferenced.
  final _i3.String? instance;

  /// A URI reference that identifies the problem type
  final _i3.String? problemType;

  @_i3.override
  _i3.Object? toJson() => {r'status': this.status};

  ProblemDetails Function({
    _i3.String? title,
    _i3.String? detail,
    _i3.int? status,
    _i3.String? instance,
    _i3.String? problemType,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? title = _sentinel,
      _i3.Object? detail = _sentinel,
      _i3.Object? status = _sentinel,
      _i3.Object? instance = _sentinel,
      _i3.Object? problemType = _sentinel,
    }) => ProblemDetails(
      title: _i3.identical(title, _sentinel)
          ? this.title
          : (title as _i3.String?),
      detail: _i3.identical(detail, _sentinel)
          ? this.detail
          : (detail as _i3.String?),
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i3.int?),
      instance: _i3.identical(instance, _sentinel)
          ? this.instance
          : (instance as _i3.String?),
      problemType: _i3.identical(problemType, _sentinel)
          ? this.problemType
          : (problemType as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ProblemDetails &&
        other.title == this.title &&
        other.detail == this.detail &&
        other.status == this.status &&
        other.instance == this.instance &&
        other.problemType == this.problemType;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.title,
      this.detail,
      this.status,
      this.instance,
      this.problemType,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.status != null) {
      _$result[r'status'] = _i1.PropertyValue.scalar(this.status!.toString());
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ProblemDetails: complex types cannot be URI-encoded',
    );
  }
}
