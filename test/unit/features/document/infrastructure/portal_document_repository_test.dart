// PortalDocumentRepository on the real chain and the captures: Julien's
// Paris invoices, Garnier's three pages and prescriptions, the ?type= and
// ?cursor= query strings, every enum of the contract (unknown kept), the
// prescription and its 404, the file through the 302 and its PDF bytes.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_document_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _paris = ClinicId('01960000-0000-7000-8000-000000000001');
const _documents =
    '$api/clinics/01960000-0000-7000-8000-000000000001/documents';
const _prescriptions =
    '$api/clinics/01960000-0000-7000-8000-000000000001/prescriptions';
const _pepito = '01a19a10-21af-748a-b841-690b02e4fe18';

/// The `nextCursor` of a capture.
String _cursorOf(String fixture) =>
    (jsonDecode(File('$portalFixtures/$fixture').readAsStringSync())
            as Map<String, Object?>)['nextCursor']!
        as String;

/// One document of the list, as the contract sends it, with [changes].
Map<String, Object?> _view(Map<String, Object?> changes) => {
  'id': 'd',
  'type': 'report',
  'title': 'Document',
  'petIds': <String>[],
  'issuedAt': '2026-10-24T09:40:00+02:00',
  'unread': false,
  'invoice': null,
  'prescription': null,
  ...changes,
};

Map<String, Object?> _invoice(String status) => {
  'total': {'amount': 100, 'currency': 'EUR'},
  'paymentStatus': status,
};

Map<String, Object?> _prescription(Object? renewalStatus) => {
  'id': 'p',
  'validUntil': null,
  'renewable': false,
  'renewalStatus': renewalStatus,
};

