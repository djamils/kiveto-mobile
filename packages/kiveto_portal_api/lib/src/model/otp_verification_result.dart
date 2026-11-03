// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i7;
import 'package:kiveto_portal_api/src/model/otp_verification_otp_verification_view_invitations_array_model.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/otp_verification_otp_verification_view_pending_invitations_array_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/otp_verification_otp_verification_view_status_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class OtpVerificationResult extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const OtpVerificationResult({
    required this.status,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.pendingInvitations,
    required this.onboardingToken,
    required this.onboardingTokenExpiresAt,
    required this.registrationToken,
    required this.invitations,
    required this.registrationTokenExpiresAt,
  });

  factory OtpVerificationResult.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for OtpVerificationResult: contains complex types',
    );
  }

  factory OtpVerificationResult.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'OtpVerificationResult');
    return OtpVerificationResult(
      status: _i4.OtpVerificationOtpVerificationViewStatusModel.fromJson(
        _$map[r'status'],
      ),
      accessToken: _$map[r'accessToken'].decodeJsonNullableString(
        context: r'OtpVerificationResult.accessToken',
      ),
      accessTokenExpiresAt: _$map[r'accessTokenExpiresAt']
          .decodeJsonNullableDateTime(
            context: r'OtpVerificationResult.accessTokenExpiresAt',
          ),
      refreshToken: _$map[r'refreshToken'].decodeJsonNullableString(
        context: r'OtpVerificationResult.refreshToken',
      ),
      refreshTokenExpiresAt: _$map[r'refreshTokenExpiresAt']
          .decodeJsonNullableDateTime(
            context: r'OtpVerificationResult.refreshTokenExpiresAt',
          ),
      pendingInvitations: _$map[r'pendingInvitations']
          .decodeJsonList<_i3.Object?>(
            context: r'OtpVerificationResult.pendingInvitations',
          )
          .map(
            _i5
                .OtpVerificationOtpVerificationViewPendingInvitationsArrayModel
                .fromJson,
          )
          .toList(),
      onboardingToken: _$map[r'onboardingToken'].decodeJsonNullableString(
        context: r'OtpVerificationResult.onboardingToken',
      ),
      onboardingTokenExpiresAt: _$map[r'onboardingTokenExpiresAt']
          .decodeJsonNullableDateTime(
            context: r'OtpVerificationResult.onboardingTokenExpiresAt',
          ),
      registrationToken: _$map[r'registrationToken'].decodeJsonNullableString(
        context: r'OtpVerificationResult.registrationToken',
      ),
      invitations: _$map[r'invitations']
          .decodeJsonList<_i3.Object?>(
            context: r'OtpVerificationResult.invitations',
          )
          .map(
            _i6
                .OtpVerificationOtpVerificationViewInvitationsArrayModel
                .fromJson,
          )
          .toList(),
      registrationTokenExpiresAt: _$map[r'registrationTokenExpiresAt']
          .decodeJsonNullableDateTime(
            context: r'OtpVerificationResult.registrationTokenExpiresAt',
          ),
    );
  }

  factory OtpVerificationResult.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for OtpVerificationResult: contains complex types',
    );
  }

  final _i4.OtpVerificationOtpVerificationViewStatusModel status;

  final _i3.String? accessToken;

  final _i3.DateTime? accessTokenExpiresAt;

  final _i3.String? refreshToken;

  final _i3.DateTime? refreshTokenExpiresAt;

  final _i3.List<
    _i5.OtpVerificationOtpVerificationViewPendingInvitationsArrayModel
  >
  pendingInvitations;

  final _i3.String? onboardingToken;

  final _i3.DateTime? onboardingTokenExpiresAt;

  final _i3.String? registrationToken;

  final _i3.List<_i6.OtpVerificationOtpVerificationViewInvitationsArrayModel>
  invitations;

  final _i3.DateTime? registrationTokenExpiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'status': this.status.toJson(),
    r'accessToken': this.accessToken,
    r'accessTokenExpiresAt': this.accessTokenExpiresAt
        ?.toTimeZonedIso8601String(),
    r'refreshToken': this.refreshToken,
    r'refreshTokenExpiresAt': this.refreshTokenExpiresAt
        ?.toTimeZonedIso8601String(),
    r'pendingInvitations': this.pendingInvitations
        .map((e) => e.toJson())
        .toList(),
    r'onboardingToken': this.onboardingToken,
    r'onboardingTokenExpiresAt': this.onboardingTokenExpiresAt
        ?.toTimeZonedIso8601String(),
    r'registrationToken': this.registrationToken,
    r'invitations': this.invitations.map((e) => e.toJson()).toList(),
    r'registrationTokenExpiresAt': this.registrationTokenExpiresAt
        ?.toTimeZonedIso8601String(),
  };

  OtpVerificationResult Function({
    _i4.OtpVerificationOtpVerificationViewStatusModel? status,
    _i3.String? accessToken,
    _i3.DateTime? accessTokenExpiresAt,
    _i3.String? refreshToken,
    _i3.DateTime? refreshTokenExpiresAt,
    _i3.List<
      _i5.OtpVerificationOtpVerificationViewPendingInvitationsArrayModel
    >?
    pendingInvitations,
    _i3.String? onboardingToken,
    _i3.DateTime? onboardingTokenExpiresAt,
    _i3.String? registrationToken,
    _i3.List<_i6.OtpVerificationOtpVerificationViewInvitationsArrayModel>?
    invitations,
    _i3.DateTime? registrationTokenExpiresAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.OtpVerificationOtpVerificationViewStatusModel? status,
      _i3.Object? accessToken = _sentinel,
      _i3.Object? accessTokenExpiresAt = _sentinel,
      _i3.Object? refreshToken = _sentinel,
      _i3.Object? refreshTokenExpiresAt = _sentinel,
      _i3.List<
        _i5.OtpVerificationOtpVerificationViewPendingInvitationsArrayModel
      >?
      pendingInvitations,
      _i3.Object? onboardingToken = _sentinel,
      _i3.Object? onboardingTokenExpiresAt = _sentinel,
      _i3.Object? registrationToken = _sentinel,
      _i3.List<_i6.OtpVerificationOtpVerificationViewInvitationsArrayModel>?
      invitations,
      _i3.Object? registrationTokenExpiresAt = _sentinel,
    }) => OtpVerificationResult(
      status: status ?? this.status,
      accessToken: _i3.identical(accessToken, _sentinel)
          ? this.accessToken
          : (accessToken as _i3.String?),
      accessTokenExpiresAt: _i3.identical(accessTokenExpiresAt, _sentinel)
          ? this.accessTokenExpiresAt
          : (accessTokenExpiresAt as _i3.DateTime?),
      refreshToken: _i3.identical(refreshToken, _sentinel)
          ? this.refreshToken
          : (refreshToken as _i3.String?),
      refreshTokenExpiresAt: _i3.identical(refreshTokenExpiresAt, _sentinel)
          ? this.refreshTokenExpiresAt
          : (refreshTokenExpiresAt as _i3.DateTime?),
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      onboardingToken: _i3.identical(onboardingToken, _sentinel)
          ? this.onboardingToken
          : (onboardingToken as _i3.String?),
      onboardingTokenExpiresAt:
          _i3.identical(onboardingTokenExpiresAt, _sentinel)
          ? this.onboardingTokenExpiresAt
          : (onboardingTokenExpiresAt as _i3.DateTime?),
      registrationToken: _i3.identical(registrationToken, _sentinel)
          ? this.registrationToken
          : (registrationToken as _i3.String?),
      invitations: invitations ?? this.invitations,
      registrationTokenExpiresAt:
          _i3.identical(registrationTokenExpiresAt, _sentinel)
          ? this.registrationTokenExpiresAt
          : (registrationTokenExpiresAt as _i3.DateTime?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i7.DeepCollectionEquality();
    return other is OtpVerificationResult &&
        other.status == this.status &&
        other.accessToken == this.accessToken &&
        other.accessTokenExpiresAt == this.accessTokenExpiresAt &&
        other.refreshToken == this.refreshToken &&
        other.refreshTokenExpiresAt == this.refreshTokenExpiresAt &&
        _$deepEquals.equals(
          other.pendingInvitations,
          this.pendingInvitations,
        ) &&
        other.onboardingToken == this.onboardingToken &&
        other.onboardingTokenExpiresAt == this.onboardingTokenExpiresAt &&
        other.registrationToken == this.registrationToken &&
        _$deepEquals.equals(other.invitations, this.invitations) &&
        other.registrationTokenExpiresAt == this.registrationTokenExpiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i7.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.status,
      this.accessToken,
      this.accessTokenExpiresAt,
      this.refreshToken,
      this.refreshTokenExpiresAt,
      deepEquals.hash(this.pendingInvitations),
      this.onboardingToken,
      this.onboardingTokenExpiresAt,
      this.registrationToken,
      deepEquals.hash(this.invitations),
      this.registrationTokenExpiresAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for OtpVerificationResult: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i8.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode OtpVerificationResult: complex types cannot be URI-encoded',
    );
  }
}
