---
title: 'Slice 2 — document: screen 5 « Documents publiés », the in-app PDF viewer, the prescription detail'
type: 'feature'
created: '2026-11-03'
status: 'done'
baseline_revision: 'b6706f88f506010baf51dd0ee011d60ea76447d1'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '{project-root}/CLAUDE.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-app-shell.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/notes-identity-access.md'
  - 'C:/Users/djami/AppData/Roaming/Claude/side-session-notes/local_d4dc2016-f681-4c72-9554-dcd0ab1b9b14/mockup/05.html'
warnings: ['oversized']
deferred:
  - summary: >-
      After screen 17 (slice 6) sends a renewal request, nothing refreshes the documents lists, so the card keeps « Demander un renouvellement » until a pull-to-refresh.
    evidence: |-
      Blind-hunter, maybe-false until slice 6 exists (screen 17 is a placeholder): the router discards the push future of `onRequestRenewal`; settle it when slice 6 builds the request (expose a refresh from document.dart). Recorded in deferred-work.md.
    location: >-
      lib/app/routing/app_router.dart (documents route)
    severity: medium (unverified)
  - summary: >-
      pdfrx's native-assets hook downloads the PDFium archive without a checksum on every first build (flutter test included); CI cache and iOS build unverified.
    evidence: |-
      Blind-hunter, verified: pdfium_dart-0.4.1/hook/build.dart checks only the HTTP status. Prerequisites now documented (CONTRIBUTING §5, pubspec comment); the supply-chain decision and the CI cache are recorded in deferred-work.md.
    location: >-
      pubspec.yaml (pdfrx)
    severity: medium
---

<intent-contract>

## Intent

**Problem:** The Documents tab (screen 5) is a placeholder: an owner cannot see the reports, prescriptions and invoices the clinic shared, open them, see a prescription's lines or ask for a renewal, and the unread badge never goes down. Slice 3 (home « Derniers documents », vaccination booklet) and slice 6 (screen 17) need a reusable file opener and the prescription read.

**Approach:** Build `lib/features/document/` (domain, infrastructure on `DocumentsApi` + `PetsApi.listPets` + `portalFileDownloaderProvider`, presentation) with the mockup-05 list (filter chips, C-30 cards, cursor pagination), an in-app PDF viewer on `pdfrx` 2.11.0 pushed on the root navigator, a prescription detail sheet (`getPrescription`) with the renewal control, and `ref.invalidate(meProvider)` after each successful download so the badge refreshes.

## Boundaries & Constraints

**Always:**
- D15 layers, rules 1–8 (`test/architecture/`); 100 % line coverage of every new file of `features/document/{domain,application,infrastructure}` and `shared/domain`; `make ci` green. Read-only screen: providers call the repository; no pass-through use case (no `application/` folder unless something orchestrates).
- material_ui only (`package:material_ui/material_ui.dart`); Dart 3.13 constructors (`const new(...)`); no `print`, no `DateTime.now()` in domain.
- French user strings only in `lib/l10n/app_fr.arb`, keys `documents…` with `@key.description`, then `fvm flutter gen-l10n`. Code/comments/docs English.
- Files go through `portalFileDownloaderProvider` (`download('/api/portal/v1/clinics/$c/documents/$id/file')`), wrapped by the feature's infrastructure (presentation never imports `core/network`).
- Account scoping: list/pet-name providers `ref.watch(sessionStatusProvider)` directly and watch only the active clinic **id** (`activeClinicProvider.selectAsync((c) => c?.clinicId)`); providers read via `AsyncData` patterns / `AsyncValueView`, never `.value`.
- Mockup 05 decides the look (exact styles: body padding 20 20 16, gap 16; chips C-13a wrap gap 8; cards gap 8; C-30 card padding 12 14 radius 12, 40×40 tile radius 10 text glyph 12/700, title 14/700, meta 12 `#5f5f73`, gap 2, wraps; trailing C-9e; C-4c below); the contract decides the data.
- `pdfrx: 2.11.0` (already in `pubspec.yaml`/`pubspec.lock` on the branch, exact pin) — document the check in the pubspec comment (latest, espresso3389.jp, 160/160 points, ~610 k downloads/30 d, `sdk ^3.13.0`, `flutter >=3.47.0`, depends on `material_ui ^1.0.0`, imports only material_ui; native-assets hook builds a C gate and downloads PDFium chromium/8125 at build time; pdfx rejected: re-exports photo_view 0.15.0, unmaintained since 2024-04, which imports `flutter/material.dart`).

