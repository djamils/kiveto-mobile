// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// The pair of tokens a sign-in, an invitation acceptance or a
/// registration gives: the access token (Bearer) and the rotating refresh
/// token, with their expiry instants (UTC) when known.
///
/// Never logged: [toString] redacts everything.
final class SessionTokens {
  const new({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  @override
  bool operator ==(Object other) =>
      other is SessionTokens &&
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
  String toString() => 'SessionTokens(<redacted>)';
}
