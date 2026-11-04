import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/presentation/document_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-30, a document card (mockup 05): its 40 × 40 tile, its title (with a
/// dot until it is opened) and [meta] line, the open button (C-9e), and
/// under them the renewal control of a prescription.
///
/// [onTap] answers a tap on the card, [onOpen] on the open button;
/// [onRequestRenewal] the "Demander un renouvellement" button (C-4c).
class DocumentCard extends StatelessWidget {
  const new({
    required this.document,
    required this.meta,
    required this.onTap,
    required this.onOpen,
    required this.onRequestRenewal,
    super.key,
  });

  final Document document;
  final String meta;
  final VoidCallback onTap;
  final VoidCallback onOpen;
  final VoidCallback onRequestRenewal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (colors, text) = documentTile(l10n, document.kind);
    final renewal = renewalControlOf(document.prescription);
    return KivetoCard(
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  KivetoLeadingTile(
                    colors: colors,
                    text: text,
                    glyph: text == null ? LucideGlyph.fileText : null,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The dot after the title, on its first line. An
                        // inline dot always offers a line break before it,
                        // and sat alone on a second line under a title
                        // that filled the first.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                document.title,
                                style: KivetoText.labelStrong,
                                // The dot right after the longest line,
                                // not at the far edge.
                                textWidthBasis: TextWidthBasis.longestLine,
                              ),
                            ),
                            if (document.unread)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text.rich(
                                  const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: UnreadDot(),
                                  ),
                                  style: KivetoText.labelStrong,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(meta, style: KivetoText.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  KivetoIconButton.squareMuted(
                    glyph: LucideGlyph.download,
                    semanticLabel: l10n.documentsOpen(document.title),
                    onPressed: onOpen,
                  ),
                ],
              ),
              if (renewal != RenewalControl.none) ...[
                const SizedBox(height: 10),
                RenewalControlView(
                  control: renewal,
                  onRequestRenewal: onRequestRenewal,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The dot of a document not opened yet: 8 px, brand, read "Nouveau".
class UnreadDot extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    // Its own node: read as "Nouveau", not lost in the card's label.
    container: true,
    label: AppLocalizations.of(context).documentsUnread,
    child: Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: KivetoColors.brand,
        shape: BoxShape.circle,
      ),
    ),
  );
}

/// The renewal control of a prescription ([renewalControlOf]): the C-4c
/// button, or the pill of a request (neutral while open, green once
/// handled).
class RenewalControlView extends StatelessWidget {
  const new({required this.control, required this.onRequestRenewal, super.key});

  final RenewalControl control;
  final VoidCallback onRequestRenewal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (control) {
      RenewalControl.request => KivetoButton.outlineBrand(
        label: l10n.documentsRequestRenewal,
        onPressed: onRequestRenewal,
      ),
      RenewalControl.requested => Align(
        alignment: AlignmentDirectional.centerStart,
        child: StatusPill(
          l10n.documentsRenewalRequested,
          tone: StatusTone.neutral,
        ),
      ),
      RenewalControl.done => Align(
        alignment: AlignmentDirectional.centerStart,
        child: StatusPill(l10n.documentsRenewalDone, tone: StatusTone.success),
      ),
      RenewalControl.none => const SizedBox.shrink(),
    };
  }
}
