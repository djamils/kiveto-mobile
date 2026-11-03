// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ResentOtpChallengeView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ResentOtpChallengeView({
    required this.challengeId,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  factory ResentOtpChallengeView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'challengeId', r'expiresAt', r'resendAvailableAt'},
      listKeys: {},
      context: r'ResentOtpChallengeView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ResentOtpChallengeView(
      challengeId: _$values[r'challengeId'].decodeSimpleString(
        context: r'ResentOtpChallengeView.challengeId',
      ),
      expiresAt: _$values[r'expiresAt'].decodeSimpleDateTime(
        context: r'ResentOtpChallengeView.expiresAt',
      ),
      resendAvailableAt: _$values[r'resendAvailableAt'].decodeSimpleDateTime(
        context: r'ResentOtpChallengeView.resendAvailableAt',
      ),
    );
  }

  factory ResentOtpChallengeView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ResentOtpChallengeView');
    return ResentOtpChallengeView(
      challengeId: _$map[r'challengeId'].decodeJsonString(
        context: r'ResentOtpChallengeView.challengeId',
      ),
      expiresAt: _$map[r'expiresAt'].decodeJsonDateTime(
        context: r'ResentOtpChallengeView.expiresAt',
      ),
      resendAvailableAt: _$map[r'resendAvailableAt'].decodeJsonDateTime(
        context: r'ResentOtpChallengeView.resendAvailableAt',
      ),
    );
  }

  factory ResentOtpChallengeView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'challengeId', r'expiresAt', r'resendAvailableAt'},
      listKeys: {},
      context: r'ResentOtpChallengeView',
    );
    return ResentOtpChallengeView(
      challengeId: _$values[r'challengeId'].decodeFormString(
        context: r'ResentOtpChallengeView.challengeId',
      ),
      expiresAt: _$values[r'expiresAt'].decodeFormDateTime(
        context: r'ResentOtpChallengeView.expiresAt',
      ),
      resendAvailableAt: _$values[r'resendAvailableAt'].decodeFormDateTime(
        context: r'ResentOtpChallengeView.resendAvailableAt',
      ),
    );
  }

  final _i3.String challengeId;

  final _i3.DateTime expiresAt;

  final _i3.DateTime resendAvailableAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'challengeId': this.challengeId,
    r'expiresAt': this.expiresAt.toTimeZonedIso8601String(),
    r'resendAvailableAt': this.resendAvailableAt.toTimeZonedIso8601String(),
  };

  ResentOtpChallengeView Function({
    _i3.String? challengeId,
    _i3.DateTime? expiresAt,
    _i3.DateTime? resendAvailableAt,
  })
  get copyWith {
    return ({
      _i3.String? challengeId,
      _i3.DateTime? expiresAt,
      _i3.DateTime? resendAvailableAt,
    }) => ResentOtpChallengeView(
      challengeId: challengeId ?? this.challengeId,
      expiresAt: expiresAt ?? this.expiresAt,
      resendAvailableAt: resendAvailableAt ?? this.resendAvailableAt,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ResentOtpChallengeView &&
        other.challengeId == this.challengeId &&
        other.expiresAt == this.expiresAt &&
        other.resendAvailableAt == this.resendAvailableAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.challengeId,
      this.expiresAt,
      this.resendAvailableAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'challengeId'] = _i1.PropertyValue.scalar(this.challengeId);
    _$result[r'expiresAt'] = _i1.PropertyValue.scalar(
      this.expiresAt.toTimeZonedIso8601String(),
    );
    _$result[r'resendAvailableAt'] = _i1.PropertyValue.scalar(
      this.resendAvailableAt.toTimeZonedIso8601String(),
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
      r'Cannot uriEncode ResentOtpChallengeView: complex types cannot be URI-encoded',
    );
  }
}
