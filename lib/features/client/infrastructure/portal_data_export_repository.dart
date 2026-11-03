import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/features/client/domain/data_export_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [DataExportRepository] on the generated `AccountApi`; the archive
/// through the [PortalFileDownloader] (never the generated
/// `getDataExportFile` / `FilesApi.downloadDataExport`, whose 302 dart:io
/// would follow to the unresolvable dev host).
///
/// The contract types the export's status and instants as plain strings:
/// a status this app does not know is `unknown`, an instant that does not
/// parse is an answer it cannot use (`ServerFailure`).
final class PortalDataExportRepository implements DataExportRepository {
  new(api.Server server, this._downloader, this._failures)
    : _api = api.AccountApi(server);

  final api.AccountApi _api;
  final PortalFileDownloader _downloader;
  final ApiFailureMapper _failures;

  @override
  Future<List<DataExport>> exports() async =>
      switch (await _api.listDataExports()) {
        TonikSuccess(value: api.ListDataExportsResponse200(:final body)) => [
          for (final view in body)
            DataExport(
              id: view.id,
              status: switch (view.status) {
                'pending' => DataExportStatus.pending,
                'ready' => DataExportStatus.ready,
                'failed' => DataExportStatus.failed,
                'expired' => DataExportStatus.expired,
                _ => DataExportStatus.unknown,
              },
              requestedAt: _instant(view.requestedAt),
              readyAt: _optionalInstant(view.readyAt),
              expiresAt: _optionalInstant(view.expiresAt),
            ),
        ],
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<String> request() async => switch (await _api.requestDataExport()) {
    TonikSuccess(value: api.RequestDataExportResponse202(:final body)) =>
      body.id,
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<PortalFile> download(String id) async {
    final file = await _downloader.download(
      '/api/portal/v1/me/data-exports/${Uri.encodeComponent(id)}/file',
    );
    return PortalFile(
      file.bytes,
      contentType: file.contentType,
      fileName: file.fileName,
    );
  }

  static DateTime _instant(String wire) {
    try {
      return DateTime.parse(wire).toUtc();
    } on FormatException {
      throw ServerFailure(detail: 'data export instant: $wire');
    }
  }

  static DateTime? _optionalInstant(String? wire) =>
      wire == null ? null : _instant(wire);
}
