import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

/// What a `POST /auth/refresh` gave.
sealed class RefreshOutcome {
  const new();
}

/// The new pair (the refresh token rotates: the old one is spent).
final class RefreshSucceeded extends RefreshOutcome {
  const new(this.tokens);

  final TokenPair tokens;
}

/// The server refused the refresh token (`401 refresh_revoked`, or a 4xx
/// other than 408 and 429): the session is over.
final class RefreshRejected extends RefreshOutcome {
  const new();
}

/// No usable answer (network, 5xx, 408, 429, undecodable): the session is
/// kept, the next 401 tries again.
final class RefreshUnavailable extends RefreshOutcome {
  const new(this.error);

  /// The `DioException` when there is one.
  final Object error;
}

/// Calls `POST /auth/refresh` on an `AuthApi` whose server runs on the
/// chain without the auth interceptor (`PortalHttp.bareDio`).
final class SessionRefresher {
  const new(this._auth);

  final AuthApi _auth;

  Future<RefreshOutcome> refresh(String refreshToken) async {
    final result = await _auth.refreshSession(
      body: SessionRefresh(refreshToken: refreshToken),
    );
    return switch (result) {
      TonikSuccess(value: RefreshSessionResponse200(:final body)) =>
        RefreshSucceeded(
          TokenPair(
            accessToken: body.accessToken,
            refreshToken: body.refreshToken,
            accessTokenExpiresAt: body.accessTokenExpiresAt.toUtc(),
            refreshTokenExpiresAt: body.refreshTokenExpiresAt.toUtc(),
          ),
        ),
      TonikSuccess(
        value: RefreshSessionResponse400() ||
            RefreshSessionResponse401() ||
            RefreshSessionResponse422(),
      ) =>
        const RefreshRejected(),
      TonikError(
        error: DioException(response: Response(statusCode: final int status)),
      )
          when status >= 400 &&
              status < 500 &&
              status != 408 &&
              status != 429 =>
        const RefreshRejected(),
      TonikError(:final error) => RefreshUnavailable(error),
    };
  }
}
