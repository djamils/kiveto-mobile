import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-31, a clinic of a search (mockup 10): its name over its address,
/// distance and tags, « RDV en ligne » when it takes new clients online,
/// the next slot when the server gives one; tapping it opens its sheet
/// ([onOpen]). A clinic not on Kiveto: a dashed card, « Pas encore sur
/// Kiveto », « Appeler » ([onCall]) when it has a phone, not tappable.
class ClinicCard extends StatelessWidget {
  const new({
    required this.clinic,
    required this.onOpen,
    required this.onCall,
    super.key,
  });

  final ClinicListingSummary clinic;
  final VoidCallback onOpen;

  /// Calls the clinic's phone (E.164).
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clinic = this.clinic;
    final meta = clinicCardMeta(clinic);
    final next = clinic.nextAvailableAt;
    final listed = clinic.onKiveto;
    final pill = listed
        ? (clinic.onlineBooking
              ? StatusPill(l10n.clinicSearchOnline, tone: StatusTone.success)
              : null)
        : StatusPill(l10n.clinicSearchUnlisted, tone: StatusTone.neutral);
    final phone = clinic.phone;
    final content = Padding(
      padding: const EdgeInsets.all(KivetoSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clinic.name, style: KivetoText.itemTitle),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: KivetoSpace.xxs),
                      Text(meta, style: KivetoText.bodySmall),
                    ],
                  ],
                ),
              ),
              if (pill != null) ...[const SizedBox(width: KivetoSpace.m), pill],
            ],
          ),
          if (listed && next != null) ...[
            const SizedBox(height: KivetoSpace.m),
            Text(
              l10n.clinicSearchNextSlot(KivetoFormat.dateTimeShort(next)),
              style: KivetoText.labelSmall.copyWith(color: KivetoColors.brand),
            ),
          ],
          if (!listed && phone != null) ...[
            const SizedBox(height: KivetoSpace.m),
            KivetoButton.outline(
              label: l10n.bookingCall,
              icon: LucideGlyph.phone,
              expand: true,
              onPressed: () => onCall(phone),
            ),
          ],
        ],
      ),
    );
    final radius = BorderRadius.circular(KivetoRadius.l);
    if (!listed) {
      return Semantics(
        container: true,
        child: KivetoDashedBorder(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: KivetoColors.surface,
              borderRadius: radius,
            ),
            child: content,
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      container: true,
      child: Material(
        color: KivetoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: KivetoColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: content,
        ),
      ),
    );
  }
}
