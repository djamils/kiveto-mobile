// The auth interceptor on the real chain (PortalHttp.create) and the real
// generated client, against the fake backend: Bearer, one refresh for N
// concurrent 401s (milestone V4), the outcomes of a refresh, retries.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/auth_interceptor.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/core/network/session_refresher.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _me = '$api/me';
const _refresh = '$api/auth/refresh';
const _paris = '01960000-0000-7000-8000-000000000001';

/// `GET /me`: 200 to `Bearer <accepted>`, 401 [expiredType] otherwise.
void _meAccepts(
  FakePortalBackend backend,
  String accepted, {
  String expiredType = 'token_expired',
}) => backend.onRequest(
  'GET',
  _me,
  (request) => bearerOf(request) == 'Bearer $accepted'
      ? PortalReply.fixture('me.get.200.json')
      : problem(expiredType, 401),
);

void main() {
  late PortalHarness harness;

  Future<TonikResult<GetMeResponse, Response<Object?>>> getMe() =>
      AccountApi(harness.http.server).getMe();

  ApiFailure failureOf(TonikResult<Object?, Response<Object?>> result) =>
      apiFailureOf(result, harness.failures);

  group('signed in with pair A', () {
    setUp(() async {
      harness = await PortalHarness.create(tokens: pair('A'));
    });

    test('every request carries Bearer A', () async {
      _meAccepts(harness.backend, 'A');

      final result = await getMe();

      expect(result, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
      expect(bearerOf(harness.backend.requests.single), 'Bearer A');
      expect(harness.refreshes, isEmpty);
    });

    test('the Bearer goes to the API origin only', () async {
      harness.backend.on('GET', '/x', PortalReply.json('{}'));

      await harness.http.dio.get<Object?>('https://cdn.example.com/x');
      await harness.http.dio.get<Object?>('/x');

      final [other, api] = harness.backend.requests;
      expect(other.headers, isNot(contains('Authorization')));
      expect(bearerOf(api), 'Bearer A');
    });

    test('a request that waited on a refresh which then failed refreshes '
        'again', () async {
      _meAccepts(harness.backend, 'B');
      late Future<TonikResult<GetMeResponse, Response<Object?>>> during;
      var refreshes = 0;
      harness.backend.onRequest('POST', _refresh, (_) async {
        if (++refreshes > 1) return refreshed('B');
        during = getMe();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        throw const SocketException('offline');
      });

      final first = await getMe();
      final waited = await during;

      expect(failureOf(first), isA<NetworkFailure>());
      expect(waited, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
      expect(harness.refreshes, hasLength(2));
      expect(harness.session.tokens?.accessToken, 'B');
    });

    test('V4: 5 concurrent 401s trigger exactly one refresh', () async {
      _meAccepts(harness.backend, 'B');
      harness.backend.onRequest('POST', _refresh, (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return refreshed('B');
      });

      final results = await Future.wait([for (var i = 0; i < 5; i++) getMe()]);

      expect(harness.refreshes, hasLength(1));
      expect(refreshTokenOf(harness.refreshes.single), 'refresh-A');
      final retries = [
        for (final request in harness.backend.requestsTo(_me))
          if (bearerOf(request) == 'Bearer B') request,
      ];
      expect(retries, hasLength(5));
      for (final result in results) {
        expect(
          result,
          isA<TonikSuccess<GetMeResponse, Response<Object?>>>().having(
            (success) => success.value,
            'value',
            isA<GetMeResponse200>(),
          ),
        );
      }
      expect(harness.session.tokens?.accessToken, 'B');
      expect(harness.session.tokens?.refreshToken, 'refresh-B');
      expect(
        harness.session.tokens?.accessTokenExpiresAt,
        DateTime.utc(2026, 11, 3, 12, 15),
      );
      expect(harness.storage.tokens, harness.session.tokens);
    });

    for (final type in ['unauthorized', null]) {
      test('a 401 ${type ?? 'without problem type'} refreshes too', () async {
        harness.backend
          ..onRequest(
            'GET',
            _me,
            (request) => bearerOf(request) == 'Bearer B'
                ? PortalReply.fixture('me.get.200.json')
                : type == null
                ? PortalReply.empty(401)
                : problem(type, 401),
          )
          ..on('POST', _refresh, refreshed('B'));

        final result = await getMe();

        expect(result, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
        expect(harness.refreshes, hasLength(1));
      });
    }

    for (final (status, type) in [
      (401, 'refresh_revoked'),
      (400, 'bad_request'),
      (422, 'validation_failed'),
    ]) {
      test('refresh refused ($status $type): signed out, storage cleared, '
          'the call is an UnauthorizedFailure', () async {
        var notifications = 0;
        harness.session.addListener(() => notifications++);
        _meAccepts(harness.backend, 'B');
        harness.backend.on('POST', _refresh, problem(type, status));

        final result = await getMe();

        expect(
          failureOf(result),
          isA<UnauthorizedFailure>().having(
            (f) => f.code,
            'code',
            'token_expired',
          ),
        );
        expect(harness.session.status, SessionStatus.signedOut);
        expect(harness.storage.tokens, isNull);
        expect(notifications, 1);
        expect(harness.backend.requestsTo(_me), hasLength(1));
      });
    }

    test(
      'refresh rate-limited (429): session kept, RateLimitedFailure',
      () async {
        _meAccepts(harness.backend, 'B');
        harness.backend.on(
          'POST',
          _refresh,
          PortalReply.json(
            jsonEncode({'type': 'rate_limited', 'status': 429}),
            status: 429,
            headers: {
              'Retry-After': ['60'],
            },
          ),
        );

        final failure = failureOf(await getMe());

        expect(
          failure,
          isA<RateLimitedFailure>().having(
            (f) => f.retryAfter,
            'retryAfter',
            const Duration(seconds: 60),
          ),
        );
        expect(harness.session.tokens, pair('A'));
        expect(harness.storage.tokens, pair('A'));
      },
    );

    test('offline: 5 concurrent 401s share one failed refresh; a later call '
        'refreshes again', () async {
      _meAccepts(harness.backend, 'B');
      harness.backend.onRequest('POST', _refresh, (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        throw const SocketException('offline');
      });

      final results = await Future.wait([for (var i = 0; i < 5; i++) getMe()]);

      expect(harness.refreshes, hasLength(1));
      expect(results.map(failureOf), everyElement(isA<NetworkFailure>()));
      expect(harness.session.tokens, pair('A'));
      expect(harness.storage.tokens, pair('A'));

      harness.backend.on('POST', _refresh, refreshed('B'));
      final later = await getMe();

      expect(harness.refreshes, hasLength(2));
      expect(later, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
      expect(harness.session.tokens?.accessToken, 'B');
    });

    test('a newer pair opened during a refused refresh: the call is retried '
        'with it', () async {
      _meAccepts(harness.backend, 'C');
      harness.backend.onRequest('POST', _refresh, (_) async {
        await harness.session.open(pair('C'));
        return problem('refresh_revoked', 401);
      });

      final result = await getMe();

      expect(result, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
      expect(harness.session.tokens, pair('C'));
      expect(bearerOf(harness.backend.requestsTo(_me).last), 'Bearer C');
    });

    test('refresh unavailable (connection error): session kept, '
        'NetworkFailure', () async {
      _meAccepts(harness.backend, 'B');
      harness.backend.onRequest(
        'POST',
        _refresh,
        (_) => throw const SocketException('offline'),
      );

      final result = await getMe();

      expect(failureOf(result), isA<NetworkFailure>());
      expect(harness.session.tokens, pair('A'));
      expect(harness.storage.tokens, pair('A'));
    });

    test('refresh unavailable (503): session kept, ServerFailure', () async {
      _meAccepts(harness.backend, 'B');
      harness.backend.on(
        'POST',
        _refresh,
        PortalReply.json(
          jsonEncode({'type': 'service_unavailable', 'status': 503}),
          status: 503,
          headers: {
            'Retry-After': ['20'],
          },
        ),
      );

      final failure = failureOf(await getMe());

      expect(
        failure,
        isA<ServerFailure>()
            .having((f) => f.statusCode, 'statusCode', 503)
            .having(
              (f) => f.retryAfter,
              'retryAfter',
              const Duration(seconds: 20),
            ),
      );
      expect(harness.session.tokens, pair('A'));
    });

    test('refresh unavailable (undecodable 200): session kept, '
        'NetworkFailure', () async {
      _meAccepts(harness.backend, 'B');
      harness.backend.on('POST', _refresh, PortalReply.json('{}'));

      expect(failureOf(await getMe()), isA<NetworkFailure>());
      expect(harness.session.tokens, pair('A'));
      expect(harness.storage.tokens, pair('A'));
    });

    test('the retry keeps the Idempotency-Key and the body bytes', () async {
      const path = '$api/clinics/$_paris/appointments';
      harness.backend
        ..onRequest(
          'POST',
          path,
          (request) => bearerOf(request) == 'Bearer B'
              ? problem('slot_taken', 409)
              : problem('token_expired', 401),
        )
        ..on('POST', _refresh, refreshed('B'));

      final result = await SchedulingApi(harness.http.server).bookAppointment(
        clinicId: _paris,
        idempotencyKey: 'K',
        body: AppointmentBooking(
          petId: 'pet',
          motifId: 'motif',
          practitionerId: 'practitioner',
          startAt: OffsetDateTime.parse('2026-11-04T13:30:00+01:00'),
        ),
      );

      final [first, retry] = harness.backend.requestsTo(path);
      expect(bearerOf(first), 'Bearer A');
      expect(bearerOf(retry), 'Bearer B');
      expect(first.headers['Idempotency-Key'], 'K');
      expect(retry.headers['Idempotency-Key'], 'K');
      expect(retry.body, first.body);
      expect(utf8.decode(retry.body), contains('2026-11-04T13:30:00+01:00'));
      expect(
        failureOf(result),
        isA<ConflictFailure>().having((f) => f.code, 'code', 'slot_taken'),
      );
    });

    test(
      '401 onboarding_invalid is not a session expiry: no refresh',
      () async {
        _meAccepts(harness.backend, 'B', expiredType: 'onboarding_invalid');

        final result = await getMe();

        expect(harness.refreshes, isEmpty);
        expect(
          failureOf(result),
          isA<UnauthorizedFailure>().having(
            (f) => f.code,
            'code',
            'onboarding_invalid',
          ),
        );
        expect(harness.session.tokens, pair('A'));
      },
    );

    test('the retry answering 401 ends the call: no second refresh', () async {
      _meAccepts(harness.backend, 'nobody');
      harness.backend.on('POST', _refresh, refreshed('B'));

      final result = await getMe();

      expect(harness.refreshes, hasLength(1));
      expect(harness.backend.requestsTo(_me), hasLength(2));
      expect(failureOf(result), isA<UnauthorizedFailure>());
      expect(harness.session.tokens?.accessToken, 'B');
    });

    test(
      'a newer pair opened during the refresh wins over its result',
      () async {
        _meAccepts(harness.backend, 'C');
        harness.backend.onRequest('POST', _refresh, (_) async {
          await harness.session.open(pair('C'));
          return refreshed('B');
        });

        final result = await getMe();

        expect(result, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
        expect(harness.session.tokens, pair('C'));
        expect(harness.storage.tokens, pair('C'));
        expect(bearerOf(harness.backend.requestsTo(_me).last), 'Bearer C');
      },
    );

    test('a request sent during the refresh waits for the new pair', () async {
      _meAccepts(harness.backend, 'B');
      late Future<TonikResult<GetMeResponse, Response<Object?>>> during;
      harness.backend.onRequest('POST', _refresh, (_) async {
        during = getMe();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return refreshed('B');
      });

      await getMe();
      final result = await during;

      expect(result, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
      expect(harness.refreshes, hasLength(1));
      expect(harness.backend.requestsTo(_me).map(bearerOf), [
        'Bearer A',
        'Bearer B',
        'Bearer B',
      ]);
    });

    test('signed out while the 401 travels: no refresh, no retry', () async {
      harness.backend.onRequest('GET', _me, (_) async {
        await harness.session.signOut();
        return problem('token_expired', 401);
      });

      final result = await getMe();

      expect(harness.refreshes, isEmpty);
      expect(harness.backend.requestsTo(_me), hasLength(1));
      expect(failureOf(result), isA<UnauthorizedFailure>());
    });
  });

  test('signed out: no Bearer, and a 401 is not refreshed', () async {
    harness = await PortalHarness.create();
    _meAccepts(harness.backend, 'A', expiredType: 'unauthorized');

    final result = await getMe();

    expect(
      harness.backend.requests.single.headers,
      isNot(contains('Authorization')),
    );
    expect(harness.refreshes, isEmpty);
    expect(failureOf(result), isA<UnauthorizedFailure>());
  });

  test('a request flagged as already retried is passed on', () async {
    harness = await PortalHarness.create(tokens: pair('A'));
    final interceptor = AuthInterceptor(
      config: devConfig,
      session: harness.session,
      refresher: SessionRefresher(AuthApi(harness.http.server)),
      retryDio: harness.http.bareDio,
    );
    final options = RequestOptions(
      path: _me,
      extra: {
        AuthInterceptor.sentTokenKey: 'A',
        AuthInterceptor.retriedKey: true,
      },
    );
    final error = DioException.badResponse(
      statusCode: 401,
      requestOptions: options,
      response: Response<Object?>(requestOptions: options, statusCode: 401),
    );
    final handler = _RecordingErrorHandler();

    await interceptor.onError(error, handler);

    expect(handler.passed, same(error));
    expect(harness.refreshes, isEmpty);
  });
}

final class _RecordingErrorHandler extends ErrorInterceptorHandler {
  DioException? passed;

  @override
  void next(DioException error) => passed = error;
}
