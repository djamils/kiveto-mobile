import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire_repository.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [QuestionnaireRepository] on the generated `RequestsApi`: the only
/// questionnaire code that sees the generated DTOs.
///
/// The questionnaire read (`QuestionnaireView`) and the one saved
/// (`SavedQuestionnaireView`) have the same shape but their own status
/// classes: one mapper each, the answers (one class) mapped once. Every
/// wire enum is read by an exhaustive switch (`unknown` kept), never by
/// its JSON value.
final class PortalQuestionnaireRepository implements QuestionnaireRepository {
  new(api.Server server, this._failures) : _api = api.RequestsApi(server);

  final api.RequestsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<Questionnaire> questionnaire(
    ClinicId clinicId,
    AppointmentId appointmentId,
  ) async => switch (await _api.getQuestionnaire(
    clinicId: clinicId.value,
    appointmentId: appointmentId.value,
  )) {
    TonikSuccess(value: api.GetQuestionnaireResponse200(:final body)) => _read(
      body,
    ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<Questionnaire> save(
    ClinicId clinicId,
    AppointmentId appointmentId,
    QuestionnaireAnswers answers,
  ) async => switch (await _api.saveQuestionnaire(
    clinicId: clinicId.value,
    appointmentId: appointmentId.value,
    body: api.QuestionnaireUpdate(
      version: api.QuestionnaireUpdateVersionModel.one,
      symptoms: [
        for (final symptom in answers.symptoms) ?_wireSymptom(symptom),
      ],
      ongoingTreatment: api.$RawQuestionnaireUpdateOngoingTreatmentAnyOfModel(
        ongoingTreatment: api.OngoingTreatment(
          has: answers.ongoingTreatment,
          details: answers.treatmentDetails,
        ),
      ),
      temperament: _wireTemperament(answers.temperament),
      notes: answers.notes,
    ),
  )) {
    TonikSuccess(value: api.SaveQuestionnaireResponse200(:final body)) =>
      _saved(body),
    final other => throw apiFailureOf(other, _failures),
  };

  /// A symptom on the wire; none for [Symptom.unknown] (nothing to send).
  static api.QuestionnaireUpdateSymptomsArrayModel? _wireSymptom(
    Symptom symptom,
  ) => switch (symptom) {
    Symptom.none => api.QuestionnaireUpdateSymptomsArrayModel.none,
    Symptom.cough => api.QuestionnaireUpdateSymptomsArrayModel.cough,
    Symptom.vomiting => api.QuestionnaireUpdateSymptomsArrayModel.vomiting,
    Symptom.diarrhea => api.QuestionnaireUpdateSymptomsArrayModel.diarrhea,
    Symptom.appetiteLoss =>
      api.QuestionnaireUpdateSymptomsArrayModel.appetiteLoss,
    Symptom.itching => api.QuestionnaireUpdateSymptomsArrayModel.itching,
    Symptom.lameness => api.QuestionnaireUpdateSymptomsArrayModel.lameness,
    Symptom.unknown => null,
  };

  /// The temperament on the wire; [Temperament.unknown] has no value to
  /// send (the form never holds it).
  static api.QuestionnaireUpdateTemperamentModel _wireTemperament(
    Temperament temperament,
  ) => switch (temperament) {
    Temperament.calm => api.QuestionnaireUpdateTemperamentModel.calm,
    Temperament.stressed => api.QuestionnaireUpdateTemperamentModel.stressed,
    Temperament.mayBite => api.QuestionnaireUpdateTemperamentModel.mayBite,
    Temperament.unknown => throw ArgumentError.value(
      temperament,
      'temperament',
      'an unknown temperament cannot be sent',
    ),
  };

  static Questionnaire _read(api.QuestionnaireView view) => Questionnaire(
    status: switch (view.status) {
      api.QuestionnaireQuestionnaireViewStatusModel.notStarted =>
        QuestionnaireStatus.notStarted,
      api.QuestionnaireQuestionnaireViewStatusModel.submitted =>
        QuestionnaireStatus.submitted,
      api.QuestionnaireQuestionnaireViewStatusModel.unknown =>
        QuestionnaireStatus.unknown,
    },
    answers: _answers(view.answers?.questionnaireAnswersView),
    updatedAt: switch (view.updatedAt) {
      final DateTime at => clinicInstantOf(at),
      null => null,
    },
    editable: view.editable,
  );

  static Questionnaire _saved(api.SavedQuestionnaireView view) => Questionnaire(
    status: switch (view.status) {
      api.QuestionnaireUpdateQuestionnaireViewStatusModel.notStarted =>
        QuestionnaireStatus.notStarted,
      api.QuestionnaireUpdateQuestionnaireViewStatusModel.submitted =>
        QuestionnaireStatus.submitted,
      api.QuestionnaireUpdateQuestionnaireViewStatusModel.unknown =>
        QuestionnaireStatus.unknown,
    },
    answers: _answers(view.answers?.questionnaireAnswersView),
    updatedAt: switch (view.updatedAt) {
      final DateTime at => clinicInstantOf(at),
      null => null,
    },
    editable: view.editable,
  );

  static QuestionnaireAnswers? _answers(
    api.QuestionnaireAnswersView? view,
  ) => switch (view) {
    final api.QuestionnaireAnswersView answers => QuestionnaireAnswers(
      symptoms: Set.unmodifiable({
        for (final symptom in answers.symptoms)
          switch (symptom) {
            api.QuestionnaireAnswersViewSymptomsArrayModel.none => Symptom.none,
            api.QuestionnaireAnswersViewSymptomsArrayModel.cough =>
              Symptom.cough,
            api.QuestionnaireAnswersViewSymptomsArrayModel.vomiting =>
              Symptom.vomiting,
            api.QuestionnaireAnswersViewSymptomsArrayModel.diarrhea =>
              Symptom.diarrhea,
            api.QuestionnaireAnswersViewSymptomsArrayModel.appetiteLoss =>
              Symptom.appetiteLoss,
            api.QuestionnaireAnswersViewSymptomsArrayModel.itching =>
              Symptom.itching,
            api.QuestionnaireAnswersViewSymptomsArrayModel.lameness =>
              Symptom.lameness,
            api.QuestionnaireAnswersViewSymptomsArrayModel.unknown =>
              Symptom.unknown,
          },
      }),
      ongoingTreatment: answers.ongoingTreatment.has,
      treatmentDetails: answers.ongoingTreatment.details,
      temperament: switch (answers.temperament) {
        api.QuestionnaireAnswersViewTemperamentModel.calm => Temperament.calm,
        api.QuestionnaireAnswersViewTemperamentModel.stressed =>
          Temperament.stressed,
        api.QuestionnaireAnswersViewTemperamentModel.mayBite =>
          Temperament.mayBite,
        api.QuestionnaireAnswersViewTemperamentModel.unknown =>
          Temperament.unknown,
      },
      notes: answers.notes,
    ),
    null => null,
  };
}
