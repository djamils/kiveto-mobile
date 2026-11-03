import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/device_id_store.dart';

import '../../../support/fakes.dart';

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  test('absent: a new UUID v4 is written and returned', () async {
    FlutterSecureStorage.setMockInitialValues({});

    final id = await DeviceIdStore(storage).loadOrCreate();

    expect(id, matches(_uuidV4));
    expect(await storage.read(key: DeviceIdStore.key), id);
    expect(await DeviceIdStore(storage).loadOrCreate(), id);
  });

  test('blank: replaced by a new id', () async {
    FlutterSecureStorage.setMockInitialValues({DeviceIdStore.key: '  '});

    final id = await DeviceIdStore(storage, random: Random(1)).loadOrCreate();

    expect(id, matches(_uuidV4));
    expect(await storage.read(key: DeviceIdStore.key), id);
  });

  test('present: the same id', () async {
    FlutterSecureStorage.setMockInitialValues({DeviceIdStore.key: 'device-1'});

    expect(await DeviceIdStore(storage).loadOrCreate(), 'device-1');
  });

  test('the storage throws: an id in memory, never an exception', () async {
    final id = await DeviceIdStore(
      throwingSecureStorage(),
      random: Random(3),
    ).loadOrCreate();

    expect(id, matches(_uuidV4));
  });
}
