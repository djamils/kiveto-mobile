---
title: 'Kiveto Mobile — architecture and bootstrap decisions'
status: 'accepted'
date: '2026-11-02'
author: 'Djamil'
inputs:
  - 'Kiveto Symfony: CLAUDE.md, CONTRIBUTING.md, Makefile, tests/Unit/Architecture/'
  - 'Kiveto Symfony: openapi/portal.v1.yaml (OpenAPI 3.2.0), openapi/portal-api-v1.md'
  - 'Versions checked on pub.dev, the Flutter release manifest and npm on 2026-11-02'
---

# Kiveto Mobile — architecture and bootstrap decisions

Accepted on 2026-11-02 (decisions D1–D14 below). Versions were checked on
that date; re-check them before pinning anything in a later phase.
Updated on 2026-11-03 by phase 3: decision D15 (the user's source tree and
features) replaces the feature list of §2 and the `core/` split of §3 and
§6; §5–§8 describe the tooling as built.

## 1. Context

Kiveto Mobile is the Android and iOS app of the Kiveto Portal, the pet
owners' space. It is a **client of the Portal API** of the Kiveto Symfony
backend (`/api/portal/v1` on the portal host, 18 screens, 60 operations,
delivered in 7 slices). The backend owns every business invariant.

Relationship with the backend: **customer / supplier** with a **published
language** — the OpenAPI document `openapi/portal.v1.yaml`. The generated
client is an infrastructure detail; each feature's `infrastructure/` is the
**anti-corruption layer** that turns generated DTOs into domain models. No
network DTO reaches `application/` or `presentation/`.

The mobile domain is therefore thin:

- **In:** typed models (ids, `Money` in minor units, `LocalDate` for
  `YYYY-MM-DD`, `ClinicInstant` keeping the clinic's UTC offset, which
  `DateTime.parse` drops), sealed failures mapped from the problem+json
  `type` codes, and the policies the client owns — session lifecycle, one
  token refresh in flight at a time (required by the contract), a stable
  `Idempotency-Key` per user intent, the 4-step booking wizard.
- **Out:** rules the server enforces and answers for — phone coverage
  (`422 phone_not_supported`), OTP limits, slot computation, cancellation
  window (`cancellableUntil`, `cancellation_window_closed`), quotas. The
  app formats and guides; the server decides.

## 2. Bounded contexts of the app (features)

D15 (user decision, 2026-11-03): the features are named after the Symfony
bounded contexts, in snake_case, and cut from the screens and flows of the
contract. This list replaces the first one (`session`, `pets`,
`appointments`, `documents`, `account`, `directory`).

| Feature | Screens and flows |
|---|---|
| `identity_access` | 7, 8, 9, 0; invitation onboarding, token refresh, logout, the e-mail change and account deletion flows of 6 |
| `client` | 6 (profile, clinics, consents, export); the active clinic and its switcher; link suggestions |
| `patient` | 2 (pet sheet), change requests, the pet list used for booking |
| `consultation` | 2 (visit history) |
| `scheduling` | 12, 13, 3, 14, 4, 16; reschedule, 15 (questionnaire), `.ics`, new-client booking requests |
| `document` | 5, 17; prescription detail |
| `clinic_listing` | 10, 11; new-client booking from the directory |
| `home` | 1; composes the others through their public APIs |

Next to the features (§6): `lib/shared/` is the **shared kernel**
(`domain/`: pure Dart value objects such as `Money`, `LocalDate`,
`ClinicInstant`, the `Clock` port, the common failures; `presentation/`:
the UI kit and formatters); `lib/core/` is the **technical core**, with no
business rule (`network/`: Dio, interceptors, problem+json; `security/`:
tokens, session, device id; `errors/`: `ApiFailure`; `di/`: the core
providers); `lib/app/` is the **composition root** (`bootstrap/`: env,
`ProviderScope`, `runApp`; `routing/`: go_router and the shell; `theme/`:
`ThemeData` and tokens). The active clinic (every `/clinics/{c}` route) is
exposed by `client` through its public API.

## 3. Layers and dependency rules

