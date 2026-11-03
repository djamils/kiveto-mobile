// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationAcceptance extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvitationAcceptance({
    required this.token,
    required this.challengeId,
    required this.code,
    required this.termsVersion,
  });

  factory InvitationAcceptance.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'token', r'challengeId', r'code', r'termsVersion'},
      listKeys: {},
      context: r'InvitationAcceptance',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return InvitationAcceptance(
      token: _$values[r'token'].decodeSimpleString(
        context: r'InvitationAcceptance.token',
      ),
      challengeId: _$values[r'challengeId'].decodeSimpleString(
        context: r'InvitationAcceptance.challengeId',
      ),
      code: _$values[r'code'].decodeSimpleString(
        context: r'InvitationAcceptance.code',
      ),
      termsVersion: _$values[r'termsVersion'].decodeSimpleString(
        context: r'InvitationAcceptance.termsVersion',
      ),
    );
  }

  factory InvitationAcceptance.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationAcceptance');
    return InvitationAcceptance(
      token: _$map[r'token'].decodeJsonString(
        context: r'InvitationAcceptance.token',
      ),
      challengeId: _$map[r'challengeId'].decodeJsonString(
        context: r'InvitationAcceptance.challengeId',
      ),
      code: _$map[r'code'].decodeJsonString(
        context: r'InvitationAcceptance.code',
      ),
      termsVersion: _$map[r'termsVersion'].decodeJsonString(
        context: r'InvitationAcceptance.termsVersion',
      ),
    );
  }

  factory InvitationAcceptance.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'token', r'challengeId', r'code', r'termsVersion'},
      listKeys: {},
      context: r'InvitationAcceptance',
    );
    return InvitationAcceptance(
      token: _$values[r'token'].decodeFormString(
        context: r'InvitationAcceptance.token',
      ),
      challengeId: _$values[r'challengeId'].decodeFormString(
        context: r'InvitationAcceptance.challengeId',
      ),
      code: _$values[r'code'].decodeFormString(
        context: r'InvitationAcceptance.code',
      ),
      termsVersion: _$values[r'termsVersion'].decodeFormString(
        context: r'InvitationAcceptance.termsVersion',
      ),
    );
  }

  final _i3.String token;

  final _i3.String challengeId;

  final _i3.String code;

  /// The `version` of /legal/terms/current.
  final _i3.String termsVersion;

  @_i3.override
  _i3.Object? toJson() => {
    r'token': this.token,
    r'challengeId': this.challengeId,
    r'code': this.code,
    r'termsVersion': this.termsVersion,
  };

  InvitationAcceptance Function({
    _i3.String? token,
    _i3.String? challengeId,
    _i3.String? code,
    _i3.String? termsVersion,
  })
  get copyWith {
    return ({
      _i3.String? token,
      _i3.String? challengeId,
      _i3.String? code,
      _i3.String? termsVersion,
    }) => InvitationAcceptance(
      token: token ?? this.token,
      challengeId: challengeId ?? this.challengeId,
      code: code ?? this.code,
      termsVersion: termsVersion ?? this.termsVersion,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvitationAcceptance &&
        other.token == this.token &&
        other.challengeId == this.challengeId &&
        other.code == this.code &&
        other.termsVersion == this.termsVersion;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.token,
      this.challengeId,
      this.code,
      this.termsVersion,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'token'] = _i1.PropertyValue.scalar(this.token);
    _$result[r'challengeId'] = _i1.PropertyValue.scalar(this.challengeId);
    _$result[r'code'] = _i1.PropertyValue.scalar(this.code);
    _$result[r'termsVersion'] = _i1.PropertyValue.scalar(this.termsVersion);
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
      r'Cannot uriEncode InvitationAcceptance: complex types cannot be URI-encoded',
    );
  }
}
