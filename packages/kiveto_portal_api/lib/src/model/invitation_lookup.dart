// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationLookup extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvitationLookup({required this.token});

  factory InvitationLookup.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'token'},
      listKeys: {},
      context: r'InvitationLookup',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return InvitationLookup(
      token: _$values[r'token'].decodeSimpleString(
        context: r'InvitationLookup.token',
      ),
    );
  }

  factory InvitationLookup.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationLookup');
    return InvitationLookup(
      token: _$map[r'token'].decodeJsonString(
        context: r'InvitationLookup.token',
      ),
    );
  }

  factory InvitationLookup.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'token'},
      listKeys: {},
      context: r'InvitationLookup',
    );
    return InvitationLookup(
      token: _$values[r'token'].decodeFormString(
        context: r'InvitationLookup.token',
      ),
    );
  }

  final _i3.String token;

  @_i3.override
  _i3.Object? toJson() => {r'token': this.token};

  InvitationLookup Function({_i3.String? token}) get copyWith {
    return ({_i3.String? token}) =>
        InvitationLookup(token: token ?? this.token);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvitationLookup && other.token == this.token;
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
      r'Cannot uriEncode InvitationLookup: complex types cannot be URI-encoded',
    );
  }
}
