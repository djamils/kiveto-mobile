import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';

/// Where the session's [TokenPair] survives a restart.
abstract interface class TokenStorage {
  /// The stored pair, or null when there is none (or it was unreadable).
  Future<TokenPair?> read();

  Future<void> write(TokenPair tokens);

  Future<void> clear();
}

/// The pair as one JSON value under one key of the Keychain / Android
/// Keystore: one write replaces both tokens at once.
final class SecureTokenStorage implements TokenStorage {
  const new(this._storage);

  static const key = 'kiveto.session.tokens';

  final FlutterSecureStorage _storage;

  /// A stored value that does not decode is deleted and reads as null.
  @override
  Future<TokenPair?> read() async {
    final stored = await _storage.read(key: key);
    if (stored == null) return null;
    try {
      final json = jsonDecode(stored);
      if (json is! Map<String, Object?>) {
        throw const FormatException('TokenPair: not an object');
      }
      return TokenPair.fromJson(json);
    } on FormatException {
      await _storage.delete(key: key);
      return null;
    }
  }

  @override
  Future<void> write(TokenPair tokens) =>
      _storage.write(key: key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: key);
}
