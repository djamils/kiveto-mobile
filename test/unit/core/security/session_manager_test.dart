import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';

import '../../../support/fakes.dart';

/// A storage whose read answers JSON that does not decode, through the
/// real SecureTokenStorage contract (null) — and one whose read throws.
final class _ThrowingRead implements TokenStorage {
  @override
  Future<TokenPair?> read() => Future.error(StateError('corrupt keystore'));

  @override
  Future<void> write(TokenPair tokens) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  group('restore', () {
    test('empty storage: signed out', () async {
      final session = await SessionManager.restore(InMemoryTokenStorage());

      expect(session.status, SessionStatus.signedOut);
      expect(session.tokens, isNull);
    });

    test('a stored pair: signed in with it', () async {
      final session = await SessionManager.restore(
        InMemoryTokenStorage(tokens: pair('A')),
      );

      expect(session.status, SessionStatus.signedIn);
      expect(session.tokens, pair('A'));
    });

    test('the storage throws: signed out, never an exception', () async {
      final failing = await SessionManager.restore(
        InMemoryTokenStorage(tokens: pair('A'), failing: true),
      );
      final broken = await SessionManager.restore(_ThrowingRead());

      expect(failing.status, SessionStatus.signedOut);
      expect(broken.status, SessionStatus.signedOut);
    });
  });

  group('changes', () {
    late InMemoryTokenStorage storage;
    late SessionManager session;
    late int notifications;

    setUp(() async {
      storage = InMemoryTokenStorage();
      session = await SessionManager.restore(storage);
      notifications = 0;
      session.addListener(() => notifications++);
    });

    test('open: memory and listeners at once, then the storage', () async {
      final opened = session.open(pair('A'));

      expect(session.tokens, pair('A'));
      expect(session.status, SessionStatus.signedIn);
      expect(notifications, 1);
      await opened;
      expect(storage.tokens, pair('A'));
    });

    test('the newest pair always wins', () async {
      await session.open(pair('A'));
      await session.open(pair('C'));

      expect(session.tokens, pair('C'));
      expect(storage.tokens, pair('C'));
      expect(notifications, 2);
    });

    test('signOut clears memory then storage; twice notifies once', () async {
      await session.open(pair('A'));
      await session.signOut();
      await session.signOut();

      expect(session.status, SessionStatus.signedOut);
      expect(storage.tokens, isNull);
      expect(storage.clears, 2);
      expect(notifications, 2);
    });

    test('replaceTokens is a compare-and-set on the refresh token', () async {
      await session.open(pair('A'));

      expect(
        await session.replaceTokens(expected: pair('A'), next: pair('B')),
        isTrue,
      );
      expect(session.tokens, pair('B'));
      expect(storage.tokens, pair('B'));

      expect(
        await session.replaceTokens(expected: pair('A'), next: pair('X')),
        isFalse,
      );
      expect(session.tokens, pair('B'));
    });

    test('signOutIfCurrent signs out only the expected session', () async {
      await session.open(pair('C'));

      await session.signOutIfCurrent(pair('A'));
      expect(session.tokens, pair('C'));

      await session.signOutIfCurrent(pair('C'));
      expect(session.status, SessionStatus.signedOut);
      expect(storage.tokens, isNull);
    });

    test(
      'a failing storage is swallowed: the session lives in memory',
      () async {
        storage.failing = true;

        await session.open(pair('A'));
        expect(session.tokens, pair('A'));

        await session.signOut();
        expect(session.tokens, isNull);
        expect(storage.writes, 0);
      },
    );

    test('writes reach the storage in order', () async {
      final writes = [
        session.open(pair('A')),
        session.signOut(),
        session.open(pair('B')),
      ];
      await Future.wait(writes);

      expect(storage.tokens, pair('B'));
      expect(storage.writes, 2);
      expect(storage.clears, 1);
    });
  });
}
