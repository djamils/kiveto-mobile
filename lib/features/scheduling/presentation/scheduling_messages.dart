import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';

// The French texts of the scheduling screens: the server sends codes,
// instants and dates; the labels and the tone of a pill are the app's.
// Which slots exist, which status an appointment has and until when it may
// be cancelled are the server's answers.

/// The error a provider failed with (a dependency's error arrives wrapped
/// in [ProviderException]s).
Object failureCause(Object error) =>
    error is ProviderException ? failureCause(error.exception) : error;

/// The label and tone of an appointment's status pill; none for a status
/// this app does not know.
(String, StatusTone)? appointmentStatusPill(
  AppLocalizations l10n,
  AppointmentStatus status,
) => switch (status) {
  AppointmentStatus.confirmed => (
    l10n.appointmentsStatusConfirmed,
    StatusTone.success,
  ),
  AppointmentStatus.pendingClinicConfirmation => (
    l10n.appointmentsStatusPending,
    StatusTone.neutral,
  ),
  AppointmentStatus.cancelledByClient => (
    l10n.appointmentsStatusCancelled,
    StatusTone.neutral,
  ),
  AppointmentStatus.cancelledByClinic => (
    l10n.appointmentsStatusCancelledByClinic,
    StatusTone.neutral,
  ),
  AppointmentStatus.declined => (
    l10n.appointmentsStatusDeclined,
    StatusTone.neutral,
  ),
  AppointmentStatus.completed => (
    l10n.appointmentsStatusCompleted,
    StatusTone.neutral,
  ),
  AppointmentStatus.noShow => (
    l10n.appointmentsStatusNoShow,
    StatusTone.warning,
  ),
  AppointmentStatus.unknown => null,
};

/// A slot on the clinic's clock: « Lun. 9 nov. à 10:00 », or « lun. 9
/// nov. à 10:00 » inside a sentence (not [capitalized]).
String slotShort(
  AppLocalizations l10n,
  ClinicInstant slot, {
  bool capitalized = true,
}) => l10n.bookingDateAtTime(
  KivetoFormat.dayShort(slot.date, capitalized: capitalized),
  KivetoFormat.time(slot),
);

/// A slot on the clinic's clock: « Lundi 9 novembre à 10:00 ».
String slotLong(AppLocalizations l10n, ClinicInstant slot) =>
    l10n.bookingDateAtTime(
      KivetoFormat.dayLong(slot.date),
      KivetoFormat.time(slot),
    );

/// « Annulation en ligne possible jusqu'au dim. 8 nov. à 10:00. »
String cancellableUntilLine(AppLocalizations l10n, ClinicInstant until) =>
    l10n.appointmentsCancellableUntil(
      KivetoFormat.dayShort(until.date, capitalized: false),
      KivetoFormat.time(until),
    );

/// A practitioner's name, « Vétérinaire » when the clinic gave none.
String practitionerLabel(AppLocalizations l10n, String? name) =>
    switch (name?.trim()) {
      final String trimmed when trimmed.isNotEmpty => trimmed,
      _ => l10n.bookingVetLabel,
    };

/// « Consultation · 30 min ».
String motifWithDuration(AppLocalizations l10n, String label, int minutes) =>
    '$label · ${l10n.bookingMotifDuration(minutes)}';

/// The meta line of a motif card: its length, then why the server
/// suggests it or its description (« 30 min · Un problème de santé… »).
String motifMeta(AppLocalizations l10n, BookingMotif motif) {
  final detail = motif.suggested
      ? (motif.suggestionReason ?? motif.description)
      : motif.description;
  return [
    l10n.bookingMotifDuration(motif.durationMin),
    if (detail?.trim() case final String text when text.isNotEmpty) text,
  ].join(' · ');
}

/// The line under a pet of the booking: species · breed · age (« Chien ·
/// Labrador · 6 ans »), what is not known left out.
String bookingPetLine(AppLocalizations l10n, PetSummary pet, LocalDate today) =>
    [
      ?speciesLabel(l10n, pet.species),
      if (pet.breed?.trim() case final String breed when breed.isNotEmpty)
        breed,
      ?petAgeLabel(l10n, pet.birthDate, today),
    ].join(' · ');

/// The warning of screen 16 about the care item the motif covers, by its
/// kind (« Le rappel CHPL de Oslo est à faire avant le 5 sept. 2027.
/// Reporter évite un retard de vaccination. »).
String careWarning(
  AppLocalizations l10n,
  RelatedCareItem item,
  String pet,
  LocalDate today,
) {
  final date = careDate(item.dueOn, today);
  return switch (item.kind) {
    'vaccination' => l10n.appointmentCancelCareVaccination(
      item.label,
      pet,
      date,
    ),
    'internal_parasite' => l10n.appointmentCancelCareInternalParasite(
      item.label,
      pet,
      date,
    ),
    'external_parasite' => l10n.appointmentCancelCareExternalParasite(
      item.label,
      pet,
      date,
    ),
    _ => l10n.appointmentCancelCareOther(item.label, pet, date),
  };
}

