// The real Portal HTTP chain (PortalHttp.create) on the fake backend, with
// a session in memory: what the network tests of core/ drive.

import 'dart:convert';

import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/portal_http.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';

import '../fakes.dart';
import 'fake_portal_backend.dart';

const api = '/api/portal/v1';

/// The dev configuration of `config/env/dev.json`.
final devConfig = ApiConfig(
  baseUrl: Uri.parse('http://10.0.2.2:81'),
  hostHeader: 'portal.kiveto.local',
);

final class PortalHarness {
  new _(this.backend, this.storage, this.session, this.http, this.failures);

  /// A chain signed in with [tokens] (signed out when null).
  static Future<PortalHarness> create({
    TokenPair? tokens,
    ApiConfig? config,
    String deviceId = 'device-1',
  }) async {
    final backend = FakePortalBackend();
    final storage = InMemoryTokenStorage(tokens: tokens);
    final session = await SessionManager.restore(storage);
    final http = PortalHttp.create(
      config: config ?? devConfig,
      session: session,
      deviceId: deviceId,
      adapter: backend,
    );
    return PortalHarness._(
      backend,
      storage,
      session,
      http,
      ApiFailureMapper(clock: FixedClock(DateTime.utc(2026, 11, 3))),
    );
  }

  final FakePortalBackend backend;
  final InMemoryTokenStorage storage;
  final SessionManager session;
  final PortalHttp http;
  final ApiFailureMapper failures;

  /// The refresh requests received so far.
  List<PortalRequest> get refreshes => backend.requestsTo('$api/auth/refresh');
}

/// A problem+json reply with [type] and [status].
PortalReply problem(String type, int status) => PortalReply.json(
  jsonEncode({'type': type, 'title': type, 'status': status}),
  status: status,
);

/// The `POST /auth/refresh` 200 body of the pair [name].
PortalReply refreshed(String name) => PortalReply.json(
  jsonEncode({
    'accessToken': name,
    'accessTokenExpiresAt': '2026-11-03T12:15:00+00:00',
    'refreshToken': 'refresh-$name',
    'refreshTokenExpiresAt': '2027-02-01T00:00:00+00:00',
  }),
);

/// The `Authorization` header a request carried.
Object? bearerOf(PortalRequest request) => request.headers['Authorization'];

/// The `refreshToken` of a refresh request's body.
Object? refreshTokenOf(PortalRequest request) =>
    (jsonDecode(utf8.decode(request.body))
        as Map<String, Object?>)['refreshToken'];