```
presentation ──► application ──► domain ◄── infrastructure
      │                                         ▲
      └────────── di.dart (the only bridge) ────┘
```

| Layer | Contains | May import |
|---|---|---|
| `features/*/domain/` | models, value objects, sealed failures, repository contracts | `dart:core/async/collection/math`, its own domain, `shared/domain/` — no package |
| `features/*/application/` | use cases **only** where something is orchestrated (e.g. `SignInWithCode`: verify, then branch on `authenticated` / `invitation_pending` / `registration_required`), state machines | + its own application — no Flutter, Riverpod, Dio, generated client or `core/` |
| `features/*/infrastructure/` | repositories on the generated client, DTO → domain mapping, storage | + `dio`, `kiveto_portal_api`, `core/` — never `presentation/` |
| `features/*/presentation/` | pages, widgets, Riverpod notifiers (view models), routes | Flutter, Riverpod, go_router, its own application and domain, its own `di.dart`, `core/di/`, `core/errors/`, `shared/`, other features' public APIs — never `infrastructure/`, Dio, the generated client, `core/network/` or `core/security/` |
| `features/*/di.dart` | providers binding each domain contract to its implementation | the feature file importing `infrastructure/` (with `core/di/`, `app/bootstrap/` and tests) |
| `features/*/<feature>.dart` | the feature's public API | the only entry point for other features; no cycles |
| `shared/domain/` | shared kernel: value objects, `Clock`, common failures | `dart:core/async/collection/math` and itself |
| `shared/presentation/` | UI kit, formatters | Flutter, `shared/domain/` — no feature, `core/` or `app/` |
| `core/{network,security,errors}/` | technical core: Dio and interceptors, tokens and session, `ApiFailure` | packages, `shared/` — no feature |
| `core/di/` | the core providers | `core/`, `kiveto_portal_api` — no feature |
| `app/{bootstrap,routing,theme}/` | composition root | anything; `main.dart` too |

Some constraints of this table are **conventions, kept by review, not
checked by `test/architecture/`**: where Dio may appear outside the
domains, applications and presentations (only `infrastructure/`,
`core/network/` and `core/di/` should use it); `infrastructure/` never
importing `presentation/`; features and `core/` never importing `app/`;
`di.dart` and `core/di/` not re-exporting an `infrastructure/` file or the
generated client. Everything else is a rule below.

Domain and application never import another feature (rules 1–2), not even
its public API: cross-feature use happens in presentation, infrastructure
or `di.dart`, through `<other>.dart`, and what several domains share
belongs in `shared/domain/`.

Rules checked by `test/architecture/` (D15), written like the Symfony
`tests/Unit/Architecture/` tests (scan of the `import` / `export` / `part`
directives of `lib/**`, comments stripped; collect the offences, assert
there is none), with self-tests that inject offending files:

1. `features/*/domain/` and `shared/domain/`: no package, no `dart:io` /
   `dart:ui`; may import its own domain and `shared/domain/`. Checked as
   an allow-list: `dart:core`, `dart:async`, `dart:collection`,
   `dart:math` (CLAUDE.md §3), its own domain, `shared/domain/`.
2. `features/*/application/`: + its own domain and `shared/domain/` (and
   its own application); no Flutter, Riverpod, Dio, generated client,
   `core/`. An allow-list too; the message names the forbidden family.
3. `features/*/presentation/` and `shared/presentation/`: never
   `**/infrastructure/**`, `package:dio`, `kiveto_portal_api`,
   `core/network/`, `core/security/`.
4. Only `features/*/di.dart`, `core/di/`, `app/bootstrap/` and tests
   import a feature's `infrastructure/` (and its own `infrastructure/`
   files, each other). The `core/di/` exception never applies: rule 6
   forbids `core/` to import any feature, so the feature wiring lives in
   `features/*/di.dart` and `app/bootstrap/`.
5. A feature imports another only through `features/<other>/<other>.dart`;
   the feature graph is acyclic (each cycle reported once, one
   `path:line` per edge). `app/` and `main.dart` may reach feature
   internals, rule 4 permitting.
6. `core/` and `shared/` import no feature; `shared/` imports nothing from
   `core/` or `app/`.
