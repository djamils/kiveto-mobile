import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';

/// [SessionStore] over the app's [SessionManager]: the router, the auth
/// interceptor and `sessionStatusProvider` follow what it opens and closes.
final class SessionManagerStore implements SessionStore {
  const new(this._session);

  final SessionManager _session;

  @override
  Future<void> open(SessionTokens tokens) => _session.open(
    TokenPair(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      accessTokenExpiresAt: tokens.accessTokenExpiresAt?.toUtc(),
      refreshTokenExpiresAt: tokens.refreshTokenExpiresAt?.toUtc(),
    ),
  );

  @override
  Future<void> close() => _session.signOut();

  @override
  String? get refreshToken => _session.tokens?.refreshToken;
}