**Never:**
- Edit `packages/kiveto_portal_api/`, `contracts/`, `CLAUDE.md`, `.claude/settings.json`; import `package:flutter/material.dart`; import `app/` from a feature; call the generated `getDocumentFile` / `FilesApi.download*`.
- Re-implement backend rules (renewability, 7-day refusal, quotas): `renewable` and `renewalStatus` decide what shows; screen 17 (slice 6) gets the 422.
- Build screen 17 (the renewal route stays the placeholder), the clinic switcher, the home, a `petId` filter, saving/sharing the PDF outside the app (deferred-work).

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Julien Paris | `clinics.paris.documents.get.200.json` + pets `clinics.paris.pets.get.200.json` | 2 invoice cards « Facture PAR-2026-000067 » meta « 52,00 € · Payée · 24 oct. »; the first has the unread dot | — |
| Empty | Lyon `{"items":[],"nextCursor":null}` | « Aucun document » + « Les documents partagés par Clinique Vétérinaire de Lyon apparaîtront ici. » | — |
| Pagination | Garnier page 1 → `?cursor=<p1.nextCursor>` → page 2 → page 3 (`nextCursor: null`) | 20, 40, 51 cards; no further request after page 3 | next page fails → items kept + « Impossible de charger la suite. » + « Réessayer »; `400 cursor_invalid` → reload from page 1 |
| Filter | tap « Ordonnances » | request `?type=prescription`; 5 cards; « Tous » back → the all list (kept per filter) | per-filter empty title (« Aucune ordonnance »…) |
| Report / prescription meta | report petIds [Pepito]; ORD-36 validUntil 2027-11-02 | « Pepito · 31 août 2026 »; « Pepito · valable jusqu'au 2 nov. 2027 » | unknown pet id / names call failed → meta without names |
| Invoice | Garnier PAR-2026-000025 (unpaid, 9600 EUR, 31 Aug); PAR-2026-000022 (`petIds: []`) | « 96,00 € · Non payée · 31 août » (invoices never show pet names) | `paymentStatus` unknown → no status piece |
| Renewal | renewable + `renewalStatus` null / rejected / closed | C-4c « Demander un renouvellement » → `onRequestRenewal(context, prescriptionId)` | — |
| Renewal open/done | `{status: submitted}` / `{status: done, …}` | neutral pill « Renouvellement demandé » / success pill « Renouvellement traité », no button | unknown status / malformed map → treated as null (button if renewable) |
| Open file | tap C-9e or a non-prescription card | full-screen viewer over the nav: back + title, PDF; then `meProvider` invalidated, row dot removed | 404 → « Document indisponible » / « Ce document a été retiré ou n'est pas encore prêt. Réessayez plus tard. »; other → `ErrorView` + retry |
| Prescription detail | tap a prescription card | sheet « Ordonnance du 22 déc. 2025 », « Dr Rousseau · Oscar », line « Meloxidyl 1 mg/mL suspension buvable » / « Qté 2 · 0,1 mg/kg, 1×/j, pendant 60 jours, voie per os », « Voir l'ordonnance », renewal control | 404 → « Ordonnance indisponible » / « Cette ordonnance n'est plus disponible. » |
| Link gone | list 404 `not_found` | « Documents indisponibles » / « Votre accès aux documents de cette clinique n'est plus actif. » | retry invalidates `meProvider` and the list |

</intent-contract>

## Code Map

