---
title: 'Slice 1 — identity_access (sign-in, invitation, registration, logout) and the minimal client feature'
type: 'feature'
created: '2026-11-03'
status: 'done'
baseline_revision: 'a22f81f8ff0314c873e7b5aa366134b5e66ddda2'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/CONTRIBUTING.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-app-shell.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/screens.md'
warnings: ['multiple-goals', 'oversized']
deferred:
  - summary: >-
      The "politique de confidentialité" link of the terms consent opens the terms page: the contract gives one terms URL only.
    evidence: |-
      `CurrentTerms` has only `version` and `url` (`GET /legal/terms/current`); a privacy-policy URL needs a backend contract field (or the terms page must hold the policy). Blind-hunter review, verified.
    location: >-
      lib/features/identity_access/presentation/terms_consent.dart
    severity: medium
  - summary: >-
      End-to-end tests (integration_test/, make test-e2e) still have no home; slice 1 left them deferred.
    evidence: |-
      A device test of the sign-in needs a real OTP, readable only in the backend's worker log; trigger recorded in deferred-work.md (before the first store build, or once the backend exposes a dev OTP read-back).
    severity: low
  - summary: >-
      Device-level behaviour (real backend, OS deep-link handoff cold and warm, mockup fidelity) was not exercised by the tests at review time.
    evidence: |-
      Intent-alignment review, maybe-false: the tests run the real HTTP chain on a fake transport; settled by the emulator walk of the slice agent right after the review (Auto Run Result).
    severity: medium (unverified)
---

<intent-contract>

## Intent

**Problem:** The app has the shell (router, kit, auth chain) but every screen is a placeholder: nobody can sign in, accept a clinic invitation, register or sign out, and the shell seams (`hasConfirmedClinicProvider`, `accountInitialsProvider`, `unreadDocumentsCountProvider`) and the active clinic every later slice needs do not exist.

**Approach:** Build the `identity_access` feature (screens 7 Bienvenue, 8 Code, 9 Inscription, 0 Activation, the `invitation_pending` onboarding page, the logout use case) and a minimal `client` feature (`GET /me` → `Me`, the active clinic persisted with `shared_preferences`), wire them into the router and the seams, add a reactive `sessionStatusProvider`, and replace the `/home` placeholder by one that proves the session (first name + active clinic). The backend decides every rule; the app shows its answers in French.

## Boundaries & Constraints

