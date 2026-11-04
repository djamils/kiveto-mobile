import 'package:flutter/foundation.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether this installation of the app has already started once, kept
/// where an uninstall removes it.
abstract interface class InstallMarker {
  Future<bool> exists();

  Future<void> create();
}

/// [InstallMarker] in the platform preferences (`UserDefaults` on iOS,
/// which live in the app container and go with an uninstall): one bool
/// under [key].
///
/// The preferences are opened at the first use, so that an unavailable
/// platform fails that call rather than the construction, and a platform
/// that never asks (Android) never opens them.
final class PreferencesInstallMarker implements InstallMarker {
  new(this._open);

  static const key = 'kiveto.install.marker';

  final SharedPreferencesAsync Function() _open;
  late final SharedPreferencesAsync _preferences = _open();

  @override
  Future<bool> exists() async => await _preferences.getBool(key) ?? false;

  @override
  Future<void> create() async {
    await _preferences.setBool(key, true);
  }
}

/// Signs out the first launch after an iOS install: the Keychain survives
/// an uninstall, so a reinstalled app would otherwise come back with the
/// previous session. Run before the session is restored.
///
/// iOS only (the platform it is given): without the [InstallMarker], the
/// session tokens are cleared ([TokenStorage.clear]), then the marker is
/// written. The device id (another key of the same Keychain) is not
/// touched: keeping it across reinstalls suits the backend's device budget.
///
/// Never throws: a marker that cannot be read clears nothing; a clear that
/// fails writes no marker (the next launch retries); a marker that cannot
/// be written signs the user out again at the next launch. Each failure is
/// logged by its type only.
final class ReinstallGuard {
  const new({
    required this._tokens,
    required this._marker,
    required this._platform,
  });

  final TokenStorage _tokens;
  final InstallMarker _marker;
  final TargetPlatform _platform;

  Future<void> run() async {
    if (_platform != TargetPlatform.iOS) return;
    final bool installed;
    try {
      installed = await _marker.exists();
    } on Object catch (error) {
      debugPrint('ReinstallGuard: marker unreadable (${error.runtimeType})');
      return;
    }
    if (installed) return;
    try {
      await _tokens.clear();
    } on Object catch (error) {
      debugPrint('ReinstallGuard: session not cleared (${error.runtimeType})');
      return;
    }
    try {
      await _marker.create();
    } on Object catch (error) {
      debugPrint('ReinstallGuard: marker not written (${error.runtimeType})');
    }
  }
}
