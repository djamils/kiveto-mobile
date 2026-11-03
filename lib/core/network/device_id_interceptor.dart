import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';

/// `X-Device-Id` on every request to the API origin (the backend's device
/// budget signal), unless the request already names one
/// (`requestOtp(deviceId:)`); never sent to another host.
final class DeviceIdInterceptor extends Interceptor {
  const new(this._config, this._deviceId);

  static const header = 'X-Device-Id';

  final ApiConfig _config;
  final String _deviceId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final named = options.headers.keys.any(
      (name) => name.toLowerCase() == header.toLowerCase(),
    );
    if (!named && _config.isApiOrigin(options.uri)) {
      options.headers[header] = _deviceId;
    }
    handler.next(options);
  }
}
