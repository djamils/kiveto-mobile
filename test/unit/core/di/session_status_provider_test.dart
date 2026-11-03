// sessionStatusProvider: notifies on every sign-in and sign-out (a sign-in
// over a sign-in too), never on a token refresh; stops listening when
// disposed.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';

import '../../../support/fakes.dart';

void main() {
  late SessionManager session;
  late ProviderContainer container;
  late List<SessionStatus> notified;

  Future<void> start([String? tokens]) async {
    session = await memorySession(tokens == null ? null : pair(tokens));
    container = ProviderContainer(
      overrides: [sessionManagerProvider.overrideWithValue(session)],
    );
    addTearDown(container.dispose);
    notified = [];
    container.listen<SessionStatus>(
      sessionStatusProvider,
      (_, next) => notified.add(next),
    );
  }

  test('starts with the restored status', () async {
    await start('A');

    expect(container.read(sessionStatusProvider), SessionStatus.signedIn);
    expect(notified, isEmpty);
  });

  test('a sign-out, then a sign-in notify', () async {
    await start('A');

    await session.signOut();
    await session.open(pair('B'));

    expect(notified, [SessionStatus.signedOut, SessionStatus.signedIn]);
    expect(container.read(sessionStatusProvider), SessionStatus.signedIn);
  });

  test(
    'a sign-in over a signed-in session notifies (another account)',
    () async {
      await start('A');

      await session.open(pair('B'));

      expect(notified, [SessionStatus.signedIn]);
    },
  );

  test('a token refresh does not notify', () async {
    await start('A');

    await session.replaceTokens(expected: pair('A'), next: pair('B'));
    // A sign-out with nothing to end does not either.
    await session.signOut();
    await session.signOut();

    expect(notified, [SessionStatus.signedOut]);
  });

  test('disposed: the session listener is removed', () async {
    await start('A');
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);
    ProviderContainer(
        overrides: [sessionManagerProvider.overrideWithValue(session)],
      )
      ..read(sessionStatusProvider)
      ..dispose();

    // A change after the disposal reaches no listener of the disposed
    // notifier (it would fail setting its state).
    await session.open(pair('B'));

    expect(errors, isEmpty);
    expect(notified, [SessionStatus.signedIn]);
  });
}
