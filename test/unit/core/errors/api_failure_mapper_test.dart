import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';

final _now = DateTime.utc(2026, 11, 3, 12);
final _mapper = ApiFailureMapper(clock: FixedClock(_now));
final _request = RequestOptions(path: '/api/portal/v1/me');

List<int> _fixture(String name) =>
    File('$portalFixtures/$name').readAsBytesSync();

ApiFailure _status(
  int? status, {
  Object? body,
  Map<String, List<String>> headers = const {},
}) => _mapper.fromResponse(statusCode: status, body: body, headers: headers);

String _problem(String type) => jsonEncode({'type': type, 'status': 0});

void main() {
  group('the contract fixtures', () {
    test('me.get.401.json is an UnauthorizedFailure', () {
      final failure = _status(401, body: _fixture('me.get.401.json'));

      expect(
        failure,
        isA<UnauthorizedFailure>().having(
          (f) => f.code,
          'code',
          'unauthorized',
        ),
      );
    });

    test('clinics.unknown.home.get.404.json is a NotFoundFailure', () {
      final failure = _status(
        404,
        body: _fixture('clinics.unknown.home.get.404.json'),
      );

      expect(
        failure,
        isA<NotFoundFailure>()
            .having((f) => f.code, 'code', 'not_found')
            .having((f) => f.detail, 'detail', isNull),
      );
    });

    test('me.patch.422.json is a ValidationFailure with its violation', () {
      final failure = _status(422, body: _fixture('me.patch.422.json'));

      expect(failure, isA<ValidationFailure>());
      final violations = (failure as ValidationFailure).violations;
      expect(violations, [
        const Violation(
          propertyPath: 'firstName',
          message: 'Le prénom ne peut pas être vide.',
          code: 'c1051bb4-d103-4f74-8988-acbcafc7fdc3',
        ),
      ]);
      expect(failure.code, 'validation_failed');
    });
  });

  group('by status', () {
    test('409 slot_taken is a ConflictFailure', () {
      expect(
        _status(409, body: _problem('slot_taken')),
        isA<ConflictFailure>().having((f) => f.code, 'code', 'slot_taken'),
      );
    });

    for (final (status, type) in [
      (410, 'invitation_expired'),
      (403, 'account_disabled'),
      (400, 'bad_request'),
      (422, 'otp_invalid'),
    ]) {
      test('$status $type is a BusinessFailure', () {
        expect(
          _status(status, body: _problem(type)),
          isA<BusinessFailure>()
              .having((f) => f.code, 'code', type)
              .having((f) => f.statusCode, 'statusCode', status),
        );
      });
    }

    test('a 4xx without problem type is named after its status', () {
      expect(
        _status(418),
        isA<BusinessFailure>().having((f) => f.code, 'code', 'http_418'),
      );
    });

    test('5xx is a ServerFailure with its Retry-After', () {
      expect(
        _status(
          503,
          body: _problem('service_unavailable'),
          headers: {
            'retry-after': ['30'],
          },
        ),
        isA<ServerFailure>()
            .having((f) => f.statusCode, 'statusCode', 503)
            .having((f) => f.code, 'code', 'service_unavailable')
            .having(
              (f) => f.retryAfter,
              'retryAfter',
              const Duration(seconds: 30),
            ),
      );
      expect(
        _status(500),
        isA<ServerFailure>()
            .having((f) => f.statusCode, 'statusCode', 500)
            .having((f) => f.retryAfter, 'retryAfter', isNull),
      );
    });

    test('no status, 1xx, 2xx, 3xx are ServerFailures (unexpected)', () {
      for (final status in [null, 101, 200, 302]) {
        expect(
          _status(status),
          isA<ServerFailure>().having(
            (f) => f.statusCode,
            'statusCode',
            status,
          ),
        );
      }
    });

    test('an undecodable body is mapped by status, without code', () {
      final bodies = <Object?>[
        utf8.encode('<html>502</html>'),
        [0xff, 0xfe],
        'not json',
        '[1, 2]',
        42,
        null,
      ];
      for (final body in bodies) {
        expect(
          _status(404, body: body),
          isA<NotFoundFailure>().having((f) => f.code, 'code', isNull),
        );
      }
    });

    test('a decoded map and a string body are read too', () {
      expect(
        _status(401, body: {'type': 'token_expired', 'detail': 'x'}),
        isA<UnauthorizedFailure>()
            .having((f) => f.code, 'code', 'token_expired')
            .having((f) => f.detail, 'detail', 'x'),
      );
      expect(
        _status(401, body: '{"type": 7, "detail": false}'),
        isA<UnauthorizedFailure>()
            .having((f) => f.code, 'code', isNull)
            .having((f) => f.detail, 'detail', isNull),
      );
    });

    test('422 validation_failed skips the malformed violations', () {
      final failure = _status(
        422,
        body: jsonEncode({
          'type': 'validation_failed',
          'violations': [
            {'propertyPath': 'email', 'message': 'Invalide.', 'code': 3},
            {'propertyPath': 'phone'},
            'oops',
          ],
        }),
      );

      expect((failure as ValidationFailure).violations, [
        const Violation(propertyPath: 'email', message: 'Invalide.'),
      ]);
      expect(
        (_status(
          422,
          body: _problem('validation_failed'),
        ) as ValidationFailure).violations,
        isEmpty,
      );
    });
  });

  group('429 Retry-After', () {
    RateLimitedFailure limited(Map<String, List<String>> headers) =>
        _status(429, body: _problem('otp_rate_limited'), headers: headers)
            as RateLimitedFailure;

    test('in seconds, whatever the header case', () {
      final failure = limited({
        'Retry-After': [' 120 '],
      });

      expect(failure.retryAfter, const Duration(seconds: 120));
      expect(failure.code, 'otp_rate_limited');
    });

    test('as an HTTP-date, minus the clock, never negative', () {
      expect(
        limited({
          'retry-after': [
            HttpDate.format(_now.add(const Duration(minutes: 3))),
          ],
        }).retryAfter,
        const Duration(minutes: 3),
      );
      expect(
        limited({
          'retry-after': [
            HttpDate.format(_now.subtract(const Duration(hours: 1))),
          ],
        }).retryAfter,
        Duration.zero,
      );
    });

    test('garbage, a negative number or no header give null', () {
      expect(
        limited({
          'retry-after': ['soon'],
        }).retryAfter,
        isNull,
      );
      expect(
        limited({
          'retry-after': ['-5'],
        }).retryAfter,
        isNull,
      );
      expect(limited({}).retryAfter, isNull);
    });
  });

  group('fromDio', () {
    test('a response (badResponse, or unknown with one) maps by status', () {
      final response = Response<Object?>(
        requestOptions: _request,
        statusCode: 401,
        data: _fixture('me.get.401.json'),
        headers: Headers.fromMap({
          'content-type': ['application/problem+json'],
        }),
      );

      for (final type in [
        DioExceptionType.badResponse,
        DioExceptionType.unknown,
      ]) {
        expect(
          _mapper.fromDio(
            DioException(
              requestOptions: _request,
              response: response,
              type: type,
            ),
          ),
          isA<UnauthorizedFailure>().having(
            (f) => f.code,
            'code',
            'unauthorized',
          ),
        );
      }
    });

    test('no usable answer is a NetworkFailure', () {
      for (final type in DioExceptionType.values) {
        expect(
          _mapper.fromDio(DioException(requestOptions: _request, type: type)),
          isA<NetworkFailure>(),
          reason: '$type',
        );
      }
    });
  });
}
