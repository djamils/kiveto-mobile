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

## Deferred from: spec-portal-api-client.md (phase 4, 2026-11-03)

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Correct CLAUDE.md (needs the user's own go-ahead, agent-context file): bootstrap status "phases 1–4 done" (phase 4 validated on Windows, macOS pending); §5 "The generator is not chosen yet" → tonik 0.11.1 (D3), `make api-sync REF=<sha>` / `api-generate` / `api-check`, the normalised build copy, never hand-edit `contracts/`, `packages/kiveto_portal_api/` or the CONTRACT stamp; §3 "`tonik_util` is confined like the generated client (rule 7)".
  evidence: CLAUDE.md §5 still says the spike of phase 4 compares candidates; the spec forbids editing CLAUDE.md without the user's go-ahead. architecture.md, CONTRIBUTING.md and README.md are up to date.

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Add the remote fallback of `make api-sync` (a temporary `git clone --filter=blob:none --no-checkout` of djamils/kiveto, then `git show <sha>:openapi/portal.v1.yaml`) for machines without a backend checkout.
  evidence: Out of the phase 4 scope (a clone of the private repository may open a sign-in window); `api-sync` reads a local checkout only (`KIVETO_BACKEND_DIR`, default `../kiveto`).

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Validate phase 4 on macOS: `make api-sync` (with a sibling `../kiveto` checkout), `make api-generate` byte-identical to the committed client (`git status` clean), `make api-check`, and `make ci` with its seven steps under `/usr/bin/make` 3.81 and bash 3.2.
  evidence: Every `make api-*` run and the V3 milestone ran on Windows only (Git Bash, make 4.4.1).

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Backend proposal (spike §7.2) — declare `required` on the output schemas (API Platform: `required: true` on the output DTO properties, or a schema-factory decorator for output classes); then drop `tool/normalize_contract.dart` from `make api-generate`.
  evidence: 88 of 110 schemas have no `required` although the server's success bodies carry every key (`null` included; its problem+json bodies omit some nullable keys such as `detail` and `instance`); the mobile normaliser adds it to 84 response-only schemas of the build copy so that tonik types them non-null (spike `live/logs/tonik-required-live.log`).

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Backend proposal (spike §7.3) — declare `required` on the input schemas whose properties carry `#[ApiProperty(schema: …)]`: `AppointmentBooking` (petId, motifId, practitionerId, startAt are `NotBlank`), `AppointmentReschedule`, `AppointmentBookingWithNewPet` / `ListingBooking` (only `newPet` is required), `ProfileAddress.countryCode`.
  evidence: The generated request classes take every one of these as optional (`AppointmentBooking({String? petId, …})`); the guide says they are mandatory.

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Backend proposals (spike §7.4–§7.6) — naming: one schema per output class (20 byte-identical and 7 near-identical duplicates: `AppointmentView` ×6, `OtpChallengeView` ×5, `AccountView` ×3…); explicit camelCase operationIds and English tags (`openapi: new Operation(operationId: 'getHome')`); query enums as components (`AppointmentScope`, `DocumentType`), optionally `servers: [{url: /api/portal/v1}]` with relative paths. Each one shrinks `tool/api_generator/tonik.yaml` and the generated names that remain.
  evidence: The client has a class per duplicate (and a mapper per class later); 60 operation, 11 tag and 34 dotted-schema renames live in `tonik.yaml`; 109 inline model types keep a path-derived name (99 named after their schema key, such as `AppointmentAppointmentViewStatusModel`; 10 after their route, such as `ApiPortalV1ClinicsClinicIdAppointmentsParametersModel`), plus the 3 `PATCH /me` body classes and the 58 `ApiPortalV1…Response` error bodies — spec implementation notes.

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Backend proposals (spike §7.7–§7.9) — responses: reference `Error` (`application/problem+json`) on every 4xx/5xx and list the `type` codes; document the `Location` header of the 302 file routes; list `application/merge-patch+json` first (or alone) on `PATCH /me`.
  evidence: 133 of 191 error responses have no schema (every 401, most 404), so the client returns e.g. `GetMeResponse401()` without body; the 302 file operations end in an undocumented 200 when Dio follows the redirect; the generated `updateMe` takes a sealed body with both content types.

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Backend proposal (spike §7.10) — accept RFC 3339 `date-time` values in requests (fractional seconds, `Z`), or document "no fractional seconds" in the contract.
  evidence: `startAt` is validated with `Assert\DateTime(DATE_ATOM)`, which rejects `2026-11-04T12:30:00.000Z`; the client encodes a slot value without fractional seconds (`test/integration/portal_api_contract_test.dart`), but a UTC `DateTime` built by the app would be refused.

## Deferred from: code review of spec-portal-api-client.md (2026-11-03)

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Test the Makefile's handling of inherited variables: `REF`, `PLATFORM` and `ENV` set only in the environment are ignored (`REF=x make api-sync` must stop with "REF is required"), `KIVETO_BACKEND_DIR` is honoured.
  evidence: Verification-gap finding: the `ifeq ($(origin REF),environment)` block of the Makefile is untested (so are the `PLATFORM` and `ENV` ones); `test/scripts/api_sh_test.sh` runs `scripts/api.sh` directly, never through make.

- source_spec: `_bmad-output/implementation-artifacts/spec-portal-api-client.md`
  summary: Capture contract fixtures of the POST responses the normaliser also makes all-required (`POST /auth/otp/verify` for `authenticated`, `invitation_pending` and `registration_required`, `/auth/refresh`, `/auth/otp/request`, a booking 201) and decode them in an integration test — slice 1 (`identity_access`) and slice 4 (`scheduling`) at the latest.
  evidence: Code review (blind-hunter), maybe-false, if true medium: the 18 fixtures are GET responses plus the 401/404/422; the live V3(b) run decoded `requestOtp` 202 and `verifyOtp` 200 `authenticated`, but a branch-dependent body that omits a non-nullable key (e.g. an `invitation_pending` verification without tokens) would only fail at runtime as a decoding `TonikError`. Settled by capturing those responses from the local backend.
