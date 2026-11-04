import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiveto_mobile/core/di/system_clock.dart';
import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/core/network/portal_http.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';

// The presentation compares the session status without importing
// core/security/ (rule 3).
export 'package:kiveto_mobile/core/security/session_manager.dart'
    show SessionStatus;

// The core services, as plain Riverpod providers (no code generation, D7).
// The first three are read before runApp and overridden by app/bootstrap;
// the slices build their repositories in features/*/di.dart on
// portalServerProvider and apiFailureMapperProvider.

/// Overridden by `app/bootstrap` with the `--dart-define-from-file` config.
final apiConfigProvider = Provider<ApiConfig>(
  (ref) => throw UnimplementedError('apiConfigProvider: set by bootstrap'),
);

/// Overridden by `app/bootstrap` with `DeviceIdStore.loadOrCreate()`.
final deviceIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('deviceIdProvider: set by bootstrap'),
);

/// Overridden by `app/bootstrap` with `SessionManager.restore(...)`.
final sessionManagerProvider = Provider<SessionManager>(
  (ref) => throw UnimplementedError('sessionManagerProvider: set by bootstrap'),
);

/// The session status, reactive: the providers that belong to the account
/// (`GET /me`, the active clinic…) watch it and rebuild on every sign-in
/// and sign-out, a sign-in over a signed-in session included, but not on a
/// token refresh (`SessionManager.generation`).
final sessionStatusProvider =
    NotifierProvider<SessionStatusNotifier, SessionStatus>(
      SessionStatusNotifier.new,
    );

final class SessionStatusNotifier extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    final session = ref.watch(sessionManagerProvider);
    var generation = session.generation;
    void changed() {
      if (session.generation == generation) return;
      generation = session.generation;
      state = session.status;
    }

    session.addListener(changed);
    ref.onDispose(() => session.removeListener(changed));
    return session.status;
  }

  /// A sign-in over a signed-in session is another account, or the same
  /// one signed in again: notify even when the status is the same.
  @override
  bool updateShouldNotify(SessionStatus previous, SessionStatus next) => true;
}

/// The one secure storage of the app (tokens, device id). iOS: readable
/// after the first unlock, never migrated to another device (backup, Quick
/// Start). Android: the defaults, values encrypted with a Keystore key that
/// never leaves the device (a copy moved elsewhere cannot be decrypted and
/// is reset, `resetOnError`).
const secureStorage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => secureStorage,
);

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// The `Idempotency-Key`s of the request forms (a seam for the tests: one
/// key per intent, see `IntentKey`).
final idempotencyKeyFactoryProvider = Provider<IdempotencyKey Function()>(
  (ref) => IdempotencyKey.generate,
);

final apiFailureMapperProvider = Provider<ApiFailureMapper>(
  (ref) => ApiFailureMapper(clock: ref.watch(clockProvider)),
);

final portalHttpProvider = Provider<PortalHttp>((ref) {
  final http = PortalHttp.create(
    config: ref.watch(apiConfigProvider),
    session: ref.watch(sessionManagerProvider),
    deviceId: ref.watch(deviceIdProvider),
  );
  ref.onDispose(http.close);
  return http;
});

/// The generated client's server:
/// `AccountApi(ref.watch(portalServerProvider))`.
final portalServerProvider = Provider<CustomServer>(
  (ref) => ref.watch(portalHttpProvider).server,
);

final portalFileDownloaderProvider = Provider<PortalFileDownloader>(
  (ref) => PortalFileDownloader(
    ref.watch(portalHttpProvider).dio,
    ref.watch(apiConfigProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
