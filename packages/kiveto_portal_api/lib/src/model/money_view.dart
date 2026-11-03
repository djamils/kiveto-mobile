// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class MoneyView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const MoneyView({required this.amount, required this.currency});

  factory MoneyView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'amount', r'currency'},
      listKeys: {},
      context: r'MoneyView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return MoneyView(
      amount: _$values[r'amount'].decodeSimpleInt(context: r'MoneyView.amount'),
      currency: _$values[r'currency'].decodeSimpleString(
        context: r'MoneyView.currency',
      ),
    );
  }

  factory MoneyView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'MoneyView');
    return MoneyView(
      amount: _$map[r'amount'].decodeJsonInt(context: r'MoneyView.amount'),
      currency: _$map[r'currency'].decodeJsonString(
        context: r'MoneyView.currency',
      ),
    );
  }

  factory MoneyView.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'amount', r'currency'},
      listKeys: {},
      context: r'MoneyView',
    );
    return MoneyView(
      amount: _$values[r'amount'].decodeFormInt(context: r'MoneyView.amount'),
      currency: _$values[r'currency'].decodeFormString(
        context: r'MoneyView.currency',
      ),
    );
  }

  final _i3.int amount;

  final _i3.String currency;

  @_i3.override
  _i3.Object? toJson() => {r'amount': this.amount, r'currency': this.currency};

  MoneyView Function({_i3.int? amount, _i3.String? currency}) get copyWith {
    return ({_i3.int? amount, _i3.String? currency}) => MoneyView(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MoneyView &&
        other.amount == this.amount &&
        other.currency == this.currency;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.amount, this.currency]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'amount'] = _i1.PropertyValue.scalar(this.amount.toString());
    _$result[r'currency'] = _i1.PropertyValue.scalar(this.currency);
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
      r'Cannot uriEncode MoneyView: complex types cannot be URI-encoded',
    );
  }
}
