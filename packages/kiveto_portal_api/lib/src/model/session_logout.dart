// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class SessionLogout extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const SessionLogout({required this.refreshToken});

  factory SessionLogout.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'refreshToken'},
      listKeys: {},
      context: r'SessionLogout',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return SessionLogout(
      refreshToken: _$values[r'refreshToken'].decodeSimpleString(
        context: r'SessionLogout.refreshToken',
      ),
    );
  }

  factory SessionLogout.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'SessionLogout');
    return SessionLogout(
      refreshToken: _$map[r'refreshToken'].decodeJsonString(
        context: r'SessionLogout.refreshToken',
      ),
    );
  }

  factory SessionLogout.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'refreshToken'},
      listKeys: {},
      context: r'SessionLogout',
    );
    return SessionLogout(
      refreshToken: _$values[r'refreshToken'].decodeFormString(
        context: r'SessionLogout.refreshToken',
      ),
    );
  }

  final _i3.String refreshToken;

  @_i3.override
  _i3.Object? toJson() => {r'refreshToken': this.refreshToken};

  SessionLogout Function({_i3.String? refreshToken}) get copyWith {
    return ({_i3.String? refreshToken}) =>
        SessionLogout(refreshToken: refreshToken ?? this.refreshToken);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SessionLogout && other.refreshToken == this.refreshToken;
  }

  @_i3.override
  _i3.int get hashCode => this.refreshToken.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'refreshToken'] = _i1.PropertyValue.scalar(this.refreshToken);
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
      r'Cannot uriEncode SessionLogout: complex types cannot be URI-encoded',
    );
  }
}
