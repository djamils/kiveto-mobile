// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationOtpRequest extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvitationOtpRequest({required this.token});

  factory InvitationOtpRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'token'},
      listKeys: {},
      context: r'InvitationOtpRequest',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return InvitationOtpRequest(
      token: _$values[r'token'].decodeSimpleString(
        context: r'InvitationOtpRequest.token',
      ),
    );
  }

  factory InvitationOtpRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationOtpRequest');
    return InvitationOtpRequest(
      token: _$map[r'token'].decodeJsonString(
        context: r'InvitationOtpRequest.token',
      ),
    );
  }

  factory InvitationOtpRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'token'},
      listKeys: {},
      context: r'InvitationOtpRequest',
    );
    return InvitationOtpRequest(
      token: _$values[r'token'].decodeFormString(
        context: r'InvitationOtpRequest.token',
      ),
    );
  }

  final _i3.String token;

  @_i3.override
  _i3.Object? toJson() => {r'token': this.token};

  InvitationOtpRequest Function({_i3.String? token}) get copyWith {
    return ({_i3.String? token}) =>
        InvitationOtpRequest(token: token ?? this.token);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvitationOtpRequest && other.token == this.token;
  }

  @_i3.override
  _i3.int get hashCode => this.token.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'token'] = _i1.PropertyValue.scalar(this.token);
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
      r'Cannot uriEncode InvitationOtpRequest: complex types cannot be URI-encoded',
    );
  }
}
