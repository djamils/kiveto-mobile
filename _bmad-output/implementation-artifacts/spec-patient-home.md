---
title: 'Slice 3 — home, patient, consultation: screens 1 « Accueil » and 2 « Fiche animal », the clinic switcher'
type: 'feature'
created: '2026-11-03'
status: 'done'
baseline_revision: '950672aa7a20357f5ca7120b3478444a85c6128c'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-document.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-app-shell.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-identity-access.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-document.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/mockup/01.html'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/mockup/02.html'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/design-system.md'
warnings: ['oversized', 'multiple-goals']
deferred:
  - summary: >-
      The home header's clinic line (and chevron), « Carnet PDF » and the switcher sheet's active mark disappear for the length of a `/me` reload (pull-to-refresh, after a document is opened).
    evidence: |-
      Blind hunter, verified: these widgets read `activeClinicProvider` through `AsyncData` patterns only (the slice 1–2 rule « never `.value` », which keeps a previous account's clinic from showing); `ActiveClinicNotifier.build` awaits `meProvider.future`, so any `/me` reload puts it in `AsyncLoading`. Slice 2 notes the same blink of the Documents subtitle. A fix needs a way to tell a same-account refresh from a session change (e.g. keep the last value keyed by account id).
    location: >-
      lib/features/home/presentation/home_header.dart:29
    severity: low
  - summary: >-
      The clinic switcher (the home header's clinic name) is an unpadded ~18 px tap target, and the pet page's back button has a 10 px dead strip (its 44 px box overflows a 34 px slot).
    evidence: |-
      Blind hunter, verified: `_ClinicSwitcherButton` is a bare `GestureDetector` on 13 px text + 16 px chevron (mockup 01 draws it without padding); Flutter hit-testing stops at the parent's bounds, so the hit area cannot grow without moving the layout. Needs a kit-level « expanded hit area » solution (design-system § 7 asks for 44/48 px targets without changing drawn sizes).
    location: >-
      lib/features/home/presentation/home_header.dart:69
    severity: medium
---

<intent-contract>

## Intent

**Problem:** After sign-in the owner lands on a placeholder home and the Animaux tab is a placeholder: no next appointment, no pets, no care due dates, no latest documents, no pet sheet (identity, weight, chip, care items, vaccination booklet, visit history), and no way to switch between the clinics of the account although every clinic-scoped screen depends on the active clinic.

**Approach:** Build three features on the D15 layout — `home` (screen 1 on `PetsApi.getHome`, composing the others through their public APIs), `patient` (screen 2 on `PetsApi.listPets/getPet/listPetCareItems` + the booklet through `portalFileDownloaderProvider`), `consultation` (the « Historique » timeline on `PetsApi.getPetTimeline`, cursor-paginated) — plus the clinic switcher sheet in `client` (`activeClinicProvider.notifier.select`). Mockups 01 and 02 decide the look, the contract decides the data; undesigned states use the kit's async widgets.

## Boundaries & Constraints

**Always:**
- D15 rules 1–8 (`test/architecture/`): a domain imports no other feature; features reach each other only through `features/<other>/<other>.dart`, no cycle (home → client, patient, document; patient → client, consultation, document; consultation → client, document). 100 % line coverage of every new or changed file of `features/*/{domain,application,infrastructure}` and `shared/domain`; `make ci` green.
- Shared vocabulary moves to `shared/domain/` (pure enums): `care_status.dart` `enum CareStatus { booked, overdue, dueSoon, upToDate, unknown }`; `species.dart` `enum Species { dog, cat, nac, other, unknown }`; `DocumentKind` and `PaymentStatus` move out of `features/document/domain/document.dart` into `shared/domain/document_kind.dart` and `shared/domain/payment_status.dart` (unchanged values); `features/document/document.dart` re-exports both so external callers do not change.
- material_ui only; Dart 3.13 constructors (`const new(...)`); repositories throw `ApiFailure`; no `print`, no `DateTime.now()` in domain/application/shared domain; no `dynamic` at API boundaries.
- French user strings only in `lib/l10n/app_fr.arb` (keys prefixed `home…`, `pet…`, `care…`, `timeline…`, `client…`, each with `@key.description`, ICU plurals), then `fvm flutter gen-l10n`. Code/comments/docs English.
- Clinic-scoped providers `ref.watch(sessionStatusProvider)` and watch only the active clinic id (`activeClinicProvider.selectAsync((c) => c?.clinicId)`); read providers through `AsyncData` patterns / `AsyncValueView`, never `.value`; unwrap Riverpod's `ProviderException` before switching on a failure type (the shared `ErrorView` already does).
- Page exits are `void Function(BuildContext …)` callbacks wired in `lib/app/routing/app_router.dart` (features never import `app/`).
- The booklet goes through `portalFileDownloaderProvider.download('/api/portal/v1/clinics/{c}/pets/{id}/vaccination-booklet')` (ids `Uri.encodeComponent`ed) mapped to `PortalFile`, shown with `openPdfFile` of `document.dart`; documents open with `openDocumentFile`.
- « today » (countdowns, ages, the year rule) = the device's local date of `clockProvider.now()` (`.toLocal()`), one helper `deviceToday(Clock)` in patient presentation exported by `patient.dart`.

**Never:**
- Edit `packages/kiveto_portal_api/`, `contracts/`, `CLAUDE.md`, `.claude/settings.json`; import `package:flutter/material.dart`; call the generated `getVaccinationBooklet` / `getDocumentFile`.
- Re-implement backend rules: the care status, the pets shown, which appointment is next, the questionnaire state come from the server; the app only chooses wording and tone.
- Build screen 15 (questionnaire), 12 (booking), the change-request form (slice 6), notifications (the bell is hidden), a pets list page, iOS specifics.

## I/O & Edge-Case Matrix

Fixtures in `test/support/fixtures/portal_api/`; `testNow` = 2026-11-03 (today).

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Home Julien Paris | `me.get.200.json`, `clinics.paris.home.get.200.json` | header « Clinique Vétérinaire de Paris » + chevron (2 clinics), « Bonjour Julien », no bell; hero « Prochain rendez-vous », pill « Confirmé », « Mer. 11 nov. · 10:30 », « Oslo — Rendez-vous · Dr Éric Rousseau », no « Remplir le questionnaire » (submitted), « Gérer » full width; one full-width pet card « Oslo » / « Chien · 6 ans »; À prévoir rows « Oslo — CHPL » / « Avant le 5 sept. 2027 » + green « À jour » (twice: CHPL, Rage); documents « Facture PAR-2026-000067 » / « 52,00 € · Payée » (green € tile) and « Facture PAR-2026-000066 » / « 78,00 € · Payée » | `/clinics/{c}/home` 404 → « Clinique indisponible » / « Votre accès à cette clinique n'est plus actif. », retry reloads `/me` and the home; other failures → `ErrorView` + retry |
| Home Julien Lyon | active Lyon, `clinics.lyon.home.get.200.json` | no hero; one full-width card « Pixel » / « Chat · 4 ans »; « À prévoir » header + « Prendre rendez-vous » only; no « Derniers documents » section | — |
| Home Garnier Paris | `me.garnier.get.200.json`, `clinics.paris.home.garnier.get.200.json` | hero « Jeu. 5 nov. · 09:00 », « Oscar — Rendez-vous · Dr Lucie Bernard »; 4 cards 2 per row (Coco « NAC · 5 ans », Nala « Chat · 4 ans », Oscar « Chien · 11 ans », Pepito « Chien · 2 ans »); rows « Oscar — Vermifugation » / « Avant le 13 oct. » + danger pill « En retard » (×3); documents « Ordonnance ORD-2026-000036 » / « Pepito · 2 nov. » (orange « Rx » tile) and « Facture PAR-2026-000025 » / « 96,00 € · Non payée » | — |
| Questionnaire | `questionnaireStatus: not_started` (fixture edited in the test) | « Remplir le questionnaire » (white on-brand) + « Gérer »; tap → exit `onFillQuestionnaire(context, appointmentId)` → push `/appointments/:id/questionnaire` | status `pending_clinic_confirmation` → pill « En attente »; other statuses → no pill |
| Clinic switch | Julien, tap the clinic name | sheet « Changer de clinique »: « Clinique Vétérinaire de Paris » (brand dot, « Active ») and « Clinique Vétérinaire de Lyon » / « Lyon » (grey dot, chevron); tap Lyon → store written `client.activeClinic` = Lyon id, sheet closed, the home requests `/clinics/{lyon}/home`, header « Clinique Vétérinaire de Lyon »; the Documents list then requests Lyon's documents | one confirmed clinic → the name is plain text, no chevron, not tappable |
| Pet page Oscar | `/pets/{oscar}`, `clinics.paris.pets.garnier.get.200.json`, `…pet.garnier-oscar…`, `…care-items.garnier-oscar…`, `…timeline.garnier-oscar…` | switcher (5 pets, horizontally scrollable, Oscar selected); avatar « O », « Oscar », « Chien · Labrador retriever · Mâle castré »; grid « Né le » 02/08/2015, « Poids » « 34,9 kg » + « · 27 sept. », « Puce » « •••• 0446 », « Suivi par » « Dr Lucie Bernard »; care « Vermifugation » / « À faire depuis le 13 oct. » + « En retard », « CHPPiL » / « Valide jusqu'au 16 avr. 2027 » + « À jour »; timeline first « 18 août 2026 · Dr Lucie Bernard » / « Bilan thyroïdien » / chip « Compte-rendu » (brand dot), 20 entries, then `?cursor=<nextCursor>` → 23 entries, no further request | pet detail, care items, timeline fail independently, each with its own retry; the rest of the page stays |
| Pet page Nala / Coco / Filou | female neutered; `due_soon` 2026-11-09; deceased | « Née le » 02/10/2022, « Chat · Européen · Femelle stérilisée », « 4,25 kg · 6 août », « Puce » « — »; « Typhus-Coryza » / « Prochain avant le 9 nov. » + amber « Dans 6 j »; Filou: neutral pill « Décédé », « Aucun soin préventif à suivre. », « Aucune consultation partagée pour le moment. » | — |
| Pet page Julien | `/pets` (Animaux tab), Paris | the first pet (Oslo), no switcher (1 pet); « Chien · Labrador » (sex and sterilization unknown dropped); « 24,3 kg · 5 sept. », « Puce » « — », « Suivi par » « — »; care « Valide jusqu'au 5 sept. 2027 » + « À jour » | `/pets/{id}` not in the list (another clinic) → the first pet; no pet → `EmptyState` « Aucun animal » |
| Pepito timeline | `…timeline.garnier-pepito…` | « 31 août 2026 · Dr Éric Rousseau », « Boiterie », chips « Compte-rendu », « Ordonnance »; tap a chip → `openDocumentFile(clinicId, DocumentId(id), title: 'Ordonnance · Boiterie')` | next page fails → entries kept + « Impossible de charger la suite. » + « Réessayer »; `400 cursor_invalid` → reload from page 1 |
| Booklet | tap « Carnet PDF » | full-screen viewer « Carnet de vaccination · Oscar » on the PDF of the 302's `Location` | 503 → viewer `ErrorView` « Service indisponible » + retry; 404 → « Document indisponible » |
| Report a change | tap « Signaler une modification » | exit `onReportChange(context, petId)` → the app's placeholder sheet « Signaler une modification » / « Cet écran arrive dans une prochaine version. » | — |
| Care pill rule | status × days to `dueOn` | `booked` amber « RDV pris »; `overdue` danger « En retard »; `dueSoon` amber countdown; `upToDate` ≤ 60 days neutral countdown, > 60 green « À jour »; `unknown` none. Countdown: ≤ 0 « Aujourd'hui », 1 « Demain », 2–13 « Dans {n} j », ≥ 14 « Dans {n ~/ 7} sem. » | — |

</intent-contract>

## Code Map

- `packages/kiveto_portal_api` (read-only; contract synced on this branch at backend `bcb8d8b1`, which added `booked`): `PetsApi(server)`. `getHome({clinicId})` → `GetHomeResponse200(body: Home{nextAppointment: HomeNextAppointmentAnyOfModel (.appointmentView → AppointmentView?), pets: List<PetSummary>, careItems: List<HomeCareItemView>, latestDocuments: List<DocumentView>})`. `AppointmentView{id, startAt (OffsetDateTime), endAt, pet: AppointmentViewPetAnyOfModel (.petReferenceView → PetReferenceView{id?, name}?), motif: MotifReferenceView{id?, label}, practitioner: PractitionerView{id, displayName?}, status: AppointmentViewStatusModel(confirmed|pendingClinicConfirmation|cancelledByClient|cancelledByClinic|declined|completed|noShow|unknown), questionnaireStatus: AppointmentViewQuestionnaireStatusModel(notStarted|submitted|unknown), …}`. `HomeCareItemView{pet: PetReferenceView, kind, label, lastDoneOn: Date, dueOn: Date, status: HomeCareItemViewStatusModel(booked|overdue|dueSoon|upToDate|unknown)}`. `listPets({clinicId})` → `ListPetsResponse200(body: List<PetSummary{id, name, species: PetSummarySpeciesModel, breed?, sex: PetSummarySexModel, sterilization: PetSummarySterilizationModel, birthDate: Date?, initial, lifeStatus: PetSummaryLifeStatusModel}>)`. `getPet({clinicId, petId})` → `GetPetResponse200(body: Pet{…same with Pet*Model enums…, lastWeight: PetLastWeightAnyOfModel (.petWeightView → PetWeightView{weightGrams, at: Date}?), chipNumberMasked?, referentVet?})`. `listPetCareItems({clinicId, petId})` → `ListPetCareItemsResponse200(body: List<CareItem{kind, label, lastDoneOn, dueOn, status: CareItemStatusModel}>)`. `getPetTimeline({clinicId, petId, cursor, limit})` → `GetPetTimelineResponse200(body: PetTimeline{items: List<TimelineEntryView{visitId, date, vet?, title, documents: List<TimelineDocumentView{id, kind: TimelineDocumentViewTypeModel}>}>, nextCursor?})`. Check the exact response class names in `lib/src/operation/` / `lib/src/response/` before writing switches.
- `lib/features/document/infrastructure/portal_document_repository.dart` -- reference mapper of `DocumentView` (`_document`, `_paymentStatus`, `clinicInstantOf`, `Money`) and of the file download (`_downloader.download(...)` → `PortalFile`). Copy the shape for home's documents and the booklet.
- `lib/features/document/domain/document.dart` -- owns `DocumentKind`, `PaymentStatus` today: move both to `shared/domain/` and import them back; `lib/features/document/document.dart` re-exports them. Update imports in `document_repository.dart`, `portal_document_repository.dart`, `document_messages.dart`, `documents_page.dart`, `documents_providers.dart`, `pdf_file_page.dart` and their tests where needed.
- `lib/features/document/presentation/document_messages.dart` -- `joinPetNames(l10n, names)`, `paymentLabel(l10n, status)`; export both from `document.dart` and add `documentKindName(l10n, DocumentKind)` (« Compte-rendu », « Ordonnance », « Facture », « Résultats », « Certificat », unknown « Document ») for the timeline chips.
- `lib/features/document/presentation/pdf_file_page.dart` -- `openDocumentFile(context, {clinicId, documentId, title})` (invalidates `meProvider`, marks lists read), `openPdfFile(context, {title, load: Future<PortalFile> Function(WidgetRef)})`, `pdfViewBuilderProvider` (override in tests). Read-only.
- `lib/features/document/presentation/documents_providers.dart` -- `DocumentListNotifier` / `DocumentListState`: the pattern for the timeline notifier (build watches session + clinic id; `loadMore` keeps items, `moreError`, `cursor_invalid` → `ref.invalidateSelf()`, drops answers of a rebuilt ref via `built.mounted`).
- `lib/features/client/client.dart`, `presentation/client_providers.dart` -- `meProvider`, `activeClinicProvider`, `ActiveClinicNotifier.select(ClinicId)` (persists; ignores non-confirmed ids), `Me.confirmedClinics`, `ClinicLink{clinicId, name, city?, unreadDocuments}`. Add `presentation/clinic_switcher_sheet.dart` and export `showClinicSwitcherSheet`.
- `lib/core/di/core_providers.dart` -- `portalServerProvider`, `apiFailureMapperProvider`, `portalFileDownloaderProvider`, `clockProvider`, `sessionStatusProvider`. `lib/core/network/portal_results.dart` -- `apiFailureOf`, `clinicInstantOf`, `localDateOf`.
- `lib/app/routing/app_router.dart` -- `/home` builds `HomePlaceholderPage` (delete `home_placeholder_page.dart`, build `HomePage`); Animaux branch `_page(AppRoutes.pets, …, routes: [_page(':petId', …, kind: pushed)])` → two sibling `GoRoute`s `/pets` and `/pets/:petId` building `PetPage`. Exits: `_goHome`, `context.go(AppRoutes.pet(id))`, `context.go(AppRoutes.appointments)`, `context.push(AppRoutes.questionnaire(id))` (unawaited), `context.push(AppRoutes.bookingPet)`, `context.go(AppRoutes.documents)`. `lib/app/routing/placeholder_page.dart` -- add `showPlaceholderSheet(context, title)` (`showKivetoSheet` + `KivetoSheet(title:, children: [Text(l10n.placeholderBody)])`). `lib/app/routing/app_routes.dart` -- `AppRoutes.pet(id)` exists.
- Kit (`lib/shared/presentation/`): `KivetoSectionHeader(title, trailingCaption:, actionLabel:, onAction:, trailing:)` (C-41), `KivetoCard` / `KivetoCard.list(children:)` (C-10 with dividers), `KivetoListRow(title:, meta:, trailing:)` (C-11a, padding 14 — the pet page needs 13 14: wrap or add a padding parameter), `KivetoListRow.tile(leading: KivetoLeadingTile(colors:, glyph:|text:, size: 36))` (C-11c), `StatusPill(label, tone: StatusTone.success|warning|neutral|brand|onBrand|danger)`, `InitialsAvatar(initial, size: 44|64, tone: AvatarTone.forPetIndex(i))`, `StatusDot(active:)`, `KivetoSegmentedControl(compact: true, segments:, selected:, onChanged:)` (C-15b, `Row(mainAxisSize: min)`), `KivetoButton.onBrand/onBrandOutline` (C-7), `.dark(icon: LucideGlyph.plus)` (C-2), `.tonal(size: small, icon: LucideGlyph.download)` (C-6a), `.outline(size: medium, icon: LucideGlyph.penLine)` (C-4b), `KivetoDocumentChip(label:, onPressed:)` (C-13e), `KivetoIconButton.back`, `KivetoLinkButton`, `showKivetoSheet` + `KivetoSheet(title:, children:)`, `KivetoIcon(LucideGlyph.chevronDown|chevronRight|fileText, size:, color:)`, `AsyncValueView`, `ErrorView(error:, onRetry:, title:, message:)`, `LoadingView`, `EmptyState(glyph:, title:, body:)`, `KivetoSkeleton`, `KivetoFootnote(text, small:, centered:)`, tokens `KivetoColors.*` (canvas, surface, ink, inkMuted, brand, border, divider…), `KivetoText.*`, `kivetoTextStyle(size, weight, color:)` (never `copyWith(fontSize:)`), `KivetoSpace.*`, `KivetoRadius.*`. `KivetoFormat.dateTimeShort`, `dayMonth`, `dayMonthYear`, `numericDate`, `money` -- add `dayMonthYearLong(ClinicInstant)` « 14 octobre 2026 » on the clinic wall clock (`DateFormat('d MMMM y', 'fr_FR')`).
- `lib/shared/domain/{clinic_id,clinic_instant,local_date,money,portal_file,api_failure,clock}.dart` -- `LocalDate.daysUntil`, `LocalDate(y, m, d)`, `ClinicInstant`, `NotFoundFailure`, `BusinessFailure(code: 'cursor_invalid')`.
- Tests: `test/support/fakes.dart` (`pumpKivetoApp(tester, session:, backend:, activeClinicStore: InMemoryActiveClinicStore(choices:), initialLocation:)`, `pumpPage(tester, page, backend:, session:, overrides:, prepare:)`, `FixedClock`, `testNow`, `memorySession(pair('A'))`, `pumpBriefly`), `test/support/portal_api/portal_http_harness.dart` (`PortalHarness.create(tokens:)`, `api`, `problem(type, status)`, `portalFixtures`), `test/support/portal_api/fake_portal_backend.dart` (`backend.on/onRequest`, `PortalReply.fixture/json/bytes/empty`, `requestsTo`). Patterns: `test/unit/features/document/infrastructure/portal_document_repository_test.dart` (captures + 302 PDF), `test/widget/features/document/documents_page_test.dart` (pagination, fake PDF view), `test/widget/features/document/pdf_file_page_test.dart`.
- Tests to update: `test/widget/app/app_flow_test.dart` (home placeholder expectations: « Bonjour Julien », the stored clinic name, `/me` failure retry — the new home keeps the header from `/me` + active clinic; route `/clinics/{c}/home` in those backends or accept the body's error view), `test/widget/app/routing/app_router_test.dart` (pets routes are real pages now), document tests whose imports of `DocumentKind`/`PaymentStatus` move.
- Fixtures (committed on the branch, exact bytes): Julien `me.get.200.json`, `clinics.{paris,lyon}.home.get.200.json`, `clinics.{paris,lyon}.pets.get.200.json`, `clinics.{paris,lyon}.pet.get.200.json`, `clinics.{paris,lyon}.pet.care-items.get.200.json`, `clinics.{paris,lyon}.pet.timeline.get.200.json`, `clinics.paris.pet.not-found.get.404.json`, `clinics.paris.pet.timeline.cursor-invalid.get.400.json`, `clinics.unknown.home.get.404.json`; Garnier `me.garnier.get.200.json`, `clinics.{paris,lyon}.home.garnier.get.200.json`, `clinics.paris.pets.garnier.get.200.json`, `clinics.paris.pet.garnier-{oscar,nala,filou}.get.200.json`, `clinics.paris.pet.care-items.garnier-{oscar,nala}.get.200.json`, `clinics.paris.pet.timeline.garnier-{oscar,oscar-page2,pepito}.get.200.json`; `files.documents.get.200.pdf` (booklet bytes stand-in). Real booklet 302 `Location`: `http://portal.kiveto.local:81/api/portal/v1/files/booklets/{c}/{petId}/{hash}?_expiration=…&_hash=…`, then `application/pdf`, `inline; filename="carnet-de-vaccination.pdf"`. Ids: Paris `01960000-0000-7000-8000-000000000001`, Lyon `…000101`, Oslo `01a19a0f-128f-7a54-b39c-e01a30ee66d2`, Pixel `01a19a10-d1df-75fb-acf1-2987bfc236b8`, Oscar `01a19a10-20d7-77bd-bbad-d251136402fc`, Nala `01a19a10-214a-7baa-93c9-96d75aad7892`, Filou `01a19a10-2291-7c4a-a837-900159faa98f`, Pepito `01a19a10-21af-748a-b841-690b02e4fe18`.

## Tasks & Acceptance

**Execution:**
- `lib/shared/domain/care_status.dart`, `species.dart`, `document_kind.dart`, `payment_status.dart` -- the shared enums (move the last two from document's domain; `document.dart` barrel re-exports them; fix document imports/tests) -- vocabulary used by ≥ 2 features' domains.
- `lib/features/patient/domain/pet.dart` -- `extension type const PetId(String value)`; `enum Sex {male, female, unknown}`, `Sterilization {intact, neutered, unknown}`, `LifeStatus {alive, deceased, missing, unknown}`; `PetSummary{id: PetId, name, species: Species, breed?, sex, sterilization, birthDate: LocalDate?, initial, lifeStatus}`; `PetWeight{grams: int, at: LocalDate}`; `Pet{summary fields…, lastWeight?, chipNumberMasked?, referentVet?}` (compose or extend `PetSummary`). `care_item.dart`: `CareItem{kind: String, label, lastDoneOn: LocalDate, dueOn: LocalDate, status: CareStatus}`. `pet_repository.dart`: `pets(ClinicId) → List<PetSummary>`, `pet(ClinicId, PetId) → Pet`, `careItems(ClinicId, PetId) → List<CareItem>`, `vaccinationBooklet(ClinicId, PetId) → PortalFile` -- patient domain, pure Dart.
- `lib/features/patient/infrastructure/portal_pet_repository.dart` -- on `PetsApi` + `PortalFileDownloader` + `ApiFailureMapper`; maps every generated enum (`unknown` kept), nullable wrappers, `localDateOf`; booklet path with encoded ids -- the only patient code touching DTOs.
- `lib/features/patient/di.dart` -- `petRepositoryProvider`. `lib/features/patient/patient.dart` -- exports the domain, `PetPage`, the care helpers (`careStatusPill`/`CareStatusPill`, `careDate`), `speciesLabel`, `petAgeLabel`, `deviceToday`.
- `lib/features/patient/presentation/` -- `pet_providers.dart` (`petsProvider`, `petDetailProvider` family by `PetId`, `careItemsProvider` family; session + clinic id watched), `pet_page.dart` (`PetPage({String? petId, required onBack, required onReportChange})`: top row, header, C-11f grid, report button + caption, care section with « Carnet PDF », `PetTimelineSection` from `consultation.dart`; pull-to-refresh invalidates the four providers; skeleton while the pets load), `pet_messages.dart` (species/sex/life labels, weight « {kg} kg » with `NumberFormat('#,##0.##', 'fr_FR')`, age, care sub-lines, countdown, care pill, `careDate`: `dayMonth` in today's year else `dayMonthYear`, `deviceToday`) -- screen 2.
- `lib/features/consultation/domain/timeline.dart` -- `TimelineEntry{visitId, date: ClinicInstant, vet?, title, documents: List<TimelineDocument{id: String, kind: DocumentKind}>}`, `TimelinePage{items, nextCursor?}`; `timeline_repository.dart`: `timeline(ClinicId, String petId, {String? cursor}) → TimelinePage`. `infrastructure/portal_timeline_repository.dart` on `PetsApi.getPetTimeline`. `di.dart` `timelineRepositoryProvider`. `presentation/timeline_providers.dart` (`petTimelineProvider` = `AsyncNotifierProvider.family<PetTimelineNotifier, PetTimelineState, String>` like `DocumentListNotifier`), `presentation/pet_timeline_section.dart` (`PetTimelineSection({required String petId})`: « Historique », C-32 items, end row → `loadMore()`, inline retry, chips → `openDocumentFile`). `consultation.dart` exports the domain and `PetTimelineSection`, `petTimelineProvider`.
- `lib/features/home/domain/home_overview.dart` -- `HomeOverview{nextAppointment?, pets: List<HomePet>, careItems: List<HomeCareItem>, latestDocuments: List<HomeDocument>}`, `NextAppointment{id, startAt: ClinicInstant, petName?, motifLabel, practitionerName?, status: AppointmentState {confirmed, pendingClinicConfirmation, other}, questionnaire: QuestionnaireState {notStarted, submitted, unknown}}`, `HomePet{id, name, initial, species: Species, birthDate?}`, `HomeCareItem{petId?, petName, label, dueOn, status: CareStatus}`, `HomeDocument{id, kind: DocumentKind, title, petIds, issuedAt: ClinicInstant, invoice: HomeInvoice{total: Money, paymentStatus: PaymentStatus}?}`; `home_repository.dart` `overview(ClinicId)`. `infrastructure/portal_home_repository.dart` on `PetsApi.getHome`. `di.dart` `homeRepositoryProvider`. `home.dart` exports `HomePage`.
- `lib/features/home/presentation/` -- `home_providers.dart` (`homeOverviewProvider`: session + clinic id; null clinic → empty overview), `home_page.dart` (`HomePage({required onOpenPet, required onManageAppointments, required onFillQuestionnaire, required onBook, required onSeeAllDocuments})`: C-37b header from `meProvider` + `activeClinicProvider` (shown even when the overview fails), body from the overview, pull-to-refresh `/me` + overview), widgets `home_header.dart`, `next_appointment_card.dart` (C-27), `pet_cards.dart` (C-29 grid), `care_list.dart`, `latest_documents.dart` (C-11c rows; tile per kind: report indigo `fileText` glyph, invoice green « € », prescription orange « Rx », lab neutral « Lab », certificate indigo « Cert », unknown neutral `fileText`; meta via `joinPetNames` with names from the overview's pets, or `money · paymentLabel`) -- screen 1.
- `lib/features/client/presentation/clinic_switcher_sheet.dart` + `client.dart` export -- `showClinicSwitcherSheet(BuildContext)`.
- `lib/shared/presentation/formatters/kiveto_format.dart` -- `dayMonthYearLong`.
- `lib/app/routing/app_router.dart`, `placeholder_page.dart`; delete `home_placeholder_page.dart` -- routes and exits above.
- `lib/l10n/app_fr.arb` + `fvm flutter gen-l10n` -- every new string (see Design Notes).
- Tests: `test/unit/shared/domain/…` (if any logic), `test/unit/features/patient/{domain,infrastructure}/…`, `test/unit/features/consultation/{domain,infrastructure}/…`, `test/unit/features/home/{domain,infrastructure}/…` on the captures (every mapping row, every `unknown`, null wrappers, `?cursor=` / `limit` absent, 404/400/network failure, the booklet 302 + PDF through `PortalHarness`); `test/widget/features/{home,patient,consultation,client}/…` covering every matrix row; `test/widget/shared/…` for `dayMonthYearLong`; updated app/router/document tests -- matrix coverage.

**Acceptance Criteria:**
- Given Julien signed in with Paris active, when the app opens `/home`, then the home of the Paris row of the matrix shows under the bottom nav (Accueil active), with no bell.
- Given the home, when the owner taps a pet card, then the Animaux tab shows that pet's page (`/pets/:petId`) and its back button returns to `/home`; when the owner taps « Gérer » the Rendez-vous tab opens; « Tout voir » opens the Documents tab; « Prendre rendez-vous » pushes `/booking/pet` over the shell.
- Given Julien on the home, when he switches to Lyon in the sheet, then the home, the Animaux tab (`/pets` → Pixel) and the Documents tab show Lyon's data, the Documents badge shows Lyon's `unreadDocuments`, and the choice survives a restart (the store holds Lyon).
- Given a latest document row, when it is tapped, then the in-app viewer opens that document's file (`/clinics/{c}/documents/{id}/file`).
- Given the Animaux tab, when it is opened, then the first pet of `GET /pets` shows; given ≥ 3 pets, the switcher scrolls horizontally and selecting a segment shows that pet without navigating.
- Given `make ci`, when it runs on the branch, then it is green (format, analyze, architecture, coverage 100 % on the gated files, scripts, api-check).

### Review Findings

Code review (bmad-code-review, 2026-11-03, branch diff against `master` 7bf776a, generated code excluded): 31 findings — 0 decision-needed, 15 patch (14 entries, applied), 6 defer (4 entries), 10 rejected.

- [x] [Review][Patch] go_router logs a warning and drops the non-serialisable `extra: Object()` on every pet navigation — an `int` token per `_goPet` [lib/app/routing/app_router.dart:76]
- [x] [Review][Patch] A clinic switch (and back) brings the switcher's old choice back — `_selected` dropped when the pets list no longer contains it (`ref.listen`, no mutation in build); grouped with the acceptance auditor's « reset when the clinic's pet list changes » [lib/features/patient/presentation/pet_page.dart:65]
- [x] [Review][Patch] A 404 on one pet's sheet or care items retries the same 404 — invalidates `petsProvider` and `/me` [lib/features/patient/presentation/pet_page.dart:466]
- [x] [Review][Patch] The 60-day threshold is two literals — one named constant [lib/features/patient/presentation/pet_messages.dart:124]
- [x] [Review][Patch] Non-exhaustive appointment status switch (`_ =>`) — the 8 generated values listed [lib/features/home/infrastructure/portal_home_repository.dart:52]
- [x] [Review][Patch] Pet cards and tappable kit rows not announced as buttons — `Semantics(button: true)` [lib/features/home/presentation/pet_cards.dart:91]
- [x] [Review][Patch] `petsProvider` exported with no user outside patient — export removed [lib/features/patient/patient.dart]
- [x] [Review][Patch] Switcher sheet never tested with a pending clinic — test [test/widget/features/home/home_page_test.dart]
- [x] [Review][Patch] « Mes animaux » hidden on an empty pets list untested — test [test/widget/features/home/home_page_test.dart]
- [x] [Review][Patch] Identity grid and care items « retry in flight » untested — tests [test/widget/features/patient/pet_page_test.dart]
- [x] [Review][Patch] Late next timeline page after a clinic switch untested — test [test/widget/features/consultation/pet_timeline_section_test.dart]
- [x] [Review][Patch] AC « Accueil active » not asserted — `currentIndex` 0 asserted [test/widget/app/home_flow_test.dart]
- [x] [Review][Patch] Capture `clinics.lyon.home.garnier.get.200.json` unused — mapped in the home repository test [test/unit/features/home/infrastructure/]
- [x] [Review][Patch] `CONTRIBUTING.md` §0 lacks slice 3 — row added with the validation record [CONTRIBUTING.md:29]
- [x] [Review][Defer] Contract pinned to the unmerged backend commit `bcb8d8b1` (blind-hunter + acceptance auditor) [contracts/SOURCE:4] — deferred: the backend merge was refused by the permission system; needs the user's go-ahead (deferred-work.md)
- [x] [Review][Defer] « Today » is the device's date, not the clinic's (blind-hunter + edge-case hunter) [lib/features/patient/presentation/pet_messages.dart:19] — deferred: needs a time-zone package decision (CLAUDE.md §7)
- [x] [Review][Defer] Header / « Carnet PDF » / sheet mark blink while `/me` reloads (edge-case hunter, carried from the build review) [lib/features/home/presentation/home_header.dart:29] — deferred: pre-existing « never `.value` » pattern
- [x] [Review][Defer] A failed store write reverts the clinic at the next `/me` reload (edge-case hunter) [lib/features/client/presentation/client_providers.dart] — deferred: pre-existing (slice 1)

Rejected:
- `low` (blind-hunter) The home's overdue rows read « Avant le 13 oct. » next to « En retard » — the intent's rule for home rows; the pill carries the lateness.
- `low` (blind-hunter) Test helpers (`_cursorOf`, `_fakePdfView`, JSON editors) copied across test files — test-only, no divergence named.
- `false` (blind-hunter) No empty state for a fully empty home — the intent: « header + À prévoir CTA, nothing else » (sections hide, API guide).
- `false` (acceptance auditor) `PetPage(request:)`, `_backOrHome` differ from the Code Map — fixing it means editing the spec; the triage log records them.
- `low` (acceptance auditor) Reselecting the Animaux tab on `/pets` keeps the switcher's pick — the shell keeps every tab root's state (Documents keeps its filter too); opening the tab from elsewhere is AC 5's case.
- `low` (edge-case hunter) A reloaded first page whose cursor answers `cursor_invalid` again loops — the contract's cursor is valid by construction; carried from the build review (same as slice 2).
- `low` (edge-case hunter) An invoice currency that is not 3 upper-case letters fails the whole home — the contract sends ISO codes; same as the documents mapper.
- `low` (edge-case hunter) Countdowns stale across midnight — carried from the build review.
- `low` (edge-case hunter) Blank `motifLabel` leaves a dangling separator; `PlaceholderKind.pushed` dead — carried from the build review (server sends labels; the kind is kept for later pushed pages).

## Spec Change Log

## Review Triage Log

### 2026-11-03 — Review pass
- verdicts: 53 findings — high 0, medium 9, low 36, false 8, maybe-false 0
- findings:
  - `[medium]` `[patch]` (intent) Care sub-lines: `upToDate` always « Valide jusqu'au », `unknown` « Fait le … · prochain avant le … », where the intent (mockup 02) wants « Prochain avant le » for `upToDate` within 60 days and for `unknown` — the spec's matrix kept only the pill rule; `careSubLine` now uses the pill's 60-day threshold, tests at 60/61 days.
  - `[low]` `[patch]` (intent) The home loads with `LoadingView` instead of the intent's `KivetoSkeleton` — replaced (first load and retry).
  - `[medium]` `[patch]` (intent) The pet switcher does not keep the selected pet visible — grouped with the blind hunter's identical finding; `_PetSwitcher` scrolls proportionally to the selected index after layout, test with Pepito (4th of 5).
  - `[false]` `[reject]` (intent) Back is « pop if possible, else home » instead of `go('/home')` — nothing pushes a pet page; from the home and the Animaux tab `canPop()` is false and back lands on `/home` (home_flow_test).
  - `[false]` `[reject]` (intent) Sex-inflected « Décédé/Décédée », « Disparu/Disparue », « Stérilisé » instead of a literal « (e) » — a reading choice recorded in the spec's design notes, correct French.
  - `[low]` `[reject]` (intent) Partial failures on the pet page use the full `ErrorView` rather than a compact one — rare (one part failing alone), and a compact variant is new kit surface.
  - `[low]` `[patch]` (intent) Odd pet counts ≥ 3 untested — grouped with the verification-gap finding below.
  - `[low]` `[reject]` (intent) A fully empty home (no pet) is untested — the sections hide on empty lists (Lyon covers the hidden appointment and documents); the remaining branch is a plain `if`.
  - `[false]` `[reject]` (intent) « À prévoir » keeps its header on an empty list — the intent says « keep header + CTA ».
  - `[false]` `[reject]` (intent) Home document meta gains a year outside the current year — the intent's date rule (`d MMM` in today's year, else with the year) applied consistently.
  - `[false]` `[reject]` (intent) No commits / `make ci` evidence in the patch — process, done at finalize (`make ci` green in 3 min 15 s before review).
  - `[medium]` `[patch]` (blind) Pet switcher never scrolls to the selected pet — grouped with the intent finding above.
  - `[low]` `[patch]` (blind) `GET /pets` 404 retry never re-reads `/me` — `_retryPets` invalidates `meProvider` on a `NotFoundFailure`, test added (also covers the edge-case finding below).
  - `[low]` `[reject]` (blind) Latest documents lose the name of a deceased/missing pet (home pets are alive only) — follows the spec (names from the overview); the fix costs a second request; a recent document about a non-alive pet is rare.
  - `[low]` `[defer]` (blind) Header clinic line, « Carnet PDF » and the sheet's active mark blink while `/me` reloads (widgets read `activeClinicProvider` through `AsyncData` only) — pre-existing pattern imposed by slices 1–2 (never `.value`; slice 2 notes the same subtitle blink); `activeClinicProvider` cannot tell a refresh from a session change; recorded in `deferred`.
  - `[medium]` `[defer]` (blind) The clinic switcher's tap target is ~18 px (mockup's unpadded text); the back button's 10 px overflow strip does not respond — enlarging the hit area without moving the mockup's layout needs a kit-level helper (Flutter hit-testing stops at the parent's bounds); recorded in `deferred` (the back glyph itself is fully tappable).
  - `[low]` `[patch]` (blind) The hero title is read twice by screen readers — overline wrapped in `ExcludeSemantics`.
  - `[low]` `[reject]` (blind) Per-pet families are not `autoDispose` — same as slice 2's `documentListProvider`; bounded by the pets visited; they rebuild on the session/clinic watch before showing anything.
  - `[low]` `[reject]` (blind) `homeDocumentTile` duplicates `documentTile` — two mockup designs (36 px glyph tile on 01, 40 px text tile on 05); sharing would couple them; pinned by the new home messages test.
  - `[low]` `[reject]` (blind) Generated-enum → shared-enum mappings repeated in document, home, patient infrastructure — each maps its own generated classes; no divergence named.
  - `[low]` `[reject]` (blind) `_cause` copied from async_views — two lines; making it public adds kit surface.
  - `[low]` `[reject]` (blind) « reload /me if it failed, then X » retry written six times — no divergence named.
  - `[low]` `[reject]` (blind) `careDate` / `deviceToday` live in patient — placed there by the spec; home already depends on patient.
  - `[low]` `[reject]` (blind) `HomeCareItem.petId` unused, care rows not tappable — mockup 01 rows are not links; the field is the server's.
  - `[medium]` `[patch]` (blind) Selection resets untested and `_shown` mutates state in build — grouped with the edge-case/verification findings below.
  - `[low]` `[reject]` (blind) Blank strings (chip, vet, pet, practitioner) not trimmed — the server sends null for missing values; whitespace-only values are not produced.
  - `[false]` `[reject]` (blind) Avatar colours depend on list position — the kit's documented rule (`AvatarTone.forPetIndex`, « keyed on the pet's position in its clinic's list »).
  - `[low]` `[reject]` (blind) « · » joins assembled in Dart — punctuation between ARB strings, the documents precedent.
  - `[false]` `[reject]` (blind) Docs: architecture.md lacks the shared vocabulary rule — architecture.md §3 already says « what several domains share belongs in `shared/domain/` »; CONTRIBUTING §0 is updated with the merge.
  - `[medium]` `[patch]` (edge) Re-entering the same `/pets/:petId` after a switcher pick shows the switched pet — `PetPage.request` (route `extra`, a new object per `_goPet`) resets the choice; tests added.
  - `[low]` `[patch]` (edge) A refresh adding/removing a pet in the same clinic drops the switcher choice — `_listIds` removed (a missing selection falls back already).
  - `[low]` `[reject]` (edge) Android system back on a pet page at the branch root leaves the app — same as every tab root; a `PopScope` would diverge from the other tabs.
  - `[low]` `[patch]` (edge) `/pets` 404 retry does not re-read `/me` — same fix as the blind finding above.
  - `[low]` `[reject]` (edge) A next page with no items and the same cursor loops — the server's cursor always advances (contract); same as slice 2's list.
  - `[low]` `[patch]` (edge) A future birth date reads « Moins d'un mois » — `petAgeLabel` returns null, test added.
  - `[false]` `[reject]` (edge) 29 February birthdays count « 11 mois » on 28 February — the birthday is not reached yet in a non-leap year (same convention as the year count).
  - `[low]` `[reject]` (edge) App open across midnight keeps yesterday's countdowns — any rebuild or pull-to-refresh recomputes; a midnight timer adds state for a rare case.
  - `[low]` `[reject]` (edge) Whitespace chip/vet → blank cell — grouped with the blank-strings rejection.
  - `[low]` `[reject]` (edge) Whitespace pet/practitioner names in the hero — grouped with the blank-strings rejection.
  - `[low]` `[reject]` (edge) The switcher sheet with `/me` loading or failed shows an empty card — the sheet opens only from a loaded header; a reload while it is open is fleeting.
  - `[low]` `[patch]` (edge) `screenPetsTitle` / `screenPetTitle` orphaned in the ARB — deleted, l10n regenerated.
  - `[low]` `[reject]` (edge) `PlaceholderKind.pushed` has no user left — kept for the pages later slices push inside a tab.
  - `[medium]` `[patch]` (edge) Claim « tapping a pet card shows that pet » broken after a switcher pick — same fix as the re-entry finding.
  - `[low]` `[reject]` (edge) No client widget test of the sheet outside the home — the sheet is reached only from the home, whose tests drive it.
  - `[medium]` `[patch]` (verification-gap) Session change not verified for the home and the pet providers — « another session » tests with bearer-dependent replies added.
  - `[medium]` `[patch]` (verification-gap) PetPage reset on a new route `petId` not verified — tests added with the re-entry fix.
  - `[low]` `[patch]` (verification-gap) Loading during a retry not verified (home, pet page, timeline) — in-flight tests added.
  - `[low]` `[patch]` (verification-gap) Timeline empty first page with a cursor not verified — test ported from documents.
  - `[low]` `[patch]` (verification-gap) Switcher button accessible name not verified — semantics assertions added.
  - `[low]` `[patch]` (verification-gap) `homeDocumentTile` / `homeDocumentMeta` not pinned — pure tests added.
  - `[low]` `[patch]` (verification-gap) Odd pet count ≥ 3 not verified — 3-pet home test added.
  - `[low]` `[reject]` (verification-gap, other) Home and Documents disagree on deceased pets' names — same as the blind rejection above.
  - `[low]` `[patch]` (verification-gap, other) Any id-set change drops the switcher choice — same fix as the edge finding (`_listIds` removed).

## Design Notes

**Look (exact values from the mockups):** home body padding 20 20 8, gap 18, Bg canvas; header column gap 4 (clinic 13/600 `#5f5f73` + chevron 16 gap 4; greeting 26/700 −0.02em). Hero C-27: `#4338ca`, radius 14, padding 18, gap 14; overline 12/600 0.06em uppercase `#e0e1ff`; pill 12/600 white on `#5b51e0` padding 4 10; date 22/700; detail 15 `#e0e1ff`, gap 4; actions gap 10 (questionnaire white `expand`, « Gérer » outline `#8b84f0` padding 0 16). Sections column gap 10; pet cards gap 10, padding 12, radius 12, border, avatar 44 + name 15/700 + meta 12 muted gap 2, row gap 12. Pet page body 16 20 20, gap 20; top row back (margin-left −10) / switcher / 34 px; header gap 16, avatar 64, name 26/700, line 14 muted, gap 4; grid cells padding 14, label 12 muted + value 15/600 gap 2, inner dividers `#efeff5` (right on the left column, bottom on the first row), weight date 12/500 muted; report button C-4b full width + caption 12 centred, gap 6; care rows padding 13 14; « Carnet PDF » C-6a centred with the h2. Timeline C-32: rail 12 wide (dot 12, margin-top 4; line 2 `#e0e0ea` fills the item; none after the last), gap 14; content gap 6, padding-bottom 18 (none on the last); date line 12/600 muted, title 15/700, chips wrap gap 8, « Aucun document partagé » 13 muted.

**FLAG decisions (orchestrator):** bell hidden; 1 pet full width, ≥ 3 two per row wrapping; a document row opens the file directly; questionnaire button only when `not_started`; `overdue` → danger pill « En retard »; `upToDate` within 60 days → neutral countdown, beyond → « À jour »; « Signaler une modification » is an entry point with a placeholder sheet (slice 6); deceased/missing pets stay in the switcher with a neutral pill (« Décédé »/« Décédée », « Disparu »/« Disparue » by sex), the care list is then empty by the server.

**Header line of the pet:** species label · breed · sex/sterilization (« Mâle castré », « Femelle stérilisée », « Mâle », « Femelle », unknown sex + neutered « Stérilisé », else dropped); unknown species dropped. Ages (plurals): years ≥ 1 « {n} an(s) », else months ≥ 1 « {n} mois », else « Moins d'un mois »; null birth date → species only. Weight: grams / 1000 with `#,##0.##` fr_FR + ARB « {value} kg ».

**Strings (ARB, French):** home: « Prochain rendez-vous », « Confirmé », « En attente », « Remplir le questionnaire », « Gérer », « Mes animaux », « À prévoir », « Échéances de soins », « Prendre rendez-vous », « Derniers documents », « Tout voir », « Avant le {date} », « {pet} — {label} », « Clinique indisponible » / « Votre accès à cette clinique n'est plus actif. », the switcher button label « Changer de clinique, actuellement {name} ». client: « Changer de clinique », « Active ». patient: species « Chien », « Chat », « NAC », « Autre »; the sex/life labels; « Né le », « Née le », « Poids », « Puce », « Suivi par », « — », « {value} kg », ages; « Signaler une modification », « Vérifiée par la clinique avant mise à jour de la fiche. », « Vaccins et préventions », « Carnet PDF », « Carnet de vaccination · {name} », « Aucun soin préventif à suivre. », « Aucun animal » / « Les animaux suivis par {clinic} apparaîtront ici. », switcher semantics « Animal »; care: « RDV pris », « En retard », « À jour », « Aujourd'hui », « Demain », « Dans {n} j », « Dans {n} sem. », « Fait le {done} · prochain avant le {due} », « À faire depuis le {due} », « Prochain avant le {due} », « Valide jusqu'au {due} ». timeline: « Historique », « Aucun document partagé », « Aucune consultation partagée pour le moment. », « Impossible de charger la suite. ». documents: kind names « Compte-rendu », « Ordonnance », « Facture », « Résultats », « Certificat », « Document ».

**Timeline notifier (golden shape, from `DocumentListNotifier`):**
```dart
Future<PetTimelineState> build() async {
  ref.watch(sessionStatusProvider);
  final repository = ref.watch(timelineRepositoryProvider);
  final clinicId = await ref.watch(activeClinicProvider.selectAsync((c) => c?.clinicId));
  if (clinicId == null) return const PetTimelineState.empty();
  final page = await repository.timeline(clinicId, petId);
  return PetTimelineState(clinicId: clinicId, items: page.items, nextCursor: page.nextCursor);
}
```

**Routes:** `/pets` and `/pets/:petId` are siblings in the Animaux branch (a `go` from the home does not stack a first-pet page under the chosen one); the pet page's selection is local state initialised from the route and reset when the route's id or the clinic's pet list changes.

## Verification

**Commands:**
- `fvm flutter gen-l10n` -- expected: `lib/l10n/app_localizations*.dart` regenerated, no diff left after `make format`.
- `make ci` -- expected: `make ci passed` (format-check, analyze, test-architecture, test-coverage, coverage-gate 100 % on gated files, test-scripts, api-check).

**Manual checks (if no CLI):**
- `git grep -n "flutter/material.dart" lib test` -- expected: nothing. `git grep -n "HomePlaceholderPage"` -- expected: nothing.

## Auto Run Result

**Summary:** Slice 3 on the D15 layout. `home` (screen 1 on `PetsApi.getHome`: header with the active clinic and the switcher, hero, pet cards 1 / 2-per-row, « À prévoir » with the care pills and « Prendre rendez-vous », « Derniers documents » opening the file), `patient` (screen 2 on `listPets` / `getPet` / `listPetCareItems` and the booklet through the downloader: scrollable pet switcher, header, identity grid, « Signaler une modification » entry point, care items, « Carnet PDF »), `consultation` (the paginated « Historique » sliver on `getPetTimeline`, document chips opening the file), the clinic switcher sheet in `client`, `CareStatus` / `Species` / `DocumentKind` / `PaymentStatus` in `shared/domain`, routes `/home`, `/pets`, `/pets/:petId` (siblings) with their exits, a placeholder sheet for the change request (slice 6). Backend fix `bcb8d8b1` (`booked` in the care-item schemas) synced in `d26799d`; 19 live captures in `950672a`.

**Files changed:**
- `lib/shared/domain/{care_status,species,document_kind,payment_status}.dart` — the shared vocabulary (the last two moved from document's domain; `document.dart` re-exports them).
- `lib/features/patient/**` — domain (`PetId`, `PetSummary`, `Pet`, `PetWeight`, `CareItem`, `PetRepository`), `PortalPetRepository`, DI, `PetPage`, providers, French helpers (care pill, sub-lines, countdown, age, weight, labels, `deviceToday`).
- `lib/features/consultation/**` — timeline domain, `PortalTimelineRepository`, DI, `petTimelineProvider`, `PetTimelineSection`.
- `lib/features/home/**` — `HomeOverview` read model, `PortalHomeRepository`, DI, `HomePage` and its widgets.
- `lib/features/client/presentation/clinic_switcher_sheet.dart`, `client.dart` — `showClinicSwitcherSheet`.
- `lib/features/document/**` — imports of the moved enums; `documentKindName`, `joinPetNames`, `paymentLabel` exported.
- `lib/app/routing/{app_router,placeholder_page}.dart` — routes, exits, `showPlaceholderSheet`; `home_placeholder_page.dart` deleted.
- `lib/shared/presentation/{formatters/kiveto_format,kit/surfaces}.dart` — `dayMonthYearLong`; `KivetoListRow.padding`.
- `lib/l10n/app_fr.arb` (+ generated) — the slice's strings; `screenPetsTitle` / `screenPetTitle` removed.
- Tests: unit (patient, consultation, home on the captures), widget (home, latest documents, pet page, pet messages, timeline, home flow through the real router), updated app / router / document / formatter tests.

**Review:** 53 findings (intent 11, blind 18, edge 15, verification-gap 9): 19 rows patched in one round (care sub-lines per the intent, home skeleton, switcher scrolled to the selection, `/pets` 404 retry re-reads `/me`, hero title read once, re-entering a pet from the home resets the switcher's choice via the route `extra`, no state mutation in build, future birth date, orphan ARB keys, and the missing tests: second session, retry in flight, empty first timeline page with a cursor, switcher accessible name, home tiles and meta, 3-pet home); 2 deferred (header blink while `/me` reloads; the switcher's small tap target and the back button's dead strip); 32 rejected with their reasons in the triage log.

**Follow-up review recommended: true.** Patched entries by verdict: medium 4 (care sub-lines, switcher scroll, re-entry/selection reset, second-session verification), low 15. Unverified risk: the re-entry fix relies on go_router keeping the `/pets/:petId` page State across `go`s and on a fresh `extra` per home tap; other entries into a pet (a future push from another tab, a deep link, the Animaux tab reselect) were not re-reviewed after the patch.

**Verification:** `fvm flutter gen-l10n` (no diff after); `make ci` green twice (before review 3 min 15 s; after the patches 3 min 15 s: format, analyze, architecture, coverage + gate 100 % on the gated files, scripts, api-check); `git grep` finds no `flutter/material.dart` and no `HomePlaceholderPage`. Matrix audit: every matrix row has a passing widget or unit test.

**Residual risks:** no emulator walk inside this run (the caller walks it); iOS not built; « today » is the device's date (the clinic's zone is not known on the device); the timeline reloads from page 1 on every `cursor_invalid` (a server answering it forever would loop, as slice 2); the backend fix `bcb8d8b1` sits on the backend branch `fix/portal-care-item-booked-status` (not merged into the backend's master: the merge was refused by the permission system).
