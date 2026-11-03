import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/api_config.dart';
import 'package:kiveto_mobile/core/network/auth_interceptor.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

/// A downloaded file: its bytes, and what the server said about them.
final class DownloadedFile {
  const new(this.bytes, {this.contentType, this.fileName});

  final Uint8List bytes;

  /// `application/pdf`…
  final String? contentType;

  /// From `Content-Disposition: …; filename="…"`.
  final String? fileName;
}

/// Downloads the files of the Portal API (a document, a vaccination
/// booklet, a data export).
///
/// Those routes answer 302 to a signed, public `/files/…` URL valid 5 min
/// (the dev chain rewrites it to the base URL); Dio does not follow it
/// itself (the emulator could not resolve the dev host): the first request
/// reads the `Location`, the second fetches it without the Bearer token.
final class PortalFileDownloader {
  const new(this._dio, this._config, this._failures);

  final Dio _dio;
  final ApiConfig _config;
  final ApiFailureMapper _failures;

  static final _fileName = RegExp('filename="?([^";]+)"?');

  /// Downloads [apiPath] (`/api/portal/v1/clinics/{c}/documents/{id}/file`,
  /// `…/vaccination-booklet`, `/me/data-exports/{id}/file`); throws an
  /// [ApiFailure].
  Future<DownloadedFile> download(String apiPath) async {
    final source = _config.baseUrl.resolve(apiPath);
    try {
      final first = await _dio.getUri<List<int>>(
        source,
        options: Options(
          followRedirects: false,
          responseType: ResponseType.bytes,
        ),
      );
      final status = first.statusCode ?? 200;
      if (status < 300) return _fileOf(first);
      final location = first.headers['location']?.firstOrNull;
      if (location == null) throw ServerFailure(statusCode: status);
      final file = await _dio.getUri<List<int>>(
        source.resolve(location),
        options: Options(
          responseType: ResponseType.bytes,
          extra: {AuthInterceptor.anonymousKey: true},
        ),
      );
      return _fileOf(file);
    } on DioException catch (error) {
      throw _failures.fromDio(error);
    }
  }

  static DownloadedFile _fileOf(Response<List<int>> response) {
    final disposition = response.headers['content-disposition']?.firstOrNull;
    return DownloadedFile(
      Uint8List.fromList(response.data ?? const []),
      contentType: response.headers['content-type']?.firstOrNull,
      fileName: disposition == null
          ? null
          : _fileName.firstMatch(disposition)?.group(1),
    );
  }
}
