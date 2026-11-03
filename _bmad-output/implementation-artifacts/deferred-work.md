# Deferred work

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Replace the template `MaterialApp.title: 'Flutter Demo'`, which Android shows in the recents screen, when phase 5 rewrites `lib/main.dart`.
  evidence: App code is out of phase 2 by the frozen boundary (review finding 21); phase 3 only adapted `lib/main.dart` to the new lints.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Add the Claude Code hooks of D14 in `.claude/settings.json`: team permissions, a `PostToolUse` hook formatting the edited Dart files (a Dart script, Git Bash has no `jq`), a `PreToolUse` hook refusing `git commit` until `make ci` has passed on the staged tree.
  evidence: The phase 3 session was not allowed to write `.claude/settings.json`; architecture §8, §10 and §11 mark D14 deferred.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Validate phase 3 on macOS: `make ci` with `/usr/bin/make` 3.81 and `/bin/bash` 3.2 first on `PATH`, the git hooks on a real commit (BSD `mktemp`, `sed`, `tar`, `find`), `make test-scripts` included.
  evidence: `make ci`, the hooks and the plain-bash checks ran on Windows only; under bash 3.2 only the checks needing neither git nor Flutter ran (Docker `bash:3.2` image, busybox userland).

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Watch the first GitHub Actions run of `.github/workflows/ci.yml` (FVM archive layout, cache, `make ci V=1` on `ubuntu-24.04`), then make its `make ci` check required on `master` (branch protection).
  evidence: The workflow could not run from the phase 3 session (no push); a Linux run was only simulated with a stubbed `uname` on Windows.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Test the cold-boot readiness of `make start` (`sys.boot_completed`, then `pm path android` under a 10 s device-side timeout) with a stubbed `adb`, `emulator` and `fvm flutter devices`.
  evidence: No test sources or runs `scripts/start.sh`; the readiness function was only run by hand against an emulator already up, so the boot wait loop never ran (review, verification-gap finding).

## Deferred from: code review of spec-quality-gates.md (2026-11-03)

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Test the second doctor pass of `make install` (Flutter not cached before `fvm install`, cached after it, NDK missing → blocker on Windows before `pub get`).
  evidence: No test goes past the first doctor pass of `scripts/install.sh`; a blocker-free fake machine needs a JDK, Developer Mode (Windows) or Xcode (macOS), so the stubbing is machine-dependent.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Decide whether CI also builds the app (`fvm flutter build apk --debug`, outside `make ci` to keep the local loop short).
  evidence: `make ci` runs no Gradle or Xcode build, so manifest, Gradle, NDK or plugin breakage reaches `master` unseen until `make start`; D8 only asks CI to run `make ci`.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Decide whether to check the conventions of the architecture §3 table that `test/architecture/` does not enforce: Dio outside `features/*/infrastructure/`, `core/network/` and `core/di/`; `infrastructure/` importing `presentation/`; features or `core/` importing `app/`; `di.dart` or `core/di/` re-exporting infrastructure or `kiveto_portal_api` (which hands DTOs to presentation).
  evidence: The 8 D15 rules do not cover them (review findings, rejected as new rules); they are marked as unchecked conventions in architecture §3 and CLAUDE.md §3.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Check Conventional Commits on GitHub too (pull request titles, which become squash-merge subjects), not only with the local `commit-msg` hook.
  evidence: Commits made without `make install`, with `--no-verify`, through the GitHub UI or by squash merge are never checked.

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Close the coverage gate's blind spot: a gated file reachable from a test only through an unused conditional import, a deferred import or a skipped suite is absent from `lcov.info` and passes as "no executable lines".
  evidence: The gate approximates "loaded" by static reachability; none of these patterns exists in the app today (review findings, rejected as unlikely).

- source_spec: `_bmad-output/implementation-artifacts/spec-quality-gates.md`
  summary: Correct CLAUDE.md (needs the user's own go-ahead, agent-context file): bootstrap status as a fact ("phases 1–3 done; phase 2 validated on Windows and macOS, phase 3 on Windows — macOS run and first GitHub Actions run pending"); rule 8 bullet "No `DateTime.now()` / `DateTime.timestamp()`"; §3 "domain and application never import another feature"; §3 "checked by `test/architecture/`, except the Dio / DTO bullet (Dio is only refused in domain, application and presentation)"; §4 "adding an untested file to a gated layer fails the gate".
  evidence: Code review of the branch: the CLAUDE.md lines written by phase 3 read conditionally ("done once `chore/quality-gates` is merged"), omit `DateTime.timestamp`, and claim checks the tooling does not make; architecture.md and CONTRIBUTING.md already say it right.
