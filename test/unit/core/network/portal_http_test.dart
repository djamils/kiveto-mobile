// The transport of the chain on the real generated client: dev Host header,
// X-Device-Id, strict status, the two Dios.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/auth_interceptor.dart';
import 'package:kiveto_mobile/core/network/dev_host_interceptor.dart';
import 'package:kiveto_mobile/core/network/device_id_interceptor.dart';
import 'package:kiveto_mobile/core/network/portal_http.dart';
import 'package:kiveto_mobile/core/network/strict_status_interceptor.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

void main() {
  late PortalHarness harness;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
  });

  test('the chain: strict status, dev host, device id, auth', () {
    // After Dio's own ImplyContentTypeInterceptor.
    expect(harness.http.dio.interceptors.skip(1).map((i) => i.runtimeType), [
      StrictStatusInterceptor,
      DevHostInterceptor,
      DeviceIdInterceptor,
      AuthInterceptor,
    ]);
    expect(
      harness.http.bareDio.interceptors.skip(1).map((i) => i.runtimeType),
      [StrictStatusInterceptor, DevHostInterceptor, DeviceIdInterceptor],
    );
    expect(
      harness.http.bareDio.httpClientAdapter,
      same(harness.http.dio.httpClientAdapter),
    );
    expect(harness.http.server.baseUrl, 'http://10.0.2.2:81');
    expect(harness.http.server.dio, same(harness.http.dio));
    expect(
      harness.http.dio.options.connectTimeout,
      const Duration(seconds: 15),
    );
    expect(
      harness.http.dio.options.receiveTimeout,
      const Duration(seconds: 30),
    );
  });

  test('Host: portal.kiveto.local and X-Device-Id on API requests', () async {
    harness.backend.on(
      'GET',
      '$api/me',
      PortalReply.fixture('me.get.200.json'),
    );

    await AccountApi(harness.http.server).getMe();

    final request = harness.backend.requests.single;
    expect(request.uri.toString(), 'http://10.0.2.2:81$api/me');
    expect(request.headers['Host'], 'portal.kiveto.local');
    expect(request.headers['X-Device-Id'], 'device-1');
  });

  test('no Host header on another origin', () async {
    harness.backend.on('GET', '/other', PortalReply.json('{}'));

    await harness.http.dio.get<Object?>('http://example.com/other');

    expect(harness.backend.requests.single.headers, isNot(contains('Host')));
  });

  test('without hostHeader there is no host interceptor', () async {
    harness = await PortalHarness.create(
      config: ApiConfig(baseUrl: Uri.parse('https://portal.kiveto.app')),
    );
    harness.backend.on(
      'GET',
      '$api/me',
      PortalReply.fixture('me.get.200.json'),
    );

    await AccountApi(harness.http.server).getMe();

    expect(
      harness.http.dio.interceptors.whereType<DevHostInterceptor>(),
      isEmpty,
    );
    expect(harness.backend.requests.single.headers, isNot(contains('Host')));
  });

  test('an explicit X-Device-Id (requestOtp) is kept', () async {
    harness.backend.on(
      'POST',
      '$api/auth/otp/request',
      PortalReply.json('{}', status: 202),
    );

    await AuthApi(harness.http.server).requestOtp(
      body: const OtpRequest(phone: '+33612345678'),
      deviceId: 'explicit',
    );

    expect(harness.backend.requests.single.headers['X-Device-Id'], 'explicit');
  });

  test('strict status: 2xx is a success, 4xx/5xx a TonikError carrying '
      'the DioException', () async {
    harness.backend
      ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
      ..on('GET', '$api/legal/terms/current', problem('server_error', 500));

    final success = await AccountApi(harness.http.server).getMe();
    final failure = await TermsApi(harness.http.server).getCurrentTerms();

    expect(success, isA<TonikSuccess<GetMeResponse, Response<Object?>>>());
    final error = (failure as TonikError).error as DioException;
    expect(error.type, DioExceptionType.badResponse);
    expect(error.response?.statusCode, 500);
  });

  test('close closes both Dios', () async {
    final backend = FakePortalBackend();
    final http = PortalHttp.create(
      config: devConfig,
      session: await SessionManager.restore(InMemoryTokenStorage()),
      deviceId: 'device-1',
      adapter: backend,
    )..close();

    await expectLater(
      http.dio.get<Object?>('/x'),
      throwsA(isA<DioException>()),
    );
    await expectLater(
      http.bareDio.get<Object?>('/x'),
      throwsA(isA<DioException>()),
    );
    // Refused by the closed Dios: the adapter never saw them.
    expect(backend.requests, isEmpty);
  });

  test("without adapter, Dio's own, shared by both", () async {
    final http = PortalHttp.create(
      config: devConfig,
      session: await SessionManager.restore(InMemoryTokenStorage()),
      deviceId: 'device-1',
    );
    addTearDown(http.close);

    expect(http.dio.httpClientAdapter, same(http.bareDio.httpClientAdapter));
    expect(http.dio.httpClientAdapter, isNot(isA<FakePortalBackend>()));
  });
}
