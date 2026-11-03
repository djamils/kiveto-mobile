// Test doubles shared by the suites: a token storage in memory, a fixed
// clock, a secure storage that fails, and the real app pumped with them.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/app/kiveto_app.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/theme/kiveto_theme.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

/// A [TokenStorage] in memory; [failing] makes every call throw, like a
/// keystore whose key is gone.
final class InMemoryTokenStorage implements TokenStorage {
  new({this.tokens, this.failing = false});

  TokenPair? tokens;
  bool failing;

  /// How many writes and clears reached the storage.
  int writes = 0;
  int clears = 0;

  @override
  Future<TokenPair?> read() async {
    _failIfAsked();
    return tokens;
  }

  @override
  Future<void> write(TokenPair tokens) async {
    _failIfAsked();
    writes++;
    this.tokens = tokens;
  }

  @override
  Future<void> clear() async {
    _failIfAsked();
    clears++;
    tokens = null;
  }

  void _failIfAsked() {
    if (failing) {
      throw PlatformException(code: 'storage', message: 'unavailable');
    }
  }
}

/// A [Clock] stopped at [instant] (UTC).
final class FixedClock implements Clock {
  new(this.instant);

  DateTime instant;

  @override
  DateTime now() => instant;
}

final class _MockSecureStorage extends Mock implements FlutterSecureStorage;

/// A [FlutterSecureStorage] whose every read, write and delete throws a
/// [PlatformException].
FlutterSecureStorage throwingSecureStorage() {
  final storage = _MockSecureStorage();
  final failure = PlatformException(code: 'keystore', message: 'unavailable');
  when(() => storage.read(key: any(named: 'key'))).thenThrow(failure);
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenThrow(failure);
  when(() => storage.delete(key: any(named: 'key'))).thenThrow(failure);
  return storage;
}

/// A pair whose tokens are [name] (`TokenPair(accessToken: 'A', refreshToken:
/// 'refresh-A')`).
TokenPair pair(String name) =>
    TokenPair(accessToken: name, refreshToken: 'refresh-$name');

/// A signed-out session in memory, or one signed in with [tokens].
Future<SessionManager> memorySession([TokenPair? tokens]) =>
    SessionManager.restore(InMemoryTokenStorage(tokens: tokens));

/// Pumps the real [KivetoApp] (theme, French localisations, router) on a
/// container with the bootstrap values overridden ([session]: signed out by
/// default) and [overrides]; goes to [initialLocation] when given. Returns
/// the container (`container.read(routerProvider)` drives the router).
Future<ProviderContainer> pumpKivetoApp(
  WidgetTester tester, {
  SessionManager? session,
  List<Override> overrides = const [],
  String? initialLocation,
}) async {
  await initializeDateFormatting('fr_FR');
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      apiConfigProvider.overrideWithValue(
        ApiConfig(baseUrl: Uri.parse('http://portal.test')),
      ),
      deviceIdProvider.overrideWithValue('device-test'),
      sessionManagerProvider.overrideWithValue(
        session ?? await memorySession(),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const KivetoApp()),
  );
  if (initialLocation != null) {
    container.read(routerProvider).go(initialLocation);
  }
  await tester.pumpAndSettle();
  return container;
}

/// Pumps [child] in a French Material app with the Kiveto theme, without
/// router or providers (the kit widget tests).
Future<void> pumpKit(WidgetTester tester, Widget child) async {
  await initializeDateFormatting('fr_FR');
  await tester.pumpWidget(
    MaterialApp(
      theme: kivetoTheme(),
      locale: const Locale('fr', 'FR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();
}
