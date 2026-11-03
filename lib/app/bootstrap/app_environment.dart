import 'package:kiveto_mobile/core/network/api_config.dart';

/// The [ApiConfig] of the `--dart-define-from-file` values
/// (`config/env/<ENV>.json`, passed by `make start`).
///
/// An empty `API_BASE_URL` is a [StateError] that names the fix; an empty
/// `API_HOST_HEADER` means no dev `Host` header.
ApiConfig apiConfigFromDefines({
  String baseUrl = const String.fromEnvironment('API_BASE_URL'),
  String hostHeader = const String.fromEnvironment('API_HOST_HEADER'),
}) {
  if (baseUrl.isEmpty) {
    throw StateError(
      'API_BASE_URL is not defined: run the app with `make start`, which '
      'passes --dart-define-from-file=config/env/dev.json '
      '(created from config/env/dev.json.dist by `make install`).',
    );
  }
  return ApiConfig(
    baseUrl: Uri.parse(baseUrl),
    hostHeader: hostHeader.isEmpty ? null : hostHeader,
  );
}
