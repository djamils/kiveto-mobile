import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Reads the `.ics` of [appointment] and hands it to the share sheet as
/// one `text/calendar` file named after its day on the clinic's clock
/// (`rendez-vous-2026-11-09.ics`); a SnackBar says when it could not.
/// [origin] is the global rect of the tapped control ([globalRectOf]),
/// the anchor of the sheet's popover on iPad.
Future<void> shareAppointmentCalendar(
  BuildContext context,
  WidgetRef ref, {
  required ClinicId clinicId,
  required Appointment appointment,
  required Rect origin,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failed = AppLocalizations.of(context).appointmentsCalendarError;
  final repository = ref.read(schedulingRepositoryProvider);
  final share = ref.read(calendarSharerProvider);
  try {
    final file = await repository.calendar(clinicId, appointment.id);
    await share(
      PortalFile(
        file.bytes,
        contentType: file.contentType,
        fileName: 'rendez-vous-${appointment.startAt.date}.ics',
      ),
      origin,
    );
  } on Object catch (error) {
    debugPrint('Calendar not shared (${error.runtimeType})');
    messenger?.showSnackBar(SnackBar(content: Text(failed)));
  }
}

/// C-28, an appointment of screen 4 (mockup 04): the date tile, the time
/// and pet with the status pill, the motif, the practitioner and clinic
/// (or « En attente de confirmation par la clinique »); for an upcoming
/// appointment the questionnaire banner while it is not started, « Reporter »
/// (a portal booking with a motif) and « Annuler » while the clinic's
/// window is open, the window's footnote, « Ajouter à mon calendrier ».
/// The server decides the window ([Appointment.cancellableUntil]); the app
/// compares it with [now].
class AppointmentCard extends StatelessWidget {
  const new({
    required this.appointment,
    required this.upcoming,
    required this.now,
    required this.onReschedule,
    required this.onCancel,
    required this.onFillQuestionnaire,
    required this.onAddToCalendar,
    super.key,
    this.clinicName,
  });

  final Appointment appointment;

  /// In the « À venir » list: actions, banner and calendar; a past one is
  /// shown neutral, without them.
  final bool upcoming;
  final DateTime now;
  final String? clinicName;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onFillQuestionnaire;

  /// « Ajouter à mon calendrier », with the global rect of the tapped link
  /// (the share sheet's anchor on iPad).
  final ValueChanged<Rect> onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointment = this.appointment;
    final pill = appointmentStatusPill(l10n, appointment.status);
    final time = KivetoFormat.time(appointment.startAt);
    final pet = appointment.petName;
    final cancellable = upcoming && appointment.isModifiableAt(now);
    final reschedulable = upcoming && appointment.isReschedulableAt(now);
    final until = appointment.cancellableUntil;
    final footnote = !upcoming || until == null
        ? null
        : cancellable
        ? cancellableUntilLine(l10n, until)
        : l10n.appointmentsWindowClosed;
    final questionnaire =
        upcoming && appointment.questionnaire == QuestionnaireStatus.notStarted;
    final clinic = clinicName;
    final third = appointment.isPending
        ? l10n.appointmentsPendingLine
        : [
            practitionerLabel(l10n, appointment.practitionerName),
            ?clinic,
          ].join(' · ');
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KivetoColors.surface,
          border: Border.all(color: KivetoColors.border),
          borderRadius: BorderRadius.circular(KivetoRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(KivetoSpace.xl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppointmentDateTile(
                    date: appointment.startAt.date,
                    brand: upcoming && !appointment.isPending,
                  ),
                  const SizedBox(width: KivetoSpace.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The pill at the end of the line, or under the
                        // time when both do not fit (« Annulé par la
                        // clinique »).
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: KivetoSpace.sm,
                            runSpacing: KivetoSpace.xs,
                            children: [
                              Text(
                                pet == null
                                    ? time
                                    : l10n.appointmentsTimePet(time, pet),
                                style: KivetoText.sectionTitle,
                              ),
                              if (pill case (final label, final tone))
                                StatusPill(label, tone: tone),
                            ],
                          ),
                        ),
                        const SizedBox(height: KivetoSpace.xs),
                        Text(
                          appointment.motifLabel,
                          style: KivetoText.body.copyWith(
                            color: KivetoColors.inkSecondary,
                          ),
                        ),
                        const SizedBox(height: KivetoSpace.xs),
                        Text(third, style: KivetoText.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (questionnaire)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KivetoSpace.xl),
                child: _QuestionnaireBanner(onTap: onFillQuestionnaire),
              ),
            if (cancellable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    if (reschedulable) ...[
                      Expanded(
                        child: KivetoButton.outline(
                          label: l10n.appointmentsReschedule,
                          onPressed: onReschedule,
                          expand: true,
                        ),
                      ),
                      const SizedBox(width: KivetoSpace.m),
                    ],
                    Expanded(
                      child: KivetoButton.outlineDanger(
                        label: l10n.appointmentsCancel,
                        onPressed: onCancel,
                        expand: true,
                      ),
                    ),
                  ],
                ),
              ),
            if (footnote != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16, cancellable ? 4 : 0, 16, 14),
                child: Text(footnote, style: KivetoText.caption),
              ),
            if (questionnaire && footnote == null)
              const SizedBox(height: KivetoSpace.ml),
            if (upcoming) _CalendarLink(onTap: onAddToCalendar),
          ],
        ),
      ),
    );
  }
}

