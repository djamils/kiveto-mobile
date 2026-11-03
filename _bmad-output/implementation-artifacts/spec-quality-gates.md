---
title: 'Quality gates (phase 3): analyzer, architecture tests, coverage gate, hooks, make ci, GitHub Actions'
type: 'chore'
created: '2026-11-03'
status: 'done'
baseline_revision: 'ba66f706737806ea0d60a38340fed3cb8817bf49'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md'
warnings: ['multiple-goals', 'oversized']
deferred:
  - summary: >-
      Test the cold-boot readiness of make start (sys.boot_completed, then pm path android under a 10 s device-side timeout) with a stubbed adb.
    evidence: |-
      Verification-gap finding: no test sources or runs scripts/start.sh; the readiness function was only run by hand against the running emulator, so the boot wait loop itself never ran. Testing it means stubbing fvm flutter devices, emulator and adb across the loop.
    location: >-
      scripts/start.sh:74
    severity: medium
---

<intent-contract>

## Intent

**Problem:** `make ci` does not exist: nothing checks formatting, lints, the layer rules, coverage or commit messages; `tool/devices.dart` and the phase-2 scripts are untested; and the user changed the target source tree (decision D15, 2026-11-03) after `architecture.md` was accepted.

**Approach:** Deliver phase 3 of architecture §11 on the D15 tree: very_good_analysis + riverpod_lint, architecture tests for the 8 D15 rules with self-tests, an SDK-only coverage gate over `lib/` and a `kiveto_tool` package, the make targets and `make ci`, plain-bash checks of the scripts, git hooks, a GitHub Actions workflow, the deferred phase-2 items and the docs; then verify milestone V2.

## Boundaries & Constraints

**Always:**
- Every Flutter / Dart call through `fvm flutter` / `fvm dart`. Makefile GNU Make 3.81 compatible; scripts, hooks and bash tests bash 3.2, LF only; phase-2 make UX (`step/ok/warn/fail`, quiet runs logged to `LOG_FILE` with the last 30 lines on failure, `V=1`, `NO_COLOR=1`).
- Versions verified on pub.dev on 2026-11-03 and pinned exactly: dev dependencies `very_good_analysis: 11.0.0`, `mocktail: 1.0.5`; `riverpod_lint: 3.1.9` as an analyzer plugin (`plugins:` in `analysis_options.yaml`, no pubspec entry). `flutter_lints` removed.
- The D15 source tree, rules and gated layers (Design Notes), generic over feature names.
- `tool/` code uses SDK libraries only; the architecture tests and the gate are tested themselves.
- No `| ^ & < > %` in arguments given to `fvm flutter` / `fvm dart` (on Windows they go through `cmd.exe`).

