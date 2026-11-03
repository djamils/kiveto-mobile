import 'package:flutter/foundation.dart';

/// The session's tokens: the short-lived access token (Bearer) and the
/// rotating refresh token, with their expiry instants (UTC) when known.
///
/// Never logged: [toString] redacts everything.
@immutable
final class TokenPair {
  const new({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  /// The stored form of [toJson]; [FormatException] on a missing or
  /// invalid field.
  factory fromJson(Map<String, Object?> json) {
    String token(String key) => switch (json[key]) {
      final String value when value.isNotEmpty => value,
      _ => throw FormatException('TokenPair: missing or invalid $key'),
    };
    DateTime? instant(String key) => switch (json[key]) {
      null => null,
      final String value => DateTime.parse(value).toUtc(),
      _ => throw FormatException('TokenPair: invalid $key'),
    };
    return TokenPair(
      accessToken: token('accessToken'),
      refreshToken: token('refreshToken'),
      accessTokenExpiresAt: instant('accessTokenExpiresAt'),
      refreshTokenExpiresAt: instant('refreshTokenExpiresAt'),
    );
  }

  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessTokenExpiresAt': accessTokenExpiresAt?.toUtc().toIso8601String(),
    'refreshTokenExpiresAt': refreshTokenExpiresAt?.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is TokenPair &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.accessTokenExpiresAt == accessTokenExpiresAt &&
      other.refreshTokenExpiresAt == refreshTokenExpiresAt;

  @override
  int get hashCode => Object.hash(
    accessToken,
    refreshToken,
    accessTokenExpiresAt,
    refreshTokenExpiresAt,
  );

  @override
  String toString() => 'TokenPair(<redacted>)';
}
