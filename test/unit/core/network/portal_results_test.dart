import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

final _failures = ApiFailureMapper(clock: FixedClock(DateTime.utc(2026)));
final _request = RequestOptions(path: '/x');

TonikError<Object?, Response<Object?>> _error(
  Object error,
  TonikErrorType type, {
  Response<Object?>? response,
}) => TonikError(
  error,
  stackTrace: StackTrace.empty,
  type: type,
  response: response,
);

void main() {
  group('apiFailureOf', () {
    test('a TonikError carrying a DioException is mapped from it', () {
      final failure = apiFailureOf(
        _error(
          DioException.connectionTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: _request,
          ),
          TonikErrorType.network,
        ),
        _failures,
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('network or cancelled without DioException: NetworkFailure', () {
      for (final type in [TonikErrorType.network, TonikErrorType.cancelled]) {
        expect(
          apiFailureOf(_error(StateError('x'), type), _failures),
          isA<NetworkFailure>(),
        );
      }
    });

    test('an undecodable 2xx is a ServerFailure(200)', () {
      final failure = apiFailureOf(
        _error(
          const FormatException('bad json'),
          TonikErrorType.decoding,
          response: Response(requestOptions: _request, statusCode: 200),
        ),
        _failures,
      );

      expect(
        failure,
        isA<ServerFailure>().having((f) => f.statusCode, 'status', 200),
      );
    });

    test('another error without response: ServerFailure()', () {
      expect(
        apiFailureOf(
          _error(StateError('x'), TonikErrorType.encoding),
          _failures,
        ),
        isA<ServerFailure>().having((f) => f.statusCode, 'status', isNull),
      );
    });

    test('an undesired success variant maps from its response', () async {
      final backend = FakePortalBackend()
        ..on(
          'GET',
          '$api/me',
          PortalReply.fixture('clinics.unknown.home.get.404.json', status: 404),
        );

      final result = await AccountApi(portalServer(backend)).getMe();

      expect(result, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
      expect(
        apiFailureOf(result, _failures),
        isA<NotFoundFailure>().having((f) => f.code, 'code', 'not_found'),
      );
    });
  });

  test('clinicInstantOf keeps the wire offset; +00:00 is UTC', () {
    final paris = clinicInstantOf(
      OffsetDateTime.parse('2026-11-11T10:30:00+01:00'),
    );
    final utc = clinicInstantOf(
      OffsetDateTime.parse('2026-09-02T02:22:35+00:00'),
    );

    expect(paris.toIso8601String(), '2026-11-11T10:30:00+01:00');
    expect(paris.hour, 10);
    expect(utc.offset, Duration.zero);
    expect(utc.instant, DateTime.utc(2026, 9, 2, 2, 22, 35));
  });

  test('localDateOf', () {
    expect(localDateOf(Date(2020, 3, 2)), LocalDate(2020, 3, 2));
  });
}