**Always:**
- D15 layers and rules 1–8 (`test/architecture/`); 100% line coverage of every new file of `features/*/{domain,application,infrastructure}`, `core/{network,security,errors}`; `make ci` green.
- Material only from `package:material_ui/material_ui.dart`; Dart 3.13 constructor style (`const new(...)`); no `print`, no `DateTime.now()` in domain/application (inject `Clock`); repositories throw `ApiFailure` (no Result type).
- User-facing strings in French in `lib/l10n/app_fr.arb` only (keys prefixed `identity…`, `client…`, `home…` with `@key.description`), then `fvm flutter gen-l10n`; code, comments, docs in English.
- Build the screens as mockups `00/07/08/09.html` show them (notes folder `mockup/`), with the phase-5 kit (`lib/shared/presentation/`), white auth pages, 24 gutter, the paddings of design-system §4.1, `SafeArea` top and `kivetoBottomPadding` at the bottom; real backend data, never the mockup samples.
- Tokens (access, refresh, onboarding, registration, invitation token) never reach a log, a `toString`, a route path or a query string; the invitation token travels only in request bodies (and the `#t=` fragment it arrived in).
- Account-scoped providers watch `sessionStatusProvider` and are read through `AsyncData` patterns / `AsyncValueView`, never `.value` (a reload keeps the previous account's value).
- New dependencies pinned exactly: `shared_preferences: 2.5.6`, `url_launcher: 6.3.3` (both flutter.dev, latest on pub.dev 2026-11-03, Dart ≥ 3.11, resolution checked with `fvm flutter pub add --dry-run`).

**Never:**
- Re-implement backend rules: phone coverage (no mobile-prefix check), OTP quotas, code lifetimes, terms version logic, name length rules — the server answers, the app displays.
- Edit `packages/kiveto_portal_api/`, `contracts/`, `CLAUDE.md`, `.claude/settings.json`; import `package:flutter/material.dart`; import `app/` from a feature; call the generated client outside `infrastructure/`.
- Build screens of later slices (Accueil 1, Trouver une clinique 10, Compte 6, the clinic switcher sheet): `/home` and `/account` stay placeholders (with the additions below), `/clinics` stays a placeholder.
- Add `integration_test/` / `make test-e2e` (deferred), a "do not refresh" flag for logout (not needed, see Design Notes), or a public signed-out directory entry.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Request code | 7: "6 12 34 56 78" (or "06 12 34 56 78") with +33 | `POST /auth/otp/request {phone:"+33612345678"}` → 8 shows "Envoyé par SMS au **06 12 34 56 78**" | 422 `phone_not_supported` / `validation_failed`, 429 `otp_rate_limited` (minutes from `Retry-After`), network: French message under the field (C-18e), CTA re-enabled |
| Verify, authenticated | 8: 6 digits | session opened (`SessionManager.open`), → `/home` | — |
| Verify, authenticated + `pendingInvitations` | non-empty list + `onboardingToken` | session opened, → `/onboarding/invitations` (signed-in variant with "Plus tard") | — |
| Verify, invitation_pending | `invitations[]`, `onboardingToken` | no session, → `/onboarding/invitations` | — |
| Verify, registration_required | `registrationToken` | no session, → `/register` | — |
| Verify errors | 422 `otp_invalid` / `otp_expired` / `otp_attempts_exceeded`, 403 `account_disabled`, 429, network | stays on 8, specific French message under the OTP boxes (error border) | message cleared on the next edit |
| Resend | countdown to `resendAvailableAt` reached 0 | `POST /auth/otp/{challengeId}/resend {channel: sms\|email}` → new countdown, confirmation line | 404 `otp_challenge_not_found` → message + "Recommencer" (→ 7); 429 → minutes message |
| Accept pending invitation | onboarding page, CGU checked | `POST /invitations/{id}/accept {onboardingToken, termsVersion}` → session opened; no invitation left → `/home`; others left → stay, accepted one removed | 401 `onboarding_invalid` → "vérification expirée" + "Se reconnecter" (→ 7); 404 `invitation_invalid` → that invitation removed + message; 422 `terms_outdated` → terms reloaded, box unchecked, message; 403 `account_disabled` |
| Deep link valid | `/invitation#t=<ROUSSEL_TOKEN>` | lookup → clinic tag, title with pet names, read-only email, code sent at once (`POST /invitations/otp`), "Code reçu par SMS au {maskedPhone}" → 6 digits + CGU → `POST /invitations/accept` → session → `/home` | code errors under the field; 429 on the code request shown with the resend control |
| Deep link expired / invalid / used / missing | 410 `invitation_expired` (PERRIN_TOKEN), 404 `invitation_invalid`, 410 `invitation_already_used`, no `#t=` | dedicated state: title + explanation + "Se connecter avec mon numéro" (→ 7; signed in: "Revenir à l'accueil" → `/home`) | network/5xx: `ErrorView` with retry |
| Register | 9: first + last name, optional email, CGU | `POST /auth/register` → session opened → router sends to `/home` → `/clinics` (no clinic) | 422 `validation_failed` → server message under the matching field (`firstName`/`lastName`/`email`); 401 `onboarding_invalid`, 409 `account_exists` → message + "Recommencer" (→ 7); 422 `terms_outdated` → reload terms; 403; 429 |
| Logout | "Se déconnecter" on `/account` | `POST /auth/logout {refreshToken}` then local sign-out → `/welcome` | any failure (network, 401, 5xx) still signs out locally |
| Restart signed in | stored pair | shell opens; `/me` loaded; no sign-in | — |
| Clinic-less account | `/me clinics: []` (Moreau, a new account) | `hasConfirmedClinicProvider` false → `/home` redirects to `/clinics` | — |
| Active clinic | `/me` with Paris + Lyon confirmed, stored choice for this account | stored id if still a confirmed clinic, else the first confirmed; none → null | storage read failure → default (first confirmed) |

</intent-contract>

## Code Map

Foundation (read, reuse; change only where a task says):
- `lib/core/security/session_manager.dart` -- `SessionManager` (`open`, `signOut`, `replaceTokens`, `tokens`, `status`, `SessionStatus`); `replaceTokens` calls `open` today (the refresh path).
- `lib/core/di/core_providers.dart` -- `sessionManagerProvider`, `portalServerProvider`, `apiFailureMapperProvider`, `clockProvider`; add `sessionStatusProvider` here.
- `lib/core/network/portal_results.dart` -- `apiFailureOf(result, failures)` for every non-wanted `TonikResult` (all non-2xx arrive as `TonikError`, strict status chain).
- `lib/core/network/auth_interceptor.dart` -- refreshes on 401 `token_expired`/`unauthorized` of a request sent with a token and replays the same body; `onboarding_invalid`/`refresh_revoked` pass through.
- `lib/shared/domain/api_failure.dart` -- sealed `ApiFailure` (`code`, `RateLimitedFailure.retryAfter`, `ValidationFailure.violations`, `BusinessFailure.statusCode`); `lib/shared/domain/clinic_id.dart` (`ClinicId` extension type); `lib/shared/domain/clock.dart`.
- `lib/shared/presentation/async/async_views.dart` -- `AsyncValueView`, `ErrorView(title:, message:)`, `failureMessage`, `EmptyState`, `LoadingView`.
- `lib/shared/presentation/kit/forms.dart` -- `KivetoPhoneField` (C-19, `onCountryTap`, `errorText`), `KivetoCodeField` (C-20), `KivetoOtpField` (C-21, no error state yet), `KivetoTextField` (C-18a/b, `readOnly`, `errorText`), `KivetoConsentCheckbox` (C-22a, `InlinePart` links).
- `lib/shared/presentation/kit/{buttons,surfaces,feedback,pills,navigation}.dart` -- `KivetoButton.primary(loading:)`, `KivetoTextButton` (C-8a), `KivetoInlineLinks`, `KivetoIconButton.back`, `KivetoBrandLockup` (C-38), `KivetoTag.brand/success` (C-12b), `KivetoCallout.info/danger` (C-33a/e), `KivetoRadioCard`, `KivetoCard`, `showKivetoSheet` + `KivetoSheet`, `KivetoListRow`.
- `lib/shared/presentation/formatters/kiveto_format.dart` -- `KivetoFormat.phone(e164)` → "06 12 34 56 78".
- `lib/app/routing/app_router.dart` -- routes with `PlaceholderPage`; `lib/app/routing/app_routes.dart` -- `AppRoutes`, `_signInOnly`, `redirectFor`, `invitationTokenFrom`; `lib/app/routing/shell_seams.dart` -- the three seams; `lib/app/routing/placeholder_page.dart` -- kinds `welcome`/`invitation` (to retire), `account` (sign-out button), `notFound`; the debug link to `/debug/kit` lives on the welcome placeholder.
- `lib/app/bootstrap/bootstrap.dart` -- `ProviderScope.overrides`.
- Generated client (read only): `AuthApi.requestOtp/verifyOtp/resendOtp/register/logout`, `InvitationsApi.lookupInvitation/requestInvitationOtp/acceptInvitation/acceptInvitationById(invitationId:)`, `TermsApi.getCurrentTerms`, `AccountApi.getMe`; bodies `OtpRequest`, `OtpVerification`, `OtpResend(channel: OtpResendChannelModel.sms|email)`, `Registration` (`email` nullable), `SessionLogout`, `InvitationLookup`, `InvitationOtpRequest`, `InvitationAcceptance`, `InvitationGrantAcceptance`; results `OtpVerificationResult` (`status`: `authenticated|invitationPending|registrationRequired|unknown`, every key present, nulls on the other branches), `OtpChallengeView`/`ResentOtpChallengeView`/`InvitationOtpChallengeView` (`challengeId, expiresAt, resendAvailableAt`), `RegistrationResultView`/`AcceptedInvitationView`/`AcceptedInvitationGrantView` (tokens + `AccountView`), `InvitationLookupView` (`invitationId, clinic{id,name,city?}, email?, maskedPhone, petNames, expiresAt`), `CurrentTerms(version, url)`, `Me(account: AccountView, clinics: List<ClinicLinkView>)`, `AccountView(id, firstName?, lastName?, email?, emailVerified, maskedPhone, address.addressView?)`, `AddressView(line1, line2?, postalCode?, city, country)`, `ClinicLinkView(clinicId, name, city?, timezone, linkStatus pending|confirmed|unknown, linkedAt?, petNames, tags, unreadDocuments)`. Wire dates are UTC (`+00:00`): store `.toUtc()`.
- Test support: `test/support/fakes.dart` (`pumpKivetoApp`, `pumpKit`, `memorySession`, `pair`, `FixedClock`, `InMemoryTokenStorage`), `test/support/portal_api/fake_portal_backend.dart` (`FakePortalBackend`, `PortalReply.fixture/json`, `portalServer(backend)`, `backend.requestsTo`), `test/support/portal_api/portal_http_harness.dart` (`PortalHarness.create(tokens:)`, `problem(type, status)`, `refreshes`).
- Real captures already added (2026-11-03, local backend, traces → `"[stripped]"`) in `test/support/fixtures/portal_api/`: `auth.otp.request.post.202.json`, `auth.otp.request.post.422.json` (validation_failed), `auth.otp.request.phone-not-supported.post.422.json`, `auth.otp.request.post.429.json` (live `Retry-After: 3599`), `auth.otp.verify.{authenticated,invitation-pending,registration-required}.post.200.json`, `auth.otp.verify.otp-invalid.post.422.json`, `auth.otp.resend.post.404.json`, `auth.refresh.post.200.json`, `auth.refresh.post.401.json`, `auth.register.post.201.json`, `auth.register.terms-outdated.post.422.json`, `legal.terms.current.get.200.json`, `invitations.lookup.post.200.json` (Roussel), `invitations.lookup.expired.post.410.json`, `invitations.lookup.invalid.post.404.json`, `invitations.otp.post.202.json`, `me.no-clinic.get.200.json`; `me.get.200.json` exists (Girard, Paris + Lyon). The two invitation acceptance 200s are captured during the live walk (they consume an invitation).
- Backend facts checked live: `POST /auth/logout` with a rotated (spent) refresh token revokes the whole family (`RevokePortalSessionHandler` finds the token by hash whatever its rotation state); a resend on a verified challenge answers 404 `otp_challenge_not_found`; terms version `2026-10-29`, url `http://portal.kiveto.local/cgu`.

## Tasks & Acceptance

**Execution:**
- `pubspec.yaml` -- add `shared_preferences: 2.5.6`, `url_launcher: 6.3.3` (exact) via `fvm flutter pub add`; commit the lock -- persistence of the active clinic; opening the terms URL.
- `android/app/src/main/AndroidManifest.xml` -- `<queries>` with the `VIEW` + `https` intent (url_launcher README) -- terms links on Android 11+.
- `lib/core/security/session_manager.dart` -- add `int get generation`: `open()` increments it (a sign-in, an acceptance, a registration), `signOut()` increments it when it actually signs out, `replaceTokens` installs the refreshed pair WITHOUT incrementing (private install helper) -- refreshes must not rebuild account data.
- `lib/core/di/core_providers.dart` -- `sessionStatusProvider` (`NotifierProvider<SessionStatusNotifier, SessionStatus>`): listens to the `SessionManager`, sets `state` when `generation` changes, `updateShouldNotify` always true (a sign-in over a sign-in still notifies), removes its listener on dispose; `export '…/session_manager.dart' show SessionStatus;` so presentation can compare without importing `core/security` -- the deferred reactive session provider.
- `lib/features/identity_access/domain/` -- pure Dart: `phone_number.dart` (`PhoneNumber.fromNational(countryCode:, national:)` → digits only, one leading `0` dropped, `e164`; null without digits), `session_tokens.dart` (redacted `toString`), `otp_challenge.dart` (`id`, `expiresAt`, `resendAvailableAt`), `otp_channel.dart`, `otp_verification.dart` (sealed: `AuthenticatedVerification(tokens, pendingInvitations, onboarding?)`, `InvitationPendingVerification(onboarding, invitations)`, `RegistrationRequiredVerification(registration)`; `PendingInvitation(id, clinicName, clinicCity?)`, `OnboardingGrant(token, expiresAt)`, `RegistrationGrant(token, expiresAt)`), `invitation_preview.dart`, `terms.dart`, `registration_request.dart`, contracts `auth_repository.dart`, `invitation_repository.dart`, `terms_repository.dart`, port `session_store.dart` (`open(SessionTokens)`, `close()`, `String? get refreshToken`) -- the vocabulary of the flows.
- `lib/features/identity_access/application/` -- `sign_in_with_code.dart` (verify; `authenticated` → `session.open` then return `SignedIn(pendingInvitations, onboarding?)`; the other branches return `InvitationPending(...)` / `RegistrationRequired(...)` without opening; tokens never in the outcome), `accept_invitation_by_link.dart`, `accept_pending_invitation.dart` (one invitation by id + onboarding token + terms version → open), `register_account.dart`, `sign_out.dart` (`logout(refreshToken)` when a session exists, any `ApiFailure` ignored, `session.close()` in `finally`) -- the orchestrations; no pass-through use case for request/resend/lookup/code/terms.
- `lib/features/identity_access/infrastructure/` -- `portal_auth_repository.dart`, `portal_invitation_repository.dart`, `portal_terms_repository.dart` (generated APIs, `apiFailureOf` for everything else, `unknown` verification status → `ServerFailure`), `session_manager_store.dart` (`SessionStore` over `SessionManager`, `TokenPair` with UTC expiries) -- the only client/Dio users.
- `lib/features/identity_access/di.dart` -- providers of the three repositories, the store and the five use cases (`signOutProvider`…).
- `lib/features/identity_access/presentation/` -- `flows.dart` (Notifiers: `signInFlowProvider` {phone e164, challenge}, `onboardingProvider` {grant, invitations, signedIn}, `registrationFlowProvider` {grant, phone}; `currentTermsProvider` autoDispose); `phone_input_formatter.dart`; `identity_messages.dart` (failure → French text per `code`); `terms_consent.dart` (C-22a bound to `currentTermsProvider`, links open `Terms.url` with `url_launcher`, snackbar when it cannot); `resend_countdown.dart` (m:ss from `clockProvider`, 1 s ticker); `welcome_page.dart` (7), `country_code_sheet.dart`, `invitation_link_sheet.dart`, `code_page.dart` (8), `register_page.dart` (9), `onboarding_invitations_page.dart`, `invitation_page.dart` (0) + its controller -- screens per Design Notes.
- `lib/features/identity_access/identity_access.dart` -- public API: the pages and `signOutProvider`.
- `lib/features/client/domain/` -- `me.dart` (`Me`, `Account` with `initials`/`firstName`, `PostalAddress`, `ClinicLink` with `ClinicId`, `LinkStatus {confirmed, pending, unknown}`, UTC `linkedAt?`, `petNames`, `tags`, `unreadDocuments`; `Me.confirmedClinics`, `hasConfirmedClinic`, `activeClinic({String? preferredClinicId})`), `me_repository.dart`, `active_clinic_store.dart` (`read(accountId)`, `write(accountId, clinicId)`).
- `lib/features/client/infrastructure/` -- `portal_me_repository.dart` (`AccountApi.getMe`), `preferences_active_clinic_store.dart` (`SharedPreferencesAsync`, key `client.activeClinic.<accountId>`).
- `lib/features/client/di.dart`, `lib/features/client/presentation/client_providers.dart` (`meProvider`: watches `sessionStatusProvider`, signed out → throws `UnauthorizedFailure`, else `repository.me()`; `activeClinicProvider`: `AsyncNotifier<ClinicLink?>` from `meProvider` + store, `select(ClinicId)` persists, store read failure → default), `lib/features/client/client.dart` (exports domain + both providers).
- `lib/shared/presentation/kit/forms.dart` -- `KivetoOtpField.errorText` (C-18e: red borders, message replaces the help text, announced) -- needed by 8.
- `lib/app/routing/app_routes.dart` -- remove `signInCode` from `_signInOnly` (8 navigates itself after the session opens; a stale 8 with no flow goes to 7) -- avoids the redirect unmounting 8 mid-branch.
- `lib/app/routing/app_router.dart` -- real pages on `/welcome`, `/sign-in/code`, `/register`, `/onboarding/invitations`, `/invitation` (token from `invitationTokenFrom`); exits passed as callbacks `void Function(BuildContext)` built on `AppRoutes` (features never import `app/`); `/home` → `home_placeholder_page.dart`; debug kit link passed to 7 in debug only.
- `lib/app/routing/home_placeholder_page.dart` -- `KivetoPageHeader("Bonjour {firstName}", subtitle: active clinic name)` + placeholder body, via `AsyncValueView` on `meProvider` / `activeClinicProvider`.
- `lib/app/routing/placeholder_page.dart` -- drop the `welcome`/`invitation` kinds; the account kind's "Se déconnecter" runs `signOutProvider` (button loading while it runs).
- `lib/app/bootstrap/feature_overrides.dart` + `bootstrap.dart` -- `featureOverrides()`: `hasConfirmedClinicProvider` (AsyncData → `hasConfirmedClinic`, else null), `accountInitialsProvider` (AsyncData → `initials`), `unreadDocumentsCountProvider` (AsyncData active clinic → `unreadDocuments`, else 0).
- `lib/l10n/app_fr.arb` (+ gen-l10n) -- every string of the screens and messages (copy in Design Notes).
- Tests -- `test/unit/core/security/session_manager_test.dart` (generation), `test/unit/core/di/session_status_provider_test.dart` (notifies on sign-in/out/sign-in-over-sign-in, not on refresh), `test/unit/features/identity_access/{domain,application,infrastructure}/…` and `test/unit/features/client/…` (100%; infrastructure on the fixtures above through `portalServer(backend)`; acceptances on JSON shaped like `auth.register.post.201.json` until the live captures land; the logout through `PortalHarness` with an expired access token: one refresh, the replay carries the same body, the session ends signed out; the preferences store with a mocktail `SharedPreferencesAsync`), `test/widget/features/identity_access/…` (each page: states of the matrix, navigation callbacks recorded), `test/widget/app/…` (router redirects updated for 8, app-level flow welcome → code → home on `PortalHttp.create(adapter: backend)`, seams, home placeholder, account sign-out) -- every matrix row covered.
- `CONTRIBUTING.md` §0 (slice 1 row), `_bmad-output/planning-artifacts/architecture.md` §5 (the two pins, the shared_preferences row now "pinned") -- keep the docs true.

**Acceptance Criteria:**
- Given the app signed out, when it starts, then 7 shows the mockup layout (lockup, title 30, phone field with "+33", help text, "Recevoir mon code", the C-33a invitation box) and the CTA stays disabled until the number is complete for its prefix (9 national digits for +33/+262/+590/+594/+596, at least 6 otherwise).
- Given 7, when "+33" is tapped, then a sheet lists +33 France, +262 La Réunion · Mayotte, +590 Guadeloupe, +594 Guyane, +596 Martinique, +508 Saint-Pierre-et-Miquelon, +681 Wallis-et-Futuna, +687 Nouvelle-Calédonie, +689 Polynésie française, and picking one updates the button and the E.164 sent.
- Given 7, when "J'ai un lien d'invitation" is tapped, then a sheet explains that the link opens the app and accepts a pasted `https://…/invitation#t=…` link that opens 0 with that token (an unparsable link shows an error).
- Given a signed-in session and a refresh of its tokens, when `sessionStatusProvider` is watched, then it does not notify; given a sign-out or a sign-in, then it notifies.
- Given the user on 8, when the code is wrong then right, then the error shows then clears on the next digit, and the right code lands on the destination of its branch.
- Given an expired access token, when "Se déconnecter" is tapped, then one refresh happens, the logout replays its body, and the app lands on 7 signed out even if the logout fails.
- Given `/me` loading after a session change, when the shell reads the seams, then `hasConfirmedClinicProvider` is null and the initials are null (no previous account's value).
- Given `make ci`, then it passes, with 100% on the new gated files and no architecture offence.

## Spec Change Log

## Review Triage Log

### 2026-11-03 — Review pass
- verdicts: 36 findings — high 0, medium 12, low 13, false 6, maybe-false 5
- findings:
  - `[medium]` `[patch]` (verification-gap) `bootstrap()`'s `...featureOverrides()` is checked by no test (`pumpKivetoApp` adds the seams itself) — `test/widget/app/bootstrap_test.dart` now asserts the pumped `ProviderScope` overrides the three seams.
  - `[medium]` `[patch]` (verification-gap, other) `InvitationController._ready()` casts after awaits while resend stays enabled during an acceptance: a 410 from one call then any answer of the other throws a `TypeError` out of an unawaited future — post-await updates guarded on `InvitationReady`, resend disabled while accepting (and accept while sending a code), test added.
  - `[false]` `[reject]` (blind) "the app does not open invitation links" — `android/app/src/debug/AndroidManifest.xml` declares the `VIEW`/`BROWSABLE` filter for `portal.kiveto.local/invitation` (phase 5); the production host is unknown and already deferred (deferred-work, production deep links). The filter now also takes `http` (the dev backend writes its SMS links with http).
  - `[low]` `[reject]` (blind) a replaced session (invitation accepted while signed in) is not revoked on the server — the contract says so on purpose ("l'ancienne reste valide jusqu'à son expiration ; l'app garde toujours la paire la plus récente"); revoking would add a logout branch to the acceptances for a rare path.
  - `[medium]` `[patch]` (blind) signed-in user on the invitation form has no way out (reached by `go`, Android back exits) — a centred "Revenir à l'accueil" (`onDone`) where the signed-out "Rattacher cette clinique" line is; widget test.
  - `[low]` `[reject]` (blind) "Plus tard" drops the pending invitations until the next sign-in, and "Se reconnecter" signed in lands on `/home` — the first is the contract's documented limit (no route lists the invitations of a signed-in account); the second only mislabels a 15-min-grant expiry on a rare path.
  - `[low]` `[reject]` (blind) "Valable 10 minutes." hard-codes the code lifetime — the mockup's copy for the contract's fixed 10-min lifetime (guide "Essais"); deriving it changes nothing visible today.
  - `[medium]` `[defer]` (blind) the "politique de confidentialité" link opens the terms URL — `CurrentTerms` has only `version` + `url`; a privacy-policy URL needs a backend contract field.
  - `[medium]` `[patch]` (blind) a malformed `#t=` (`%FF`) makes `invitationTokenFrom` throw in the route builder instead of the invalid state — `FormatException` caught (null), router test added.
  - `[false]` `[reject]` (blind) `authenticated` with `pendingInvitations` but no onboarding token drops them — without a grant they cannot be accepted (`POST /invitations/{id}/accept` requires it); landing on `/home` is the only outcome.
  - `[low]` `[reject]` (blind) a non-`ApiFailure` logout error surfaces as an unhandled async error — the session is closed first (`finally`), only a bug in the repository can raise it; catching it would hide that bug.
  - `[medium]` `[patch]` (blind) `ActiveClinicNotifier.select` races its own `build` and the session — `select` awaits the build, reads `/me` in a try, returns on error or when unmounted; tests added.
  - `[low]` `[reject]` (blind) fixtures hold a real-domain demo email and signed tokens — the email is the backend's demo fixture (Antoine Roussel); every captured token family was revoked (logout, then refresh → 401) and the access tokens expired; exact captures are the project's fixture rule (phase 4).
  - `[medium]` `[patch]` (blind) the slice's conventions (session generation, `sessionStatusProvider`, the `show SessionStatus` re-export, exits as callbacks, `featureOverrides`) are only in CONTRIBUTING.md — paragraph added to architecture.md §3.
  - `[low]` `[reject]` (blind) "Envoyé par SMS" stays after an email resend — the heading describes the first send, the conditional notice says where the new code may be; the SMS code stays valid when no verified email exists.
  - `[low]` `[defer]` (blind) e2e deferred with no target — deferred-work entry updated with the trigger (first slice with a CI device, or before the first store build).
  - `[medium]` `[patch]` (edge) dup of the `InvitationController` race — same patch.
  - `[low]` `[patch]` (edge) the CTA guard `terms is AsyncData` holds while the terms refresh after `terms_outdated` — `&& !terms.isLoading` in the three pages.
  - `[medium]` `[patch]` (edge) a number pasted/autofilled as "+33 6 …" or "0033 6 …" is cut to a wrong national number — the formatter drops the selected prefix's `+<code>` / `00<code>`; tests.
  - `[low]` `[reject]` (edge) device clock skew shifts the resend countdown — the server's `resendAvailableAt` is absolute; a skewed device clock is rare (network time) and the fix needs the response `Date` header in infrastructure.
  - `[medium]` `[patch]` (edge) sign-out waits for the Dio timeouts on a stalled network — logout bounded to 5 s, `TimeoutException` ignored like an `ApiFailure`; fake-async test.
  - `[medium]` `[patch]` (edge) `select` throws when `/me` is in error or the session changed — same patch as the select race.
  - `[medium]` `[patch]` (edge) `select` during `build` is overwritten — same patch.
  - `[low]` `[reject]` (edge) the welcome prefill can show a number typed before a sign-in by link then a sign-out — needs Modifier, then a link acceptance, then a sign-out on one device; the number is the device user's own.
  - `[low]` `[patch]` (edge) initials from a non-BMP first character keep half a surrogate pair — `String.fromCharCode(runes.first)`; test.
  - `[low]` `[patch]` (edge) two violations on one known field show a spurious general message — general message only for a violation outside firstName/lastName/email; test.
  - `[low]` `[patch]` (edge) resend enabled while a verification is in flight — disabled while `_verifying`.
  - `[maybe-false]` `[defer]` (intent) the sign-in flows ran only on the fake transport — settled by the emulator walk against the local backend (done after this review, see Auto Run Result).
  - `[maybe-false]` `[defer]` (intent) the OS deep-link handoff (cold/warm) is not tested — settled by `adb … am start -d …/invitation#t=` in the walk.
  - `[maybe-false]` `[defer]` (intent) the acceptance answers were synthetic — settled: `invitations.accept.post.200.json`, `invitations.accept-by-id.post.200.json`, `auth.otp.verify.authenticated-pending.post.200.json`, `invitations.lookup.used.post.410.json`, `invitations.accept-by-id.onboarding-invalid.post.401.json` captured live and used by the infrastructure tests.
  - `[false]` `[reject]` (intent) the active clinic is never written by a user action — the switcher is slice 3's (intent: "minimal client", seams); the persisted choice and its `select` API are tested.
  - `[false]` `[reject]` (intent) logout revocation backed only by a comment — checked live: a logout with a rotated refresh token revoked its successor (`auth.refresh.post.401.json` captured right after).
  - `[false]` `[reject]` (intent) "Rattacher cette clinique" does not accept this link's invitation by id — the sign-in it opens answers `authenticated` with that invitation in `pendingInvitations`, accepted by id on the onboarding page (screens.md's path).
  - `[false]` `[reject]` (intent) a signed-in link acceptance replaces the session — the contract's rule ("la paire la plus récente"); the account switch on a link for another number is the server's choice (the invitation's phone).
  - `[maybe-false]` `[defer]` (intent) e2e and V5 moved out of the slice — V5 is the emulator walk (done after this review); `integration_test/` stays deferred with its trigger.
  - `[maybe-false]` `[defer]` (intent) mockup fidelity only checked by text finders — settled by the emulator screenshots of the walk (`shots-identity-access/`).

## Design Notes

**Navigation.** Features never import `app/`. Each page takes its exits as `void Function(BuildContext context)` callbacks, built by `app_router.dart` on `AppRoutes` (e.g. `CodePage(onSignedIn: (c) => c.go(AppRoutes.home), onInvitations: …, onRegister: …, onRestart: (c) => c.go(AppRoutes.welcome))`). 7 pushes 8 (back pops); the other exits `go`. Order on 8 for `SignedIn` with pending invitations: the session opens inside the use case; because `/sign-in/code` is no longer sign-in-only, the router does not move, and 8 then calls its exit. A page opened without its flow state (restart, stale route) calls its "restart" exit at once (`/onboarding/invitations` signed in → `/home`). Register success needs no exit: `/register` stays sign-in-only, the router sends it to `/home` → `/clinics`. 0 and onboarding call `onDone` (→ `/home`) after the session opens.

**Logout over the plain chain.** The backend revokes the family from any of its members, spent ones included (checked live: logout with the rotated token revoked its successor; `RevokePortalSessionHandler` → `findByHashForUpdate` + `revokeFamily`). So `AuthApi.logout` goes through `PortalHttp.dio`: with an expired access token the interceptor refreshes and replays the body — the family is still revoked. Write this in a comment and pin it with the `PortalHarness` test.

**Screens (mockup values in design-system §4/§7).**
- 7: column `space-between`, 32 24 28; top gap 32 (lockup / header gap 10: display 30 "La santé de vos animaux, avec votre clinique", bodyLarge "Rendez-vous en ligne, documents, rappels de vaccins." / form gap 14: phone field label "Numéro de mobile", placeholder "6 12 34 56 78", help "Vous recevrez un code par SMS. Pas de mot de passe.", CTA "Recevoir mon code"); bottom C-33a "Votre clinique vous a envoyé une invitation ?" / "Ouvrez le lien reçu par SMS ou email : vos animaux et votre historique seront déjà là." / "J'ai un lien d'invitation". Formatter: digits only; leading `0` → pairs ("06 12 34 56 78", max 10); otherwise 1 + pairs ("6 12 34 56 78", max 9) for the 10-digit plans, pairs for the others. Debug builds: a `KivetoTextButton` "Ouvrir le kit d'interface" under the box (existing key `welcomeKitGalleryLink`).
- 8: back (pop) → title 26 "Entrez le code reçu", "Envoyé par SMS au **{KivetoFormat.phone}**. Modifier" (Modifier → 7 with the number kept); C-21 legend "Code de vérification", help "Valable 10 minutes.", autofocus, auto-submit on the 6th digit; "Renvoyer le SMS dans m:ss" (disabled, muted) → "Renvoyer le SMS"; "Recevoir le code par email" disabled during the countdown too (the API refuses a resend before `resendAvailableAt`; deviation from the mockup, which draws it enabled); after an email resend: "Si un email vérifié est associé à votre compte, le code vous y a été envoyé."; after an SMS resend: "Nouveau code envoyé par SMS."; once the countdown is over: footnote "Vous n'avez pas reçu de code ? Réessayez dans quelques minutes." (guide, unknown-number budget). Bottom area 14 24 28: "Valider" (enabled at 6 digits, loading while verifying).
- 9: 16 24 28 `space-between`, gap 22: back (→ 7, flow cleared) → C-12b success tag "{06 12 34 56 78} vérifié" + title 26 "Créez votre compte" → form gap 16 (Prénom / Nom side by side gap 12, Email + help "Pour recevoir vos documents et confirmations.", CGU) → note "Vos animaux seront ajoutés lors de votre premier rendez-vous, ou retrouvés si votre clinique utilise déjà Kiveto."; CTA "Créer mon compte" enabled when both names are non-blank and CGU checked (email optional, sent null when blank).
- 0: 32 24 28 `space-between`, top gap 28: lockup → tag "Invitation : {clinic.name}" (no "de la": works for every name) + title 28 "Activez votre espace pour suivre {A, B et C}" ("Activez votre espace" when no pet) + "Rendez-vous, documents et rappels de soins, au même endroit." → form gap 16: read-only email (C-18b, help "Renseigné par la clinique.", hidden when null), C-20 "Code reçu par SMS au {maskedPhone as received}" placeholder "6 chiffres", resend text button with the 30 s countdown (requests a new invitation code), CGU; bottom gap 14: "Activer mon espace" (6 digits + CGU + terms loaded), signed out only: "Déjà un compte Kiveto ? **Rattacher cette clinique**" (→ 7). States: expired "Invitation expirée" / "Ce lien n'est plus valable. Demandez à votre clinique de vous renvoyer une invitation."; invalid or missing "Lien d'invitation invalide" / "Ce lien est incomplet ou a été remplacé par un envoi plus récent. Utilisez le dernier lien reçu, ou connectez-vous avec votre numéro."; already used "Invitation déjà utilisée" / "Cette invitation a déjà été acceptée. Connectez-vous avec votre numéro pour retrouver votre espace." — lockup, title 28, body, bottom CTA "Se connecter avec mon numéro" (signed in: "Revenir à l'accueil").
- Onboarding (`/onboarding/invitations`, screen 0's language): lockup → tag "Invitation : {name}" (one) or "{n} invitations" → title 28 "Activez votre espace" → body "Votre clinique vous invite à retrouver vos animaux sur Kiveto : rendez-vous, documents et rappels de soins, au même endroit." → one invitation: a `KivetoCard` row (clinic name 16/700, city 13 muted); several: `KivetoRadioCard`s (first selected) → CGU; bottom: "Activer mon espace" (one) / "Accepter cette invitation" (several); after an acceptance with invitations left: C-33a-style success line "{clinic} est rattachée à votre espace." and a "Plus tard" `KivetoTextButton` (→ `/home`); signed-out bottom line "Pas maintenant ? **Revenir à l'accueil**" (→ 7, flows cleared).
- Messages by code (French, ARB): `phone_not_supported` "Ce numéro de mobile n'est pas encore pris en charge par Kiveto."; `validation_failed` on the phone "Vérifiez votre numéro de mobile."; `otp_invalid` "Code incorrect. Vérifiez-le, puis réessayez."; `otp_expired` "Ce code a expiré. Demandez-en un nouveau."; `otp_attempts_exceeded` "Trop d'essais. Demandez un nouveau code."; `otp_rate_limited` "Trop de demandes de code. Réessayez dans {minutes} min." (unknown delay: "…dans quelques minutes."); `otp_challenge_not_found` "Cette demande de code n'est plus valable. Recommencez."; `account_disabled` "Ce compte est désactivé. Contactez votre clinique."; `onboarding_invalid` "Votre vérification a expiré. Reconnectez-vous avec votre numéro."; `account_exists` "Un compte existe déjà pour ce numéro. Connectez-vous avec votre numéro."; `terms_outdated` "Les conditions d'utilisation ont changé : relisez-les, puis acceptez-les à nouveau."; `invitation_invalid` (onboarding) "Cette invitation n'est plus disponible."; network/server/other → `failureMessage` body. Terms link failure: "Impossible d'ouvrir les conditions d'utilisation."

**Active clinic.** `Me.activeClinic(preferredClinicId:)`: the preferred one when it is a confirmed link of this `Me`, else the first confirmed in API order, else null. Stored per account id so a second account on the device never inherits it. The switcher UI is slice 3's; `activeClinicProvider.notifier.select(id)` is its API.

## Verification

**Commands:**
- `fvm flutter gen-l10n` -- expected: no diff after a second run.
- `make ci` -- expected: green (format, analyze with zero infos, architecture, tests, coverage gate 100% on gated files, scripts, api-check).

**Manual checks (if no CLI):**
- Emulator walk against the local backend is done by the slice agent after the review (not by the implementation subagent): Girard sign-in → home, restart, logout; Roussel/fresh invitation; PERRIN deep link; Moreau → `/clinics`; a new number → register.

## Auto Run Result

Status: done (2026-11-03). Baseline `a22f81f8ff0314c873e7b5aa366134b5e66ddda2`.

**Summary.** Slice 1 is built: the `identity_access` feature (screens 7 Bienvenue, 8 Code, 9 Inscription, 0 Activation, the pending-invitations page, the logout), a minimal `client` feature (`GET /me` → `Me`, the active clinic per account in `shared_preferences`), `SessionManager.generation` + `sessionStatusProvider`, the three shell seams filled by `featureOverrides()`, a `/home` placeholder proving the session, the account placeholder's "Se déconnecter" on the logout use case.

**Files changed (by area).**
- `lib/core/security/session_manager.dart` — `generation` (sign-in / sign-out, not refresh); `lib/core/di/core_providers.dart` — `sessionStatusProvider`, `show SessionStatus` re-export.
- `lib/features/identity_access/**` — domain (phone number, tokens, challenge, verification branches, preview, terms, contracts, `SessionStore` port), application (`SignInWithCode`, `AcceptInvitationByLink`, `AcceptPendingInvitation`, `RegisterAccount`, `SignOut` bounded to 5 s), infrastructure (three Portal repositories, `SessionManagerStore`), `di.dart`, public `identity_access.dart`, presentation (five pages, two sheets, flows, formatter, messages, terms consent, countdown, invitation controller).
- `lib/features/client/**` — `Me` / `Account` / `ClinicLink` and the active-clinic rule, `PortalMeRepository`, `PreferencesActiveClinicStore`, `meProvider`, `activeClinicProvider` (`select`), `di.dart`, `client.dart`.
- `lib/app/**` — router on the real pages (exits as callbacks), `/sign-in/code` no longer sign-in-only, malformed `#t=` → invalid state, `home_placeholder_page.dart`, account placeholder sign-out, `bootstrap/feature_overrides.dart`.
- `lib/shared/presentation/kit/forms.dart` — `KivetoOtpField.errorText`, `KivetoPhoneField.onChanged/inputFormatters`.
- `lib/l10n/app_fr.arb` (+ gen-l10n) — every string of the slice.
- `pubspec.yaml` / `pubspec.lock` — `shared_preferences 2.5.6`, `url_launcher 6.3.3`; `android/app/src/main/AndroidManifest.xml` `<queries>` https; `android/app/src/debug/AndroidManifest.xml` — the dev invitation link filter also takes `http` (the dev backend's SMS links).
- `test/**` — unit (session generation, status provider, domains, use cases, repositories on 24 live captures in `test/support/fixtures/portal_api/`), widget (each page, helpers, client providers, app-level flows on the real HTTP chain, bootstrap seams), `test/support/fakes.dart` (`pumpKivetoApp` on the real chain, `pumpPage`, `pumpBriefly`, `InMemoryActiveClinicStore`).
- Docs — `CONTRIBUTING.md` §0/§5/§6, `architecture.md` §3 (slice conventions), §5 (pins), §6, §11 (V5 result), `deferred-work.md` (five entries resolved, e2e trigger, three new entries).

**Review findings.** 36 findings (high 0, medium 12, low 13, false 6, maybe-false 5). Patched: 15 rows (11 medium, 4 low; 12 entries: invitation controller race + exits, malformed fragment, signed-in exit on 0, international paste, logout timeout, `select` guards, resend during verify, register general message, terms refresh guard, non-BMP initials, bootstrap seams test, architecture conventions). Deferred: privacy-policy link (medium, needs a contract field), e2e target (low), device-level checks (settled by the walk below). Rejected (with reasons in the triage log): replaced session not revoked (contract rule), "Plus tard"/"Se reconnecter" signed in, fixed "Valable 10 minutes", non-ApiFailure logout error, fixture PII/tokens (demo data, revoked tokens), "Envoyé par SMS" after an email resend, clock skew, welcome prefill after a link sign-in; false: missing deep-link filter (debug manifest has it), pending invitations without a grant, active clinic never written by the UI, logout revocation evidence, "Rattacher", account switch on a link.

**Follow-up review recommended:** true — 11 medium entries patched on a first pass; the named unverified risk is the invitation controller and `select` concurrency patches, covered by targeted tests but not by a second review.

**Verification.**
- `make ci` green before the review (2 min 59 s) and after the patches (2 min 57 s): format, analyze, architecture, coverage (all gated files 100%), scripts, api-check; then again after the walk tweaks (see the slice commit).
- `fvm flutter gen-l10n` idempotent.
- Emulator walk (Android `Medium_Phone_API_37.0`, local backend, screenshots in the notes folder `shots-identity-access/`): demo account sign-in (wrong code then right one) → home "Bonjour Julien" / Paris, badge 1, initials JG; app killed and restarted → still signed in; "Se déconnecter" → `POST /auth/logout` → welcome. A number with two pending invitations → `invitation_pending` → accepted one by one → home. An invitation link (`http://portal.kiveto.local/invitation#t=…`, VIEW intent) → lookup, code sent, accepted → home. `PERRIN_TOKEN` → "Invitation expirée", warm signed in and cold signed out. Revoked-link account → `/clinics`. New number → `registration_required` → registered → `/clinics`. Landline → `phone_not_supported` under the field. The terms link opens Chrome (dev URL unreachable).
- Walk tweaks: the onboarding CTA reads "Accepter cette invitation" once signed in, "Plus tard" centred; the accepted line reads "Invitation acceptée : {clinic}." (no gendered agreement).

**Residual risks.** iOS not built; the dev terms URL unreachable on the emulator; the logout's server revocation after a refresh relies on the backend behaviour checked live (comment + harness test on the client side); `integration_test/` deferred.

### Review Findings

bmad-code-review of `master...feature/identity-access` (2026-11-03, layers: blind-hunter, edge-case-hunter, verification-gap, acceptance-auditor; 42 findings).

- [x] [Review][Patch] Invitation page: the loading and load-failed states have no exit (reached by `go` or a deep link; back leaves the app) — add the closed states' exit (sign in / back home) under the error view [lib/features/identity_access/presentation/invitation_page.dart:129]
- [x] [Review][Patch] Invitation controller reads `state` before checking `ref.mounted` after its awaits (code request and refused acceptance): leaving the page mid-request throws out of an unawaited future [lib/features/identity_access/presentation/invitation_controller.dart:133]
- [x] [Review][Patch] Code page: back / "Modifier" during a verification, and a verification started during a resend, race the challenge — ignore back while verifying, refuse verify (and disable "Valider") while resending [lib/features/identity_access/presentation/code_page.dart:75]
- [x] [Review][Patch] `Onboarding.remove` drops `acceptedClinicName`: the success line disappears after a later `invitation_invalid` [lib/features/identity_access/presentation/flows.dart:118]
- [x] [Review][Patch] Tests: the `select` race test cannot fail (the gated store reads after `select` wrote); the terms-reload CTA guard, resend-during-verify, the warm second invitation link and the access-token mapping (verify, register, accept by id) are untested [test/widget/features/client/client_providers_test.dart:64]
- [x] [Review][Patch] Hand-written test bodies copy a real-domain email (`antoine.roussel@gmail.com`) — use `example.com` outside the exact captures [test/widget/features/identity_access/invitation_page_test.dart:46]
- [x] [Review][Patch] architecture.md §3 says "nothing else of `core/security/` reaches" the presentation, but `sessionManagerProvider` (core/di) hands it the `SessionManager` — correct the wording [_bmad-output/planning-artifacts/architecture.md:170]
- [x] [Review][Patch] The main manifest's `<queries>` https entry serves no call (`canLaunchUrl` is never used; `launchUrl` starts the intent) — remove it and its doc mentions [android/app/src/main/AndroidManifest.xml:53]
- [x] [Review][Patch] Four ARB keys only the retired placeholders used (`screenWelcomeTitle`, `screenOnboardingInvitationsTitle`, `screenInvitationTitle`, `screenHomeTitle`) — delete them [lib/l10n/app_fr.arb:40]
- [x] [Review][Patch] deferred-work.md: a blank line splits the last resolved entry, and the new heading follows it without a blank line [_bmad-output/implementation-artifacts/deferred-work.md:141]
- [x] [Review][Defer] The "politique de confidentialité" link opens the terms URL [lib/features/identity_access/presentation/terms_consent.dart:43] — deferred: needs a privacy URL in `CurrentTerms` (backend contract), already in deferred-work.md; the copy stays the mockup's until the user decides.

Rejected:
- `low` Pasting another listed territory's international number with +33 selected keeps the wrong digits — the user picks the prefix first (sheet), the server answers `phone_not_supported`; a country switch from the formatter adds behaviour for a rare paste.
- `low` Rate-limit delays shown only in minutes ("60 min") — readable; hours need a second plural form for a rare daily quota. (Its claim that register's 429 shows no delay is false: the generic `errorRateLimitedBody` carries the minutes.)
- `low` Register violation paths and the resend 202 are not live captures — `me.patch.422.json` shows API Platform's plain `firstName` paths; a mismatch would still show the server message in the general callout.
- `low` (×3) The spec's Design Notes and e2e trigger wording drift from the code (7 → 8 by `go`, walk copy) — fixing them edits the spec under review; the drift is recorded in the Auto Run Result and the hand-over note.
- `low` V5 evidence (screenshots) lives in the notes folder — the effort's brief puts them there; the walk is described in the spec, CONTRIBUTING §0 and architecture §11.
- `low` `client.activeClinic.<accountId>` keys are never removed — account UUIDs only, one per account that signed in on the device; a retention rule is a product choice for slice 5 (account screen).
- `low` A new link opened while the previous acceptance is in flight goes home — the first acceptance succeeded and opened its session; rare.
- `low` (carried) Onboarding "Se reconnecter" while signed in lands on `/home`; a non-`ApiFailure` logout error surfaces after the local sign-out.
- `false` Back on the register page / "Revenir à l'accueil" during an in-flight request lands signed in — the request the user sent succeeded; being signed in is its outcome.
- `low` The active clinic chosen with a failed store write reverts on a `/me` rebuild — needs a store failure, then a rebuild before restart; an in-memory override adds state for a rare path.
- `low` The 5 s logout bound can leave the refresh family unrevoked on a slow network with an expired access token — the tokens are gone from the device; only a stolen copy could use them; a responsive sign-out was chosen (recorded in the hand-over note).

Code review outcome: 0 decision-needed, 10 patch (all applied: `make ci` green in 2 min 59 s after them), 1 defer (already recorded), 13 rejected (above). Story status stays `done`.
