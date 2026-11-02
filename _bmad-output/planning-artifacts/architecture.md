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

Cut from the screens and operations of the contract, not from the 22
backend contexts.

| Feature | Screens | API tags | Backend contexts read | Slice |
|---|---|---|---|---|
| `session` | 0, 7, 8, 9 | Authentification, Invitation, CGU | IdentityAccess, ClientPortal | 1 (7 for registration) |
| `home` | 1 | Animaux (`/home`) | ClientPortal | 3 |
| `pets` | 2 | Animaux, Demandes (change requests) | Animal, ClientPortal | 3, 6 |
| `appointments` | 3, 4, 12–16 | Rendez-vous, questionnaire | Scheduling, ClientPortal | 4, 6 |
| `documents` | 5, 17 | Documents, Fichiers, renewal requests | ClientPortal, Billing, Prescription | 2, 6 |
| `account` | 6 | Compte, Consentements | ClientPortal, IdentityAccess, Client | 5 |
| `directory` | 10, 11 | Annuaire, link suggestions | ClinicListing, ClientPortal | 7 |

`lib/core/` is the shared kernel (cross-cutting value objects, HTTP
client, interceptors, storage, UI kit). `lib/app/` is the composition root
(bootstrap, router, theme, localisation, `ProviderScope`). The active
clinic (every `/clinics/{c}` route) is exposed by `account` through its
public API.

## 3. Layers and dependency rules

```
presentation ──► application ──► domain ◄── infrastructure
      │                                         ▲
      └────────── di.dart (the only bridge) ────┘
```

| Layer | Contains | May import |
|---|---|---|
| `domain/` | models, value objects, sealed failures, repository contracts | `dart:core/async/collection/math`, its own domain, `core/domain` — no package |
| `application/` | use cases **only** where something is orchestrated (e.g. `SignInWithCode`: verify, then branch on `authenticated` / `invitation_pending` / `registration_required`), state machines | + its domain, `core/application` — no Flutter, Riverpod or Dio |
| `infrastructure/` | repositories on the generated client, DTO → domain mapping, storage | + `dio`, `kiveto_portal_api`, `core/infrastructure` — never `presentation/` |
| `presentation/` | pages, widgets, Riverpod notifiers (view models), routes | Flutter, Riverpod, go_router — never `infrastructure/`, Dio or the generated client |
| `di.dart` | providers binding each domain contract to its implementation | the only non-test file importing `infrastructure/` |
| `<feature>.dart` | the feature's public API | the only entry point for other features; no cycles |

Rules checked by `test/architecture/` (phase 3), written like the Symfony
`tests/Unit/Architecture/` tests (scan of `import`/`export` directives,
plus self-tests that inject offending files):

1. `domain/` imports no package, nor `dart:io` / `dart:ui`.
2. `application/` imports no Flutter, Riverpod, Dio or generated client.
3. `presentation/` never imports `infrastructure/`, Dio or `kiveto_portal_api`.
4. Only `di.dart` and tests import `infrastructure/`.
5. A feature imports another only through `<feature>.dart`; acyclic graph.
6. `core/` imports no feature.
7. `kiveto_portal_api` only under `**/infrastructure/**`.
8. `DateTime.now(` (use the `Clock` port), `print(` and `coverage:ignore`
   are forbidden in `domain/` and `application/`.

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
- Only `**/infrastructure/**` and `core/infrastructure` import it.
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