void main() {
  late PortalHarness harness;
  late PortalDocumentRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalDocumentRepository(
      harness.http.server,
      PortalFileDownloader(harness.http.dio, devConfig, harness.failures),
      harness.failures,
    );
  });

  group('documents', () {
    test('Julien, Paris (capture): two invoices, the first unread', () async {
      harness.backend.on(
        'GET',
        _documents,
        PortalReply.fixture('clinics.paris.documents.get.200.json'),
      );

      final page = await repository.documents(_paris);

      expect(page.nextCursor, isNull);
      final [first, second] = page.items;
      expect(
        first.id,
        const DocumentId('01a19a12-65aa-78e6-b439-fe4e297698d8'),
      );
      expect(first.kind, DocumentKind.invoice);
      expect(first.title, 'Facture PAR-2026-000067');
      expect(first.petIds, ['01a19a0f-128f-7a54-b39c-e01a30ee66d2']);
      expect(first.issuedAt, ClinicInstant.parse('2026-10-24T09:40:00+02:00'));
      expect(first.issuedAt.offset, const Duration(hours: 2));
      expect(first.unread, isTrue);
      expect(first.invoice!.total, Money(5200, 'EUR'));
      expect(first.invoice!.paymentStatus, PaymentStatus.paid);
      expect(first.prescription, isNull);
      expect(second.title, 'Facture PAR-2026-000066');
      expect(second.unread, isFalse);
      expect(second.invoice!.total, Money(7800, 'EUR'));
      final request = harness.backend.requests.single;
      expect(request.pathWithQuery, _documents);
      expect(bearerOf(request), 'Bearer A');
    });

    test('Lyon (capture): no document', () async {
      const lyon = ClinicId('01960000-0000-7000-8000-000000000101');
      harness.backend.on(
        'GET',
        '$api/clinics/${lyon.value}/documents',
        PortalReply.fixture('clinics.lyon.documents.get.200.json'),
      );

      final page = await repository.documents(lyon);

      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('Garnier (captures): three pages through ?cursor=', () async {
      final cursor1 = _cursorOf('clinics.paris.documents.garnier.get.200.json');
      final cursor2 = _cursorOf(
        'clinics.paris.documents.garnier-page2.get.200.json',
      );
      harness.backend
        ..on(
          'GET',
          _documents,
          PortalReply.fixture('clinics.paris.documents.garnier.get.200.json'),
        )
        ..on(
          'GET',
          '$_documents?cursor=$cursor1',
          PortalReply.fixture(
            'clinics.paris.documents.garnier-page2.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$_documents?cursor=$cursor2',
          PortalReply.fixture(
            'clinics.paris.documents.garnier-page3.get.200.json',
          ),
        );

      final page1 = await repository.documents(_paris);
      final page2 = await repository.documents(_paris, cursor: cursor1);
      final page3 = await repository.documents(
        _paris,
        cursor: page2.nextCursor,
      );

      expect(page1.items, hasLength(20));
      expect(page1.nextCursor, cursor1);
      expect(page2.items, hasLength(20));
      expect(page2.nextCursor, cursor2);
      expect(page3.items, hasLength(11));
      expect(page3.nextCursor, isNull);
      expect(harness.backend.requests.map((r) => r.pathWithQuery), [
        _documents,
        '$_documents?cursor=$cursor1',
        '$_documents?cursor=$cursor2',
      ]);

      // ORD-36: renewable, no request yet.
      final ord36 = page1.items.first;
      expect(ord36.kind, DocumentKind.prescription);
      expect(ord36.title, 'Ordonnance ORD-2026-000036');
      expect(ord36.petIds, [_pepito]);
      expect(ord36.issuedAt.offset, const Duration(hours: 1));
      expect(ord36.invoice, isNull);
      final summary36 = ord36.prescription!;
      expect(
        summary36.id,
        const PrescriptionId('01a19a12-8b44-7c87-b043-5d82ad91c574'),
      );
      expect(summary36.validUntil, LocalDate(2027, 11, 2));
      expect(summary36.renewable, isTrue);
      expect(summary36.renewal, isNull);

      // PAR-2026-000025: unpaid.
      final unpaid = page1.items[1];
      expect(unpaid.title, 'Facture PAR-2026-000025');
      expect(unpaid.invoice!.total, Money(9600, 'EUR'));
      expect(unpaid.invoice!.paymentStatus, PaymentStatus.unpaid);

      // A report: neither invoice nor prescription.
      final report = page1.items[2];
      expect(report.kind, DocumentKind.report);
      expect(report.title, 'Compte rendu du 31/08/2026');
      expect(report.invoice, isNull);
      expect(report.prescription, isNull);

      // ORD-08: renewal done, with the resulting prescription.
      final done = page1.items[3].prescription!.renewal!;
      expect(done.status, RenewalStatus.done);
      expect(done.requestId, '01a19a12-8983-7a72-b4fa-fe2105c858c1');
      expect(
        done.resultingPrescriptionId,
        '01a19a12-8b44-7c87-b043-5d82ad91c574',
      );

      // ORD-07: rejected, nothing resulting.
      final rejected = page1.items[7].prescription!.renewal!;
      expect(rejected.status, RenewalStatus.rejected);
      expect(rejected.resultingPrescriptionId, isNull);

      // PAR-2026-000022: an invoice without pet.
      expect(page1.items[8].title, 'Facture PAR-2026-000022');
      expect(page1.items[8].petIds, isEmpty);

      // ORD-05 (page 2): a request still open.
      final submitted = page2.items
          .singleWhere((d) => d.title == 'Ordonnance ORD-2026-000005')
          .prescription!;
      expect(submitted.renewal!.status, RenewalStatus.submitted);
      expect(submitted.validUntil, LocalDate(2026, 12, 22));
    });

    test('the prescriptions filter (capture): ?type=prescription', () async {
      harness.backend.on(
        'GET',
        '$_documents?type=prescription',
        PortalReply.fixture(
          'clinics.paris.documents.prescriptions.get.200.json',
        ),
      );

      final page = await repository.documents(
        _paris,
        kind: DocumentKind.prescription,
      );

      expect(page.items, hasLength(5));
      expect(
        page.items.map((d) => d.kind),
        everyElement(DocumentKind.prescription),
      );
    });

    test('every filter is sent as ?type=, after the cursor', () async {
      for (final (kind, type) in [
        (DocumentKind.report, 'report'),
        (DocumentKind.invoice, 'invoice'),
        (DocumentKind.labResult, 'lab_result'),
        (DocumentKind.certificate, 'certificate'),
      ]) {
        harness.backend.on(
          'GET',
          '$_documents?cursor=c1&type=$type',
          PortalReply.fixture('clinics.lyon.documents.get.200.json'),
        );

        final page = await repository.documents(
          _paris,
          kind: kind,
          cursor: 'c1',
        );

        expect(page.items, isEmpty, reason: type);
        expect(
          harness.backend.requests.last.pathWithQuery,
          '$_documents?cursor=c1&type=$type',
        );
      }
    });

    test(
      'the unknown kind cannot be sent: a ServerFailure, no request',
      () async {
        await expectLater(
          repository.documents(_paris, kind: DocumentKind.unknown),
          throwsA(isA<ServerFailure>()),
        );
        expect(harness.backend.requests, isEmpty);
      },
    );

    test('every kind, payment and renewal status; unknown ones kept', () async {
      harness.backend.on(
        'GET',
        _documents,
        PortalReply.json(
          jsonEncode({
            'items': [
              _view({'type': 'lab_result'}),
              _view({'type': 'certificate'}),
              _view({'type': 'vaccination_record'}),
              _view({'type': 'invoice', 'invoice': _invoice('partially_paid')}),
              _view({'type': 'invoice', 'invoice': _invoice('credited')}),
              _view({'type': 'invoice', 'invoice': _invoice('refunded')}),
              _view({
                'type': 'prescription',
                'prescription': _prescription({
                  'status': 'closed',
                  'requestId': 7,
                }),
              }),
              _view({
                'type': 'prescription',
                'prescription': _prescription({'status': 'archived'}),
              }),
              _view({
                'type': 'prescription',
                'prescription': _prescription({'status': 42}),
              }),
              _view({
                'type': 'prescription',
                'prescription': _prescription(<String, Object?>{}),
              }),
            ],
            'nextCursor': 'next',
          }),
        ),
      );

      final page = await repository.documents(_paris);

      expect(page.nextCursor, 'next');
      expect(page.items.take(3).map((d) => d.kind), [
        DocumentKind.labResult,
        DocumentKind.certificate,
        DocumentKind.unknown,
      ]);
      expect(page.items.skip(3).take(3).map((d) => d.invoice!.paymentStatus), [
        PaymentStatus.partiallyPaid,
        PaymentStatus.credited,
        PaymentStatus.unknown,
      ]);
      final renewals = [
        for (final document in page.items.skip(6)) document.prescription!,
      ];
      expect(renewals.first.validUntil, isNull);
      expect(renewals.first.renewable, isFalse);
      expect(renewals.map((p) => p.renewal!.status), [
        RenewalStatus.closed,
        RenewalStatus.unknown,
        RenewalStatus.unknown,
        RenewalStatus.unknown,
      ]);
      // A non-string id is no id.
      expect(renewals.first.renewal!.requestId, isNull);
    });

    test('400 cursor_invalid (capture): a BusinessFailure', () async {
      harness.backend.on(
        'GET',
        '$_documents?cursor=stale',
        PortalReply.fixture(
          'clinics.paris.documents.cursor-invalid.get.400.json',
          status: 400,
        ),
      );

      await expectLater(
        repository.documents(_paris, cursor: 'stale'),
        throwsA(
          isA<BusinessFailure>()
              .having((f) => f.code, 'code', 'cursor_invalid')
              .having((f) => f.statusCode, 'status', 400),
        ),
      );
    });

    test('404 not_found: the link is gone', () async {
      harness.backend.on('GET', _documents, problem('not_found', 404));

      await expectLater(
        repository.documents(_paris),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('no answer: a NetworkFailure', () async {
      await expectLater(
        repository.documents(_paris),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('prescription', () {
    const id = PrescriptionId('01a19a10-3d12-7911-83f9-9050f5a06273');

    test('ORD-05 (capture): its vet, pet and line', () async {
      harness.backend.on(
        'GET',
        '$_prescriptions/${id.value}',
        PortalReply.fixture('clinics.paris.prescriptions.get.200.json'),
      );

      final prescription = await repository.prescription(_paris, id);

      expect(prescription.id, id);
      expect(
        prescription.issuedAt,
        ClinicInstant.parse('2025-12-22T11:30:00+01:00'),
      );
      expect(prescription.vet, 'Dr Rousseau');
      expect(prescription.pet.id, '01a19a10-20d7-77bd-bbad-d251136402fc');
      expect(prescription.pet.name, 'Oscar');
      final line = prescription.lines.single;
      expect(line.label, 'Meloxidyl 1 mg/mL suspension buvable');
      expect(line.quantity, '2');
      expect(
        line.posologySummary,
        '0,1 mg/kg, 1×/j, pendant 60 jours, voie per os',
      );
    });

    test('a pet that left the files: no id', () async {
      harness.backend.on(
        'GET',
        '$_prescriptions/p',
        PortalReply.json(
          jsonEncode({
            'id': 'p',
            'issuedAt': '2025-12-22T11:30:00+01:00',
            'vet': 'Dr Rousseau',
            'pet': {'id': null, 'name': 'Filou'},
            'lines': <Object?>[],
          }),
        ),
      );

      final prescription = await repository.prescription(
        _paris,
        const PrescriptionId('p'),
      );

      expect(prescription.pet.id, isNull);
      expect(prescription.pet.name, 'Filou');
      expect(prescription.lines, isEmpty);
    });

    test('404 (capture): a NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        '$_prescriptions/gone',
        PortalReply.fixture(
          'clinics.paris.prescriptions.not-found.get.404.json',
          status: 404,
        ),
      );

      await expectLater(
        repository.prescription(_paris, const PrescriptionId('gone')),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('file', () {
    const id = DocumentId('01a19a12-65aa-78e6-b439-fe4e297698d8');
    const file = '$_documents/01a19a12-65aa-78e6-b439-fe4e297698d8/file';
    // The captured shape of the backend's signed URL (valid 5 min).
    const signed =
        '$api/files/documents/01960000-0000-7000-8000-000000000001/'
        '01a19a12-65aa-78e6-b439-fe4e297698d8/1'
        '?_expiration=1793710624'
        '&_hash=MzDejOoG2uYndUzh-y-eiTaWXFmpmQrPHZtTjxx8nUw';

    test('the 302 to the signed URL, then the PDF bytes (capture)', () async {
      final pdf = File('$portalFixtures/files.documents.get.200.pdf')
          .readAsBytesSync();
      harness.backend
        ..on(
          'GET',
          file,
          PortalReply.empty(
            302,
            headers: {
              'location': ['http://portal.kiveto.local:81$signed'],
            },
          ),
        )
        ..on(
          'GET',
          signed,
          PortalReply.bytes(
            pdf,
            contentType: 'application/pdf',
            headers: {
              'content-disposition': ['inline; filename="document.pdf"'],
            },
          ),
        );

      final downloaded = await repository.file(_paris, id);

      expect(downloaded.bytes, pdf);
      expect(String.fromCharCodes(downloaded.bytes.take(5)), '%PDF-');
      expect(downloaded.contentType, 'application/pdf');
      expect(downloaded.fileName, 'document.pdf');
      final [first, second] = harness.backend.requests;
      expect(first.pathWithQuery, file);
      expect(bearerOf(first), 'Bearer A');
      // Rewritten from the dev host to the dev base URL, query kept.
      expect(second.uri.toString(), 'http://10.0.2.2:81$signed');
      expect(second.pathWithQuery, signed);
      expect(second.uri.queryParameters, {
        '_expiration': '1793710624',
        '_hash': 'MzDejOoG2uYndUzh-y-eiTaWXFmpmQrPHZtTjxx8nUw',
      });
      expect(second.headers, isNot(contains('Authorization')));
    });

    test('the ids are one encoded path segment each', () async {
      harness.backend.on(
        'GET',
        '$api/clinics/a%2Fb/documents/c%20d/file',
        PortalReply.bytes(const [1, 2]),
      );

      final downloaded = await repository.file(
        const ClinicId('a/b'),
        const DocumentId('c d'),
      );

      expect(downloaded.bytes, [1, 2]);
      expect(downloaded.contentType, isNull);
      expect(downloaded.fileName, isNull);
    });

    test('404: a NotFoundFailure', () async {
      harness.backend.on('GET', file, problem('not_found', 404));

      await expectLater(
        repository.file(_paris, id),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
