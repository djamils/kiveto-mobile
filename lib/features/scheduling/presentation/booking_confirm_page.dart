import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/patient/patient.dart' show speciesLabel;
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 14, step 4 of the booking (mockup 14): « Vérifiez et confirmez »,
/// the recap (« Modifier » on the date), the reassurance lines,
/// « Confirmer le rendez-vous »; then « Rendez-vous confirmé » or
/// « Demande envoyée » (the clinic confirms), « Ajouter à mon calendrier »
/// and the questionnaire. A failure stays on the recap with its message
/// (a retry sends the same key).
///
/// Exits: [onDone] (« Plus tard », back on the success),
/// [onFillQuestionnaire] with the appointment id, [onEditSlot],
/// [onSlotTaken] (another booking took the slot), [onEditPet] (the pet was
/// refused), [onBack], [onClose].
class BookingConfirmPage extends ConsumerWidget {
  const new({
    required this.onDone,
    required this.onFillQuestionnaire,
    required this.onEditSlot,
    required this.onSlotTaken,
    required this.onEditPet,
    required this.onBack,
    required this.onClose,
    super.key,
  });

  final void Function(BuildContext context) onDone;
  final void Function(BuildContext context, String appointmentId)
  onFillQuestionnaire;
  final void Function(BuildContext context) onEditSlot;
  final void Function(BuildContext context) onSlotTaken;
  final void Function(BuildContext context) onEditPet;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onClose;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final outcome = await ref.read(bookingWizardProvider.notifier).confirm();
    if (outcome == BookingOutcome.slotTaken && context.mounted) {
      onSlotTaken(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wizard = ref.watch(bookingWizardProvider);
    final draft = wizard.draft;
    final clinicId = draft.clinicId;
    final submission = wizard.submission;
    if (submission case BookingDone(:final appointment) when clinicId != null) {
      return _Booked(
        clinicId: clinicId,
        appointment: appointment,
        onDone: onDone,
        onFillQuestionnaire: onFillQuestionnaire,
      );
    }
    final clinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(:final value?) when value.clinicId == clinicId => value,
      _ => null,
    };
    final pet = draft.pet;
    final motif = draft.motif;
    final slot = draft.slot;
    final practitioner = draft.practitioner;
    final address = clinic?.address;
    final sending = submission is BookingSubmitting;
    // While the booking is on its way the owner stays on the recap: its
    // answer shows here (the success, or why it failed).
    void unlessSending(void Function(BuildContext context) exit) {
      if (!sending) exit(context);
    }

    return PopScope(
      canPop: !sending,
      child: FlowScaffold(
        bar: StickyCtaBar(
          child: KivetoButton.primary(
            label: l10n.bookingConfirm,
            loading: sending,
            onPressed: draft.request == null || sending
                ? null
                : () => unawaited(_confirm(context, ref)),
          ),
        ),
        children: [
          WizardHeader(
            step: 4,
            stepLabel: l10n.bookingStepLabel(4),
            title: l10n.screenBookingConfirmTitle,
            onBack: () => unlessSending(onBack),
            onClose: () => unlessSending(onClose),
          ),
          KivetoCard.list(
            radius: KivetoRadius.xl,
            children: [
              KivetoKeyValueRow(
                label: l10n.bookingPetLabel,
                value: pet?.name ?? '',
                secondary: switch (pet) {
                  NewPet(:final species) => l10n.bookingNewPetSecondary(
                    speciesLabel(l10n, species) ?? '',
                  ),
                  _ => null,
                },
              ),
              KivetoKeyValueRow(
                label: l10n.bookingMotifLabel,
                value: motif == null
                    ? ''
                    : motifWithDuration(l10n, motif.label, motif.durationMin),
              ),
              KivetoKeyValueRow(
                label: l10n.bookingRecapDate,
                value: slot == null ? '' : slotLong(l10n, slot),
                actionLabel: l10n.bookingEdit,
                onAction: () => unlessSending(onEditSlot),
              ),
              KivetoKeyValueRow(
                label: l10n.bookingVetLabel,
                value: practitionerLabel(l10n, practitioner?.displayName),
              ),
              KivetoKeyValueRow(
                label: l10n.bookingRecapClinic,
                value: clinic?.name ?? '',
                secondary: address == null
                    ? null
                    : '${address.line}, '
                          '${[?address.postalCode, address.city].join(' ')}',
              ),
            ],
          ),
          ReassuranceList([
            l10n.bookingReassuranceCancel,
            l10n.bookingReassuranceQuestionnaire,
          ]),
          if (submission case BookingFailed(:final error))
            KivetoCallout.danger(
              body: schedulingFailureMessage(l10n, error),
              actionLabel: isPetFailure(error)
                  ? l10n.bookingEdit
                  : isTransientFailure(error)
                  ? l10n.commonRetry
                  : null,
              onAction: isPetFailure(error)
                  ? () => onEditPet(context)
                  : () => unawaited(_confirm(context, ref)),
            ),
        ],
      ),
    );
  }
}

/// The success of screen 14 (C-34a): confirmed or sent, the appointment,
/// what comes next; back closes the booking like « Plus tard ».
class _Booked extends ConsumerWidget {
  const new({
    required this.clinicId,
    required this.appointment,
    required this.onDone,
    required this.onFillQuestionnaire,
  });

  final ClinicId clinicId;
  final Appointment appointment;
  final void Function(BuildContext context) onDone;
  final void Function(BuildContext context, String appointmentId)
  onFillQuestionnaire;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = appointment.isPending;
    final until = appointment.cancellableUntil;
    final questionnaire =
        appointment.questionnaire == QuestionnaireStatus.notStarted;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onDone(context);
      },
      child: Scaffold(
        backgroundColor: KivetoColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: SuccessView(
                      title: pending
                          ? l10n.bookingPendingTitle
                          : l10n.bookingConfirmedTitle,
                      message: [
                        slotLong(l10n, appointment.startAt),
                        [
                          ?appointment.petName,
                          appointment.motifLabel,
                          practitionerLabel(l10n, appointment.practitionerName),
                        ].join(' · '),
                      ].join('\n'),
                      note: [
                        if (pending)
                          l10n.bookingPendingNote
                        else
                          l10n.bookingSmsSent,
                        if (until != null) cancellableUntilLine(l10n, until),
                      ].join('\n'),
                      action: KivetoButton.outline(
                        label: l10n.appointmentsAddToCalendar,
                        icon: LucideGlyph.calendar,
                        expand: false,
                        onPressed: () => unawaited(
                          shareAppointmentCalendar(
                            context,
                            ref,
                            clinicId: clinicId,
                            appointment: appointment,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BottomCtaArea(
                success: true,
                children: [
                  if (questionnaire) ...[
                    KivetoButton.primary(
                      label: l10n.bookingFillQuestionnaire,
                      onPressed: () =>
                          onFillQuestionnaire(context, appointment.id.value),
                    ),
                    KivetoLinkButton(
                      label: l10n.bookingLater,
                      onPressed: () => onDone(context),
                    ),
                  ] else
                    KivetoButton.primary(
                      label: l10n.bookingBackHome,
                      onPressed: () => onDone(context),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
