// The questionnaire's form (screen 15): « Rien de particulier » at first,
// its exclusivity with the other symptoms (mockup 15's script), the
// treatment and temperament answered, the answers sent (trimmed, the
// details only with a treatment, the symptoms in order), a form made from
// answers already sent (unknown values dropped); the read models.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';

void main() {
  group('QuestionnaireForm', () {
    test('a new form: « Rien de particulier », nothing else answered, not '
        'complete', () {
      const form = QuestionnaireForm.initial();

      expect(form.symptoms, {Symptom.none});
      expect(form.ongoingTreatment, isNull);
      expect(form.temperament, isNull);
      expect(form.isComplete, isFalse);
      expect(form.toAnswers(), isNull);
    });

    test('a symptom replaces « Rien de particulier »; others add up; '
        '« Rien de particulier » again clears them', () {
      final cough = const QuestionnaireForm.initial().toggle(Symptom.cough);
      expect(cough.symptoms, {Symptom.cough});

      final both = cough.toggle(Symptom.itching);
      expect(both.symptoms, {Symptom.cough, Symptom.itching});

      final none = both.toggle(Symptom.none);
      expect(none.symptoms, {Symptom.none});
    });

    test('a symptom tapped again goes; « Rien de particulier » tapped again '
        'leaves nothing (not complete)', () {
      final answered = const QuestionnaireForm.initial()
          .withTreatment(ongoing: false)
          .withTemperament(Temperament.calm);
      expect(answered.isComplete, isTrue);

      final empty = answered.toggle(Symptom.none);
      expect(empty.symptoms, isEmpty);
      expect(empty.isComplete, isFalse);
      expect(empty.toAnswers(), isNull);

      final lameness = empty.toggle(Symptom.lameness);
      expect(lameness.toggle(Symptom.lameness).symptoms, isEmpty);
    });

    test('a toggle keeps the treatment and the temperament; an unknown '
        'symptom is no choice', () {
      final form = const QuestionnaireForm.initial()
          .withTreatment(ongoing: true)
          .withTemperament(Temperament.mayBite)
          .toggle(Symptom.vomiting);

      expect(form.ongoingTreatment, isTrue);
      expect(form.temperament, Temperament.mayBite);
      expect(form.toggle(Symptom.unknown), same(form));
    });

    test('the treatment and the temperament, each answered once; an unknown '
        'temperament is no answer', () {
      const form = QuestionnaireForm.initial();

      expect(form.withTreatment(ongoing: false).isComplete, isFalse);
      expect(form.withTemperament(Temperament.stressed).isComplete, isFalse);
      final complete = form
          .withTreatment(ongoing: true)
          .withTemperament(Temperament.stressed);
      expect(complete.isComplete, isTrue);
      expect(complete.withTreatment(ongoing: false).ongoingTreatment, isFalse);
      expect(complete.withTemperament(Temperament.unknown).temperament, isNull);
    });

    test('the answers: symptoms in the questionnaire order, details and '
        'notes trimmed, blank: none', () {
      final form = const QuestionnaireForm.initial()
          .toggle(Symptom.lameness)
          .toggle(Symptom.cough)
          .withTreatment(ongoing: true)
          .withTemperament(Temperament.stressed);

      final answers = form.toAnswers(
        details: '  Antibiotique, 1 comprimé matin et soir ',
        notes: '   ',
      )!;

      expect(answers.symptoms.toList(), [Symptom.cough, Symptom.lameness]);
      expect(answers.ongoingTreatment, isTrue);
      expect(
        answers.treatmentDetails,
        'Antibiotique, 1 comprimé matin et soir',
      );
      expect(answers.temperament, Temperament.stressed);
      expect(answers.notes, isNull);

      final bare = form.toAnswers()!;
      expect(bare.treatmentDetails, isNull);
      expect(bare.notes, isNull);
    });

    test('no treatment: its details are not sent; the notes are', () {
      final answers = const QuestionnaireForm.initial()
          .withTreatment(ongoing: false)
          .withTemperament(Temperament.calm)
          .toAnswers(details: 'Ancien traitement', notes: ' Tousse la nuit ')!;

      expect(answers.symptoms, {Symptom.none});
      expect(answers.ongoingTreatment, isFalse);
      expect(answers.treatmentDetails, isNull);
      expect(answers.notes, 'Tousse la nuit');
    });

    test('a form of answers already sent; unknown values dropped', () {
      final form = QuestionnaireForm.from(
        const QuestionnaireAnswers(
          symptoms: {Symptom.cough, Symptom.unknown, Symptom.itching},
          ongoingTreatment: true,
          treatmentDetails: 'Antibiotique',
          temperament: Temperament.stressed,
          notes: 'La nuit',
        ),
      );

      expect(form.symptoms, {Symptom.cough, Symptom.itching});
      expect(form.ongoingTreatment, isTrue);
      expect(form.temperament, Temperament.stressed);
      expect(form.isComplete, isTrue);

      final unknown = QuestionnaireForm.from(
        const QuestionnaireAnswers(
          symptoms: {Symptom.unknown},
          ongoingTreatment: false,
          temperament: Temperament.unknown,
        ),
      );
      expect(unknown.symptoms, isEmpty);
      expect(unknown.temperament, isNull);
      expect(unknown.isComplete, isFalse);
    });
  });

  test('Questionnaire: its status, answers, when sent, whether editable', () {
    final at = ClinicInstant.parse('2026-11-04T02:00:06+01:00');
    const answers = QuestionnaireAnswers(
      symptoms: {Symptom.none},
      ongoingTreatment: false,
      temperament: Temperament.calm,
    );
    final sent = Questionnaire(
      status: QuestionnaireStatus.submitted,
      editable: true,
      answers: answers,
      updatedAt: at,
    );
    const empty = Questionnaire(
      status: QuestionnaireStatus.notStarted,
      editable: false,
    );

    expect(sent.answers, same(answers));
    expect(sent.updatedAt, at);
    expect(sent.editable, isTrue);
    expect(empty.answers, isNull);
    expect(empty.updatedAt, isNull);
    expect(answers.treatmentDetails, isNull);
    expect(answers.notes, isNull);
  });
}
