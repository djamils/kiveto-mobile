import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/patient.dart' show deviceToday;
import 'package:kiveto_mobile/features/scheduling/domain/booking_venue.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/slot_picker.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 3, step 3 of the booking (mockup 03): « Choisissez un créneau »,
/// the pet and motif chosen (each chip goes back to its step), the
/// practitioners and the slot picker; « Ce créneau vient d'être pris… »
/// after the confirmation found the slot taken.
///
/// Exits: [onContinue] once a slot is chosen, [onEditPet] and
/// [onEditMotif] (back to that step), [onBack], [onClose].
class BookingSlotPage extends ConsumerWidget {
  const new({
    required this.onContinue,
    required this.onEditPet,
    required this.onEditMotif,
    required this.onBack,
    required this.onClose,
    super.key,
  });

  final void Function(BuildContext context) onContinue;
  final void Function(BuildContext context) onEditPet;
  final void Function(BuildContext context) onEditMotif;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wizard = ref.watch(bookingWizardProvider);
    final draft = wizard.draft;
    final clinicId = draft.clinicId;
    final pet = draft.pet;
    final motif = draft.motif;
    final slot = draft.slot;
    return FlowScaffold(
      bar: StickySummaryBar(
        label: l10n.bookingSlotLabel,
        value: slot == null ? l10n.bookingSlotEmpty : slotShort(l10n, slot),
        action: KivetoButton.primary(
          label: l10n.commonContinue,
          size: KivetoButtonSize.medium,
          onPressed: draft.request == null ? null : () => onContinue(context),
        ),
      ),
      children: [
        WizardHeader(
          step: 3,
          stepLabel: l10n.bookingStepLabel(3),
          title: l10n.screenBookingSlotTitle,
          onBack: () => onBack(context),
          onClose: () => onClose(context),
        ),
        Wrap(
          spacing: KivetoSpace.sm,
          runSpacing: KivetoSpace.sm,
          children: [
            if (pet != null)
              KivetoSummaryChip(
                label: pet.name,
                onPressed: () => onEditPet(context),
              ),
            if (motif != null)
              KivetoSummaryChip(
                label: motifWithDuration(l10n, motif.label, motif.durationMin),
                onPressed: () => onEditMotif(context),
              ),
          ],
        ),
        if (clinicId == null)
          const BookingClinicPending()
        else if (motif != null)
          SlotPicker(
            venue: ClinicVenue(clinicId),
            motifId: motif.id,
            today: deviceToday(ref.watch(clockProvider)),
            selectedPractitionerId: draft.practitioner?.id,
            selectedSlot: slot,
            takenSlots: draft.takenSlots,
            warning: wizard.slotTaken ? l10n.bookingSlotTaken : null,
            onPractitioner: (practitioner) => ref
                .read(bookingWizardProvider.notifier)
                .choosePractitioner(practitioner),
            onSlot: (practitioner, slot) => ref
                .read(bookingWizardProvider.notifier)
                .chooseSlot(practitioner, slot),
          ),
      ],
    );
  }
}
