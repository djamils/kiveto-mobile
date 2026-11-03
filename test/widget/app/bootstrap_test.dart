// bootstrap(): the stored session and device id are read before runApp.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/bootstrap/bootstrap.dart';
import 'package:kiveto_mobile/app/kiveto_app.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/security/device_id_store.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';

import '../../support/fakes.dart';

ApiConfig _config() => ApiConfig(baseUrl: Uri.parse('http://portal.test'));

void main() {
  testWidgets('no stored session: the welcome page; a device id is created', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});

    await bootstrap(readConfig: _config);
    await tester.pumpAndSettle();

    expect(
      find.text('La santé de vos animaux, avec votre clinique'),
      findsOneWidget,
    );
    expect(
      await const FlutterSecureStorage().read(key: DeviceIdStore.key),
      isNotNull,
    );
  });

  testWidgets('a stored session: the shell', (tester) async {
    FlutterSecureStorage.setMockInitialValues({
      SecureTokenStorage.key: jsonEncode(pair('A').toJson()),
      DeviceIdStore.key: 'device-1',
    });

    await bootstrap(readConfig: _config);
    await tester.pumpAndSettle();

    expect(find.text('Rendez-vous'), findsOneWidget);

    // The storage bootstrap really uses: device-only on iOS (the platform
    // mock ignores the options, so they are pinned here).
    final container = ProviderScope.containerOf(
      tester.element(find.byType(KivetoApp)),
    );
    final storage = container.read(secureStorageProvider);
    expect(storage, same(secureStorage));
    expect(
      storage.iOptions.accessibility,
      KeychainAccessibility.first_unlock_this_device,
    );

    // The shell seams are the features' (featureOverrides()).
    final overridden = [
      for (final override
          in tester.widget<ProviderScope>(find.byType(ProviderScope)).overrides)
        '$override',
    ];
    for (final seam in <Object>[
      hasConfirmedClinicProvider,
      accountInitialsProvider,
      unreadDocumentsCountProvider,
    ]) {
      expect(overridden, contains('$seam.overrideWith(...)'), reason: '$seam');
    }
  });

  test('without --dart-define: a StateError before runApp', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await expectLater(bootstrap(), throwsStateError);
  });
}