| Role | Choice | Version | Why |
|---|---|---|---|
| SDK | Flutter via FVM | 3.47.9 (Dart 3.13.7), FVM 4.3.2 | Current stable; riverpod_lint and very_good_analysis 11 need Dart ≥ 3.13 (D1) |
| State + DI | flutter_riverpod | 3.4.3 | Riverpod 3 stable; typed DI, overrides in tests, `AsyncValue` |
| State lint | riverpod_lint | 3.1.9 | Ships on the analyzer plugin system (`plugins:` in `analysis_options.yaml`), reported by `dart analyze` |
| Lints | very_good_analysis | 11.0.0 | Strictest maintained rule set |
| Routing | go_router | 18.1.2 | Maintained by the Flutter team; deep link `/invitation#t=` |
| HTTP | dio | 5.11.1 | `QueuedInterceptor` gives one refresh in flight |
| Tokens | flutter_secure_storage | 11.2.0 | Keychain / Keystore; minSdk 24 = template default |
| Preferences | shared_preferences | 2.5.6 | Active clinic |
| Localisation | flutter_localizations + gen-l10n (ARB) | SDK | The contract returns codes; labels are translated in the app |
| Tests | flutter_test, integration_test, mocktail | SDK, 1.0.5 | No goldens in `make ci` |
| Coverage report | coverde | 0.4.1 | HTML without Perl / genhtml |

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
├── .githooks/                  # pre-commit, commit-msg (bash 3.2)
├── .github/workflows/ci.yml    # make ci on Linux
├── .claude/settings.json       # team permissions and hooks
├── .claude/skills/             # BMAD skills
├── _bmad/  _bmad-output/{planning-artifacts,implementation-artifacts}/
├── CLAUDE.md  CONTRIBUTING.md  README.md
├── Makefile                    # thin, delegates to scripts/
├── analysis_options.yaml  l10n.yaml  pubspec.yaml  pubspec.lock
├── config/env/{dev.json.dist,staging.json,prod.json}   # --dart-define-from-file; dev.json ignored
├── contracts/{portal.v1.yaml,SOURCE}
├── packages/kiveto_portal_api/ # generated, committed
├── scripts/                    # bash 3.2: lib, doctor, install, start, devices, api-sync
├── tool/                       # Dart: coverage_gate, api_generate
├── lib/{main.dart,app/,core/,l10n/,features/<feature>/}
├── test/{unit,widget,integration,architecture,support}/
├── integration_test/
└── android/  ios/              # applicationId / bundle id app.kiveto.portal
```

Identity (D2): Dart package `kiveto_mobile`; Android `applicationId` and
iOS bundle id `app.kiveto.portal`, the ids the backend serves in its
`.well-known` files (`PORTAL_ANDROID_PACKAGE`, `PORTAL_IOS_APP_ID`).
Still to provide: the display name and the Apple Team ID (the backend
holds the placeholder `ABCDE12345`).

## 7. Developer experience

Same contract on Windows 11 (Git Bash) and macOS:
`make install`, `make start`, `make ci`.

Portability rules:

- The `Makefile` is thin and compatible with **GNU Make 3.81** (macOS's
  `/usr/bin/make`): no `.ONESHELL`, `$(file)`, `!=` or grouped targets.
  `SHELL := bash`, resolved on `PATH` (a native Windows make has no
  `/bin/bash`) — to validate in phase 2.
- Logic lives in `scripts/*.sh`, written for **bash 3.2** (no
  `declare -A`, `${v,,}`, `mapfile`, `printf '%(…)T'`, `[[ -v ]]`), LF only.
- Anything that runs once Flutter is installed is Dart, in `tool/`.

| Target | Contract |
|---|---|
| `make doctor` | Read-only. Checks every prerequisite, says how to fix it, fails on a blocker. `FULL=1` adds `flutter doctor -v`. |
| `make install` | doctor (blockers) → `fvm install` (no-op when cached) → `pub get` → `git config core.hooksPath .githooks` (repository-local) → `config/env/dev.json` from `.dist` if missing → summary. Idempotent; installs nothing system-wide. |
| `make start` | `pub get` only when a `pubspec` changed (stamp in `.make/`) → device selection → `fvm flutter run -d <id> --dart-define-from-file=config/env/$(ENV).json`. Options `PLATFORM`, `DEVICE`, `EMULATOR`, `SIMULATOR`, `ENV`. |
| `make devices` | Connected devices, AVDs, simulators. |
| `make ci` | `format-check → analyze → test-architecture → test (unit + widget + integration, with coverage) → coverage-gate → api-check` |
| `make format`, `format-check`, `analyze`, `test`, `test-unit`, `test-widget`, `test-integration`, `test-coverage`, `test-e2e` | Single steps |
| `make api-sync REF=`, `api-generate`, `api-check` | Contract (§4) |
| `make install-fvm` | Opt-in, current user only, from the official source; prints the `PATH` line instead of editing it (D10) |
| `make clean`, `make reset` | `flutter clean` + stamps; reset = clean + install |
| Options | `V=1`, `NO_COLOR=1`, `LOG_FILE=.make/make.log` — same as the Symfony Makefile |

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
| FVM ≥ 4 and Flutter 3.47.9 cached | Global `core.autocrlf=true` (neutralised by `.gitattributes`) |
| Windows: Developer Mode (FVM symbolic links) | Windows long paths disabled; clone on a UNC path or with spaces |
| Android SDK with cmdline-tools and accepted licences | No AVD, no emulator acceleration (WHPX; AEHD unsupported after 2026-12-31) |
| JDK ≥ 17 (`javac`) | Template platform (compileSdk 36) not installed |
| macOS: Xcode ≥ 15, `xcode-select`, a simulator runtime | macOS: Xcode < 26 (App Store uploads need 26), no CocoaPods |
| | Local backend unreachable |

## 8. Quality gates and tests

- **Analysis:** very_good_analysis 11 + riverpod_lint;
  `dart analyze --fatal-infos --fatal-warnings`; `deprecated_member_use`
  as an error; `avoid_print`. Generated code excluded.
- **Architecture:** §3 rules in `test/architecture/`.
- **Suites:** unit (`test/unit/`, mirrors `lib/`), widget (`test/widget/`),
  integration without device (`test/integration/`: real wiring, real
  generated client, fake Dio `HttpClientAdapter` fed with contract JSON),
  end-to-end on a device (`integration_test/`, `make test-e2e`, not in
  `make ci`).
- **Coverage gate** (`tool/coverage_gate.dart`, no dependency, tested
  itself): lists every `lib/**/*.dart`, counts files missing from
  `lcov.info` as 0% (flutter/flutter#27997 was closed "not planned"),
  prints its declared exclusions (`lib/main.dart`, gen-l10n output) and a
  feature × layer table.

| Layer | Threshold (D6) |
|---|---|
| `domain/`, `application/`, `infrastructure/` | 100%, blocking |
| `presentation/`, `app/` | measured, no threshold |

- **Hooks** (D9): `.githooks/commit-msg` (Conventional Commits regex),
  `.githooks/pre-commit` (format of staged Dart files), activated by
  `make install` through the repository-local `core.hooksPath`.
- **CI** (D8): GitHub Actions running `make ci` on Linux. No macOS job for
  now.
- **Claude Code** (D14): `.claude/settings.json` with team permissions; a
  `PostToolUse` hook formatting edited Dart files (a Dart script — Git
  Bash has no `jq`); a `PreToolUse` hook refusing `git commit` until
  `make ci` has passed on the staged tree.

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
| D2 | Package `kiveto_mobile`; ids `app.kiveto.portal`; display name and Apple Team ID to provide |
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
| D14 | Claude Code hook: no commit before `make ci` passes on the staged tree |

## 11. Phases and validation milestones

| # | Branch | Content | Milestone |
|---|---|---|---|
| 1 | root commit, `chore/repo-foundations` | Git attributes, editor config, ignores, `CLAUDE.md`, `CONTRIBUTING.md`, BMAD, this document | Documents reviewed; `bmad-help` answers in French |
| 2 | `chore/toolchain-bootstrap` | `.fvmrc`, `flutter create` (Android + iOS), `Makefile`, `scripts/`, `config/env` | **V1:** fresh clone on Windows → `make install` → `make start` on the AVD; a second `make start` reinstalls nothing; every missing prerequisite gives an actionable message. Same on macOS, plus the iOS simulator |
| 3 | `chore/quality-gates` | Analyzer config, architecture tests, coverage gate, hooks, `make ci`, GitHub Actions, Claude hooks | **V2:** one injected violation per rule fails `make ci` with a clear message; riverpod_lint diagnostics fail `dart analyze` |
| 4 | `chore/portal-api-client` | Generator spike, `api-sync` / `api-generate` / `api-check`, generated package | **V3:** the client decodes `GET /me` from the local backend (demo phone +33612345678); a YAML drift fails `api-check` |
| 5 | `feature/app-shell` | `core/`: Dio, dev Host header, auth interceptor with one refresh, token storage, problem+json → failures, `Idempotency-Key`, `X-Device-Id`, router + `/invitation` deep link, theme from the mockup, French l10n | **V4:** N concurrent 401s trigger one refresh; 100% coverage |
| 6 | `feature/session` | Slice 1: OTP sign-in, invitation, terms, empty home | **V5:** real flow on an emulator against the local backend |
| 7+ | `documents` → `pets` + `home` → `appointments` → `account` → requests → `directory` | Slices 2 to 7, in the contract's order | `make ci` green and a device demo per slice |

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