**Never:**
- Write `.claude/settings.json` (D14's Claude Code hooks are deferred), push, install anything system-wide, change system settings, add riverpod / dio / go_router (phases 4–5), add `coverage:ignore` anywhere.
- Edit `_bmad/`, `.claude/`, or the intent block of `spec-toolchain-bootstrap.md`.
- Replace the template app: `lib/main.dart` stays (phase 5 rewrites it), only adapted to the new lints.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|---|---|---|---|
| Clean tree | `make ci` on the branch | every step `ok`, step and total durations printed | exit 0 |
| Rule violation | one offending file per D15 rule (1–8) and a two-feature cycle, in a temporary tree | an offence of that rule naming the rule, `path:line`, the import or token and what is allowed | test fails |
| Compliant layout | temporary tree with every D15 folder and every allowed edge | no offence | N/A |
| Untested gated file | code under a gated layer, unreachable from the test roots | gate: "not loaded by any test (0%)" | exit 1 |
| Declarations only | gated file with only abstract members / enum / typedef / const, imported by a test, absent from lcov | "no executable lines", passes | N/A |
| Partly covered | gated file in lcov with LH < LF | gate prints its uncovered line numbers | exit 1 |
| `coverage:ignore` | in a gated file | gate refuses it | exit 1 |
| Outside layout | e.g. `lib/core/foo.dart`, `lib/features/x/util.dart`, `tool/bin/x.dart` | gate: outside the D15 layout | exit 1 |
| Missing input | no lcov file, no package config, no `--test-dir` | message (`make test-coverage` / `make install` first) | exit 2 |
| Device picker | `flutter devices --machine` fixtures: one / none / several Android; banner before the JSON; entry lacking a field; no JSON array; `--device` by id, by name, unknown; bad arguments | 0 + id / 2 / 3 + `id\tname` lines / 0 / 1 / 1 / 0 / 0 / 2 + every device / 1 | message on stderr for 1 |
| commit-msg | `feat(patient): x`, `fix!: x`, `chore(identity_access): x`, `Merge branch 'a/b'`, every subject of this repository's history, `Revert "x"`, `fixup! x` → accepted; `update stuff`, `feat: ` (empty), `Feat: x`, empty message → refused | refusal shows the format, the types and an example | exit 1 on refusal |
| pre-commit | staged unformatted Dart file (also when only the unstaged copy is formatted) | refused, file named, `make format` suggested | exit 1 |
| Empty suite | `test/integration/` missing or without `*_test.dart` | `make test-integration` says there is nothing to run | exit 0 |
| Doctor blocker | stub `fvm` reporting `3.0.0` | `make install` prints the FVM blocker and never calls `fvm install` | exit ≠ 0 |
| install-fvm | stubbed `uname`, `curl`, `sha256sum`: wrong digest / pinned digest with a `../evil` member / pinned digest, good layout | nothing installed / "unsafe paths", nothing written / installed, `--version` 4.3.2 | exit 1 / 1 / 0 |
| pub_get_needed | no stamp; no package config; newer `pubspec.yaml`, `pubspec.lock` or `tool/pubspec.yaml`; other Flutter pin; unchanged | needed (6 cases); not needed | N/A |
| NDK | Flutter asks for 28.2.13676358, absent from `$ANDROID_HOME/ndk/` | doctor names the version and both fixes; blocker on Windows, warning elsewhere | Windows: exit 1 |

</intent-contract>

## Code Map

Existing files:
- `Makefile` -- thin, one recipe line per target calling `scripts/`; options exported; `PLATFORM`/`ENV` from the environment ignored; help text.
- `scripts/lib.sh` -- sourced by every script: `step/ok/warn/fail/info/die`; `run` (quiet runner: `log_open` writes `▶ make $KV_TARGET`, `KV_TARGET=$(basename "$0" .sh)`); `version_ge`; `require_flutter`; `flutter_cached` (greps `fvm api list --compress --skip-size-calculation`); `pub_get_needed` / `pub_get_if_needed` (stamp `.make/pub-get.stamp` holds the Flutter version); `android_sdk`, `find_jdk`. The `uname -s` case dies on anything but MINGW*/MSYS*/CLANG*/UCRT64*/Darwin.
- `scripts/doctor.sh` -- `pass/blocker/warning`, `--quiet` for install, `KV_CALLER`; Android section (`sdk` variable) hosts the NDK check.
- `scripts/install.sh` -- already sets `core.hooksPath .githooks` once `.githooks/` exists; runs `doctor.sh --quiet` first (stops on a blocker before `fvm install`).
- `scripts/install-fvm.sh` -- pinned asset + SHA-256 per OS (macOS arm64 `c9b1e67e…19342`); `sha256_of` prefers `sha256sum`; unsafe-path grep; `"$dest/$bin" --version` must print 4.3.2; macOS dest `$HOME/fvm/bin`; no branch for other systems.
- `scripts/start.sh` -- `adb_boot_completed` and `wait_for_device` (BOOT_WAIT loop): add the `pm path android` readiness there.
- `tool/devices.dart` -- the picker; its header documents the contract (exit 0 / 1 / 2 / 3); private `_run`, `_parse`, `_Device`.
- `lib/main.dart`, `test/widget_test.dart` -- template counter app and its test.
- `analysis_options.yaml` (flutter_lints template), `pubspec.yaml` (dev deps `flutter_test`, `flutter_lints`).
- `_bmad-output/specs/spec-toolchain-bootstrap/make-targets.md` -- doctor checks table (the NDK row goes there first).
- `_bmad-output/implementation-artifacts/deferred-work.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md` (French), `_bmad-output/planning-artifacts/architecture.md`.
- Backend style reference (read-only): `tests/Unit/Architecture/PortalBoundaryTest.php` of the backend repository -- regex scan of imports, offences `file: import`, assert the list is empty.

Facts established while planning (throwaway clone, 2026-11-03):
- VGA 11 + `plugins: riverpod_lint: 3.1.9` work on Dart 3.13.7; `dart analyze --fatal-infos --fatal-warnings` reports plugin diagnostics and exits 1 (infos) or 2 (warnings). First run ~40 s (plugin fetched from pub), then ~11 s.
- `missing_provider_scope` (WARNING) fires on any `runApp(x)` whose argument is not a `ProviderScope`, riverpod imported or not: the template `main.dart` triggers it. Ignore syntax `// ignore: riverpod_lint/missing_provider_scope`, with an explanatory comment on the line above (VGA `document_ignores`). A temporary file calling `runApp(const SizedBox())` is the riverpod_lint proof.
- VGA 11 on the template: `unnecessary_type_name_in_constructor` (Dart 3.13 `const new(...)` constructors, `dart fix --apply` rewrites them), `always_put_required_named_parameters_first`, `avoid_types_on_closure_parameters`, `sort_pub_dependencies`.
- `flutter test --coverage` records only `package:` libraries of the packages matched by `--coverage-package` (default: the root package): code under `tool/` imported relatively is never measured. A path dev dependency `kiveto_tool` (`tool/pubspec.yaml`, code in `tool/lib/`) with `--coverage-package=kiveto_mobile --coverage-package=kiveto_tool` puts `tool/lib/**` in `lcov.info`. `dart analyze` and `dart format` handle `tool/` with the root options; `fvm dart tool/x.dart` resolves `package:kiveto_tool/` through the root `.dart_tool/package_config.json`.
- lcov `SF:` paths are project-relative with OS separators (`lib\main.dart` on Windows).
- A loaded library with no coverable line (abstract interface, enum, typedef, const, export-only file) is absent from `lcov.info`; a loaded library with uncalled code is present with 0 hits. Hence the gate's reachability rule.
- On Windows `fvm flutter` / `fvm dart` run `flutter.bat` / `dart.bat` through `cmd.exe`: `--coverage-package '^kiveto_(mobile|tool)$'` broke the command; use one plain `--coverage-package=<name>` per package.
- `fvm flutter test --reporter failures-only` exists.
- NDK: `val ndkVersion: String = "28.2.13676358"` in `<flutter sdk>/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`; `android/app/build.gradle.kts` has `ndkVersion = flutter.ndkVersion`. The SDK directory is the `"directory"` field of the pinned version's object in `fvm api list --compress --skip-size-calculation` (backslashes escaped on Windows: `D:\\Dev\\fvm\\versions\\3.47.9`).
- FVM 4.3.2 `fvm-4.3.2-linux-x64.tar.gz` SHA-256 `17dfced05f5b0cb32398dadd0691acc2bc458e8c4b0045a781cd5aa6c85f6ecb` (GitHub release digest). `actions/checkout` v7.0.1 = `3d3c42e5aac5ba805825da76410c181273ba90b1`; `actions/cache` v6.1.0 = `55cc8345863c7cc4c66a329aec7e433d2d1c52a9`.
- `flutter devices --machine` entries look like `{"name": "sdk gphone64 x86 64", "id": "emulator-5554", "isSupported": true, "targetPlatform": "android-x64", "emulator": true, "sdk": "Android 17 (API 37)", "capabilities": {…}}`; the same list has `windows` (`windows-x64`), `chrome` and `edge` (`web-javascript`). The emulator `emulator-5554` is usually running on this machine.

## Tasks & Acceptance

**Execution:**
- [x] `pubspec.yaml`, `analysis_options.yaml` -- remove `flutter_lints`; dev deps (sorted) `flutter_test`, `kiveto_tool: {path: tool}`, `mocktail: 1.0.5`, `very_good_analysis: 11.0.0`; sort dependencies; `fvm flutter pub get`. Options: `include: package:very_good_analysis/analysis_options.yaml`; exclude `build/**`, `android/**`, `ios/**`, `packages/**` (phase-4 generated client), `lib/l10n/app_localizations*.dart` (gen-l10n output; narrowed from `lib/l10n/**` at review); `errors: deprecated_member_use: error`; `public_member_api_docs: false` (an app, not a published API; Very Good's app template does the same); `plugins: riverpod_lint: 3.1.9`; a comment per choice -- architecture §8.
- [x] `tool/pubspec.yaml`, `tool/lib/devices.dart`, `tool/devices.dart` -- package `kiveto_tool` (`publish_to: none`, sdk `^3.13.7`, no dependency). Picker moved into `Future<int> pickDevice(List<String> args, {required Stream<List<int>> input, required StringSink out, required StringSink err})`, behaviour unchanged; `tool/devices.dart` keeps its path and header contract, becomes `exitCode = await pickDevice(args, input: stdin, out: stdout, err: stderr);` (header: it runs after `pub get`, which `start.sh` does first) -- deferred item, testability.
- [x] `tool/lib/dart_source.dart` -- shared SDK-only scanner: strip comments (line, doc, nested block) keeping string literals and line numbers; parse `import` / `export` / `part` directives (one or several lines, `as`, `show`, `hide`, `deferred`, conditional `if (…) 'uri'` configurations: every URI kept) with their 1-based line; resolve a URI seen from a project-relative file to a project-relative path (relative URIs; `package:<name>/…` through `.dart_tool/package_config.json`, only for packages rooted inside the project), else classify it as `dart:<lib>` or external package `<name>` -- used by the rules and the gate.
- [x] `tool/lib/coverage_gate.dart`, `tool/coverage_gate.dart` -- gate of Design Notes "Coverage gate" behind `int runCoverageGate(List<String> args, {required String root, required StringSink out, required StringSink err})` (async allowed); thin main.
- [x] `test/tool/devices_test.dart`, `test/tool/dart_source_test.dart`, `test/tool/coverage_gate_test.dart`, `test/tool/fixtures/` -- 100% line coverage of `tool/lib/**`; covers the "Device picker" row and every gate row; gate tests build temporary trees (`lib/`, `tool/lib/`, `.dart_tool/package_config.json`, test roots, lcov).
- [x] `test/architecture/architecture_rules.dart`, `test/architecture/architecture_test.dart`, `test/architecture/architecture_self_test.dart` -- engine `List<Offence> checkArchitecture(String root)` over `<root>/lib/**/*.dart` (Design Notes "Rules engine"); one test per rule on the real `lib/`, failing through `fail()` with the formatted offences; self-tests per Matrix rows "Rule violation" (at least one injection per rule, plus a cycle) and "Compliant layout".
- [x] `lib/main.dart`, `test/widget/main_test.dart` (moved from `test/widget_test.dart` with `git mv`) -- minimal changes so every gate passes: `dart fix --apply`, the documented ignore of `missing_provider_scope` (phase 5 wraps the app in `ProviderScope`); the test still checks the counter.
- [x] `scripts/lib.sh` -- accept `Linux*` as `KV_OS=linux` (GitHub Actions runs `make ci`; the developer targets stay Windows and macOS); `KV_TARGET=${KV_TARGET:-$(basename "$0" .sh)}`; `KV_TEST_SUITES="unit widget integration tool architecture"`, `KV_COVERAGE_SUITES="unit widget integration tool"`; `pub_get_needed` compares every file of `KV_PUB_INPUTS="pubspec.yaml pubspec.lock tool/pubspec.yaml"` (missing ones skipped; comment: phase 4 adds the generated package's pubspec); `flutter_sdk_dir` (the pinned version's `"directory"`, unescaped, through `to_unix`); every `case $KV_OS` keeps working for `linux` under `set -u`.
- [x] `scripts/format.sh`, `scripts/analyze.sh`, `scripts/test.sh`, `scripts/coverage-gate.sh`, `scripts/test-scripts.sh`, `scripts/ci.sh`, `Makefile` -- Design Notes "Make targets"; help lists the new targets; mode 100755 like the other scripts.
- [x] `test/scripts/support.sh`, `test/scripts/*_test.sh` -- Design Notes "Plain-bash checks".
- [x] `.githooks/commit-msg`, `.githooks/pre-commit` -- Design Notes "Hooks"; mode 100755 in the index (`git update-index --chmod=+x`); then `git config --local core.hooksPath .githooks` in this clone.
- [x] `.github/workflows/ci.yml` -- Design Notes "CI".
- [x] `_bmad-output/specs/spec-toolchain-bootstrap/make-targets.md`, then `scripts/doctor.sh` -- NDK row first, then the check (Design Notes "NDK").
- [x] `scripts/start.sh` -- the device counts as booted only when `sys.boot_completed` is `1` and `adb -s <id> shell pm path android` prints a line starting with `package:` (the emulator once reported boot completed with dead services and `flutter run` hung 15 min); same BOOT_WAIT loop.
- [x] `scripts/install-fvm.sh` -- `*)` branch dying with "make install-fvm supports Windows and macOS" (Linux is accepted by `lib.sh` now).
- [x] `_bmad-output/planning-artifacts/architecture.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `_bmad-output/implementation-artifacts/deferred-work.md` -- Design Notes "Docs".

**Acceptance Criteria:**
- Given the clean branch on this Windows machine, when `make ci` runs, then it exits 0, and `make ci V=1` shows every command.
- Given a temporary file calling `runApp(const SizedBox())` under `lib/`, when `make analyze` runs, then it fails on `missing_provider_scope`; the file is then removed.
- Given a throwaway clone of the branch where one compilable, analyzer-clean violation of one D15 rule is injected (stub path packages for dio or `kiveto_portal_api` when needed), when `make ci` runs, then it fails at `test-architecture` with that rule's message, for each rule; and an untested file with code in a gated layer makes `make ci` fail at `coverage-gate`.
- Given `make ci` passes, then the gate output shows the declared exclusions and a `tool` / `lib` row at 100%.
- Given this clone after the change, then `git config --local --get core.hooksPath` prints `.githooks`, and a commit with the message `update stuff` is refused.
- Given the emulator, when `make start RUN_ARGS=--no-resident` runs, then the app launches.

## Implementation Notes

- Implemented by a subagent from this spec (2026-11-03), on the Windows machine of phase 2 (Git Bash 5.2, make 4.4.1, FVM 4.3.2, emulator `emulator-5554` running). Nothing committed or pushed; `.claude/` untouched.
- `make ci`: exit 0 in 1 min 03–1 min 07 on a warm tree (format-check 1–3 s, analyze 9 s, test-architecture 5 s, test-coverage 6 s, coverage-gate 2–3 s, test-scripts 40–42 s); 1 min 31 on the fresh throwaway clone (pub get included). `make ci V=1` printed every command (`+ <make> <target>`, `+ fvm …`, `+ bash test/scripts/…`). Gate output: the three declared exclusions and `tool  lib  3  445/445  100.0%  100%`. `make test-integration`: exit 0, nothing to run.
- riverpod_lint: `lib/riverpod_probe.dart` calling `runApp(const SizedBox())` made `make analyze` exit 2 on `missing_provider_scope`; the file was removed.
- V2, in a throwaway clone of the branch state in the scratchpad (baseline `make ci` green there first): one formatted, analyzer-clean injection per rule, each making `make ci` stop with `make ci failed at test-architecture` and only that rule's offence — rule 1 `features/patient/domain/pet.dart` importing `package:flutter/foundation.dart` (`@immutable`); rule 2 `features/patient/application/pet_count.dart` with a `ValueNotifier` (message tagged `(Flutter)`); rule 3 `features/patient/presentation/pet_label.dart` importing `core/network/endpoints.dart`; rule 4 `app/routing/router.dart` importing `features/patient/infrastructure/pet_api.dart`; rule 5 `features/home/presentation/home_label.dart` importing `features/patient/domain/pet.dart`; rule 6 `core/di/providers.dart` importing `features/patient/patient.dart`; rule 7 `core/security/session.dart` importing a stub path package `packages/kiveto_portal_api` added to the clone's pubspec; rule 8 `features/patient/domain/age.dart` calling `DateTime.now()`. An untested `features/patient/domain/pet.dart` with a getter stopped `make ci` at `coverage-gate` ("not loaded by any test (0%)").
- Hooks: `git config --local --get core.hooksPath` prints `.githooks` in this clone. The refused `git commit -m 'update stuff'` was run in the throwaway clone (hooks path set there; exit 1, HEAD unchanged), not in this clone, so that no commit could land here; here the hook itself refuses the message (exit 1, format, types, example).
- `make start RUN_ARGS=--no-resident`: built and launched `app.kiveto.portal` on the running emulator (30 s; `topResumedActivity` is `app.kiveto.portal/.MainActivity`). The emulator was already up, so the cold-boot wait loop did not run; the new `adb_boot_completed` (boot flag plus `pm path android`) was run directly against `emulator-5554` (ready) and an absent id (not ready).
- `make install-fvm` with every `fvm` folder removed from `PATH`, `LOCALAPPDATA` and `HOME` in the scratchpad: the real `fvm-4.3.2-windows-x64.zip` downloaded, its SHA-256 matched, `fvm.exe --version` printed 4.3.2; the scratch folder was then deleted. With a stubbed `uname` reporting Linux and no fvm, `install-fvm.sh` stops on the new `*)` branch.
- Linux: a `make ci` run with a stubbed `uname` reporting Linux passed (the `linux` branches of `lib.sh` under `set -u`, doctor's NDK warning branch). The GitHub Actions workflow itself cannot run from here (no push): its first run is on the PR.
- bash 3.2: in the cached `bash:3.2` image (bash 3.2.57, busybox, no network, repository mounted read-only), `bash -n` passed on every script, hook and test script; `lib_test.sh`, `portability_test.sh`, `test_sh_test.sh` passed and the commit-msg hook accepted / refused the Matrix subjects (CRLF included). The tests needing git or Flutter (hooks pre-commit, doctor, devices) were not run under 3.2.
- File modes: the new scripts, the hooks and `test/scripts/*_test.sh` are 100755 in the index (`git add --chmod=+x` / `git update-index --chmod=+x`, `core.filemode=false` on Windows), so those files are staged; the other changes are not.
- Choices within the spec: the literal coverage-ignore marker is split in Dart sources (`'coverage' ':ignore'`), since the gate refuses it in `tool/lib/` (gated) and no file holds it; the gate lists "no executable lines" files and unloaded measured files under a "Notes:" heading; `--lcov` / `--test-dir` paths are relative to the project root; files under hidden folders (`tool/.dart_tool/`) are skipped; `support.sh` adds `expect_not_contains` and `with_real_fvm` (for the cases needing the real `fvm dart`); the history check of `hooks_test.sh` skips GitHub's synthetic `Merge <sha> into <sha>` subject of a pull request checkout; doctor's "NDK not checked until Flutter … is installed" warning is silent during `make install`, like the Flutter-cache warning (finding 19 of phase 2).
- `tool/lib/devices.dart`, behaviour unchanged: the `is! List` check after decoding a `[`…`]` slice could never fail (the slice decodes to a list or throws), so it became a cast; the `if case … else throw` list element became a loop because the VM's coverage did not count its `throw` line.
- After the review patches (2026-11-03): `make ci` exit 0 in 1 min 12 (format-check 2 s, analyze 8 s, test-architecture 5 s, test-coverage 5 s, coverage-gate 2 s, test-scripts 50 s, 9 bash files); gate `tool  lib  3  467/467  100.0%`, exclusions `lib/main.dart`, `lib/l10n/app_localizations*.dart`, `tool/*.dart`. Checked by the parent agent: with an unresolvable plugin version (`riverpod_lint: 99.0.0`), `dart analyze` exits 4 with the pub error, so a riverpod_lint that fails to load stops `make analyze` instead of passing silently; a `pub get` run inside `tool/` keeps the root rules for `tool/` (only `tool/pubspec.lock` appears, now ignored); `adb shell timeout 10 pm path android` answers on the API 37 emulator. The second doctor pass of `make install` (Flutter not cached before `fvm install`) has no automated test.

## Spec Change Log

## Review Triage Log

### 2026-11-03 — Review pass
- verdicts: 63 findings — high 0, medium 10, low 47, false 6, maybe-false 0
- findings:
  - `low` `patch` [blind] Rule 8 misses `DateTime.timestamp()` — regex extended to `DateTime.(now|timestamp)`, self-test added, docs updated.
  - `low` `reject` [blind] Infrastructure or `kiveto_portal_api` can leak through `export` from `di.dart` / `core/di/` — not among the 8 D15 rules; a re-export check adds a rule branch for an unlikely pattern; noted for phases 4–5 in the hand-over.
  - `low` `patch` [blind] Rule 4 lists `core/di/` while rule 6 forbids core/ → feature — the D15 text has both; the engine checks both literally (rule 6 wins); architecture.md now says so under rule 4 (CLAUDE.md untouched).
  - `low` `reject` [blind] "Only infrastructure talks to Dio" not checked for `core/security`, `core/errors`, `app/`, `di.dart` — not a D15 rule; adding one is new scope; noted in the hand-over.
  - `low` `reject` [blind] infrastructure → presentation and features/core → app/ not enforced — not among the D15 rules; adds branches; noted in the hand-over.
  - `low` `reject` [blind] Gate passes code behind an unused conditional import, a deferred import or a skipped suite — no conditional or deferred import and no skipped suite in this mobile app; telling them apart needs parsing conditions; documented limitation.
  - `low` `patch` [blind] An absolute `--test-dir` passes the check but finds no test — the gate now refuses it with exit 2; test added.
  - `low` `reject` [blind] No coverage suite with tests → gate exits 2 — unreachable: `tool/lib` is gated, so `test/tool` must hold tests; the gate would fail anyway without them.
  - `false` `reject` [blind] `mocktail` added unused — the intent asks for it explicitly ("add mocktail for tests"), architecture §5 lists it.
  - `low` `reject` [blind] CI `pub get` without `--enforce-lockfile`, no clean-tree check — the lock is committed and consistent; an added CI guard for an unlikely hand-edited lock.
  - `low` `patch` [blind] `cancel-in-progress` cancels master pushes — now only for pull requests.
  - `low` `patch` [blind] One cache without `restore-keys` re-downloads Flutter on any lock change — `restore-keys` added.
  - `low` `reject` [blind] Conventional Commits only checked client-side; PR CI history check empty — D9 is a local hook by design; squash titles are reviewed; noted in the hand-over.
  - `low` `patch` [blind] CI marked "Now" although never run and not a required check — CONTRIBUTING row reworded (written, not run; make it required on master); deferred-work entry added.
  - `low` `patch` [blind] Portability scan misses `;&`, `declare -n`, negative subscripts, `${v@Q}`, globstar, `EPOCH*`, `wait -n` — patterns added.
  - `medium` `patch` [blind] Phase 3 reads as done without a macOS run — §0 row and README say macOS pending; deferred-work entry added.
  - `low` `reject` [blind] NDK test: Gradle-literal branch untested, exit-code assertion not discriminating — the `✗ NDK … missing` content assertion discriminates; the literal branch is a fallback unused today.
  - `low` `reject` [blind] `support.sh` drops every PATH entry holding fvm (brew / choco bins) — assertions match messages, not only exit codes; install-fvm needs fvm absent from PATH; low impact (warnings only).
  - `low` `patch` [blind] A `pub get` inside `tool/` leaves `tool/pubspec.lock` untracked — checked: analysis of `tool/` keeps the root rules after such a pub get; `/tool/pubspec.lock` ignored.
  - `low` `patch` [blind] `lib/l10n/**` excluded as a whole — narrowed to `lib/l10n/app_localizations*.dart` (analyzer, gate, docs).
  - `low` `reject` [blind] The rules engine is outside the 100% gate — test code is not measured by design; its self-tests exercise every rule.
  - `low` `patch` [blind] Layout check accepts any `lib/app/<x>/` — restricted to `bootstrap`, `routing`, `theme` (+ files directly under `lib/app/`).
  - `false` `reject` [blind] CLAUDE.md §3 omits application's own `application/` — the line lists what application adds to the domain allow-list; files of one layer importing each other is implied and enforced as allowed.
  - `low` `patch` [blind] architecture.md §3 presentation row omits its own `di.dart` and `core/di/` — row completed.
  - `low` `reject` [blind] Spec cites a machine-specific backend path — fix is editing this spec.
  - `medium` `patch` [edge] `mktemp` failure leaves `KV_T` empty → `rm -rf /home /tmp` — support.sh stops unless the temp dir exists.
  - `medium` `patch` [edge] pre-commit passes one path per file through cmd.exe: ~70+ files exceed 8191 chars — the temp folder is passed as one argument.
  - `low` `reject` [edge] Conditional-import alternative passes as "no executable lines" — same as the blind finding above.
  - `low` `reject` [edge] Skipped suite or relative `../lib` import from a test passes absent code — `avoid_relative_lib_imports` fails `make analyze` first; skipped suites unlikely; same group.
  - `low` `reject` [edge] No coverage suite → gate exit 2 — same group, unreachable.
  - `low` `patch` [edge] Absolute `--test-dir` — same fix as above.
  - `low` `patch` [edge] Absolute lcov paths with another prefix never match → fail-open — covered by the per-package "no record" check (VG1 group).
  - `low` `patch` [edge] `lib/app/misc/` accepted — same fix as above.
  - `low` `patch` [edge] Dot-prefixed `.dart` file names skipped by `listDartFiles` — only hidden folders are skipped now; test added.
  - `low` `patch` [edge] `DateTime.timestamp()` / `print` tear-off bypass rule 8 — timestamp added; the tear-off part rejected (`avoid_print` already fails analysis).
  - `low` `patch` [edge] commit-msg refuses `Reapply "…"` and octopus `Merge branches …` — accepted now; cases added.
  - `low` `reject` [edge] `core.commentChar` other than `#` — unlikely; needs a config lookup.
  - `low` `patch` [edge] pre-commit uses the working-copy `analysis_options.yaml` — the staged one is used (fallback: working copy).
  - `medium` `patch` [edge] Fresh clone: the NDK check is skipped during `make install` (Flutter not cached yet) — install re-runs doctor after `fvm install` when Flutter was not cached.
  - `medium` `patch` [edge] `pm path android` can block forever on a wedged system_server — `adb shell timeout 10 pm path android` (checked on the API 37 emulator).
  - `low` `patch` [edge] `cancel-in-progress` on master — same fix as above.
  - `medium` `patch` [verification-gap] The gate passes when lcov has no record for a project package (`--coverage-package` dropped) — fails now when a package directory with reachable gated files has no `SF:` record; test added.
  - `medium` `patch` [verification-gap] `ci.sh` and `test-scripts.sh` never run with a failing step — `test/scripts/ci_sh_test.sh` added (stub MAKE; failing `*_test.sh`).
  - `medium` `patch` [verification-gap] `format.sh --check` never run on an unformatted file — cases added (unformatted → exit 1 with `make format`; formatted → 0).
  - `medium` `defer` [verification-gap] The `pm path android` readiness in `start.sh` has no automated test — needs stubbing the whole boot loop; checked by hand on the emulator; recorded in deferred-work.md.
  - `low` `patch` [verification-gap] The gate fails open by design on absent-but-reachable files — the systemic case (a whole package missing) now fails; per-file reachability stays the documented rule.
  - `low` `reject` [verification-gap] No coverage suite → gate exit 2 — same group, unreachable.
  - `low` `reject` [verification-gap] History check empty on PR CI — same group as the client-side Conventional Commits finding.
  - `false` `reject` [intent] V2 checked by hand in a throwaway clone, not automated — the intent asks to verify V2 and record it; the self-tests automate each rule.
  - `false` `reject` [intent] riverpod_lint could silently not load — checked: with an unresolvable plugin version `dart analyze` exits 4 with the pub error, so `make analyze` fails.
  - `low` `reject` [intent] The reachability assumption is not checked against a real `flutter test --coverage` — established empirically while planning (spec Code Map); the per-package check now catches a coverage run that measured nothing.
  - `low` `reject` [intent] Process exit codes of `tool/devices.dart` tested for 0 only — the main only assigns `exitCode`; `pickDevice` returns 0–3 under test.
  - `false` `reject` [intent] `make install` not exercised through make — the target is one recipe line running the tested script.
  - `low` `reject` [intent] install-fvm tested on the macOS branch only — the Windows branch ran with the real release download (SHA-256 matched).
  - `low` `reject` [intent] All-empty test path through the gate not exercised — same group, unreachable.
  - `low` `reject` [intent] Hooks run directly; CI history check empty — `make install` sets `core.hooksPath` (unchanged code), verified in this clone; same group as above.
  - `low` `reject` [intent] CI only checked with a stubbed `uname` — no push possible; stated in the notes.
  - `medium` `defer` [intent] `start.sh` boot loop not exercised — same as the deferred verification gap.
  - `low` `reject` [intent] Dio not confined outside presentation/application — same as the blind finding.
  - `low` `reject` [intent] Changes beyond the letter (layout check, ignore ban in all gated layers, `test-tool`, Linux in lib.sh, `public_member_api_docs`) — each justified in the spec Design Notes and needed by the gate or CI.
  - `low` `reject` [intent] `test-scripts` last in `ci`, so `api-check` would follow it — phase 4 places `api-check` where it wants in the one list.
  - `low` `reject` [intent] architecture §7 doctor table rewritten — aligned with `make-targets.md`, the approved contract (phase 2 review rejected those checks).
  - `false` `reject` [intent] Version checks not evidenced in the diff — checked on pub.dev on 2026-11-03 while planning (spec Code Map: VGA 11.0.0 sdk ^3.13.0, riverpod_lint 3.1.9 sdk >=3.13.0-0, mocktail 1.0.5).


## Design Notes

### D15 (user decision, 2026-11-03)

Supersedes the feature list of architecture §2 and the `core/{domain,application,infrastructure,presentation}` split of §3/§6; everything else of §3 holds (di.dart bridge, public `<feature>.dart`, no pass-through use cases, sealed failures, `Clock`).

```
lib/
├── main.dart
├── app/{bootstrap,routing,theme}/   # composition root: env, ProviderScope, runApp / go_router, shell / ThemeData, tokens
├── core/                            # technical kernel, no business rule
│   ├── network/   security/   errors/   di/   # Dio + interceptors + problem+json / tokens, session, device id / ApiFailure / core providers
├── shared/{domain,presentation}/    # shared kernel: pure Dart value objects, Clock, common failures / UI kit, formatters
├── features/<bounded_context>/{domain,application,infrastructure,presentation}/, di.dart, <bounded_context>.dart
└── l10n/                            # app_fr.arb + gen-l10n output
```

Features (snake_case, named after the Symfony bounded contexts): `identity_access` (7, 8, 9, 0, invitation onboarding, refresh, logout, e-mail change and deletion flows of 6), `client` (6 profile, clinics, consents, export, active clinic and switcher, link suggestions), `patient` (2 pet sheet, change requests, pet list for booking), `consultation` (2 visit history), `scheduling` (12, 13, 3, 14, 4, 16, reschedule, 15 questionnaire, `.ics`, new-client booking requests), `document` (5, 17, prescription detail), `clinic_listing` (10, 11, new-client booking from the directory), `home` (1, composes the others through their public APIs).

Rules (`test/architecture/`):
1. `features/*/domain/` and `shared/domain/`: no package, no `dart:io` / `dart:ui`; may import its own domain and `shared/domain/`.
2. `features/*/application/`: + its own domain and `shared/domain/`; no Flutter, Riverpod, Dio, generated client, `core/`.
3. `features/*/presentation/` and `shared/presentation/`: never `**/infrastructure/**`, `package:dio`, `kiveto_portal_api`, `core/network/`, `core/security/`.
4. Only `features/*/di.dart`, `core/di/`, `app/bootstrap/` and tests import a feature's `infrastructure/`.
5. A feature imports another only through `features/<other>/<other>.dart`; acyclic feature graph.
6. `core/` and `shared/` import no feature; `shared/` imports nothing from `core/` or `app/`.
7. `kiveto_portal_api` only under `features/*/infrastructure/**`, `core/network/**`, `core/di/**`.
8. `DateTime.now(`, `print(` and `coverage:ignore` forbidden in `features/*/domain/`, `features/*/application/` and `shared/domain/`.

Gated at 100%: `features/*/{domain,application,infrastructure}`, `shared/domain`, `core/{network,security,errors}` (+ `tool/lib`, this spec). Measured without threshold: `features/*/presentation`, `shared/presentation`, `app/`, `core/di`, `features/*/di.dart`, `<feature>.dart`.

### Rules engine

- Scans `<root>/lib/**/*.dart` (paths `/`-separated, relative to `lib/`), comment-stripped; internal targets come from relative URIs and `package:kiveto_mobile/…`; `dart:` and other packages keep their name. Every rule is checked independently (one import may break several).
- Rules 1 and 2 are allow-lists: `dart:core`, `dart:async`, `dart:collection`, `dart:math` (CLAUDE.md §3, stricter than D15's "no `dart:io`/`dart:ui`"), plus rule 1's own domain and `shared/domain/`, rule 2's own domain, own application and `shared/domain/`; nothing else, no external package. Rule 2's message names the forbidden family when it is one (Flutter, Riverpod, Dio, `kiveto_portal_api`, `core/`).
- Rule 4 allows, besides the listed files, a feature's own `infrastructure/` files importing each other; rule 5 then catches `features/y/di.dart` → `features/x/infrastructure`, and rule 6 catches `core/di/` → features. Rule 5 applies to files under `features/<x>/` only (`app/` and `main.dart` may reach feature internals, rule 4 permitting); the cycle check uses every cross-feature edge and reports each cycle once, with one `path:line` per edge.
- Rule 8: on comment-stripped text, `\bDateTime\s*\.\s*(now|timestamp)\b` (tear-offs too; `timestamp` added at review) and `(?<![\w$.])print\s*\(`; `coverage:ignore` on the raw text.
- Offence message: `[rule N] lib/<path>:<line> imports <uri>` (or `uses <token>`) `— <what the rule allows> (architecture §3, D15)`; the per-rule test prints all offences of its rule. Style of the backend's architecture tests (collect, assert empty).

### Coverage gate

- CLI: `--lcov <file>` (default `coverage/lcov.info`), `--test-dir <dir>` (repeatable, at least one; roots = its `*_test.dart` files), `--root <dir>` (default: current directory). Exit 0 pass, 1 gate failed, 2 usage error or missing lcov / package config.
- Files: `lib/**/*.dart` and `tool/**/*.dart`. Declared exclusions, printed with their reason: `lib/main.dart` (entry point), `lib/l10n/app_localizations*.dart` (gen-l10n output; any other file of `lib/l10n/` is outside the layout), `tool/*.dart` (thin entry points over `tool/lib/`, run by the make targets and the plain-bash checks).
- Classification (area / layer / gated): `lib/features/<f>/{domain,application,infrastructure}/**` gated; `…/presentation/**`, `lib/features/<f>/di.dart`, `lib/features/<f>/<f>.dart` measured; `lib/shared/domain/**` gated, `lib/shared/presentation/**` measured; `lib/core/{network,security,errors}/**` gated, `lib/core/di/**` measured; `lib/app/{bootstrap,routing,theme}/**` and `lib/app/*.dart` measured (other `lib/app/` folders are outside the layout, since the review); `tool/lib/**` gated. Anything else is outside the D15 layout: blocking.
- Per file: in lcov → hit/found; absent and reachable from the roots through import/export/part (relative or `package:` of the project) → "no executable lines" (0/0, passes); absent and unreachable → "not loaded by any test", 0% (its lines estimated for the table as non-blank, non-comment, non-directive lines). lcov paths normalised (`\` → `/`, absolute paths under the root made relative).
- Fails on: a gated file below 100% (uncovered line numbers listed), a gated file not loaded, `coverage:ignore` in a gated file (CLAUDE.md §4 for every gated layer), a file outside the layout, and (since the review) a project package directory (`lib/`, `tool/lib/`) whose gated files tests load while `lcov.info` has no record under it (a `--coverage-package` dropped from the coverage run). An absolute `--test-dir` is refused (exit 2).
- Output: exclusions; table `area | layer | files | lines hit/found | cover | threshold (100% / –)`; failures; a final `ok` / `fail` line.

### Make targets

- Every new target is one recipe line `@KV_TARGET=$@ bash scripts/<x>.sh [args]`; steps needing Flutter call `require_flutter` and `pub_get_if_needed` first; quiet by default through `run`, live with `V=1`.
- `format` / `format-check`: `fvm dart format` (`--output=none --set-exit-if-changed` for the check) on `lib test tool` plus `integration_test` when it exists; the check's failure names the files and says `make format`.
- `analyze`: `fvm dart analyze --fatal-infos --fatal-warnings`.
- `test`, `test-unit`, `test-widget`, `test-integration`, `test-tool`, `test-architecture`: `fvm flutter test` on `test/<suite>` for the suites of `KV_TEST_SUITES` (or the one named) that contain a `*_test.dart`; the others are reported as having nothing to run; none at all → `ok` "nothing to run", decided before any `fvm` call. Quiet runs add `--reporter failures-only` so the failure message ends up in the 30-line tail.
- `test-coverage`: deletes `coverage/lcov.info`, then `fvm flutter test --coverage --coverage-package=kiveto_mobile --coverage-package=kiveto_tool` on the `KV_COVERAGE_SUITES` folders with tests; none → writes an empty `coverage/lcov.info`.
- `coverage-gate`: `fvm dart tool/coverage_gate.dart --lcov coverage/lcov.info` with one `--test-dir test/<s>` per `KV_COVERAGE_SUITES` folder that has tests; output shown live (it is the report).
- `test-scripts`: runs every `test/scripts/*_test.sh` with bash, one line per case, fails when one fails.
- `ci`: `scripts/ci.sh` runs, in order, the targets of one list `format-check analyze test-architecture test-coverage coverage-gate test-scripts` (comment: phase 4 appends `api-check`), each through `$(MAKE)` passed by the recipe (`MAKE='$(MAKE)'`), stops at the first failure with `make ci failed at <target>`, prints each step's duration and the total.

### Plain-bash checks (`test/scripts/`)

- `support.sh` (sourced, bash 3.2): temp dir removed on exit, `PATH` without the directories holding an `fvm` / `fvm.exe` executable, stub writer, `expect_status` / `expect_contains` / `expect_eq`, one `✓` / `✗` line per case, exit 1 if a case failed.
- `lib_test.sh`: `version_ge` cases (`1.10`≥`1.9`, `3.81`≥`3.81`, `4`≥`4.0.0`, `3.80`<`3.81`, `20.12.1`≥`20.12`, `08`≥`7`, `2.9`<`2.10`) and the "pub_get_needed" row, in a temporary project holding a copy of `scripts/lib.sh` and its inputs, mtimes set with `touch -t` (BSD and GNU).
- `doctor_test.sh`: "Doctor blocker" row (stub `fvm` printing `3.0.0` for `--version`, logging its arguments, failing otherwise; `ANDROID_HOME` an empty temp dir; `LOG_FILE` in the temp dir; `bash scripts/install.sh` and `bash scripts/doctor.sh`) and "NDK" row (stub `fvm` `4.3.2` whose `api list` returns a pinned version with `"directory"` pointing to a fake SDK holding `FlutterExtension.kt`; fake `ANDROID_HOME` without then with `ndk/28.2.13676358/source.properties`).
- `install_fvm_test.sh`: "install-fvm" row with stubs `uname` (`-s` → `Darwin`, `-m` → `arm64`), `curl` (copies a prepared archive to its `-o` path), `sha256sum` (the "pinned digest" cases print the macOS arm64 digest read from `scripts/install-fvm.sh`), `HOME` a temp dir; archives built with `tar` (good: `fvm/fvm` script printing `4.3.2`; unsafe: a `../evil` member, created with `-P`); assert exit codes, messages, and what exists under `$HOME` and next to it afterwards.
- `hooks_test.sh`: "commit-msg" row; message files may start with comment lines; every `git log --format=%s` subject of this repository is accepted. "pre-commit" row in a temporary git repository holding copies of `.fvmrc`, `analysis_options.yaml` and `.dart_tool/package_config.json`: staged unformatted file → exit 1 naming it; staged unformatted with a formatted working copy → exit 1; staged formatted → exit 0.
- `test_sh_test.sh`: "Empty suite" row: a copy of `scripts/` in a temporary project with no `test/integration/` (then an empty one) → `bash scripts/test.sh integration` exits 0 and says there is nothing to run, without calling `fvm`.
- `devices_main_test.sh`: `fvm dart tool/devices.dart --platform android < <one-device fixture>` prints the id, exit 0 (wiring of the thin main).
- `portability_test.sh`: no bash ≥ 4 construct (`declare -A`, `${v,,}` / `${v^^}`, `mapfile`, `readarray`, `printf '%(`, `[[ -v`, `&>>`, `|&`, `;;&`, `coproc`) and no CR in `scripts/*.sh`, `.githooks/*`, `test/scripts/*.sh`, `Makefile`.

### Hooks

- `commit-msg`: the subject is the first line that is neither blank nor a `#` comment. Accepted: `^(feat|fix|test|refactor|chore|docs|style|perf|build|ci|revert)(\([a-z0-9_.,/-]+\))?!?: [^ ]`; git's own `^Merge (branch|remote-tracking branch|tag|pull request|commit) `, `^Revert "`, `^(fixup|squash|amend)! `. Refusal: expected format, the types, an example, pointer to `CONTRIBUTING.md` §3; exit 1.
- `pre-commit`: staged `*.dart` (`git diff --cached --name-only --diff-filter=ACMR`), `packages/` excluded; none → exit 0. Checks the staged content: `git checkout-index --prefix=<tmp>/` of those files, plus copies of `analysis_options.yaml` and `.dart_tool/package_config.json` (the formatter reads its options through them), then `fvm dart format --output=none --set-exit-if-changed` on the temp copies from the repository root; failure lists the repository paths and says `make format, then git add`; no `fvm` or no package config → refuse with `make install`.

### CI

`.github/workflows/ci.yml`: on `pull_request` and `push` to `master`; `permissions: contents: read`; concurrency per ref with cancel-in-progress; one job on `ubuntu-24.04`, `timeout-minutes: 30`, env `FVM_CACHE_PATH: /home/runner/fvm-cache`. Steps: checkout (pinned SHA, `# v7.0.1`); cache (pinned SHA, `# v6.1.0`) of `/home/runner/fvm-cache` and `~/.pub-cache`, key on `.fvmrc`, `pubspec.lock`, `tool/pubspec.yaml`; install FVM 4.3.2 from the linux-x64 release asset checked with `sha256sum -c` and added to `$GITHUB_PATH`; `fvm install --skip-pub-get`; `make ci V=1`. The workflow cannot run from here (no push): say so in the notes.

### NDK (doctor, Android section)

Version: a literal `ndkVersion = "x"` in `android/app/build.gradle.kts` if any, else the `val ndkVersion: String = "x"` of `$(flutter_sdk_dir)/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`; Flutter not cached → warning "NDK not checked until Flutter <v> is installed". Present when `$sdk/ndk/<v>/source.properties` exists. Missing → blocker on Windows (Gradle cannot install it: `sdkmanager.bat` of cmdline-tools 23 splits `ndk;<v>`), warning elsewhere; fix `"$sdk/cmdline-tools/latest/bin/android" --no-metrics sdk install ndk/<v>`, or SDK Manager › SDK Tools › NDK (Side by side) with "Show Package Details". Same row in `make-targets.md`.

### Docs

- `architecture.md`: D15 in §10 (user, 2026-11-03) with §2 (feature table above), §3 (layer table: shared kernel / technical core; rules 1–8 above) and §6 (D15 tree + the real layout: `.githooks/`, `.github/workflows/ci.yml`, `scripts/` incl. `install-fvm`, `clean`, `format`, `analyze`, `test`, `coverage-gate`, `test-scripts`, `ci`, `tool/` = package `kiveto_tool` with `lib/` and thin mains, `test/{unit,widget,integration,architecture,tool,scripts}`); D2: display name "Kiveto" decided, Apple Team ID still open; §7: `SHELL := bash` validated in phase 2 (Git Bash + make 4.4.1, macOS `/usr/bin/make` 3.81 where the first `bash` on `PATH` wins, Homebrew bash included; the scripts stay 3.2-compatible), targets table and `ci` sequence as built, doctor table + NDK, Linux accepted for `make ci` only; §8 gate as built (reachability, layout check, `coverage:ignore`, `tool/lib`); D14 Claude Code hooks marked deferred (§8, §10, §11 phase-3 row); §5 versions as pinned.
- `CLAUDE.md`: Bootstrap status (phases 1–3 done once merged, phase 2 validated on Windows and macOS, `make ci` exists); §1 (`make ci` exists); §3 and §4 in D15 terms (`shared/domain`, `core/{network,security,errors,di}`, gated layers + `tool/lib`).
- `CONTRIBUTING.md`: §0 phase 3 row (what it brings; Done) and phase 5 row in D15 terms; §5 commands (new targets) and quality-controls table (available now; Claude Code hook deferred); §6 in D15 terms (tree, features, rules); §7 suites (+ `test/tool/`, `test/scripts/`) and coverage policy (D15 layers, `tool/lib`, reachability, exclusions).
- `README.md` (French): phases 1–3, `make ci`.
- `deferred-work.md`: remove the handled entries (devices.dart tests, `pub_get_needed`, `version_ge`/doctor, install-fvm, architecture.md, NDK, CLAUDE.md status); keep `MaterialApp.title`; add D14's Claude Code hooks (this session may not write `.claude/settings.json`).

## Verification

**Commands:**
- `make ci` -- expected: exit 0; note the total runtime.
- `make test-integration` -- expected: exit 0, nothing to run.
- `git config --local --get core.hooksPath` -- expected: `.githooks`.
- `bash .githooks/commit-msg <file containing "update stuff">` -- expected: exit 1 with the format.

**Manual checks:**
- V2 in a throwaway clone of the branch (scratchpad): per rule, inject one compilable violation (stub path packages `dio` / `kiveto_portal_api` if needed), `make ci` fails at `test-architecture` with the rule's message; an untested gated file fails at `coverage-gate`; a `runApp(const SizedBox())` file fails `make analyze`.
- `make start RUN_ARGS=--no-resident` with the emulator: the app launches.
- `make install-fvm` with `fvm` filtered out of `PATH` and `LOCALAPPDATA` / `HOME` pointed to a scratch folder: the real Windows asset downloads, its SHA-256 matches, `fvm --version` prints 4.3.2 (nothing installed for the user).

## Auto Run Result

Status: done

- **Change:** phase 3 on the D15 tree: very_good_analysis 11.0.0 + riverpod_lint 3.1.9 (analyzer plugin), architecture tests of the 8 D15 rules with self-tests, the SDK-only coverage gate over `lib/` and the new path package `kiveto_tool` (`tool/`), the make targets and `make ci`, plain-bash checks of the scripts and hooks, git hooks, the GitHub Actions workflow, the deferred phase-2 items (devices.dart tests, `pub_get_needed`, `version_ge`/doctor, install-fvm, NDK check, `pm path android` readiness) and the docs (D15 recorded in architecture.md, CLAUDE.md, CONTRIBUTING.md, README.md, deferred-work.md).
- **Files:** `analysis_options.yaml`, `pubspec.yaml`/`.lock` (lints, mocktail, `kiveto_tool`); `tool/pubspec.yaml`, `tool/lib/{devices,dart_source,coverage_gate}.dart` and thin mains `tool/{devices,coverage_gate}.dart`; `test/tool/**` (picker, scanner, gate, fixtures); `test/architecture/{architecture_rules,architecture_test,architecture_self_test}.dart`; `test/widget/main_test.dart` (moved), `lib/main.dart` (lints, documented ignore); `scripts/{format,analyze,test,coverage-gate,test-scripts,ci}.sh` new, `scripts/{lib,doctor,install,install-fvm,start}.sh` changed; `Makefile`; `test/scripts/*` (9 test files + `support.sh`); `.githooks/{commit-msg,pre-commit}`; `.github/workflows/ci.yml`; `.gitignore`; docs listed above and `make-targets.md` (NDK row).
- **Review (one pass, 63 findings):** 28 rows patched (medium: phase-3 status on macOS, the `mktemp` guard of `support.sh`, the pre-commit argument length, the NDK check after `fvm install`, the `pm path` timeout, the per-package lcov check of the gate, tests of `ci.sh`/`test-scripts.sh` and of `format.sh --check`); 1 entry deferred (start.sh boot-loop test, 2 rows); 33 rows rejected (6 false, 27 low: each reason in the triage log).
- **Follow-up review recommended: true** — 8 medium findings were patched (patched rows: high 0, medium 8, low 20). Unverified risk: the patches themselves (the gate's per-package record check, the single-folder `fvm dart format` call of the pre-commit hook, the second doctor pass of `make install`) were checked by tests and `make ci` but not reviewed again; the branch's `bmad-code-review` pass covers that.
- **Verification:** `make ci` exit 0 (1 min 12 after the patches); `make test-integration` exit 0 with nothing to run; `core.hooksPath` = `.githooks`; the commit-msg hook refuses `update stuff` (exit 1); V2, riverpod_lint probe, `make start`, real `make install-fvm` download and the Linux simulation as in the Implementation Notes.
- **Residual risks:** GitHub Actions never ran (no push); phase 3 not run on macOS (`/usr/bin/make` 3.81, `/bin/bash` 3.2, BSD tools); the cold-boot wait loop of `make start` and the second doctor pass of `make install` are untested; the gate's "absent but reachable = no executable lines" rule can pass code behind an unused conditional import or a skipped suite (none exists today).
