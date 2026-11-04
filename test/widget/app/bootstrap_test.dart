// bootstrap(): the stored session and device id are read before runApp;
// the first launch after an iOS install clears the session first.

import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  group('after an iOS install', () {
    final stored = {
      SecureTokenStorage.key: jsonEncode(pair('A').toJson()),
      DeviceIdStore.key: 'device-1',
    };

    testWidgets(
      'the first launch (no marker): the stored session is cleared before '
      'it is restored (the welcome page), the device id kept, the marker '
      'written',
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      (tester) async {
        FlutterSecureStorage.setMockInitialValues({...stored});
        final marker = InMemoryInstallMarker();

        await bootstrap(readConfig: _config, installMarker: marker);
        await tester.pumpAndSettle();

        expect(
          find.text('La santé de vos animaux, avec votre clinique'),
          findsOneWidget,
        );
        const storage = FlutterSecureStorage();
        expect(await storage.read(key: SecureTokenStorage.key), isNull);
        expect(await storage.read(key: DeviceIdStore.key), 'device-1');
        expect(marker.present, isTrue);
      },
    );

    testWidgets(
      'a later launch (marker present): the session kept, the shell',
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      (tester) async {
        FlutterSecureStorage.setMockInitialValues({...stored});
        final marker = InMemoryInstallMarker(present: true);

        await bootstrap(readConfig: _config, installMarker: marker);
        await tester.pumpAndSettle();

        expect(find.text('Rendez-vous'), findsOneWidget);
        expect(
          await const FlutterSecureStorage().read(key: SecureTokenStorage.key),
          isNotNull,
        );
        expect(marker.creates, 0);
      },
    );
  });

  testWidgets('Android without a marker: the guard does not run, the '
      'session kept (the shell), the marker untouched', (tester) async {
    expect(defaultTargetPlatform, TargetPlatform.android);
    FlutterSecureStorage.setMockInitialValues({
      SecureTokenStorage.key: jsonEncode(pair('A').toJson()),
      DeviceIdStore.key: 'device-1',
    });
    final marker = InMemoryInstallMarker();

    await bootstrap(readConfig: _config, installMarker: marker);
    await tester.pumpAndSettle();

    expect(find.text('Rendez-vous'), findsOneWidget);
    expect(marker.reads, 0);
    expect(marker.present, isFalse);
  });

  test('without --dart-define: a StateError before runApp', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await expectLater(bootstrap(), throwsStateError);
  });
}
