---
title: 'Toolchain bootstrap (phase 2): pinned Flutter, project, Makefile, portable scripts'
type: 'chore'
created: '2026-11-02'
status: 'done'
route: 'dispatch'
baseline_commit: '815fe21f555a58ee6b0519f8652562e2c2e0939e'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/specs/spec-toolchain-bootstrap/SPEC.md'
  - '{project-root}/_bmad-output/specs/spec-toolchain-bootstrap/make-targets.md'
  - '{project-root}/CLAUDE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The repository has only its foundations: no pinned Flutter SDK, no app project and no command to install or run it, so no later phase can start and Windows / macOS developers have no shared entry point.

**Approach:** Pin Flutter 3.47.9 with FVM, generate the Android + iOS project with the backend's ids, and add a thin Makefile over bash 3.2 scripts that implements `doctor`, `install`, `install-fvm`, `start`, `devices`, `clean`, `reset` exactly as `make-targets.md` specifies (SPEC CAP-1…CAP-8).

**Decisions:** the app's display name is **Kiveto** (Android launcher label, iOS `CFBundleDisplayName`); it can change later, unlike the `app.kiveto.portal` ids. The spec is kept whole at ~1,700 tokens: the V1 milestone needs the project and the make targets together.

## Boundaries & Constraints

**Always:** every Flutter / Dart call through `fvm flutter` / `fvm dart`; Makefile valid for GNU Make 3.81 with `SHELL := bash`; scripts valid for bash 3.2, LF only; Symfony make UX (`step / ok / warn / fail`, quiet runs logged with timestamps to `LOG_FILE`, last 30 lines on failure, `V=1`, `NO_COLOR=1`); idempotent install and start; only repository-local git config.

**Never:** install or configure anything system-wide or edit `PATH`; add a package to `pubspec.yaml`; touch analyzer config, tests, hooks, CI, API client or app code (phases 3–5); parse JSON with tools absent from Git Bash (`jq`, Python).

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Ready machine | `make doctor` | one line per check, exit 0 | N/A |
| FVM missing | `make doctor` / `make install` | `fail` line with `make install-fvm` and the OS package command | exit 1, nothing installed |
| Second install | `make install` twice | second run downloads nothing, exit 0 | N/A |
| No device running | `make start` | first AVD booted, waited for (`BOOT_WAIT`), app launched | timeout → exit 1 naming `BOOT_WAIT` |
| Several devices | `make start` | list of ids, asks for `DEVICE=` | exit 1 |
| Unknown device | `make start DEVICE=x` | message listing available ids | exit 1 |
| iOS on Windows | `make start PLATFORM=ios` | "iOS builds need macOS" | exit 1 |
| Unchanged pubspecs | `make start` twice | second run skips `pub get` | N/A |
| FVM already on PATH | `make install-fvm` | says so, does nothing | exit 0 |

</frozen-after-approval>

## Code Map

- `.fvmrc` -- new; `{"flutter": "3.47.9"}` plus FVM flags that stop it from editing `.gitignore` and IDE settings.
- `pubspec.yaml`, `lib/main.dart`, `test/widget_test.dart`, `analysis_options.yaml`, `android/`, `ios/`, `.metadata` -- new, from `fvm flutter create --project-name kiveto_mobile --org app.kiveto --platforms android,ios .`; existing files are not overwritten.
- `android/app/build.gradle.kts`, `android/app/src/main/kotlin/**/MainActivity.kt`, `android/app/src/main/AndroidManifest.xml` -- `namespace` / `applicationId` `app.kiveto.portal`, matching Kotlin package path, label.
- `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist` -- `PRODUCT_BUNDLE_IDENTIFIER` `app.kiveto.portal` (`.RunnerTests` for tests), display name.
- `Makefile` -- new, thin: exports options, one recipe line per target calling `scripts/`.
- `scripts/lib.sh` -- new; OS detection, colours, `step/ok/warn/fail`, quiet runner with timestamped log (pattern of the Symfony `run` macro, bash 3.2 timestamps through `date`), Android SDK / JDK / FVM lookup helpers.
- `scripts/doctor.sh`, `install.sh`, `install-fvm.sh`, `start.sh`, `devices.sh`, `clean.sh` -- new, one per target.
- `tool/devices.dart` -- new; reads `flutter devices --machine` JSON on stdin and picks a device for a platform (exit 0 + id / 2 none / 3 several); SDK libraries only.
- `config/env/dev.json.dist` -- new; `API_BASE_URL` (`http://10.0.2.2:81`) and `API_HOST_HEADER` (`portal.kiveto.local`), read by the app from phase 5.
- `.gitignore` -- add Flutter template entries missing from the current file, if any.
- `CONTRIBUTING.md` §0, `README.md` -- phase 2 status and the commands that now exist.
- Do not change: `_bmad/`, `.claude/`, `CLAUDE.md` directives, `_bmad-output/planning-artifacts/`.
- V1 machine: Windows 11 with Git Bash 5.2; make 4.4.1 (winget) and FVM 4.3.2 installed for the user, Flutter 3.47.9 already in the FVM cache; Android SDK (android-36, android-37.0, cmdline-tools 23.0, licence accepted), AVD `Medium_Phone_API_37.0` with WHPX, pub and Gradle caches all relocated to another drive through the user variables `ANDROID_HOME`, `ANDROID_AVD_HOME`, `PUB_CACHE`, `GRADLE_USER_HOME`; Android Studio and its JBR 25 outside `Program Files`; Developer Mode on; no `jq`, no real Python. Git Bash rewrites `/x` arguments of Windows programs: use `MSYS_NO_PATHCONV=1` or `cygpath` when passing paths to `.exe` tools. The scripts find all of this through those variables and the OS defaults, never through machine-specific paths.

