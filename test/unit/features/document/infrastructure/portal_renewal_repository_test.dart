// PortalRenewalRepository on the real chain and the captures of
// 2026-11-04: the request sent (body, Idempotency-Key), its receipt (also
// the replay of an open request), the conditions by code, the status read
// by name (unknown kept), and the refusals (422 prescription_not_renewable,
// 429, 404, no answer).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/renewal.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_renewal_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _paris = ClinicId(_parisId);
const _prescriptionId = '01a19a12-8b44-7c87-b043-5d82ad91c574';
const _prescription = PrescriptionId(_prescriptionId);
const _path =
    '$api/clinics/$_parisId/prescriptions/$_prescriptionId/renewal-requests';
const _key = IdempotencyKey('renewal-intent-1');

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

void main() {
  late PortalHarness harness;
  late PortalRenewalRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalRenewalRepository(harness.http.server, harness.failures);
  });

  test('202 (capture): the condition and note sent with the key; the '
      'request submitted', () async {
    harness.backend.on(
      'POST',
      _path,
      PortalReply.fixture(
        'clinics.paris.prescriptions.renewal-requests.post.202.json',
        status: 202,
      ),
    );

    final receipt = await repository.requestRenewal(
      _paris,
      _prescription,
      const RenewalRequestDraft(
        condition: PetCondition.noImprovement,
        note: 'Il boite encore un peu.',
      ),
      _key,
    );

    final request = harness.backend.requests.single;
    expect(request.method, 'POST');
    expect(request.headers['Idempotency-Key'], 'renewal-intent-1');
    expect(_jsonOf(request), {
      'petCondition': 'no_improvement',
      'note': 'Il boite encore un peu.',
    });
    expect(receipt.requestId, '01a19a12-87fc-7cd1-a51e-c25f03efc697');
    expect(receipt.status, RenewalStatus.submitted);
  });

  test('the other conditions by code; no note', () async {
    final bodies = <Map<String, Object?>>[];
    harness.backend.onRequest('POST', _path, (request) {
      bodies.add(_jsonOf(request));
      return PortalReply.fixture(
        'clinics.paris.prescriptions.renewal-requests.post.202.json',
        status: 202,
      );
    });

    for (final condition in [
      PetCondition.improved,
      PetCondition.adverseEffects,
    ]) {
      await repository.requestRenewal(
        _paris,
        _prescription,
        RenewalRequestDraft(condition: condition),
        _key,
      );
    }

    expect(bodies.map((body) => body['petCondition']), [
      'improved',
      'adverse_effects',
    ]);
    expect(bodies.first['note'], isNull);
  });

  test('a status this app does not know: unknown', () async {
    harness.backend.on(
      'POST',
      _path,
      PortalReply.json('{"requestId":"r-1","status":"queued"}', status: 202),
    );

    final receipt = await repository.requestRenewal(
      _paris,
      _prescription,
      const RenewalRequestDraft(condition: PetCondition.improved),
      _key,
    );

    expect(receipt.requestId, 'r-1');
    expect(receipt.status, RenewalStatus.unknown);
  });

  test('refused (422 prescription_not_renewable, capture): its code', () async {
    harness.backend.on(
      'POST',
      _path,
      PortalReply.fixture(
        'clinics.paris.prescriptions.renewal-requests.'
        'not-renewable.post.422.json',
        status: 422,
      ),
    );

    await expectLater(
      repository.requestRenewal(
        _paris,
        _prescription,
        const RenewalRequestDraft(condition: PetCondition.improved),
        _key,
      ),
      throwsA(
        isA<BusinessFailure>().having(
          (failure) => failure.code,
          'code',
          'prescription_not_renewable',
        ),
      ),
    );
  });

  for (final (name, reply, matcher) in [
    (
      '429 rate_limited',
      problem('rate_limited', 429),
      isA<RateLimitedFailure>(),
    ),
    ('404', problem('not_found', 404), isA<NotFoundFailure>()),
  ]) {
    test('$name: its failure', () async {
      harness.backend.on('POST', _path, reply);

      await expectLater(
        repository.requestRenewal(
          _paris,
          _prescription,
          const RenewalRequestDraft(condition: PetCondition.improved),
          _key,
        ),
        throwsA(matcher),
      );
    });
  }

  test('no answer: a NetworkFailure', () async {
    await expectLater(
      repository.requestRenewal(
        _paris,
        _prescription,
        const RenewalRequestDraft(condition: PetCondition.improved),
        _key,
      ),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