- `lib/core/network/portal_file_downloader.dart` -- `PortalFileDownloader.download(apiPath)` → `DownloadedFile(Uint8List bytes, contentType, fileName)`; throws `ApiFailure`. Read-only.
- `lib/core/di/core_providers.dart` -- `portalServerProvider`, `apiFailureMapperProvider`, `portalFileDownloaderProvider`, `sessionStatusProvider` (+ re-exported `SessionStatus`). Read-only.
- `lib/core/network/portal_results.dart` -- `apiFailureOf(result, failures)`, `clinicInstantOf(DateTime)`, `localDateOf(Date)`.
- `lib/features/client/infrastructure/portal_me_repository.dart`, `lib/features/client/di.dart`, `lib/features/client/client.dart` -- repository/DI/public-API patterns to copy; `meProvider`, `activeClinicProvider` (`ClinicLink.clinicId`, `.name`). `ActiveClinicNotifier.select` for clinic switching in tests.
- `packages/kiveto_portal_api` (read-only): `DocumentsApi.listDocuments({clinicId, cursor, limit, kind: ApiPortalV1ClinicsClinicIdDocumentsParametersModel})` → `ListDocumentsResponse200(body: DocumentList{items, nextCursor})`; `DocumentView{id, kind: DocumentViewTypeModel(report|prescription|invoice|labResult|certificate|unknown), title, petIds, issuedAt (OffsetDateTime), unread, invoice?.invoiceSummaryView{total: MoneyView{amount, currency}, paymentStatus: InvoiceSummaryViewPaymentStatusModel(unpaid|partiallyPaid|paid|credited|unknown)}, prescription?.prescriptionSummaryView{id, validUntil: Date?, renewable, renewalStatus: Map<String,Object?>?}}`; `DocumentsApi.getPrescription({clinicId, prescriptionId})` → `GetPrescriptionResponse200(body: Prescription{id, issuedAt, vet, pet: PetReferenceView{id?, name}, lines: [PrescriptionLineView{label, quantity, posologySummary}]})`; `PetsApi.listPets({clinicId})` → `ListPetsResponse200(body: List<PetSummary{id, name, …}>)`.
- `lib/app/routing/app_router.dart` -- Documents branch `_page(AppRoutes.documents, …, routes: [fullScreen('prescriptions/:prescriptionId/renewal', …)])`: replace the documents builder only; `AppRoutes.prescriptionRenewal(id)` in `app_routes.dart`.
- `lib/app/bootstrap/feature_overrides.dart` -- `unreadDocumentsCountProvider` already reads `activeClinicProvider` → `unreadDocuments`: nothing to add, the refresh comes from invalidating `meProvider`.
- Kit (`lib/shared/presentation/`): `KivetoPageHeader(title, subtitle:)`, `KivetoFilterChip(label, selected, onSelected)`, `KivetoLeadingTile(colors: KivetoColorSets.indigo|orange|green|neutral, text:, glyph:, size: 40)`, `KivetoIconButton.squareMuted(glyph: LucideGlyph.download, semanticLabel:, onPressed:)`, `KivetoIconButton.back`, `KivetoButton.outlineBrand(label:, onPressed:, expand:)` (C-4c), `KivetoButton.primary/outline`, `StatusPill(label, tone: StatusTone.neutral|success)`, `KivetoCard`, `KivetoCard.list`, `KivetoListRow`, `showKivetoSheet` + `KivetoSheet(title:, subtitle:, children:)`, `KivetoColors.*`, `KivetoText.*`/`kivetoTextStyle`, `AsyncValueView`, `LoadingView`, `ErrorView(error:, onRetry:, title:, message:)`, `EmptyState(glyph: LucideGlyph.fileText, title:, body:)`, `KivetoFormat.dayMonthYear/dayMonth/money`.
- `lib/features/identity_access/presentation/identity_messages.dart:46` -- `joinNames` pattern (« A, B et C » via `{head} et {last}`); copy the idea, do not import.
- `lib/shared/domain/{clinic_id,clinic_instant,local_date,money,api_failure}.dart` -- `ClinicId`, `ClinicInstant.date`, `LocalDate`, `Money`, `NotFoundFailure`, `BusinessFailure(code: 'cursor_invalid')`.
- Tests: `test/support/fakes.dart` (`pumpPage(tester, page, backend:, session:, overrides:, prepare:)`, `pumpKivetoApp(...)`, `memorySession(pair('A'))`, `InMemoryActiveClinicStore`, `pumpBriefly`), `test/support/portal_api/portal_http_harness.dart` (`PortalHarness.create(tokens: pair('A'))`, `api` = `/api/portal/v1`, `devConfig`), `test/support/portal_api/fake_portal_backend.dart` (`backend.on(method, pathWithQuery, PortalReply.fixture/json/empty/bytes)`, `backend.requestsTo(path)`), `test/unit/core/network/portal_file_downloader_test.dart` (302 + bytes pattern), `test/unit/features/client/infrastructure/client_infrastructure_test.dart` (repository-on-captures pattern).
- Fixtures already on the branch (`test/support/fixtures/portal_api/`): `clinics.paris.documents.garnier{,-page2,-page3}.get.200.json`, `clinics.paris.documents.prescriptions.get.200.json`, `clinics.paris.documents.cursor-invalid.get.400.json`, `clinics.paris.prescriptions.get.200.json`, `clinics.paris.prescriptions.not-found.get.404.json`, `clinics.paris.pets.garnier.get.200.json`, `files.documents.get.200.pdf`; existing `clinics.{paris,lyon}.documents.get.200.json`, `clinics.paris.pets.get.200.json`, `me.get.200.json`.
- `test/widget/app/routing/app_router_test.dart` -- « every placeholder route builds » lists `/documents`: move it out (it is a real page now) and assert the page instead.

## Tasks & Acceptance