7. `kiveto_portal_api` only under `features/*/infrastructure/**`,
   `core/network/**`, `core/di/**`.
8. `DateTime.now` / `DateTime.timestamp` (use the `Clock` port), `print(`
   and `coverage:ignore` are forbidden in `features/*/domain/`,
   `features/*/application/` and `shared/domain/`.

Each offence reads `[rule N] lib/<path>:<line> imports <uri> — <what the
rule allows> (architecture §3, D15)`.

No pass-through use cases: a notifier that only reads calls the repository
directly (the official Flutter architecture guide makes the use-case layer
optional too). No command / query / event buses and no generic
`Result` / `Either`: normal business outcomes are sealed return types,
errors are sealed failures handled by pattern matching. Riverpod is both
the state holder and the dependency injection; tests override providers.

## 4. Sharing the OpenAPI contract

- `contracts/portal.v1.yaml` is a copy of the backend file, with
  `contracts/SOURCE` (repository, commit, sha256). The backend has no
  contract tags, so the copy is **pinned by commit SHA** (D4).
  `make api-sync REF=<sha>` copies it from a local backend checkout
  (`KIVETO_BACKEND_DIR`; a WSL checkout seen from Windows needs a one-off
  `git -c safe.directory=…`) or from the remote.
- The client is generated into `packages/kiveto_portal_api/` (a `path:`
  dependency), **committed** (D5) and excluded from analysis and coverage:
  `make install` and the CI need neither Java nor the generator.
  `make api-check` (in `make ci`) fails when the sha256 recorded in the
  generated package differs from the copy's.
- Only `features/*/infrastructure/**`, `core/network/` and `core/di/`
  import it (rule 7).
- An API change is a backend PR (DTOs + YAML), then a mobile PR
  `chore(api): sync portal contract <sha>`.

Known properties of the exported document (2026-11-02), documented in the
backend guide: `openapi: 3.2.0` (API Platform 4.4 default; `--spec-version=3.0.0`
exists, no 3.1 output); nullability as `type: [T, 'null']` and
`anyOf: [{$ref}, {type: 'null'}]`; no `oneOf` / `allOf`; 60 operationIds
derived from paths (`api_clinics_clinicIdhome_get`); French tags;
110 schemas including dotted names (`Appointment.AppointmentView`,
`MeUpdate.jsonMergePatch`); `apiKey` security scheme on `Authorization`;
58 of 191 error responses carry a schema.

### Generator spike (phase 4, D3)

No generator is retained before it has run on the real contract.

| Candidate | Version | Reads 3.2? | Notes |
|---|---|---|---|
| `swagger_parser` | 1.45.1 | No (2.0, 3.0, 3.1 only) | Pure Dart, mature; handles both nullable forms; needs the header rewritten to 3.1.0 behind a guard that rejects 3.2-only keywords |
| `tonik` | 0.11.1 | Yes | Pure Dart, explicit renames (`nameOverrides`); young, one maintainer |
| `openapi-generator` | 7.27.0 | No | Needs Java; ruled out |

Spike criteria: the generated code compiles and passes the analyzer;
nullable fields are right; `PATCH /me` sends `application/merge-patch+json`;
`date-time` values keep their offset (or we parse them ourselves);
readable names despite the operationIds and tags; decodes `GET /me` from
the local backend.

## 5. Technology choices (checked 2026-11-02)

Pinned in phase 3 (versions checked again on pub.dev on 2026-11-03, pinned
exactly): very_good_analysis 11.0.0 and mocktail 1.0.5 as dev
dependencies, riverpod_lint 3.1.9 as an analyzer plugin (no pubspec
entry); flutter_lints removed. The other rows are added by later phases,
checked again then.

