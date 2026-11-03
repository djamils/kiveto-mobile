import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/patient.dart' show deviceToday;
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/slot_picker.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The reschedule of an appointment (screen 3's slot picker, reused):
/// « Reporter le rendez-vous », the appointment and its current slot, the
/// practitioners (the current one chosen) and the slots; then « Rendez-vous
/// reporté ». Only a portal appointment with a motif, within the clinic's
/// window, may move (the server refuses any other).
///
/// Exits: [onBack], [onDone] (« Retour à mes rendez-vous », back on the
/// success).
class ReschedulePage extends ConsumerStatefulWidget {
  const new({
    required this.appointmentId,
    required this.onBack,
    required this.onDone,
    super.key,
  });

  final String appointmentId;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onDone;

  @override
  ConsumerState<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends ConsumerState<ReschedulePage> {
  Practitioner? _practitioner;
  ClinicInstant? _slot;

  /// The slots another booking took meanwhile (`409 slot_taken`).
  final _taken = <ClinicInstant>{};
  bool _slotTaken = false;
  bool _sending = false;
  Object? _error;

  /// The appointment as the server moved it.
  ClinicAppointment? _moved;

  AppointmentId get _id => AppointmentId(widget.appointmentId);

  Future<void> _confirm(ClinicId clinicId) async {
    final slot = _slot;
    final practitioner = _practitioner;
    if (slot == null || practitioner == null || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final repository = ref.read(schedulingRepositoryProvider);
    final revision = ref.read(appointmentsRevisionProvider.notifier);
    try {
      final moved = await repository.reschedule(
        clinicId,
        _id,
        startAt: slot,
        practitionerId: practitioner.id,
      );
      // Moved whatever became of the page: the lists follow.
      revision.bump();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _moved = (clinicId: clinicId, appointment: moved);
      });
    } on Object catch (error) {
      final cause = failureCause(error);
      // The window closed or the appointment changed meanwhile: the lists
      // show what the server says now.
      if (isStaleAppointment(error)) revision.bump();
      if (!mounted) return;
      // Refused for good: the appointment read again says whether it may
      // still move.
      if (isClosedAppointment(error) ||
          (cause is ApiFailure && cause.code == 'booking_not_open')) {
        ref.invalidate(appointmentProvider(_id));
      }
      // A 404: the appointment is gone, or the slot or practitioner is no
      // longer offered for its motif; read both again.
      final gone = cause is NotFoundFailure;
      if (gone) {
        ref
          ..invalidate(appointmentProvider(_id))
          ..invalidate(practitionersProvider);
      }
      if (cause case ConflictFailure(code: 'slot_taken')) {
        ref.invalidate(availabilityProvider);
        setState(() {
          _sending = false;
          _taken.add(slot);
          _slot = null;
          _slotTaken = true;
        });
        return;
      }
      setState(() {
        _sending = false;
        _error = error;
        if (gone) _slot = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_moved case (:final clinicId, :final appointment)) {
      return _Moved(
        clinicId: clinicId,
        appointment: appointment,
        onDone: widget.onDone,
      );
    }
    final read = ref.watch(appointmentProvider(_id));
    void back() => widget.onBack(context);
    return switch (read) {
      AsyncValue(isLoading: true, hasError: true) => _Plain(
        onBack: back,
        child: const LoadingView(),
      ),
      AsyncData(:final value) => _page(context, l10n, value),
      AsyncError(:final error) => _Plain(
        onBack: back,
        child: failureCause(error) is NotFoundFailure
            ? ErrorView(
                error: error,
                title: l10n.rescheduleNotFoundTitle,
                onRetry: () => ref.invalidate(appointmentProvider(_id)),
              )
            : ErrorView(
                error: error,
                onRetry: () => ref.invalidate(appointmentProvider(_id)),
              ),
      ),
      _ => _Plain(onBack: back, child: const LoadingView()),
    };
  }

  Widget _page(
    BuildContext context,
    AppLocalizations l10n,
    ClinicAppointment read,
  ) {
    final (:clinicId, :appointment) = read;
    final now = ref.watch(clockProvider).now();
    final motifId = appointment.motifId;
    if (motifId == null ||
        !appointment.isActive ||
        !appointment.isReschedulableAt(now)) {
      return _Plain(
        onBack: () => widget.onBack(context),
        child: EmptyState(
          glyph: LucideGlyph.calendar,
          title: l10n.rescheduleNotAllowed,
          action: KivetoButton.outline(
            label: l10n.commonBack,
            onPressed: () => widget.onBack(context),
          ),
        ),
      );
    }
    final current = slotShort(l10n, appointment.startAt, capitalized: false);
    final pet = appointment.petName;
    final slot = _slot;
    final error = _error;
    return FlowScaffold(
      bar: StickySummaryBar(
        label: l10n.rescheduleSlotLabel,
        value: slot == null ? l10n.bookingSlotEmpty : slotShort(l10n, slot),
        action: KivetoButton.primary(
          label: l10n.rescheduleConfirm,
          size: KivetoButtonSize.medium,
          loading: _sending,
          onPressed: slot == null || _sending
              ? null
              : () => unawaited(_confirm(clinicId)),
        ),
      ),
      children: [
        KivetoDetailHeader(
          title: l10n.screenRescheduleTitle,
          subtitle: pet == null
              ? l10n.rescheduleSubtitleNoPet(appointment.motifLabel, current)
              : l10n.rescheduleSubtitle(pet, appointment.motifLabel, current),
          onBack: () => widget.onBack(context),
        ),
        if (error != null)
          KivetoCallout.danger(
            body: schedulingFailureMessage(
              l10n,
              error,
              notFound: l10n.rescheduleSlotGone,
            ),
            actionLabel: isTransientFailure(error) ? l10n.commonRetry : null,
            onAction: () => unawaited(_confirm(clinicId)),
          ),
        SlotPicker(
          clinicId: clinicId,
          motifId: motifId,
          today: deviceToday(ref.watch(clockProvider)),
          selectedPractitionerId:
              _practitioner?.id ?? appointment.practitionerId,
          selectedSlot: slot,
          takenSlots: _taken,
          warning: _slotTaken ? l10n.bookingSlotTaken : null,
          // While the move is on its way, its answer is for the slot sent.
          onPractitioner: (practitioner) => _sending
              ? null
              : setState(() {
                  _practitioner = practitioner;
                  _slot = null;
                  _taken.clear();
                  _slotTaken = false;
                  _error = null;
                }),
          onSlot: (practitioner, slot) => _sending
              ? null
              : setState(() {
                  _practitioner = practitioner;
                  _slot = slot;
                  _slotTaken = false;
                  _error = null;
                }),
        ),
      ],
    );
  }
}

/// A page of the reschedule without a picker: back, and [child] (loading,
/// a failure, the reason it may not move).
class _Plain extends StatelessWidget {
  const new({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KivetoColors.surface,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KivetoIconButton.back(onPressed: onBack),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    ),
  );
}

/// The success of the reschedule (C-34a): « Rendez-vous reporté », the new
/// slot, « Ajouter à mon calendrier », « Retour à mes rendez-vous ».
class _Moved extends ConsumerWidget {
  const new({
    required this.clinicId,
    required this.appointment,
    required this.onDone,
  });

  final ClinicId clinicId;
  final Appointment appointment;
  final void Function(BuildContext context) onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final until = appointment.cancellableUntil;
    final notes = [
      // A pending appointment stays pending: the clinic confirms the new
      // slot.
      if (appointment.isPending) l10n.rescheduleStillPending,
      if (until != null) cancellableUntilLine(l10n, until),
    ];
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
                      title: l10n.rescheduleDoneTitle,
                      message: [
                        slotLong(l10n, appointment.startAt),
                        [
                          ?appointment.petName,
                          appointment.motifLabel,
                          practitionerLabel(l10n, appointment.practitionerName),
                        ].join(' · '),
                      ].join('\n'),
                      note: notes.isEmpty ? null : notes.join('\n'),
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
                  KivetoButton.primary(
                    label: l10n.appointmentsBackToList,
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
