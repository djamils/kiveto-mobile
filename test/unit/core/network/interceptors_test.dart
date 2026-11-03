// Each transport interceptor alone, on a Dio whose adapter is the fake
// backend; and ApiConfig.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/dev_host_interceptor.dart';
import 'package:kiveto_mobile/core/network/device_id_interceptor.dart';
import 'package:kiveto_mobile/core/network/strict_status_interceptor.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

(Dio, FakePortalBackend) _dio(List<Interceptor> interceptors) {
  final backend = FakePortalBackend();
  final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:81'))
    ..httpClientAdapter = backend;
  dio.interceptors.addAll(interceptors);
  return (dio, backend);
}

void main() {
  group('ApiConfig', () {
    test('an origin, with or without a trailing slash', () {
      final config = ApiConfig(baseUrl: Uri.parse('http://10.0.2.2:81/'));

      expect(config.origin, 'http://10.0.2.2:81');
      expect(config.hostHeader, isNull);
      expect(config.isApiOrigin(Uri.parse('http://10.0.2.2:81/api')), isTrue);
      expect(config.isApiOrigin(Uri.parse('https://10.0.2.2:81/')), isFalse);
      expect(config.isApiOrigin(Uri.parse('http://10.0.2.2/')), isFalse);
      expect(config.isApiOrigin(Uri.parse('http://other:81/')), isFalse);
      expect(
        ApiConfig(baseUrl: Uri.parse('https://portal.kiveto.app')).origin,
        'https://portal.kiveto.app',
      );
    });

    for (final url in [
      'portal.kiveto.local',
      '/api',
      'ftp://host',
      'http://host/api',
      'http://host?x=1',
      'http://host#f',
      'http://user@host',
      'http:///path',
    ]) {
      test('refuses $url', () {
        expect(() => ApiConfig(baseUrl: Uri.parse(url)), throwsArgumentError);
      });
    }
  });

  group('StrictStatusInterceptor', () {
    test('2xx passes, 4xx is a badResponse', () async {
      final (dio, backend) = _dio([const StrictStatusInterceptor()]);
      backend
        ..on('GET', '/ok', PortalReply.json('{}'))
        ..on('GET', '/missing', problem('not_found', 404));

      expect((await dio.get<Object?>('/ok')).statusCode, 200);
      await expectLater(
        dio.get<Object?>('/missing'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.badResponse,
          ),
        ),
      );
    });

    test('a 3xx passes only when redirects are not followed', () async {
      final (dio, backend) = _dio([const StrictStatusInterceptor()]);
      backend.on(
        'GET',
        '/moved',
        PortalReply.empty(
          302,
          headers: {
            'location': ['/elsewhere'],
          },
        ),
      );

      final response = await dio.get<Object?>(
        '/moved',
        options: Options(followRedirects: false),
      );

      expect(response.statusCode, 302);
      await expectLater(
        dio.get<Object?>('/moved'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('DevHostInterceptor', () {
    test('Host on the API origin only', () async {
      final (dio, backend) = _dio([DevHostInterceptor(devConfig)]);
      backend.on('GET', '/x', PortalReply.json('{}'));

      await dio.get<Object?>('/x');
      await dio.get<Object?>('http://example.com/x');

      expect(backend.requests.first.headers['Host'], 'portal.kiveto.local');
      expect(backend.requests.last.headers, isNot(contains('Host')));
    });

    test('rewrites a 3xx Location on the dev host, any port and case, path '
        'and query kept', () async {
      final (dio, backend) = _dio([
        const StrictStatusInterceptor(),
        DevHostInterceptor(devConfig),
      ]);
      for (final (path, location) in [
        (
          '/a',
          'http://portal.kiveto.local/files/documents/c/d/1?_hash=x&_expiration=9',
        ),
        ('/b', 'https://PORTAL.kiveto.local:8443/files/x'),
        ('/c', 'https://cdn.example.com/files/x'),
        ('/d', '/files/relative'),
      ]) {
        backend.on(
          'GET',
          path,
          PortalReply.empty(
            302,
            headers: {
              'location': [location],
            },
          ),
        );
      }

      Future<String?> locationOf(String path) async => (await dio.get<Object?>(
        path,
        options: Options(followRedirects: false),
      )).headers.value('location');

      expect(
        await locationOf('/a'),
        'http://10.0.2.2:81/files/documents/c/d/1?_hash=x&_expiration=9',
      );
      expect(await locationOf('/b'), 'http://10.0.2.2:81/files/x');
      expect(await locationOf('/c'), 'https://cdn.example.com/files/x');
      expect(await locationOf('/d'), '/files/relative');
    });

    test('rewrites the Location of a 3xx that arrives as an error', () async {
      final (dio, backend) = _dio([
        const StrictStatusInterceptor(),
        DevHostInterceptor(devConfig),
      ]);
      backend.on(
        'GET',
        '/moved',
        PortalReply.empty(
          301,
          headers: {
            'location': ['http://portal.kiveto.local/new'],
          },
        ),
      );

      final error = await dio
          .get<Object?>('/moved')
          .then<DioException?>(
            (_) => null,
            onError: (Object e) => e as DioException,
          );

      expect(
        error?.response?.headers.value('location'),
        'http://10.0.2.2:81/new',
      );
    });

    test('leaves non-3xx answers, errors without response and an absent '
        'host header alone', () async {
      final (dio, backend) = _dio([
        DevHostInterceptor(devConfig),
        DevHostInterceptor(ApiConfig(baseUrl: Uri.parse('http://10.0.2.2:81'))),
      ]);
      backend
        ..on(
          'GET',
          '/ok',
          PortalReply.json(
            '{}',
            headers: {
              'location': ['http://portal.kiveto.local/x'],
            },
          ),
        )
        ..on(
          'GET',
          '/moved',
          PortalReply.empty(
            302,
            headers: {
              'location': ['http://portal.kiveto.local/x'],
            },
          ),
        );

      final ok = await dio.get<Object?>('/ok');
      expect(ok.headers.value('location'), 'http://portal.kiveto.local/x');
      final moved = await dio.get<Object?>(
        '/moved',
        options: Options(followRedirects: false, validateStatus: (_) => true),
      );
      expect(moved.headers.value('location'), 'http://10.0.2.2:81/x');
      await expectLater(
        dio.get<Object?>('/unrouted'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('DeviceIdInterceptor', () {
    test('adds X-Device-Id unless one is named, whatever its case', () async {
      final (dio, backend) = _dio([DeviceIdInterceptor(devConfig, 'device-1')]);
      backend.on('GET', '/x', PortalReply.json('{}'));

      await dio.get<Object?>('/x');
      await dio.get<Object?>(
        '/x',
        options: Options(headers: {'x-device-id': 'mine'}),
      );

      expect(backend.requests.first.headers['X-Device-Id'], 'device-1');
      final explicit = backend.requests.last.headers;
      expect(
        explicit.entries
            .where((e) => e.key.toLowerCase() == 'x-device-id')
            .map((e) => e.value),
        ['mine'],
      );
    });

    test('never on another origin', () async {
      final (dio, backend) = _dio([DeviceIdInterceptor(devConfig, 'device-1')]);
      backend.on('GET', '/files/x', PortalReply.json('{}'));

      await dio.get<Object?>('https://cdn.example.com/files/x');
      await dio.get<Object?>('/files/x');

      final [other, api] = backend.requests;
      expect(
        other.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('x-device-id')),
      );
      expect(api.headers['X-Device-Id'], 'device-1');
    });
  });
}