**Execution:**
- `.gitattributes` -- add `*.pdf binary` -- the PDF fixture's xref offsets need exact bytes.
- `pubspec.yaml` -- comment block above `pdfrx: 2.11.0` with the checks above -- CLAUDE.md §7 trace, like slice 1.
- `lib/shared/domain/portal_file.dart` -- `PortalFile(List<int> bytes, {String? contentType, String? fileName})` -- pure-Dart file value shared by document, patient (booklet) and client (export).
- `lib/features/document/domain/` -- `document.dart`: `extension type const DocumentId(String value)`, `PrescriptionId`; `enum DocumentKind {report, prescription, invoice, labResult, certificate, unknown}`; `Document{id, kind, title, petIds: List<String>, issuedAt: ClinicInstant, unread, invoice: InvoiceSummary?, prescription: PrescriptionSummary?}` with `markedRead()`; `InvoiceSummary{Money total, PaymentStatus}`; `enum PaymentStatus {unpaid, partiallyPaid, paid, credited, unknown}`; `PrescriptionSummary{id, LocalDate? validUntil, bool renewable, RenewalRequest? renewal}`; `RenewalRequest{RenewalStatus status, String? requestId, String? resultingPrescriptionId}`; `enum RenewalStatus {submitted, done, rejected, closed, unknown}`; `DocumentPage{items, String? nextCursor}`. `prescription.dart`: `Prescription{id, issuedAt, vet, PetReference pet{String? id, String name}, lines: List<PrescriptionLine{label, quantity, posologySummary}>}`. `document_repository.dart`: `documents(ClinicId, {DocumentKind? kind, String? cursor})`, `prescription(ClinicId, PrescriptionId)`, `file(ClinicId, DocumentId) → PortalFile`. `pet_name_repository.dart`: `petNames(ClinicId) → Map<String, String>` -- the domain of the slice.
- `lib/features/document/infrastructure/portal_document_repository.dart` -- on `DocumentsApi` + `PortalFileDownloader`; maps every enum (`unknown` kept), `invoice?.invoiceSummaryView`, `prescription?.prescriptionSummaryView`, `renewalStatus` map (`status` string → enum, non-string/missing → `unknown`; null map → null), `issuedAt` via `clinicInstantOf`, `validUntil` via `localDateOf`; filter `kind` → `ApiPortalV1ClinicsClinicIdDocumentsParametersModel` (`unknown` / `certificate` allowed). `portal_pet_name_repository.dart` -- on `PetsApi.listPets`. Both throw `apiFailureOf(...)` -- generated DTOs stay here.
- `lib/features/document/di.dart` -- `documentRepositoryProvider`, `petNameRepositoryProvider`.
- `lib/features/document/presentation/` -- `documents_providers.dart`: `documentListProvider` (`AsyncNotifierProvider.family<DocumentListNotifier, DocumentListState, DocumentKind?>`, state = items + nextCursor + loadingMore + moreError; `loadMore()`, `markRead(DocumentId)`, cursor_invalid → `ref.invalidateSelf()`), `documentPetNamesProvider` (failure → empty map), `prescriptionProvider` (family on (ClinicId, PrescriptionId)). `documents_page.dart`: `DocumentsPage({required void Function(BuildContext, String prescriptionId) onRequestRenewal})`. `document_card.dart` (C-30 + meta + dot + renewal control). `prescription_sheet.dart`. `pdf_file_page.dart`: `PdfFilePage(title, load: Future<PortalFile> Function(WidgetRef), onLoaded: void Function(WidgetRef)?)` + `pdfViewBuilderProvider` (default `PdfViewer.data(Uint8List, sourceName: unique)`; tests override) + `openDocumentFile(context, {clinicId, documentId, title, VoidCallback? onRead})` and `openPdfFile(context, {title, load})` pushing on `Navigator.of(context, rootNavigator: true)`. `document_messages.dart`: meta builders, kind/payment/renewal labels, `joinPetNames`.
- `lib/features/document/document.dart` -- export the domain models, `DocumentsPage`, `openDocumentFile`, `openPdfFile`, `prescriptionProvider`, `PortalFile` re-export not needed (shared).
- `lib/app/routing/app_router.dart` -- `/documents` builds `DocumentsPage(onRequestRenewal: (context, id) => context.push(AppRoutes.prescriptionRenewal(id)))` keeping the renewal sub-route placeholder.
- `lib/l10n/app_fr.arb` (+ gen-l10n) -- strings: « Partagés par {clinic} », chips « Tous / Comptes-rendus / Ordonnances / Factures / Résultats » (+ group label « Filtrer par type »), glyphs « CR / Rx / € / Lab / Cert », « valable jusqu'au {date} », « Payée / Non payée / Partiellement payée / Avoir », « Ouvrir le document », « Nouveau », « Demander un renouvellement », « Renouvellement demandé », « Renouvellement traité », empty titles/body, « Impossible de charger la suite. », « Documents indisponibles » + body, viewer « Document indisponible » + body, « Impossible d'afficher ce document. » (PDF render error), sheet « Ordonnance du {date} », « Qté {quantity} · {posology} », « Voir l'ordonnance », « Ordonnance indisponible » + body, `documentsNamesAnd` « {head} et {last} ».
- `test/unit/features/document/domain/document_domain_test.dart`, `test/unit/features/document/infrastructure/portal_document_repository_test.dart`, `…/portal_pet_name_repository_test.dart`, `test/unit/shared/domain/portal_file_test.dart` (or in an existing shared test) -- 100 % on the captures (every I/O row of the infrastructure, the 302 + PDF bytes through `PortalHarness`, `?type=` and `?cursor=` query strings, 400/404, network failure).
- `test/widget/features/document/documents_page_test.dart`, `prescription_sheet_test.dart`, `pdf_file_page_test.dart` -- the matrix rows on the fake backend with a fake PDF view; badge: through `pumpKivetoApp` (Julien `me.get.200.json` → badge `1`; after opening the unread invoice the next `/me` answers `unreadDocuments: 0` → `unreadDocumentsCountProvider` 0); clinic switch (`activeClinicProvider.notifier.select`) reloads the list for Lyon.
- `test/widget/app/routing/app_router_test.dart` -- adapt the placeholder test.

**Acceptance Criteria:**
- Given Julien signed in on Paris, when he opens the Documents tab, then the header reads « Documents » / « Partagés par Clinique Vétérinaire de Paris » and both invoices show with their totals, « Payée » and dates.
- Given the unread invoice, when he opens it and the PDF shows, then `GET …/documents/{id}/file` was sent, `/me` is fetched again and the nav badge follows its new `unreadDocuments`, and the row has no dot.
- Given the active clinic switches to Lyon, when the page rebuilds, then `GET /clinics/<lyon>/documents` is sent and the empty state names the Lyon clinic.
- Given `make ci`, when it runs on the branch, then it is green (format, analyze, architecture, coverage 100 % gated, scripts, api-check).

