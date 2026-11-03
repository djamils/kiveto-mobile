/// Where the Portal API lives, from `--dart-define-from-file`
/// (`config/env/<ENV>.json`, see `app/bootstrap/app_environment.dart`).
final class ApiConfig {
  /// [baseUrl] is an origin (`http://10.0.2.2:81`): absolute, http or https,
  /// a host, no user info, path, query or fragment ([ArgumentError]
  /// otherwise). [hostHeader] (dev only) is the `Host` the local backend's
  /// routes are bound to (`portal.kiveto.local`), which an Android emulator
  /// cannot resolve.
  new({required this.baseUrl, this.hostHeader}) {
    if (!baseUrl.hasScheme ||
        !const {'http', 'https'}.contains(baseUrl.scheme) ||
        baseUrl.host.isEmpty ||
        baseUrl.userInfo.isNotEmpty ||
        (baseUrl.path.isNotEmpty && baseUrl.path != '/') ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment) {
      throw ArgumentError.value(
        baseUrl.toString(),
        'baseUrl',
        'expected an http(s) origin such as http://10.0.2.2:81',
      );
    }
  }

  final Uri baseUrl;
  final String? hostHeader;

  /// `http://10.0.2.2:81` (no trailing slash).
  String get origin => baseUrl.origin;

  /// Whether [uri] targets the API's scheme, host and port.
  bool isApiOrigin(Uri uri) =>
      uri.scheme == baseUrl.scheme &&
      uri.host == baseUrl.host &&
      uri.port == baseUrl.port;
}
