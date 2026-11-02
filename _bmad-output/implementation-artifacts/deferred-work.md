# Deferred work

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Test `tool/devices.dart` (exit codes 0/1/2/3, banner skipping, malformed entries, `--device` by id, name and unknown) with `flutter devices --machine` fixtures, and bring `tool/` under the coverage gate.
  evidence: No test spawns the picker; architecture §8 gates only `lib/**`, so phase 3 would not flag it (review findings 1 and 17).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Add a plain-bash check of `pub_get_needed` (missing stamp or package config, newer pubspec.yaml or pubspec.lock, other Flutter pin, unchanged tree).
  evidence: The skip decision is untested and `make start` passes `--no-pub`, so a wrong skip is never corrected (review finding 2).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Add a plain-bash check of `version_ge` cases and of doctor's exit code with a blocker (e.g. fvm stubbed out of PATH), so that `make install` provably stops before `fvm install`.
  evidence: The blocker counter and exit are untested (review finding 3).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Test `make install-fvm` with a stubbed `curl`: wrong digest installs nothing, unsafe archive path refused, matching digest installs; run the real download once by hand.
  evidence: The integrity paths of CAP-5 are covered by no automated or listed check (review finding 4).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Update `architecture.md` through `bmad-architecture`: display name "Kiveto" (D2), layout with `install-fvm.sh`, `clean.sh`, `tool/devices.dart`, the result of the `SHELL := bash` check on Windows (both `bash` and `/bin/bash` work from Git Bash with make 4.4.1), the NDK prerequisite.
  evidence: The planning artifact no longer matches the repository (review finding 11).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Replace the template `MaterialApp.title: 'Flutter Demo'`, which Android shows in the recents screen, when phase 5 rewrites `lib/main.dart`.
  evidence: App code is out of phase 2 by the frozen boundary (review finding 21).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: On macOS, report an Xcode whose licence or first launch is pending (`xcodebuild` exit 69) as such, with `sudo xcodebuild -license accept` / `-runFirstLaunch`, instead of "Xcode not found".
  evidence: Unverified (needs a Mac); if true, medium: every new Mac setup meets it (review finding 41).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Add an NDK check to `make doctor` (the version Flutter asks for, under `ndk/`), with the Android CLI or SDK Manager fix; add it to `make-targets.md` first.
  evidence: On Windows with cmdline-tools 23.0, AGP cannot auto-install the NDK (`sdkmanager.bat` splits `ndk;<version>`), and doctor reports ready before a failing first build (review finding 46).

- source_spec: `_bmad-output/implementation-artifacts/spec-toolchain-bootstrap.md`
  summary: Update the "Bootstrap status" line of `CLAUDE.md` when phase 2 is merged.
  evidence: It still says phase 1; agent-context files are not edited by a build review (review finding 47).
