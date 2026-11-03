// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PrescriptionLineView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PrescriptionLineView({
    required this.label,
    required this.quantity,
    required this.posologySummary,
  });

  factory PrescriptionLineView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'label', r'quantity', r'posologySummary'},
      listKeys: {},
      context: r'PrescriptionLineView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PrescriptionLineView(
      label: _$values[r'label'].decodeSimpleString(
        context: r'PrescriptionLineView.label',
      ),
      quantity: _$values[r'quantity'].decodeSimpleString(
        context: r'PrescriptionLineView.quantity',
      ),
      posologySummary: _$values[r'posologySummary'].decodeSimpleString(
        context: r'PrescriptionLineView.posologySummary',
      ),
    );
  }

  factory PrescriptionLineView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PrescriptionLineView');
    return PrescriptionLineView(
      label: _$map[r'label'].decodeJsonString(
        context: r'PrescriptionLineView.label',
      ),
      quantity: _$map[r'quantity'].decodeJsonString(
        context: r'PrescriptionLineView.quantity',
      ),
      posologySummary: _$map[r'posologySummary'].decodeJsonString(
        context: r'PrescriptionLineView.posologySummary',
      ),
    );
  }

  factory PrescriptionLineView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'label', r'quantity', r'posologySummary'},
      listKeys: {},
      context: r'PrescriptionLineView',
    );
    return PrescriptionLineView(
      label: _$values[r'label'].decodeFormString(
        context: r'PrescriptionLineView.label',
      ),
      quantity: _$values[r'quantity'].decodeFormString(
        context: r'PrescriptionLineView.quantity',
      ),
      posologySummary: _$values[r'posologySummary'].decodeFormString(
        context: r'PrescriptionLineView.posologySummary',
      ),
    );
  }

  final _i3.String label;

  final _i3.String quantity;

  final _i3.String posologySummary;

  @_i3.override
  _i3.Object? toJson() => {
    r'label': this.label,
    r'quantity': this.quantity,
    r'posologySummary': this.posologySummary,
  };

  PrescriptionLineView Function({
    _i3.String? label,
    _i3.String? quantity,
    _i3.String? posologySummary,
  })
  get copyWith {
    return ({
      _i3.String? label,
      _i3.String? quantity,
      _i3.String? posologySummary,
    }) => PrescriptionLineView(
      label: label ?? this.label,
      quantity: quantity ?? this.quantity,
      posologySummary: posologySummary ?? this.posologySummary,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PrescriptionLineView &&
        other.label == this.label &&
        other.quantity == this.quantity &&
        other.posologySummary == this.posologySummary;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.label,
      this.quantity,
      this.posologySummary,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'label'] = _i1.PropertyValue.scalar(this.label);
    _$result[r'quantity'] = _i1.PropertyValue.scalar(this.quantity);
    _$result[r'posologySummary'] = _i1.PropertyValue.scalar(
      this.posologySummary,
    );
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
      r'Cannot uriEncode PrescriptionLineView: complex types cannot be URI-encoded',
    );
  }
}
