// The app boots with the bootstrap values overridden: title, French,
// DM Sans; the bootstrap pieces; the core providers.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/bootstrap/app_environment.dart';
import 'package:kiveto_mobile/app/bootstrap/asset_licenses.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/di/debug_probe.dart';
import 'package:kiveto_mobile/core/di/system_clock.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/portal_api/fake_portal_backend.dart';

final class _Bundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode('text of $key')));
}

void main() {
  testWidgets('boots signed out on the welcome page: Kiveto, French, '
      'DM Sans', (tester) async {
    await pumpKivetoApp(tester);

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Kiveto'), findsOneWidget);
    expect(tester.widget<Title>(find.byType(Title)).title, 'Kiveto');

    final context = tester.element(find.text('Bienvenue'));
    expect(Localizations.localeOf(context).languageCode, 'fr');
    expect(MaterialLocalizations.of(context).cancelButtonLabel, 'Annuler');
    final theme = Theme.of(context);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'DMSans');
    expect(theme.textTheme.headlineLarge?.fontSize, 26);
    expect(theme.textTheme.headlineLarge?.fontVariations, [
      const FontVariation.opticalSize(26),
    ]);
    expect(theme.colorScheme.primary, const Color(0xFF4338CA));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F6FA));
  });

  group('apiConfigFromDefines', () {
    test('reads the base URL and the dev Host header', () {
      final config = apiConfigFromDefines(
        baseUrl: 'http://10.0.2.2:81',
        hostHeader: 'portal.kiveto.local',
      );

      expect(config.origin, 'http://10.0.2.2:81');
      expect(config.hostHeader, 'portal.kiveto.local');
      expect(
        apiConfigFromDefines(baseUrl: 'https://portal.example').hostHeader,
        isNull,
      );
    });

    test('no base URL (no define in tests): a StateError naming make '
        'start', () {
      expect(
        apiConfigFromDefines,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('make start'),
          ),
        ),
      );
    });
  });

  test('the asset licences: DM Sans and Lucide', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerAssetLicenses(bundle: _Bundle());

    final entries = await LicenseRegistry.licenses.toList();
    final packages = entries.expand((entry) => entry.packages).toList();

    expect(packages, containsAll(['DM Sans', 'Lucide']));
  });

  group('core providers', () {
    test('the bootstrap values must be overridden', () {
      final container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);

      for (final provider in [
        apiConfigProvider,
        deviceIdProvider,
        sessionManagerProvider,
      ]) {
        expect(() => container.read(provider), throwsA(anything));
      }
    });

    test('the HTTP chain, its server, the downloader, the clock', () async {
      final container = ProviderContainer(
        overrides: [
          apiConfigProvider.overrideWithValue(
            ApiConfig(baseUrl: Uri.parse('http://portal.test')),
          ),
          deviceIdProvider.overrideWithValue('device-test'),
          sessionManagerProvider.overrideWithValue(await memorySession()),
        ],
      );
      addTearDown(container.dispose);

      final http = container.read(portalHttpProvider);
      expect(container.read(portalServerProvider), same(http.server));
      expect(container.read(portalFileDownloaderProvider), isNotNull);
      expect(container.read(secureStorageProvider), same(secureStorage));
      expect(
        secureStorage.iOptions.accessibility,
        KeychainAccessibility.first_unlock_this_device,
      );
      expect(container.read(clockProvider), isA<SystemClock>());
      expect(container.read(clockProvider).now().isUtc, isTrue);
      expect(container.read(apiFailureMapperProvider), isNotNull);
    });

    Future<ProviderContainer> probe(PortalReply reply) async {
      final backend = FakePortalBackend()
        ..on('GET', '/api/portal/v1/legal/terms/current', reply);
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          portalServerProvider.overrideWithValue(portalServer(backend)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('the debug terms probe: 200 and its version', () async {
      final container = await probe(
        PortalReply.json('{"version": "2026-10", "url": "https://x/cgu"}'),
      );

      expect(await container.read(termsProbeProvider.future), '200 · 2026-10');
    });

    test('the debug terms probe: a failure is thrown', () async {
      final container = await probe(
        PortalReply.json('{"type": "not_found", "status": 404}', status: 404),
      );
      final subscription = container.listen(termsProbeProvider, (_, _) {});
      addTearDown(subscription.close);

      await expectLater(
        container.read(termsProbeProvider.future),
        throwsA(isA<ApiFailure>()),
      );
    });
  });
}
