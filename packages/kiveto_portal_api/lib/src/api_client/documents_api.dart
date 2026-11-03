// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i5;

import 'package:dio/dio.dart' as _i8;
import 'package:kiveto_portal_api/src/model/api_portal_v1_clinics_clinic_id_documents_parameters_model.dart'
    as _i9;
import 'package:kiveto_portal_api/src/operation/get_document_file.dart' as _i3;
import 'package:kiveto_portal_api/src/operation/get_prescription.dart' as _i4;
import 'package:kiveto_portal_api/src/operation/list_documents.dart' as _i2;
import 'package:kiveto_portal_api/src/response_wrapper/get_document_file_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response_wrapper/get_prescription_response.dart'
    as _i11;
import 'package:kiveto_portal_api/src/response_wrapper/list_documents_response.dart'
    as _i7;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i6;

/// Resource 'Documents' operations.
class DocumentsApi {
  DocumentsApi(_i1.Server server)
    : _listDocuments = _i2.ListDocuments(server.baseUrl, () => server.dio),
      _getDocumentFile = _i3.GetDocumentFile(server.baseUrl, () => server.dio),
      _getPrescription = _i4.GetPrescription(server.baseUrl, () => server.dio);

  final _i2.ListDocuments _listDocuments;

  final _i3.GetDocumentFile _getDocumentFile;

  final _i4.GetPrescription _getPrescription;

  /// Les documents publiés pour le propriétaire dans cette clinique.
  /// Du plus récent au plus ancien. Statut de paiement et état des ordonnances lus en direct.
  _i5.Future<
    _i6.TonikResult<_i7.ListDocumentsResponse, _i8.Response<_i5.Object?>>
  >
  listDocuments({
    required _i5.String clinicId,
    _i5.String? petId,
    _i5.String? cursor,
    _i5.int? limit,
    _i9.ApiPortalV1ClinicsClinicIdDocumentsParametersModel? kind,
    _i6.TonikCancellation? cancellation,
  }) async => this._listDocuments(
    clinicId: clinicId,
    petId: petId,
    cursor: cursor,
    limit: limit,
    kind: kind,
    cancellation: cancellation,
  );

  /// Télécharger un document.
  /// Marque le document comme lu pour l'appelant, puis redirige vers une URL signée valable 5 minutes.
  _i5.Future<
    _i6.TonikResult<_i10.GetDocumentFileResponse, _i8.Response<_i5.Object?>>
  >
  getDocumentFile({
    required _i5.String clinicId,
    required _i5.String documentId,
    _i6.TonikCancellation? cancellation,
  }) async => this._getDocumentFile(
    clinicId: clinicId,
    documentId: documentId,
    cancellation: cancellation,
  );

  /// Une ordonnance publiée et ses lignes.
  /// Une ordonnance publiée et ses lignes.
  _i5.Future<
    _i6.TonikResult<_i11.GetPrescriptionResponse, _i8.Response<_i5.Object?>>
  >
  getPrescription({
    required _i5.String clinicId,
    required _i5.String prescriptionId,
    _i6.TonikCancellation? cancellation,
  }) async => this._getPrescription(
    clinicId: clinicId,
    prescriptionId: prescriptionId,
    cancellation: cancellation,
  );
}
