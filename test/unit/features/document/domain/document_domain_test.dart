// The domain of document: a document read once opened, the prescription
// and its lines, the defaults of the optional parts.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/prescription.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';

void main() {
  final issuedAt = ClinicInstant.parse('2026-10-24T09:40:00+02:00');

  group('Document', () {
    test('markedRead keeps everything but the unread flag', () {
      final invoice = InvoiceSummary(
        total: Money(5200, 'EUR'),
        paymentStatus: PaymentStatus.paid,
      );
      final prescription = PrescriptionSummary(
        id: const PrescriptionId('p'),
        validUntil: LocalDate(2027, 11, 2),
        renewable: true,
        renewal: const RenewalRequest(
          status: RenewalStatus.done,
          requestId: 'r',
          resultingPrescriptionId: 'p2',
        ),
      );
      final document = Document(
        id: const DocumentId('d'),
        kind: DocumentKind.invoice,
        title: 'Facture PAR-2026-000067',
        issuedAt: issuedAt,
        petIds: const ['pet'],
        unread: true,
        invoice: invoice,
        prescription: prescription,
      );

      final read = document.markedRead();

      expect(read.unread, isFalse);
      expect(read.id, const DocumentId('d'));
      expect(read.kind, DocumentKind.invoice);
      expect(read.title, 'Facture PAR-2026-000067');
      expect(read.issuedAt, issuedAt);
      expect(read.petIds, ['pet']);
      expect(read.invoice, same(invoice));
      expect(read.prescription, same(prescription));
      expect(read.prescription!.renewal!.status, RenewalStatus.done);
      expect(read.toString(), 'Document(d, invoice)');
    });

    test('a read document is itself once marked read; the defaults', () {
      final document = Document(
        id: const DocumentId('d'),
        kind: DocumentKind.report,
        title: 'Compte rendu',
        issuedAt: issuedAt,
      );

      expect(document.markedRead(), same(document));
      expect(document.unread, isFalse);
      expect(document.petIds, isEmpty);
      expect(document.invoice, isNull);
      expect(document.prescription, isNull);
    });

    test('a prescription summary and a renewal request have defaults', () {
      final summary = PrescriptionSummary(id: PrescriptionId('p'.trim()));
      final renewal = RenewalRequest(status: RenewalStatus.values.first);

      expect(summary.validUntil, isNull);
      expect(summary.renewable, isFalse);
      expect(summary.renewal, isNull);
      expect(renewal.status, RenewalStatus.submitted);
      expect(renewal.requestId, isNull);
      expect(renewal.resultingPrescriptionId, isNull);
    });

    test('a page: empty and last by default', () {
      final page = DocumentPage(items: List.empty());

      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
      expect(const DocumentPage().items, isEmpty);
    });
  });

  test('Prescription: its pet and lines', () {
    final prescription = Prescription(
      id: const PrescriptionId('p'),
      issuedAt: issuedAt,
      vet: 'Dr Rousseau',
      pet: PetReference(name: 'Oscar'.trim()),
      lines: [
        PrescriptionLine(
          label: 'Meloxidyl'.trim(),
          quantity: '2',
          posologySummary: '1×/j',
        ),
      ],
    );

    expect(prescription.pet.id, isNull);
    expect(prescription.pet.name, 'Oscar');
    expect(prescription.lines.single.label, 'Meloxidyl');
    expect(prescription.lines.single.quantity, '2');
    expect(prescription.lines.single.posologySummary, '1×/j');
    expect(prescription.toString(), 'Prescription(p, 1 lines)');
    expect(
      Prescription(
        id: const PrescriptionId('q'),
        issuedAt: issuedAt,
        vet: 'Dr X',
        pet: const PetReference(id: 'pet', name: 'Moka'),
      ).lines,
      isEmpty,
    );
  });
}
