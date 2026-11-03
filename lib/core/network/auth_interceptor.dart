import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/session_refresher.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';

/// The last interceptor of `PortalHttp.dio`: `Authorization: Bearer` on
/// every request of a signed-in session to the API origin (never another
/// host), and one token refresh in flight at
/// a time (the backend requires the client to serialise its refreshes).
///
/// A [QueuedInterceptor] handles one error at a time: the first 401
/// `token_expired` refreshes, the next ones find that the session's access
/// token changed since they were sent and retry with it — N concurrent
/// 401s, one refresh. Retries and the refresh go through `retryDio` (the
/// same transport without this interceptor): a retry through this
/// interceptor's own Dio would deadlock when it fails, its error queued
/// behind the one awaiting it.
final class AuthInterceptor extends QueuedInterceptor {
  new({
    required this._config,
    required this._session,
    required this._refresher,
    required this._retryDio,
  });

  /// `RequestOptions.extra` key: the access token the request was sent
  /// with.
  static const sentTokenKey = 'kiveto.auth.sentAccessToken';

  /// `RequestOptions.extra` key: the request is already a retry.
  static const retriedKey = 'kiveto.auth.retried';

  /// `RequestOptions.extra` key: the order in which the request went
  /// through [onRequest].
  static const sequenceKey = 'kiveto.auth.sequence';

  /// `RequestOptions.extra` key: send this request without the Bearer
  /// token (the signed, public file URLs of `PortalFileDownloader`).
  static const anonymousKey = 'kiveto.auth.anonymous';

  /// The 401 `type`s that mean "refresh, then retry" (absent counts too).
  static const _refreshable = {'token_expired', 'unauthorized'};

  final ApiConfig _config;
  final SessionManager _session;
  final SessionRefresher _refresher;
  final Dio _retryDio;

  Future<RefreshOutcome>? _inFlight;

  /// The last request sequence number given by [onRequest].
  int _sequence = 0;

  /// The last refresh that ended unavailable: the requests sent before it
  /// with the same access token share its failure instead of refreshing
  /// again one by one (N concurrent 401s offline: one refresh).
  ({int sequence, String accessToken, Object error})? _unavailableAt;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final inFlight = _inFlight;
    if (inFlight != null) await inFlight;
    options.extra[sequenceKey] = ++_sequence;
    final tokens = _session.tokens;
    if (tokens != null &&
        options.extra[anonymousKey] != true &&
        _config.isApiOrigin(options.uri)) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      options.extra[sentTokenKey] = tokens.accessToken;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final sent = options.extra[sentTokenKey];
    if (sent is! String ||
        options.extra[retriedKey] == true ||
        !_isExpiredSession(err.response)) {
      handler.next(err);
      return;
    }

    final current = _session.tokens;
    if (current != null && current.accessToken == sent) {
      final failed = _unavailableAt;
      final sequence = options.extra[sequenceKey];
      if (failed != null &&
          failed.accessToken == sent &&
          sequence is int &&
          sequence <= failed.sequence) {
        // Sent before a refresh of this token failed: same failure.
        handler.reject(_unavailable(failed.error, options));
        return;
      }
      final outcome = await (_inFlight ??= _refresh(current));
      if (outcome case RefreshUnavailable(:final error)) {
        handler.reject(_unavailable(error, options));
        return;
      }
    }
    // The newest pair: the refreshed one, or one another error refreshed
    // or the app opened meanwhile (also after a refused refresh); none
    // after a refused refresh signed the session out.
    final next = _session.tokens;
    if (next == null) {
      handler.next(err);
      return;
    }

    options.headers['Authorization'] = 'Bearer ${next.accessToken}';
    options.extra[sentTokenKey] = next.accessToken;
    options.extra[retriedKey] = true;
    try {
      handler.resolve(await _retryDio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.reject(retryError);
    }
  }

  /// A 401 whose problem `type` is `token_expired`, `unauthorized` or
  /// absent; `onboarding_invalid`, `refresh_revoked`… are not session
  /// expiries.
  static bool _isExpiredSession(Response<dynamic>? response) {
    if (response?.statusCode != 401) return false;
    final type = ApiFailureMapper.problemOf(response!.data)?['type'];
    return type is! String || _refreshable.contains(type);
  }

  /// Refreshes [expected], applies the outcome to the session, then frees
  /// the slot for the next refresh.
  Future<RefreshOutcome> _refresh(TokenPair expected) async {
    try {
      final outcome = await _refresher.refresh(expected.refreshToken);
      switch (outcome) {
        case RefreshSucceeded(:final tokens):
          await _session.replaceTokens(expected: expected, next: tokens);
        case RefreshRejected():
          await _session.signOutIfCurrent(expected);
        case RefreshUnavailable(:final error):
          _unavailableAt = (
            sequence: _sequence,
            accessToken: expected.accessToken,
            error: error,
          );
      }
      return outcome;
    } finally {
      _inFlight = null;
    }
  }

  /// The refresh's own error, re-targeted to the original request, or a
  /// connection error when it was not a [DioException].
  static DioException _unavailable(Object error, RequestOptions options) =>
      switch (error) {
        final DioException exception => exception.copyWith(
          requestOptions: options,
        ),
        _ => DioException.connectionError(
          requestOptions: options,
          reason: 'the token refresh failed',
          error: error,
        ),
      };
}
