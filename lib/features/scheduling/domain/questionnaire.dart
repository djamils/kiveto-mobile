import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';

/// A symptom of the pre-visit questionnaire (version 1); [none] (« Rien de
/// particulier ») goes with no other; [unknown] for a value this app does
/// not know yet.
enum Symptom {
  none,
  cough,
  vomiting,
  diarrhea,
  appetiteLoss,
  itching,
  lameness,
  unknown,
}

/// How the pet lives its visits; [unknown] for a value this app does not
/// know yet.
enum Temperament { calm, stressed, mayBite, unknown }

/// The answers of a pre-visit questionnaire, as sent or as the server
/// keeps them.
final class QuestionnaireAnswers {
  const new({
    required this.symptoms,
    required this.ongoingTreatment,
    required this.temperament,
    this.treatmentDetails,
    this.notes,
  });

  final Set<Symptom> symptoms;

  /// Whether the pet follows a treatment; [treatmentDetails] says which.
  final bool ongoingTreatment;
  final String? treatmentDetails;
  final Temperament temperament;

  /// « Autre chose à signaler ».
  final String? notes;
}

/// The pre-visit questionnaire of an appointment (`GET …/questionnaire`):
/// its status, the answers once submitted, when they were sent, and
/// whether they may still change ([editable]: the server's answer — the
/// appointment holds its slot, has not started, no consultation began).
final class Questionnaire {
  const new({
    required this.status,
    required this.editable,
    this.answers,
    this.updatedAt,
  });

  final QuestionnaireStatus status;
  final QuestionnaireAnswers? answers;
  final ClinicInstant? updatedAt;
  final bool editable;
}

/// The form of screen 15 (mockup 15): the symptoms chosen (« Rien de
/// particulier » at first), the treatment and the temperament once
/// answered. Immutable: each change returns a new form. It knows only what
/// the form needs to send; the server checks the answers.
final class QuestionnaireForm {
  const new _({
    required this.symptoms,
    this.ongoingTreatment,
    this.temperament,
  });

  /// A new questionnaire: « Rien de particulier », the treatment and the
  /// temperament not answered.
  const new initial()
    : symptoms = const {Symptom.none},
      ongoingTreatment = null,
      temperament = null;

  /// The form of answers already sent (the values this app does not know
  /// are dropped: they must be answered again).
  factory from(QuestionnaireAnswers answers) => QuestionnaireForm._(
    symptoms: Set.unmodifiable({
      for (final symptom in answers.symptoms)
        if (symptom != Symptom.unknown) symptom,
    }),
    ongoingTreatment: answers.ongoingTreatment,
    temperament: answers.temperament == Temperament.unknown
        ? null
        : answers.temperament,
  );

  final Set<Symptom> symptoms;

  /// Null until answered.
  final bool? ongoingTreatment;

  /// Null until answered.
  final Temperament? temperament;

  /// [symptom] turned on or off. « Rien de particulier » alone: on, it
  /// clears the others; another symptom turned on clears it.
  QuestionnaireForm toggle(Symptom symptom) {
    if (symptom == Symptom.unknown) return this;
    final on = symptoms.contains(symptom);
    final Set<Symptom> next;
    if (symptom == Symptom.none) {
      next = on ? const {} : const {Symptom.none};
    } else {
      next = Set.unmodifiable({
        for (final other in symptoms)
          if (other != Symptom.none && other != symptom) other,
        if (!on) symptom,
      });
    }
    return QuestionnaireForm._(
      symptoms: next,
      ongoingTreatment: ongoingTreatment,
      temperament: temperament,
    );
  }

  QuestionnaireForm withTreatment({required bool ongoing}) =>
      QuestionnaireForm._(
        symptoms: symptoms,
        ongoingTreatment: ongoing,
        temperament: temperament,
      );

  QuestionnaireForm withTemperament(Temperament temperament) =>
      QuestionnaireForm._(
        symptoms: symptoms,
        ongoingTreatment: ongoingTreatment,
        temperament: temperament == Temperament.unknown ? null : temperament,
      );

  /// At least one symptom, the treatment and the temperament answered.
  bool get isComplete =>
      symptoms.isNotEmpty && ongoingTreatment != null && temperament != null;

  /// The answers to send, with the treatment's [details] (only for an
  /// ongoing treatment) and the [notes], trimmed (blank: none); null while
  /// the form is not [isComplete]. The symptoms in the questionnaire's
  /// order.
  QuestionnaireAnswers? toAnswers({String? details, String? notes}) {
    final (ongoing, temperament) = (ongoingTreatment, this.temperament);
    if (symptoms.isEmpty || ongoing == null || temperament == null) {
      return null;
    }
    return QuestionnaireAnswers(
      symptoms: Set.unmodifiable({
        for (final symptom in Symptom.values)
          if (symptoms.contains(symptom)) symptom,
      }),
      ongoingTreatment: ongoing,
      treatmentDetails: ongoing ? _text(details) : null,
      temperament: temperament,
      notes: _text(notes),
    );
  }

  static String? _text(String? value) => switch (value?.trim()) {
    final String text when text.isNotEmpty => text,
    _ => null,
  };
}
