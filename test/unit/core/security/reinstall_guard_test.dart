// ReinstallGuard: the first launch after an iOS install clears the session
// tokens (never the device id: the guard only holds the token storage),
// then writes the marker; Android and the other platforms skip it without
// opening the preferences; every storage failure is swallowed.
// PreferencesInstallMarker on a mocked SharedPreferencesAsync.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/reinstall_guard.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fakes.dart';

final class _MockPreferences extends Mock implements SharedPreferencesAsync;

void main() {
  Future<void> guard(
    InMemoryTokenStorage tokens,
    InstallMarker marker, {
    TargetPlatform platform = TargetPlatform.iOS,
  }) =>
      ReinstallGuard(tokens: tokens, marker: marker, platform: platform).run();

  group('ReinstallGuard', () {
    test('Android and the other platforms: skipped, the marker never read, '
        'the session kept', () async {
      for (final platform in TargetPlatform.values.where(
        (platform) => platform != TargetPlatform.iOS,
      )) {
        final tokens = InMemoryTokenStorage(tokens: pair('A'));
        final marker = InMemoryInstallMarker();

        await guard(tokens, marker, platform: platform);

        expect(tokens.tokens, pair('A'), reason: '$platform');
        expect(tokens.clears, 0, reason: '$platform');
        expect(marker.reads, 0, reason: '$platform');
        expect(marker.present, isFalse, reason: '$platform');
      }
    });

    test('Android: the platform preferences are never opened', () async {
      var opened = 0;
      final tokens = InMemoryTokenStorage(tokens: pair('A'));

      await guard(
        tokens,
        PreferencesInstallMarker(() {
          opened++;
          return _MockPreferences();
        }),
        platform: TargetPlatform.android,
      );

      expect(opened, 0);
      expect(tokens.tokens, pair('A'));
    });

    test('iOS, first launch after an install: the tokens cleared once, then '
        'the marker written', () async {
      final tokens = InMemoryTokenStorage(tokens: pair('A'));
      final marker = InMemoryInstallMarker();

      await guard(tokens, marker);

      expect(tokens.tokens, isNull);
      expect(tokens.clears, 1);
      expect(marker.present, isTrue);
      expect(marker.creates, 1);
    });

    test('iOS, a later launch (marker present): the session kept', () async {
      final tokens = InMemoryTokenStorage(tokens: pair('A'));
      final marker = InMemoryInstallMarker(present: true);

      await guard(tokens, marker);

      expect(tokens.tokens, pair('A'));
      expect(tokens.clears, 0);
      expect(marker.creates, 0);
    });

    test(
      'iOS, a marker that cannot be read: nothing cleared, no throw',
      () async {
        final tokens = InMemoryTokenStorage(tokens: pair('A'));
        final marker = InMemoryInstallMarker(failingRead: true);

        await guard(tokens, marker);

        expect(tokens.tokens, pair('A'));
        expect(tokens.clears, 0);
        expect(marker.creates, 0);
      },
    );

    test('iOS, a clear that fails: no marker (the next launch retries), no '
        'throw', () async {
      final tokens = InMemoryTokenStorage(tokens: pair('A'), failing: true);
      final marker = InMemoryInstallMarker();

      await guard(tokens, marker);

      expect(marker.present, isFalse);
      expect(marker.creates, 0);

      // The next launch, with a storage that works again.
      tokens.failing = false;
      await guard(tokens, marker);

      expect(tokens.tokens, isNull);
      expect(marker.present, isTrue);
    });

    test('iOS, a marker that cannot be written: the tokens cleared, no '
        'throw', () async {
      final tokens = InMemoryTokenStorage(tokens: pair('A'));
      final marker = InMemoryInstallMarker(failingWrite: true);

      await guard(tokens, marker);

      expect(tokens.tokens, isNull);
      expect(tokens.clears, 1);
      expect(marker.creates, 1);
      expect(marker.present, isFalse);
    });

    test('iOS, preferences that cannot open: nothing cleared, no '
        'throw', () async {
      final tokens = InMemoryTokenStorage(tokens: pair('A'));

      await guard(
        tokens,
        PreferencesInstallMarker(() => throw StateError('no platform')),
      );

      expect(tokens.tokens, pair('A'));
      expect(tokens.clears, 0);
    });
  });

  group('PreferencesInstallMarker', () {
    test('one bool under kiveto.install.marker, the preferences opened '
        'once, at the first use', () async {
      final preferences = _MockPreferences();
      when(() => preferences.getBool('kiveto.install.marker'))
          .thenAnswer((_) async => null);
      when(() => preferences.setBool('kiveto.install.marker', true))
          .thenAnswer((_) async {});
      var opened = 0;
      final marker = PreferencesInstallMarker(() {
        opened++;
        return preferences;
      });

      expect(opened, 0);
      expect(await marker.exists(), isFalse);
      await marker.create();
      when(() => preferences.getBool('kiveto.install.marker'))
          .thenAnswer((_) async => true);
      expect(await marker.exists(), isTrue);

      verify(() => preferences.setBool('kiveto.install.marker', true))
          .called(1);
      expect(PreferencesInstallMarker.key, 'kiveto.install.marker');
      expect(opened, 1);
    });

    test('a stored false reads as absent', () async {
      final preferences = _MockPreferences();
      when(() => preferences.getBool('kiveto.install.marker'))
          .thenAnswer((_) async => false);

      expect(
        await PreferencesInstallMarker(() => preferences).exists(),
        isFalse,
      );
    });

    test('preferences that cannot open fail the call, not the '
        'construction', () async {
      final marker = PreferencesInstallMarker(
        () => throw StateError('no platform'),
      );

      await expectLater(marker.exists(), throwsStateError);
      await expectLater(marker.create(), throwsStateError);
    });
  });
}
