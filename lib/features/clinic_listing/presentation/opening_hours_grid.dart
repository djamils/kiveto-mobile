import 'package:kiveto_mobile/features/clinic_listing/domain/opening_schedule.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-11g, the opening hours of a clinic's sheet (mockup 11): a white card,
/// one line per group of days (« Lun – Ven », « Samedi ») in grey, its
/// ranges on the right in 600 (one per line), « Fermé » for a closed day.
class OpeningHoursGrid extends StatelessWidget {
  const new({required this.rows, super.key});

  final List<OpeningRow> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final day = KivetoText.bodySmall;
    final hours = KivetoText.labelSmall.copyWith(color: KivetoColors.ink);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: KivetoSpace.ml,
        horizontal: KivetoSpace.l,
      ),
      decoration: BoxDecoration(
        color: KivetoColors.surface,
        border: Border.all(color: KivetoColors.border),
        borderRadius: BorderRadius.circular(KivetoRadius.l),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: KivetoSpace.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(openingDaysLabel(rows[i]), style: day)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (rows[i].closed)
                        Text(l10n.clinicListingClosed, style: hours)
                      else
                        for (final range in rows[i].ranges)
                          Text(
                            openingRangeLabel(range),
                            style: hours,
                            textAlign: TextAlign.right,
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
