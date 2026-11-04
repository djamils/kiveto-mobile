---
title: 'iOS support, step 1 (Windows, no Mac): the iOS simulator backend address, geolocator''s « always » path, the iPad share origin, the session after an iOS reinstall, a dev invitation link for the simulator, the other iOS gaps'
type: 'feature'
created: '2026-11-04'
status: 'done'
baseline_revision: '9ab54dd8bcff46f16323bd2e3cd94cd3bcffbecd'
review_loop_iteration: 0
followup_review_recommended: false
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/CONTRIBUTING.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-app-shell.md'
warnings: ['multiple-goals', 'oversized']
deferred:
  - summary: >-
      Release and Profile builds keep the CFBundleURLTypes entry (app.kiveto.portal.dev) with an empty scheme string, since $(KIVETO_DEV_URL_SCHEME) is undefined in Release.xcconfig.
    evidence: |-
      An empty scheme cannot match a URL, so no kiveto-dev link opens a release build; whether App Store validation accepts an empty CFBundleURLSchemes item is unverified. Settled by plutil -p on the built Release Info.plist (step 2) and an App Store Connect validation (step 3); if refused, an INFOPLIST_FILE per configuration (pbxproj edit).
    location: >-
      ios/Runner/Info.plist
    severity: medium (unverified)
  - summary: >-
      The real share_plus closures of calendarSharerProvider and dataExportSharerProvider, which now pass sharePositionOrigin, run in no test.
    evidence: |-
      Every test overrides the seams (they now assert the rect received); a test of the closures needs a SharePlatform fake (share_plus_platform_interface as a dev dependency) or channel and path_provider mocks. Already tracked by the slice-4 and slice-5 « real share_plus closure » entries of deferred-work.md, updated by this branch.
    location: >-
      lib/features/scheduling/presentation/scheduling_providers.dart, lib/features/client/presentation/account_providers.dart
    severity: low
  - summary: >-
      iOS builds outside make start (flutter build ios/ipa for TestFlight and the App Store, an iOS CI job) must export BYPASS_PERMISSION_LOCATION_ALWAYS=1 once they exist.
    evidence: |-
      Only scripts/start.sh exports it (debug runs); CONTRIBUTING « iOS (macOS) » says other builds must set it; release and archive builds, the ones App Review sees, are step 3.
    location: >-
      scripts/start.sh
    severity: low
---

<intent-contract>

## Intent

**Problem:** The Flutter app was only built and walked on Android. On an iOS simulator it would call `10.0.2.2` (an Android-emulator-only alias), compile geolocator's « always » permission path, anchor the iPad share popovers nowhere, come back signed in after a reinstall (the Keychain survives an uninstall), and have no way to open screen 0 in dev (iOS opens http(s) links in an app only through universal links, step 3). Nothing here may need a Mac: step 2 builds it on the user's Mac.

**Approach:** Everything that can be built and tested on Windows: a per-platform dev env file chosen by `make start`; `BYPASS_PERMISSION_LOCATION_ALWAYS=1` for every build `make start` runs; the tapped control's global rect through both share seams; a first-run marker in `shared_preferences` that clears the session tokens (not the device id) on iOS before bootstrap reads the session; a debug-only `kiveto-dev` URL scheme through an xcconfig variable; small cross-platform fixes for the other iOS gaps (status bar, keyboard dismissal). The rest goes to the Mac checklist (hand-over note).

## Boundaries & Constraints

**Always:**
- D15 layers and the 100 % coverage of `core/{network,security,errors}`, `features/*/{domain,application,infrastructure}`, `shared/domain`, `tool/lib` (CLAUDE.md §3–4). New gated files get unit tests; presentation changes get widget tests.
- Scripts stay bash 3.2, LF, and pass `test/scripts/portability_test.sh`; new script logic is covered by `test/scripts/*_test.sh` run against a temporary project copy (never write stamps or env files in the real repository from a test).
- Android behaviour is unchanged: `config/env/dev.json` keeps working as it is; the reinstall guard never runs on Android (the emulator stays signed in as Julien after this build is installed).
- Code comments and docs in English; any new user-facing string in `lib/l10n/app_fr.arb` (none is expected).
- Material only from `package:material_ui/material_ui.dart`.

