import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';

/// The exports of the account's data; throws an `ApiFailure`
/// (shared/domain). The server decides the quota (one export per 24 h:
/// `429 export_rate_limited`).
abstract interface class DataExportRepository {
  /// `GET /me/data-exports`, newest first.
  Future<List<DataExport>> exports();

  /// `POST /me/data-export`: the id of the new export, being built.
  Future<String> request();

  /// `GET /me/data-exports/{id}/file`: the archive of a ready export (a
  /// gone one: `NotFoundFailure`).
  Future<PortalFile> download(String id);
}
