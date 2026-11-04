import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Who books on a clinic's sheet (11).
enum ClinicVisitor { known, newClient }

/// C-24d, « Vous êtes » (mockup 11): « Déjà client / de cette clinique »
/// and « Nouveau client / première visite », two radio cards side by side.
class WhoCards extends StatelessWidget {
  const new({required this.selected, required this.onSelected, super.key});

  final ClinicVisitor selected;
  final ValueChanged<ClinicVisitor> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.clinicListingWho,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _WhoCard(
              label: l10n.clinicListingKnownClient,
              sub: l10n.clinicListingKnownClientSub,
              selected: selected == ClinicVisitor.known,
              onTap: () => onSelected(ClinicVisitor.known),
            ),
          ),
          const SizedBox(width: KivetoSpace.sm),
          Expanded(
            child: _WhoCard(
              label: l10n.clinicListingNewClient,
              sub: l10n.clinicListingNewClientSub,
              selected: selected == ClinicVisitor.newClient,
              onTap: () => onSelected(ClinicVisitor.newClient),
            ),
          ),
        ],
      ),
    );
  }
}

/// One who card: min-height 64, padding 0 14, radius 12; off: border 1
/// strong, white, ink; on: border 2 brand, brand-soft, `#312e81`; the
/// label 14/700 over the sub 12 at .8 opacity.
class _WhoCard extends StatelessWidget {
  const new({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? KivetoColors.onBrandSoft : KivetoColors.ink;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$label, $sub',
      excludeSemantics: true,
      child: Material(
        color: selected ? KivetoColors.brandSoft : KivetoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KivetoRadius.l),
          side: selected
              ? const BorderSide(color: KivetoColors.brand, width: 2)
              : const BorderSide(color: KivetoColors.borderStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 13 : KivetoSpace.l,
                vertical: KivetoSpace.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: KivetoText.labelStrong.copyWith(color: foreground),
                  ),
                  const SizedBox(height: KivetoSpace.xxs),
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      sub,
                      style: KivetoText.caption.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
