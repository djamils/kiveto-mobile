import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiveto_mobile/shared/domain/uuid_v4.dart';

/// The installation's `X-Device-Id`: a UUID v4 generated once and kept in
/// the secure storage (one storage, no other package; the iOS keychain
/// keeps it across reinstalls, which suits the backend's device budget).
final class DeviceIdStore {
  new(this._storage, {this._random});

  static const key = 'kiveto.device.id';

  final FlutterSecureStorage _storage;
  final Random? _random;

  /// The stored id, or a new one written for next time. Never throws: when
  /// the storage fails, an id that lives in memory for this run.
  Future<String> loadOrCreate() async {
    try {
      final stored = await _storage.read(key: key);
      if (stored != null && stored.trim().isNotEmpty) return stored;
      final created = uuidV4(_random);
      await _storage.write(key: key, value: created);
      return created;
    } on Object catch (error) {
      debugPrint('DeviceIdStore: storage unavailable (${error.runtimeType})');
      return uuidV4(_random);
    }
  }
}
