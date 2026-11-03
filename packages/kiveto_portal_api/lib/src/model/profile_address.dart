// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ProfileAddress extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ProfileAddress({
    required this.streetLine1,
    required this.city,
    this.postalCode,
    this.countryCode,
  });

  factory ProfileAddress.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'streetLine1', r'postalCode', r'city', r'countryCode'},
      listKeys: {},
      context: r'ProfileAddress',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ProfileAddress(
      streetLine1: _$values[r'streetLine1'].decodeSimpleString(
        context: r'ProfileAddress.streetLine1',
      ),
      postalCode: _$values[r'postalCode'].decodeSimpleNullableString(
        context: r'ProfileAddress.postalCode',
      ),
      city: _$values[r'city'].decodeSimpleString(
        context: r'ProfileAddress.city',
      ),
      countryCode: _$values[r'countryCode'].decodeSimpleNullableString(
        context: r'ProfileAddress.countryCode',
      ),
    );
  }

  factory ProfileAddress.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ProfileAddress');
    return ProfileAddress(
      streetLine1: _$map[r'streetLine1'].decodeJsonString(
        context: r'ProfileAddress.streetLine1',
      ),
      postalCode: _$map[r'postalCode'].decodeJsonNullableString(
        context: r'ProfileAddress.postalCode',
      ),
      city: _$map[r'city'].decodeJsonString(context: r'ProfileAddress.city'),
      countryCode: _$map[r'countryCode'].decodeJsonNullableString(
        context: r'ProfileAddress.countryCode',
      ),
    );
  }

  factory ProfileAddress.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'streetLine1', r'postalCode', r'city', r'countryCode'},
      listKeys: {},
      context: r'ProfileAddress',
    );
    return ProfileAddress(
      streetLine1: _$values[r'streetLine1'].decodeFormString(
        context: r'ProfileAddress.streetLine1',
      ),
      postalCode: _$values[r'postalCode'].decodeFormNullableString(
        context: r'ProfileAddress.postalCode',
      ),
      city: _$values[r'city'].decodeFormString(context: r'ProfileAddress.city'),
      countryCode: _$values[r'countryCode'].decodeFormNullableString(
        context: r'ProfileAddress.countryCode',
      ),
    );
  }

  final _i3.String streetLine1;

  final _i3.String? postalCode;

  final _i3.String city;

  /// **Example**:
  /// ```
  /// FR
  /// ```
  final _i3.String? countryCode;

  @_i3.override
  _i3.Object? toJson() => {
    r'streetLine1': this.streetLine1,
    r'postalCode': this.postalCode,
    r'city': this.city,
    if (this.countryCode != null) r'countryCode': this.countryCode,
  };

  ProfileAddress Function({
    _i3.String? streetLine1,
    _i3.String? postalCode,
    _i3.String? city,
    _i3.String? countryCode,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? streetLine1,
      _i3.Object? postalCode = _sentinel,
      _i3.String? city,
      _i3.Object? countryCode = _sentinel,
    }) => ProfileAddress(
      streetLine1: streetLine1 ?? this.streetLine1,
      postalCode: _i3.identical(postalCode, _sentinel)
          ? this.postalCode
          : (postalCode as _i3.String?),
      city: city ?? this.city,
      countryCode: _i3.identical(countryCode, _sentinel)
          ? this.countryCode
          : (countryCode as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ProfileAddress &&
        other.streetLine1 == this.streetLine1 &&
        other.postalCode == this.postalCode &&
        other.city == this.city &&
        other.countryCode == this.countryCode;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.streetLine1,
      this.postalCode,
      this.city,
      this.countryCode,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'streetLine1'] = _i1.PropertyValue.scalar(this.streetLine1);
    if (this.postalCode != null) {
      _$result[r'postalCode'] = _i1.PropertyValue.scalar(this.postalCode!);
    }
    _$result[r'city'] = _i1.PropertyValue.scalar(this.city);
    if (this.countryCode != null) {
      _$result[r'countryCode'] = _i1.PropertyValue.scalar(this.countryCode!);
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
      r'Cannot uriEncode ProfileAddress: complex types cannot be URI-encoded',
    );
  }
}
