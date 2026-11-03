// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ClinicAddressView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ClinicAddressView({
    required this.line,
    required this.postalCode,
    required this.city,
  });

  factory ClinicAddressView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'line', r'postalCode', r'city'},
      listKeys: {},
      context: r'ClinicAddressView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ClinicAddressView(
      line: _$values[r'line'].decodeSimpleString(
        context: r'ClinicAddressView.line',
      ),
      postalCode: _$values[r'postalCode'].decodeSimpleNullableString(
        context: r'ClinicAddressView.postalCode',
      ),
      city: _$values[r'city'].decodeSimpleString(
        context: r'ClinicAddressView.city',
      ),
    );
  }

  factory ClinicAddressView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ClinicAddressView');
    return ClinicAddressView(
      line: _$map[r'line'].decodeJsonString(context: r'ClinicAddressView.line'),
      postalCode: _$map[r'postalCode'].decodeJsonNullableString(
        context: r'ClinicAddressView.postalCode',
      ),
      city: _$map[r'city'].decodeJsonString(context: r'ClinicAddressView.city'),
    );
  }

  factory ClinicAddressView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'line', r'postalCode', r'city'},
      listKeys: {},
      context: r'ClinicAddressView',
    );
    return ClinicAddressView(
      line: _$values[r'line'].decodeFormString(
        context: r'ClinicAddressView.line',
      ),
      postalCode: _$values[r'postalCode'].decodeFormNullableString(
        context: r'ClinicAddressView.postalCode',
      ),
      city: _$values[r'city'].decodeFormString(
        context: r'ClinicAddressView.city',
      ),
    );
  }

  /// Street lines 1 and 2 of the letterhead, joined by a comma.
  final _i3.String line;

  final _i3.String? postalCode;

  final _i3.String city;

  @_i3.override
  _i3.Object? toJson() => {
    r'line': this.line,
    r'postalCode': this.postalCode,
    r'city': this.city,
  };

  ClinicAddressView Function({
    _i3.String? line,
    _i3.String? postalCode,
    _i3.String? city,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? line,
      _i3.Object? postalCode = _sentinel,
      _i3.String? city,
    }) => ClinicAddressView(
      line: line ?? this.line,
      postalCode: _i3.identical(postalCode, _sentinel)
          ? this.postalCode
          : (postalCode as _i3.String?),
      city: city ?? this.city,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ClinicAddressView &&
        other.line == this.line &&
        other.postalCode == this.postalCode &&
        other.city == this.city;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.line, this.postalCode, this.city]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'line'] = _i1.PropertyValue.scalar(this.line);
    if (this.postalCode != null) {
      _$result[r'postalCode'] = _i1.PropertyValue.scalar(this.postalCode!);
    }
    _$result[r'city'] = _i1.PropertyValue.scalar(this.city);
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
      r'Cannot uriEncode ClinicAddressView: complex types cannot be URI-encoded',
    );
  }
}
