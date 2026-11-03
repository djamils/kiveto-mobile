import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-27, the next appointment on the brand card (mockup 01): « PROCHAIN
/// RENDEZ-VOUS » and its status pill (« Confirmé », « En attente », none
/// otherwise), the day and time on the clinic's clock, the pet, motif and
/// practitioner; « Remplir le questionnaire » while it is not started, and
/// « Gérer ».
class NextAppointmentCard extends StatelessWidget {
  const new({
    required this.appointment,
    required this.onFillQuestionnaire,
    required this.onManage,
    super.key,
  });

  final NextAppointment appointment;
  final VoidCallback onFillQuestionnaire;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (appointment.status) {
      AppointmentState.confirmed => l10n.homeAppointmentConfirmed,
      AppointmentState.pendingClinicConfirmation => l10n.homeAppointmentPending,
      AppointmentState.other => null,
    };
    final questionnaire =
        appointment.questionnaire == QuestionnaireState.notStarted;
    final manage = KivetoButton.onBrandOutline(
      label: l10n.homeManageAppointments,
      expand: !questionnaire,
      onPressed: onManage,
    );
    return Semantics(
      container: true,
      label: l10n.homeNextAppointmentTitle,
      child: Container(
        padding: const EdgeInsets.all(KivetoSpace.xl2),
        decoration: BoxDecoration(
          color: KivetoColors.brand,
          borderRadius: BorderRadius.circular(KivetoRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  // The card is already named after it.
                  child: ExcludeSemantics(
                    child: Text(
                      l10n.homeNextAppointmentTitle.toUpperCase(),
                      style: KivetoText.overline,
                    ),
                  ),
                ),
                if (status != null)
                  StatusPill(status, tone: StatusTone.onBrand),
              ],
            ),
            const SizedBox(height: KivetoSpace.l),
            Text(
              KivetoFormat.dateTimeShort(appointment.startAt),
              style: KivetoText.headline.copyWith(color: KivetoColors.surface),
            ),
            const SizedBox(height: KivetoSpace.xs),
            Text(
              appointmentDetail(l10n, appointment),
              style: kivetoTextStyle(
                15,
                FontWeight.w400,
                color: KivetoColors.onBrandMuted,
              ),
            ),
            const SizedBox(height: KivetoSpace.l),
            if (questionnaire)
              Row(
                children: [
                  Expanded(
                    child: KivetoButton.onBrand(
                      label: l10n.homeFillQuestionnaire,
                      onPressed: onFillQuestionnaire,
                    ),
                  ),
                  const SizedBox(width: KivetoSpace.m),
                  manage,
                ],
              )
            else
              manage,
          ],
        ),
      ),
    );
  }
}

/// « Oslo — Rendez-vous · Dr Éric Rousseau », what is not known left out.
String appointmentDetail(AppLocalizations l10n, NextAppointment appointment) {
  final pet = appointment.petName;
  final practitioner = appointment.practitionerName;
  return [
    if (pet == null || pet.isEmpty)
      appointment.motifLabel
    else
      l10n.homeAppointmentPetMotif(pet, appointment.motifLabel),
    if (practitioner != null && practitioner.isNotEmpty) practitioner,
  ].join(' · ');
}
