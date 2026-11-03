// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PetWeightView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PetWeightView({required this.weightGrams, required this.at});

  factory PetWeightView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'weightGrams', r'at'},
      listKeys: {},
      context: r'PetWeightView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PetWeightView(
      weightGrams: _$values[r'weightGrams'].decodeSimpleInt(
        context: r'PetWeightView.weightGrams',
      ),
      at: _$values[r'at'].decodeSimpleDate(context: r'PetWeightView.at'),
    );
  }

  factory PetWeightView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PetWeightView');
    return PetWeightView(
      weightGrams: _$map[r'weightGrams'].decodeJsonInt(
        context: r'PetWeightView.weightGrams',
      ),
      at: _$map[r'at'].decodeJsonDate(context: r'PetWeightView.at'),
    );
  }

  factory PetWeightView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'weightGrams', r'at'},
      listKeys: {},
      context: r'PetWeightView',
    );
    return PetWeightView(
      weightGrams: _$values[r'weightGrams'].decodeFormInt(
        context: r'PetWeightView.weightGrams',
      ),
      at: _$values[r'at'].decodeFormDate(context: r'PetWeightView.at'),
    );
  }

  final _i3.int weightGrams;

  final _i1.Date at;

  @_i3.override
  _i3.Object? toJson() => {
    r'weightGrams': this.weightGrams,
    r'at': this.at.toJson(),
  };

  PetWeightView Function({_i3.int? weightGrams, _i1.Date? at}) get copyWith {
    return ({_i3.int? weightGrams, _i1.Date? at}) => PetWeightView(
      weightGrams: weightGrams ?? this.weightGrams,
      at: at ?? this.at,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PetWeightView &&
        other.weightGrams == this.weightGrams &&
        other.at == this.at;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.weightGrams, this.at]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'weightGrams'] = _i1.PropertyValue.scalar(
      this.weightGrams.toString(),
    );
    _$result[r'at'] = _i1.PropertyValue.scalar(this.at.toString());
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
      r'Cannot uriEncode PetWeightView: complex types cannot be URI-encoded',
    );
  }
}
