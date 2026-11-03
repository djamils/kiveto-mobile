// SessionRefresher on the real generated AuthApi: the typed answers of a
// client without strict status, and the DioExceptions of the strict chain.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/session_refresher.dart';
import 'package:kiveto_mobile/core/network/strict_status_interceptor.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _refresh = '$api/auth/refresh';

void main() {
  late FakePortalBackend backend;

  SessionRefresher refresher({bool strict = true}) => SessionRefresher(
    AuthApi(
      portalServer(
        backend,
        interceptors: [if (strict) const StrictStatusInterceptor()],
      ),
    ),
  );

  setUp(() => backend = FakePortalBackend());

  test('200: the new pair, expiries in UTC; the refresh token is sent in '
      'the body', () async {
    backend.on('POST', _refresh, refreshed('B'));

    final outcome = await refresher().refresh('refresh-A');

    final tokens = (outcome as RefreshSucceeded).tokens;
    expect(tokens.accessToken, 'B');
    expect(tokens.refreshToken, 'refresh-B');
    expect(tokens.accessTokenExpiresAt, DateTime.utc(2026, 11, 3, 12, 15));
    expect(tokens.accessTokenExpiresAt!.isUtc, isTrue);
    expect(tokens.refreshTokenExpiresAt, DateTime.utc(2027, 2));
    expect(refreshTokenOf(backend.requests.single), 'refresh-A');
    expect(backend.requests.single.uri.query, isEmpty);
  });

  group('typed refusals (a client without strict status)', () {
    for (final (status, body) in [
      (400, problem('bad_request', 400)),
      (401, PortalReply.empty(401)),
      (422, PortalReply.fixture('me.patch.422.json', status: 422)),
    ]) {
      test('$status is rejected', () async {
        backend.on('POST', _refresh, body);

        expect(
          await refresher(strict: false).refresh('r'),
          isA<RefreshRejected>(),
        );
      });
    }
  });

  test('a 4xx DioException of the strict chain is rejected', () async {
    backend.on('POST', _refresh, problem('refresh_revoked', 401));

    expect(await refresher().refresh('r'), isA<RefreshRejected>());
  });

  for (final (status, type) in [(408, 'timeout'), (429, 'rate_limited')]) {
    test('$status is transient: unavailable, not rejected', () async {
      backend.on('POST', _refresh, problem(type, status));

      expect(await refresher().refresh('r'), isA<RefreshUnavailable>());
      expect(
        await refresher(strict: false).refresh('r'),
        isA<RefreshUnavailable>(),
      );
    });
  }

  test('5xx, network and undecodable answers are unavailable', () async {
    backend.on('POST', _refresh, problem('service_unavailable', 503));
    final server = await refresher().refresh('r');
    expect(
      (server as RefreshUnavailable).error,
      isA<DioException>().having((e) => e.response?.statusCode, 'status', 503),
    );

    backend.onRequest(
      'POST',
      _refresh,
      (_) => throw const SocketException('offline'),
    );
    expect(await refresher().refresh('r'), isA<RefreshUnavailable>());

    backend.on('POST', _refresh, PortalReply.json('{"accessToken": 1}'));
    expect(
      (await refresher().refresh('r') as RefreshUnavailable).error,
      isNot(isA<DioException>()),
    );
  });
}
