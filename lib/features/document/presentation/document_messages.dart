import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';

// The French texts of the documents screen: the meta line of a card, the
// labels of the kinds, payments and filters. The server sends codes; the
// labels are the app's.

/// "A, B et C" (nothing for no name).
String joinPetNames(AppLocalizations l10n, List<String> names) =>
    switch (names) {
      [] => '',
      [final single] => single,
      _ => l10n.documentsNamesAnd(
        names.sublist(0, names.length - 1).join(', '),
        names.last,
      ),
    };

/// The meta line of a document's card: the pets ([petNames], name by id;
/// an unknown id is left out) and the issue date, the validity of a
/// prescription, the total, payment and day of an invoice (never its
/// pets).
String documentMeta(
  AppLocalizations l10n,
  Document document,
  Map<String, String> petNames,
) {
  final issued = document.issuedAt.date;
  if (document.invoice case final invoice?) {
    return [
      KivetoFormat.money(invoice.total),
      ?paymentLabel(l10n, invoice.paymentStatus),
      KivetoFormat.dayMonth(issued),
    ].join(' · ');
  }
  final names = joinPetNames(l10n, [
    for (final id in document.petIds) ?petNames[id],
  ]);
  final validUntil = document.prescription?.validUntil;
  return [
    if (names.isNotEmpty) names,
    if (validUntil != null)
      l10n.documentsValidUntil(KivetoFormat.dayMonthYear(validUntil))
    else
      KivetoFormat.dayMonthYear(issued),
  ].join(' · ');
}

/// The label of a payment status; none for a status this app does not
/// know.
String? paymentLabel(AppLocalizations l10n, PaymentStatus status) =>
    switch (status) {
      PaymentStatus.paid => l10n.documentsPaymentPaid,
      PaymentStatus.unpaid => l10n.documentsPaymentUnpaid,
      PaymentStatus.partiallyPaid => l10n.documentsPaymentPartiallyPaid,
      PaymentStatus.credited => l10n.documentsPaymentCredited,
      PaymentStatus.unknown => null,
    };

/// The name of a kind of document (the chips of a pet's history):
/// « Compte-rendu », « Ordonnance »…; « Document » for a kind this app does
/// not know.
String documentKindName(AppLocalizations l10n, DocumentKind kind) =>
    switch (kind) {
      DocumentKind.report => l10n.documentsKindReport,
      DocumentKind.prescription => l10n.documentsKindPrescription,
      DocumentKind.invoice => l10n.documentsKindInvoice,
      DocumentKind.labResult => l10n.documentsKindLabResult,
      DocumentKind.certificate => l10n.documentsKindCertificate,
      DocumentKind.unknown => l10n.documentsKindUnknown,
    };

/// The colours and text glyph of a document's tile (mockup 05); a kind
/// this app does not know has no text (a file icon instead).
(KivetoColorSet colors, String? text) documentTile(
  AppLocalizations l10n,
  DocumentKind kind,
) => switch (kind) {
  DocumentKind.report => (KivetoColorSets.indigo, l10n.documentsGlyphReport),
  DocumentKind.prescription => (
    KivetoColorSets.orange,
    l10n.documentsGlyphPrescription,
  ),
  DocumentKind.invoice => (KivetoColorSets.green, l10n.documentsGlyphInvoice),
  DocumentKind.labResult => (
    KivetoColorSets.neutral,
    l10n.documentsGlyphLabResult,
  ),
  DocumentKind.certificate => (
    KivetoColorSets.indigo,
    l10n.documentsGlyphCertificate,
  ),
  DocumentKind.unknown => (KivetoColorSets.neutral, null),
};

/// The filters of the screen, in the mockup's order (null: every
/// document).
const documentFilters = <DocumentKind?>[
  null,
  DocumentKind.report,
  DocumentKind.prescription,
  DocumentKind.invoice,
  DocumentKind.labResult,
];

/// The label of a filter chip.
String filterLabel(AppLocalizations l10n, DocumentKind? filter) =>
    switch (filter) {
      DocumentKind.report => l10n.documentsFilterReports,
      DocumentKind.prescription => l10n.documentsFilterPrescriptions,
      DocumentKind.invoice => l10n.documentsFilterInvoices,
      DocumentKind.labResult => l10n.documentsFilterLabResults,
      _ => l10n.documentsFilterAll,
    };

/// The title of the empty state of a filter.
String emptyTitle(AppLocalizations l10n, DocumentKind? filter) =>
    switch (filter) {
      DocumentKind.report => l10n.documentsEmptyReportsTitle,
      DocumentKind.prescription => l10n.documentsEmptyPrescriptionsTitle,
      DocumentKind.invoice => l10n.documentsEmptyInvoicesTitle,
      DocumentKind.labResult => l10n.documentsEmptyLabResultsTitle,
      _ => l10n.documentsEmptyAllTitle,
    };

/// What a prescription shows about its renewal.
enum RenewalControl {
  /// "Demander un renouvellement" (screen 17).
  request,

  /// "Renouvellement demandé": the clinic has not answered yet.
  requested,

  /// "Renouvellement traité".
  done,

  /// Nothing.
  none,
}

/// The renewal control of [prescription], from the server's answer only:
/// an open request or a handled one shows its pill; otherwise (no request,
/// a rejected or closed one, a status this app does not know) the button
/// when the server says the prescription is renewable.
RenewalControl renewalControlOf(PrescriptionSummary? prescription) =>
    switch (prescription) {
      null => RenewalControl.none,
      PrescriptionSummary(
        renewal: RenewalRequest(status: RenewalStatus.submitted),
      ) =>
        RenewalControl.requested,
      PrescriptionSummary(
        renewal: RenewalRequest(status: RenewalStatus.done),
      ) =>
        RenewalControl.done,
      PrescriptionSummary(renewable: true) => RenewalControl.request,
      _ => RenewalControl.none,
    };