/// The date tile of C-28: 56 wide, the weekday (« MER »), the day, the
/// month of [date] (the clinic's day); brand for a confirmed appointment to
/// come, neutral otherwise (a pending one, a past one, a booking request).
class AppointmentDateTile extends StatelessWidget {
  const new({required this.date, required this.brand, super.key});

  final LocalDate date;
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final colors = brand ? KivetoColorSets.indigo : KivetoColorSets.neutral;
    final foreground = brand ? colors.foreground : KivetoColors.inkSecondary;
    // The card's day, read out in full (« Mercredi 11 novembre »).
    return Semantics(
      label: KivetoFormat.dayLong(date),
      excludeSemantics: true,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: KivetoSpace.sm),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(KivetoRadius.m),
        ),
        child: Column(
          children: [
            Text(
              KivetoFormat.weekdayShort(date).toUpperCase(),
              style: kivetoTextStyle(11, FontWeight.w700, color: foreground),
            ),
            Text(
              '${date.day}',
              style: kivetoTextStyle(
                22,
                FontWeight.w700,
                height: 1.1,
                color: foreground,
              ),
            ),
            Text(
              KivetoFormat.monthShort(date),
              style: kivetoTextStyle(11, FontWeight.w600, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

/// C-33d: « Questionnaire à compléter » on amber, a chevron.
class _QuestionnaireBanner extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      child: Material(
        color: KivetoColors.warningSoft,
        borderRadius: BorderRadius.circular(KivetoRadius.m),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KivetoSpace.l,
                vertical: KivetoSpace.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appointmentsQuestionnaireTitle,
                          style: KivetoText.labelStrong.copyWith(
                            color: KivetoColors.warning,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.appointmentsQuestionnaireBody,
                          style: KivetoText.caption.copyWith(
                            color: KivetoColors.onWarningSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KivetoSpace.ml),
                  const KivetoIcon(
                    LucideGlyph.chevronRight,
                    size: 18,
                    color: KivetoColors.warning,
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

/// « Ajouter à mon calendrier »: a 44 row, the calendar glyph and a brand
/// label; a tap reports the row's global rect.
class _CalendarLink extends StatelessWidget {
  const new({required this.onTap});

  final ValueChanged<Rect> onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: () => onTap(globalRectOf(context)),
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(KivetoRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KivetoSpace.xl),
          child: Row(
            children: [
              const KivetoIcon(
                LucideGlyph.calendar,
                size: 16,
                color: KivetoColors.brand,
              ),
              const SizedBox(width: KivetoSpace.sm),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).appointmentsAddToCalendar,
                  style: KivetoText.labelStrong.copyWith(
                    color: KivetoColors.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
