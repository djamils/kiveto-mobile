import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The pre-visit questionnaire of an appointment (Portal API). Every method
/// throws an `ApiFailure` on a failure; whether the questionnaire may still
/// change and which answers are valid are the server's answers.
abstract interface class QuestionnaireRepository {
  /// `GET …/appointments/{id}/questionnaire`.
  Future<Questionnaire> questionnaire(
    ClinicId clinicId,
    AppointmentId appointmentId,
  );

  /// `PUT …/appointments/{id}/questionnaire`: [answers] replace the
  /// previous ones (naturally idempotent); the questionnaire as saved.
  Future<Questionnaire> save(
    ClinicId clinicId,
    AppointmentId appointmentId,
    QuestionnaireAnswers answers,
  );
}