| Role | Choice | Version | Why |
|---|---|---|---|
| SDK | Flutter via FVM | 3.47.9 (Dart 3.13.7), FVM 4.3.2 | Current stable; riverpod_lint and very_good_analysis 11 need Dart ≥ 3.13 (D1) |
| State + DI | flutter_riverpod | 3.4.3 | Riverpod 3 stable; typed DI, overrides in tests, `AsyncValue` |
| State lint | riverpod_lint | 3.1.9 (pinned) | Ships on the analyzer plugin system (`plugins:` in `analysis_options.yaml`), reported by `dart analyze` |
| Lints | very_good_analysis | 11.0.0 (pinned) | Strictest maintained rule set |
| Routing | go_router | 18.1.2 | Maintained by the Flutter team; deep link `/invitation#t=` |
| HTTP | dio | 5.11.1 | `QueuedInterceptor` gives one refresh in flight |
| Tokens | flutter_secure_storage | 11.2.0 | Keychain / Keystore; minSdk 24 = template default |
| Preferences | shared_preferences | 2.5.6 | Active clinic |
| Localisation | flutter_localizations + gen-l10n (ARB) | SDK | The contract returns codes; labels are translated in the app |
| Tests | flutter_test, integration_test, mocktail | SDK, 1.0.5 (pinned) | No goldens in `make ci` |
| Coverage gate | `tool/coverage_gate.dart` (package `kiveto_tool`) | — | SDK libraries only, tested itself (§8) |
| Coverage report | coverde | 0.4.1 | HTML without Perl / genhtml; not added yet |

No code generation in the app itself (D7): no riverpod_generator (4.0.9
needs `build < 5`, which pulls build_runner back to 2.16) and no freezed
(the domain stays pure Dart; sealed classes, records and pattern matching
are enough). Rejected as well: custom_lint (archived), import_lint and
import_guard (analyzer version conflict with riverpod_lint — all analyzer
plugins share one resolution), melos, bloc, get_it / injectable, fpdart,
equatable, golden_toolkit (discontinued), the Dart ports of husky /
git_hooks / commitlint (unmaintained since 2024).

Any later dependency is checked when it is added.

## 6. Repository layout

```
kiveto-mobile/
├── .fvmrc                      # {"flutter": "3.47.9"} — committed; .fvm/ ignored
├── .gitattributes .editorconfig .gitignore
├── .githooks/{commit-msg,pre-commit}   # bash 3.2; core.hooksPath set by make install
├── .github/workflows/ci.yml    # make ci on Linux
├── .claude/skills/             # BMAD skills (settings.json with the team hooks: deferred, D14)
├── _bmad/  _bmad-output/{planning-artifacts,implementation-artifacts,specs}/
├── CLAUDE.md  CONTRIBUTING.md  README.md
├── Makefile                    # thin, delegates to scripts/
├── analysis_options.yaml  pubspec.yaml  pubspec.lock   # l10n.yaml: phase 5
├── config/env/dev.json.dist    # --dart-define-from-file; dev.json ignored
├── contracts/{portal.v1.yaml,SOURCE}                    # phase 4
├── packages/kiveto_portal_api/ # generated, committed  # phase 4
├── scripts/                    # bash 3.2: lib, doctor, install, install-fvm, start, devices,
│                               #   clean, format, analyze, test, coverage-gate, test-scripts, ci
├── tool/                       # package kiveto_tool (SDK libraries only, path dev dependency):
│   ├── lib/                    #   devices.dart, dart_source.dart, coverage_gate.dart
│   └── devices.dart  coverage_gate.dart   # thin entry points run by the scripts
├── lib/                        # the D15 tree below
├── test/{unit,widget,integration,architecture,tool,scripts}/
├── integration_test/           # phase 5
└── android/  ios/              # applicationId / bundle id app.kiveto.portal
```

`lib/` (D15):

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

Identity (D2): Dart package `kiveto_mobile`; Android `applicationId` and
iOS bundle id `app.kiveto.portal`, the ids the backend serves in its
`.well-known` files (`PORTAL_ANDROID_PACKAGE`, `PORTAL_IOS_APP_ID`).
Display name: **Kiveto** (decided in phase 2; it can change, unlike the
ids). Still to provide: the Apple Team ID (the backend holds the
placeholder `ABCDE12345`).

## 7. Developer experience

Same contract on Windows 11 (Git Bash) and macOS:
`make install`, `make start`, `make ci`.

Portability rules:

