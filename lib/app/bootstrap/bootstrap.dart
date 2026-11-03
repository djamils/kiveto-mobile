import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kiveto_mobile/app/bootstrap/app_environment.dart';
import 'package:kiveto_mobile/app/bootstrap/asset_licenses.dart';
import 'package:kiveto_mobile/app/kiveto_app.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/security/device_id_store.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';
import 'package:material_ui/material_ui.dart';

/// Starts the app: licences, French dates, the API config of the
/// `--dart-define-from-file` values, the device id and the stored session,
/// read before `runApp` and handed to the providers.
///
/// No automatic retry of failing providers: a failure shows an
/// `ErrorView` with its retry button. [readConfig] is a seam for the tests
/// (they run without `--dart-define`).
Future<void> bootstrap({
  ApiConfig Function() readConfig = apiConfigFromDefines,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAssetLicenses();
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';

  final config = readConfig();
  const storage = secureStorage;
  final deviceId = await DeviceIdStore(storage).loadOrCreate();
  final session = await SessionManager.restore(
    const SecureTokenStorage(storage),
  );

  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        apiConfigProvider.overrideWithValue(config),
        deviceIdProvider.overrideWithValue(deviceId),
        sessionManagerProvider.overrideWithValue(session),
        secureStorageProvider.overrideWithValue(storage),
      ],
      child: const KivetoApp(),
    ),
  );
}
