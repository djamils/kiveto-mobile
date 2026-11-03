import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/prescription.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';

/// The documents of a clinic; throws an `ApiFailure` (shared/domain).
abstract interface class DocumentRepository {
  /// `GET /clinics/{c}/documents`: the first page, or the one of [cursor];
  /// only the documents of [kind] when given.
  Future<DocumentPage> documents(
    ClinicId clinicId, {
    DocumentKind? kind,
    String? cursor,
  });

  /// `GET /clinics/{c}/prescriptions/{id}`.
  Future<Prescription> prescription(
    ClinicId clinicId,
    PrescriptionId prescriptionId,
  );

  /// The file of a document (`GET /clinics/{c}/documents/{id}/file`, which
  /// the server counts as a read).
  Future<PortalFile> file(ClinicId clinicId, DocumentId documentId);
}