## Tasks & Acceptance

**Execution:**
- [x] `.fvmrc` -- pin 3.47.9 -- D1.
- [x] project files -- run `flutter create` as in the Code Map, then set ids and display name -- CAP-7.
- [x] `scripts/lib.sh`, `Makefile` -- shared helpers and targets -- constraints of the SPEC.
- [x] `scripts/doctor.sh` -- every check of `make-targets.md`, blockers exit 1 -- CAP-1.
- [x] `scripts/install.sh`, `scripts/install-fvm.sh` -- CAP-2, CAP-5 (FVM 4.3.2 assets and SHA-256 digests pinned in the script).
- [x] `tool/devices.dart`, `scripts/start.sh`, `scripts/devices.sh` -- CAP-3, CAP-4, device selection of `make-targets.md`.
- [x] `scripts/clean.sh`, `config/env/dev.json.dist`, `.gitignore` -- CAP-6, CAP-8.
- [x] `CONTRIBUTING.md`, `README.md` -- mark phase 2 done, document only what exists.

**Acceptance Criteria:**
- Given a fresh clone on the Windows machine, when `make install` then `make start` run, then the app shows on `Medium_Phone_API_37.0`.
- Given the app ran once, when `make start` runs again with unchanged pubspecs, then no `pub get` happens.
- Given any script, when checked for bash ≥ 4 constructs and CRLF, then none is found.

## Implementation Notes

- Implemented by a context-free subagent from this spec (2026-11-02). `.fvmrc` keeps FVM's own key order because `fvm install` rewrites the file; the pub-get stamp stores the Flutter version for the same reason; `make start` passes `--no-pub`; `make install` also skips pub get when nothing changed; `make reset` forces it.
- First `make start` failed in Gradle: cmdline-tools 23.0's `sdkmanager.bat` splits `ndk;28.2.13676358` at `;` on Windows, so AGP cannot auto-install the NDK. With the user's go-ahead on prerequisites, the NDK was installed with the new Android CLI (`android --no-metrics sdk install ndk/28.2.13676358`). The Assumption "the first build downloads the NDK" does not hold on Windows with cmdline-tools 23.0.
- V1 on Windows: `make start RUN_ARGS=--no-resident` booted `Medium_Phone_API_37.0`, built, installed and launched `app.kiveto.portal` (label `Kiveto`, compileSdk 36) in 1 min 06; the second run reused the emulator and skipped pub get (13 s). On a throwaway fresh clone (tracked + committable files only): `make doctor` ready with 2 warnings, `make install` twice (second: no download, pub get skipped, `dev.json` kept), `make start` launched the app; no committable file changed during the run. macOS half of V1 not run.
- Matrix rows saying "exit 1": the scripts exit 1; `make` itself reports a failed recipe with exit 2 (GNU make convention). The user accepted this on 2026-11-03: "exit 1" in the matrix means the failing exit of the script, seen as a non-zero `make` exit.
- Personal paths of the V1 machine removed from this spec before commit, at the user's request (2026-11-03).
- macOS shell simulation (2026-11-03), no Mac being reachable: in the official `bash:3.2` image (bash 3.2.57, busybox userland) with stubs for `uname` (Darwin, arm64), Xcode 26.1, `simctl`, FVM, emulator and adb, the unmodified scripts passed `doctor` (macOS branch, Android Studio jbr, simulator runtime), `install` twice, `start` for iOS (booted the named or first iPhone simulator, names with parentheses included) and Android (booted the AVD), the EMULATOR/SIMULATOR error paths, `RUN_ARGS`, `BOOT_WAIT=090`, `devices`, `clean`, `FULL=1`; `install-fvm` downloaded the real `fvm-4.3.2-macos-arm64.tar.gz`, verified its SHA-256 and found the expected `fvm/fvm` layout (its version check cannot run a Mach-O binary on Linux). GNU Make 3.81 built from the GNU source ran the real Makefile with bash 3.2: default help, option export, environment `PLATFORM`/`ENV` ignored, command line wins, `reset`, exit 2 on failure. Still needs a real Mac: BSD userland, the real FVM binary, Xcode build and simulator run, Android on macOS.

