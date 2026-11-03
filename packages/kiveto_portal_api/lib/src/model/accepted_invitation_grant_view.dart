// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/account_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AcceptedInvitationGrantView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AcceptedInvitationGrantView({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.account,
  });

  factory AcceptedInvitationGrantView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for AcceptedInvitationGrantView: contains complex types',
    );
  }

  factory AcceptedInvitationGrantView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AcceptedInvitationGrantView');
    return AcceptedInvitationGrantView(
      accessToken: _$map[r'accessToken'].decodeJsonString(
        context: r'AcceptedInvitationGrantView.accessToken',
      ),
      accessTokenExpiresAt: _$map[r'accessTokenExpiresAt'].decodeJsonDateTime(
        context: r'AcceptedInvitationGrantView.accessTokenExpiresAt',
      ),
      refreshToken: _$map[r'refreshToken'].decodeJsonString(
        context: r'AcceptedInvitationGrantView.refreshToken',
      ),
      refreshTokenExpiresAt: _$map[r'refreshTokenExpiresAt'].decodeJsonDateTime(
        context: r'AcceptedInvitationGrantView.refreshTokenExpiresAt',
      ),
      account: _i4.AccountView.fromJson(_$map[r'account']),
    );
  }

  factory AcceptedInvitationGrantView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for AcceptedInvitationGrantView: contains complex types',
    );
  }

  final _i3.String accessToken;

  final _i3.DateTime accessTokenExpiresAt;

  final _i3.String refreshToken;

  final _i3.DateTime refreshTokenExpiresAt;

  final _i4.AccountView account;

  @_i3.override
  _i3.Object? toJson() => {
    r'accessToken': this.accessToken,
    r'accessTokenExpiresAt': this.accessTokenExpiresAt
        .toTimeZonedIso8601String(),
    r'refreshToken': this.refreshToken,
    r'refreshTokenExpiresAt': this.refreshTokenExpiresAt
        .toTimeZonedIso8601String(),
    r'account': this.account.toJson(),
  };

  AcceptedInvitationGrantView Function({
    _i3.String? accessToken,
    _i3.DateTime? accessTokenExpiresAt,
    _i3.String? refreshToken,
    _i3.DateTime? refreshTokenExpiresAt,
    _i4.AccountView? account,
  })
  get copyWith {
    return ({
      _i3.String? accessToken,
      _i3.DateTime? accessTokenExpiresAt,
      _i3.String? refreshToken,
      _i3.DateTime? refreshTokenExpiresAt,
      _i4.AccountView? account,
    }) => AcceptedInvitationGrantView(
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiresAt:
          refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      account: account ?? this.account,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptedInvitationGrantView &&
        other.accessToken == this.accessToken &&
        other.accessTokenExpiresAt == this.accessTokenExpiresAt &&
        other.refreshToken == this.refreshToken &&
        other.refreshTokenExpiresAt == this.refreshTokenExpiresAt &&
        other.account == this.account;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.accessToken,
      this.accessTokenExpiresAt,
      this.refreshToken,
      this.refreshTokenExpiresAt,
      this.account,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for AcceptedInvitationGrantView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode AcceptedInvitationGrantView: complex types cannot be URI-encoded',
    );
  }
}
