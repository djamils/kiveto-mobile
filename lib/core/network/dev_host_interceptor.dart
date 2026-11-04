import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';

/// Dev only (installed when `ApiConfig.hostHeader` is set): the local
/// backend's routes are bound to `portal.kiveto.local`, which neither the
/// Android emulator nor the iOS simulator resolves, so requests go to the
/// base URL (`10.0.2.2:81` from the emulator, `127.0.0.1:81` from the
/// simulator) with that `Host`, and the redirects the backend writes for
/// that host point back to the base URL.
final class DevHostInterceptor extends Interceptor {
  new(this._config);

  final ApiConfig _config;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final host = _config.hostHeader;
    if (host != null && _config.isApiOrigin(options.uri)) {
      options.headers['Host'] = host;
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _rewriteLocation(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) _rewriteLocation(response);
    handler.next(err);
  }

  /// A 3xx to `<scheme>://<hostHeader>[:port]/path?query` becomes the same
  /// path and query on the base URL; other answers are left alone.
  void _rewriteLocation(Response<dynamic> response) {
    final host = _config.hostHeader;
    final status = response.statusCode ?? 0;
    final location = response.headers['location']?.firstOrNull;
    if (host == null || status < 300 || status >= 400 || location == null) {
      return;
    }
    final target = Uri.tryParse(location);
    if (target == null || target.host.toLowerCase() != host.toLowerCase()) {
      return;
    }
    final base = _config.baseUrl;
    response.headers.set(
      'location',
      target
          .replace(scheme: base.scheme, host: base.host, port: base.port)
          .toString(),
    );
  }
}
