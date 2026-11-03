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
