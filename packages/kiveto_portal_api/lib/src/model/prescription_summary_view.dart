// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PrescriptionSummaryView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PrescriptionSummaryView({
    required this.id,
    required this.validUntil,
    required this.renewable,
    required this.renewalStatus,
  });

  factory PrescriptionSummaryView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PrescriptionSummaryView: contains complex types',
    );
  }

  factory PrescriptionSummaryView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PrescriptionSummaryView');
    return PrescriptionSummaryView(
      id: _$map[r'id'].decodeJsonString(context: r'PrescriptionSummaryView.id'),
      validUntil: _$map[r'validUntil'].decodeJsonNullableDate(
        context: r'PrescriptionSummaryView.validUntil',
      ),
      renewable: _$map[r'renewable'].decodeJsonBool(
        context: r'PrescriptionSummaryView.renewable',
      ),
      renewalStatus: _$map[r'renewalStatus'].decodeJsonNullableMap(
        (v) => v,
        context: r'PrescriptionSummaryView.renewalStatus',
      ),
    );
  }

  factory PrescriptionSummaryView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PrescriptionSummaryView: contains complex types',
    );
  }

  final _i3.String id;

  final _i1.Date? validUntil;

  final _i3.bool renewable;

  final _i3.Map<_i3.String, _i3.Object?>? renewalStatus;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'validUntil': this.validUntil?.toJson(),
    r'renewable': this.renewable,
    r'renewalStatus': this.renewalStatus?.map(
      (k, v) => _i3.MapEntry(
        k,
        _i1.encodeUnknownJson(
          v,
          context: r'PrescriptionSummaryView.renewalStatus',
        ),
      ),
    ),
  };

  PrescriptionSummaryView Function({
    _i3.String? id,
    _i1.Date? validUntil,
    _i3.bool? renewable,
    _i3.Map<_i3.String, _i3.Object?>? renewalStatus,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.Object? validUntil = _sentinel,
      _i3.bool? renewable,
      _i3.Object? renewalStatus = _sentinel,
    }) => PrescriptionSummaryView(
      id: id ?? this.id,
      validUntil: _i3.identical(validUntil, _sentinel)
          ? this.validUntil
          : (validUntil as _i1.Date?),
      renewable: renewable ?? this.renewable,
      renewalStatus: _i3.identical(renewalStatus, _sentinel)
          ? this.renewalStatus
          : (renewalStatus as _i3.Map<_i3.String, _i3.Object?>?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i4.DeepCollectionEquality();
    return other is PrescriptionSummaryView &&
        other.id == this.id &&
        other.validUntil == this.validUntil &&
        other.renewable == this.renewable &&
        _$deepEquals.equals(other.renewalStatus, this.renewalStatus);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i4.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.validUntil,
      this.renewable,
      deepEquals.hash(this.renewalStatus),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PrescriptionSummaryView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PrescriptionSummaryView: complex types cannot be URI-encoded',
    );
  }
}