- The `Makefile` is thin and compatible with **GNU Make 3.81** (macOS's
  `/usr/bin/make`): no `.ONESHELL`, `$(file)`, `!=` or grouped targets.
  `SHELL := bash`, resolved on `PATH` (a native Windows make has no
  `/bin/bash`) — validated in phase 2: Git Bash with make 4.4.1 on
  Windows; on macOS, `/usr/bin/make` 3.81 runs the first `bash` on
  `PATH`, a Homebrew bash included, which is why the scripts stay
  3.2-compatible rather than relying on `/bin/bash`.
- Logic lives in `scripts/*.sh`, written for **bash 3.2** (no associative
  arrays, case-changing expansions, line-reading array builtins, strftime
  `printf`, `[[ -v ]]`), LF only — checked by
  `test/scripts/portability_test.sh`.
- Anything that runs once Flutter is installed is Dart, in `tool/` (the
  package `kiveto_tool`, SDK libraries only).
- Systems: Windows (Git Bash) and macOS for every target. On Linux only
  `make ci` is supported and checked (GitHub Actions): the other targets
  are not refused there but untested, and `make install-fvm` refuses it.

| Target | Contract |
|---|---|
| `make doctor` | Read-only. Checks every prerequisite, says how to fix it, fails on a blocker. `FULL=1` adds `flutter doctor -v`. |
| `make install` | doctor (blockers) → `fvm install` (no-op when cached) → `pub get` → `git config core.hooksPath .githooks` (repository-local) → `config/env/dev.json` from `.dist` if missing → summary. Idempotent; installs nothing system-wide. |
| `make start` | `pub get` only when a pubspec changed (stamp in `.make/`) → device selection → `fvm flutter run -d <id> --dart-define-from-file=config/env/$(ENV).json`. Options `PLATFORM`, `DEVICE`, `EMULATOR`, `SIMULATOR`, `ENV`. |
| `make devices` | Connected devices, AVDs, simulators. |
| `make ci` | `format-check → analyze → test-architecture → test-coverage → coverage-gate → test-scripts` (phase 4 appends `api-check`), each through the calling make; stops at the first failure (`make ci failed at <target>`), prints each step's duration and the total. |
| `make format`, `format-check` | `fvm dart format` on `lib test tool` (+ `integration_test`); the check names the unformatted files and says `make format` |
| `make analyze` | `fvm dart analyze --fatal-infos --fatal-warnings` |
| `make test`, `test-unit`, `test-widget`, `test-integration`, `test-tool`, `test-architecture` | `fvm flutter test` on the `test/<suite>` folders holding a `*_test.dart`; the others have "nothing to run", decided before any `fvm` call |
| `make test-coverage` | unit, widget, integration and tool suites with `--coverage --coverage-package=kiveto_mobile --coverage-package=kiveto_tool` into `coverage/lcov.info` (empty when no test) |
| `make coverage-gate` | `tool/coverage_gate.dart` (§8), its report shown live |
| `make test-scripts` | the plain-bash checks of `test/scripts/` (scripts, hooks, thin Dart entry points), one line per case |
| `make test-e2e` | phase 5 |
| `make api-sync REF=`, `api-generate`, `api-check` | Contract (§4), phase 4 |
| `make install-fvm` | Opt-in, current user only, from the official source; prints the `PATH` line instead of editing it (D10) |
| `make clean`, `make reset` | `flutter clean` + stamps; reset = clean + install |
| Options | `V=1`, `NO_COLOR=1`, `LOG_FILE=.make/make.log` — same as the Symfony Makefile |

