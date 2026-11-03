// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class OtpRequest extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const OtpRequest({required this.phone});

  factory OtpRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'phone'},
      listKeys: {},
      context: r'OtpRequest',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return OtpRequest(
      phone: _$values[r'phone'].decodeSimpleString(
        context: r'OtpRequest.phone',
      ),
    );
  }

  factory OtpRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'OtpRequest');
    return OtpRequest(
      phone: _$map[r'phone'].decodeJsonString(context: r'OtpRequest.phone'),
    );
  }

  factory OtpRequest.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'phone'},
      listKeys: {},
      context: r'OtpRequest',
    );
    return OtpRequest(
      phone: _$values[r'phone'].decodeFormString(context: r'OtpRequest.phone'),
    );
  }

  /// E.164, e.g. `+33612345678`.
  final _i3.String phone;

  @_i3.override
  _i3.Object? toJson() => {r'phone': this.phone};

  OtpRequest Function({_i3.String? phone}) get copyWith {
    return ({_i3.String? phone}) => OtpRequest(phone: phone ?? this.phone);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is OtpRequest && other.phone == this.phone;
  }

  @_i3.override
  _i3.int get hashCode => this.phone.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'phone'] = _i1.PropertyValue.scalar(this.phone);
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
      r'Cannot uriEncode OtpRequest: complex types cannot be URI-encoded',
    );
  }
}
