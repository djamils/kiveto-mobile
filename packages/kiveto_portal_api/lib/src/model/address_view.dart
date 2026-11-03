// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AddressView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AddressView({
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.city,
    required this.country,
  });

  factory AddressView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'line1', r'line2', r'postalCode', r'city', r'country'},
      listKeys: {},
      context: r'AddressView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return AddressView(
      line1: _$values[r'line1'].decodeSimpleString(
        context: r'AddressView.line1',
      ),
      line2: _$values[r'line2'].decodeSimpleNullableString(
        context: r'AddressView.line2',
      ),
      postalCode: _$values[r'postalCode'].decodeSimpleNullableString(
        context: r'AddressView.postalCode',
      ),
      city: _$values[r'city'].decodeSimpleString(context: r'AddressView.city'),
      country: _$values[r'country'].decodeSimpleString(
        context: r'AddressView.country',
      ),
    );
  }

  factory AddressView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AddressView');
    return AddressView(
      line1: _$map[r'line1'].decodeJsonString(context: r'AddressView.line1'),
      line2: _$map[r'line2'].decodeJsonNullableString(
        context: r'AddressView.line2',
      ),
      postalCode: _$map[r'postalCode'].decodeJsonNullableString(
        context: r'AddressView.postalCode',
      ),
      city: _$map[r'city'].decodeJsonString(context: r'AddressView.city'),
      country: _$map[r'country'].decodeJsonString(
        context: r'AddressView.country',
      ),
    );
  }

  factory AddressView.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'line1', r'line2', r'postalCode', r'city', r'country'},
      listKeys: {},
      context: r'AddressView',
    );
    return AddressView(
      line1: _$values[r'line1'].decodeFormString(context: r'AddressView.line1'),
      line2: _$values[r'line2'].decodeFormNullableString(
        context: r'AddressView.line2',
      ),
      postalCode: _$values[r'postalCode'].decodeFormNullableString(
        context: r'AddressView.postalCode',
      ),
      city: _$values[r'city'].decodeFormString(context: r'AddressView.city'),
      country: _$values[r'country'].decodeFormString(
        context: r'AddressView.country',
      ),
    );
  }

  final _i3.String line1;

  final _i3.String? line2;

  final _i3.String? postalCode;

  final _i3.String city;

  final _i3.String country;

  @_i3.override
  _i3.Object? toJson() => {
    r'line1': this.line1,
    r'line2': this.line2,
    r'postalCode': this.postalCode,
    r'city': this.city,
    r'country': this.country,
  };

  AddressView Function({
    _i3.String? line1,
    _i3.String? line2,
    _i3.String? postalCode,
    _i3.String? city,
    _i3.String? country,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? line1,
      _i3.Object? line2 = _sentinel,
      _i3.Object? postalCode = _sentinel,
      _i3.String? city,
      _i3.String? country,
    }) => AddressView(
      line1: line1 ?? this.line1,
      line2: _i3.identical(line2, _sentinel)
          ? this.line2
          : (line2 as _i3.String?),
      postalCode: _i3.identical(postalCode, _sentinel)
          ? this.postalCode
          : (postalCode as _i3.String?),
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AddressView &&
        other.line1 == this.line1 &&
        other.line2 == this.line2 &&
        other.postalCode == this.postalCode &&
        other.city == this.city &&
        other.country == this.country;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.line1,
      this.line2,
      this.postalCode,
      this.city,
      this.country,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'line1'] = _i1.PropertyValue.scalar(this.line1);
    if (this.line2 != null) {
      _$result[r'line2'] = _i1.PropertyValue.scalar(this.line2!);
    }
    if (this.postalCode != null) {
      _$result[r'postalCode'] = _i1.PropertyValue.scalar(this.postalCode!);
    }
    _$result[r'city'] = _i1.PropertyValue.scalar(this.city);
    _$result[r'country'] = _i1.PropertyValue.scalar(this.country);
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
      r'Cannot uriEncode AddressView: complex types cannot be URI-encoded',
    );
  }
}
