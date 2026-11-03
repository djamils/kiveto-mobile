// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class SessionTokens extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const SessionTokens({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory SessionTokens.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'accessToken',
        r'accessTokenExpiresAt',
        r'refreshToken',
        r'refreshTokenExpiresAt',
      },
      listKeys: {},
      context: r'SessionTokens',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return SessionTokens(
      accessToken: _$values[r'accessToken'].decodeSimpleString(
        context: r'SessionTokens.accessToken',
      ),
      accessTokenExpiresAt: _$values[r'accessTokenExpiresAt']
          .decodeSimpleDateTime(context: r'SessionTokens.accessTokenExpiresAt'),
      refreshToken: _$values[r'refreshToken'].decodeSimpleString(
        context: r'SessionTokens.refreshToken',
      ),
      refreshTokenExpiresAt: _$values[r'refreshTokenExpiresAt']
          .decodeSimpleDateTime(
            context: r'SessionTokens.refreshTokenExpiresAt',
          ),
    );
  }

  factory SessionTokens.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'SessionTokens');
    return SessionTokens(
      accessToken: _$map[r'accessToken'].decodeJsonString(
        context: r'SessionTokens.accessToken',
      ),
      accessTokenExpiresAt: _$map[r'accessTokenExpiresAt'].decodeJsonDateTime(
        context: r'SessionTokens.accessTokenExpiresAt',
      ),
      refreshToken: _$map[r'refreshToken'].decodeJsonString(
        context: r'SessionTokens.refreshToken',
      ),
      refreshTokenExpiresAt: _$map[r'refreshTokenExpiresAt'].decodeJsonDateTime(
        context: r'SessionTokens.refreshTokenExpiresAt',
      ),
    );
  }

  factory SessionTokens.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'accessToken',
        r'accessTokenExpiresAt',
        r'refreshToken',
        r'refreshTokenExpiresAt',
      },
      listKeys: {},
      context: r'SessionTokens',
    );
    return SessionTokens(
      accessToken: _$values[r'accessToken'].decodeFormString(
        context: r'SessionTokens.accessToken',
      ),
      accessTokenExpiresAt: _$values[r'accessTokenExpiresAt']
          .decodeFormDateTime(context: r'SessionTokens.accessTokenExpiresAt'),
      refreshToken: _$values[r'refreshToken'].decodeFormString(
        context: r'SessionTokens.refreshToken',
      ),
      refreshTokenExpiresAt: _$values[r'refreshTokenExpiresAt']
          .decodeFormDateTime(context: r'SessionTokens.refreshTokenExpiresAt'),
    );
  }

  final _i3.String accessToken;

  final _i3.DateTime accessTokenExpiresAt;

  final _i3.String refreshToken;

  final _i3.DateTime refreshTokenExpiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'accessToken': this.accessToken,
    r'accessTokenExpiresAt': this.accessTokenExpiresAt
        .toTimeZonedIso8601String(),
    r'refreshToken': this.refreshToken,
    r'refreshTokenExpiresAt': this.refreshTokenExpiresAt
        .toTimeZonedIso8601String(),
  };

  SessionTokens Function({
    _i3.String? accessToken,
    _i3.DateTime? accessTokenExpiresAt,
    _i3.String? refreshToken,
    _i3.DateTime? refreshTokenExpiresAt,
  })
  get copyWith {
    return ({
      _i3.String? accessToken,
      _i3.DateTime? accessTokenExpiresAt,
      _i3.String? refreshToken,
      _i3.DateTime? refreshTokenExpiresAt,
    }) => SessionTokens(
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiresAt:
          refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SessionTokens &&
        other.accessToken == this.accessToken &&
        other.accessTokenExpiresAt == this.accessTokenExpiresAt &&
        other.refreshToken == this.refreshToken &&
        other.refreshTokenExpiresAt == this.refreshTokenExpiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.accessToken,
      this.accessTokenExpiresAt,
      this.refreshToken,
      this.refreshTokenExpiresAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'accessToken'] = _i1.PropertyValue.scalar(this.accessToken);
    _$result[r'accessTokenExpiresAt'] = _i1.PropertyValue.scalar(
      this.accessTokenExpiresAt.toTimeZonedIso8601String(),
    );
    _$result[r'refreshToken'] = _i1.PropertyValue.scalar(this.refreshToken);
    _$result[r'refreshTokenExpiresAt'] = _i1.PropertyValue.scalar(
      this.refreshTokenExpiresAt.toTimeZonedIso8601String(),
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
      r'Cannot uriEncode SessionTokens: complex types cannot be URI-encoded',
    );
  }
}