## Spec Change Log

## Review Triage Log

### 2026-11-03 — Review pass
- verdicts: 46 findings — high 0, medium 16, low 24, false 2, maybe-false 4
- findings:
  - `[medium]` `[patch]` (blind) The list never refreshes; a document published after the first load never shows while the `/me` badge counts it; the intent asked for pull-to-refresh (lost in the spec) — RefreshIndicator invalidating the list family, the pet names and `/me`, with a test.
  - `[low]` `[patch]` (blind) Pet names are only requested once the documents answered (two round trips in a row) — the page watches `documentPetNamesProvider` at the top of `build()`.
  - `[medium]` `[patch]` (blind) A pet-names failure is cached as `{}` for the session; the page's `AsyncError` branch is dead — the provider lets the error through; `_retry` and pull-to-refresh invalidate it; test added.
  - `[low]` `[reject]` (blind) `DocumentKind.unknown` as a filter fails as a `ServerFailure` — no caller passes it (the chips are report/prescription/invoice/lab_result), the generated client refuses it before any request; a narrower type adds surface for nothing.
  - `[low]` `[reject]` (blind) The server counts the read on the 302 request, the app only after the PDF arrived — only a back-out within the sub-second download leaves the dot and badge stale until the next `/me`; splitting the downloader is more than a direct correction.
  - `[low]` `[reject]` (blind) `/me` is read again on every open, even of a read document, and the header subtitle blanks while it reloads — the reload runs under the full-screen viewer; one cheap GET per open.
  - `[medium]` `[patch]` (blind) pdfrx's native hook (C toolchain, PDFium download, no checksum) undocumented — CONTRIBUTING §5 prerequisite row and pubspec comment; the checksum / CI cache / iOS decision deferred (frontmatter `deferred`, deferred-work.md).
  - `[maybe-false]` `[defer]` (blind) Nothing refreshes the lists after a renewal request (screen 17) — screen 17 is a placeholder until slice 6; if true medium; deferred-work.md entry for slice 6.
  - `[false]` `[reject]` (blind) The viewer ignores the content type; a non-PDF would get the generic error — the contract serves `application/pdf` only on `/files/documents/…`; `contentType` / `fileName` serve the later export (zip).
  - `[low]` `[reject]` (blind) Renewal outcomes mapped but not shown (`rejected` looks like no request; `requestId` / `resultingPrescriptionId` unused) — the orchestrator's FLAG decision: `rejected` / `closed` → the button; the intent asks the object mapped.
  - `[low]` `[reject]` (blind) Wildcard switches in `filterLabel` / `emptyTitle`; no certificate chip — certificates are reserved in v1 and the mockup has no chip; the switches only take the five filters.
  - `[medium]` `[reject]` (blind) Invoice dates without the year — the intent and mockup 05 ask `dayMonth` for invoices; recorded as a design question in deferred-work.md.
  - `[low]` `[reject]` (blind) An expired prescription reads « valable jusqu'au <past date> » — the intent's wording, still factual; no client-side date rule.
  - `[medium]` `[patch]` (blind) Every open button is announced « Ouvrir le document » — `documentsOpen` takes the title (« Ouvrir {title} »).
  - `[low]` `[reject]` (blind) `joinPetNames` / `documentsNamesAnd` copy slice 1's helper; « · » separator hard-coded — features may not import each other; moving slice 1's helper to shared is a cross-slice refactor; the separator is punctuation.
  - `[low]` `[patch]` (blind) Test gaps: the ORD-36 sheet test serves ORD-05's body; stale `loadMore`, dot after « Voir l'ordonnance », real `_pdfrxView` untested — ORD-36 capture added (`clinics.paris.prescriptions.renewable.get.200.json`); the other gaps are the verification-gap patches below.
  - `[low]` `[patch]` (blind) Deferred items and the manual check not recorded — deferred-work.md slice 2 section; the walk is recorded under Auto Run Result.
  - `[medium]` `[patch]` (verification-gap) Account scoping on a session change untested (removing the `sessionStatusProvider` watch fails nothing) — test: `session.open(pair('B'))` reloads with `Bearer B`, A's items gone.
  - `[medium]` `[patch]` (verification-gap) The `built.mounted` guard of `loadMore` untested — test: a held page 2 answering after a switch to Lyon is dropped.
  - `[medium]` `[patch]` (verification-gap) The dot of an unread prescription after « Voir l'ordonnance » from its sheet untested — test on ORD-36.
  - `[medium]` `[patch]` (verification-gap) The real pdfrx view and its French error banner never run — test builds the default view and its `errorBannerBuilder`.
  - `[low]` `[patch]` (verification-gap) Retry in flight (loading, no second « Réessayer ») untested on the list and the sheet — tests with a held reply.
  - `[medium]` `[patch]` (verification-gap, other) A failed pet-names request is never retried — same root cause and patch as the pet-names caching row.
  - `[low]` `[reject]` (edge) A `/me` refresh failing right after a successful download turns every list into an error screen — the network just answered; the retry restores it; a guard keeping the last clinic adds state.
  - `[medium]` `[patch]` (edge) Errors through `selectAsync` arrive as `ProviderException`, so a `/me` network failure reads « Une erreur est survenue » — `failureMessage` / `ErrorView` unwrap it (shared async views), test added.
  - `[low]` `[reject]` (edge) Header subtitle and empty-state body vanish while `/me` reloads — same as the `/me`-on-every-open row; under the viewer, or during a pull-to-refresh spinner.
  - `[maybe-false]` `[reject]` (edge) The server answers `cursor_invalid` again for a fresh cursor → endless reload — would need a backend bug; if true low (the user can leave the tab); a once-flag adds state.
  - `[false]` `[reject]` (edge) A next page returning the cursor just sent loops — the backend's cursor is `(issued_at, id)` of the last row, it always advances.
  - `[medium]` `[patch]` (edge) A first page with no items but a `nextCursor` (rows not listable any more are left out, README) shows the empty state and stops — empty state only when `nextCursor` is null too; test added.
  - `[medium]` `[patch]` (edge) A pet-names blip is cached for the session — same as the pet-names caching row.
  - `[medium]` `[patch]` (edge) The list never refetches — same as the pull-to-refresh row.
  - `[low]` `[reject]` (edge) A currency that is not three upper-case letters makes `Money` throw `ArgumentError` — the backend sends ISO 4217 codes (`EUR`); `Money`'s check is the shared kernel's (phase 5).
  - `[medium]` `[reject]` (edge) Older invoices show no year — same as the blind row (intent's `dayMonth`); deferred-work design question.
  - `[low]` `[reject]` (edge) Expired prescription wording — same as the blind row.
  - `[maybe-false]` `[reject]` (edge) The spec says "unknown / certificate allowed" for the filter while `unknown` fails — the spec lists the enum mapping; no caller filters by `unknown`; if true low.
  - `[low]` `[patch]` (intent) Pull-to-refresh missing — same as the first row.
  - `[low]` `[patch]` (intent) Lab-result empty title « Aucun résultat » vs « Aucun résultat d'analyse » — ARB string and tests changed.
  - `[low]` `[patch]` (intent) Deferred-work record missing — same as the deferred-items row.
  - `[low]` `[reject]` (intent) Subtitle 14 px (kit C-37a) vs mockup 13 px — the shared `KivetoPageHeader` (screens 4, 5, 6, 10; design-system "13 or 14") renders 14; a 1-px cosmetic gap; changing the kit is outside the slice.
  - `[low]` `[reject]` (intent) The report chip is never tapped in a widget test — the kind → `?type=` mapping is tested for every kind at repository level and the chip list is tested.
  - `[low]` `[reject]` (intent) Only two empty titles render at widget level — the five titles are tested as pure functions; the page renders whichever the filter gives.
  - `[low]` `[patch]` (intent) The file test uses a made-up 302 `location` and filename — the test now uses the captured shape (`:81/…/{c}/{id}/1?_expiration=…&_hash=…`, `document.pdf`).
  - `[medium]` `[patch]` (intent) The real PDF rendering never runs — same as the verification-gap pdfrx row; PDFium itself only runs on the emulator walk.
  - `[low]` `[patch]` (intent) Session change / null clinic not exercised — the session change test above; a null active clinic cannot reach the page (the router sends a clinic-less account to `/clinics`).
  - `[low]` `[patch]` (intent) The « Nouveau » label of the dot is not asserted — semantics assertion added.
  - `[maybe-false]` `[reject]` (intent) An invoice-type document without its invoice summary, and the list waiting for the names, untested — the backend always sends the summary of its type (README "Le détail par type"); if true low (the meta shows the date only).

### 2026-11-03 — Code review pass (bmad-code-review, branch diff vs master)
- verdicts: 28 findings — high 0, medium 8, low 15, false 1, maybe-false 4
- findings:
  - `[medium]` `[patch]` (verification-gap) The pet-names provider's session / clinic scoping is never observed — test: session B re-reads the pets with `Bearer B` and shows B's name (« Pipo »).
  - `[low]` `[patch]` (verification-gap) `_retry` re-reading the pet names is unverified — test: list and pets 503, both fixed, « Réessayer » → names back.
  - `[medium]` `[patch]` (verification-gap) `markRead` keeping the pagination state is untested on a multi-page list — test on Garnier: open PAR-2026-000025, back, scroll → 40 items, one `?cursor=`.
  - `[low]` `[patch]` (verification-gap) Pull-to-refresh reloading the hidden filters is unverified — test: « Factures » loaded, pull on « Tous », « Factures » re-requested with the new invoice.
  - `[medium]` `[reject]` (blind) A failed pull replaces the loaded list by the error view — the explicit error with « Réessayer » is the shared async pattern; keeping the stale items needs refresh-vs-reload tracking so that another session's reload never shows the previous account's documents (during the pull itself the list stays: `AsyncData` with `isRefreshing`).
  - `[medium]` `[patch]` (blind) Only the caller cleared a document's dot: slice 3's home opening an unread document would leave « Nouveau » on the Documents tab — `openDocumentFile` marks the document read in every loaded list itself; `onRead` removed; test from another widget.
  - `[low]` `[reject]` (blind) Raw `String` ids (`requestId`, `resultingPrescriptionId`, pet ids, the renewal callback) — no caller diverges; `PetId` is slice 3's (`patient`) to create or move to shared/domain.
  - `[low]` `[reject]` (blind) Closing the viewer does not cancel the download; no progress — demo and real documents are small PDFs; cancellation plumbing through the downloader is more than a direct correction.
  - `[medium]` `[defer]` (blind) The PDFium notices are not on the licence page — deferred-work (before the first store build).
  - `[low]` `[defer]` (blind) `make doctor` does not check the C toolchain — deferred-work.
  - `[low]` `[reject]` (blind) The spec's context points to the notes folder on this machine — the same as every earlier spec of this effort; the mockup lives there.
  - `[low]` `[reject]` (blind) The spec text lags the diff (fixtures "already on the branch", the `.gitattributes` task, status) — the fix is editing the spec under review.
  - `[low]` `[defer]` (blind) Large text and narrow phones not checked — deferred-work, like slice 1's entry.
  - `[low]` `[reject]` (blind) The names request holds up the list — both requests run in parallel; « names first » avoids meta lines changing under the eye; `/pets` is a small call.
  - `[low]` `[reject]` (blind) A download icon for an in-app viewer — the mockup's C-9e glyph; the label says « Ouvrir {title} ».
  - `[low]` `[patch]` (blind) « Avoir » reads as if the invoice were a credit note — « Avoir émis ».
  - `[low]` `[reject]` (blind) `markedRead` copies the fields by hand — no field is lost today (tested); a `copyWith` adds surface for a hypothetical field.
  - `[low]` `[reject]` (edge) A fast double tap stacks two viewers — unlikely; a guard adds state.
  - `[maybe-false]` `[reject]` (edge) A read during a pull is dropped by `markRead` (`isLoading`) — the refreshed page carries the server's read flag when the read happened before it; if true low.
  - `[false]` `[reject]` (edge) `onLoaded` throwing replaces the PDF — it only invalidates `/me` and marks lists read, neither throws.
  - `[low]` `[reject]` (edge) Closing the viewer does not cancel the download — same as the blind row.
  - `[low]` `[reject]` (edge) `done` + `renewable` shows the pill, no button — the orchestrator's FLAG decision (open or done → pill).
  - `[low]` `[reject]` (edge) The badge hides while `/me` reloads after a pull — the badge is hidden on the Documents tab anyway; it comes back with `/me`.
  - `[maybe-false]` `[reject]` (edge) An empty vet or pet name gives « · Oscar » — the backend always names both; if true low.
  - `[maybe-false]` `[reject]` (edge) Duplicate pet ids give « Moka et Moka » — the backend stores distinct ids; if true low.
  - `[maybe-false]` `[reject]` (edge, claim) The commit message says « the button while renewable » but `done` shows a pill — the same FLAG decision; the message summarises it.
  - `[low]` `[reject]` (acceptance) The Tasks line says pet-name failures fall back to an empty map in the provider (now in the page) — the fix edits the spec under review; the behaviour is the same.
  - `[medium]` `[patch]` (acceptance) The shared opener does not clear the dot by itself — same as the blind `onRead` row.
- Slice agent's emulator walk, patched with it: the unread dot now follows the last word of a wrapped title (inline `WidgetSpan`); pdfrx's heavy page shadow replaced by the kit's `KivetoShadows.bottomNav`.

### Emulator walk (slice agent, 2026-11-03, after the bmad-build-auto review)
Debug build on `Medium_Phone_API_37.0` against the local backend (screenshots `shots-document/` in the notes folder): Julien Paris badge 1 → both invoices with the dot → the real invoice PDF through pdfrx over the nav → back: no dot, badge gone on the home; Lyon (switched with a temporary, uncommitted long-press hack: the switcher is slice 3's) → « Aucun document » naming Lyon. Garnier (signed in by OTP): badge 5, 51 documents through three pages to « Compte rendu du 18/11/2023 », every renewal state (button for none and rejected, « Renouvellement traité », « Renouvellement demandé »), ORD-05's sheet (« Ordonnance du 22 déc. 2025 », « Dr Rousseau · Oscar », « Qté 2 · … ») and its PDF, the renewal button → screen 17 placeholder, « Factures » with « Non payée », « Résultats » empty, pull-to-refresh, Lyon « Aucune facture ». Julien signed in again, Paris active; his invoice set back to unread.

## Design Notes

- **Viewer navigation:** a page route on the root navigator, not a go_router route: the viewer is internal to the feature, slice 3 reuses it from the home and for the booklet (another API path) without new routes; go_router keeps pageless routes above the page that pushed them and drops them with it (sign-out).
- **Badge:** `/me` holds `unreadDocuments`; the list watches only the clinic id (`selectAsync` does not notify on loading nor on an equal id), so invalidating `meProvider` refreshes the badge without reloading the list.
- **PdfFilePage callbacks take the page's own `WidgetRef`:** the opener (list, home) may be disposed before the download ends; check `mounted` before `onLoaded`.
- Example (provider scoping):
  ```dart
  ref.watch(sessionStatusProvider);
  final clinicId = await ref.watch(activeClinicProvider.selectAsync((c) => c?.clinicId));
  if (clinicId == null) return const DocumentListState.empty();
  ```

## Verification

**Commands:**
- `fvm flutter gen-l10n` -- expected: `lib/l10n/app_localizations*.dart` regenerated, formatted.
- `make analyze` -- expected: no issue (run twice if riverpod_lint surprises).
- `make ci` -- expected: green, coverage gate 100 % on `features/document/{domain,infrastructure}` and `shared/domain/portal_file.dart`.

**Manual checks (if no CLI):**
- Emulator (slice agent, after implementation): Julien Paris and Lyon, Garnier pagination and prescriptions, a real PDF opened, the badge decreasing.

## Auto Run Result

Status: done (bmad-build-auto, one review pass; the bmad-code-review pass and the emulator walk follow on the branch).

**Implemented:** screen 5 « Documents » on `GET /clinics/{c}/documents` (five server-side filters, one list per filter, C-30 cards with per-type meta and an unread dot, cursor pagination with an inline retry, `cursor_invalid` reload, pull-to-refresh, empty / error / link-gone states), pet names from `GET /clinics/{c}/pets`, the in-app PDF viewer (pdfrx 2.11.0, pushed on the root navigator; `/me` invalidated once the file shows so the badge follows), the prescription sheet (`getPrescription`) and the renewal control (button → screen 17 placeholder, pills for `submitted` / `done`), the public API for slices 3 and 6, `PortalFile` in shared/domain.

**Files:**
- `lib/shared/domain/portal_file.dart` — the pure-Dart file value of the Portal API.
- `lib/features/document/domain/{document,prescription,document_repository,pet_name_repository}.dart` — models, enums with `unknown`, the two ports.
- `lib/features/document/infrastructure/portal_document_repository.dart` — `DocumentsApi` + `PortalFileDownloader` mapping (renewal map, enums, dates, money); `portal_pet_name_repository.dart` — `PetsApi.listPets`.
- `lib/features/document/di.dart`, `document.dart` — bindings and public API.
- `lib/features/document/presentation/{documents_page,documents_providers,document_card,document_messages,prescription_sheet,pdf_file_page}.dart` — the screen, its providers, the card, the French texts, the sheet, the viewer.
- `lib/shared/presentation/async/async_views.dart` — `failureMessage` / `ErrorView` unwrap Riverpod's `ProviderException` (errors arriving through `selectAsync`).
- `lib/app/routing/app_router.dart` — `/documents` builds the page; renewal pushes screen 17.
- `lib/l10n/app_fr.arb` (+ generated) — the `documents…` strings.
- `pubspec.yaml` / `pubspec.lock` — `pdfrx: 2.11.0` and its checks; `CONTRIBUTING.md` §5 — the C toolchain / network prerequisite of its native hook.
- `_bmad-output/implementation-artifacts/deferred-work.md` — four slice-2 entries.
- Tests: unit (domain, both repositories on the captures, `PortalFile`), widget (page, sheet, viewer, messages, async views, router); 10 new captures in `test/support/fixtures/portal_api/`.

**Review:** 46 findings (blind 17, verification-gap 6, edge-case 12, intent-alignment 11): 14 patch entries applied by the implementation subagent (pull-to-refresh, parallel and retried pet names, empty first page with a cursor, `ProviderException` unwrapping, per-title open label, lab-result title, six verification-gap tests, captured 302 shape, « Nouveau » label, ORD-36 capture), 2 deferred (renewal refresh for slice 6, PDFium download checksum / CI cache / iOS), the rest rejected with their reasons in the triage log (invoice year and expired-prescription wording follow the intent; `unknown` filter unreachable; 13 px subtitle is the shared kit's 14 px).

**Follow-up review recommended: true** — 10 medium entries were patched on this first pass, among them a shared-kit change (`async_views.dart` unwraps `ProviderException` for every screen) and the pull-to-refresh invalidating `meProvider`, which reloads the active clinic under every tab; the bmad-code-review pass on the branch diff covers it.

**Verification:** `make ci` green before the review (3 min 13 s) and after the patches (3 min 09 s): format, analyze, architecture, coverage gate (100 % on `features/document/{domain,infrastructure}` and `shared/domain/portal_file.dart`), scripts, api-check. Matrix audit: every I/O row has a passing test (documents_page, prescription_sheet, pdf_file_page, document_messages, repository tests). The implementation subagent also ran the debug build on the emulator as Julien (Paris): badge 1, both invoices, the real invoice PDF through pdfrx over the nav, then no dot and no badge.

**Residual risks:** PDFium only runs on a device (tests use a fake view); iOS not built; the first build needs network and a C toolchain; the header subtitle blanks while `/me` reloads (after an open, under the viewer, or during a pull).
