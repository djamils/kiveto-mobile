# Claude Code instructions for Kiveto Mobile

This file is auto-loaded by Claude Code at the start of every session in
this project. It pins the non-negotiable directives so that any agent
working on the repo behaves consistently across sessions and machines.

> **First action of any session:** read `CONTRIBUTING.md` for the git flow,
> the commands, the architecture rules and the BMAD workflow, and
> `_bmad-output/planning-artifacts/architecture.md` for the architecture
> decisions. This file is the short, MUST-OBEY summary.

---

## Project at a glance

- **What:** the Flutter app (Android and iOS) of the Kiveto Portal, the
  pet owners' space. It is a client of the Portal API of the Kiveto
  Symfony backend; the backend owns every business rule.
- **Stack:** Flutter 3.47.9 / Dart 3.13.7 pinned with FVM (`.fvmrc`),
  Riverpod 3, go_router, Dio, a client generated from the backend's
  OpenAPI contract.
- **Architecture:** feature-first, DDD and Clean Architecture (D15):
  `lib/features/<bounded_context>/{domain,application,infrastructure,presentation}`
  plus `di.dart` and `<bounded_context>.dart`, shared kernel in
  `lib/shared/{domain,presentation}`, technical core in
  `lib/core/{network,security,errors,di}`, composition root in
  `lib/app/{bootstrap,routing,theme}`.
- **Planning method:** BMAD 6.12.4 (`_bmad/`), artefacts in `_bmad-output/`.
- **Bootstrap status:** phases 1–3 done once `chore/quality-gates` is
  merged (phase 2 validated on Windows and macOS). The Flutter project,
  the `Makefile`, `make ci`, the git hooks and the GitHub Actions workflow
  exist; the API client arrives in phase 4. See `CONTRIBUTING.md` §0
  before relying on a command.

---

## Non-negotiable directives

### 1. `make ci` must be green before every commit

`make ci` is the quality gate: format check, `dart analyze --fatal-infos
--fatal-warnings`, architecture tests, unit / widget / integration / tool
tests with coverage, coverage gate, plain-bash checks of the scripts and
hooks (phase 4 adds the contract check). Run it before every commit; if it
fails, fix the failures rather than committing yellow. GitHub Actions runs
it again on every pull request.

### 2. Git flow — GitHub Flow, no `staging` branch

- **Never work directly on `master`.** Every change is on a dedicated
  branch `<type>/<slug>` (`feature`, `fix`, `hotfix`, `chore`), merged by
  Pull Request. Direct pushes to `master` are forbidden.
- One branch = one logical change.
- Conventional Commits (`feat(patient): …`, `fix(identity_access): …`,
  `chore(ci): …`), see `CONTRIBUTING.md` §3; the `commit-msg` hook refuses
  any other subject.
- **Never commit or push unless the user explicitly asks you to.**

### 3. Layers and boundaries

- `features/*/domain/` and `shared/domain/` import no package at all (no
  Flutter, no Riverpod, no Dio, no generated code) — only
  `dart:core/async/collection/math`, their own domain and `shared/domain/`.
- `features/*/application/` adds its own domain and `shared/domain/`; still
  no Flutter, Riverpod, Dio, generated code or `core/`. A use case exists
  only when it orchestrates something; no pass-through use cases.
- `features/*/infrastructure/` (with `core/network/` and `core/di/`) is the
  only place that talks to Dio and to the generated API client, and it maps
  generated DTOs to domain models. DTOs never leave it.
- `presentation/` (feature pages, widgets, Riverpod notifiers, and
  `shared/presentation/`) never imports `infrastructure/`, Dio, the
  generated client, `core/network/` or `core/security/`.
- Only `features/*/di.dart`, `core/di/`, `app/bootstrap/` and tests import a
  feature's `infrastructure/`. Another feature is reached only through its
  public `features/<other>/<other>.dart`; no cycles. `core/` and `shared/`
  never import a feature; `shared/` never imports `core/` or `app/`.
- No `DateTime.now()`, `print(` or `coverage:ignore` in
  `features/*/domain/`, `features/*/application/` or `shared/domain/`:
  inject the `Clock`.
- Do not re-implement rules the backend enforces (phone coverage, OTP
  limits, slots, cancellation window, quotas): the server decides, the app
  shows its answer.

These rules (architecture §3, D15) are checked by `test/architecture/`.

### 4. Coverage is enforced by the tooling

`features/*/{domain,application,infrastructure}`, `shared/domain`,
`core/{network,security,errors}` and `tool/lib` stay at **100% line
coverage**, file by file. `features/*/presentation`, `shared/presentation`,
`app/`, `core/di`, `di.dart` and `<feature>.dart` are measured and shown
without a threshold. The coverage gate counts every file of `lib/` and
`tool/` that no test loads as 0%: adding an untested file fails the gate,
and so does a file outside the D15 layout. Never add `coverage:ignore`
comments to the gated layers.

### 5. The Portal API contract

- `contracts/portal.v1.yaml` is a copy of the backend's
  `openapi/portal.v1.yaml`, pinned by commit SHA in `contracts/SOURCE`.
  Update it only with `make api-sync`, never by hand.
- `packages/kiveto_portal_api/` is generated and committed. Never edit it
  by hand; regenerate it with `make api-generate`.
- An API change starts with a backend PR. The generator is not chosen
  yet: the spike of phase 4 compares candidates on the real contract.

### 6. Code style and language

- Code comments, identifiers and documentation in **English**. User-facing
  strings in **French**, in the ARB files (`lib/l10n/`), never hard-coded.
- Follow the analyzer configuration; if a rule conflicts with what you
  want to do, the rule wins.
- No `print`; no `dynamic` at API boundaries.

### 7. Dependencies

Add a package only after checking its current version, its maintenance and
its compatibility with the pinned Dart SDK and the other dependencies. No
abstraction, fallback or package added "for later".

### 8. BMAD for planning

For non-trivial work: `bmad-spec` → `bmad-build` → `bmad-code-review`.
Architecture decisions go through `bmad-architecture` into
`_bmad-output/planning-artifacts/architecture.md`. `bmad-build` needs `uv`.

---

## Useful pointers

| You want to know…                  | Look at…                                           |
|------------------------------------|----------------------------------------------------|
| Git flow, commands, DoD            | `CONTRIBUTING.md`                                  |
| Architecture decisions             | `_bmad-output/planning-artifacts/architecture.md`  |
| Specs of past and current work     | `_bmad-output/implementation-artifacts/`           |
| What the API returns, error codes  | backend `openapi/portal-api-v1.md`                 |
| BMAD skills                        | `.claude/skills/bmad-*`, `bmad-help`               |

---

## Things NOT to do

- Don't work on or push to `master`. Don't create a `staging` branch.
- Don't commit or push without an explicit request.
- Don't bypass `make ci`, git hooks (`--no-verify`) or signing.
- Don't import `infrastructure/`, Dio or the generated client from
  `presentation/`, and nothing but pure Dart into `domain/`.
- Don't edit `packages/kiveto_portal_api/` or `contracts/` by hand.
- Don't install anything globally (FVM, SDKs, system settings) from a
  script or a command without the user's go-ahead.
- Don't write code comments in French, or user-facing strings in Dart code.
- Don't pin a dependency version you have not verified.
