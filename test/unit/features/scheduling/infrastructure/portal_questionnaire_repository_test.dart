// PortalQuestionnaireRepository on the real chain and the captures of
// 2026-11-04: the questionnaire not started, submitted (still editable),
// closed with and without answers, gone (404); the answers saved, with the
// body sent; every enum of the contract (unknown kept); the refusals
// (422 validation_failed, 422 questionnaire_locked).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_questionnaire_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _paris = ClinicId(_parisId);
const _appointmentId = '01a1a297-4a0a-7093-83f7-14de2798613e';
const _appointment = AppointmentId(_appointmentId);
const _path =
    '$api/clinics/$_parisId/appointments/$_appointmentId/questionnaire';

/// The capture [fixture] with [change] applied to its JSON body.
PortalReply _edited(
  String fixture,
  void Function(Map<String, Object?> body) change, {
  int status = 200,
}) {
  final body = jsonDecode(
    File('$portalFixtures/$fixture').readAsStringSync(),
  ) as Map<String, Object?>;
  change(body);
  return PortalReply.json(jsonEncode(body), status: status);
}

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

const _coughAndItching = QuestionnaireAnswers(
  symptoms: {Symptom.cough, Symptom.itching},
  ongoingTreatment: true,
  treatmentDetails: 'Antibiotique, 1 comprimé matin et soir',
  temperament: Temperament.stressed,
  notes: 'Tousse surtout la nuit depuis une semaine.',
);

