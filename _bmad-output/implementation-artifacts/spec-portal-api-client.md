---
title: 'Portal API client (phase 4): contract copy, tonik generator, generated client, make api-*'
type: 'chore'
created: '2026-11-03'
status: 'done'
baseline_revision: 'bbf9d6a91966ae6f0706de9991f76d2410c72759'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-quality-gates.md'
warnings: ['multiple-goals', 'oversized']
deferred:
  - summary: >-
      Test the Makefile's handling of inherited variables (REF, PLATFORM and ENV from the environment ignored, KIVETO_BACKEND_DIR honoured).
    evidence: |-
      Verification-gap finding: the ifeq ($(origin REF),environment) block is untested, like the PLATFORM and ENV ones; test/scripts/api_sh_test.sh runs scripts/api.sh directly, never through make. Checked once by hand (REF=abc make api-sync stops with "REF is required").
    location: >-
      Makefile:25
    severity: low
  - summary: >-
      Update CLAUDE.md for phase 4 (generator chosen: tonik 0.11.1, make api-*, tonik_util under rule 7, bootstrap status).
    evidence: |-
      Intent-alignment finding: CLAUDE.md §5 still says "The generator is not chosen yet"; CLAUDE.md is an agent-context file whose edits need the user's own go-ahead (recorded in deferred-work.md).
    location: >-
      CLAUDE.md
    severity: low
---

<intent-contract>

## Intent

**Problem:** The app has no Portal API client: no pinned copy of the backend contract, no generator, no generated package and no check that they agree, so phase 5 and the slices cannot call the backend. The phase-4 spike (2026-11-03) chose **tonik 0.11.1** (decision D3) and proved it on the real contract and real responses.

**Approach:** Pin the backend's `openapi/portal.v1.yaml` by commit SHA (D4), normalise a build copy (response-only schemas: every property required, nullability kept), generate `packages/kiveto_portal_api/` with tonik and commit it (D5) with a `CONTRACT` stamp; add `make api-sync` / `api-generate` / `api-check` (in `make ci`), the app dependencies, the rule-7 extension to `tonik_util`, a contract-fixture integration test, milestone V3 and the docs.

## Boundaries & Constraints

**Always:**
- Every Flutter / Dart call through `fvm flutter` / `fvm dart`; Makefile GNU Make 3.81 compatible; scripts and bash tests bash 3.2, LF, mode 100755; phase-3 make UX (`step/ok/warn/fail/die`, `run` quiet runner, `V=1`, `NO_COLOR=1`).
- No `| ^ & < > %` in arguments given to `fvm flutter` / `fvm dart` (cmd.exe on Windows): build `<ref>^{commit}` inside Dart, and refuse a `REF` with characters outside `[0-9A-Za-z._/-]`.
- Versions checked on pub.dev on 2026-11-03 and pinned exactly: `tonik: 0.11.1` (generator, dev dependency of `tool/api_generator/`, its `pubspec.lock` committed), app dependencies `dio: 5.11.1`, `tonik_util: 0.11.1`, `kiveto_portal_api: {path: packages/kiveto_portal_api}`, `kiveto_tool` dependency `yaml: 3.1.4` (all latest; `yaml` brings no new transitive package).
- `contracts/portal.v1.yaml` is a byte copy (`git show <sha>:openapi/portal.v1.yaml`), never rewritten; the normalisation writes to `build/kiveto_portal_api/portal.v1.yaml` only.
- `tool/lib/**` stays at 100% line coverage; `tool/lib/portal_api.dart` uses SDK libraries only; `package:yaml` is used only by `tool/lib/contract_normalizer.dart`. New thin mains `tool/portal_api.dart`, `tool/normalize_contract.dart` (gate exclusion `tool/*.dart`) get their exit-code check in `test/scripts/`.
- Never write `coverage:ignore`; tests never call the network or the real `git` of the backend.

