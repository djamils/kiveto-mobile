// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i5;

import 'package:dio/dio.dart' as _i8;
import 'package:kiveto_portal_api/src/operation/download_booklet.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/download_data_export.dart'
    as _i4;
import 'package:kiveto_portal_api/src/operation/download_document.dart' as _i3;
import 'package:kiveto_portal_api/src/response_wrapper/download_booklet_response.dart'
    as _i7;
import 'package:kiveto_portal_api/src/response_wrapper/download_data_export_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response_wrapper/download_document_response.dart'
    as _i9;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i6;

class FilesApi {
  FilesApi(_i1.Server server)
    : _downloadBooklet = _i2.DownloadBooklet(server.baseUrl, () => server.dio),
      _downloadDocument = _i3.DownloadDocument(
        server.baseUrl,
        () => server.dio,
      ),
      _downloadDataExport = _i4.DownloadDataExport(
        server.baseUrl,
        () => server.dio,
      );

  final _i2.DownloadBooklet _downloadBooklet;

  final _i3.DownloadDocument _downloadDocument;

  final _i4.DownloadDataExport _downloadDataExport;

  /// Le PDF d'un carnet de vaccination (URL signée).
  /// Publique : la signature tient lieu d'authentification, 5 minutes.
  _i5.Future<
    _i6.TonikResult<_i7.DownloadBookletResponse, _i8.Response<_i5.Object?>>
  >
  downloadBooklet({
    required _i5.String clinicId,
    required _i5.String animalId,
    required _i5.String hash,
    _i6.TonikCancellation? cancellation,
  }) async => this._downloadBooklet(
    clinicId: clinicId,
    animalId: animalId,
    hash: hash,
    cancellation: cancellation,
  );

  /// Le PDF d'un document (URL signée).
  /// Publique : la signature tient lieu d'authentification, 5 minutes. Sert la version signée même si une plus récente a été publiée depuis.
  _i5.Future<
    _i6.TonikResult<_i9.DownloadDocumentResponse, _i8.Response<_i5.Object?>>
  >
  downloadDocument({
    required _i5.String clinicId,
    required _i5.String documentId,
    required _i5.String version,
    _i6.TonikCancellation? cancellation,
  }) async => this._downloadDocument(
    clinicId: clinicId,
    documentId: documentId,
    version: version,
    cancellation: cancellation,
  );

  /// L'archive ZIP d'un export de données (URL signée).
  /// Publique : la signature tient lieu d'authentification, 5 minutes. Servie en pièce jointe tant que l'export n'a pas expiré (48 h).
  _i5.Future<
    _i6.TonikResult<_i10.DownloadDataExportResponse, _i8.Response<_i5.Object?>>
  >
  downloadDataExport({
    required _i5.String exportId,
    _i6.TonikCancellation? cancellation,
  }) async =>
      this._downloadDataExport(exportId: exportId, cancellation: cancellation);
}
