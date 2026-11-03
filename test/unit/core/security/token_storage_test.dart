import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';

FlutterSecureStorage _storageOf(FlutterSecureStorage storage) => storage;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final full = TokenPair(
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: DateTime.utc(2026, 11, 3, 12, 15),
    refreshTokenExpiresAt: DateTime.utc(2027, 2),
  );

  group('TokenPair', () {
    test('round-trips through JSON, expiries in UTC', () {
      final json = full.toJson();

      expect(json['accessTokenExpiresAt'], '2026-11-03T12:15:00.000Z');
      expect(TokenPair.fromJson(json), full);
      expect(TokenPair.fromJson(json).hashCode, full.hashCode);
      expect(
        TokenPair.fromJson(
          const TokenPair(accessToken: 'a', refreshToken: 'r').toJson(),
        ),
        const TokenPair(accessToken: 'a', refreshToken: 'r'),
      );
    });

    test('refuses a missing or invalid field', () {
      for (final json in <Map<String, Object?>>[
        {'refreshToken': 'r'},
        {'accessToken': '', 'refreshToken': 'r'},
        {'accessToken': 'a', 'refreshToken': 3},
        {'accessToken': 'a', 'refreshToken': 'r', 'accessTokenExpiresAt': 5},
        {
          'accessToken': 'a',
          'refreshToken': 'r',
          'refreshTokenExpiresAt': 'tomorrow',
        },
      ]) {
        expect(() => TokenPair.fromJson(json), throwsFormatException);
      }
    });

    test('never shows a token', () {
      expect('$full', 'TokenPair(<redacted>)');
      expect('$full', isNot(contains('access')));
      expect(full == Object(), isFalse);
      expect(full, isNot(const TokenPair(accessToken: 'x', refreshToken: 'r')));
    });
  });

  group('SecureTokenStorage', () {
    const storage = FlutterSecureStorage();
    late SecureTokenStorage tokens;

    // Built at run time, as bootstrap does.
    setUp(() => tokens = SecureTokenStorage(_storageOf(storage)));

    test('nothing stored reads as null', () async {
      FlutterSecureStorage.setMockInitialValues({});

      expect(await tokens.read(), isNull);
    });

    test(
      'writes the pair as one JSON value, reads it back, clears it',
      () async {
        FlutterSecureStorage.setMockInitialValues({});

        await tokens.write(full);
        final stored = await storage.read(key: SecureTokenStorage.key);
        expect(jsonDecode(stored!), full.toJson());
        expect(await tokens.read(), full);

        await tokens.clear();
        expect(await storage.read(key: SecureTokenStorage.key), isNull);
      },
    );

    for (final corrupt in ['{not json', '[1]', '{"accessToken": "a"}']) {
      test('a corrupt value ($corrupt) reads as null and is deleted', () async {
        FlutterSecureStorage.setMockInitialValues({
          SecureTokenStorage.key: corrupt,
        });

        expect(await tokens.read(), isNull);
        expect(await storage.containsKey(key: SecureTokenStorage.key), isFalse);
      });
    }
  });
}
