import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/patient.dart' show deviceToday;
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 16 (mockup 16), over screen 4: « Annuler ce rendez-vous ? », the
/// appointment, a warning when its motif covers a care item of the pet,
/// the reasons, « Annuler le rendez-vous » once a reason is chosen,
/// « Reporter plutôt » ([onReschedule], for an appointment the owner may
/// move) and « Garder mon rendez-vous »; once cancelled, « Rendez-vous
/// annulé » and « Retour à mes rendez-vous ».
Future<void> showCancelAppointmentSheet(
  BuildContext context,
  Appointment appointment, {
  required ClinicId clinicId,
  VoidCallback? onReschedule,
}) => showKivetoSheet<void>(
  context: context,
  builder: (context) => CancelAppointmentSheet(
    clinicId: clinicId,
    appointment: appointment,
    onReschedule: onReschedule,
  ),
);

/// The content of screen 16 (see [showCancelAppointmentSheet]).
class CancelAppointmentSheet extends ConsumerStatefulWidget {
  const new({
    required this.clinicId,
    required this.appointment,
    super.key,
    this.onReschedule,
  });

  final ClinicId clinicId;
  final Appointment appointment;
  final VoidCallback? onReschedule;

  @override
  ConsumerState<CancelAppointmentSheet> createState() =>
      _CancelAppointmentSheetState();
}

class _CancelAppointmentSheetState
    extends ConsumerState<CancelAppointmentSheet> {
  CancellationReason? _reason;
  bool _sending = false;
  Object? _error;

  /// The cancellation the server recorded.
  Appointment? _cancelled;

  Future<void> _cancel() async {
    final reason = _reason;
    if (reason == null || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final repository = ref.read(schedulingRepositoryProvider);
    final revision = ref.read(appointmentsRevisionProvider.notifier);
    try {
      final cancelled = await repository.cancel(
        widget.clinicId,
        widget.appointment.id,
        reason,
      );
      // Cancelled whatever became of the sheet: the lists follow.
      revision.bump();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _cancelled = cancelled;
      });
    } on Object catch (error) {
      // The window closed or the appointment changed meanwhile: the lists
      // show what the server says now.
      if (isStaleAppointment(error)) revision.bump();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error;
        // Refused for good: no reason left to send again.
        if (isClosedAppointment(error)) _reason = null;
      });
    }
  }

  void _reschedule() {
    final onReschedule = widget.onReschedule;
    Navigator.of(context).pop();
    onReschedule?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cancelled = _cancelled;
    if (cancelled != null) {
      return _SheetFrame(
        child: SheetSuccessView(
          title: l10n.appointmentCancelDoneTitle,
          message: [
            l10n.appointmentCancelDoneBody,
            if (widget.appointment.status == AppointmentStatus.confirmed)
              l10n.appointmentCancelDoneSms,
          ].join(' '),
          action: KivetoButton.primary(
            label: l10n.appointmentsBackToList,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
    final appointment = widget.appointment;
    final now = ref.watch(clockProvider).now();
    // The list does not carry the care item the motif covers: the
    // appointment's own read does (the warning shows once it answered).
    final care =
        appointment.relatedCareItem ??
        switch (ref.watch(appointmentProvider(appointment.id))) {
          AsyncData(:final value) => value.appointment.relatedCareItem,
          _ => null,
        };
    final pet = appointment.petName;
    final date = KivetoFormat.dateTimeShort(appointment.startAt);
    final error = _error;
    final reason = _reason;
    return KivetoSheet(
      title: l10n.appointmentCancelTitle,
      subtitle: pet == null
          ? l10n.appointmentCancelSubtitleNoPet(date, appointment.motifLabel)
          : l10n.appointmentCancelSubtitle(date, pet, appointment.motifLabel),
      // The sheet sets its children 8 apart; the groups of the mockup are
      // 18 apart (8 + 2 + 8).
      children: [
        if (care != null && pet != null) ...[
          KivetoCallout.warning(
            body: careWarning(
              l10n,
              care,
              pet,
              deviceToday(ref.watch(clockProvider)),
            ),
          ),
          _gap,
        ],
        Semantics(
          container: true,
          label: l10n.appointmentCancelReasonLegend,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Text(
                  l10n.appointmentCancelReasonLegend,
                  style: KivetoText.labelStrong,
                ),
              ),
              const SizedBox(height: KivetoSpace.m),
              _reasons(l10n, reason),
            ],
          ),
        ),
        if (error != null) ...[
          _gap,
          KivetoCallout.danger(
            body: schedulingFailureMessage(
              l10n,
              error,
              notFound: l10n.appointmentGone,
            ),
          ),
        ],
        _gap,
        KivetoButton.danger(
          label: l10n.appointmentCancelConfirm,
          loading: _sending,
          onPressed: reason == null ? null : _cancel,
        ),
        if (widget.onReschedule != null && appointment.isReschedulableAt(now))
          KivetoButton.outline(
            label: l10n.appointmentCancelReschedule,
            size: KivetoButtonSize.large,
            onPressed: _sending ? null : _reschedule,
          ),
        KivetoLinkButton(
          label: l10n.appointmentCancelKeep,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _reasons(AppLocalizations l10n, CancellationReason? reason) => Wrap(
    spacing: KivetoSpace.sm,
    runSpacing: KivetoSpace.sm,
    children: [
      for (final (value, label) in [
        (
          CancellationReason.unavailable,
          l10n.appointmentCancelReasonUnavailable,
        ),
        (
          CancellationReason.noLongerNeeded,
          l10n.appointmentCancelReasonNoLongerNeeded,
        ),
        (
          CancellationReason.seenElsewhere,
          l10n.appointmentCancelReasonSeenElsewhere,
        ),
        (CancellationReason.other, l10n.appointmentCancelReasonOther),
      ])
        KivetoChoiceChip(
          label: label,
          selected: value == reason,
          onSelected: _sending ? null : () => setState(() => _reason = value),
        ),
    ],
  );
}

/// Two more points between two children of the sheet (8 apart): the 18
/// between the groups of the mockup.
const _gap = SizedBox(height: KivetoSpace.xxs);

/// The handle and paddings of a sheet without title (its success state).
class _SheetFrame extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      KivetoSpace.gutter,
      10,
      KivetoSpace.gutter,
      kivetoBottomPadding(context, 28),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: KivetoColors.borderChip,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: KivetoSpace.xl2),
        child,
      ],
    ),
  );
}