void main() {
  late PortalHarness harness;
  late PortalQuestionnaireRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalQuestionnaireRepository(
      harness.http.server,
      harness.failures,
    );
  });

  group('questionnaire', () {
    test('not started (capture): no answers, no date, editable', () async {
      harness.backend.on(
        'GET',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.get.200.json',
        ),
      );

      final questionnaire = await repository.questionnaire(
        _paris,
        _appointment,
      );

      expect(questionnaire.status, QuestionnaireStatus.notStarted);
      expect(questionnaire.answers, isNull);
      expect(questionnaire.updatedAt, isNull);
      expect(questionnaire.editable, isTrue);
      expect(harness.backend.requests.single.method, 'GET');
    });

    test('submitted (capture): the answers and when, in the clinic offset; '
        'still editable', () async {
      harness.backend.on(
        'GET',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.submitted.get.200.json',
        ),
      );

      final questionnaire = await repository.questionnaire(
        _paris,
        _appointment,
      );

      expect(questionnaire.status, QuestionnaireStatus.submitted);
      expect(questionnaire.editable, isTrue);
      expect(
        questionnaire.updatedAt,
        ClinicInstant.parse('2026-11-04T02:00:06+01:00'),
      );
      final answers = questionnaire.answers!;
      expect(answers.symptoms, {Symptom.cough, Symptom.itching});
      expect(answers.ongoingTreatment, isTrue);
      expect(
        answers.treatmentDetails,
        'Antibiotique, 1 comprimé matin et soir',
      );
      expect(answers.temperament, Temperament.stressed);
      expect(answers.notes, 'Tousse surtout la nuit depuis une semaine.');
    });

    test("closed (Garnier's visit, capture): its answers, no treatment, "
        'not editable; closed without answers', () async {
      harness.backend.on(
        'GET',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.locked.get.200.json',
        ),
      );

      final locked = await repository.questionnaire(_paris, _appointment);

      expect(locked.editable, isFalse);
      expect(locked.status, QuestionnaireStatus.submitted);
      expect(locked.updatedAt?.offset, const Duration(hours: 2));
      expect(locked.answers?.symptoms, {
        Symptom.appetiteLoss,
        Symptom.diarrhea,
      });
      expect(locked.answers?.ongoingTreatment, isFalse);
      expect(locked.answers?.treatmentDetails, isNull);

      harness.backend.on(
        'GET',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.'
          'locked-not-started.get.200.json',
        ),
      );
      final empty = await repository.questionnaire(_paris, _appointment);
      expect(empty.editable, isFalse);
      expect(empty.status, QuestionnaireStatus.notStarted);
      expect(empty.answers, isNull);
    });

    test('every symptom and temperament of the contract; values this app '
        'does not know kept unknown', () async {
      harness.backend.on(
        'GET',
        _path,
        _edited(
          'clinics.paris.appointment.questionnaire.submitted.get.200.json',
          (body) {
            body['status'] = 'archived';
            final answers = body['answers']! as Map<String, Object?>;
            answers['symptoms'] = [
              'none',
              'vomiting',
              'diarrhea',
              'appetite_loss',
              'lameness',
              'sneezing',
            ];
            answers['temperament'] = 'may_bite';
          },
        ),
      );

      final first = await repository.questionnaire(_paris, _appointment);

      expect(first.status, QuestionnaireStatus.unknown);
      expect(first.answers?.symptoms, {
        Symptom.none,
        Symptom.vomiting,
        Symptom.diarrhea,
        Symptom.appetiteLoss,
        Symptom.lameness,
        Symptom.unknown,
      });
      expect(first.answers?.temperament, Temperament.mayBite);

      for (final (wire, temperament) in [
        ('calm', Temperament.calm),
        ('grumpy', Temperament.unknown),
      ]) {
        harness.backend.on(
          'GET',
          _path,
          _edited(
            'clinics.paris.appointment.questionnaire.submitted.get.200.json',
            (body) =>
                (body['answers']! as Map<String, Object?>)['temperament'] =
                    wire,
          ),
        );
        final read = await repository.questionnaire(_paris, _appointment);
        expect(read.answers?.temperament, temperament, reason: wire);
      }
    });

    test('a cancelled appointment (404, capture): a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.cancelled.get.404.json',
          status: 404,
        ),
      );

      await expectLater(
        repository.questionnaire(_paris, _appointment),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('save', () {
    test('PUT the answers (capture): version 1, the codes, the treatment; '
        'the questionnaire as saved', () async {
      harness.backend.on(
        'PUT',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.put.200.json',
        ),
      );

      final saved = await repository.save(
        _paris,
        _appointment,
        _coughAndItching,
      );

      final request = harness.backend.requests.single;
      expect(request.method, 'PUT');
      expect(_jsonOf(request), {
        'version': 1,
        'symptoms': ['cough', 'itching'],
        'ongoingTreatment': {
          'has': true,
          'details': 'Antibiotique, 1 comprimé matin et soir',
        },
        'temperament': 'stressed',
        'notes': 'Tousse surtout la nuit depuis une semaine.',
      });
      expect(saved.status, QuestionnaireStatus.submitted);
      expect(saved.editable, isTrue);
      expect(saved.updatedAt, ClinicInstant.parse('2026-11-04T02:00:06+01:00'));
      expect(saved.answers?.symptoms, {Symptom.cough, Symptom.itching});
      expect(saved.answers?.notes, _coughAndItching.notes);
    });

    test('every symptom and temperament sent by its code; an unknown symptom '
        'is not sent; no treatment, no notes', () async {
      final bodies = <Map<String, Object?>>[];
      harness.backend.onRequest('PUT', _path, (request) {
        bodies.add(_jsonOf(request));
        return PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.put.200.json',
        );
      });

      for (final temperament in [Temperament.calm, Temperament.mayBite]) {
        await repository.save(
          _paris,
          _appointment,
          QuestionnaireAnswers(
            symptoms: const {
              Symptom.none,
              Symptom.vomiting,
              Symptom.diarrhea,
              Symptom.appetiteLoss,
              Symptom.lameness,
              Symptom.unknown,
            },
            ongoingTreatment: false,
            temperament: temperament,
          ),
        );
      }

      expect(bodies.first['symptoms'], [
        'none',
        'vomiting',
        'diarrhea',
        'appetite_loss',
        'lameness',
      ]);
      expect(bodies.first['ongoingTreatment'], {'has': false, 'details': null});
      expect(bodies.first['temperament'], 'calm');
      expect(bodies.first['notes'], isNull);
      expect(bodies.last['temperament'], 'may_bite');
    });

    test('an unknown temperament cannot be sent: nothing goes', () async {
      await expectLater(
        repository.save(
          _paris,
          _appointment,
          const QuestionnaireAnswers(
            symptoms: {Symptom.none},
            ongoingTreatment: false,
            temperament: Temperament.unknown,
          ),
        ),
        throwsArgumentError,
      );
      expect(harness.backend.requests, isEmpty);
    });

    test('the saved status of the contract, unknown kept; no date', () async {
      for (final (wire, status) in [
        ('not_started', QuestionnaireStatus.notStarted),
        ('closed', QuestionnaireStatus.unknown),
      ]) {
        harness.backend.on(
          'PUT',
          _path,
          _edited('clinics.paris.appointment.questionnaire.put.200.json', (
            body,
          ) {
            body['status'] = wire;
            body['answers'] = null;
            body['updatedAt'] = null;
          }),
        );

        final saved = await repository.save(
          _paris,
          _appointment,
          _coughAndItching,
        );

        expect(saved.status, status, reason: wire);
        expect(saved.answers, isNull);
        expect(saved.updatedAt, isNull);
      }
    });

    test('« none » with another symptom (422 validation_failed, capture): '
        'the violation on symptoms', () async {
      harness.backend.on(
        'PUT',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.validation.put.422.json',
          status: 422,
        ),
      );

      final failure = await repository
          .save(_paris, _appointment, _coughAndItching)
          .then<Object?>((_) => null, onError: (Object error) => error);

      expect(failure, isA<ValidationFailure>());
      final violation = (failure! as ValidationFailure).violations.single;
      expect(violation.propertyPath, 'symptoms');
      expect(
        violation.message,
        '« Aucun symptôme » ne se combine pas avec un autre symptôme.',
      );
    });

    test('the appointment started (422 questionnaire_locked, capture): a '
        'BusinessFailure with its code', () async {
      harness.backend.on(
        'PUT',
        _path,
        PortalReply.fixture(
          'clinics.paris.appointment.questionnaire.locked.put.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.save(_paris, _appointment, _coughAndItching),
        throwsA(
          isA<BusinessFailure>().having(
            (failure) => failure.code,
            'code',
            'questionnaire_locked',
          ),
        ),
      );
    });
  });
}
