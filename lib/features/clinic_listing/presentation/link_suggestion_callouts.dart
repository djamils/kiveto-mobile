import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-33b, a clinic's record at the account's phone number (mockup 10):
/// « {clinic} a un dossier à votre numéro », why to link it, « Rattacher ce
/// dossier » ([onAccept], a spinner while [accepting]).
class LinkSuggestionCallout extends StatelessWidget {
  const new({
    required this.suggestion,
    required this.onAccept,
    super.key,
    this.accepting = false,
  });

  final LinkSuggestion suggestion;
  final VoidCallback onAccept;
  final bool accepting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: KivetoCallout.brand(
        title: l10n.linkSuggestionTitle(suggestion.clinicName),
        body: l10n.linkSuggestionBody,
        actionLabel: l10n.linkSuggestionAccept,
        actionLoading: accepting,
        onAction: accepting ? null : onAccept,
      ),
    );
  }
}

/// A link the clinic has yet to confirm (not drawn in the mockup): a white
/// box, « Rattachement demandé : {clinic} » with « En attente », what comes
/// next.
class PendingLinkCallout extends StatelessWidget {
  const new({required this.clinicName, super.key});

  final String clinicName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(KivetoSpace.l),
        decoration: BoxDecoration(
          color: KivetoColors.surface,
          border: Border.all(color: KivetoColors.border),
          borderRadius: BorderRadius.circular(KivetoRadius.l),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.linkPendingTitle(clinicName),
                    style: KivetoText.labelStrong,
                  ),
                ),
                const SizedBox(width: KivetoSpace.m),
                StatusPill(
                  l10n.appointmentsStatusPending,
                  tone: StatusTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: KivetoSpace.s),
            Text(
              l10n.linkPendingBody,
              style: KivetoText.bodySmall.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
