# Contributing to Kiveto Mobile

This document is the source of truth for how we work on Kiveto Mobile:
git flow, conventions, commands, architecture rules, tests, the API
contract and the BMAD workflow. Human contributors and AI agents follow
it; AI agents also obey `CLAUDE.md`.

The conventions are shared with the Kiveto Symfony repository wherever
they make sense for a Flutter app. The architecture decisions and their
rationale are in `_bmad-output/planning-artifacts/architecture.md`.

---

## 0. Bootstrap status

The repository is being bootstrapped in phases; each phase ends with a
validation milestone before the next one starts. Until a phase is done,
the commands and checks it brings **do not exist** — do not rely on them.

| Phase | Branch | Brings | Status |
|---|---|---|---|
| 1 | root commit, `chore/repo-foundations` | Git attributes, editor config, ignores, `CLAUDE.md`, `CONTRIBUTING.md`, BMAD 6.12.4, architecture decisions | Done |
| 2 | `chore/toolchain-bootstrap` | `.fvmrc`, Flutter project (Android + iOS), `Makefile`, `scripts/` (`doctor`, `install`, `install-fvm`, `start`, `devices`, `clean`), `tool/devices.dart`, environment config | Done (validated on Windows and macOS) |
| 3 | `chore/quality-gates` | very_good_analysis + riverpod_lint, architecture tests of the D15 rules, coverage gate, `tool/` as the `kiveto_tool` package, `make ci` and its steps, plain-bash checks of the scripts, git hooks, GitHub Actions, doctor NDK check | Done (validated on Windows; macOS run and first GitHub Actions run pending) |
| 4 | `chore/portal-api-client` | Generator spike (tonik 0.11.1, D3), contract copy pinned by commit (`contracts/`), contract normaliser, generated client `packages/kiveto_portal_api` (committed, stamped), `make api-sync` / `api-generate` / `api-check` (`api-check` in `make ci`), app dependencies `dio` and `tonik_util`, rule 7 on `tonik_util`, contract fixtures and their integration test | Done (validated on Windows; macOS run pending) |
| 5 | `feature/app-shell` | `lib/core/{network,security,errors,di}`: HTTP client, auth and refresh, token storage, errors; `lib/shared/`: `Clock`, value objects, UI kit; `lib/app/{bootstrap,routing,theme}`: `ProviderScope`, router, theme; French l10n | Done (validated on Windows and the Android emulator; iOS not built) |
| 6 | `feature/identity-access` | Slice 1: `identity_access` (screens 7 Bienvenue, 8 Code, 9 Inscription, 0 Activation, the pending invitations, the logout) and a minimal `client` (`GET /me`, the active clinic in `shared_preferences`); the reactive `sessionStatusProvider`; the shell seams filled; a `/home` placeholder proving the session; `shared_preferences` 2.5.6 and `url_launcher` 6.3.3 | Done (validated on Windows and the Android emulator against the local backend: sign-in, restart, logout, two pending invitations, the invitation link, the expired link cold and warm, a clinic-less account, a registration; iOS not built) |
| 7 | `feature/document` | Slice 2: `document` (screen 5 Documents: filters, cursor pagination, pull-to-refresh, the in-app PDF viewer, the prescription sheet and the renewal control), `PortalFile` in `shared/domain`, the unread badge refreshed after a read; `pdfrx` 2.11.0 | Done (validated on Windows and the Android emulator against the local backend: Julien Paris and Lyon, the badge after a read, Garnier's 51 documents and prescriptions, real PDFs; iOS not built) |
| 8 | `feature/patient-home` | Slice 3: `home` (screen 1 Accueil: the active clinic and its switcher, the next appointment, the pets, the care due dates, the latest documents), `patient` (screen 2 Fiche animal: pet switcher, identity, care items and their pills, the vaccination booklet, the change-request entry point), `consultation` (the paginated visit history), the clinic switcher sheet in `client`; the shared vocabulary (`CareStatus`, `Species`, `DocumentKind`, `PaymentStatus`) in `shared/domain`; contract synced at backend `bcb8d8b1` (`booked` care status) | Done (validated on Windows and the Android emulator against the local backend: Julien Paris and Lyon switched from the home, the Documents tab and badge following, a document and both booklets opened; Garnier's four-pet home, overdue items, Oscar's 23-visit history across two pages, Nala, Filou deceased; iOS not built; the backend commit is not merged into the backend's master yet) |
| 9 | `feature/scheduling` | Slice 4: `scheduling` (the booking wizard 12 → 13 → 3 → 14 with one `BookingDraft` and its `Idempotency-Key`, a new pet booked with its appointment, the 7-day week picker over 14-day windows, `409 slot_taken` struck and reloaded, « Demande envoyée » for a pending booking; screen 4 Rendez-vous with cursor-paginated tabs, « Reporter » / « Annuler » within the server's window; the cancellation sheet 16 with the care warning; the reschedule on the same picker; the `.ics` handed to the share sheet); the clinic's phone and address from `/me` (contract synced at backend `aa35f2c4`); the home and the care items reload after every change; `share_plus` 13.3.1 | Done (validated on Windows and the Android emulator against the local backend: Julien booked Oslo, moved it, cancelled it, booked a vaccination (« RDV pris » on the home and the pet sheet) and cancelled it from the sheet with its warning, the share sheet with the `.ics`, the dialer from 13, the clinic switch from 12; a test client booked a new pet on a motif the clinic confirms (« Demande envoyée ») and cancelled it; iOS not built; the backend branch is not merged into the backend's master yet) |
| 10+ | `feature/<feature>` | The Portal slices, in the backend contract's order | To do |

Update this table in the PR that completes a phase.

---

## 1. Git flow

GitHub Flow with a single long-lived branch:

- **`master`** is always releasable and always green (`make ci` passes once
  it exists). Every change reaches it through a Pull Request; direct
  pushes are forbidden.
- **`feature/*`, `fix/*`, `hotfix/*`, `chore/*`** are ephemeral: branched
  off the latest `master`, merged back by PR, then deleted.
- There is no `staging` branch.

The only commit made directly on `master` is the repository's root commit
(the repository was created empty and a PR needs a base branch).

---

## 2. Branch naming

Pattern: `<type>/<short-slug>`, kebab-case, English.

| Type       | When to use it                                                  | Example                        |
|------------|-----------------------------------------------------------------|--------------------------------|
| `feature/` | A new user-visible capability                                   | `feature/otp-sign-in`          |
| `fix/`     | A bug fix scoped to existing behaviour                          | `fix/refresh-token-race`       |
| `hotfix/`  | An urgent production fix                                        | `hotfix/crash-on-launch`       |
| `chore/`   | Tooling, dependencies, refactoring, docs — no user-visible change | `chore/quality-gates`        |

One branch = one logical change. If a branch starts doing two things,
split it.

---

## 3. Commit messages — Conventional Commits

```
<type>(<scope>): <short imperative summary>

<optional body explaining the why, wrapping at ~72 chars>

<optional footers (Co-Authored-By, Refs, BREAKING CHANGE, …)>
```

| Type       | Use it for                                          |
|------------|-----------------------------------------------------|
| `feat`     | A user-visible feature                              |
| `fix`      | A bug fix                                           |
| `test`     | Adding or fixing tests (no production code change)  |
| `refactor` | A change that neither fixes a bug nor adds a feature |
| `chore`    | Tooling, dependencies, generated files              |
| `docs`     | Documentation only                                  |
| `style`    | Formatting only                                     |
| `perf`     | A performance improvement                           |
| `build`    | Build system, Gradle, Xcode, packaging              |
| `ci`       | CI configuration only                               |
| `revert`   | Reverting an earlier commit (git's own `Revert "…"` also passes) |

Scope: a feature (`identity_access`, `client`, `patient`, `consultation`,
`scheduling`, `document`, `clinic_listing`, `home`) or `core`, `shared`,
`app`, `api`, `tooling`, `ci`, `bmad`.

```
feat(scheduling): book a slot for a known pet
fix(core): serialise concurrent token refreshes
chore(api): sync portal contract 1a2b3c4
```

The body explains **why**; the diff already shows what. The `commit-msg`
hook refuses any other subject; git's own messages (`Merge …`,
`Revert "…"`, `fixup! …`, `squash! …`) pass.

---

## 4. Pull Request workflow

```
<type>/* ──► PR → master
                 │
             make ci green locally, then GitHub Actions re-runs it
                 │
             Review (human or AI)
                 │
             Squash-merge → master
```

- The PR title follows the format of the squash commit it will produce.
- The PR body describes the change, links the BMAD spec and the backend
  slice or contract commit when relevant, and lists the manual checks done
  on a device.
- At least one approval for any PR touching `lib/`.

---

## 5. Local development

### Prerequisites

| Tool | Windows 11 | macOS | Why |
|---|---|---|---|
| Git | Git for Windows (Git Bash) | Xcode Command Line Tools or Homebrew | — |
| GNU Make ≥ 3.81 | `winget install ezwinports.make` (Git for Windows has no `make`) | `/usr/bin/make` (3.81) | Entry point of every command |
| FVM ≥ 4 | `choco install fvm`, or the release archive from GitHub | `brew tap btwld/fvm && brew install btwld/fvm/fvm` | Pins Flutter (`.fvmrc`) |
| Developer Mode | Settings › System › For developers | — | FVM creates symbolic links |
| Android Studio | With the SDK, cmdline-tools, an emulator, licences accepted, and NDK (Side by side) 28.2.13676358, the version Flutter 3.47.9 asks for: SDK Manager › SDK Tools › NDK (Side by side) with "Show Package Details", or `android --no-metrics sdk install ndk/28.2.13676358` from `cmdline-tools/latest/bin` (on Windows with cmdline-tools 23.0, Gradle cannot install it itself: `sdkmanager.bat` splits `ndk;28.2.13676358` at `;`) | Same | Android builds and emulator |
| JDK ≥ 17 | Android Studio's or an installed JDK (a JRE is not enough) | Same | Gradle |
| Xcode ≥ 26 | — | App Store, then `sudo xcodebuild -license accept` and `sudo xcodebuild -runFirstLaunch` (until the licence is accepted, `/usr/bin/make` and `/usr/bin/git` refuse to run, so `make doctor` cannot start: run `bash scripts/doctor.sh`), and an iOS simulator runtime (Xcode › Settings › Components) | iOS builds and simulator (Xcode 26 is required for App Store uploads) |
| C toolchain and network on the first build | Visual Studio Build Tools (MSVC, "Desktop development with C++") | Xcode Command Line Tools (Linux CI: gcc or clang) | `pdfrx` (the in-app PDF viewer, slice 2): its native-assets hook (`pdfium_dart`) compiles a small C library and downloads the PDFium binary from `github.com/bblanchon/pdfium-binaries` (release `chromium/8125`) on the first `flutter test` / `make ci` and the first Android build, then reuses it from `.dart_tool/` and `build/` |
| Node ≥ 20.12 and uv | | | BMAD only (`bmad-build` halts without uv) |

Keep the clone on a local disk, in a path without spaces (not on a
`\\wsl.localhost\…` share).

### Commands

Run them from Git Bash on Windows, from any terminal on macOS. Every
Flutter and Dart call goes through FVM (`fvm flutter …`, `fvm dart …`),
pinned to the version of `.fvmrc`.

```bash
make help          # targets and options (default goal)
make doctor        # read-only: every prerequisite, with the fix of each missing one (FULL=1 adds flutter doctor -v)
make install       # prerequisites, pinned Flutter (fvm install), pub get, git hooks, config/env/dev.json
make start         # run the app; boots the first AVD (or EMULATOR=) when no device runs
make devices       # connected devices, AVDs and, on macOS, simulators
make install-fvm   # opt-in: FVM 4.3.2 for the current user only, SHA-256 checked; prints the PATH line
make clean         # fvm flutter clean + the .make/ stamps (the log is kept)
make reset         # clean + install

make ci                 # the quality gate: every step below, in this order, stops at the first failure
make format-check       # 1. fvm dart format check of lib/, test/, tool/ (make format rewrites them)
make analyze            # 2. fvm dart analyze --fatal-infos --fatal-warnings
make test-architecture  # 3. the layer and feature rules (test/architecture/)
make test-coverage      # 4. unit, widget, integration and tool suites with coverage (coverage/lcov.info)
make coverage-gate      # 5. 100% of the gated layers, every file of lib/ and tool/ counted
make test-scripts       # 6. plain-bash checks of scripts/ and .githooks/ (test/scripts/)
make api-check          # 7. the contract copy, contracts/SOURCE and the generated client agree
make test               # every Flutter suite, without coverage
make test-unit          # one suite: also test-widget, test-integration, test-tool

make api-sync REF=<sha> # copy the backend contract at that commit, then api-generate (§8)
make api-generate       # regenerate packages/kiveto_portal_api from contracts/portal.v1.yaml
```

Options: `PLATFORM=android|ios` (default `android`; iOS needs macOS),
`DEVICE=<id>`, `EMULATOR=<avd>`, `SIMULATOR=<name>`, `ENV=dev` (passes
`config/env/<ENV>.json` with `--dart-define-from-file`), `RUN_ARGS=`
(extra `flutter run` flags, e.g. `--release`), `BOOT_WAIT=180` (seconds),
`REF=<backend commit>` and `KIVETO_BACKEND_DIR=<backend checkout>` (default
`../kiveto`) for `make api-sync`, `V=1`, `NO_COLOR=1`,
`LOG_FILE=.make/make.log`. Quiet steps write their
output, timestamped, to `LOG_FILE` and print its last 30 lines when they
fail; `V=1` runs them live and shows every command (`make ci V=1`).
`make install` and `make start` are idempotent: `pub get` runs only when
`pubspec.yaml`, `pubspec.lock`, `tool/pubspec.yaml` or
`packages/kiveto_portal_api/pubspec.yaml` changed (stamp in `.make/`). A
test suite without `*_test.dart` has nothing to run, which is not a
failure. `make ci` prints the duration of each step and the total (about
two minutes on a warm machine, most of it in `test-scripts`).

Nothing installs system-wide software: `make doctor` explains what is
missing and how to install it; `make install-fvm` installs FVM for the
current user only, and only when you run it. `make install` activates the
git hooks for this clone only (`core.hooksPath=.githooks`). The contract of
each target is in the architecture document, §7 Developer experience.
`make ci` also runs on Linux (GitHub Actions); the other targets are for
Windows and macOS.

### Quality controls

| Rule | Enforced by | Available from |
|---|---|---|
| Formatting (`dart format`) | `make ci`, pre-commit hook (staged content) | Now |
| Static analysis (very_good_analysis, riverpod_lint, infos and warnings fatal) | `make ci` | Now |
| Layer and feature boundaries (§6 rules 1–8) | `test/architecture/` in `make ci` | Now |
| Tests green (unit, widget, integration without device, tooling) | `make ci` | Now |
| 100% coverage of the gated layers (§7) | Coverage gate in `make ci` | Now |
| Scripts and hooks behave, stay bash 3.2 and LF | `test/scripts/` in `make ci` | Now |
| Conventional Commits | `commit-msg` hook | Now |
| `make ci` green on every PR | GitHub Actions (`.github/workflows/ci.yml`) | Written, not run yet; make the check required on `master` (branch protection) |
| Contract copy unedited, generated client matches it (§8) | `make api-check` in `make ci` | Now |
| End-to-end tests on a device | `make test-e2e`, run by hand | Deferred (not built by slice 1; the slice is checked by hand on the emulator) |
| No commit before `make ci` passed on the staged tree | Claude Code hook (D14) | Deferred |

Until a control is available, the rule still applies and the author checks
it by hand.

---

## 6. Architecture

Feature-first DDD and Clean Architecture (architecture §2–§3, D15). Each
feature is a bounded context of the mobile app, named after the Symfony
bounded context it reads and cut from the screens and flows of the Portal
API.

```
lib/
├── main.dart
├── app/{bootstrap,routing,theme}/   # composition root: env, ProviderScope, runApp / go_router, shell / ThemeData, tokens
├── core/                            # technical core, no business rule
│   ├── network/   security/   errors/   di/   # Dio + interceptors + problem+json / tokens, session, device id / ApiFailure / core providers
├── shared/{domain,presentation}/    # shared kernel: pure Dart value objects, Clock, common failures / UI kit, formatters
├── l10n/                            # app_fr.arb + gen-l10n output
└── features/<bounded_context>/
    ├── domain/          # models, value objects, sealed failures, repository contracts — pure Dart
    ├── application/     # use cases with real orchestration, state machines — pure Dart
    ├── infrastructure/  # repositories on the generated client, DTO → domain mapping
    ├── presentation/    # pages, widgets, Riverpod notifiers, routes
    ├── di.dart          # binds the domain contracts to their implementations
    └── <bounded_context>.dart   # the feature's public API
```

Features: `identity_access` (sign-in, invitation, refresh, logout, e-mail
change and deletion), `client` (profile, clinics, consents, export, active
clinic, link suggestions), `patient` (pet sheet, change requests),
`consultation` (visit history), `scheduling` (appointments, booking,
questionnaire, `.ics`), `document` (documents, prescriptions),
`clinic_listing` (directory), `home` (composes the others through their
public APIs). The screen numbers are in the architecture document, §2.

Dependency rules, checked by `test/architecture/` in `make ci`:

1. `features/*/domain/` and `shared/domain/` import no package: only
   `dart:core/async/collection/math`, their own domain and `shared/domain/`.
2. `features/*/application/` adds its own domain and application and
   `shared/domain/`; no Flutter, Riverpod, Dio, generated client or `core/`.
3. `features/*/presentation/` and `shared/presentation/` never import an
   `infrastructure/`, Dio, the generated client, `core/network/` or
   `core/security/`.
4. Only `features/*/di.dart`, `core/di/`, `app/bootstrap/` and tests
   import a feature's `infrastructure/` (its own `infrastructure/` files
   may import each other). The `core/di/` exception never applies: rule 6
   forbids `core/` to import any feature, so the feature wiring lives in
   `features/*/di.dart` and `app/bootstrap/`.
5. A feature imports another one only through
   `features/<other>/<other>.dart`; the feature graph has no cycle.
6. `core/` and `shared/` import no feature; `shared/` imports nothing from
   `core/` or `app/`.
7. The generated client (`kiveto_portal_api`) and its runtime
   (`tonik_util`: `TonikResult`, `OffsetDateTime`, `Date`, `ServerConfig`)
   are imported only under `features/*/infrastructure/`, `core/network/`
   and `core/di/`.
8. `DateTime.now` / `DateTime.timestamp` (inject the `Clock`), `print(` and
   `coverage:ignore` are forbidden in `features/*/domain/`,
   `features/*/application/` and `shared/domain/`.

An offence reads `[rule N] lib/<path>:<line> imports <uri> — <what the rule
allows> (architecture §3, D15)`. The self-tests of
`test/architecture/architecture_self_test.dart` inject a violation of each
rule into a temporary tree.

The backend owns the business rules. The app types what the API returns,
maps its error codes to sealed failures, and owns only the client-side
policies: session lifecycle, one token refresh at a time, a stable
`Idempotency-Key` per user intent, the booking wizard state.

### App foundation (phase 5)

- **Material** comes from `package:material_ui/material_ui.dart` (go_router
  18 is built on it): never import `package:flutter/material.dart` (nor
  `package:flutter/cupertino.dart`: `cupertino_ui` replaces it), or the
  app gets a second `MaterialApp`, `Theme` and `MaterialLocalizations`
  that go_router does not see; `test/architecture/material_ui_test.dart`
  fails on either import.
- **Failures:** repositories throw the sealed `ApiFailure` of
  `lib/shared/domain/api_failure.dart` (`switch (await api.getMe()) {
  TonikSuccess(value: GetMeResponse200(:final body)) => …, final other =>
  throw apiFailureOf(other, failures) }`, `core/network/portal_results.dart`);
  the presentation pattern-matches it, `ErrorView` and `failureMessage`
  give the French title and body. No generic `Result`.
- **Session and HTTP:** the generated client runs on
  `portalServerProvider` (`core/di/`): strict status, dev `Host`,
  `X-Device-Id`, `Authorization` with one refresh in flight. An intent that
  must not be applied twice holds one `IdempotencyKey` for all its retries.
  What belongs to the account (`meProvider`, the active clinic…) watches
  `sessionStatusProvider` (`core/di/`): it rebuilds on every sign-in and
  sign-out, never on a token refresh; read it through `AsyncData` patterns
  or `AsyncValueView`, never `.value` (a reload keeps the previous
  account's value).
- **Files:** download them through `PortalFileDownloader`
  (`portalFileDownloaderProvider`), never through the generated 302
  operations (`getDocumentFile`, `getVaccinationBooklet`,
  `getDataExportFile`): those follow the redirect inside `dart:io`, which on
  the dev emulator fails on the unresolvable dev host.
- **UI kit** (`lib/shared/presentation/`): the tokens, the Lucide icons and
  the components of the mockup (`KivetoButton.primary`, `KivetoBottomNav`…);
  build screens from them, never from raw colours or `TextStyle`s. The
  debug-only gallery `/debug/kit` shows them all (link on the welcome page).
- **Strings:** every user-facing string goes in `lib/l10n/app_fr.arb`, keys
  prefixed by area; run `fvm flutter gen-l10n` after an ARB edit and commit
  the generated `app_localizations*.dart`.
- **Shell seams:** the slices fill `unreadDocumentsCountProvider`,
  `accountInitialsProvider` and `hasConfirmedClinicProvider`
  (`lib/app/routing/shell_seams.dart`) with `ProviderScope` overrides in
  `app/bootstrap` (`featureOverrides()`).
- **Navigation from a feature:** features never import `app/`; a page
  takes its exits as `void Function(BuildContext)` callbacks, built by
  `app/routing/app_router.dart` on `AppRoutes`.

---

## 7. Tests and coverage

| Suite | Directory | Covers | In `make ci` |
|---|---|---|---|
| Unit | `test/unit/` (mirrors `lib/`) | domain, application, infrastructure | Yes (`make test-unit`) |
| Widget | `test/widget/` (mirrors `lib/**/presentation`) | pages and widgets: empty / short / long lists, states, errors | Yes (`make test-widget`) |
| Integration | `test/integration/` (shared helpers in `test/support/`) | complete flows without a device: real wiring, real generated client, fake HTTP adapter fed with contract JSON (`portal_api_contract_test.dart` decodes every contract fixture) | Yes (`make test-integration`) |
| Tooling | `test/tool/` (fixtures in `test/tool/fixtures/`) | `tool/lib/`: the device picker, the Dart scanner, the coverage gate, the contract commands (`portal_api.dart`, SHA-256 included), the contract normaliser | Yes (`make test-tool`) |
| Architecture | `test/architecture/` | the rules of §6, with self-tests that inject violations | Yes (`make test-architecture`) |
| Scripts | `test/scripts/*_test.sh` (plain bash, `support.sh`) | `scripts/lib.sh`, doctor and install, install-fvm, `test.sh`, `ci.sh`, `test-scripts.sh`, `format.sh`, `analyze.sh`, `api.sh`, the git hooks, the entry points `tool/devices.dart`, `tool/coverage_gate.dart`, `tool/portal_api.dart` and `tool/normalize_contract.dart`, bash 3.2 portability | Yes (`make test-scripts`) |
| End-to-end | `integration_test/` | emulator or simulator against the local backend | No (`make test-e2e`, deferred) |

Coverage policy:

- **Gated at 100% line coverage**, file by file:
  `features/*/{domain,application,infrastructure}`, `shared/domain`,
  `core/{network,security,errors}` and `tool/lib`. **Measured**, without
  threshold: `features/*/presentation`, `shared/presentation`, `app/`,
  `core/di`, `features/*/di.dart` and `<feature>.dart`.
- `flutter test --coverage` leaves out of `lcov.info` the libraries no test
  loads and those without any executable line. The coverage gate
  (`tool/coverage_gate.dart`, `make coverage-gate`) lists every Dart file
  of `lib/` and `tool/` itself: a file absent from `lcov.info` but reached
  from a `*_test.dart` through its imports, exports or parts has "no
  executable lines" and passes (an abstract interface, an enum); one that
  no test reaches is "not loaded by any test" and counts as 0%.
- The gate fails on a gated file below 100% (its uncovered lines are
  listed), a gated file no test loads, `coverage:ignore` in a gated file,
  a file outside the D15 layout (e.g. `lib/core/foo.dart`,
  `lib/features/x/util.dart`, `lib/app/widgets/x.dart`,
  `lib/l10n/plurals.dart`), and a package (`lib/`, `tool/lib/`) whose
  gated files tests load but which has no record in `lcov.info` (its
  `--coverage-package` dropped from `scripts/test.sh`).
- Declared exclusions, printed by the gate: `lib/main.dart` (entry point),
  `lib/l10n/app_localizations*.dart` (gen-l10n output; also excluded from
  analysis), `tool/*.dart` (thin entry points over
  `tool/lib/`, run by the make targets and `test/scripts/`). The generated
  client (`packages/kiveto_portal_api`) is a separate package, outside the
  measured scope and the analysis: `test/integration/` exercises it on the
  contract fixtures. `tool/` is the path package `kiveto_tool` so that
  `flutter test --coverage` measures `tool/lib/`.
- The contract fixtures (`test/support/fixtures/portal_api/`) are real
  responses of the backend, captured on 2026-11-03 through the generator
  spike's in-process replay, byte for byte except the dev `trace` arrays,
  replaced by `"[stripped]"`; one file per route and status
  (`me.get.200.json`, `clinics.paris.home.get.200.json`,
  `me.patch.422.json`…); `test/support/portal_api/fake_portal_backend.dart`
  serves them to the generated client through a fake Dio
  `HttpClientAdapter` and records the requests. Later slices reuse both.
- Golden tests are not part of `make ci`: font rendering differs between
  Windows, macOS and Linux.

---

## 8. The Portal API contract

Source of truth: the backend's `openapi/portal.v1.yaml` (OpenAPI 3.2.0)
and its guide `openapi/portal-api-v1.md`. An API change is a backend PR
first, then a mobile PR `chore(api): sync portal contract <sha>`.

**The pieces** (architecture §4, D3–D5):

| Path | What | Written by |
|---|---|---|
| `contracts/portal.v1.yaml` | byte copy of the backend file at one commit (`-text` in `.gitattributes`: no line-ending conversion, ever) | `make api-sync` |
| `contracts/SOURCE` | repository, path, commit, sha256 of the copy (the backend has no contract tags: pinned by commit SHA, D4) | `make api-sync` |
| `tool/api_generator/` | the generator package: `tonik: 0.11.1` pinned, its `pubspec.lock` committed, `tonik.yaml` (configuration and readable names) | by hand, reviewed |
| `build/kiveto_portal_api/portal.v1.yaml` | the normalised copy tonik reads (ignored) | `make api-generate` |
| `packages/kiveto_portal_api/` | the generated client, committed (D5): neither `make install` nor the CI needs the generator | `make api-generate` |
| `packages/kiveto_portal_api/CONTRACT` | stamp: contract sha256 and commit, tonik version, a sha256 over the generator inputs and one over the generated files | `make api-generate` |

**Never edit** `contracts/` or `packages/kiveto_portal_api/` by hand: only
the make targets write them, and `make api-check` (the last step of
`make ci`) fails on any difference, each message ending with the command
that fixes it — a hand-edited copy (`git checkout -- contracts/portal.v1.yaml`
or `make api-sync REF=<sha>`), a client generated from another contract or
commit, a generated file changed, added or removed, a changed
`tonik.yaml`, generator lock or normaliser, another tonik pinned
(`make api-generate`), a missing file (the target that writes it). It
compares the tree with the `CONTRACT` stamp: a hand edit followed by a
manual `tool/portal_api.dart stamp` would pass, so only `make api-generate`
leaving `git status` clean proves the client is the generator's output.

**The generator: tonik 0.11.1** (decision D3, spike of 2026-11-03 on the
real contract). Pure Dart, it reads OpenAPI 3.2 natively (no rewrite of the
document), keeps the clinic UTC offset of every `date-time`
(`OffsetDateTime`: `2026-11-11T10:30:00+01:00` stays hour 10, offset
+01:00), types `format: date` as `Date`, sends `PATCH /me` as
`application/merge-patch+json`, renames operations, tags, schemas,
properties and parameters through `nameOverrides`, and needs no
build_runner. `swagger_parser` 1.45.1 needed four contract rewrites and
lost the offsets. Risks: a young 0.x package with one maintainer; a large
output (~415 files).

**Using the client** (phase 5 and the slices, under
`features/*/infrastructure/`, `core/network/`, `core/di/` only — rule 7):
`AccountApi(CustomServer(baseUrl: origin, serverConfig:
ServerConfig<Dio>.client(dio)))`; each call returns a `TonikResult`
(`TonikSuccess(value: GetMeResponse200(:final body))`). Every documented
status is a typed value, errors included (`GetMeResponse401`,
`UpdateMeResponse422` with its `ConstraintViolation`; the contract's
`Error` schema is generated as `ProblemDetails`, so that it does not hide
`dart:core`'s `Error`), unless an
interceptor narrows `validateStatus` to 2xx: then a non-2xx response is a
`TonikError` carrying the `DioException(badResponse)` and the problem+json
bytes. A booking `startAt` must be the slot value received (no fractional
seconds), never a UTC `DateTime`.

**Commands:**

```bash
# Update the contract to a backend commit (a full or short SHA, a branch, a tag
# known to that checkout), then regenerate and stamp the client:
make api-sync REF=840dbead                  # backend checkout in ../kiveto
make api-sync REF=840dbead KIVETO_BACKEND_DIR=//wsl.localhost/Ubuntu/home/<you>/kiveto   # a WSL checkout, from Windows
make api-generate   # regenerate from the current copy (after a tonik.yaml change)
make api-check      # the copy, SOURCE and the client agree (part of make ci)
```

`KIVETO_BACKEND_DIR` defaults to `../kiveto` (a sibling checkout); a WSL
checkout seen from Windows works as above (`KIVETO_BACKEND_DIR` may not
hold `| ^ & < > % "`: fvm passes it through cmd.exe; git is run with
`-c safe.directory=*` for these read-only commands). `REF` must exist in
that checkout (`git fetch` there first) and may only hold letters,
digits and `. _ / -`. Copying from the remote repository is not built
(deferred). Updating the contract, step by step: merge the backend PR;
`make api-sync REF=<sha>`; read the diff of `contracts/` and
`packages/kiveto_portal_api/`; refresh the fixtures of
`test/support/fixtures/portal_api/` whose route changed (capture the real
response from the local backend, exact bytes); fix the mappers of the
features; `make ci`;
commit `chore(api): sync portal contract <short sha>`.

**The normalisation** (`tool/normalize_contract.dart`, run by
`make api-generate`): the backend declares no `required` on the schemas it
answers with, although its success bodies carry every key (`null`
included), so a generator would type every response field as optional.
Its problem+json bodies omit some nullable keys (`detail`, `instance`),
which still decode: a missing nullable key reads as `null`. The normaliser
writes `build/kiveto_portal_api/portal.v1.yaml`, where every
**response-only** schema (reachable from the responses and from no request
body or parameter) lists all its properties in `required`; nullability is
kept (a `type: [T, 'null']` field stays nullable), request schemas are
untouched (a merge-patch body stays all-optional), and nothing else
changes. It disappears the day the backend declares `required` itself.

**Readable names**: the contract's operationIds derive from the routes
(`api_clinics_clinicIdhome_get`), its tags are French and its output
schemas are named `<Input>.<Output>`. `tool/api_generator/tonik.yaml`
renames them (`PetsApi.getHome`, `AppointmentDetailView`, a `type`
property becomes `kind` or `problemType`). The normaliser refuses a
contract whose operationId, tag or dotted schema has no entry there
("add a readable name to nameOverrides.<section> of
tool/api_generator/tonik.yaml"): add it, then `make api-generate`. Inline
types keep a name tonik derives from their path (route-derived
`ApiPortalV1…` request bodies, query enums and error bodies; enums and
nullable wrappers named after their schema key, such as
`AppointmentViewStatusModel`).

---

## 9. BMAD workflow

Kiveto Mobile uses **BMAD 6.12.4** (`_bmad/`), installed with the `core`
and `bmm` modules for Claude Code. Skills live in `.claude/skills/` and are
invoked as `/<skill-name>`. Agents talk in French and write their
artefacts in English (pinned in `_bmad/custom/config.toml`).

| Use case | Skill |
|---|---|
| Don't know what to do next | `bmad-help` |
| Explore an idea | `bmad-brainstorming`, `bmad-forge-idea` |
| Product brief, PRD, UX | `bmad-product-brief`, `bmad-prd`, `bmad-ux` |
| Architecture decisions | `bmad-architecture` |
| Epics, stories, sprint | `bmad-create-epics-and-stories`, `bmad-sprint-planning` |
| Spec a change | `bmad-spec` |
| Implement it | `bmad-build` (needs `uv`) |
| Review the code | `bmad-code-review` |
| Agent instructions (`AGENTS.md` block) | `bmad-project-context` |

Typical change: `bmad-spec` → `bmad-build` → `bmad-code-review` → PR.
Artefacts: `_bmad-output/planning-artifacts/` (architecture, PRD) and
`_bmad-output/implementation-artifacts/` (one spec per branch, linking the
backend slice it implements).

Customisation is TOML only: team overrides in `_bmad/custom/*.toml`
(committed), personal ones in `_bmad/custom/*.user.toml` and
`_bmad/config.user.toml` (git-ignored). Use `bmad-customize`.

These skill names differ from the Symfony repository, which still runs
BMAD 6.2.0 (`bmad-quick-spec` / `bmad-quick-dev` there).

---

## 10. Definition of Done

- [ ] `make ci` is 100% green locally
- [ ] Tests cover the change; the coverage gate passes
- [ ] Commit messages follow Conventional Commits
- [ ] Branch name follows §2
- [ ] PR opened against `master` with a descriptive title and body
- [ ] PR links the BMAD spec, and the backend slice or contract commit when relevant
- [ ] Checked on an Android emulator, and on an iOS simulator when the change touches iOS
- [ ] GitHub Actions green on the PR
- [ ] Code review approved
- [ ] Branch deleted after merge
