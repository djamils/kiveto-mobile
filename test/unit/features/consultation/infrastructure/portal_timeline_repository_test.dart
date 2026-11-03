// PortalTimelineRepository on the real chain and the captures: Oscar's two
// pages through ?cursor= (no limit sent), Pepito's documents, Julien's
// empty history, every document kind (unknown kept), a visit without vet
// or document, 400 cursor_invalid, 404, a network failure.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/consultation/infrastructure/portal_timeline_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _paris = ClinicId('01960000-0000-7000-8000-000000000001');
const _pets = '$api/clinics/01960000-0000-7000-8000-000000000001/pets';
const _oscar = '01a19a10-20d7-77bd-bbad-d251136402fc';
const _pepito = '01a19a10-21af-748a-b841-690b02e4fe18';

/// The `nextCursor` of a capture.
String _cursorOf(String fixture) =>
    (jsonDecode(File('$portalFixtures/$fixture').readAsStringSync())
            as Map<String, Object?>)['nextCursor']!
        as String;

void main() {
  late PortalHarness harness;
  late PortalTimelineRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalTimelineRepository(
      harness.http.server,
      harness.failures,
    );
  });

  test('Oscar (captures): 20 visits, then 3 through ?cursor=; no limit '
      'sent', () async {
    final cursor = _cursorOf(
      'clinics.paris.pet.timeline.garnier-oscar.get.200.json',
    );
    harness.backend
      ..on(
        'GET',
        '$_pets/$_oscar/timeline',
        PortalReply.fixture(
          'clinics.paris.pet.timeline.garnier-oscar.get.200.json',
        ),
      )
      ..on(
        'GET',
        '$_pets/$_oscar/timeline?cursor=$cursor',
        PortalReply.fixture(
          'clinics.paris.pet.timeline.garnier-oscar-page2.get.200.json',
        ),
      );

    final page1 = await repository.timeline(_paris, _oscar);
    final page2 = await repository.timeline(_paris, _oscar, cursor: cursor);

    expect(page1.items, hasLength(20));
    expect(page1.nextCursor, cursor);
    expect(page2.items, hasLength(3));
    expect(page2.nextCursor, isNull);
    final first = page1.items.first;
    expect(first.visitId, '01a19a10-6488-7365-bfb1-ad3f546619c5');
    expect(first.date, ClinicInstant.parse('2026-08-18T17:45:00+02:00'));
    expect(first.date.offset, const Duration(hours: 2));
    expect(first.vet, 'Dr Lucie Bernard');
    expect(first.title, 'Bilan thyroïdien');
    final document = first.documents.single;
    expect(document.id, '01a19a12-5fc2-71c0-b88b-f24f681822c2');
    expect(document.kind, DocumentKind.report);
    expect(harness.backend.requests.map((r) => r.pathWithQuery), [
      '$_pets/$_oscar/timeline',
      '$_pets/$_oscar/timeline?cursor=$cursor',
    ]);
    expect(bearerOf(harness.backend.requests.first), 'Bearer A');
  });

  test('Pepito (capture): a report and a prescription', () async {
    harness.backend.on(
      'GET',
      '$_pets/$_pepito/timeline',
      PortalReply.fixture(
        'clinics.paris.pet.timeline.garnier-pepito.get.200.json',
      ),
    );

    final page = await repository.timeline(_paris, _pepito);

    final boiterie = page.items.first;
    expect(boiterie.title, 'Boiterie');
    expect(boiterie.vet, 'Dr Éric Rousseau');
    expect(boiterie.documents.map((d) => d.kind), [
      DocumentKind.report,
      DocumentKind.prescription,
    ]);
    expect(page.items, hasLength(3));
    expect(page.nextCursor, isNull);
  });

  test('Julien (capture): no visit shared', () async {
    harness.backend.on(
      'GET',
      '$_pets/p/timeline',
      PortalReply.fixture('clinics.paris.pet.timeline.get.200.json'),
    );

    final page = await repository.timeline(_paris, 'p');

    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
  });

  test('every kind (unknown kept); a visit without vet or document', () async {
    harness.backend.on(
      'GET',
      '$_pets/p/timeline',
      PortalReply.json(
        jsonEncode({
          'items': [
            {
              'visitId': 'v1',
              'date': '2026-01-26T09:15:00+01:00',
              'vet': null,
              'title': 'Conjonctivite',
              'documents': [
                for (final type in [
                  'report',
                  'prescription',
                  'invoice',
                  'lab_result',
                  'certificate',
                  'vaccination_record',
                ])
                  {'id': type, 'type': type},
              ],
            },
            {
              'visitId': 'v2',
              'date': '2025-12-22T11:00:00+01:00',
              'vet': 'Dr Hélène Morel',
              'title': 'Bilan sanguin',
              'documents': <Object?>[],
            },
          ],
          'nextCursor': null,
        }),
      ),
    );

    final [first, second] = (await repository.timeline(_paris, 'p')).items;

    expect(first.vet, isNull);
    expect(first.documents.map((d) => d.kind), [
      DocumentKind.report,
      DocumentKind.prescription,
      DocumentKind.invoice,
      DocumentKind.labResult,
      DocumentKind.certificate,
      DocumentKind.unknown,
    ]);
    expect(second.documents, isEmpty);
  });

  test('400 cursor_invalid (capture): a BusinessFailure', () async {
    harness.backend.on(
      'GET',
      '$_pets/$_oscar/timeline?cursor=stale',
      PortalReply.fixture(
        'clinics.paris.pet.timeline.cursor-invalid.get.400.json',
        status: 400,
      ),
    );

    await expectLater(
      repository.timeline(_paris, _oscar, cursor: 'stale'),
      throwsA(
        isA<BusinessFailure>()
            .having((f) => f.code, 'code', 'cursor_invalid')
            .having((f) => f.statusCode, 'status', 400),
      ),
    );
  });

  test('404 (capture): a NotFoundFailure', () async {
    harness.backend.on(
      'GET',
      '$_pets/gone/timeline',
      PortalReply.fixture(
        'clinics.paris.pet.not-found.get.404.json',
        status: 404,
      ),
    );

    await expectLater(
      repository.timeline(_paris, 'gone'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('no answer: a NetworkFailure', () async {
    await expectLater(
      repository.timeline(_paris, _oscar),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
