import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/document_repository.dart';
import 'package:kiveto_mobile/features/document/domain/prescription.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [DocumentRepository] on the generated `DocumentsApi`; the files through
/// the [PortalFileDownloader] (never the generated `getDocumentFile`,
/// whose 302 dart:io would follow to the unresolvable dev host).
final class PortalDocumentRepository implements DocumentRepository {
  new(api.Server server, this._downloader, this._failures)
    : _api = api.DocumentsApi(server);

  final api.DocumentsApi _api;
  final PortalFileDownloader _downloader;
  final ApiFailureMapper _failures;

  @override
  Future<DocumentPage> documents(
    ClinicId clinicId, {
    DocumentKind? kind,
    String? cursor,
  }) async => switch (await _api.listDocuments(
    clinicId: clinicId.value,
    cursor: cursor,
    kind: kind == null ? null : _filter(kind),
  )) {
    TonikSuccess(value: api.ListDocumentsResponse200(:final body)) =>
      DocumentPage(
        items: [for (final view in body.items) _document(view)],
        nextCursor: body.nextCursor,
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<Prescription> prescription(
    ClinicId clinicId,
    PrescriptionId prescriptionId,
  ) async => switch (await _api.getPrescription(
    clinicId: clinicId.value,
    prescriptionId: prescriptionId.value,
  )) {
    TonikSuccess(value: api.GetPrescriptionResponse200(:final body)) =>
      Prescription(
        id: PrescriptionId(body.id),
        issuedAt: clinicInstantOf(body.issuedAt),
        vet: body.vet,
        pet: PetReference(id: body.pet.id, name: body.pet.name),
        lines: [
          for (final line in body.lines)
            PrescriptionLine(
              label: line.label,
              quantity: line.quantity,
              posologySummary: line.posologySummary,
            ),
        ],
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<PortalFile> file(ClinicId clinicId, DocumentId documentId) async {
    final file = await _downloader.download(
      '/api/portal/v1/clinics/${Uri.encodeComponent(clinicId.value)}'
      '/documents/${Uri.encodeComponent(documentId.value)}/file',
    );
    return PortalFile(
      file.bytes,
      contentType: file.contentType,
      fileName: file.fileName,
    );
  }

  /// The `?type=` filter; `unknown` cannot be sent (the client refuses to
  /// encode it: a `ServerFailure`).
  static api.ApiPortalV1ClinicsClinicIdDocumentsParametersModel _filter(
    DocumentKind kind,
  ) => switch (kind) {
    DocumentKind.report => .report,
    DocumentKind.prescription => .prescription,
    DocumentKind.invoice => .invoice,
    DocumentKind.labResult => .labResult,
    DocumentKind.certificate => .certificate,
    DocumentKind.unknown => .unknown,
  };

  static Document _document(api.DocumentView view) => Document(
    id: DocumentId(view.id),
    kind: switch (view.kind) {
      api.DocumentViewTypeModel.report => DocumentKind.report,
      api.DocumentViewTypeModel.prescription => DocumentKind.prescription,
      api.DocumentViewTypeModel.invoice => DocumentKind.invoice,
      api.DocumentViewTypeModel.labResult => DocumentKind.labResult,
      api.DocumentViewTypeModel.certificate => DocumentKind.certificate,
      api.DocumentViewTypeModel.unknown => DocumentKind.unknown,
    },
    title: view.title,
    petIds: view.petIds,
    issuedAt: clinicInstantOf(view.issuedAt),
    unread: view.unread,
    invoice: switch (view.invoice?.invoiceSummaryView) {
      final api.InvoiceSummaryView invoice => InvoiceSummary(
        total: Money(invoice.total.amount, invoice.total.currency),
        paymentStatus: _paymentStatus(invoice.paymentStatus),
      ),
      null => null,
    },
    prescription: switch (view.prescription?.prescriptionSummaryView) {
      final api.PrescriptionSummaryView prescription => PrescriptionSummary(
        id: PrescriptionId(prescription.id),
        validUntil: switch (prescription.validUntil) {
          final Date date => localDateOf(date),
          null => null,
        },
        renewable: prescription.renewable,
        renewal: _renewal(prescription.renewalStatus),
      ),
      null => null,
    },
  );

  static PaymentStatus _paymentStatus(
    api.InvoiceSummaryViewPaymentStatusModel status,
  ) => switch (status) {
    api.InvoiceSummaryViewPaymentStatusModel.unpaid => PaymentStatus.unpaid,
    api.InvoiceSummaryViewPaymentStatusModel.partiallyPaid =>
      PaymentStatus.partiallyPaid,
    api.InvoiceSummaryViewPaymentStatusModel.paid => PaymentStatus.paid,
    api.InvoiceSummaryViewPaymentStatusModel.credited => PaymentStatus.credited,
    api.InvoiceSummaryViewPaymentStatusModel.unknown => PaymentStatus.unknown,
  };

  /// The contract leaves `renewalStatus` an open object: a `status` this
  /// app does not know, or no string at all, is [RenewalStatus.unknown].
  static RenewalRequest? _renewal(Map<String, Object?>? renewal) =>
      switch (renewal) {
        null => null,
        _ => RenewalRequest(
          status: switch (renewal['status']) {
            'submitted' => RenewalStatus.submitted,
            'done' => RenewalStatus.done,
            'rejected' => RenewalStatus.rejected,
            'closed' => RenewalStatus.closed,
            _ => RenewalStatus.unknown,
          },
          requestId: _string(renewal['requestId']),
          resultingPrescriptionId: _string(renewal['resultingPrescriptionId']),
        ),
      };

  static String? _string(Object? value) => value is String ? value : null;
}
