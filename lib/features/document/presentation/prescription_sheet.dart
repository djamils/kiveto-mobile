import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/prescription.dart';
import 'package:kiveto_mobile/features/document/presentation/document_card.dart';
import 'package:kiveto_mobile/features/document/presentation/document_messages.dart';
import 'package:kiveto_mobile/features/document/presentation/documents_providers.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the prescription of [document] in a sheet over the navigation:
/// its date, vet, pet and lines, "Voir l'ordonnance" (the PDF) and the
/// renewal control. "Demander un renouvellement" closes the sheet, then
/// calls [onRequestRenewal] with the page's [context].
Future<void> showPrescriptionSheet(
  BuildContext context, {
  required ClinicId clinicId,
  required Document document,
  required PrescriptionSummary prescription,
  required void Function(BuildContext context, String prescriptionId)
  onRequestRenewal,
}) => showKivetoSheet<void>(
  context: context,
  builder: (sheetContext) => PrescriptionSheet(
    clinicId: clinicId,
    document: document,
    prescription: prescription,
    onRequestRenewal: () {
      Navigator.of(sheetContext).pop();
      if (context.mounted) onRequestRenewal(context, prescription.id.value);
    },
  ),
);

/// The content of the prescription sheet (`GET …/prescriptions/{id}`):
/// loading, a 404 ("Ordonnance indisponible"), another failure with a
/// retry, or the prescription.
class PrescriptionSheet extends ConsumerWidget {
  const new({
    required this.clinicId,
    required this.document,
    required this.prescription,
    required this.onRequestRenewal,
    super.key,
  });

  final ClinicId clinicId;
  final Document document;
  final PrescriptionSummary prescription;
  final VoidCallback onRequestRenewal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = prescriptionProvider((clinicId, prescription.id));
    return switch (ref.watch(provider)) {
      AsyncValue(isLoading: true, hasError: true) => _loading(),
      AsyncData(value: final loaded) => _prescription(context, l10n, loaded),
      AsyncError(:final NotFoundFailure error) => KivetoSheet(
        title: document.title,
        children: [
          ErrorView(
            error: error,
            title: l10n.documentsPrescriptionGoneTitle,
            message: l10n.documentsPrescriptionGoneBody,
          ),
        ],
      ),
      AsyncError(:final error) => KivetoSheet(
        title: document.title,
        children: [
          ErrorView(error: error, onRetry: () => ref.invalidate(provider)),
        ],
      ),
      _ => _loading(),
    };
  }

  Widget _loading() => KivetoSheet(
    title: document.title,
    children: const [SizedBox(height: 160, child: LoadingView())],
  );

  Widget _prescription(
    BuildContext context,
    AppLocalizations l10n,
    Prescription loaded,
  ) {
    final renewal = renewalControlOf(prescription);
    return KivetoSheet(
      title: l10n.documentsPrescriptionTitle(
        KivetoFormat.dayMonthYear(loaded.issuedAt.date),
      ),
      subtitle: '${loaded.vet} · ${loaded.pet.name}',
      children: [
        if (loaded.lines.isNotEmpty)
          KivetoCard.list(
            children: [
              for (final line in loaded.lines)
                KivetoListRow(
                  title: line.label,
                  meta: l10n.documentsPrescriptionLine(
                    line.quantity,
                    line.posologySummary,
                  ),
                ),
            ],
          ),
        KivetoButton.primary(
          label: l10n.documentsPrescriptionOpen,
          onPressed: () => unawaited(
            openDocumentFile(
              context,
              clinicId: clinicId,
              documentId: document.id,
              title: document.title,
            ),
          ),
        ),
        if (renewal != RenewalControl.none)
          RenewalControlView(
            control: renewal,
            onRequestRenewal: onRequestRenewal,
          ),
      ],
    );
  }
}
