import 'dart:async';

import 'package:kiveto_mobile/features/identity_access/domain/auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

/// Signs out: revokes the session on the server when there is one, then
/// signs out locally whatever the server answered (offline, 401, 5xx…), and
/// at the latest after [serverWait]: a stalled network must not hold the
/// tokens on the device for the HTTP timeouts (a refresh and a replay
/// included).
final class SignOut {
  const new(this._auth, this._session);

  /// How long the server revocation may take before the local sign-out.
  static const serverWait = Duration(seconds: 5);

  final AuthRepository _auth;
  final SessionStore _session;

  Future<void> call() async {
    final refreshToken = _session.refreshToken;
    try {
      if (refreshToken != null) {
        await _auth.logout(refreshToken).timeout(serverWait);
      }
    } on ApiFailure {
      // The local sign-out below is what the user asked for: the tokens
      // leave the device even when the server could not revoke them.
    } on TimeoutException {
      // Same: the server did not answer in time.
    } finally {
      await _session.close();
    }
  }
}