The pub-get stamp compares `pubspec.yaml`, `pubspec.lock` and
`tool/pubspec.yaml` (phase 4 adds the generated package's pubspec) and the
Flutter pin. Quiet test runs use `--reporter failures-only`, so a failure
ends up in the 30 log lines printed.

Device selection: `DEVICE` → the single running device or emulator →
start `EMULATOR` or the first AVD and wait for `sys.boot_completed`
(bounded) → with `PLATFORM=ios` on macOS, the booted or named simulator.
Several candidates or none: list them and print the exact command.
`PLATFORM=ios` on Windows: explicit message.

Local backend: its routes are bound to the host `portal.kiveto.local`
(port 81), which an Android emulator cannot resolve. `dev.json` targets
`http://10.0.2.2:81` and a dev-only interceptor sets
`Host: portal.kiveto.local`. Clear-text HTTP is allowed in debug builds
only. The backend's 302 file redirects point to `portal.kiveto.local`
too; the dev interceptor rewrites them.

`make doctor` checks:

| Blocking | Warning |
|---|---|
| GNU Make ≥ 3.81 | Node ≥ 20.12 and uv (BMAD) |
| FVM ≥ 4 (Flutter 3.47.9 cached: blocker for `make start`) | Flutter 3.47.9 not cached yet (`make install`); global `core.autocrlf=true` (neutralised by `.gitattributes`) |
| Windows: Developer Mode (FVM symbolic links) | Windows long paths disabled; clone on a UNC path or with spaces |
| Android SDK with cmdline-tools and accepted licences | No AVD, no emulator acceleration (WHPX; AEHD unsupported after 2026-12-31) |
| Windows: the NDK Flutter asks for (28.2.13676358 for 3.47.9) | Elsewhere: that NDK missing (the first build installs it); NDK not checked until Flutter is installed |
| JDK ≥ 17 (`javac`) | Template platform (compileSdk 36) not installed |
| macOS: Xcode licence accepted and first launch done, Xcode ≥ 15, `xcode-select` | macOS: Xcode < 26 (App Store uploads need 26), no simulator runtime |

The NDK version is a literal `ndkVersion = "x"` of
`android/app/build.gradle.kts` if any, else the `val ndkVersion` of the
pinned SDK's `FlutterExtension.kt` (the SDK directory comes from
`fvm api list`); it is present when `ndk/<v>/source.properties` exists
under the Android SDK. Missing, it is a blocker on Windows, where Gradle
cannot install it (`sdkmanager.bat` of cmdline-tools 23 splits
`ndk;<v>` at the `;`); the fix is `cmdline-tools/latest/bin/android
--no-metrics sdk install ndk/<v>`, or SDK Manager › SDK Tools › NDK (Side
by side) with "Show Package Details". The full table is in
`_bmad-output/specs/spec-toolchain-bootstrap/make-targets.md`. CocoaPods
(optional with Swift Package Manager) and the local backend (phase 5) are
not checked.

## 8. Quality gates and tests

- **Analysis:** very_good_analysis 11 + riverpod_lint 3.1.9 (analyzer
  plugin); `dart analyze --fatal-infos --fatal-warnings`;
  `deprecated_member_use` as an error; `avoid_print`;
  `public_member_api_docs` off (an app, not a published API). Excluded:
  `build/`, `android/`, `ios/`, `packages/` (generated client),
  `lib/l10n/app_localizations*.dart` (gen-l10n output; any other file of
  `lib/l10n/` is analyzed). A justified exception is a
  `// ignore: <rule>` with its reason on the line above (the template
  `main.dart` ignores `riverpod_lint/missing_provider_scope` until phase 5
  wraps it in a `ProviderScope`).
- **Architecture:** the D15 rules of §3 in `test/architecture/`: one test
  per rule on the real `lib/`, and self-tests injecting a violation of
  each rule (a cycle included) and a compliant layout into temporary
  trees.
- **Suites:** unit (`test/unit/`, mirrors `lib/`), widget (`test/widget/`),
  integration without device (`test/integration/`: real wiring, real
  generated client, fake Dio `HttpClientAdapter` fed with contract JSON),
  tooling (`test/tool/`: the device picker, the scanner, the gate, with
  fixtures), plain-bash checks (`test/scripts/`: `lib.sh`, doctor, install,
  install-fvm, `test.sh`, `ci.sh`, `test-scripts.sh`, `format.sh`,
  `analyze.sh`, hooks, the entry points `tool/devices.dart` and
  `tool/coverage_gate.dart`, portability), end-to-end on a device
  (`integration_test/`, `make test-e2e`, not in `make ci`).