**Never:**
- Hand-edit `contracts/` or `packages/kiveto_portal_api/` (only `make api-sync` / `make api-generate` write them); use tonik `--overwrite`.
- Change the backend repository (its defects of spike §7.2–7.10 become deferred proposals), edit `CLAUDE.md` (needs the user's own go-ahead: deferred), write `.claude/settings.json`, push, install anything globally.
- Write app code under `lib/` (phase 5): no Dio factory, interceptor or repository yet.
- Implement the remote fallback of `api-sync` (a clone of a private GitHub repository may open a sign-in window): deferred.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|---|---|---|---|
| Sync | `make api-sync REF=840dbead KIVETO_BACKEND_DIR=//wsl.localhost/ubuntu/home/djamil/sites/personal/kiveto` | copy byte-identical to the backend file at the full SHA `840dbead0202f55a4e8aacf2858a579d2b828f45`, `SOURCE` written, client regenerated and stamped | exit 0 |
| Sync, no REF / bad REF | `make api-sync` / `REF='a^b'` | "REF is required: make api-sync REF=<backend commit>" / "REF … may only hold …" | exit 1 before any fvm call |
| Sync, bad dir / unknown ref | dir missing or not a git checkout / ref absent | names the dir and says to set `KIVETO_BACKEND_DIR` / names the ref and says to fetch it | exit 1, nothing written |
| Check, clean | copy, `SOURCE`, `CONTRACT`, package files, generator inputs agree | `api-check: contract <sha256> (backend <commit>) matches contracts/SOURCE and packages/kiveto_portal_api (tonik 0.11.1)` | exit 0 |
| Copy edited | a line appended to `contracts/portal.v1.yaml` | "edited by hand … restore it (git checkout -- contracts/portal.v1.yaml) or make api-sync REF=<sha>" and "generated from another contract … make api-generate" | exit 1 |
| Client stale / edited | `CONTRACT` sha256 differs; a generated file changed, added or removed; `tonik.yaml`, the generator lock or the normaliser changed; tonik pin ≠ stamp | one message per cause, each ending with the command to run | exit 1, all causes listed |
| Missing pieces | no copy / no `SOURCE` / no `CONTRACT` | names the file and the make target that writes it | exit 1 |
| Normalise | real contract | `required` added to every response-only schema lacking it (84 today), request schemas and nullability untouched, idempotent, re-parses as YAML | exit 0 |
| Unnamed contract items | an operationId, tag or dotted schema of the contract without an entry in `tool/api_generator/tonik.yaml` `nameOverrides` | lists them: "add a readable name to nameOverrides.<section> of tool/api_generator/tonik.yaml" | exit 1, no generation |
| Contract decoding | captured real responses through the generated client on a fake `HttpClientAdapter` | decoded with the clinic offsets kept (`+01:00`, hour 10), `Date` for `YYYY-MM-DD`, non-null required fields, `null` kept where nullable | test fails otherwise |
| Problem+json | 401 `GET /me`, 404 home, 422 `PATCH /me` (merge-patch) | default: typed `…Response401/404/422` values (422 body `ConstraintViolation` with violations); with `validateStatus` 2xx-only: `TonikError` whose `error` is a `DioException(badResponse)` | test fails otherwise |

</intent-contract>

## Code Map

Existing files:
- `Makefile` -- thin: one `@KV_TARGET=$@ bash scripts/x.sh` line per target; options block (`PLATFORM`/`ENV` from the environment ignored, `REF` must follow that pattern; `KIVETO_BACKEND_DIR` from the environment is honoured), `export` line, `.PHONY`, help text.
- `scripts/lib.sh:37` -- `KV_PUB_INPUTS="pubspec.yaml pubspec.lock tool/pubspec.yaml"` (comment: phase 4 adds the generated pubspec); `run`, `run_live`, `require_flutter`, `pub_get_if_needed`.
- `scripts/ci.sh:11` -- `KV_CI_TARGETS` (comment: phase 4 appends `api-check`); `test/scripts/ci_sh_test.sh` asserts the exact list ("the six targets").
- `test/scripts/lib_test.sh:37-63` -- `pub_get_needed` cases per input file; `test/scripts/coverage_gate_main_test.sh` -- the pattern for a thin main's exit code (temporary project, `with_real_fvm fvm dart tool/x.dart`).
- `tool/lib/coverage_gate.dart:45-59` -- `_exclusions` (`tool/*.dart` = thin entry points); the gate lists only `lib/**` and `tool/**` (`.dart_tool` skipped), so `packages/` is outside it; reachability may walk into `packages/kiveto_portal_api` (measured: gate 2 s with the client loaded).
- `tool/lib/dart_source.dart` -- `listDartFiles`, `readPackageConfig` (reuse in tests only if useful).
- `test/architecture/architecture_rules.dart:23,143,268-280` -- `ruleTitles[7]`, the application `family` switch, rule 7 (`kiveto_portal_api` only under `features/*/infrastructure/`, `core/network/`, `core/di/`); `test/architecture/architecture_self_test.dart:350-372` -- the rule-7 self-test to extend.
- `analysis_options.yaml` -- already excludes `packages/**`. `.githooks/pre-commit` already skips `packages/`. `.gitignore` ignores `build/`, `.dart_tool/`, `/tool/pubspec.lock` (anchored: `tool/api_generator/pubspec.lock` stays committed).
- `.gitattributes` -- `* text=auto eol=lf`.
- Docs: `CONTRIBUTING.md` §0 (phase table), §5 (commands, quality-controls row "Generated client matches the contract copy … Phase 4", pub-get inputs sentence), §6 rule 7, §7 (coverage scope), §8 (contract); `_bmad-output/planning-artifacts/architecture.md` §3 rule 7 and table, §4 (+ "Generator spike" table), §5 (versions table, `kiveto_tool` "SDK libraries only"), §6 layout, §7 (pub-get inputs, `make api-*` row, "make ci … phase 4 appends api-check"), §8, §10 D3, §11 phase 4 milestone, §12 risks; `README.md` (French: bootstrap status, commands); `_bmad-output/implementation-artifacts/deferred-work.md`.

Spike material (read-only, notes folder `C:\Users\djami\AppData\Roaming\Claude\side-session-notes\local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14\`):
- `spike-generator.md` §2, §5–§8 -- commands, findings, defects §7.2–7.10, phase-5 notes.
- `spike-generator/config/tonik.yaml` -- working config (transport dio, `generateUnknownCase`, `contentTypes`, tags, 4 schema renames, 60 operation renames): start from it.
- `spike-generator/tool/infer_required.dart` -- prototype normaliser (YAML for analysis, text insertion of a `required:` list after `      type: object`).
- `spike-generator/tool/portal_api.dart` -- prototype `sync`/`stamp`/`check` and the SDK-only SHA-256.
- `spike-generator/live/capture-all.json` -- 21 real responses (`method`, `path`, `requestContentType`, `status`, `contentType`, `body` as the exact response string); `live/tonik/live.dart` -- usage of the generated client (switches on `TonikSuccess(value: GetMeResponse200(:final body))`, `ServerConfig<Dio>.client`, strict `validateStatus`).

Facts established while planning (scratch copies, 2026-11-03):
- Backend local `master` = `840dbead0202f55a4e8aacf2858a579d2b828f45` (WSL git); `openapi/portal.v1.yaml` unchanged since `c4be516f747e0dd010a0e400941694ca307be176`; sha256 `91fd6444255735a96084e0c6f5a692eb75c8825c052112be8facc3dff0de0266`, LF only, final newline. Windows git reads it in 0.2 s: `git -c safe.directory=* -C //wsl.localhost/ubuntu/home/djamil/sites/personal/kiveto show <sha>:openapi/portal.v1.yaml`. No `../kiveto` sibling on this machine.
- pub.dev 2026-11-03: tonik / tonik_util 0.11.1 (2026-10-26, sdk ≥3.13), dio 5.11.1 (2026-09-04), yaml 3.1.4 (2026-08-28), all latest. `yaml`'s dependencies (`collection`, `source_span`, `string_scanner`) are already in the root lock.
- `tool/api_generator/` with `dev_dependencies: tonik: 0.11.1`: `fvm dart pub get` 1.4 s; `fvm dart` there finds the root `.fvmrc` (no copy needed). Spike normaliser on the real contract: 84 response-only schemas get `required`, 26 input schemas untouched. `fvm dart run tonik --config tonik.yaml` on the normalised copy: ~10 s, one expected warning (`text/calendar` → String), 414 files, LF only, no `.gitignore`; output pubspec: `big_decimal ^0.7.0, collection ^1.19.1, dio ^5.11.1, meta ^1.19.0, tonik_util ^0.11.1`, dev `lints ^6.1.0`, plus its own `analysis_options.yaml`. CLI flags `-s/--spec`, `-o/--output-dir` exist. Name overrides: `nameOverrides.{schemas,properties ("Schema.prop"),operations,parameters ("opId.param"),enums ("Enum.VALUE"),tags}`.
- Root app with the three dependencies: `fvm flutter pub get` OK (adds dio, dio_web_adapter, http_parser, mime, tonik_util, typed_data, web, big_decimal…; meta 1.18.3 → 1.19.0); lock records `path: "packages/kiveto_portal_api"` with `/`. `fvm dart analyze --fatal-infos --fatal-warnings` with the package present: no issue (33 s).
- A `flutter test` file under `test/integration/` decoding `GET /me` through `AccountApi(CustomServer(baseUrl: …, serverConfig: ServerConfig<Dio>.client(dio)))` with a fake `HttpClientAdapter` returning `ResponseBody.fromBytes(bytes, 200, headers: {Headers.contentTypeHeader: ['application/json']})` passes; `body.account.firstName` is non-null after normalisation; fixtures read with `File('test/support/…')` (cwd = package root). The real network is never touched.
- The local backend answers: `GET /legal/terms/current` 200, `GET /me` without token 401 problem+json (`http://portal.kiveto.local:81`).

## Tasks & Acceptance

**Execution:**
- [x] `.gitattributes`, `.gitignore` -- `contracts/portal.v1.yaml -text` (byte copy, no EOL conversion ever), `packages/kiveto_portal_api/** linguist-generated=true`; ignore `/packages/kiveto_portal_api/pubspec.lock` (an IDE pub get inside the nested package) -- the copy's sha256 must survive any git configuration.
- [x] `tool/pubspec.yaml` -- `dependencies: yaml: 3.1.4`; description and comment updated (SDK libraries only, except `yaml` for the contract normaliser) -- `package:yaml` is the only sound way to read the contract.
- [x] `tool/lib/portal_api.dart`, `tool/portal_api.dart` -- Design Notes "portal_api"; `Future<int> runPortalApi(List<String> args, {required String root, required StringSink out, required StringSink err, GitRunner git = …})` with an injectable git runner; thin main `exitCode = await runPortalApi(args, root: Directory.current.path, out: stdout, err: stderr);` (UTF-8 stdout/stderr like `tool/coverage_gate.dart`).
- [x] `tool/lib/contract_normalizer.dart`, `tool/normalize_contract.dart` -- Design Notes "Normaliser"; thin main `normalize_contract.dart <contract> <tonik.yaml> <out>`.
- [x] `test/tool/portal_api_test.dart`, `test/tool/contract_normalizer_test.dart` (+ fixtures under `test/tool/fixtures/` if needed) -- 100% of both libraries: every Matrix row of sync/check/stamp (temporary trees, fake git runner returning bytes / failures), SHA-256 vectors (`''`, `'abc'`, 56-byte `'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'`, 1,000,000 × `'a'` or a 1000-byte vector, multi-byte UTF-8) against known digests; normaliser on small synthetic contracts (response-only vs shared vs request schemas, nullable forms kept, existing `required` left alone, quoted dotted names, idempotence, unrewritable schema → error, missing names → error) and on the real `contracts/portal.v1.yaml` + `tool/api_generator/tonik.yaml` (structural assertions, no hard-coded count).
- [x] `tool/api_generator/pubspec.yaml`, `tool/api_generator/pubspec.lock`, `tool/api_generator/tonik.yaml` -- package `kiveto_api_generator` (`publish_to: none`, sdk `^3.13.7`, `dev_dependencies: tonik: 0.11.1`), lock from `fvm dart pub get`; `tonik.yaml` = spike config with `spec: ../../build/kiveto_portal_api/portal.v1.yaml`, `outputDir: ../../packages`, header comment, and the names of Design Notes "Names".
- [x] `scripts/api.sh` (new, 100755), `Makefile` -- Design Notes "Make targets"; help lists the three targets and the `REF=`, `KIVETO_BACKEND_DIR=` options.
- [x] `scripts/lib.sh`, `scripts/ci.sh`, `test/scripts/lib_test.sh`, `test/scripts/ci_sh_test.sh` -- add `packages/kiveto_portal_api/pubspec.yaml` to `KV_PUB_INPUTS` (and its `pub_get_needed` case); append `api-check` to `KV_CI_TARGETS` (expected list: seven targets).
- [x] `test/scripts/api_sh_test.sh`, `test/scripts/portal_api_main_test.sh` -- plain-bash checks: `api.sh sync` without `REF`, with a bad `REF`, with a missing `KIVETO_BACKEND_DIR` (exit 1, message, no fvm call — stub `fvm` that records calls); `tool/portal_api.dart check` (real fvm, temporary project with copy + `SOURCE` + `CONTRACT` + one generated file + generator inputs) exit 0, then exit 1 after appending a line to the copy; `tool/normalize_contract.dart` exit 1 on a contract with an unnamed operation, 0 on a named one.
- [x] `contracts/portal.v1.yaml`, `contracts/SOURCE`, `packages/kiveto_portal_api/**` (incl. `CONTRACT`) -- produced only by `make api-sync REF=840dbead0202f55a4e8aacf2858a579d2b828f45 KIVETO_BACKEND_DIR=//wsl.localhost/ubuntu/home/djamil/sites/personal/kiveto`; then `make api-generate` again leaves `git status` clean (determinism).
- [x] `pubspec.yaml`, `pubspec.lock` -- dependencies (sorted) `cupertino_icons`, `dio: 5.11.1`, `flutter`, `kiveto_portal_api: {path: packages/kiveto_portal_api}`, `tonik_util: 0.11.1`, with a comment (generated client and its runtime; used only by `features/*/infrastructure/`, `core/network/`, `core/di/` — rule 7); `fvm flutter pub get`.
- [x] `test/architecture/architecture_rules.dart`, `test/architecture/architecture_self_test.dart` -- rule 7 covers `kiveto_portal_api` and `tonik_util` (same allowed places, message names the package); `ruleTitles[7]` and the application `family` include `tonik_util`; self-test: `tonik_util` imported from `app/bootstrap/`, presentation and `di.dart` → rule 7, allowed in infrastructure, `core/network/`, `core/di/`.
- [x] `test/support/portal_api/` (helpers) + `test/support/fixtures/portal_api/*.json` + `test/integration/portal_api_contract_test.dart` -- Design Notes "Contract fixtures"; Matrix rows "Contract decoding" and "Problem+json".
- [x] Milestone V3 -- (a) the integration test green in `make ci`; (b) Design Notes "Live run", result recorded in the implementation notes below; (c) append a line to `contracts/portal.v1.yaml` → `make api-check` and `make ci` fail at `api-check` with the messages → `git checkout -- contracts/portal.v1.yaml` → green.
- [x] `CONTRIBUTING.md`, `_bmad-output/planning-artifacts/architecture.md`, `README.md`, `_bmad-output/implementation-artifacts/deferred-work.md` -- Design Notes "Docs".

**Acceptance Criteria:**
- Given the branch on this Windows machine, when `make ci` runs, then it passes with `api-check` as its seventh step, and `make ci V=1` shows every command.
- Given a fresh `make api-generate`, when `git status` runs, then nothing changed (byte-identical regeneration, same `CONTRACT`).
- Given `packages/kiveto_portal_api`, when `grep` looks for the default names (`apiMe`, `api_`, `ApiPortalV1ClinicsClinicIdHome…` method names, `AppointmentAppointmentView`, `$type`), then API classes are `AccountApi, AuthApi, ClinicListingApi, ConsentsApi, DocumentsApi, FilesApi, InvitationsApi, PetsApi, RequestsApi, SchedulingApi, TermsApi`, the 60 methods carry the names of `tonik.yaml`, the 34 dotted schemas their readable names, and only the path-derived inline types listed in the implementation notes keep a generated name.
- Given the local backend running, when the live run signs in +33612345678 with one OTP, then `GET /me` and the four clinic routes of both clinics decode with the generated client and no decoding failure (recorded below).

## Spec Change Log

## Review Triage Log

### 2026-11-03 — Review pass
- verdicts: 42 findings — high 0, medium 5, low 29, false 6, maybe-false 2 (blind-hunter 15, edge-case-hunter 14, verification-gap 3, intent-alignment 10)
- findings:
  - `[false]` `[reject]` `PATCH /me` merge-patch sends `"lastName":null`, which RFC 7396 reads as "remove" — the backend documents the opposite on this route: "Chaque champ absent (ou `null`) reste inchangé" (backend `src/Presentation/Api/Portal/Resource/MeUpdate.php`, `UpdateMeProcessor` maps null to "unchanged"); clearing the address is not an operation of the API.
  - `[low]` `[reject]` `api-check` trusts its own stamp and CI never regenerates (a hand edit followed by a manual `tool/portal_api.dart stamp` passes) — needs a deliberate run of the internal stamp command; a regenerate-and-diff CI step means installing the generator in CI (new workflow steps); byte-identical regeneration was checked by hand twice on Windows (implementation notes) and the macOS run is already deferred.
  - `[medium]` `[patch]` the `files` digest counts git-ignored junk (`.DS_Store` from Finder, `.idea/`, `*.iml`, `build/`): `api-check` fails on a clean tree with a hint that shows nothing — `_packageDigest` now leaves out dot-segments, `*.iml` and a top-level `build/`; test added.
  - `[medium]` `[patch]` `api.sh generate` deletes the committed client before the normaliser runs (an unnamed new operationId after `api-sync` leaves the app without its client) — the normaliser runs first; the package is removed only once it succeeded.
  - `[low]` `[patch]` after a failed `api-sync`, the hint "git checkout -- packages/kiveto_portal_api" leaves the old client next to the new contract — the message now says to fix the cause then `make api-generate`, or `git checkout -- contracts packages/kiveto_portal_api`.
  - `[maybe-false]` `[reject]` `KIVETO_BACKEND_DIR` reaches fvm (cmd.exe) unchecked — would need a run with a path holding a space or `&` through `fvm dart` on Windows; if true it is low (a developer-typed path, a visible failure; CONTRIBUTING already asks for paths without spaces), and the guard adds a branch.
  - `[low]` `[patch]` the owner's WSL path is hard-coded in the Makefile help, the `api.sh` message and CONTRIBUTING §8 — replaced by a placeholder; the concrete path stays in the spec notes.
  - `[low]` `[patch]` "the backend always sends every key" is false for problem+json bodies (the real 401/404/422 omit `detail`/`instance`) and no test decodes an `Error` body — wording corrected (success bodies carry every key; problem bodies omit nullable ones, which still decode); a test decodes the real 404 body as `GetMeResponse404` (`Error`).
  - `[low]` `[reject]` the names guard ignores new `type` properties and stale overrides — cosmetic (`$type`, dead map entries), the fix adds two checks.
  - `[low]` `[reject]` nothing checks that every fixture is decoded by a test — all 18 are used today; a recorder plus a directory listing test is new machinery for an unlikely slip.
  - `[low]` `[patch]` the client's transitive packages (big_decimal, dio_web_adapter, http_parser, mime, typed_data, web; meta bumped) are not recorded (CLAUDE.md §7) — listed in architecture §5.
  - `[medium]` `[patch]` `test/scripts/api_sh_test.sh` covers only the `sync` input checks — grouped with the verification-gap finding below (the `check` branch); `generate` stays verified by hand (it runs tonik, ~15 s), recorded in the notes.
  - `[low]` `[reject]` `contracts/SOURCE` names djamils/kiveto without checking the checkout's remote or that the commit is pushed — the documented flow syncs a merged backend commit; checking remotes adds git calls and branches for an unlikely mistake visible in the `SOURCE` diff.
  - `[low]` `[patch]` a CRLF contract would be refused with a misleading message — the `type: object` match ignores a trailing `\r` and the inserted lines keep it; CRLF test added.
  - `[low]` `[patch]` the root `pubspec.yaml` comment says rule 7 confines dio — reworded (rule 7 checks kiveto_portal_api and tonik_util; Dio is refused in domain, application and presentation).
  - `[medium]` `[patch]` git-ignored files inside the package break the `files` digest — same root cause and fix as the blind-hunter row above.
  - `[maybe-false]` `[reject]` `KIVETO_BACKEND_DIR` holding `& ^ % !` or spaces reaches fvm unchecked — same verdict and evidence as the blind-hunter row.
  - `[low]` `[reject]` a fork's checkout would be recorded as djamils/kiveto — same as the `SOURCE` repository row (reject).
  - `[low]` `[patch]` the failed-`api-sync` recovery hint — same fix as above.
  - `[low]` `[patch]` a Windows absolute `LOG_FILE` (`C:/…`) becomes `$KV_ROOT/C:/…` — `[A-Za-z]:*` paths are left alone.
  - `[low]` `[reject]` a deleted package plus a needed root `pub get` stops `api-generate` — with the reorder above the package is only removed when tonik itself fails, and `pub get` is needed then only after a pubspec change or `flutter clean`; the guard adds a branch.
  - `[low]` `[reject]` an empty or non-OpenAPI document normalises to an unchanged copy — the input is always `contracts/portal.v1.yaml`, guarded by its sha256; tonik fails loudly next.
  - `[low]` `[reject]` an operation without operationId or tags escapes the names guard — API Platform always sets both; a guard branch for an input that does not occur.
  - `[low]` `[reject]` OpenAPI 3.2 `additionalOperations` / path-item `$ref` are not walked — the contract uses neither (spike keyword inventory); new parsing branches.
  - `[low]` `[patch]` CRLF contract — same fix as the blind-hunter row.
  - `[low]` `[reject]` unreadable / non-UTF-8 input or unwritable output end in a stack trace (exit 255) — still a failing `make` step with the cause; wrapping every I/O adds branches.
  - `[low]` `[reject]` `git` missing from PATH ends in a `ProcessException` stack trace — same reasoning; `make doctor` checks git.
  - `[low]` `[reject]` a new fixture without a test passes — same as the blind-hunter fixture row.
  - `[low]` `[reject]` nested inline objects (e.g. `ConstraintViolation.violations` items) keep their partial `required` — only component schemas are "schemas" in the intent; the effect is a few more nullable fields, never a decoding failure; recorded in the hand-over.
  - `[medium]` `[patch]` no test runs `scripts/api.sh check`, the last step of `make ci` — plain-bash cases with the real fvm: exit 0 on an agreeing tree, exit 1 with "was edited by hand" and "make api-check failed" after a tampered copy.
  - `[low]` `[defer]` the Makefile rule ignoring an inherited `REF` is untested — no harness tests the Makefile's variable handling (the same `ENV`/`PLATFORM` rules are untested too); recorded in deferred-work.
  - `[low]` `[patch]` `portal_api_main_test.sh` never falls back to `shasum` (pipefail off) — the tool is chosen with `command -v sha256sum`.
  - `[low]` `[reject]` the make-level happy paths (`api-sync`, `api-generate`, byte-identical regeneration) rest on manual runs — they need the backend checkout and tonik (~15 s per run); the runs are recorded in the notes and the `check` branch now has a script test.
  - `[low]` `[reject]` `api-check` cannot prove the committed package equals tonik's output — same as the blind-hunter stamp row.
  - `[false]` `[reject]` any byte change of the normaliser or `tonik.yaml` fails `make ci` until `make api-generate` — intended: they are generator inputs (header of `tonik.yaml`, CONTRIBUTING §8); the guard-failure-after-overwrite part is patched above.
  - `[low]` `[reject]` path-derived names remain (inline types under dotted keys, `ApiPortalV1…`) — tonik cannot rename inline types; listed in the notes and deferred as backend proposals §7.4–7.6.
  - `[low]` `[patch]` fixtures described as "byte for byte" although the 404 carries `"trace":"[stripped]"` — wording corrected; not tying the fixtures to the pinned commit is rejected (they decode with the client generated from it, which is the check that matters).
  - `[false]` `[reject]` the V3(b) evidence lives in the spec notes and the script in the scratchpad — that is what the intent asks ("record the result in the spec's implementation notes"); no token or code may enter the repository.
  - `[false]` `[reject]` `make api-sync REF=<sha>` alone fails on this machine (`../kiveto` absent, no remote) — `KIVETO_BACKEND_DIR` is part of the intent's command; the remote fallback is deliberately deferred (sign-in window).
  - `[low]` `[defer]` CLAUDE.md still says the generator is not chosen — agent-context file, needs the user's go-ahead; in deferred-work.
  - `[false]` `[reject]` the normaliser lives in `kiveto_tool` with `yaml`, not SDK-only — the intent's "SDK libraries only" names `tool/portal_api.dart`, which stays SDK-only; the normaliser needs a YAML parser and is gated at 100% there.
  - `[false]` `[reject]` duplicates are kept as separate classes — tonik generates one class per contract schema; collapsing them is a backend change (§7.4, deferred).

## Design Notes

**portal_api** (`tool/lib/portal_api.dart`, SDK only; paths relative to `root`):
- `sync <backend-dir> <ref>`: dir missing or `git rev-parse` failing on it → "… is not a git checkout of djamils/kiveto - set KIVETO_BACKEND_DIR"; `git -c safe.directory=* -C <dir> rev-parse --verify <ref>^{commit}` → full SHA (unknown → "ref <ref> not found in <dir> - fetch it there first"); `git … show <sha>:openapi/portal.v1.yaml` as raw bytes (missing → message); writes `contracts/portal.v1.yaml` (bytes) and `contracts/SOURCE`:
  ```
  # Written by `make api-sync`; checked by `make api-check`. Never edit.
  repository: https://github.com/djamils/kiveto
  path: openapi/portal.v1.yaml
  commit: <full sha>
  sha256: <sha256 of the bytes>
  ```
- `stamp`: writes `packages/kiveto_portal_api/CONTRACT`:
  ```
  # Written by `make api-generate`; checked by `make api-check`. Never edit.
  contract: contracts/portal.v1.yaml
  sha256: <sha256 of the copy>
  commit: <commit of SOURCE>
  generator: tonik <version read from tool/api_generator/pubspec.lock>
  inputs: <sha256 over tool/api_generator/tonik.yaml, tool/api_generator/pubspec.lock, tool/lib/contract_normalizer.dart>
  files: <sha256 over the generated files>
  ```
  `files` = SHA-256 of the concatenation, in sorted `/`-separated relative path order, of `<path>\n<sha256 of the file bytes>\n` for every file of the package except `CONTRACT`, `pubspec.lock` and anything under a `.dart_tool/` folder.
- `check`: recomputes everything and reports every mismatch of the Matrix (each message ends with `make api-sync REF=<sha>`, `git checkout -- …` or `make api-generate`), exit 1; else the success line, exit 0. Usage errors exit 64 with the usage text.
- SHA-256: FIPS 180-4 on `List<int>`, as in the prototype; `GitRunner` = `Future<GitResult> Function(String dir, List<String> args)` with bytes stdout, default `Process.run('git', ['-c', 'safe.directory=*', '-C', dir, ...args], stdoutEncoding: null)`.

**Normaliser** (`tool/lib/contract_normalizer.dart`, `package:yaml`):
- Response-only schemas = schemas reachable (through `$ref`, transitively) from `responses` of any operation and from no `requestBody` / `parameters`; each one with `properties` and no `required` gets `required:` listing every property, inserted as text right after its `      type: object` line, inside `components.schemas` only (quoted keys, single or double quotes, handled). Nothing else changes; a selected schema that cannot be rewritten fails. Idempotent.
- Names guard (before rewriting): every operationId must be a key of `nameOverrides.operations`, every tag of `nameOverrides.tags`, every schema name containing `.` of `nameOverrides.schemas` in the given `tonik.yaml`; else fail listing them per section with the fix.
- Main prints `required added to N response-only schemas (M already declared it; request schemas untouched: K)`.

**Make targets** (`scripts/api.sh sync|generate|check`):
- `sync`: `REF` required and validated; `KIVETO_BACKEND_DIR` default `../kiveto` (relative to the repository root; documented example `//wsl.localhost/ubuntu/home/djamil/sites/personal/kiveto`); `require_flutter`, `pub_get_if_needed`, `run fvm dart tool/portal_api.dart sync "$dir" "$REF"`, then the generate steps.
- `generate`: `require_flutter`, `pub_get_if_needed`; `rm -rf packages/kiveto_portal_api build/kiveto_portal_api`; `run fvm dart tool/normalize_contract.dart contracts/portal.v1.yaml tool/api_generator/tonik.yaml build/kiveto_portal_api/portal.v1.yaml`; in `tool/api_generator`: `run fvm dart pub get --enforce-lockfile`, `run fvm dart run tonik --config tonik.yaml`; `run fvm dart tool/portal_api.dart stamp`; `pub_get_if_needed` (the client's pubspec is new). On failure: say `git checkout -- packages/kiveto_portal_api` restores the committed client.
- `check`: `require_flutter`, `pub_get_if_needed`, `run_live fvm dart tool/portal_api.dart check` (its output is the report).
- Make: `api-sync`, `api-generate`, `api-check` targets; `REF ?=` (an inherited `REF` is ignored, like `PLATFORM`), `KIVETO_BACKEND_DIR ?=`; both exported.

**Names** (`tool/api_generator/tonik.yaml`): tags `Animaux: Pets, Annuaire: ClinicListing, Authentification: Auth, CGU: Terms, Compte: Account, Consentements: Consents, Demandes: Requests, Documents: Documents, Fichiers: Files, Invitation: Invitations, Rendez-vous: Scheduling`. Operations: the spike's 60, except `api_meemail-change_post: requestEmailChange`. Schemas (34 dotted): `Appointment.AppointmentView: AppointmentDetailView`, `AppointmentBooking.AppointmentView: BookedAppointmentView`, `AppointmentBookingWithNewPet.AppointmentView: BookedWithNewPetAppointmentView`, `AppointmentCancellation.AppointmentView: CancelledAppointmentView`, `AppointmentReschedule.AppointmentView: RescheduledAppointmentView`, `BookingMotifs.BookingMotifView: BookingMotifView`, `BookingPractitioners.PractitionerView: BookingPractitionerView`, `ConsentUpdate.Consents: UpdatedConsents`, `DataExportList.DataExportView: DataExportView`, `DataExportRequest.DataExportRequestView: DataExportRequestView`, `DeletionOtp.OtpChallengeView: DeletionOtpChallengeView`, `EmailChange.EmailVerificationChallengeView: EmailVerificationChallengeView`, `EmailChangeOtp.OtpChallengeView: EmailChangeOtpChallengeView`, `EmailChangeVerification.AccountView: VerifiedEmailAccountView`, `InvitationAcceptance.AcceptedInvitationView: AcceptedInvitationView`, `InvitationGrantAcceptance.AcceptedInvitationView: AcceptedInvitationGrantView`, `InvitationLookup.InvitationLookupView: InvitationLookupView`, `InvitationOtpRequest.OtpChallengeView: InvitationOtpChallengeView`, `LinkSuggestionAcceptance.LinkSuggestionAcceptedView: LinkSuggestionAcceptedView`, `LinkSuggestions.LinkSuggestionView: LinkSuggestionView`, `ListingBooking.BookingRequestView: ListingBookingRequestView`, `ListingMotifs.BookingMotifView: ListingMotifView`, `ListingPractitioners.PractitionerView: ListingPractitionerView`, `MeUpdate.AccountView: UpdatedAccountView`, `MeUpdate.jsonMergePatch: MeUpdate`, `OtpRequest.OtpChallengeView: OtpChallengeView`, `OtpResend.OtpChallengeView: ResentOtpChallengeView`, `OtpVerification.OtpVerificationView: OtpVerificationResult`, `PetChangeRequestCreation.PortalRequestCreatedView: PortalRequestCreatedView`, `Questionnaire.QuestionnaireView: QuestionnaireView`, `QuestionnaireUpdate.QuestionnaireView: SavedQuestionnaireView`, `Registration.AcceptedInvitationView: RegistrationResultView`, `RenewalRequestCreation.RenewalRequestCreatedView: RenewalRequestCreatedView`, `SessionRefresh.SessionTokensView: SessionTokens`. Properties: every `type` property (`DocumentView`, `TimelineDocumentView` → `kind`; `Error`, `ConstraintViolation` → `problemType`; any other one found → a readable name) so no `$type` remains; record in the notes which key form tonik accepted.

**Contract fixtures** (reused by later slices):
- `test/support/fixtures/portal_api/` -- one file per captured body, exact bytes of `capture-all.json` `body` (named by route and status, e.g. `me.get.200.json`, `clinics.paris.home.get.200.json`, `me.get.401.json`, `me.patch.422.json`): the 15 captured 200 responses (both clinics: home, pets, upcoming appointments, documents; Paris: past appointments, consents, requests; me, booking-requests, data-exports, link-suggestions) and the 401, 404 and merge-patch 422.
- `test/support/portal_api/fake_portal_backend.dart` -- `FakePortalBackend implements HttpClientAdapter`: `on(method, pathWithQuery, PortalReply)` routes; `PortalReply.fixture(name, {status, contentType})`, `PortalReply.json(String body, …)`; records each request (method, URI, headers, content type, body bytes); an unrouted request fails with the method, URI and routed list. `portalServer(FakePortalBackend, {baseUrl, interceptors})` → `CustomServer` on a new `Dio` using it; one doc comment showing the pattern.
- `test/integration/portal_api_contract_test.dart` -- decodes every fixture through the generated API classes with spot assertions (account, clinics, `linkedAt` UTC, home next appointment `startAt` hour 10 offset +01:00 and `toIso8601String()` round trip `2026-11-11T10:30:00+01:00`, `birthDate` as `Date`, invoice total minor units, enums, nullable `null`s), asserts the request lines (`/api/portal/v1/clinics/<id>/appointments?scope=upcoming`, `Accept` header, `PATCH /me` content type `application/merge-patch+json`), the error rows of the Matrix, and an encode check: a booking `startAt` built from the slot value (`OffsetDateTime.parse('2026-11-04T13:30:00+01:00')`) serialises without fractional seconds.

**Live run** (V3b, not committed): a Dart script in `C:/Users/djami/AppData/Local/Temp/claude/D--Kiveto-Apps-kiveto-mobile/140d5f8a-ba5e-465f-804c-567a00db6656/scratchpad/live/` run with `fvm dart --packages=<repo>/.dart_tool/package_config.json <script>`: `AuthApi.requestOtp` (+33612345678, `deviceId`), read the code with `MSYS_NO_PATHCONV=1 wsl.exe -d Ubuntu -e bash /mnt/c/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/tools/otp.sh +33612345678 1` from Git Bash (OTP codes are not sent in dev, the backend workers log them; these demo codes are test values of the local backend; one OTP, the limit is 3 codes per hour per number; on `otp_rate_limited` run `tools/reset-rate-limits.sh` of the same folder the same way; workers down: `tools/worker-start.sh`), `AuthApi.verifyOtp`, then with `Authorization: Bearer <access>` (an interceptor): `AccountApi.getMe`, and per clinic `PetsApi.getHome`, `PetsApi.listPets`, `SchedulingApi.listAppointments(scope: upcoming)`, `DocumentsApi.listDocuments`; print and record counts, offsets and failures. Never write the code or tokens to the repository.

**Docs**: CONTRIBUTING §0 phase 4 Done (validated on Windows; macOS pending), §5 commands + quality row "Now" + pub-get inputs, §6 rule 7 (+ `tonik_util`), §7 (client outside coverage, contract fixtures in `test/support/`), §8 rewritten (tonik 0.11.1 and why, the three commands with examples, updating the contract step by step, the normalisation, `CONTRACT`, never edit, readable names guard); architecture §3/§4/§5/§6/§7/§8, D3 = "tonik 0.11.1 (spike 2026-11-03)", §11 V3 result, §12 risks (young 0.x one-maintainer generator; every field optional until the backend declares `required`; errors as values unless `validateStatus`; large output); README (French) status phases 1–4 and the `make api-*` commands; deferred-work: backend proposals §7.2–7.10 (one entry each or grouped by kind, evidence = spike), CLAUDE.md §5 (generator chosen) and status, `api-sync` remote fallback, macOS run of `make api-*`.

## Verification

**Commands:**
- `make api-sync REF=840dbead0202f55a4e8aacf2858a579d2b828f45 KIVETO_BACKEND_DIR=//wsl.localhost/ubuntu/home/djamil/sites/personal/kiveto` -- expected: copy sha256 `91fd6444…0266`, client generated and stamped.
- `make api-generate && git status --porcelain packages contracts` -- expected: empty after the first generation is committed/staged (determinism).
- `make api-check` -- expected: the success line; after appending a line to the copy: exit 1 with both messages.
- `make ci` -- expected: seven steps green, durations printed.

**Manual checks:**
- `grep -rn '\$type\|ApiPortalV1' packages/kiveto_portal_api/lib --include=*.dart | wc -l` and the API class list -- record the remaining generated names in the implementation notes.

## Implementation Notes

Filled by the implementation: what was verified and how (V3 a/b/c with numbers), the generated names that remain, the tonik key forms that worked, deviations from this spec and why.

- Implemented by a subagent from this spec (2026-11-03) on the Windows machine of phases 2–3 (Git Bash, make 4.4.1, FVM 4.3.2, Flutter 3.47.9). Nothing committed or pushed; CLAUDE.md, `.claude/` and the backend untouched. Staged in the index, nothing else: `contracts/` and `packages/kiveto_portal_api/` (needed by V3c's `git checkout --` and the determinism check), and the three new shell files with mode 100755 (`scripts/api.sh`, `test/scripts/api_sh_test.sh`, `test/scripts/portal_api_main_test.sh`, `git add --chmod=+x`, `core.filemode=false` here).
- `make api-sync REF=840dbead0202f55a4e8aacf2858a579d2b828f45 KIVETO_BACKEND_DIR=//wsl.localhost/ubuntu/home/djamil/sites/personal/kiveto`: exit 0 in 21 s. Copy sha256 `91fd6444…0266` (also of the staged blob, `git show :contracts/portal.v1.yaml | sha256sum`; `git check-attr` gives `text: unset`); normaliser "required added to 84 response-only schemas (0 already declared it; request schemas untouched: 26)"; tonik ~10 s with the one expected warning (`text/calendar` → String); 415 files (414 generated + `CONTRACT`), 55.6k lines of Dart, 2.7 MB, LF only, no `.gitignore`, no `pubspec.lock`.
- Determinism: two `make api-generate` runs gave the same sha256 for all 415 files; after `git add packages contracts`, a third run left `git status --porcelain packages contracts` with only the `A` entries.
- `make ci`: exit 0 with seven steps in 2 min 25 (format-check 2 s, analyze 34 s on the first run with the package then 11 s, test-architecture 4 s, test-coverage 9 s, coverage-gate 2 s, test-scripts 1 min 33 with 13 bash files, api-check 1 s). Gate: `tool  lib  5  776/776  100.0%`. The final `make ci V=1` run is recorded at the end of these notes.
- V3a: `test/integration/portal_api_contract_test.dart` (12 tests: the 18 fixtures, the request lines, the error rows, the encode check) passes inside `make ci` (test-coverage step).
- V3b, live run (`scratchpad/live/live.dart`, not committed; `fvm dart --packages=<repo>/.dart_tool/package_config.json`): `requestOtp` 202 (challenge expiry decoded UTC), one code read with `tools/otp.sh`, `verifyOtp` 200 `authenticated` (access token 536 chars, never printed or written), then with the bearer interceptor: `GET /me` 200 (Julien Girard, `email` null, address null, 2 clinics, `linkedAt` UTC); Paris: home 200 (next appointment `2026-11-11T10:30:00.000+01:00`, hour 10, offset +01:00, 1 pet, 2 care items, 2 documents), pets 200 (1, Oslo, `birthDate` 2020-03-02 as `Date`), upcoming appointments 200 (2, offsets +01:00, `cancellableUntil` kept), documents 200 (2 invoices, offsets +02:00, totals 5200 / 7800); Lyon: home 200 (no next appointment, Pixel `Date` 2022-02-11), pets 200 (1), upcoming 200 (0), documents 200 (0). **0 decoding failures.** The spike's blocker §7.1 (every authenticated call answering 500) no longer reproduces on backend `840dbead`.
- V3c: `x-drift: true` appended to `contracts/portal.v1.yaml` → `make api-check` exit 2 with "contracts/portal.v1.yaml was edited by hand: its sha256 is 24b2c3c4…, contracts/SOURCE says 91fd6444… - restore it (git checkout -- contracts/portal.v1.yaml) or make api-sync REF=<sha>" and "packages/kiveto_portal_api was generated from another contract: … - fix: make api-generate"; `make ci` stopped with "make ci failed at api-check" after the six other steps passed (2 min 03); `git checkout -- contracts/portal.v1.yaml` → `make api-check` passes again.
- Names (AC 3): API classes `AccountApi, AuthApi, ClinicListingApi, ConsentsApi, DocumentsApi, FilesApi, InvitationsApi, PetsApi, RequestsApi, SchedulingApi, TermsApi`; 60 methods, all from `tonik.yaml` (Account 13, Auth 6, ClinicListing 6, Consents 3, Documents 3, Files 3, Invitations 4, Pets 6, Requests 5, Scheduling 10, Terms 1); the 34 dotted schemas carry their readable names; `$type`: 0 occurrences; `apiMe`: 0. `grep -rn '\$type\|ApiPortalV1' packages/kiveto_portal_api/lib --include=*.dart | wc -l` = 815 (all `ApiPortalV1`, in 136 files). The generated names that remain, all inline types tonik names from their path and no `nameOverrides` key reaches:
  - route-derived: 2 query enums `ApiPortalV1ClinicsClinicIdAppointmentsParametersModel` (scope) and `ApiPortalV1ClinicsClinicIdDocumentsParametersModel` (kind); 8 inline array bodies `ApiPortalV1…Get200BodyModel` (clinic and listing booking motifs and practitioners, pets, pet care items, data exports, link suggestions; the API methods return `List<…>` of named schemas); the `PATCH /me` body `ApiPortalV1MePatchBodyRequestBody` with `…Json` / `…MergePatchJson`; 58 error bodies `ApiPortalV1<Route><Method><Status>Response` with `…Json` / `…ProblemJson` (174 classes);
  - schema-path-derived: 99 inline enums, nullable `anyOf` wrappers and array item models named `<schema key><Property>…Model` (`AppointmentViewStatusModel`, `AccountViewAddressAnyOfModel`, `ConstraintViolationViolationsArrayModel`); 45 of them sit under a dotted key and concatenate it (`AppointmentAppointmentViewStatusModel`, `MeUpdateJsonMergePatchAddressAnyOfModel`, `OtpVerificationOtpVerificationViewStatusModel`…): tonik names an inline type after the original schema key, never after its `nameOverrides.schemas` name.
- tonik key forms that worked (tonik_core's `NameOverrideApplier`): `nameOverrides.properties` keys are `"<schema key as in the contract>.<property>"` (`DocumentView.type: kind`, `TimelineDocumentView.type: kind`, `Error.type: problemType`, `ConstraintViolation.type: problemType`; no other `type` property exists); `nameOverrides.parameters` keys are `"<operationId>.<parameter>"`; schemas, operations and tags by their contract names (dotted keys unquoted in YAML).
- Deviations, each for a reason:
  - `nameOverrides.parameters: api_clinics_clinicIddocuments_get.type: kind` added: the documents query parameter `type` was generated as `$type` (`listDocuments(kind: …)` now), and AC 3 wants no `$type` left.
  - `toIso8601String()` of tonik's `OffsetDateTime` always writes milliseconds (`2026-11-11T10:30:00.000+01:00`); the round trip `2026-11-11T10:30:00+01:00` of the Design Notes is `toTimeZonedIso8601String()`, the form the client's JSON encoding uses. The integration test asserts both, and that the booking `startAt` serialises without fractional seconds.
  - An `OffsetDateTime` is not `==` to the `DateTime` of the same instant: the test uses `isAtSameMomentAs`. Nullable `anyOf` fields are nullable wrappers (`HomeNextAppointmentAnyOfModel` is `$Raw…?`): `home.nextAppointment?.appointmentView`.
  - The 401 of `GET /me` and the 404 of the home have no schema in the contract: `GetMeResponse401()` / `GetHomeResponse404()` carry no body (the raw problem+json bytes are in `TonikSuccess.response`, asserted).
  - `REF` is refused when it starts with `-` too (it reaches `git rev-parse` as an argument), in `scripts/api.sh` and again in `tool/lib/portal_api.dart`.
  - `check` also reports a client generated from another backend commit (CONTRACT `commit` ≠ SOURCE) and a SOURCE without commit; a missing package is reported once (its missing CONTRACT is not reported again). The stamp's `inputs` digest uses the `files` formula over the three inputs.
  - The normaliser follows `$ref`s through any `#/components/<section>/…` (responses, requestBodies), counts path-level `parameters` as request roots and takes the tags of the top-level `tags` list as well as the operations'; its result exposes the schema name sets (tests); unrewritable schemas are listed sorted.
  - `test/tool/portal_api_test.dart` runs the real `git` only through `processGit` on a temporary folder outside any repository (`git --version`, and `rev-parse --git-dir` failing there); every other sync case uses a fake git runner.
  - `make ci` takes ~2.5 min instead of ~1: the two new bash files run the real `fvm dart` six times.
- Final run, after the docs: `make ci V=1` exit 0 in 1 min 59 (format-check 2 s, analyze 10 s, test-architecture 4 s, test-coverage 9 s, coverage-gate 2 s, test-scripts 1 min 30, api-check 2 s), every command printed (`+ fvm dart analyze …`, `+ fvm flutter test …`, `+ fvm dart tool/portal_api.dart check`, `+ bash test/scripts/…`). Also checked by hand: an inherited `REF` is ignored by make (`REF=abc make api-sync` → "REF is required"), an inherited `KIVETO_BACKEND_DIR` is honoured.
- After the review (2026-11-03): the `files` digest leaves out every path with a segment starting with `.`, `*.iml` files and a top-level `build/` (tonik writes none: the committed digest did not change); `make api-generate` removes the client only after the normaliser accepted the contract (checked by hand: a name removed from `tonik.yaml` → refused, client kept, `api-check` still green once restored), and its failure message points to the cause, then `make api-generate`, or `git checkout -- contracts packages/kiveto_portal_api` (api-sync) / `git checkout -- packages/kiveto_portal_api` (api-generate); a Windows absolute `LOG_FILE` is kept; the help and messages use a `//wsl.localhost/<distro>/<path>/kiveto` placeholder; the normaliser keeps CRLF line endings; a typed `Error` (404 without `detail` / `instance`) is decoded in the integration test; new `test/scripts/api_check_sh_test.sh` (100755, staged) runs `scripts/api.sh check` with the real fvm, passing then failing on a drift; the docs say the problem+json bodies omit some nullable keys and the fixtures' dev `trace` was replaced by `[stripped]`.
- Left open: CLAUDE.md §5 and status (deferred, needs the user's go-ahead), the `api-sync` remote fallback, the macOS run, the backend proposals §7.2–7.10 (all in `deferred-work.md`); GitHub Actions has still never run (no push).

## Auto Run Result

- **Summary:** phase 4 delivered on `chore/portal-api-client`: the contract copy pinned to backend `840dbead0202f55a4e8aacf2858a579d2b828f45` (`contracts/`), tonik 0.11.1 in `tool/api_generator/` with English names, the normaliser (`required` on response-only schemas, names guard), the generated and stamped `packages/kiveto_portal_api/`, `make api-sync` / `api-generate` / `api-check` (`api-check` is the 7th step of `make ci`), dio / tonik_util / the client as app dependencies, rule 7 extended to tonik_util, the contract-fixture integration test and helpers, milestone V3 (a, b, c), the docs and the deferred backend proposals.
- **Files:** `contracts/{portal.v1.yaml,SOURCE}` (copy + provenance); `packages/kiveto_portal_api/**` (generated client + `CONTRACT`); `tool/api_generator/{pubspec.yaml,pubspec.lock,tonik.yaml}` (pinned generator and names); `tool/lib/portal_api.dart`, `tool/portal_api.dart` (sync / stamp / check, SHA-256, SDK only); `tool/lib/contract_normalizer.dart`, `tool/normalize_contract.dart` (normaliser + names guard, `yaml`); `tool/pubspec.yaml` (`yaml: 3.1.4`); `scripts/api.sh`, `Makefile`, `scripts/ci.sh`, `scripts/lib.sh` (targets, ci list, pub-get input); `pubspec.yaml`/`pubspec.lock` (dio 5.11.1, tonik_util 0.11.1, the path package); `test/architecture/*` (rule 7 + tonik_util, self-test); `test/tool/{portal_api,contract_normalizer}_test.dart`; `test/scripts/{api_sh,api_check_sh,portal_api_main}_test.sh`, `lib_test.sh`, `ci_sh_test.sh`; `test/support/portal_api/fake_portal_backend.dart` + 18 fixtures; `test/integration/portal_api_contract_test.dart` (13 tests); `.gitattributes`, `.gitignore`; `CONTRIBUTING.md`, `architecture.md`, `README.md`, `deferred-work.md`.
- **Review (1 pass, 42 findings):** patched — 3 medium entries (the `files` digest counting ignored files; `generate` deleting the client before the normaliser; no test of `scripts/api.sh check`) and 9 low entries (api-sync recovery hint, personal path, problem bodies wording + an `Error` decoding test, transitive packages recorded, CRLF contracts, pubspec comment, Windows `LOG_FILE`, `shasum` fallback, fixture wording); deferred — 2 (Makefile variable tests, CLAUDE.md); rejected — every other row, with its reason in the triage log (6 false, 2 maybe-false whose if-true grade is low, the rest low with an unlikely trigger and a fix adding complexity).
- **Follow-up review recommended: true** (3 medium entries patched on a first pass). Unverified risk: the `generate` / `sync` branches of `scripts/api.sh` (deletion order, failure messages, `KV_RESTORE`) have no automated test — verified by hand once each (`make api-generate` with a missing name, `make api-sync` with a missing name: refused, client kept, message with `git checkout -- contracts packages/kiveto_portal_api`).
- **Verification:** `make ci` green after the review fixes (2 min 07: format-check 1 s, analyze 10 s, test-architecture 5 s, test-coverage 9 s, coverage-gate 2 s, test-scripts 1 min 37, api-check 2 s; `tool/lib` 100%); `make api-generate` byte-identical (only the `inputs` line of `CONTRACT` changed after the normaliser and `portal_api.dart` edits, as designed); V3c re-run by the orchestrating agent (appended line → both messages, exit 2; restored → green).
- **Residual risks:** tonik is a young 0.x single-maintainer generator (pinned with its lock; swagger_parser fallback documented in the spike); every response field is optional in the contract itself until the backend declares `required` (the local normaliser covers component schemas only, not inline nested objects); errors are values unless phase 5 sets the 2xx-only `validateStatus`; 302 file routes end in `TonikError(decoding)` when Dio follows the redirect; GitHub Actions and the macOS run never happened.
