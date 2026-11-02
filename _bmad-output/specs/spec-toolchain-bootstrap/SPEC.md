---
id: SPEC-toolchain-bootstrap
companions:
  - make-targets.md
  - ../../planning-artifacts/architecture.md
sources: []
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Toolchain bootstrap (phase 2)

## Why

Mandate and pain: the repository has only its foundations, and every later phase needs a reproducible way to get the pinned Flutter SDK, build the app and run it. Developers work on Windows 11 (Git Bash, Android only) and macOS (Android and iOS) and expect the Kiveto Symfony experience — `make install`, `make start`, `make ci` — with the same contract on both systems and without anything installed behind their back. This phase delivers milestone V1 of `architecture.md` §11.

## Capabilities

- **CAP-1**
  - **intent:** A developer can see, with one read-only command, which prerequisites are present and how to fix each missing one, on Windows 11 Git Bash and on macOS.
  - **success:** `make doctor` exits non-zero when a blocker of `make-targets.md` is missing, printing the exact fix; exits 0 on a ready machine; writes nothing outside `.make/`.
- **CAP-2**
  - **intent:** A developer can go from a fresh clone to a buildable project with one command.
  - **success:** `make install` on a fresh clone fetches Flutter 3.47.9 through FVM, resolves dependencies, activates nothing global and prints a summary; a second run downloads nothing and succeeds.
- **CAP-3**
  - **intent:** A developer can run the app on an emulator, simulator or device with one command.
  - **success:** `make start` boots the AVD when no device runs and launches the app on it; a second `make start` skips `pub get` when no pubspec changed; `PLATFORM=ios` on Windows stops with an explicit message.
- **CAP-4**
  - **intent:** A developer can list where the app can run.
  - **success:** `make devices` lists connected devices, AVDs and, on macOS, simulators.
- **CAP-5**
  - **intent:** A developer who has no FVM can install it for their user only, on request.
  - **success:** `make install-fvm` installs FVM 4.3.2 under the user's home from the official release, checks its SHA-256, and prints the `PATH` line instead of writing it.
- **CAP-6**
  - **intent:** A developer can throw away generated state and start again.
  - **success:** `make clean` removes Flutter build outputs and `.make/` stamps; `make reset` runs `clean` then `install`.
- **CAP-7**
  - **intent:** The app project exists for Android and iOS with the identity the backend expects.
  - **success:** Dart package `kiveto_mobile`; Android `applicationId` and iOS bundle id `app.kiveto.portal`; display name "Kiveto"; the generated app builds and runs on the Android emulator.
- **CAP-8**
  - **intent:** Environment values reach the app through a versioned template.
  - **success:** `config/env/dev.json.dist` is committed; `make install` creates the git-ignored `dev.json` from it when missing; `make start` passes `config/env/$(ENV).json` with `--dart-define-from-file`.

## Constraints

- Flutter 3.47.9 / Dart 3.13.7 pinned in `.fvmrc`; every call goes through `fvm flutter` / `fvm dart`.
- The Makefile works with GNU Make 3.81: no `.ONESHELL`, `$(file)`, `!=` or grouped targets; `SHELL := bash`; logic lives in `scripts/`.
- `scripts/*.sh` run on bash 3.2: no `declare -A`, `${v,,}`, `mapfile`, `printf '%(…)T'`, `[[ -v ]]`, nor empty-array expansion under `set -u`; LF only.
- Nothing system-wide: only repository-local git config; `install-fvm` is opt-in and user-scoped; no `PATH` or system setting is ever written.
- One command contract on Windows 11 Git Bash and macOS; iOS only on macOS.
- Symfony make UX: `step / ok / warn / fail` lines, quiet runs logged with timestamps to `LOG_FILE` (default `.make/make.log`) with the target's last 30 lines on failure, `V=1`, `NO_COLOR=1`.
- Idempotent: no download or `pub get` when nothing changed; stamps in `.make/`.
- Windows Developer Mode is a blocker (FVM symbolic links).
- No package beyond what `flutter create` generates.

## Non-goals

- Analyzer configuration, lints, tests, coverage gate, architecture tests, git hooks, `make ci`, GitHub Actions (phase 3).
- OpenAPI client and `make api-*` (phase 4).
- App code, networking, the dev `Host` header interceptor, clear-text HTTP config (phase 5).
- Native flavors (D11).

## Success signal

- On the Windows 11 machine, from a fresh clone: `make install` then `make start` shows the app on `Medium_Phone_API_37.0`; a second `make start` launches it without `pub get`; with FVM removed from `PATH`, `make doctor` and `make install` stop and print how to install it. The same sequence on a Mac, with `PLATFORM=ios`, is left to the user.

## Assumptions

- No Apple Team ID is needed for simulator builds; left unset.
- `make install` does not prefetch Gradle, the NDK or iOS dependencies; the first build downloads them.
- `flutter create` defaults (flutter_lints, `analysis_options.yaml`, `test/widget_test.dart`, counter app) stay until phases 3 and 5 replace them.

## Open Questions

- What is the Apple Team ID? Needed at the first iOS distribution, not in this phase.
