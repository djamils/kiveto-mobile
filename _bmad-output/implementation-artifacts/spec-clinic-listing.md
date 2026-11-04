---
title: 'Slice 7 — clinic listing: screen 10 « Trouver une clinique » and screen 11 « Fiche clinique » (clinic_listing), the new-client booking and the booking requests on screen 4 (scheduling), the link suggestions (client), the tabs of a clinic-less account (app)'
type: 'feature'
created: '2026-11-04'
status: 'done'
baseline_revision: '0069a330a074f99cd4ae4b8b82280eaee1c5bd7c'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-app-shell.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-scheduling.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-portal-requests.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/design-system.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/mockup/10.html'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/mockup/11.html'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/mockup/04.html'
warnings: ['oversized', 'multiple-goals']
deferred:
  - summary: >-
      A listing is matched to a clinic of the account by name only (selectConfirmedClinicNamed), for « Déjà client » and the already_linked action.
    evidence: |-
      Listing ids are not clinic ids in the contract; two clinics with the same name or a renamed one defeat the match. Needs a contract field (the account's link or clinicId of a listing). deferred-work.md, slice 7.
    location: >-
      lib/features/client/presentation/link_suggestion_providers.dart
    severity: medium
  - summary: >-
      The open status of screen 11 uses the device's clock and zone, not the clinic's timezone.
    evidence: |-
      No zone database in the app (same gap as the device-today entries of slices 3 and 4); wrong for a clinic in another zone than the device. deferred-work.md, slice 7.
    location: >-
      lib/features/clinic_listing/presentation/clinic_listing_page.dart
    severity: medium
  - summary: >-
      iOS: BYPASS_PERMISSION_LOCATION_ALWAYS is not set for geolocator_apple.
    evidence: |-
      The app asks for when-in-use only; without the flag the always-permission API is compiled in. iOS is not built in this effort. deferred-work.md, slice 7.
    location: >-
      ios/Runner/Info.plist
    severity: low
---

<intent-contract>

## Intent

**Problem:** The last screens of the Portal are missing. `/clinics` (10, the landing of a clinic-less account and the target of « Ajouter une clinique » on 6) and `/clinic-listings/:listingId` (11) are placeholders, so nobody can search the directory, accept a link suggestion (`GET /me/link-suggestions`, `POST …/accept`) or book as a new client (`/clinic-listings/{l}/booking/…`). Screen 4 ignores the account's new-client booking requests (`GET /me/booking-requests`). A clinic-less account's Animaux, Rendez-vous and Documents tabs bounce to `/clinics` instead of saying why they are empty.

**Approach:** Per D15: the directory (search, detail, opening hours) is the new feature `clinic_listing`; the link suggestions join `client` (it owns `/me` and the links); the new-client booking and the booking requests join `scheduling` (it owns booking and screen 4), on a `SlotPicker` generalised to a « venue » (a clinic or a listing) and on `BookingDraft`. Build 10 and 11 the way mockups 10 and 11 draw them, the booking flow on the layout of 3 and 14, the undrawn states (pending link, request cards, the clinic-less tabs, the refusals) with the kit. The server decides every rule; the app shows its answers.

## Boundaries & Constraints

**Always:**
- D15 layers (CLAUDE.md §3, `test/architecture/`): domain pure Dart; DTOs stay in infrastructure; presentation never imports infrastructure, Dio, the client, `core/network`, `core/security`; repositories **throw** `ApiFailure` (`apiFailureOf`, `core/network/portal_results.dart`). Features meet only through `<feature>.dart`, no cycle: `clinic_listing` → `client`, `scheduling`; `scheduling` → `client`, `patient` (as today); **`scheduling` and `client` never import `clinic_listing`; `client` never imports `scheduling`**. `ListingId` (used by both domains) goes to `shared/domain`.
- Account-scoped providers watch `sessionStatusProvider`, are read through `AsyncData` patterns / `AsyncValueView`, never `.value`. Any change to appointments or requests: `ref.read(appointmentsRevisionProvider.notifier).bump()`. After a link suggestion is accepted: `ref.invalidate(meProvider)` and reload the suggestions.
- The new-client booking holds its intent in a `BookingDraft` (its `IdempotencyKey`: the same content keeps the key on every retry, a change makes a new one; keys from `bookingKeyFactoryProvider`) and sends `requestListingAppointment` with that key.
- Every user-facing string in `lib/l10n/app_fr.arb` (then `fvm flutter gen-l10n`), copy in Design Notes; a literal U+00A0 before « ? ; : ! » and inside a date or a masked phone shown in a sentence; no article or elision before a clinic or pet name (« {clinic} a un dossier… », never « à la {clinic} »); no channel promise (never « par SMS »).
- Kit widgets by C-id (notes-app-shell §7); material from `package:material_ui/material_ui.dart` only; custom sizes via `kivetoTextStyle`.
- 100% line coverage of every new or changed domain / infrastructure / `shared/domain` file, the infrastructure tested on the captured fixtures of the Code Map. Enums keep an `unknown` case; wire → domain enum mapping by name (`asNameMap()`), never the generated `toJson` of `unknown`.
- New dependency `geolocator: 14.1.2` (pinned exactly, with the pubspec comment and an architecture.md §5 row), Android `ACCESS_COARSE_LOCATION`, iOS `NSLocationWhenInUseUsageDescription`; the platform call sits behind a provider seam that tests override.

**Never:**
- No client-side rule the server owns: no `q` length check (send what is typed, show the 422's message), no new-client eligibility, no pending-request limit, no slot filtering beyond the server's answer, no « already client » detection before the server's `422 already_linked`. The only local guard: the new pet's name ≤ 80 characters and a species chosen (the form needs them).
- No « Me prévenir » (the pinned contract has no `notify-me`) and no « 23 propriétaires attendent… » line (no API field). No « Prochain créneau » line when `nextAvailableAt` is null (always, in v1).
- No acceptance of a link suggestion on behalf of the user anywhere but the tap on « Rattacher ce dossier ». No cancellation of a booking request (the API has none).
- No hand edit of `contracts/` or `packages/kiveto_portal_api/`; no edit of `CLAUDE.md`; no `.claude/settings.json`; no other new package.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| 10 first view | signed in, empty search | « Bonjour {firstName} » + subtitle; one C-33b callout per link suggestion; one pending callout per `/me` clinic with `linkStatus: pending`; `GET /clinic-listings` (no `q`): « 3 cliniques » + C-31 cards in the server's order | list failure → ErrorView + retry; suggestions failure → danger callout « Impossible de vérifier… » + « Réessayer », search unaffected |
| 10 search | text typed (debounce 350 ms) | `GET /clinic-listings?q=<trimmed text>` (empty text → no `q`), results replace the list | 422 `validation_failed` → its first violation's message in place of the results (grey 13); 429 / network → ErrorView + retry |
| 10 near me | tap « Autour de moi » | seam returns a position → `lat`/`lng` sent with the current `q`; count « N cliniques à proximité »; cards add « · 2,1 km »; the chip becomes « Autour de moi ✕ » (tap again: back to the name order) | permission denied / location off / no fix → SnackBar with the matching message, mode unchanged; « Localisation… » disabled chip while waiting |
| 10 pages | `nextCursor` non-null | an end-of-list footer reads the next page with the same `q`/`lat`/`lng` | next page failure → « Impossible de charger la suite. » + retry; 400 `cursor_invalid` → reload from page 1 |
| 10 cards | `onKiveto` true | name, meta « {line, postalCode city} · {km} · {tags} » (absent parts skipped), pill « RDV en ligne » when `onlineBooking`; tap → 11 | — |
| 10 unlisted | `onKiveto` false | dashed card, pill « Pas encore sur Kiveto », « Appeler » (C-4b + phone icon, `tel:` through the dialer seam) when `phone`, not tappable otherwise | dialer refused → SnackBar « Impossible de lancer l'appel. » |
| 10 accept | tap « Rattacher ce dossier » | `POST /me/link-suggestions/{id}/accept` (button loading) → 202: invalidate `meProvider` + suggestions; the callout is replaced by the pending callout of that clinic | 404 → SnackBar « Ce dossier n'est plus proposé. » + suggestions reloaded; other → SnackBar with `failureMessage` |
| 11 detail | `GET /clinic-listings/{l}` 200 | back; name 26/700, address 14, status line (device clock, Design Notes); « Vous êtes » (Nouveau client selected); « Motif »; « Horaires » grid (grouped days, « Fermé ») when hours exist | 404 → ErrorView « Clinique introuvable » + back; other → ErrorView + retry |
| 11 motifs | Nouveau client, `onlineBooking` true | `GET …/booking/motifs`: C-11b rows « {label} » / « {n} min · {description} »; urgency hint with the formatted phone (tappable) when `phone`; tap → the motif and the clinic name go into the listing draft, `onChooseMotif` | 422 `booking_not_open` → info callout « …ne propose pas encore… » (+ « Appeler la clinique »); empty list → « Aucun motif… »; other → ErrorView + retry |
| 11 closed to new | `onlineBooking` false | no motif call; info callout (`acceptsNewClients` false → « …n'accepte pas de nouveaux clients… », else « …ne propose pas encore… »), « Appeler la clinique » when `phone` | — |
| 11 known client | « Déjà client » chosen | hint (Design Notes), « Prendre rendez-vous » (only when `/me` has a confirmed clinic: selects the confirmed clinic of the same name if exactly one, then `onBookAsClient`) and « Retrouver mon dossier » (`onFindRecord` → `/clinics`); no motif list | — |
| Slot step | motif chosen | WizardHeader « Étape 1 sur 2 » « Choisissez un créneau », over-title C-13c « {motif} · {n} min » (→ back to 11); `SlotPicker` on the listing (`…/booking/practitioners`, `…/booking/availability`); bar « Créneau » / « À choisir » or the slot, « Continuer » once a slot is chosen | the picker's own error views; no motif in the draft → « Choisissez d'abord un motif. » + back |
| Pet + recap | slot chosen | « Étape 2 sur 2 » « Votre animal »: new pet name (≤ 80) + species chips, recap (Clinique, Motif, Date, Vétérinaire), footnote; « Envoyer la demande » disabled until name and species | — |
| Send | POST 201 | revision bumped (screen 4 reloads its requests); C-34a « Demande envoyée » + date line + note; « Voir mes rendez-vous » → `/appointments`, « Retour à l'annuaire » → `/clinics` | — |
| Send refused | 409 `slot_taken` | slot marked taken, availability reloaded, back to the slot step with the « Ce créneau vient d'être pris… » warning | — |
| Send refused | 422 `already_linked` / `booking_request_limit` / `booking_not_open`, 404, 429, `validation_failed` | danger callout in the bar above the button, the code's message; `already_linked` adds « Prendre rendez-vous » (same as 11's known client), the limit adds « Voir mes rendez-vous »; a `newPet.name` violation shows under the name field | network / 5xx → failure message + « Réessayer » (same key) |
| 4 requests | `GET /me/booking-requests?limit=50` | `confirmed` hidden (the appointment shows in its clinic's list); the others in « À venir » when `startAt` ≥ now (soonest first), else in « Passés » (latest first), under a « Demandes de rendez-vous » header, before the clinic's appointments | failure → danger callout + « Réessayer » in the requests' place; the appointments unaffected |
| 4 request card | pending / declined | C-28 card: neutral tile; « 14:00 · {pet} » + pill (« En attente » neutral; « Refusée » / « Expirée » / « Annulée » danger); motif; « {clinic} »; status line by status and `declineReason` | unknown status / reason → neutral pill « En attente » / « Refusée » |
| 4 no clinic | no active clinic | no FAB; the tab's requests (if any), then EmptyState « Aucune clinique rattachée » / « Trouvez une clinique pour prendre un premier rendez-vous. » / « Trouver une clinique » (`onFindClinic` → `/clinics`) | — |
| Tabs no clinic | `hasConfirmedClinicProvider` false | `/pets` and `/documents` show their page header + EmptyState with « Trouver une clinique »; `/home`, `/booking…` and every path under `/pets/`, `/appointments/`, `/documents/` still redirect to `/clinics`; the tab roots no longer do | `null` (unknown) → the feature page as today |

</intent-contract>

## Code Map

**Generated client (read only)** — `packages/kiveto_portal_api/lib/src/api_client/clinic_listing_api.dart`: `ClinicListingApi(server)`: `listClinicListings({String? q, num? lat, num? lng, String? cursor, int? limit})` → `ListClinicListingsResponse200(body: ClinicListings{items: List<ClinicListingSummaryView>, nextCursor})` (400/422/429/404 typed without body except 404); `getClinicListing(listingId:)` → `GetClinicListingResponse200(body: ClinicListingDetail)`; `listListingMotifs(listingId:)` → `ListListingMotifsResponse200(body: List<ListingMotifView>)`; `listListingPractitioners(listingId:, motifId:)` → `…200(body: List<ListingPractitionerView>)`; `getListingAvailability(listingId:, motifId:, practitionerId:, from: Date, to: Date)` → `…200(body: ListingAvailability{days: List<AvailabilityDayView>})` (the same `AvailabilityDayView` as scheduling's); `requestListingAppointment(body: ListingBooking(newPet: NewPet(name:, species: NewPetSpeciesModel.x), motifId:, practitionerId:, startAt: DateTime /* an OffsetDateTime */), listingId:, idempotencyKey:)` → `RequestListingAppointmentResponse201(body: ListingBookingRequestView)`. `account_api.dart`: `listBookingRequests({cursor, limit})` → `ListBookingRequestsResponse200(body: BookingRequests{items: List<BookingRequestView>, nextCursor})`; `listLinkSuggestions()` → `ListLinkSuggestionsResponse200(body: List<LinkSuggestionView{id, clinic: ClinicSummaryView{name, city?}, matchedOn}>)`; `acceptLinkSuggestion(suggestionId:)` → `AcceptLinkSuggestionResponse202(body: LinkSuggestionAcceptedView{linkStatus})`. Models (`lib/src/model/`): `ClinicListingSummaryView{id, name, address: …AddressAnyOfModel? (.listingAddressView → ListingAddressView{line, postalCode?, city}), phone?, distanceM?, onKiveto, onlineBooking, tags, nextAvailableAt?}`, `ClinicListingDetail{id, name, address?, phone?, timezone, openingHours: List<OpeningHoursView{day 1..7, opensAt "HH:MM", closesAt}>, acceptsNewClients, onlineBooking, tags}`, `BookingRequestView` / `ListingBookingRequestView` (two classes, own enum classes: `status` pending/confirmed/declined/unknown, `declineReason?` declined/expired/cancelled/accountDeleted?/unknown — check the generated case names, `pet: BookingRequestPetView{name?, species?: BookingRequestPetViewSpeciesModel?}`, `clinic: ClinicSummaryView`, `motif`, `startAt` OffsetDateTime, `appointmentId?`), `ListingMotifView{id, label, description?, durationMin, suggested, suggestionReason?}`, `ListingPractitionerView{id, displayName?}`.

**Captured fixtures (`test/support/fixtures/portal_api/`, exact bytes, traces stripped, decoded by `test/integration/portal_api_contract_test.dart` group « the clinic listing captures (slice 7) »)** — `clinic-listings.get.200.json` (Vercors: no address/phone, not online; Lyon: online; Paris: 8 tags, not online), `.search.get.200.json` (q=Lyon), `.search-empty.get.200.json`, `.near.get.200.json` (Paris, `distanceM` 2074), `.page1.get.200.json` (2 items + cursor) / `.page2.get.200.json`, `.validation.get.422.json` (`q`), `.coordinates.get.422.json` (`lat`), `.cursor-invalid.get.400.json`; `clinic-listings.{lyon,paris,vercors}.get.200.json` (Paris: two ranges Mon–Thu; Vercors: no hours, `acceptsNewClients` false), `.unknown.get.404.json`; `clinic-listings.lyon.booking.{motifs,practitioners,availability}.get.200.json` (motif `01a19a10-d3d1-7031-bd42-3d901474af59` 30 min; Dr Sarah Lemoine `01a19a0e-29db-7550-a605-8ac512a656c1`; 14 days from 2026-11-04, slots from 13:00 +01:00), `.practitioners.validation.get.422.json`, `clinic-listings.paris.booking.motifs.get.422.json` (`booking_not_open`); `clinic-listings.lyon.booking.appointments.post.201.json` (pending), `.replay.post.201.json` (stored body, spaced), `.slot-taken.post.409.json`, `.already-linked.post.422.json`, `.limit.post.422.json` (`booking_request_limit`), `.key-reused.post.422.json`, `.validation.post.422.json` (`newPet.name`), `.key-missing.post.400.json`; `me.booking-requests.{pending,declined,confirmed}.get.200.json` (declined: 3 items, `expired`/`declined`; confirmed: `appointmentId`), existing `me.booking-requests.get.200.json` (empty); `me.link-suggestions.get.200.json` (existing, Julien: Paris), `me.link-suggestions.empty.get.200.json`, `me.link-suggestions.accept.post.202.json`, `.accept.unknown.post.404.json`; `me.pending-link.get.200.json` (one Lyon clinic `pending`, `linkedAt` null); existing `me.no-clinic.get.200.json`, `me.get.200.json`.

**Reuse points**
- `lib/features/scheduling/presentation/slot_picker.dart` -- `SlotPicker(clinicId:, motifId:, today:, …)` watches `practitionersProvider((clinicId, motifId))` and `availabilityProvider((clinicId, motifId, practitionerId, from))` (`scheduling_providers.dart`); its callers `booking_slot_page.dart`, `reschedule_page.dart`. Generalise the key's first element to a `BookingVenue`.
- `lib/features/scheduling/infrastructure/portal_scheduling_repository.dart` -- motif / practitioner / availability-day mappers (lines ~34–92) and the slot wire form `OffsetDateTime.from(slot.instant, offset: slot.offset)` (line ~231): extract what both repositories share into one infrastructure file rather than copying.
- `lib/features/scheduling/domain/booking_draft.dart`, `booking.dart` -- `BookingDraft.start(null, newKey:)` is a listing draft (no clinic id), `NewPet(name, Species)`, `BookingRequest`; `presentation/booking_wizard.dart` -- the notifier pattern (submission states, `confirm()` outcomes, `ref.mounted` guards, `slot_taken` → `markTaken` + `ref.invalidate(availabilityProvider)`), `bookingKeyFactoryProvider`.
- `lib/features/scheduling/presentation/booking_pet_page.dart` `_NewPetForm` (name ≤ 80 + species chips): extract to a shared scheduling widget used by 12 and the listing pet step. `booking_confirm_page.dart` -- recap rows and `_Booked` success view; `booking_layout.dart` -- `FlowScaffold`; `scheduling_messages.dart` -- `practitionerLabel`, `failureCause`, `isTransientFailure`, slot/date helpers.
- `lib/features/scheduling/presentation/appointments_page.dart` / `appointment_card.dart` -- `_content` slivers, `_MoreFooter`, `_DateTile`, `appointmentStatusPill`; `phoneDialerProvider` (export it from `scheduling.dart` for clinic_listing).
- `lib/features/client/presentation/client_providers.dart` -- `meProvider`, `activeClinicProvider` (+ `.notifier.select(ClinicId)`); `lib/features/client/domain/me.dart` -- `LinkStatus.pending`, `Me.confirmedClinics`, `Account.firstName`.
- `lib/features/patient/patient.dart` -- `speciesLabel`, `deviceToday`; `lib/shared/domain/species.dart`, `clinic_id.dart` (pattern for `listing_id.dart`).
- `lib/shared/presentation/kit/` -- `KivetoCallout.brand/info/danger`, `KivetoSearchField`, `KivetoSummaryChip(.action)`, `KivetoCard(.list)`, `KivetoListRow.navigation` (C-11b), `KivetoKeyValueRow`, `KivetoDetailHeader(extra:, extraIsPositive:)` (C-37c), `KivetoPageHeader`, `StatusPill`, `KivetoButton.*`, `KivetoDashedBorder`, `WizardHeader(total:)`, `StickySummaryBar`, `StickyCtaBar`, `SuccessView`, `EmptyState`, `ErrorView`, `LoadingView`; `formatters/kiveto_format.dart` -- `time`, `dateTimeShort`, `dayShort`, `phone`.
- `lib/app/routing/app_router.dart`, `app_routes.dart` (`redirectFor`, `_clinicScoped`), `shell_seams.dart` (`hasConfirmedClinicProvider`), `placeholder_page.dart`; tests `test/widget/app/routing/app_router_test.dart` (redirect cases), `test/support/fakes.dart` (`pumpKivetoApp`, `pumpPage`, `FixedClock`, `testNow` = 2026-11-03 10:22:40 UTC), `test/support/portal_api/fake_portal_backend.dart`, `portal_http_harness.dart`.

## Tasks & Acceptance

**Execution:**
- `lib/shared/domain/listing_id.dart` -- `extension type const ListingId(String value) {}` -- shared by clinic_listing and scheduling domains.
- `lib/features/clinic_listing/domain/clinic_listing.dart` -- `ListingAddress`, `ClinicListingSummary`, `ClinicListingPage`, `ClockTime` (hour, minute; `parse('HH:MM')` returns null on a malformed value), `OpeningHours`, `ClinicListingDetail`, `GeoPoint`, `ListingQuery({text, near})` with value equality (a provider family key).
- `lib/features/clinic_listing/domain/opening_schedule.dart` -- pure `weeklyRows(hours)` (days 1..7, consecutive days with the same sorted ranges merged, closed days kept with no range, `[]` without hours) and `openingStatusAt(hours, weekday:, time:)` → sealed `OpenUntil(closesAt)` / `OpensLater(opensAt)` / `OpensOn(weekday, opensAt, tomorrow)` / `NoOpeningHours`; ranges are `[opensAt, closesAt)`.
- `lib/features/clinic_listing/domain/clinic_listing_repository.dart` -- `search(ListingQuery, {String? cursor})`, `listing(ListingId)`.
- `lib/features/clinic_listing/infrastructure/portal_clinic_listing_repository.dart` -- on `ClinicListingApi`; `nextAvailableAt` via `clinicInstantOf`; a malformed `HH:MM` throws `ServerFailure`.
- `lib/features/clinic_listing/{di.dart, clinic_listing.dart}` -- `clinicListingRepositoryProvider`; public API: `ClinicSearchPage`, `ClinicListingPage`.
- `lib/features/clinic_listing/presentation/` -- `clinic_listing_providers.dart` (the search notifier family by `ListingQuery` with `loadMore` and the `cursor_invalid` reload; `clinicListingProvider(ListingId)` autoDispose; `deviceLocationProvider` seam on geolocator: coarse/low accuracy, 15 s limit, typed failures denied / disabled / failed), `clinic_search_page.dart` (10), `clinic_listing_page.dart` (11), `clinic_card.dart` (C-31), `link_suggestion_callouts.dart` (C-33b + pending callout), `who_cards.dart` (C-24d), `opening_hours_grid.dart` (C-11g), `clinic_listing_messages.dart`.
- `lib/features/client/domain/link_suggestion.dart`, `link_suggestion_repository.dart`, `infrastructure/portal_link_suggestion_repository.dart` (on `AccountApi`), `di.dart` (`linkSuggestionRepositoryProvider`), `presentation/link_suggestion_providers.dart` (`linkSuggestionsProvider`, session-scoped; `acceptLinkSuggestion(ref, suggestion)` = POST then invalidate `meProvider` and the suggestions, a 404 also reloads them and rethrows; `selectConfirmedClinicNamed(ref, name)` = select the single confirmed clinic whose trimmed, case-insensitive name matches), `client.dart` exports.
- `lib/features/scheduling/domain/booking_venue.dart` -- sealed `BookingVenue`: `ClinicVenue(ClinicId)`, `ListingVenue(ListingId)`, value equality.
- `lib/features/scheduling/domain/appointment_request.dart` -- `AppointmentRequest` (id, clinic name/city, pet name?/`Species?`, motif, `ClinicInstant startAt`, status enum + unknown, `declineReason` enum? + unknown, `AppointmentId?`), `AppointmentRequestPage`, and the pure `requestsFor(scope, requests, now)` (confirmed dropped; upcoming = `startAt` not before `now`, soonest first; past latest first).
- `lib/features/scheduling/domain/new_client_booking_repository.dart` -- `motifs(ListingId)`, `practitioners(ListingId, MotifId)`, `availability(ListingId, MotifId, PractitionerId, from, to)`, `request(ListingId, BookingRequest, IdempotencyKey)` (pet must be a `NewPet`: `ArgumentError` otherwise), `requests({cursor, limit})`.
- `lib/features/scheduling/infrastructure/portal_new_client_booking_repository.dart` (+ the shared mapping file extracted from `portal_scheduling_repository.dart`) and `di.dart` (`newClientBookingRepositoryProvider`).
- `lib/features/scheduling/presentation/scheduling_providers.dart` -- `practitionersProvider` / `availabilityProvider` keyed by `BookingVenue` (dispatch per venue, the `from` retry kept for both), `listingMotifsProvider(ListingId)`, `appointmentRequestsProvider` (session-scoped, watches the revision, first page `limit: 50`); `slot_picker.dart`, `booking_slot_page.dart`, `reschedule_page.dart` -- `venue:`.
- `lib/features/scheduling/presentation/listing_booking.dart` -- `listingBookingProvider` (autoDispose family by `ListingId`): state = draft (`BookingDraft.start(null)`), clinic name, submission (idle / sending / failed(error) / sent(`AppointmentRequest`)), `slotTaken`; `start(motif, clinicName:)` (a sent state starts a new draft), `choosePractitioner`, `chooseSlot`, `setPet(name, species)`, `confirm()` → sent / slotTaken / failed / ignored (revision bumped on success).
- `lib/features/scheduling/presentation/listing_motif_section.dart` (11's « Motif » block: watches the listing draft so it lives while 11 is stacked), `listing_slot_page.dart`, `listing_confirm_page.dart`, `new_pet_form.dart` (extracted from 12), `appointment_request_card.dart`, `appointments_page.dart` (requests + no-clinic mode, `onFindClinic`), `scheduling_messages.dart`; `scheduling.dart` exports the new pages, `ListingMotifSection`, `phoneDialerProvider`.
- `lib/shared/presentation/formatters/kiveto_format.dart` -- `distance(int meters)` (« 0,4 km », « 2,1 km », « 12 km »), `weekdayName(int isoDay)` (« Lundi »), `weekdayAbbrev(int isoDay)` (« Lun »), `clockTime(hour, minute)` (« 08:30 »).
- `lib/app/routing/app_routes.dart` -- `redirectFor`: without a confirmed clinic, `/home`, `/booking…` and paths strictly under `/pets/`, `/appointments/`, `/documents/` go to `/clinics`; add `listingSlot(id)` / `listingConfirm(id)` paths.
- `lib/app/routing/no_clinic_page.dart` -- `ClinicTabGate(title:, body:, child:)`: `hasConfirmedClinicProvider == false` → canvas page, `KivetoPageHeader(title)` + `EmptyState` + « Trouver une clinique » (`go(/clinics)`); else `child`.
- `lib/app/routing/app_router.dart` -- `/clinics` → `ClinicSearchPage`; `/clinic-listings/:listingId` → `ClinicListingPage` with named sub-routes `booking/slot`, `booking/confirm` (root navigator; X pops every listing booking page back to 11); `/pets`, `/pets/:petId`, `/documents` wrapped in `ClinicTabGate`; `AppointmentsPage(onFindClinic:)`; `onBookAsClient` pushes `/booking/pet`; success exits `go` `/appointments` / `/clinics`.
- `lib/l10n/app_fr.arb` + `fvm flutter gen-l10n`; `pubspec.yaml` (+lock), `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `_bmad-output/planning-artifacts/architecture.md` §5 row -- geolocator.
- Tests: `test/unit/…` for every domain / infrastructure file above (fixtures), `test/widget/features/clinic_listing/…` (10, 11), `test/widget/features/scheduling/…` (listing slot, pet + send with each refusal, screen 4 requests and no-clinic mode), `test/widget/app/routing/app_router_test.dart` (redirect cases updated, the gates, the listing routes).

**Acceptance Criteria:**
- Given a clinic-less account signed in, when the app opens, then `/clinics` shows « Bonjour {prénom} », its suggestions and pending links, and the directory; Animaux and Documents show « Aucune clinique rattachée » with « Trouver une clinique »; Rendez-vous shows its requests and the same empty state.
- Given screen 11 of a clinic open to new clients, when the owner picks a motif, a slot, names a new pet and sends, then one `POST …/booking/appointments` carries the draft's `Idempotency-Key`, the success view shows, and screen 4 lists the request « En attente » without a manual refresh.
- Given a retry after a network failure on « Envoyer la demande », when nothing changed, then the same `Idempotency-Key` is sent; when the pet's name changed, a new key is sent.
- Given an account with a confirmed link to that clinic, when it sends a new-client request, then the `already_linked` callout offers « Prendre rendez-vous », which opens the booking wizard on the confirmed clinic of the same name.
- Given `make ci`, when it runs on the branch, then format, analyze, architecture, tests, coverage gate (100% on the gated files) and `api-check` pass.

## Spec Change Log

## Review Triage Log

### 2026-11-04 — Review pass
- verdicts: 54 findings — high 0, medium 18, low 27, false 9, maybe-false 0
- findings:
  - `[low]` `[reject]` (blind) « Déjà client » → « Prendre rendez-vous » shows for any confirmed clinic and opens the wizard on the active one without a name match — designed (Design Notes): the wizard's first step shows the clinic chip, which opens the switcher; a known client of another clinic on this sheet is rare and the fix adds branches.
  - `[medium]` `[defer]` (blind) name matching is no identity between a listing and a clinic — needs a contract field (backend); deferred-work.md.
  - `[medium]` `[patch]` (blind) a clinic-less account cannot re-read /me after the clinic confirms (no refresh on 10, Rendez-vous's refresh skips /me) — Rendez-vous's pull-to-refresh invalidates meProvider; screen 10 gets a RefreshIndicator (me, suggestions, search).
  - `[medium]` `[patch]` (blind) already_linked acts on a stale /me — the action invalidates and awaits meProvider before matching.
  - `[medium]` `[defer]` (blind) open status on the device zone; computed once per build — zone part deferred (deferred-work.md); the per-build staleness is a rejected low (a sheet left open across a boundary; a timer adds state).
  - `[low]` `[patch]` (blind) touching slots (allowed by the backend) say « ferme à 12:00 » — openingStatusAt merges touching ranges; overnight ranges are refused by the backend (OpeningSlot: closesAt > opensAt), 24:00 is parsed.
  - `[low]` `[patch]` (blind) the count shows the loaded items as the total — « Plus de {count} cliniques » while a next page exists.
  - `[low]` `[patch]` (blind) the empty state ignores « Autour de moi » — a near-mode body.
  - `[medium]` `[patch]` (blind) deniedForever is a dead end — its own LocationProblem and message (settings).
  - `[low]` `[patch]` (blind) coordinates sent at full precision — rounded to 2 decimals in the locator.
  - `[low]` `[defer]` (blind) iOS BYPASS_PERMISSION_LOCATION_ALWAYS — iOS not built; deferred-work.md.
  - `[low]` `[reject]` (blind) the plugin's GeolocatorLocationService is merged into the manifest — never started, no foreground-service permission declared; removing it with tools:node risks the plugin's service binding.
  - `[low]` `[patch]` (blind) the booking_request_limit message names one pending request and one clinic — reworded to the generic plural.
  - `[low]` `[reject]` (blind) the requests read one page of 50 — the server caps pending requests at 3 (1 per clinic); a history beyond 50 is unlikely; the spec's documented cap.
  - `[low]` `[reject]` (blind) a double tap on « Prendre rendez-vous » pushes twice — the app-wide pattern of every push; rare, a guard adds state.
  - `[low]` `[patch]` (blind) _petsGate on /pets/:petId is dead (redirected) — removed there.
  - `[low]` `[reject]` (blind) the shared MoreFooter uses the appointmentsMoreError key — naming only, the text is generic.
  - `[false]` `[reject]` (edge) cursor_invalid reload loop — needs the server to refuse a cursor it just issued; same pattern as the appointments and documents lists.
  - `[low]` `[patch]` (edge) a location failure drops the text typed during the debounce — the failure sets the query from the field.
  - `[false]` `[reject]` (edge) a locator throwing a non-LocationFailure leaves « Localisation… » — the shipped locator maps every error to LocationFailure.
  - `[low]` `[reject]` (edge) a second acceptance while the first is in flight re-enables the first — the accept is idempotent (the capture's second accept answers 202); two simultaneous suggestions are rare.
  - `[low]` `[reject]` (edge) no-match « Prendre rendez-vous » opens on another clinic — grouped with the first row.
  - `[medium]` `[patch]` (edge) already_linked with a stale /me (pending link) redirects to /clinics — grouped with the stale-/me patch.
  - `[medium]` `[defer]` (edge) device zone for the open status — grouped with the zone deferral.
  - `[low]` `[reject]` (edge) the status goes stale on an open sheet — grouped with the per-build rejection.
  - `[false]` `[reject]` (edge) overnight ranges — the backend refuses closesAt ≤ opensAt.
  - `[low]` `[patch]` (edge) touching ranges / 24:00 — touching merged (patch above); 24:00 parses as the day's end.
  - `[false]` `[reject]` (edge) a wire day outside 1..7 dropped — the contract bounds day 1–7 and the backend refuses unknown days.
  - `[low]` `[reject]` (edge) more than 50 requests — grouped with the one-page rejection.
  - `[low]` `[patch]` (edge) the count while more pages exist — grouped with the count patch.
  - `[medium]` `[patch]` (edge) deniedForever — grouped with the deniedForever patch.
  - `[low]` `[patch]` (edge) the server's name error stays under a corrected name — step 2 calls setPet on every complete change (a failed submission goes back to idle).
  - `[medium]` `[patch]` (edge) the typed pet is lost going back to step 1 — same fix: the draft holds the typed pet; the refill is tested.
  - `[low]` `[reject]` (edge) a double tap on a motif row pushes twice — grouped with the double-tap rejection.
  - `[low]` `[patch]` (edge) PlaceholderPage's tab/pushed/fullScreen kinds are dead — removed, the not-found page kept.
  - `[low]` `[patch]` (edge) screenClinicListingTitle is orphaned — removed from the ARB.
  - `[low]` `[reject]` (edge) already_linked on 0 or 2+ name matches books on the active clinic — grouped with the first row (the wizard's chip shows which clinic is active).
  - `[medium]` `[patch]` (verification) pull-to-refresh re-reading the requests is unasserted — test added.
  - `[medium]` `[patch]` (verification) after a 409, step 1's availability re-read and struck slot are unasserted — test added.
  - `[medium]` `[patch]` (verification) step 2's refill is untested — test added.
  - `[medium]` `[patch]` (verification) the router's back-to-step wiring never runs — the flow test walks back from step 2 and a 409 then a 201.
  - `[medium]` `[patch]` (verification) the sending/sent guards of step 2 are untested — tests ported from booking_confirm_page_test.
  - `[medium]` `[patch]` (verification) selectConfirmedClinicNamed is tested on an exact match only — no-match and case-variant tests added.
  - `[medium]` `[patch]` (verification) the real locator never runs — unit tests on a fake GeolocatorPlatform.
  - `[low]` `[patch]` (intent) location only on overridden seams — grouped with the locator tests; walked on the emulator.
  - `[false]` `[reject]` (intent) the unlisted card exists only in edited fixtures — the contract keeps `onKiveto`; v1 lists Kiveto clinics only, nothing to fix.
  - `[low]` `[patch]` (intent) a non-null nextAvailableAt is never rendered on a card in tests — card test added.
  - `[false]` `[reject]` (intent) the pending state comes from /me, not the accept answer — by design: /me is the durable source (it survives a restart).
  - `[medium]` `[defer]` (intent) « Déjà client » decided locally by name — grouped with the name-identity deferral.
  - `[low]` `[reject]` (intent) the requests are one page — grouped with the one-page rejection.
  - `[false]` `[reject]` (intent) the empty states use two signals untested together — the flow test covers the fully clinic-less account with both.
  - `[medium]` `[defer]` (intent) the open-now line on the device clock — grouped with the zone deferral.
  - `[false]` `[reject]` (intent) FLAG items decided without the user — the orchestrator's slice intents make FLAG decisions its own calls so slices do not stall.
  - `[false]` `[reject]` (intent) « vous en êtes informé » promises a notification — true: the backend sends PORTAL_BOOKING_DECLINED on a refusal (guide); no channel is named.

## Design Notes

**Layout (mockups 10, 11, 04).** 10: tab page on canvas, body padding 20 20 16, gap 16; header = `KivetoPageHeader(greeting, subtitle:)`; callouts; a column gap 10 (search field, chip); results column gap 10 (count 13/600 `inkMuted`, cards). C-31: white, border 1 `border`, radius 12, padding 14, column gap 10; top row = (name 15/700 over meta 13 `inkMuted`, gap 2, wrapping) + top-aligned nowrap pill; unlisted: dashed `borderStrong` border, then « Appeler » full width (C-4b medium, phone icon) since « Me prévenir » is out. Pending callout (undrawn): white box, border 1 `border`, radius 12, padding 14, column gap 6: title row 14/700 ink + neutral pill « En attente », body 13/1.4 `inkMuted`. 11: canvas, body padding 16 20 16, gap 18, no nav, `KivetoDetailHeader(onBack:, title:, subtitle: address, extra: status, extraIsPositive: open)`; sections C-41 16/700 + content gap 10; who cards C-24d (2 columns gap 8, min-height 64, padding 0 14, radius 12; off border 1 `borderStrong` white ink; on border 2 brand, fill `brandSubtle` text `#312e81`; label 14/700, sub 12 at .8 opacity; radio semantics); hints C-33f 12/1.4 `inkMuted`; hours C-11g card padding 12 14, two columns, row gap 8, 13 px, day `inkMuted`, hours 600 right-aligned, one line per range. Listing booking pages: white `FlowScaffold` like 3 and 14 (`WizardHeader(total: 2)`). Request card: C-28 without actions, neutral date tile.

**Open status (11).** Computed from the device clock (`clockProvider.now().toLocal()`: weekday and time), not the clinic zone: the app has no tz database, as the device-today gap already in deferred-work. Open → green « Ouvert · ferme à 19:00 »; else neutral 13 « Fermé · ouvre à 14:00 » / « Fermé · ouvre demain à 09:00 » / « Fermé · ouvre lundi à 09:00 »; no hours → no line.

**Hours grid.** One row per group of consecutive days with the same ranges: one day → `weekdayName` (« Samedi »), several → « Lun – Ven » (`weekdayAbbrev`, en dash); ranges « 08:30 – 19:00 », one per line; closed → « Fermé ». Lyon: Lun – Ven 08:30 – 19:00 / Samedi 09:00 – 12:00 / Dimanche Fermé.

**« Déjà client ».** The mockup's promise (« On vous enverra un code au numéro connu… ») has no endpoint: the contract's path for a known client is the link suggestion (10) or the clinic's own booking once linked (`already_linked`). Listing ids are not clinic ids: the matching confirmed clinic is found by name, best effort; without a single match the wizard opens on the active clinic and its chip lets the owner switch.

**Copy (ARB, French; `·` = U+00B7, `\u00a0` = no-break space).** 10: « Bonjour {firstName} » / « Bonjour »; « Trouvez votre clinique pour prendre rendez-vous. »; suggestion « {clinic} a un dossier à votre numéro » / « Rattachez-le pour retrouver vos animaux et votre historique. » / « Rattacher ce dossier »; « Ce dossier n'est plus proposé. »; « Impossible de vérifier les dossiers à votre numéro. »; pending « Rattachement demandé : {clinic} » (no-break before « : ») / « La clinique doit confirmer le rattachement. Vos animaux et votre historique apparaîtront dès sa confirmation. »; search label « Rechercher une clinique », hint « Nom ou ville »; « Autour de moi », « Localisation… »; count `{count, plural, =0{Aucune clinique} =1{1 clinique} other{{count} cliniques}}`, near `{count, plural, =0{Aucune clinique à proximité} =1{1 clinique à proximité} other{{count} cliniques à proximité}}`; « RDV en ligne », « Pas encore sur Kiveto », « Appeler », « Prochain créneau : {slot} »; empty « Aucune clinique trouvée » / « Essayez un autre nom ou une autre ville. »; location « Autorisez l'accès à votre position pour voir les cliniques autour de vous. », « Activez la localisation de votre téléphone pour voir les cliniques autour de vous. », « Votre position n'a pas pu être déterminée. Réessayez. »; « Impossible de lancer l'appel. ». 11: statuses above; « Vous êtes », « Déjà client » / « de cette clinique », « Nouveau client » / « première visite »; new hint « Vous décrirez votre animal à l'étape suivante. La clinique confirme les rendez-vous des nouveaux clients. »; known hint « Si la clinique a votre numéro de mobile, votre dossier vous est proposé dans « Trouver une clinique » : rattachez-le. Déjà rattaché ? Prenez rendez-vous depuis votre espace. », « Prendre rendez-vous », « Retrouver mon dossier »; « Motif », « {minutes} min » / « {minutes} min · {description} », « Urgence ? Appelez directement la clinique au {phone}. »; « Cette clinique ne propose pas encore la prise de rendez-vous en ligne aux nouveaux clients. », « Cette clinique n'accepte pas de nouveaux clients pour le moment. », « Appeler la clinique », « Aucun motif n'est ouvert en ligne aux nouveaux clients. »; « Horaires », « Fermé »; « Clinique introuvable » / « Cette clinique n'est plus dans l'annuaire. ». Booking: « Étape {step} sur 2 », « Choisissez un créneau », « Votre animal », chip « {motif} · {minutes} min », « Choisissez d'abord un motif. », footnote « La clinique confirme les rendez-vous des nouveaux clients. Vous suivez votre demande dans Rendez-vous. », « Envoyer la demande », success « Demande envoyée » / « La clinique doit confirmer votre rendez-vous du {date} à {time}. » (date `dayShort(capitalized: false)` with no-break spaces) / « Vous suivez votre demande dans Rendez-vous. Si la clinique ne peut pas la confirmer, vous en êtes informé. » / « Voir mes rendez-vous » / « Retour à l'annuaire »; refusals « Vous êtes déjà client de cette clinique : prenez rendez-vous depuis votre espace. », « Vous avez déjà une demande en attente : attendez la réponse de la clinique. », « Cette clinique ne prend plus de demandes en ligne de nouveaux clients. », « Cette clinique ou ce créneau n'est plus disponible. », « Trop de demandes en peu de temps : réessayez plus tard. ». Reuse the existing ARB keys where the text is the same (`bookingSlotTaken`, `bookingRecapClinic`, `bookingMotifLabel`, `bookingRecapDate`, `bookingVetLabel`, `bookingNewPetName`, `commonRetry`, `appointmentsMoreError`…). 4: « Demandes de rendez-vous »; pills « En attente », « Refusée », « Expirée », « Annulée »; lines « La clinique doit confirmer votre demande. », « La clinique n'a pas pu confirmer ce rendez-vous. », « Sans réponse de la clinique à temps, la demande a expiré. », « La demande a été annulée. »; « Impossible de charger vos demandes de rendez-vous. ». No clinic: « Aucune clinique rattachée », 4 « Trouvez une clinique pour prendre un premier rendez-vous. », Animaux « Vos animaux apparaîtront ici dès qu'une clinique vous aura rattaché. », Documents « Les documents partagés par votre clinique apparaîtront ici. », « Trouver une clinique ».

## Verification

**Commands:**
- `fvm flutter gen-l10n` -- expected: no diff after a second run.
- `make ci` -- expected: `make ci passed` (format, analyze, architecture, unit/widget/integration/tool tests, coverage gate at 100% on the gated files, plain-bash checks, api-check).

## Auto Run Result

Status: done

**Summary.** Slice 7 is built: `clinic_listing` (screen 10: greeting, link-suggestion callouts and pending links, the debounced search, « Autour de moi » on geolocator 14.1.2 behind a seam, cursor pages, C-31 cards and the unlisted variant; screen 11: header with the device-clock open status, « Vous êtes », the motifs or the closed-to-new-clients callout, « Déjà client », the grouped hours grid); `client` (link suggestions, their acceptance, the name match of a listing to a confirmed clinic); `scheduling` (`BookingVenue` behind `SlotPicker`, the new-client booking in two steps on a `BookingDraft` with its key, every refusal, the success view; the account's booking requests on screen 4 split by tab and its clinic-less mode); `app` (the clinic-less tab gates, the redirect kept for the pages under the tabs, the directory routes).

**Files changed** (lib): `shared/domain/listing_id.dart` (new id); `shared/presentation/{async/more_footer.dart (extracted footer), formatters/kiveto_format.dart (distance, weekday names, clock time), kit/{feedback,pills,surfaces}.dart (optional info title, loading callout action, trailing chip glyph, large detail title)}`; `features/clinic_listing/**` (new feature: domain, repository, providers, pages 10 and 11, card, callouts, who cards, hours grid, messages); `features/client/{domain/link_suggestion*.dart, infrastructure/portal_link_suggestion_repository.dart, presentation/link_suggestion_providers.dart, di.dart, client.dart}`; `features/scheduling/{domain/{booking_venue,appointment_request,new_client_booking_repository}.dart, infrastructure/{booking_wire,portal_new_client_booking_repository,portal_scheduling_repository}.dart, presentation/{listing_booking,listing_motif_section,listing_slot_page,listing_confirm_page,new_pet_form,appointment_request_card,appointments_page,appointment_card,booking_pet_page,booking_slot_page,reschedule_page,slot_picker,scheduling_providers,scheduling_messages}.dart, di.dart, scheduling.dart}`; `app/routing/{app_router,app_routes,no_clinic_page,placeholder_page}.dart`; `l10n/app_fr.arb` (+ generated). Also `pubspec.yaml`/lock (geolocator), `AndroidManifest.xml` (coarse location), `ios/Runner/Info.plist` (when-in-use string), architecture.md §5 row. Tests: unit tests on the captures for every new domain and infrastructure file, the locator on a fake `GeolocatorPlatform`, widget tests of 10, 11, the two booking steps, screen 4's requests, the router, one app flow test.

**Review.** 54 findings (high 0, medium 18, low 27, false 9): 13 patch entries applied by the implementation subagent (stale `/me` before the `already_linked` action; `/me` re-read by the pull-to-refresh of 4 and a new one on 10; « Plus de N cliniques » while pages remain; a near-mode empty body; `deniedForever`; coordinates rounded to 2 decimals; the limit message; touching opening ranges merged; the typed pet kept in the draft; the dead pets gate, placeholder kinds and two orphan ARB keys removed; the search kept after a location failure) and 8 test gaps closed (requests refresh, struck slot and availability re-read, step-2 refill, back-to-step and 409 → 201 through the router, sending/sent guards, name-match misses, the real locator, a non-null next slot). 3 deferred (name identity of a listing — needs a contract field; open status on the device zone; iOS `BYPASS_PERMISSION_LOCATION_ALWAYS`), recorded in the frontmatter and `deferred-work.md`. The rejected findings and their reasons are in the triage log.

**Follow-up review recommended: true** — first pass with more than two medium entries patched (counts patched by verdict: medium 12 entries, low 9, high 0); the unverified risk is the patched behaviour no device has run yet: the step-2 pet now written to the draft on every change (its key churn and the cleared failure), and the `/me` re-reads on 4 and 10 for a clinic-less account. The slice's mandatory `bmad-code-review` serves as that pass.

**Verification.** `make ci` green on the patched tree (4 min 58 s: format, analyze, architecture, unit/widget/integration/tool tests, coverage gate 100% on the gated files, plain-bash checks, api-check); `fvm flutter gen-l10n` leaves no diff. Not verified yet: the emulator walk (next step of the slice), iOS.

**Residual risks.** The geolocator permission flow and the manifest only run on a device; the listing ↔ clinic name match; the open status on the device zone.

## Emulator walk (2026-11-04)

Walked on the Android emulator (`Medium_Phone_API_37.0`) against the local backend; screenshots in the notes folder's `shots-clinic-listing/`. Julien Girard (linked to Paris and Lyon): screen 10 from « Ajouter une clinique » with his Paris suggestion (not accepted), the search (« lyon », a one-letter query answered by the server's « Saisissez au moins 2 caractères. »), « Autour de moi » (the permission refused then granted once; the emulator's default position, Mountain View, sent rounded; the server answered no clinic within 150 km and the near-mode empty state showed); Lyon's sheet, the slot step, the pet step, the request refused `already_linked`, « Prendre rendez-vous » opening the known-client wizard on Lyon; « Déjà client »; the Paris (two ranges a day, not online) and Vercors (no new client) sheets. Élise Moreau (clinic-less): the three clinic-less tabs, her Paris suggestion accepted (the pending callout on 10, « En attente » on 6), a new-client request at Lyon sent (« Demande envoyée », then « En attente » on 4 without a refresh), a second one refused `booking_request_limit`. Hugo Masson: three declined requests on 4 with « Aucune clinique rattachée ».

The walk changed three things (commit `e432459`): Android positions come from the platform's location manager (`forceLocationManager: true`), because Google Play services' settings check opened Google's « Location Accuracy » consent dialog before any fix; the closed-to-new-clients block of 11 is a white card with « Appeler la clinique » (an info box disappears on the canvas) and the new-client hint is hidden for a clinic closed to new clients online; a wrapping motif keeps 8 above and below in its C-11b row.

### Review Findings

Code review (bmad-code-review) of the branch against `master` (`2497c52`), head `e432459`: 4 layers (blind hunter, edge-case hunter, verification gap, acceptance auditor), 38 findings — high 0, medium 8, low 22, false 8. 0 decision-needed, 15 patch entries (18 findings), 1 defer, 19 rejected.

- [x] [Review][Patch] The typed pet written into the draft on every keystroke broke the retry's key after an edit-and-revert and wiped a refusal on a re-tapped species (blind, edge) [lib/features/scheduling/presentation/listing_confirm_page.dart] — the draft takes the pet on « Envoyer » only; the typed pet lives beside the draft for the refill; the name error hides once the name differs from the one sent.
- [x] [Review][Patch] Screen 11 rebuilt on every state change of the steps above it (blind) [lib/features/scheduling/presentation/listing_motif_section.dart] — kept alive with `ref.listen`.
- [x] [Review][Patch] Step 2 said « Choisissez d'abord un motif. » with a motif but no slot, flashing during the pop after a 409 (edge, acceptance) [lib/features/scheduling/presentation/listing_confirm_page.dart] — « Choisissez d'abord un créneau. ».
- [x] [Review][Patch] Every query change blanked the results behind a full-page spinner (blind) [lib/features/clinic_listing/presentation/clinic_search_page.dart] — the last results stay shown with a thin progress bar while the next search loads.
- [x] [Review][Patch] « Plus de 0 cliniques » on an empty page with a next cursor (blind, edge) [lib/features/clinic_listing/presentation/clinic_search_page.dart] — no count line without items.
- [x] [Review][Patch] Positions rounded to ~1 km while the cards print tenths of a km (blind) [lib/features/clinic_listing/presentation/clinic_listing_providers.dart] — 3 decimals (~100 m).
- [x] [Review][Patch] A request confirmed by a clinic that is not the active one vanished from screen 4 (blind) [lib/features/scheduling/domain/appointment_request.dart] — kept, with « Confirmée », unless its clinic is the active one.
- [x] [Review][Patch] A declined request without a reason got a neutral pill and no line (acceptance) [lib/features/scheduling/presentation/scheduling_messages.dart] — treated as declined.
- [x] [Review][Patch] A 404 on accept left the pending link of an acceptance made elsewhere invisible (blind) [lib/features/client/presentation/link_suggestion_providers.dart] — `/me` re-read too.
- [x] [Review][Patch] Two kit parameters without a caller (`KivetoCallout.info` optional title, `KivetoCallout.danger.actionLoading`) (acceptance) [lib/shared/presentation/kit/feedback.dart] — removed.
- [x] [Review][Patch] architecture.md's D15 table still gave the new-client booking to `clinic_listing` (acceptance) [_bmad-output/planning-artifacts/architecture.md] — updated.
- [x] [Review][Patch] The `/me` re-read before the `already_linked` name match was untested (verification) [test/widget/features/scheduling/listing_booking_test.dart] — test with a stale `/me`.
- [x] [Review][Patch] The "exactly one match" rule was untested with two matches (verification) [test/widget/features/clinic_listing/clinic_listing_page_test.dart] — test added.
- [x] [Review][Patch] The session scoping of the suggestions and the requests was untested (verification) [test/widget/features/clinic_listing/clinic_search_page_test.dart, test/widget/features/scheduling/appointment_requests_test.dart] — another-session tests.
- [x] [Review][Patch] A `validation_failed` on another property than the name was never shown in a test (verification) [test/widget/features/scheduling/listing_booking_test.dart] — test added.
- [x] [Review][Defer] The device-clock status of 11 cannot fail on a UTC CI if `.toLocal()` is dropped (verification) [lib/features/clinic_listing/presentation/clinic_listing_page.dart] — deferred: the existing deferred-work entry « pin a non-UTC TZ for the test step of make ci » closes it.

Rejected:
- `low` 24/7 and overnight clinics: the backend refuses closesAt ≤ opensAt and times after 23:59 (`OpeningSlot::TIME`), so no overnight range or 24:00 reaches the app; a 24/7 clinic encoded 00:00–23:59 would read « ferme à 23:59 » — rare, a cross-day status needs new branches (noted as a known issue).
- `low` No settings action on the location SnackBars and no last-known position: the messages say what to do; an action needs a new seam.
- `low` No call action when the motif list is empty or fails: `onlineBooking` already means a motif open to new clients; the error view retries.
- `low` The `already_linked` action without a confirmed clinic after the re-read (blind, edge): needs `/me` to fail right after the server confirmed the link; the redirect to `/clinics` is a sane fallback.
- `low` ARB keys shared between screens (`screenClinicsTitle` as a button, `homeGreeting`, `appointmentsMoreError` in `MoreFooter`): the texts are the same; naming only.
- `low` `callClinic` and the dialer seam exported by scheduling for clinic_listing: works, no cycle; a move to shared is churn.
- `false` The spec's context paths on one machine: every slice spec references the notes folder the same way (the effort's convention).
- `low` The clinic's city mapped but not shown: names carry the city in the data; showing it adds UI.
- `low` `/me` freshness on 11 and its silent failure on 10: the pull-to-refresh of 10 re-reads it; the greeting falls back to « Bonjour ».
- `false` Overlapping ranges: the backend refuses overlapping slots.
- `false` A day ending 24:00: the backend's times stop at 23:59.
- `low` « ouvre mercredi à … » for the same weekday next week: a clinic open one day a week is rare.
- `false` A pending request in the past: the server expires pending requests 2 h before their start.
- `low` The new-client hint above a `booking_not_open` answer of the motifs: a race between the sheet and the motifs; rare.
- `false` Edit the spec after the walk and the triage (acceptance ×2): the rule forbids fixing a finding by editing the spec under review; this section records the walk.
- `false` A suggested motif's row shows its reason: the listing motifs are never suggested (« Sans animal, suggested est toujours false », contract).
- `false` An accepted suggestion hidden for the page's life: a suggestion the clinic refused never comes back (contract).
