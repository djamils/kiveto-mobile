# Make targets — phase 2 contract

Targets this phase adds. Later phases add `format`, `analyze`, `test*`, `ci` (phase 3) and `api-*` (phase 4).

| Target | Contract |
|---|---|
| `make help` | Lists targets and options. Default goal. |
| `make doctor` | Read-only. Runs every check below, prints one `ok` / `warn` / `fail` line each with the fix, exits 1 if a blocker fails. `FULL=1` adds `fvm flutter doctor -v`. |
| `make install` | Blockers of `doctor` → `fvm install` (no-op when cached) → `fvm flutter pub get` → `git config core.hooksPath .githooks` only once `.githooks/` exists (phase 3) → `config/env/dev.json` from `.dist` if missing → summary with next commands. |
| `make start` | `pub get` only when `pubspec.yaml` or `pubspec.lock` is newer than the stamp → device selection → `fvm flutter run -d <id> --dart-define-from-file=config/env/$(ENV).json $(RUN_ARGS)`. |
| `make devices` | `fvm flutter devices`, `fvm flutter emulators`; on macOS also the available simulators. |
| `make install-fvm` | Opt-in. Downloads the official FVM 4.3.2 release for the host (Windows `fvm-4.3.2-windows-x64.zip`, macOS `fvm-4.3.2-macos-arm64.tar.gz` / `-x64`), checks its SHA-256, extracts it under the user's home (Windows `%LOCALAPPDATA%\Programs\fvm`, macOS `~/fvm/bin`), prints the `PATH` line to add. Refuses when FVM is already on `PATH`. |
| `make clean` | `fvm flutter clean` when Flutter is available, then removes `.make/` stamps (keeps the log). |
| `make reset` | `clean` then `install`. |

Options: `PLATFORM=android|ios` (default `android`), `DEVICE=<id>`, `EMULATOR=<avd>`, `SIMULATOR=<name>`, `ENV=dev`, `RUN_ARGS=` (extra `flutter run` flags, e.g. `--release`), `BOOT_WAIT=180` (seconds), `V=1`, `NO_COLOR=1`, `LOG_FILE=.make/make.log`, `FULL=1` (doctor).

## Device selection (`make start`)

1. `DEVICE` set → use it (fail if `flutter devices` does not list it).
2. Otherwise, the devices of the requested `PLATFORM` that are connected or running: exactly one → use it; several → list them and stop, asking for `DEVICE=`.
3. None, `PLATFORM=android` → launch `EMULATOR`, or the first AVD of `flutter emulators`, then wait up to `BOOT_WAIT` seconds for it to be listed and booted; none available → stop with how to create one.
4. None, `PLATFORM=ios` on macOS → boot `SIMULATOR`, or the first available iPhone simulator, then wait as above.
5. `PLATFORM=ios` on Windows → stop: iOS builds need macOS.

## `make doctor` checks

| Check | Level | Fix printed |
|---|---|---|
| bash ≥ 3.2 | blocker | install Git for Windows / use the system bash |
| GNU Make ≥ 3.81 | blocker | `winget install ezwinports.make` (Windows) |
| git | blocker | install Git |
| Repository path not UNC and without spaces | warning | clone on a local disk, path without spaces |
| `core.autocrlf=true` | warning (neutralised by `.gitattributes`) | none needed; informative |
| FVM ≥ 4 on `PATH` | blocker | `make install-fvm`, or `choco install fvm` / `brew tap btwld/fvm && brew install btwld/fvm/fvm` |
| Flutter 3.47.9 in the FVM cache | warning before install, blocker for `start` | `make install` |
| Windows: Developer Mode | blocker | Settings › System › Advanced › Developer Mode |
| Windows: long paths disabled | warning | optional, needs admin |
| Android SDK found (`ANDROID_HOME`, else OS default) | blocker | install Android Studio, then SDK Manager |
| SDK cmdline-tools | blocker | SDK Manager › SDK Tools › Command-line Tools |
| SDK platform `android-36` | warning | SDK Manager › SDK Platforms › Android 16.0 (API 36) |
| `android-sdk-license` accepted | blocker | accept the licence in Android Studio's SDK Manager |
| NDK of the version Flutter asks for (a literal `ndkVersion = "x"` in `android/app/build.gradle.kts`, else `val ndkVersion: String = "x"` in the pinned SDK's `packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`; the SDK directory is the version's `"directory"` in `fvm api list`), present when `$ANDROID_HOME/ndk/<v>/source.properties` exists | blocker on Windows (Gradle cannot install it: `sdkmanager.bat` of cmdline-tools 23 splits `ndk;<v>`), warning elsewhere; warning "NDK not checked until Flutter <v> is installed" while Flutter is not cached | `"$ANDROID_HOME/cmdline-tools/latest/bin/android" --no-metrics sdk install ndk/<v>`, or SDK Manager › SDK Tools › NDK (Side by side) with "Show Package Details" |
| JDK ≥ 17 (Android Studio's `jbr`, else `JAVA_HOME`, else `java` on `PATH` with `javac`) | blocker | install Android Studio |
| At least one AVD | warning | Android Studio › Device Manager |
| Emulator acceleration (`emulator -accel-check`) | warning | enable Windows Hypervisor Platform / check virtualisation in firmware |
| macOS: Xcode ≥ 15 and `xcode-select -p` | blocker on macOS | install Xcode, `sudo xcode-select -s` |
| macOS: Xcode < 26 | warning | App Store uploads need Xcode 26 |
| macOS: an iOS simulator runtime | warning | Xcode › Settings › Components |
| Node ≥ 20.12 and uv | warning | needed by BMAD only |

Platform detection: `uname -s` → `MINGW*` / `MSYS*` (and the `CLANG*` / `UCRT64*` prefixes) = Windows (Git Bash), `Darwin` = macOS, `Linux*` = Linux, where only `make ci` is supported and checked (GitHub Actions): the other targets are not refused but untested there, and `make install-fvm` refuses it. Anything else is refused with a message.