**Never:**
- No silent fallback that sends an iOS run to `10.0.2.2` (no reading `dev.json` for iOS, no rewrite of the address in Dart).
- No universal links, Associated Domains, Team ID, signing, privacy manifest, export compliance, CI job (step 3). No backend change. No new package (shared_preferences, share_plus, url_launcher, geolocator are already pinned).
- No hand edit of `ios/Runner.xcodeproj/project.pbxproj` (the URL scheme goes through `Debug.xcconfig` / `Release.xcconfig` + `Info.plist`), `contracts/`, `packages/kiveto_portal_api/`, `CLAUDE.md`, `.claude/settings.json`.
- No `AppleSettings` for the position (see Design Notes), no orientation lock, no change to the PopScope pages.
- The reinstall guard never deletes the device id (`DeviceIdStore.key`).

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| make install, fresh clone | no `config/env/*.json` | `dev.json` and `dev.ios.json` created from their `.dist` | — |
| make install, Mac of phase 2 | `dev.json` (10.0.2.2) exists, no `dev.ios.json` | `dev.json` kept, `dev.ios.json` created | — |
| make start (android) | `dev.json` | `fvm flutter run … --dart-define-from-file=config/env/dev.json` (as today) | missing → « fix: make install » (as today) |
| make start PLATFORM=ios | `dev.ios.json` (127.0.0.1:81) | `--dart-define-from-file=config/env/dev.ios.json`, `BYPASS_PERMISSION_LOCATION_ALWAYS=1` in the run's environment | missing → stops: « config/env/dev.ios.json is missing - fix: make install (creates it from config/env/dev.ios.json.dist) »; ENV≠dev → « create config/env/<ENV>.ios.json, or use ENV=dev » |
| make start PLATFORM=ios, wrong file | `dev.ios.json` holds `10.0.2.2` | stops before any build: the file points at the Android emulator's alias, the simulator reaches the Mac at 127.0.0.1; fix: `rm config/env/dev.ios.json && make install` | — |
| make start (any platform) | — | `BYPASS_PERMISSION_LOCATION_ALWAYS=1` exported for `fvm flutter run` | — |
| iPad share | tap « Ajouter à mon calendrier » (card of 4, success of 14, success of the reschedule) or « Télécharger » (export sheet) | the seam receives the file and the tapped control's global rect; the real closures pass it as `sharePositionOrigin` | failure → the existing SnackBar / sheet line |
| iOS first launch after install | no marker, tokens stored | tokens cleared, marker written, then the session is restored (signed out → welcome), device id kept | marker read fails → nothing cleared, no throw; clear fails → no marker (retried next launch); marker write fails → no throw |
| iOS later launch | marker present | tokens kept (signed in) | — |
| Android launch | any | guard skipped, preferences never opened | — |
| dev invitation link (iOS) | engine pushes `kiveto-dev://portal.kiveto.local/invitation#t=abc` (signed out or in) | invitation page (0) with token `abc`, sent in the lookup body only | — |
| release / profile iOS build | Release.xcconfig | no `kiveto-dev` scheme registered | — |
| (addendum) physical iPhone, loopback file | `make start PLATFORM=ios` picks a device that `xcrun simctl list devices` does not list, `dev.ios.json` targets `127.0.0.1` or `localhost` | stops before `flutter run`: the iPhone cannot reach the Mac at its own loopback; fix: set `API_BASE_URL` in `config/env/dev.ios.json` to `http://<LocalHostName>.local:81` (the Mac's Bonjour name from `scutil --get LocalHostName`, printed in the message) | `scutil` fails → the message says `<mac-name>`; `xcrun simctl` fails → no refusal (cannot tell) |
| (addendum) physical iPhone or simulator, Bonjour file | `dev.ios.json` targets `http://<mac-name>.local:81` | runs with it (the `Host` header unchanged) | — |
| (addendum) device selection | a plugged-in iPhone (`targetPlatform: ios`, `emulator: false`) alone, or with a booted simulator | alone: picked; with a simulator: « several », `DEVICE=<id or name>` picks the iPhone | — |
| (addendum) local network | any iOS build | `Info.plist` has `NSLocalNetworkUsageDescription` (French, one sentence) | — |

</intent-contract>

## Code Map

- `scripts/start.sh` -- `env_file=config/env/$ENV.json` (line ~25) and its missing-file `die`; the iOS-on-non-macOS refusal (`KV_OS`, from `uname -s` in `lib.sh`); `run_live fvm flutter run -d "$DEVICE_ID" --no-pub --dart-define-from-file="$env_file" …` at the end. Device picking goes through `fvm flutter devices --machine` and `fvm dart tool/devices.dart --platform …` (both stubbable via a fake `fvm`).
- `scripts/install.sh` -- lines ~39–44 copy `dev.json.dist` → `dev.json` when missing.
- `scripts/lib.sh` -- shared helpers (`die`, `ok`, `KV_OS`, `pub_get_needed` reads `.make/pub-get.stamp` and `.dart_tool/package_config.json`; missing pubspec inputs are skipped). Put the env-file helpers here so `test/scripts/lib_test.sh` tests them in a temp project (its `reset()` pattern).
- `test/scripts/support.sh` -- `stub <name> <body>`, `expect_*`, `KV_T`; `test/scripts/lib_test.sh` (temp-project pattern); `test/scripts/doctor_test.sh` (stubbed `fvm` pattern; install.sh cannot get past doctor on a fake machine — deferred-work).
- `Makefile` -- `help` text for `ENV=` / `PLATFORM=`.
- `config/env/dev.json.dist` (`http://10.0.2.2:81`, `portal.kiveto.local`); `.gitignore:46-47` ignores `/config/env/dev.json`.
- `lib/core/network/api_config.dart` (doc and `ArgumentError` text name `10.0.2.2` as « the » origin), `lib/core/network/dev_host_interceptor.dart:4-7` (« an emulator cannot resolve… `10.0.2.2:81` »), `lib/app/bootstrap/app_environment.dart:12-17` (`StateError` names `dev.json` only).
- `D:/Dev/pub-cache/hosted/pub.dev/geolocator_apple-2.4.3/darwin/geolocator_apple/Package.swift:11` -- reads `BYPASS_PERMISSION_LOCATION_ALWAYS == "1"` when the manifest is evaluated; `PermissionHandler.m:82,101` compiles out `requestAlwaysAuthorization`. The app has `NSLocationWhenInUseUsageDescription`, so runtime behaviour is unchanged.
- `lib/features/scheduling/presentation/scheduling_providers.dart:345-362` -- `calendarSharerProvider` (`Future<void> Function(PortalFile)`); callers through `shareAppointmentCalendar(context, ref, clinicId:, appointment:)` in `appointment_card.dart:23-45`: `appointments_page.dart:213` (card `onAddToCalendar: VoidCallback`, drawn by `_CalendarLink` at `appointment_card.dart:328`), `booking_confirm_page.dart:231` and `reschedule_page.dart:330` (`KivetoButton.outline(onPressed:)`). Test overrides: `appointments_page_test.dart:95`, `booking_confirm_page_test.dart:63`, `reschedule_page_test.dart:63`, `scheduling_flow_test.dart:625`.
- `lib/features/client/presentation/account_providers.dart:234-250` -- `dataExportSharerProvider`; caller `data_export_sheet.dart:83-108` (`_download(export)`), button `KivetoButton.tonal` in `_ExportRow` (`:222`, `onDownload: VoidCallback?`). Test overrides: `account_sheets_test.dart:644,690,734,911,924`.
- `D:/Dev/pub-cache/hosted/pub.dev/share_plus-13.3.1/ios/share_plus/Sources/share_plus/FPPSharePlusPlugin.m:426-442` -- on iPad, an empty origin is replaced by the view's centre (CHANGELOG 13.3.0 « Avoid exceptions on iPads with no sharePositionOrigin »): the deferred entries' « ends in the failure SnackBar » no longer holds for 13.3.1; the origin still anchors the popover to the tapped control.
- `lib/shared/presentation/tokens/kiveto_layout.dart:71` -- `kivetoBottomPadding(context, …)`, the home of context layout helpers (put the global-rect helper beside it).
- `lib/app/bootstrap/bootstrap.dart` -- reads the device id (`DeviceIdStore(storage).loadOrCreate()`), then `SessionManager.restore(const SecureTokenStorage(storage))`, before `runApp`; `readConfig` is its test seam. `lib/core/security/token_storage.dart` (`SecureTokenStorage.clear()` deletes `kiveto.session.tokens` only), `device_id_store.dart` (`kiveto.device.id`).
- `lib/features/client/infrastructure/preferences_active_clinic_store.dart` -- the `SharedPreferencesAsync Function()` opened lazily pattern; `test/unit/features/client/infrastructure/client_infrastructure_test.dart:24` mocks `SharedPreferencesAsync` with mocktail.
- `test/support/fakes.dart:32` (`InMemoryTokenStorage` with `clears`), `test/widget/app/bootstrap_test.dart` (`FlutterSecureStorage.setMockInitialValues`, `bootstrap(readConfig:)`), `test/unit/core/security/*`.
- `ios/Flutter/Debug.xcconfig`, `Release.xcconfig` (both `#include "Generated.xcconfig"` only); pbxproj: the Runner's Debug configuration uses `Debug.xcconfig`, Release and Profile use `Release.xcconfig` (lines 375, 556, 578). `ios/Runner/Info.plist` -- no `CFBundleURLTypes`; no `FlutterDeepLinkingEnabled` key (engine default YES: `FlutterSharedApplication.mm:66` of the pinned SDK).
- `D:/Dev/fvm/versions/3.47.9/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterEngine.mm:1631-1650` -- the iOS engine sends `pushRouteInformation` with `location: url.absoluteString` (scheme, host, path, fragment) after the first frame, cold (`scene:willConnectToSession:`) and warm (`openURLContexts`).
- `lib/app/routing/app_routes.dart:91-108` (`redirectFor` reads `location.path` only), `:112` `invitationTokenFrom(uri)` (reads the fragment); `lib/app/routing/app_router.dart:216-219` (`/invitation` route). go_router 18.1.2 matches on `uri.path` and keeps scheme and host (`configuration.dart:244 normalizeUri`). Tests: `test/widget/app/routing/app_router_test.dart:301-336` (invitation via `initialLocation`).
- `android/app/src/debug/AndroidManifest.xml` -- the Android counterpart (debug-only invitation intent filter).
- `lib/features/clinic_listing/presentation/clinic_listing_providers.dart:176-189` -- `LocationSettings` on iOS; `geolocator_apple-2.4.3/…/GeolocatorPlugin.m:164-176` + `GeolocationHandler.m:107-132`: a one-time position reads only `accuracy` and never allows background updates.
- `lib/features/scheduling/presentation/listing_motif_section.dart:22-38` (`callClinic`) and `booking_motif_page.dart:55` -- `tel:` through `phoneDialerProvider` (`launchUrl`); `false` or a throw → SnackBar « Impossible de lancer l'appel. ». url_launcher_ios 6.4.2 answers `false` when no app opens the URL (`URLLauncherPlugin.swift:45-47`).
- Screens with a number / phone pad: `welcome_page.dart:133` (7, `CustomScrollView`), `code_page.dart:197` (8, `ListView`, submit pinned under it), `register_page.dart:166` (9, `CustomScrollView`), `invitation_page.dart:204` (0, `CustomScrollView`), `KivetoSheet` `navigation.dart:461` (`SingleChildScrollView`: OTP of the account sheets, number fields of the pet change sheet). Kit fields `forms.dart` (`KivetoPhoneField` `TextInputType.phone`, `KivetoOtpField` / `KivetoCodeField` `TextInputType.number`).
- `lib/app/kiveto_app.dart` -- `MaterialApp.router`; no `AnnotatedRegion<SystemUiOverlayStyle>` and no `AppBar` anywhere in `lib/` (the status bar keeps the platform default, light content under the system dark mode on iOS — white on the app's white and canvas tops); `test/widget/app/kiveto_app_test.dart`.
- Orientation: no `screenOrientation` in the Android manifest and no `setPreferredOrientations` in `lib/` (Android rotates); iOS iPhone allows portrait + landscape — already consistent.

## Tasks & Acceptance

**Execution:**
- `config/env/dev.ios.json.dist` (new) -- `{"API_BASE_URL": "http://127.0.0.1:81", "API_HOST_HEADER": "portal.kiveto.local"}` -- the simulator shares the Mac's network; the dev `Host` is still needed.
- `.gitignore` -- also ignore `/config/env/dev.ios.json`.
- `scripts/lib.sh` -- `env_file_for` (`config/env/$ENV.json` for android, `config/env/$ENV.ios.json` for ios) and `create_env_files` (each `config/env/*.json.dist` copied to its `.json` when missing, else kept; one `ok` line each) -- one rule for start and install, testable in a temp project.
- `scripts/start.sh` -- use `env_file_for`; missing-file messages as in the matrix; on iOS refuse an env file containing `10.0.2.2` (message in the matrix); `export BYPASS_PERMISSION_LOCATION_ALWAYS=1` before `fvm flutter run`, with a comment (read by geolocator_apple's `Package.swift` when Xcode resolves the package; Android ignores it); header comment updated.
- `scripts/install.sh` -- `create_env_files` instead of the dev.json block; header comment.
- `Makefile` -- help lines for `ENV=` (`config/env/<ENV>.json`, `<ENV>.ios.json` with `PLATFORM=ios`).
- `test/scripts/lib_test.sh` -- `env_file_for` per platform/ENV; `create_env_files` creates both, keeps an existing `dev.json` (10.0.2.2) and creates only the missing `dev.ios.json`.
- `test/scripts/start_sh_test.sh` (new) -- `scripts/start.sh` run in a temp project copy (`scripts/lib.sh`, `scripts/start.sh`, `.fvmrc`, `config/env/*`, a pub-get stamp + `.dart_tool/package_config.json` so no pub get runs) with a stub `fvm` (version 4.3.2, `api list` with the pinned Flutter set up, `flutter devices`, `dart tool/devices.dart` printing one id, `flutter run` logging its arguments and `$BYPASS_PERMISSION_LOCATION_ALWAYS`) and, for iOS, a stub `uname` printing `Darwin`: android → `dev.json` + bypass `1`; ios → `dev.ios.json` + bypass `1`; ios without `dev.ios.json` → exit 1, the `make install` fix, no `flutter run`; ios with `10.0.2.2` → exit 1, no `flutter run`; ENV=staging ios missing → its message.
- `lib/core/network/api_config.dart`, `dev_host_interceptor.dart`, `lib/app/bootstrap/app_environment.dart` -- comments and the `StateError` text name both dev addresses (`10.0.2.2` from the Android emulator, `127.0.0.1` from the iOS simulator; `dev.json` / `dev.ios.json`).
- `lib/shared/presentation/tokens/kiveto_layout.dart` -- `Rect globalRectOf(BuildContext context)`: the global rect of the context's laid-out render box (`Rect.zero` without one).
- `lib/features/scheduling/presentation/scheduling_providers.dart` -- `calendarSharerProvider` becomes `Future<void> Function(PortalFile file, Rect origin)`, passing `sharePositionOrigin: origin`; doc updated (iPad popover anchor).
- `lib/features/scheduling/presentation/appointment_card.dart` -- `shareAppointmentCalendar(…, required Rect origin)`; `AppointmentCard.onAddToCalendar` becomes `ValueChanged<Rect>`; `_CalendarLink` reports its own `globalRectOf(context)` at tap time.
- `lib/features/scheduling/presentation/{appointments_page,booking_confirm_page,reschedule_page}.dart` -- pass the rect: the card's, and for the two `KivetoButton.outline` a `Builder` around the button whose context gives the button's rect.
- `lib/features/client/presentation/account_providers.dart` + `data_export_sheet.dart` -- `dataExportSharerProvider` takes `(PortalFile, Rect origin)`; `_ExportRow.onDownload` becomes `ValueChanged<Rect>?`, the « Télécharger » button wrapped in a `Builder`; `_download(export, origin)`.
- Tests (scheduling, client) -- every override takes the new signature; one test per call site (card of 4, success of 14, success of the reschedule, export row) asserts the rect received equals `tester.getRect` of the tapped control (the `KivetoButton`, or the calendar link's `InkWell`), and the file as before.
- `lib/core/security/reinstall_guard.dart` (new, gated) -- `InstallMarker` (interface: `exists()`, `create()`), `PreferencesInstallMarker(SharedPreferencesAsync Function() open)` (key `kiveto.install.marker`, bool, opened lazily), `ReinstallGuard({required TokenStorage tokens, required InstallMarker marker, required TargetPlatform platform})` with `run()`: iOS only; marker present → nothing; else `tokens.clear()` then `marker.create()`; every storage error caught and logged by type (`debugPrint`), never thrown; never touches the device id.
- `lib/app/bootstrap/bootstrap.dart` -- run `ReinstallGuard(..., platform: defaultTargetPlatform)` after the device id and before `SessionManager.restore`, on the same `SecureTokenStorage`; new seam `InstallMarker? installMarker` (default `PreferencesInstallMarker(SharedPreferencesAsync.new)`).
- `test/unit/core/security/reinstall_guard_test.dart` (new) -- the matrix rows (android skipped and marker never opened; iOS no marker → cleared once + marker; marker present → kept; read/clear/create failures; `PreferencesInstallMarker` on a mocktail `SharedPreferencesAsync`); `test/support/fakes.dart` -- `InMemoryInstallMarker` (optionally failing).
- `test/widget/app/bootstrap_test.dart` -- with `debugDefaultTargetPlatformOverride = TargetPlatform.iOS` (reset in `tearDown`/`addTearDown`): stored tokens + no marker → welcome page, tokens deleted, `DeviceIdStore.key` kept, marker set; marker present → the shell; android with no marker → the shell and the marker untouched.
- `ios/Flutter/Debug.xcconfig` -- `KIVETO_DEV_URL_SCHEME = kiveto-dev` with a comment (mirrors `android/app/src/debug/AndroidManifest.xml`); `ios/Flutter/Release.xcconfig` -- a comment saying release and profile register no dev scheme (the variable stays undefined).
- `ios/Runner/Info.plist` -- `CFBundleURLTypes`: one entry, `CFBundleURLName` `app.kiveto.portal.dev`, `CFBundleURLSchemes` [`$(KIVETO_DEV_URL_SCHEME)`].
- `test/widget/app/routing/app_router_test.dart` -- signed out and signed in: the engine's `pushRouteInformation` (`SystemChannels.navigation`, `location: 'kiveto-dev://portal.kiveto.local/invitation#t=abc'`) → `InvitationPage`, lookup body `{"token":"abc"}`, token never shown.
- `test/integration/ios_project_test.dart` (new) -- reads the iOS project files: `Info.plist` declares the URL type with `$(KIVETO_DEV_URL_SCHEME)` and keeps `NSLocationWhenInUseUsageDescription` without any `NSLocationAlways*` key; `Debug.xcconfig` sets `KIVETO_DEV_URL_SCHEME = kiveto-dev`; `Release.xcconfig` does not set it; the pbxproj's Runner configurations keep Debug → `Debug.xcconfig`, Release/Profile → `Release.xcconfig` (reads only).
- `lib/app/kiveto_app.dart` -- `MaterialApp.router(builder:)` wraps the app in `AnnotatedRegion<SystemUiOverlayStyle>` with dark status-bar content only (`statusBarBrightness: Brightness.light`, `statusBarIconBrightness: Brightness.dark`; navigation-bar fields left null) -- every screen's top is white or canvas; test in `kiveto_app_test.dart` (`SystemChrome.latestStyle`).
- `welcome_page.dart`, `code_page.dart`, `register_page.dart`, `invitation_page.dart` (main view), `KivetoSheet` -- `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` -- iOS phone and number pads have no return key; a drag now closes them. Widget test: the focused phone field of 7 loses focus after a drag (iOS platform override, a simulated keyboard inset).
- `clinic_listing_providers.dart` -- comment only: why iOS keeps plain `LocationSettings`.
- `CONTRIBUTING.md` -- §0 row 13 `feature/ios-support` (and 14+ « Later work »); §5 `make install` line, `ENV=` option; a new « iOS (macOS) » paragraph: `dev.ios.json` (127.0.0.1, a physical iPhone needs the Mac's LAN address there), the 10.0.2.2 refusal, `BYPASS_PERMISSION_LOCATION_ALWAYS=1` for any other iOS build (Xcode, `flutter build ios`, CI) and SPM's possible cached resolution, `xcrun simctl openurl booted "kiveto-dev://portal.kiveto.local/invitation#t=<token>"`, the session cleared on the first launch after an iOS install. `README.md` -- the `make install` line. `architecture.md` -- dated update line, §6 layout (`dev.ios.json.dist`), §7 `make install` / `make start` rows and the « Local backend » paragraph.
- `_bmad-output/implementation-artifacts/deferred-work.md` -- close (with `resolved:`) the reinstall entry (phase 5), both iPad entries (slices 4 and 5; note that share_plus 13.3.0+ already centres the popover), the `BYPASS_PERMISSION_LOCATION_ALWAYS` entry (slice 7); `update:` the « Build and run phase 5 on iOS » and the two « real share_plus closure » entries.

**Execution (addendum, orchestrator 2026-11-04: the user's own iPhone, plugged into the Mac, installed by Xcode with a free Apple account, reaching the Mac's backend over Wi-Fi):**
- `scripts/start.sh` -- after the device is chosen, on iOS: when `$env_file` targets `127.0.0.1` or `localhost` (whole host) and `xcrun simctl list devices` succeeds without listing `($DEVICE_ID)`, stop with the matrix message (the Mac's `scutil --get LocalHostName` in the suggested URL, `<mac-name>` when it fails); a failing `xcrun simctl` never refuses. Comment: a physical iPhone's 127.0.0.1 is itself.
- `test/scripts/start_sh_test.sh` -- stub `xcrun` (its `simctl list devices` output read from a file per case) and `scutil` in the Darwin stub folder: simulator + loopback runs; physical + loopback stops with `http://<stubbed name>.local:81` and no `flutter run`; physical + `http://<name>.local:81` runs; `scutil` failing → `<mac-name>`; `xcrun` failing → runs.
- `test/tool/devices_test.dart` + a fixture `test/tool/fixtures/devices_iphone_and_simulator.json` (a physical iPhone: `targetPlatform` `ios`, `emulator` false, its UDID-style id and name; plus a booted simulator) -- `--platform ios` lists both (exit 3); `--device <the iPhone's name>` and `--device <its id>` print its id; the iPhone alone is picked (exit 0). The picker's logic does not change.
- `ios/Runner/Info.plist` -- `NSLocalNetworkUsageDescription`: « Kiveto utilise le réseau local pour joindre le serveur de développement. », in every configuration (Design Notes); `test/integration/ios_project_test.dart` asserts it.
- `config/env/dev.ios.json.dist` -- unchanged (simulator default `127.0.0.1`).
- `CONTRIBUTING.md` « iOS (macOS) » -- replace the « not set up yet » physical-iPhone text: a plugged-in iPhone with a free Apple account (personal team picked in Xcode › Runner › Signing & Capabilities, never committed: `DEVELOPMENT_TEAM` lands in `project.pbxproj`, restore it before any commit), Developer Mode on the iPhone, the developer app trusted, the install expiring after 7 days; the address: `API_BASE_URL` in the git-ignored `config/env/dev.ios.json` set to `http://<mac-name>.local:81` (Bonjour, stable across DHCP; `scutil --get LocalHostName`; the simulator accepts it too), the `Host` header unchanged, the backend's compose publishes `81:80` on every interface, the macOS firewall may ask once, iOS asks the local network permission at the first request; `make start` refuses a loopback file for a physical iPhone; `DEVICE=<id or name>` when a simulator also runs.

**Acceptance Criteria:**
- Given a Mac with the phase-2 `dev.json`, when `git pull && make install && make start PLATFORM=ios` run, then `flutter run` gets `config/env/dev.ios.json` (127.0.0.1:81, `portal.kiveto.local`) and `BYPASS_PERMISSION_LOCATION_ALWAYS=1` without any hand edit, and `make start` on Android still passes `config/env/dev.json`.
- Given this branch installed on the Android emulator signed in as Julien, when the app starts, then it is still signed in (the guard does not run on Android).
- Given `make ci`, when it runs on the branch, then format, analyze, architecture, tests, coverage gate (100 % on the gated files, `reinstall_guard.dart` included), plain-bash checks (the new script tests included) and api-check pass.

## Spec Change Log

### 2026-11-04 — Orchestrator addendum: the user's physical iPhone
- Trigger: the orchestrator's brief addendum (not a review finding): the user will also run the app on a physical iPhone plugged into the Mac, installed by Xcode with a free Apple account, reaching the Mac's backend over Wi-Fi.
- Amended: the matrix (four « (addendum) » rows), the « Execution (addendum) » tasks, the Design Notes paragraph « Physical iPhone (addendum) ». The step-3 boundary is unchanged for what the repository holds: no signing setting, Team ID or `DEVELOPMENT_TEAM` is committed; the free-account signing is the user's local Xcode action, documented.
- Known-bad state avoided: a physical iPhone running with the simulator's `127.0.0.1` (its own loopback) and failing every request without a hint; no purpose string for iOS's local network prompt.
- KEEP: everything built and reviewed before (env files per platform, the 10.0.2.2 refusal on the whole address, the bypass variable, the share origins, the reinstall guard, the dev scheme, the status bar, the drag-to-close sites and their tests, the review patches).
- Not implemented, a decision for the user: a free personal team may register the bundle id `app.kiveto.portal` for itself while the user plans the paid program; a separate dev bundle id for free installs (e.g. `app.kiveto.portal.dev`) is an option (hand-over note).

## Review Triage Log

### 2026-11-04 — Review pass
- verdicts: 39 findings — high 0, medium 1, low 30, false 4, maybe-false 4
- findings:
  - `[maybe-false]` `[defer]` (blind) Release and Profile still ship the URL type with an empty scheme; nothing checks the built plist — an empty scheme matches no URL; App Store acceptance unverified: settled by `plutil -p` on the Release build (step 2) and validation (step 3); frontmatter `deferred`, deferred-work.md.
  - `[low]` `[patch]` (blind) the bypass variable only works under Swift Package Manager (the podspec ignores it) — CONTRIBUTING says it relies on SPM (Flutter's default since 3.44, no Podfile), how to check it on the Mac, and the CocoaPods route.
  - `[low]` `[defer]` (blind) no release or CI build path sets the variable — the intent asks for `make start` plus documentation; release, archive and CI builds do not exist yet (step 3): recorded for them in frontmatter `deferred` and deferred-work.md.
  - `[medium]` `[patch]` (blind) screens 15 and 17 (multiline fields, no dismiss key on iOS) never close the keyboard — FlowScaffold and the renewal page's scroll view get `onDrag` and always-scrollable physics; iOS drag tests added.
  - `[low]` `[patch]` (blind) Android behaviour changed (status bar, drag) without an Android walk recorded — the emulator walk of this branch checks it; the CONTRIBUTING row records it.
  - `[low]` `[patch]` (blind) the cleared session stays live on the server — documented in the deferred-work resolution (as with any uninstall, both platforms; expires after 90 days of inactivity); a logout before `runApp` would need the network at boot.
  - `[low]` `[patch]` (blind) the physical-iPhone instructions skip signing, the Local Network prompt and the backend's LAN interface — CONTRIBUTING lists them (signing is step 3).
  - `[low]` `[patch]` (blind) the simctl deep-link result is stated as fact — CONTRIBUTING marks it to confirm on the Mac, cold and warm start (grouped with the intent auditor's engine-side note).
  - `[low]` `[patch]` (blind) `.gitignore` lists two env files while `create_env_files` copies every `.dist` — `/config/env/*.json`.
  - `[low]` `[patch]` (blind) `start_sh_test.sh` is added as 100644 — committed with `--chmod=+x` (100755 like the others).
  - `[low]` `[patch]` (blind) the non-dev branch of the 10.0.2.2 refusal has no test — a `staging.ios.json` case added.
  - `[low]` `[patch]` (blind) `ios_project_test.dart` is undocumented in the integration suite — CONTRIBUTING §7's Integration row names it.
  - `[low]` `[patch]` (blind) architecture.md omits the reinstall guard and the marker in the shared_preferences row — both added.
  - `[low]` `[patch]` (blind) `InMemoryInstallMarker` cannot show a failing write was attempted — the attempt is counted; the test asserts one.
  - `[false]` `[reject]` (blind) the spec is not in the diff — it is the claims file of this review and is committed with the branch (finalize).
  - `[low]` `[patch]` (blind) the launch screen keeps the default (light under dark mode) status bar until Flutter's first frame — `UIStatusBarStyle` = `UIStatusBarStyleDarkContent` in Info.plist, pinned by `ios_project_test.dart`.
  - `[low]` `[patch]` (edge) the 10.0.2.2 refusal matches substrings (a LAN 10.0.2.23) — whole-address match; an accepted 10.0.2.23 case added.
  - `[low]` `[reject]` (edge) a physical iPhone with 127.0.0.1 gets no hint — physical devices need signing (step 3); a device-kind guard adds branches; CONTRIBUTING says to edit the address.
  - `[low]` `[patch]` (edge) SPM disabled makes the variable inert — grouped with the SPM documentation row.
  - `[low]` `[patch]` (edge) `.gitignore` and future `.dist` files — grouped with the `.gitignore` row.
  - `[low]` `[reject]` (edge) the rect is taken at tap and used after the download — the brief asks for the tapped control's rect; a moved control during the wait is rare and the fix adds a callback parameter.
  - `[low]` `[patch]` (edge) KivetoSheet's `onDrag` does nothing when the sheet fits above the keyboard (SingleChildScrollView without always-scrollable physics) — verified in the SDK (`single_child_scroll_view.dart`: no default physics; `scroll_view.dart:140-147` adds it for ScrollView only); when it fits, all its content is above the keyboard; the comment now says so (always-scrollable physics would take the sheet's swipe-down); a test with tall content added.
  - `[maybe-false]` `[defer]` (edge) Info.plist ships the empty-scheme entry — grouped with the first row.
  - `[low]` `[patch]` (verification) drag-to-close tested on the welcome page only — iOS drag tests on 8, 9, 0, a FlowScaffold page, 17 and a tall KivetoSheet.
  - `[low]` `[defer]` (verification) the real share closures never check `sharePositionOrigin` — tracked by the slice-4 and slice-5 entries (updated); needs a SharePlatform fake; frontmatter `deferred`.
  - `[low]` `[patch]` (verification) the staging 10.0.2.2 fix message never runs — grouped with the blind row.
  - `[low]` `[patch]` (verification) nothing fails if `install.sh` stops calling `create_env_files` — a static case in `lib_test.sh` (the success path of `install.sh` cannot run on a fake machine, an existing deferred entry).
  - `[maybe-false]` `[defer]` (verification) Release carries the URL-type entry — grouped with the first row.
  - `[low]` `[patch]` (verification) the new test file mode — grouped with the blind row.
  - `[low]` `[reject]` (intent) the 10.0.2.2 guard lives in `make start` only (an Xcode or hand-typed `flutter run` passes whatever file it names) — the intent's requirement is the `make start` path; no silent rewrite exists anywhere.
  - `[low]` `[reject]` (intent) the « always » path is closed although the compiled binary is unverified — the intent asks to set it, document it and close the entry; the binary check is on the Mac checklist.
  - `[low]` `[defer]` (intent) the iPad entries close on a different rationale; the real closures are untested — the rationale is recorded (share_plus 13.3.0+ centres the popover); the closures are the deferred row above.
  - `[low]` `[patch]` (intent) Android « still signed in » is only a widget test so far — grouped with the Android walk row.
  - `[maybe-false]` `[defer]` (intent) a release build carries a dev URL type (reading 5b) — grouped with the first row.
  - `[low]` `[patch]` (intent) the router test drives the framework side only — grouped with the simctl documentation row; cold and warm starts on the Mac checklist.
  - `[low]` `[patch]` (intent) drag dismissal tested on 7 only — grouped with the verification row.
  - `[false]` `[reject]` (intent) the iOS swipe on screen 0 is disabled while Android's back takes the page's exit — screen 0 is always reached with `go` (a link, a pasted link), so no route lies beneath it to swipe back to on iOS; its own controls are the way out on both platforms.
  - `[false]` `[reject]` (intent) the status bar and drag changes touch Android — deliberate cross-platform fixes (Design Notes); the spec's Android boundary names `dev.json` and the guard; the walk checks the icons.
  - `[false]` `[reject]` (intent) commits, the emulator walk and the hand-over note are missing — they follow the review in this run.

## Design Notes

**Env file per platform (item 1).** Simplest rule that meets « no hand edit » and « no silent fallback »: Android keeps `config/env/<ENV>.json`, iOS reads `config/env/<ENV>.ios.json`, both created from committed `.dist` files by `make install`, which never overwrites. A Mac that has the phase-2 `dev.json` gets the missing `dev.ios.json` on its next `make install`; before that, `make start PLATFORM=ios` stops with the fix. Rejected: rewriting `10.0.2.2` in Dart (a silent rewrite), extra keys in `dev.json` (the existing file would need a hand edit), two layered `--dart-define-from-file` (more moving parts). `127.0.0.1` is the simulator's view of the Mac; a physical iPhone needs the Mac's LAN address in `dev.ios.json` (documented, not automated). dart:io sockets are not subject to App Transport Security, so plain http to the local backend needs no `NSAppTransportSecurity` entry (to confirm on the Mac).

**Reinstall guard (item 4).** In `core/security` (the session lifecycle is a client-side technical policy, next to `SessionManager`), gated at 100 %. The platform is an input (`TargetPlatform`), so both platforms are unit-tested; bootstrap passes `defaultTargetPlatform`. UserDefaults (shared_preferences on iOS) live in the app container and go with an uninstall; the Keychain does not. Order: clear, then mark (the brief); a failed clear leaves no marker so the next launch retries; a failed marker write signs the user out again next launch (rare; better than keeping a reinstalled session). Existing iOS installs (none signed in so far) are signed out once.

**Dev URL scheme (item 5).** `$(KIVETO_DEV_URL_SCHEME)` in `Info.plist`, defined in `Debug.xcconfig` only: Release and Profile (both on `Release.xcconfig`) expand it to an empty string, which registers no scheme. No pbxproj edit. The router needs no code change: the engine hands `kiveto-dev://portal.kiveto.local/invitation#t=…` whole, go_router matches `uri.path`, `invitationTokenFrom` reads the fragment, `redirectFor` reads the path — the test pins it. To confirm on the Mac: the built Release `Info.plist` (`plutil -p`) and App Store validation with an empty scheme string (step 3; if refused, an `INFOPLIST_FILE` per configuration).

**Share origin (item 3).** The rect is the tapped control's global rect taken at tap time (`globalRectOf` on the control's own context: `_CalendarLink`, or a `Builder` around a `KivetoButton`), passed as a required positional argument of the seams so no call site can forget it.

**Other iOS gaps (item 6).** Position: geolocator_apple's one-time position reads only `accuracy` and never allows background updates, so `AppleSettings` (whose `allowBackgroundLocationUpdates` defaults to true, for streams) adds nothing. `tel:` on a simulator: `launchUrl` answers false → the existing SnackBar. Swipe-back: `PopScope(canPop: false)` disables the iOS back swipe on those routes (the pages keep their own controls), the pushed booking steps swipe back like the Android back. Orientation: Android does not lock it, iOS allows landscape on iPhone: consistent, no change. Fixed here: the status bar (no `AppBar` sets it, so iOS's default turns it white under the system dark mode, unreadable on the app's light tops; Android's `values-night` theme does the same) and the keyboard (iOS phone / number pads have no return key: a drag on the page or sheet now closes them; screen 8's submit stays pinned above the keyboard and the OTP submits itself).

**Physical iPhone (addendum).** The simulator default stays `127.0.0.1`; a per-machine address goes in the git-ignored `dev.ios.json` (one key). The Mac's Bonjour name (`http://<LocalHostName>.local:81`) survives DHCP changes and works from the simulator too. `make start` tells a physical device from a simulator by asking `xcrun simctl list devices` whether it lists the picked id (exact, no id-format heuristic, no change to the Dart picker); unknown (simctl failing) never refuses. `NSLocalNetworkUsageDescription` stays in every configuration: a debug-only key would need a pbxproj edit or `GENERATE_INFOPLIST_FILE` with `INFOPLIST_KEY_*` settings, neither verifiable without a Mac, and an `$(VAR)` value would leave an empty purpose string in release (App Review may treat it as missing); the key itself asks nothing — iOS prompts only when the app touches the local network, which a release build talking to a public host never does. Whether resolving a `.local` name also needs `NSBonjourServices` is a Mac check (hostname resolution is not service browsing; if `.local` fails on the iPhone, the Mac's IP works).

## Verification

**Commands:**
- `make test-scripts` -- expected: `lib_test.sh` and `start_sh_test.sh` cases pass, portability clean.
- `make ci` -- expected: `make ci passed`.

**Manual checks (if no CLI):**
- Android emulator (`make start RUN_ARGS=--no-resident`): still signed in as Julien; the adb invitation deep link opens screen 0 (`demo-portal-invitation-roussel-pending-0001`); « Ajouter à mon calendrier » opens the share sheet; the status bar icons stay dark.

## Auto Run Result

Status: done

**Summary.** The app is ready for iOS as far as Windows can take it: a per-platform dev env file (`config/env/dev.ios.json`, `127.0.0.1:81` for the simulator; `make start PLATFORM=ios` refuses a missing file, a `10.0.2.2` one, and a loopback one for a physical iPhone with its `http://<mac-name>.local:81` fix); `BYPASS_PERMISSION_LOCATION_ALWAYS=1` for every `make start` build; the tapped control's rect as the iPad share popover's anchor (calendar ×3, export); `ReinstallGuard` (core/security) clearing the session tokens on the first iOS launch after an install, before the session is read, the device id kept; a debug-only `kiveto-dev` URL scheme (xcconfig + Info.plist, no pbxproj edit) opening screen 0; dark status-bar content (app and launch screen), drag-to-close on the screens and sheets with phone, number or multiline keyboards, `NSLocalNetworkUsageDescription`; the user's physical iPhone documented (free Apple account).

**Files changed** — scripts: `scripts/{lib,start,install}.sh` (env files per platform, refusals, the bypass), `Makefile` (help), `.gitignore` (`/config/env/*.json`), `config/env/dev.ios.json.dist` (new). lib: `core/security/reinstall_guard.dart` (new), `app/bootstrap/{bootstrap,app_environment}.dart`, `app/kiveto_app.dart` (status bar), `core/network/{api_config,dev_host_interceptor}.dart` (comments), `shared/presentation/tokens/kiveto_layout.dart` (`globalRectOf`), `shared/presentation/kit/navigation.dart` (`KivetoSheet`), `features/scheduling/presentation/{scheduling_providers,appointment_card,appointments_page,booking_confirm_page,reschedule_page,booking_layout}.dart`, `features/client/presentation/{account_providers,data_export_sheet}.dart`, `features/identity_access/presentation/{welcome,code,register,invitation}_page.dart`, `features/document/presentation/renewal_page.dart`, `features/clinic_listing/presentation/clinic_listing_providers.dart` (comment). iOS: `ios/Flutter/{Debug,Release}.xcconfig`, `ios/Runner/Info.plist`. Tests: `test/scripts/{start_sh_test (new),lib_test}.sh`, `test/tool/devices_test.dart` + fixture, `test/integration/ios_project_test.dart` (new), `test/unit/core/security/reinstall_guard_test.dart` (new), `test/support/{fakes,keyboard (new)}.dart`, widget tests of bootstrap, the app, the router, 7, 8, 9, 0, 15, 17, `KivetoSheet`, `globalRectOf`, the four share call sites. Docs: CONTRIBUTING (§0 row 13, §5 « iOS (macOS) », §7), README, architecture.md, deferred-work.md.

**Review.** 39 findings (high 0, medium 1, low 30, false 4, maybe-false 4). Patched (entry verdicts: medium 1, low 15 entries): drag-to-close on 15 and 17 (medium); the whole-address 10.0.2.2 match; the staging refusal test; a static check of `install.sh`; `/config/env/*.json`; the `KivetoSheet` comment; drag tests on 8, 9, 0, 15, 17 and a tall sheet; the install-marker fake; `UIStatusBarStyle` for the launch screen; the SPM, simctl and physical-iPhone docs; the integration-suite doc; architecture.md; the server-side session limit; the Android walk recorded; the test file mode. Deferred (frontmatter, deferred-work.md): the empty release scheme (maybe-false, medium unverified), the untested real share closures (tracked), the bypass for future release and CI builds. Rejected: the stale rect after the download wait (rare; a callback parameter), a physical-iPhone guard before the addendum (then built by the addendum), the `make start`-only 10.0.2.2 guard (the intent's surface), the « always » entry closed before the Mac build (the intent closes it; Mac checklist), the spec not in the diff (claims file, committed), screen 0's iOS swipe (no route beneath it), the Android-visible fixes (deliberate), the process items (done after the review).

**Orchestrator addendum** (after the review, Spec Change Log): the physical iPhone — the loopback refusal for a device `xcrun simctl` does not list, the device-picker tests with a plugged-in iPhone, `NSLocalNetworkUsageDescription` in every configuration (reason in Design Notes), CONTRIBUTING. Not reviewed by this pass: the branch's mandatory `bmad-code-review` covers it.

**Follow-up review recommended: false** — one medium patched entry (the drag-to-close of 15 and 17, now tested), no high; the addendum's unreviewed code goes through `bmad-code-review` next.

**Verification.** `make ci` green on the patched tree with the addendum (4 min 33 s; 111 gated files at 100 %, `start_sh_test.sh` 41 cases, `lib_test.sh` 32). Android emulator (`make start RUN_ARGS=--no-resident`, 1 min 17 s with a 64 s Gradle build): still signed in as Julien (Paris) after the install, the adb invitation link opened screen 0 with Roussel's invitation (stopped before « Activer mon espace »), its number pad closed by a drag (`mInputShown=false`), « Ajouter à mon calendrier » opened the share sheet (`rendez-vous-2026-11-09.ics`), dark status-bar icons; screenshots in the notes folder's `shots-ios-support/`. Not verified: anything on iOS (no Mac) — the checklist is in the hand-over note `notes-ios-support.md`.

**Residual risks.** Every iOS claim rests on source reading (engine, share_plus, geolocator_apple, Flutter scroll physics) and Windows tests: SPM's evaluation of the bypass variable and its cache, ATS not applying to dart:io, the empty release scheme, `.local` resolution on the iPhone, the launch status bar, PDFium's XCFramework, DM Sans' `opsz` on iOS.

### Review Findings

Code review (bmad-code-review) of the branch against `master` (`9ab54dd`), head `85bfa3c`: 4 layers (blind hunter, edge-case hunter, verification gap, acceptance auditor), 31 findings — high 0, medium 2, low 26, false 1, maybe-false 2. 0 decision-needed, 8 patch entries (18 findings), 4 defer, 9 rejected.

- [x] [Review][Patch] A drag scrolling the text of an overflowing multiline field closed the keyboard mid-edit: Flutter's `onDrag` listener has no depth check (edge ×2, medium) [lib/shared/presentation/kit/forms.dart] — `KeyboardDismissOnDrag` (depth 0 only) at the seven sites; tests on 15 and 17 (a drag inside an 8-line field keeps the keyboard, one on the page closes it), each failing without the depth check.
- [x] [Review][Patch] The iOS refusals grep the whole env file (another key holding `localhost` or `10.0.2.2` triggers them) and the loopback one misses `127.x`, `[::1]`, `LOCALHOST`; its fix hard-codes the port (acceptance, blind, edge ×3) [scripts/start.sh] — only the host of `API_BASE_URL`, case-insensitive, the wider loopback set, a `mac_local_name` fix without a fixed port; 11 new cases in `start_sh_test.sh` (52).
- [x] [Review][Patch] architecture.md missed the addendum (the loopback refusal in the `make start` row, the Bonjour address, the local network permission) and the non-dev 10.0.2.2 fix still said « the Mac's LAN address » (acceptance, blind) [_bmad-output/planning-artifacts/architecture.md, scripts/start.sh] — updated.
- [x] [Review][Patch] The local network prompt comes at launch in debug builds (Flutter publishes the Dart VM service over Bonjour and adds an English purpose string when the app has none, `xcode_backend.dart:418-496`), not at the first request (blind) [ios/Runner/Info.plist, CONTRIBUTING.md] — comment and docs corrected; the French key is kept as briefed (removing it would leave Flutter's English text, debug and profile only: a decision listed in the hand-over).
- [x] [Review][Patch] Nothing stopped a committed signing team (blind) [test/integration/ios_project_test.dart] — the pbxproj must set no `DEVELOPMENT_TEAM` / `PROVISIONING_PROFILE*` value (checked to fail with one injected).
- [x] [Review][Patch] The physical-iPhone docs: Flutter can sign with the keychain's identity without any pbxproj edit (`code_signing.dart`), opening Xcode from the Dock resolves the packages without the bypass, the bundle-id decision comes before the first free install, a physical Android phone is not set up, `xcrun simctl` failing refuses nothing (blind ×4, edge) [CONTRIBUTING.md] — documented (the keychain path to confirm on the Mac).
- [x] [Review][Patch] No test needed the always-scrollable physics of FlowScaffold and the renewal form (verification, blind) [test/widget/features/scheduling/questionnaire_page_test.dart, test/widget/features/document/renewal_page_test.dart] — « fits » cases on a 390×2600 view (`maxScrollExtent == 0` asserted), each failing without the physics.
- [x] [Review][Patch] A future `SharedPreferencesAsync.clear()` would delete the install marker (blind) [lib/core/security/reinstall_guard.dart, deferred-work.md] — the marker's doc and the slice-5 clean-up entry say a clean-up removes its own keys.
- [x] [Review][Defer] A plain `http` base URL is accepted in release builds; dart:io ignores ATS (blind, maybe-false, medium unverified) [lib/core/network/api_config.dart] — deferred: settled with the first release configuration (step 3).
- [x] [Review][Defer] The session `ReinstallGuard` drops stays live on the server (blind, low) [lib/core/security/reinstall_guard.dart] — deferred: a best-effort logout after `runApp` needs a seam in `app/bootstrap`.
- [x] [Review][Defer] The release Info.plist could lose its dev items with `INFOPLIST_PREPROCESS` (blind, maybe-false) [ios/Runner/Info.plist] — folded into the empty-scheme entry as an option to try on the Mac.
- [x] [Review][Defer] The real share_plus closures never receive `sharePositionOrigin` in a test (verification, low) [lib/features/scheduling/presentation/scheduling_providers.dart] — already tracked (slice-4 and slice-5 entries).

Rejected:
- `low` The always-scrollable physics give short flow pages an overscroll stretch on Android (acceptance, blind): every ListView and CustomScrollView page already has it by default (`scroll_view.dart:140-147`); consistent, cosmetic.
- `low` A `KivetoSheet` that fits above the keyboard does not close it on a drag (acceptance): accepted at the build review — all its content is above the keyboard, and always-scrollable physics would take the sheet's swipe-down.
- `low` « No change to the PopScope pages » contradicts the tasks (acceptance): no `PopScope` is touched; the fix would edit the spec under review.
- `low` The bundle-id decision is in deferred-work.md but not in the frontmatter `deferred` (acceptance): bookkeeping of the spec under review.
- `false` The identity pages refuse the drag when their content fits (edge): `ListView` and `CustomScrollView` default to always-scrollable physics (`scroll_view.dart:140-147`).
- `low` A `kiveto-dev` link with another host or path opens any route (edge): debug builds only, every route stays behind the router's redirects; a host/path guard adds branches.
- `low` A failing Keychain delete restores the old session for that launch (edge): rare; the next launch retries; reporting it adds a branch to bootstrap.
- `low` The rect is taken at the tap and used after the download (edge): carried from the build review (rare; a callback parameter).
