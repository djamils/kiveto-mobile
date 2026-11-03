// A fake Portal API backend for tests: the generated client
// (package:kiveto_portal_api) runs on a real Dio whose HTTP adapter answers
// from routes instead of the network.
//
//   final backend = FakePortalBackend()
//     ..on('GET', '/api/portal/v1/me', PortalReply.fixture('me.get.200.json'));
//   final result = await AccountApi(portalServer(backend)).getMe();
//   // backend.requests holds what the client sent.
//
// The fixtures of test/support/fixtures/portal_api/ are real responses of
// the backend, captured on 2026-11-03 through the generator spike's
// in-process replay, byte for byte except the dev `trace` arrays, replaced
// by "[stripped]": one file per route and status
// (`<route>.<method>.<status>.json`).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

/// The folder of the contract fixtures, relative to the package root (the
/// current directory of `flutter test`).
const portalFixtures = 'test/support/fixtures/portal_api';

/// What the fake backend answers to one route.
final class PortalReply {
  /// The bytes of `test/support/fixtures/portal_api/<name>`, with the status
  /// [status] and the content type [contentType] (default: JSON for a
  /// success, problem+json for an error).
  new fixture(String name, {int status = 200, String? contentType})
    : this._(
        File('$portalFixtures/$name').readAsBytesSync(),
        status,
        contentType ?? _defaultContentType(status),
      );

  /// [body] as UTF-8, with [status] and [contentType].
  new json(String body, {int status = 200, String? contentType})
    : this._(
        utf8.encode(body),
        status,
        contentType ?? _defaultContentType(status),
      );

  new _(this.body, this.status, this.contentType);

  final List<int> body;
  final int status;
  final String contentType;

  static String _defaultContentType(int status) =>
      status < 400 ? 'application/json' : 'application/problem+json';
}

/// A request the client sent to the fake backend.
final class PortalRequest {
  const new({
    required this.method,
    required this.uri,
    required this.headers,
    required this.contentType,
    required this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, Object?> headers;
  final String? contentType;

  /// The raw bytes of the request body (empty without a body).
  final List<int> body;

  /// The path with its query, as routed: `/api/portal/v1/me?x=1`.
  String get pathWithQuery =>
      uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
}

/// An [HttpClientAdapter] answering from routes, recording every request.
///
/// An unrouted request fails with its method, its URI and the routes known;
/// Dio reports it as a [DioException] (a `TonikError` of the client).
final class FakePortalBackend implements HttpClientAdapter {
  final _routes = <String, PortalReply>{};

  /// Every request received, in order.
  final requests = <PortalRequest>[];

  /// Answers [reply] to [method] on [pathWithQuery]
  /// (`/api/portal/v1/clinics/x/appointments?scope=upcoming`).
  void on(String method, String pathWithQuery, PortalReply reply) =>
      _routes['$method $pathWithQuery'] = reply;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = <int>[];
    if (requestStream != null) {
      await requestStream.forEach(body.addAll);
    }
    final request = PortalRequest(
      method: options.method,
      uri: options.uri,
      headers: {...options.headers},
      contentType: options.contentType,
      body: body,
    );
    requests.add(request);

    final reply = _routes['${request.method} ${request.pathWithQuery}'];
    if (reply == null) {
      throw StateError(
        'FakePortalBackend: unrouted ${request.method} ${request.uri}; '
        'routes: ${_routes.keys.join(', ')}',
      );
    }
    return ResponseBody.fromBytes(
      Uint8List.fromList(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [reply.contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A server of the generated client on a new [Dio] whose adapter is
/// [backend], with [interceptors] in that order.
CustomServer portalServer(
  FakePortalBackend backend, {
  String baseUrl = 'http://portal.test',
  List<Interceptor> interceptors = const [],
}) {
  final dio = Dio()..httpClientAdapter = backend;
  dio.interceptors.addAll(interceptors);
  return CustomServer(
    baseUrl: baseUrl,
    serverConfig: ServerConfig<Dio>.client(dio),
  );
}
