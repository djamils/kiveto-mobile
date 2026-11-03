// bootstrap(): the stored session and device id are read before runApp.

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/bootstrap/bootstrap.dart';
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

    expect(find.text('Bienvenue'), findsOneWidget);
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
  });

  test('without --dart-define: a StateError before runApp', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await expectLater(bootstrap(), throwsStateError);
  });
}
