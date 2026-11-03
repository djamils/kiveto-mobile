import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';

/// The id of a published document, as the Portal API sends it.
extension type const DocumentId(String value);

/// The id of a prescription (not the id of its document).
extension type const PrescriptionId(String value);

/// A document the clinic published for the owner (`GET …/documents`).
final class Document {
  const new({
    required this.id,
    required this.kind,
    required this.title,
    required this.issuedAt,
    this.petIds = const [],
    this.unread = false,
    this.invoice,
    this.prescription,
  });

  final DocumentId id;
  final DocumentKind kind;

  /// As the clinic named it (`Facture PAR-2026-000067`).
  final String title;

  /// The pets it is about; empty for some invoices.
  final List<String> petIds;
  final ClinicInstant issuedAt;

  /// Not downloaded yet by this owner.
  final bool unread;

  /// The amount and payment of an invoice, read live by the server.
  final InvoiceSummary? invoice;

  /// The validity and renewal of a prescription, read live by the server.
  final PrescriptionSummary? prescription;

  /// This document once downloaded (the server marks it read then).
  Document markedRead() => unread
      ? Document(
          id: id,
          kind: kind,
          title: title,
          issuedAt: issuedAt,
          petIds: petIds,
          invoice: invoice,
          prescription: prescription,
        )
      : this;

  @override
  String toString() => 'Document(${id.value}, ${kind.name})';
}

/// The invoice part of a document.
final class InvoiceSummary {
  const new({required this.total, required this.paymentStatus});

  final Money total;
  final PaymentStatus paymentStatus;
}

/// The prescription part of a document. Whether a renewal may be asked is
/// the server's answer ([renewable], [renewal]), never computed here.
final class PrescriptionSummary {
  const new({
    required this.id,
    this.validUntil,
    this.renewable = false,
    this.renewal,
  });

  final PrescriptionId id;
  final LocalDate? validUntil;
  final bool renewable;

  /// The last renewal request of this prescription, if any.
  final RenewalRequest? renewal;
}

/// Where the last renewal request of a prescription stands; [unknown] for
/// a status this app does not know yet (or an answer it could not read).
enum RenewalStatus { submitted, done, rejected, closed, unknown }

/// The last renewal request of a prescription.
final class RenewalRequest {
  const new({
    required this.status,
    this.requestId,
    this.resultingPrescriptionId,
  });

  final RenewalStatus status;
  final String? requestId;

  /// The prescription the clinic issued in answer, when it did.
  final String? resultingPrescriptionId;
}

/// One page of documents, newest first; [nextCursor] reads the next one
/// (null on the last page).
final class DocumentPage {
  const new({this.items = const [], this.nextCursor});

  final List<Document> items;
  final String? nextCursor;
}
