import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-11j: a clinic row, padding 14 16: its dot (brand when [active], grey
/// otherwise), its [name] (14/700) and an optional [meta] line (12), then
/// the « Active » pill, the « En attente » pill of a [pending] link, or a
/// chevron when the row is tappable ([onTap]: the clinic switcher, the
/// account screen).
class ClinicRow extends StatelessWidget {
  const new({
    required this.name,
    required this.active,
    super.key,
    this.meta,
    this.pending = false,
    this.onTap,
  });

  final String name;
  final String? meta;
  final bool active;

  /// A link the clinic has not confirmed yet (grey dot, neutral pill).
  final bool pending;

  /// Null: not tappable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meta = this.meta;
    final onTap = this.onTap;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          StatusDot(active: active),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: KivetoText.labelStrong),
                if (meta != null && meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(meta, style: KivetoText.caption),
                ],
              ],
            ),
          ),
          if (active) ...[
            const SizedBox(width: 12),
            StatusPill(l10n.clientClinicActive, tone: StatusTone.brand),
          ] else if (pending) ...[
            const SizedBox(width: 12),
            StatusPill(l10n.accountClinicPending, tone: StatusTone.neutral),
          ] else if (onTap != null) ...[
            const SizedBox(width: 12),
            const KivetoIcon(
              LucideGlyph.chevronRight,
              size: 18,
              color: KivetoColors.inkMuted,
            ),
          ],
        ],
      ),
    );
    return Semantics(
      button: onTap != null,
      selected: active,
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(
                KivetoColors.inkPressed,
              ),
              child: row,
            ),
    );
  }
}
