// Test doubles shared by the suites: a token storage in memory, a fixed
// clock, a secure storage that fails, an active clinic store in memory, and
// the real app pumped with them.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/app/bootstrap/feature_overrides.dart';
import 'package:kiveto_mobile/app/kiveto_app.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/theme/kiveto_theme.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/portal_http.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/active_clinic_store.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import 'portal_api/fake_portal_backend.dart';

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

/// An [ActiveClinicStore] in memory; [failing] makes every call throw.
final class InMemoryActiveClinicStore implements ActiveClinicStore {
  new({Map<String, String>? choices, this.failing = false})
    : choices = choices ?? {};

  /// The clinic id chosen, by account id.
  final Map<String, String> choices;
  bool failing;

  @override
  Future<String?> read(String accountId) async {
    if (failing) throw StateError('store unavailable');
    return choices[accountId];
  }

  @override
  Future<void> write(String accountId, String clinicId) async {
    if (failing) throw StateError('store unavailable');
    choices[accountId] = clinicId;
  }
}

/// The instant of the default [FixedClock] of [pumpKivetoApp]: 30 s before
/// the `resendAvailableAt` of `auth.otp.request.post.202.json`.
final testNow = DateTime.utc(2026, 11, 3, 10, 22, 40);

/// Pumps the real [KivetoApp] (theme, French localisations, router) on a
/// container with the bootstrap values overridden ([session]: signed out by
/// default) and [overrides]; goes to [initialLocation] when given. Returns
/// the container (`container.read(routerProvider)` drives the router).
///
/// The real HTTP chain (`PortalHttp`) runs on [backend] (default: a fake
/// backend without route: every call fails as a network failure), the
/// clock is [clock] (default: a [FixedClock] at [testNow]), the active
/// clinic is kept in [activeClinicStore] (default: in memory). The shell
/// seams are the features' ([featureOverrides]) unless [seams] is false
/// (a test that overrides them itself).
Future<ProviderContainer> pumpKivetoApp(
  WidgetTester tester, {
  SessionManager? session,
  List<Override> overrides = const [],
  String? initialLocation,
  FakePortalBackend? backend,
  Clock? clock,
  ActiveClinicStore? activeClinicStore,
  bool seams = true,
}) async {
  await initializeDateFormatting('fr_FR');
  final config = ApiConfig(baseUrl: Uri.parse('http://portal.test'));
  final sessionManager = session ?? await memorySession();
  final http = PortalHttp.create(
    config: config,
    session: sessionManager,
    deviceId: 'device-test',
    adapter: backend ?? FakePortalBackend(),
  );
  addTearDown(http.close);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      apiConfigProvider.overrideWithValue(config),
      deviceIdProvider.overrideWithValue('device-test'),
      sessionManagerProvider.overrideWithValue(sessionManager),
      portalHttpProvider.overrideWithValue(http),
      clockProvider.overrideWithValue(clock ?? FixedClock(testNow)),
      activeClinicStoreProvider.overrideWithValue(
        activeClinicStore ?? InMemoryActiveClinicStore(),
      ),
      if (seams) ...featureOverrides(),
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

/// Pumps [page] alone, on a phone-sized view (390 × 844, the mockup's
/// frame), in a French Material app with the Kiveto theme and a container
/// like [pumpKivetoApp]'s (the real HTTP chain on [backend], the [clock],
/// [session] signed out by default), without router: the feature pages
/// take their exits as callbacks. [prepare] runs on the container before
/// the page is built (a flow's state). Returns the container.
Future<ProviderContainer> pumpPage(
  WidgetTester tester,
  Widget page, {
  SessionManager? session,
  FakePortalBackend? backend,
  Clock? clock,
  List<Override> overrides = const [],
  void Function(ProviderContainer container)? prepare,
}) async {
  await initializeDateFormatting('fr_FR');
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = const Size(390 * 3, 844 * 3);
  addTearDown(tester.view.reset);
  final config = ApiConfig(baseUrl: Uri.parse('http://portal.test'));
  final sessionManager = session ?? await memorySession();
  final http = PortalHttp.create(
    config: config,
    session: sessionManager,
    deviceId: 'device-test',
    adapter: backend ?? FakePortalBackend(),
  );
  addTearDown(http.close);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      apiConfigProvider.overrideWithValue(config),
      deviceIdProvider.overrideWithValue('device-test'),
      sessionManagerProvider.overrideWithValue(sessionManager),
      portalHttpProvider.overrideWithValue(http),
      clockProvider.overrideWithValue(clock ?? FixedClock(testNow)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  prepare?.call(container);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: kivetoTheme(),
        locale: const Locale('fr', 'FR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: page,
      ),
    ),
  );
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

/// Pumps half a second of frames: an answer of the fake backend arrives,
/// the animations end. For a page that keeps a spinner after a success
/// (its exit leaves the page in the app; no router in [pumpPage]), where
/// `pumpAndSettle` would never settle.
Future<void> pumpBriefly(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
