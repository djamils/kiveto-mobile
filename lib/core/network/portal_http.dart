import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/auth_interceptor.dart';
import 'package:kiveto_mobile/core/network/dev_host_interceptor.dart';
import 'package:kiveto_mobile/core/network/device_id_interceptor.dart';
import 'package:kiveto_mobile/core/network/session_refresher.dart';
import 'package:kiveto_mobile/core/network/strict_status_interceptor.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

/// The two Dios of the Portal API, on one HTTP adapter.
///
/// [dio]: strict status → dev `Host` (when configured) → `X-Device-Id` →
/// auth. [bareDio]: the same transport without auth; it carries the token
/// refresh and the retries of the auth interceptor. The generated client
/// runs on [dio] through [server]. No logging interceptor: tokens never
/// reach a log.
final class PortalHttp {
  new _({required this.dio, required this.bareDio, required this.server});

  factory create({
    required ApiConfig config,
    required SessionManager session,
    required String deviceId,
    HttpClientAdapter? adapter,
  }) {
    BaseOptions options() => BaseOptions(
      baseUrl: config.origin,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
    List<Interceptor> transport() => [
      const StrictStatusInterceptor(),
      if (config.hostHeader != null) DevHostInterceptor(config),
      DeviceIdInterceptor(config, deviceId),
    ];

    final bareDio = Dio(options());
    if (adapter != null) bareDio.httpClientAdapter = adapter;
    bareDio.interceptors.addAll(transport());

    final refresher = SessionRefresher(
      AuthApi(
        CustomServer(
          baseUrl: config.origin,
          serverConfig: ServerConfig<Dio>.client(bareDio),
        ),
      ),
    );
    final dio = Dio(options())..httpClientAdapter = bareDio.httpClientAdapter;
    dio.interceptors
      ..addAll(transport())
      ..add(
        AuthInterceptor(
          session: session,
          refresher: refresher,
          retryDio: bareDio,
        ),
      );

    return PortalHttp._(
      dio: dio,
      bareDio: bareDio,
      server: CustomServer(
        baseUrl: config.origin,
        serverConfig: ServerConfig<Dio>.client(dio),
      ),
    );
  }

  /// The authenticated chain.
  final Dio dio;

  /// The transport without auth (refresh, retries).
  final Dio bareDio;

  /// The generated client's server, on [dio]: `AccountApi(http.server)`.
  final CustomServer server;

  /// Closes both Dios (and their shared adapter).
  void close() {
    dio.close();
    bareDio.close();
  }
}
