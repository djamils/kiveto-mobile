import 'package:kiveto_mobile/core/network/api_config.dart';

/// The [ApiConfig] of the `--dart-define-from-file` values, passed by
/// `make start`: `config/env/<ENV>.json` on Android (`dev.json`: the local
/// backend at `10.0.2.2`, the emulator's alias for its host),
/// `config/env/<ENV>.ios.json` on iOS (`dev.ios.json`: `127.0.0.1`, the
/// simulator shares the Mac's network).
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
      'passes --dart-define-from-file=config/env/dev.json on Android '
      '(10.0.2.2 from the emulator) or config/env/dev.ios.json with '
      'PLATFORM=ios (127.0.0.1 from the simulator), both created from '
      'their .dist by `make install`.',
    );
  }
  return ApiConfig(
    baseUrl: Uri.parse(baseUrl),
    hostHeader: hostHeader.isEmpty ? null : hostHeader,
  );
}