/// The French message of a failed booking, reschedule or cancellation:
/// the business codes of the Portal API, the first violation of a
/// validation, else the shared message of the failure kind; [notFound]
/// replaces the booking's text of a 404 (a reschedule, a cancellation).
String schedulingFailureMessage(
  AppLocalizations l10n,
  Object error, {
  String? notFound,
}) => switch (failureCause(error)) {
  ConflictFailure(code: 'slot_taken') => l10n.bookingSlotTaken,
  ValidationFailure(:final violations) when violations.isNotEmpty =>
    violations.first.message,
  ApiFailure(code: 'pet_not_bookable') => l10n.bookingErrorPetNotBookable,
  ApiFailure(code: 'booking_not_open') => l10n.bookingErrorNotOpen,
  ApiFailure(code: 'appointment_not_modifiable') =>
    l10n.appointmentCancelNotModifiable,
  ApiFailure(code: 'cancellation_window_closed') =>
    l10n.appointmentsWindowClosed,
  NotFoundFailure() => notFound ?? l10n.bookingErrorNotFound,
  final other => failureMessage(l10n, other).$2,
};

/// The failure leaves the owner nothing to do but change the pet (a pet
/// the clinic does not take online, a new pet's name refused).
bool isPetFailure(Object error) => switch (failureCause(error)) {
  ApiFailure(code: 'pet_not_bookable') => true,
  ValidationFailure(:final violations) => violations.any(
    (violation) => violation.propertyPath.startsWith('newPet'),
  ),
  _ => false,
};

/// The server refused a change for good: the clinic's window is over, or
/// the appointment may no longer be modified.
bool isClosedAppointment(Object error) => switch (failureCause(error)) {
  ApiFailure(
    code: 'cancellation_window_closed' || 'appointment_not_modifiable',
  ) =>
    true,
  _ => false,
};

/// The appointment changed on the server (closed, or gone): the lists
/// reload to show what it is now.
bool isStaleAppointment(Object error) =>
    isClosedAppointment(error) || failureCause(error) is NotFoundFailure;

/// The failure may go away by sending the same request again (the
/// network, the server).
bool isTransientFailure(Object error) => switch (failureCause(error)) {
  NetworkFailure() || ServerFailure() => true,
  _ => false,
};

/// The chip of a symptom of the questionnaire; none for a symptom this app
/// does not know.
String? symptomLabel(AppLocalizations l10n, Symptom symptom) =>
    switch (symptom) {
      Symptom.none => l10n.questionnaireSymptomNone,
      Symptom.cough => l10n.questionnaireSymptomCough,
      Symptom.vomiting => l10n.questionnaireSymptomVomiting,
      Symptom.diarrhea => l10n.questionnaireSymptomDiarrhea,
      Symptom.appetiteLoss => l10n.questionnaireSymptomAppetiteLoss,
      Symptom.itching => l10n.questionnaireSymptomItching,
      Symptom.lameness => l10n.questionnaireSymptomLameness,
      Symptom.unknown => null,
    };

/// The chip of a temperament of the questionnaire; none for a value this
/// app does not know.
String? temperamentLabel(AppLocalizations l10n, Temperament temperament) =>
    switch (temperament) {
      Temperament.calm => l10n.questionnaireTemperamentCalm,
      Temperament.stressed => l10n.questionnaireTemperamentStressed,
      Temperament.mayBite => l10n.questionnaireTemperamentMayBite,
      Temperament.unknown => null,
    };

/// When the answers of a questionnaire were sent, on the clinic's clock:
/// the date (« mar. 4 nov. », kept on one line) and the time.
(String date, String time) questionnaireSentAt(ClinicInstant at) => (
  KivetoFormat.dayShort(at.date, capitalized: false).replaceAll(' ', '\u00a0'),
  KivetoFormat.time(at),
);

/// The French message of a questionnaire that could not be saved: the
/// first violation of a validation, the 404 of an appointment gone, else
/// the shared message of the failure kind.
String questionnaireFailureMessage(AppLocalizations l10n, Object error) =>
    switch (failureCause(error)) {
      ValidationFailure(:final violations) when violations.isNotEmpty =>
        violations.first.message,
      NotFoundFailure() => l10n.questionnaireNotFoundBody,
      final other => failureMessage(l10n, other).$2,
    };