- **Coverage gate** (`tool/coverage_gate.dart` over `tool/lib/`, SDK
  libraries only, tested at 100% itself). `flutter test --coverage` leaves
  out of `lcov.info` every library no test loads (flutter/flutter#27997 was
  closed "not planned") and every library without executable line. The
  gate lists every `lib/**/*.dart` and `tool/**/*.dart` and decides per
  file: in `lcov.info` → its lines; absent but reachable from the
  `*_test.dart` roots through import / export / part directives → "no
  executable lines" (passes); absent and unreachable → "not loaded by any
  test", 0%. It prints its declared exclusions (`lib/main.dart`,
  `lib/l10n/app_localizations*.dart` gen-l10n output, `tool/*.dart` thin
  entry points) and an area × layer table, and fails on a gated file below
  100% (uncovered lines listed), a gated file no test loads,
  `coverage:ignore` in a gated file, a file outside the D15 layout (under
  `lib/app/`, only `bootstrap/`, `routing/`, `theme/` and files directly in
  it; under `lib/l10n/`, only the gen-l10n output), or a project package
  (`lib/`, `tool/lib/`) whose gated files tests load but which has no
  record at all in `lcov.info` (its `--coverage-package` dropped). `tool/`
  is a path package (`kiveto_tool`) so that `--coverage-package=kiveto_tool`
  measures it.

| Layer | Threshold (D6, D15) |
|---|---|
| `features/*/{domain,application,infrastructure}/`, `shared/domain/`, `core/{network,security,errors}/`, `tool/lib/` | 100%, blocking |
| `features/*/presentation/`, `shared/presentation/`, `app/`, `core/di/`, `features/*/di.dart`, `<feature>.dart` | measured, no threshold |

- **Hooks** (D9): `.githooks/commit-msg` (Conventional Commits; git's own
  merge, revert, fixup and squash messages accepted), `.githooks/pre-commit`
  (format of the staged content of the staged Dart files, `packages/` left
  out), activated by `make install` through the repository-local
  `core.hooksPath`.
- **CI** (D8): `.github/workflows/ci.yml`, GitHub Actions running
  `make ci V=1` on `ubuntu-24.04` for pull requests and pushes to
  `master`; actions pinned by commit SHA, FVM 4.3.2 from its release asset
  checked with `sha256sum`, FVM cache and pub cache cached. No macOS job
  for now.
- **Claude Code** (D14), **deferred**: `.claude/settings.json` with team
  permissions; a `PostToolUse` hook formatting edited Dart files (a Dart
  script — Git Bash has no `jq`); a `PreToolUse` hook refusing
  `git commit` until `make ci` has passed on the staged tree. Phase 3 could
  not write `.claude/settings.json`; it is listed in
  `_bmad-output/implementation-artifacts/deferred-work.md`.

## 9. BMAD

BMAD 6.12.4 (latest stable; v6 is frozen, v7 is an alpha) with `core` and
`bmm`, for Claude Code (D12). No TEA: its only fully supported mobile
target is Maestro, not `flutter_test` / `integration_test`. Agents talk in
French, documents in English (pinned in `_bmad/custom/config.toml`).
Workflow: `bmad-spec` → `bmad-build` (needs uv) → `bmad-code-review`;
`bmad-architecture` maintains this document; `bmad-project-context` writes
the `AGENTS.md` block once there is code, imported from `CLAUDE.md` with
`@AGENTS.md`. Personal files (`_bmad/config.user.toml`,
`_bmad/custom/*.user.toml`, `_bmad/render/`) are git-ignored.

## 10. Decisions

| # | Decision |
|---|---|
| D1 | Flutter 3.47.9 / Dart 3.13.7 through FVM 4.3.2 |
| D2 | Package `kiveto_mobile`; ids `app.kiveto.portal`; display name "Kiveto" (phase 2); Apple Team ID to provide |
| D3 | Generator chosen after a spike on the real contract (`swagger_parser` vs `tonik`) |
| D4 | Contract pinned by commit SHA while the backend has no tags |
| D5 | Generated client committed |
| D6 | 100% coverage for `domain/`, `application/`, `infrastructure/`; `presentation/` measured |
| D7 | Riverpod without code generation, no freezed |
| D8 | GitHub Actions running `make ci` on Linux |
| D9 | `.githooks` + repository-local `core.hooksPath` |
| D10 | FVM never installed automatically; `make install-fvm` opt-in; Developer Mode required on Windows |
| D11 | Native flavors later, at the first distribution; `--dart-define-from-file` until then |
| D12 | BMAD 6.12.4, `core` + `bmm`, no TEA |
| D13 | One root commit directly on `master`, then PRs only |
| D14 | Claude Code hook: no commit before `make ci` passes on the staged tree — deferred (not built in phase 3) |
| D15 | Source tree and features of the user (2026-11-03): `app/{bootstrap,routing,theme}`, technical `core/{network,security,errors,di}`, shared kernel `shared/{domain,presentation}`, features named after the Symfony bounded contexts (§2); the dependency rules 1–8 of §3 |