## Spec Change Log

## Review Triage Log

| # | Source | Finding | Verdict | Evidence | Route |
|---|---|---|---|---|---|
| 1 | verification-gap | `tool/devices.dart` contract untested, outside the coverage gate | medium | Pre-verified gap; no test references it | defer (frozen Never: tests, phase 3) |
| 2 | verification-gap | `pub_get_needed` untested | medium | Pre-verified gap | defer (phase 3) |
| 3 | verification-gap | doctor blocker gate and `version_ge` untested | medium | Pre-verified gap | defer (phase 3) |
| 4 | verification-gap | `install-fvm` verify/refuse paths untested, download never run | medium | Pre-verified gap; only a local-archive manual run | defer (phase 3) |
| 5 | verification-gap | `--device` accepts web/desktop devices | low | Matches make-targets step 1 ("DEVICE set → use it"); filtering by PLATFORM would refuse a valid id with the default PLATFORM | rejected (low, unlikely, behaviour change) |
| 6 | blind | Phase 2 "Done" while macOS V1 pending; phase 1 row "In progress" | medium | `CONTRIBUTING.md` §0 and README claim completion; macOS half of V1 not run | patch |
| 7 | blind | FVM < 4 fix points to `install-fvm`, which exits on any fvm on PATH | medium | `install-fvm.sh:12` returns before any version check; doctor/`require_flutter` print `fvm_fix` for "too old" | patch |
| 8 | blind | platform-tools/adb never checked; timeout message blames BOOT_WAIT | low | Android Studio installs platform-tools by default; message part shares root with #28 | message: patch with #28; check: rejected (unlikely, adds a check) |
| 9 | blind | SDK/JDK lookup ignores `ANDROID_SDK_ROOT` / `flutter config` | low | make-targets: "ANDROID_HOME, else OS default"; `ANDROID_SDK_ROOT` is deprecated | rejected (low, unlikely, adds branches) |
| 10 | blind | Doctor lacks CocoaPods, backend and AEHD checks of architecture §7 | low | make-targets.md is the approved contract; CocoaPods optional with SwiftPM, backend check belongs to phase 5; machine uses WHPX | rejected (fix is editing the spec) |
| 11 | blind | `architecture.md` stale (display name, layout, SHELL result) | low | §6/D2 still say "display name to provide"; layout lacks `install-fvm.sh`, `clean.sh`, `tool/devices.dart` | defer (planning artifact, `bmad-architecture`) |
| 12 | blind | Text parsing in shell contrary to architecture §7 (emulators, simctl, fvm api) | medium (AVD list) / low (rest) | `start.sh` parses `flutter emulators` table while doctor uses `emulator -list-avds`; simctl text and `fvm api` JSON are stable at the pinned versions | AVD list: patch; rest rejected (low, rewrite) |
| 13 | blind | `dev.json.dist` only reaches the Android emulator | false | Nothing reads `API_BASE_URL` in this change; per-platform addressing is phase 5 (architecture §7) | rejected |
| 14 | blind | No warning when `dev.json` lags the template | low | No key is read yet | rejected (low, adds logic) |
| 15 | blind | Stamp ignores overrides and path packages | false | No `pubspec_overrides.yaml` or path package exists; phase 4 must extend the stamp | rejected (note for phase 4) |
| 16 | blind | bash 3.2/CRLF verification incomplete | false | Wider scan (uppercase case-changes, `-n` refs, `wait -n`, `&>>`, `|&`, `;;&`, `coproc`, `EPOCH*`, negative subscripts) finds nothing; no CRLF; `bash -n` passes | rejected (fix is editing the spec) |
| 17 | blind | `tool/devices.dart` untested | medium | Same root as #1 | defer with #1 |
| 18 | blind | Spec contains personal machine paths | low | Code Map bullet names the user profile and local paths | rejected (fix is editing the spec); raised to the human |
| 19 | blind | `make install` warns "Flutter not cached - make install" during make install | low | `doctor.sh:89` prints it in `--quiet` mode on every first install | patch |
| 20 | blind | Scripts committed without the executable bit | low | `core.filemode=false`; headers document `scripts/doctor.sh` direct calls | patch (headers say `bash scripts/…`; set +x when staging) |
| 21 | blind | Template names: `MaterialApp.title`, pubspec description | low | `title: 'Flutter Demo'` is app code (frozen Never); description is metadata | description: patch; title: defer (phase 5) |
| 22 | blind | `RUN_ARGS` loses quoting | low | Split on whitespace by design | rejected (low, unlikely) |
| 23 | blind | `.make/make.log` grows forever | low | Text log, a few kB per run | rejected (low, adds rotation) |
| 24 | blind | `install-fvm` trusts an existing install; copies in place | low | Archive is SHA-verified before copy; only a manual partial copy reaches that branch | rejected (low, unlikely) |
| 25 | edge-case | SDK via `ANDROID_SDK_ROOT` or flutter config | low | Same root as #9 | rejected with #9 |
| 26 | edge-case | Listed emulator not yet boot-completed | low | Needs a manual emulator start seconds before `make start` | rejected (low, unlikely, adds a guard) |
| 27 | edge-case | AVD already starting when launch is called | low | Same narrow window | rejected (low, unlikely) |
| 28 | edge-case | Emulator dies after launch → misleading BOOT_WAIT advice | low | Timeout message assumes slowness | patch with #8 |
| 29 | edge-case | `BOOT_WAIT=090` | low | Reproduced: "value too great for base" | patch (base-10 normalisation) |
| 30 | edge-case | `isSupported:false` devices picked | low | Needs an Android device below minSdk 24 | rejected (low, unlikely) |
| 31 | edge-case | DEVICE name shared by several devices | low | Ids are listed and unique | rejected (low, unlikely) |
| 32 | edge-case | Stray `[`/`]` lines break the JSON slice | low | No such line in `flutter devices --machine` output | rejected (low, unlikely) |
| 33 | edge-case | Notice on stdout pollutes PICKED | false | Fresh-profile run of `dart tool/devices.dart` prints only the id | rejected |
| 34 | edge-case | IDE pub get after the stamp | low | Same SDK when the IDE uses the FVM link | rejected (low, adds a guard) |
| 35 | edge-case | `pubspec.lock` deleted after the stamp | low | Lock is committed | rejected (low, adds a guard) |
| 36 | edge-case | `core.autocrlf=TRUE/yes/on/1` reported as pass | low | `git config` returns the raw spelling | patch (case-insensitive compare) |
| 37 | edge-case | javac shim outside `<jdk>/bin` | low | Android Studio's jbr is found first | rejected (low, unlikely) |
| 38 | edge-case | `install-fvm` version check after copy | low | Same root as #24 | rejected with #24 |
| 39 | edge-case | `PLATFORM`/`ENV` inherited from the environment | medium | Reproduced: `PLATFORM=BNB make start` → "PLATFORM=BNB is not supported" (HP machines set PLATFORM) | patch (Makefile ignores environment origin) |
| 40 | edge-case | Git Bash `CLANGARM64`/`UCRT64` refused | low | Windows-on-ARM Git Bash reports those prefixes | patch (case patterns) |
| 41 | edge-case | Xcode licence pending reported as "not found" | medium (unverified) | Needs a Mac to reproduce | defer (macOS V1) |
| 42 | edge-case | RUN_ARGS quotes | low | Same root as #22 | rejected with #22 |
| 43 | edge-case | Untracked `config/env/<ENV>.json` not ignored | low | Architecture commits staging/prod env files; dart-defines ship in the binary | rejected |
| 44 | edge-case | No-SDK doctor run hides later SDK blockers | false | Those checks cannot run without an SDK; the blocker names the fix | rejected |
| 45 | edge-case | install cannot repair deps resolved outside the stamp | false | `make reset` clears the stamps and forces pub get | rejected |
| 46 | implementation | NDK auto-install fails on Windows (cmdline-tools 23.0) | medium | Reproduced in Gradle; external tooling bug | defer (doctor check needs a spec update); docs: patch |
| 47 | implementation | `CLAUDE.md` still says "phase 1" | low | Bootstrap status line out of date | defer (agent-context file) |

## Design Notes

Device listing uses `flutter devices --machine` JSON parsed by `tool/devices.dart` because Git Bash has no JSON tool; the scripts keep the control flow. Booting: `fvm flutter emulators --launch <avd>`, then poll the picker and `adb -s <id> shell getprop sys.boot_completed` until `1` or `BOOT_WAIT`. Validation runs use `RUN_ARGS=--no-resident` so `flutter run` exits after launching.

## Verification

**Commands:**
- `make doctor` -- expected: exit 0 on this machine.
- `make install && make install` -- expected: both exit 0, the second downloads nothing.
- `make start RUN_ARGS=--no-resident` (twice) -- expected: app launched on the AVD; second run without `pub get`.
- `PATH` without FVM, `make doctor` -- expected: exit 1 with the FVM fix.
- `grep -nE 'declare -A|\$\{[a-z_]+(,,|\^\^)|mapfile|readarray|%\(|\[\[ -v' scripts/*.sh` -- expected: no match.
