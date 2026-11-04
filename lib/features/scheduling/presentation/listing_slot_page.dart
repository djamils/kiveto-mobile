import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/patient.dart' show deviceToday;
import 'package:kiveto_mobile/features/scheduling/domain/booking_venue.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/slot_picker.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

/// Step 1 of 2 of the new-client booking of a clinic of the directory (the
/// layout of 3): « Choisissez un créneau », the motif chosen on the
/// clinic's sheet (its chip goes back to it), the practitioners and the
/// slots open to new clients; « Ce créneau vient d'être pris… » after the
/// request found the slot taken. Reached without a motif: « Choisissez
/// d'abord un motif. ».
///
/// Exits: [onContinue] once a slot is chosen, [onEditMotif] (back to the
/// sheet), [onBack], [onClose].
class ListingSlotPage extends ConsumerWidget {
  const new({
    required this.listingId,
    required this.onContinue,
    required this.onEditMotif,
    required this.onBack,
    required this.onClose,
    super.key,
  });

  final String listingId;
  final void Function(BuildContext context) onContinue;
  final void Function(BuildContext context) onEditMotif;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = ListingId(listingId);
    final booking = ref.watch(listingBookingProvider(id));
    final draft = booking.draft;
    final motif = draft.motif;
    final slot = draft.slot;
    return FlowScaffold(
      bar: motif == null
          ? null
          : StickySummaryBar(
              label: l10n.listingBookingSlotLabel,
              value: slot == null
                  ? l10n.listingBookingSlotEmpty
                  : slotShort(l10n, slot),
              action: KivetoButton.primary(
                label: l10n.commonContinue,
                size: KivetoButtonSize.medium,
                onPressed: slot == null || draft.practitioner == null
                    ? null
                    : () => onContinue(context),
              ),
            ),
      children: [
        WizardHeader(
          step: 1,
          total: 2,
          stepLabel: l10n.listingBookingStepLabel(1),
          title: l10n.screenBookingSlotTitle,
          onBack: () => onBack(context),
          onClose: () => onClose(context),
          overTitle: motif == null
              ? null
              : KivetoSummaryChip(
                  label: motifWithDuration(
                    l10n,
                    motif.label,
                    motif.durationMin,
                  ),
                  onPressed: () => onEditMotif(context),
                ),
        ),
        if (motif == null)
          EmptyState(
            glyph: LucideGlyph.calendar,
            title: l10n.listingBookingNoMotif,
            action: KivetoButton.outline(
              label: l10n.commonBack,
              onPressed: () => onBack(context),
            ),
          )
        else
          SlotPicker(
            venue: ListingVenue(id),
            motifId: motif.id,
            today: deviceToday(ref.watch(clockProvider)),
            selectedPractitionerId: draft.practitioner?.id,
            selectedSlot: slot,
            takenSlots: draft.takenSlots,
            warning: booking.slotTaken ? l10n.bookingSlotTaken : null,
            onPractitioner: (practitioner) => ref
                .read(listingBookingProvider(id).notifier)
                .choosePractitioner(practitioner),
            onSlot: (practitioner, slot) => ref
                .read(listingBookingProvider(id).notifier)
                .chooseSlot(practitioner, slot),
          ),
      ],
    );
  }
}