## 11. Phases and validation milestones

| # | Branch | Content | Milestone |
|---|---|---|---|
| 1 | root commit, `chore/repo-foundations` | Git attributes, editor config, ignores, `CLAUDE.md`, `CONTRIBUTING.md`, BMAD, this document | Documents reviewed; `bmad-help` answers in French |
| 2 | `chore/toolchain-bootstrap` | `.fvmrc`, `flutter create` (Android + iOS), `Makefile`, `scripts/`, `config/env` | **V1:** fresh clone on Windows → `make install` → `make start` on the AVD; a second `make start` reinstalls nothing; every missing prerequisite gives an actionable message. Same on macOS, plus the iOS simulator |
| 3 | `chore/quality-gates` | Analyzer config, architecture tests, coverage gate, hooks, `make ci`, GitHub Actions (Claude hooks deferred, D14) | **V2:** one injected violation per rule fails `make ci` with a clear message; riverpod_lint diagnostics fail `dart analyze` |
| 4 | `chore/portal-api-client` | Generator spike, `api-sync` / `api-generate` / `api-check`, generated package | **V3:** the client decodes `GET /me` from the local backend (demo phone +33612345678); a YAML drift fails `api-check` |
| 5 | `feature/app-shell` | `core/{network,security,errors,di}`: Dio, dev Host header, auth interceptor with one refresh, token storage, problem+json → failures, `Idempotency-Key`, `X-Device-Id`; `shared/`: `Clock`, value objects, UI kit; `app/`: bootstrap, router + `/invitation` deep link, theme from the mockup; French l10n | **V4:** N concurrent 401s trigger one refresh; 100% coverage |
| 6 | `feature/identity-access` | Slice 1 (`identity_access`): OTP sign-in, invitation, terms, empty home | **V5:** real flow on an emulator against the local backend |
| 7+ | `document` → `patient` + `consultation` + `home` → `scheduling` → `client` → requests → `clinic_listing` | Slices 2 to 7, in the contract's order | `make ci` green and a device demo per slice |

## 12. Risks

| Risk | Mitigation |
|---|---|
| OpenAPI 3.2 poorly supported by generators | Phase 4 spike; guarded 3.2 → 3.1 rewrite; 3.0 export as a fallback (backend change) |
| `date-time` decoded to `DateTime`, losing the clinic offset | Spike criterion; otherwise `ClinicInstant` + the IANA zone from `GET /me` |
| Young analyzer plugin ecosystem (0.x, one shared resolution, fetched from pub during analysis) | Few plugins; warm pub cache in CI; checked at V2 |
| FVM symbolic links on Windows | Developer Mode as a blocker in `make doctor` |
| macOS bash 3.2 and make 3.81 | Scripts written for them; V1 on a real Mac |
| iOS cannot be checked from Windows | A macOS validation at each milestone that touches iOS |
| Backend file redirects to `portal.kiveto.local` | Dev-only host rewrite |
| Universal links impossible on `.local` | Android via `adb shell am start -d`; iOS on staging with a real HTTPS domain |
| CocoaPods registry read-only from 2026-12-02 | Plugins with Swift Package Manager support (default since Flutter 3.44) |
| Built-in Kotlin in AGP 9 soon mandatory | Follow the Flutter template, check plugins |
| Patrol Windows-host issue (#3087) | `integration_test` first; Patrol or Maestro decided later |
| BMAD v6 frozen, v7 in alpha | Pinned version, planned migration |
