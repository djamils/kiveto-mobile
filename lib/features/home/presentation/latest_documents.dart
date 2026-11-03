import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

/// « Derniers documents » of the home (C-11c): a tile per kind, the title,
/// the pets and day of a document or the total and payment of an invoice.
/// A row opens the document's file.
class LatestDocuments extends StatelessWidget {
  const new({
    required this.documents,
    required this.petNames,
    required this.today,
    required this.onOpen,
    super.key,
  });

  final List<HomeDocument> documents;

  /// The names of the home's pets, by id.
  final Map<String, String> petNames;
  final LocalDate today;
  final void Function(HomeDocument document) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KivetoCard.list(
      children: [
        for (final document in documents)
          KivetoListRow.tile(
            leading: homeDocumentTile(l10n, document.kind),
            title: document.title,
            meta: homeDocumentMeta(l10n, document, petNames, today),
            onTap: () => onOpen(document),
          ),
      ],
    );
  }
}

/// The 36 px tile of a kind (mockup 01): a file glyph for a report (indigo)
/// or a kind this app does not know (neutral), « € » (green), « Rx »
/// (orange), « Lab » (neutral), « Cert » (indigo).
KivetoLeadingTile homeDocumentTile(AppLocalizations l10n, DocumentKind kind) =>
    switch (kind) {
      DocumentKind.report => const KivetoLeadingTile(
        colors: KivetoColorSets.indigo,
        glyph: LucideGlyph.fileText,
      ),
      DocumentKind.invoice => KivetoLeadingTile(
        colors: KivetoColorSets.green,
        text: l10n.documentsGlyphInvoice,
      ),
      DocumentKind.prescription => KivetoLeadingTile(
        colors: KivetoColorSets.orange,
        text: l10n.documentsGlyphPrescription,
      ),
      DocumentKind.labResult => KivetoLeadingTile(
        colors: KivetoColorSets.neutral,
        text: l10n.documentsGlyphLabResult,
      ),
      DocumentKind.certificate => KivetoLeadingTile(
        colors: KivetoColorSets.indigo,
        text: l10n.documentsGlyphCertificate,
      ),
      DocumentKind.unknown => const KivetoLeadingTile(
        colors: KivetoColorSets.neutral,
        glyph: LucideGlyph.fileText,
      ),
    };

/// The meta line of a home document: « 52,00 € · Payée » for an invoice,
/// « Pepito · 2 nov. » otherwise (the names of the home's pets, an unknown
/// id left out; the year when it is not this one).
String homeDocumentMeta(
  AppLocalizations l10n,
  HomeDocument document,
  Map<String, String> petNames,
  LocalDate today,
) {
  if (document.invoice case final invoice?) {
    return [
      KivetoFormat.money(invoice.total),
      ?paymentLabel(l10n, invoice.paymentStatus),
    ].join(' · ');
  }
  final names = joinPetNames(l10n, [
    for (final id in document.petIds) ?petNames[id],
  ]);
  return [
    if (names.isNotEmpty) names,
    careDate(document.issuedAt.date, today),
  ].join(' · ');
}
