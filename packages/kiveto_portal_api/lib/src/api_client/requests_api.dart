// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i7;

import 'package:dio/dio.dart' as _i10;
import 'package:kiveto_portal_api/src/model/pet_change_request_creation.dart'
    as _i14;
import 'package:kiveto_portal_api/src/model/questionnaire_update.dart' as _i12;
import 'package:kiveto_portal_api/src/model/renewal_request_creation.dart'
    as _i16;
import 'package:kiveto_portal_api/src/operation/get_questionnaire.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/list_requests.dart' as _i6;
import 'package:kiveto_portal_api/src/operation/request_pet_change.dart' as _i4;
import 'package:kiveto_portal_api/src/operation/request_renewal.dart' as _i5;
import 'package:kiveto_portal_api/src/operation/save_questionnaire.dart' as _i3;
import 'package:kiveto_portal_api/src/response_wrapper/get_questionnaire_response.dart'
    as _i9;
import 'package:kiveto_portal_api/src/response_wrapper/list_requests_response.dart'
    as _i17;
import 'package:kiveto_portal_api/src/response_wrapper/request_pet_change_response.dart'
    as _i13;
import 'package:kiveto_portal_api/src/response_wrapper/request_renewal_response.dart'
    as _i15;
import 'package:kiveto_portal_api/src/response_wrapper/save_questionnaire_response.dart'
    as _i11;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i8;

/// Resource 'Demandes' operations.
class RequestsApi {
  RequestsApi(_i1.Server server)
    : _getQuestionnaire = _i2.GetQuestionnaire(
        server.baseUrl,
        () => server.dio,
      ),
      _saveQuestionnaire = _i3.SaveQuestionnaire(
        server.baseUrl,
        () => server.dio,
      ),
      _requestPetChange = _i4.RequestPetChange(
        server.baseUrl,
        () => server.dio,
      ),
      _requestRenewal = _i5.RequestRenewal(server.baseUrl, () => server.dio),
      _listRequests = _i6.ListRequests(server.baseUrl, () => server.dio);

  final _i2.GetQuestionnaire _getQuestionnaire;

  final _i3.SaveQuestionnaire _saveQuestionnaire;

  final _i4.RequestPetChange _requestPetChange;

  final _i5.RequestRenewal _requestRenewal;

  final _i6.ListRequests _listRequests;

  /// Le questionnaire pré-visite d'un rendez-vous.
  /// Version 1. `status` : `not_started` (sans `answers` ni `updatedAt`) ou `submitted`. `editable` = modifiable par `PUT` : le rendez-vous occupe son créneau, n'a pas commencé et aucune consultation n'a démarré.
  _i7.Future<
    _i8.TonikResult<_i9.GetQuestionnaireResponse, _i10.Response<_i7.Object?>>
  >
  getQuestionnaire({
    required _i7.String clinicId,
    required _i7.String appointmentId,
    _i8.TonikCancellation? cancellation,
  }) async => this._getQuestionnaire(
    clinicId: clinicId,
    appointmentId: appointmentId,
    cancellation: cancellation,
  );

  /// Remplit ou modifie le questionnaire pré-visite d'un rendez-vous.
  /// Naturellement idempotente : les réponses remplacent les précédentes. `symptoms` : `none` ne se combine avec aucun autre. Modifiable tant que le rendez-vous occupe son créneau, n'a pas commencé et qu'aucune consultation n'a démarré ; ensuite `questionnaire_locked` (un report ne le rouvre pas). Renvoie la même forme que `GET`.
  _i7.Future<
    _i8.TonikResult<_i11.SaveQuestionnaireResponse, _i10.Response<_i7.Object?>>
  >
  saveQuestionnaire({
    required _i12.QuestionnaireUpdate body,
    required _i7.String clinicId,
    required _i7.String appointmentId,
    _i8.TonikCancellation? cancellation,
  }) async => this._saveQuestionnaire(
    body: body,
    clinicId: clinicId,
    appointmentId: appointmentId,
    cancellation: cancellation,
  );

  /// Demande à la clinique de modifier une information de l'animal.
  /// La clinique applique la modification à la main ; l'animal ne change pas avant. Règles par champ : `name` 1 à 60 caractères ; `weight` décimal (virgule ou point) de 0,05 à 150 kg, `measuredOn` facultatif (pas dans le futur, par défaut le jour de la demande) ; `sterilization` `neutered` ou `intact` ; `chip_number` 15 chiffres ; `other` exige `note`. 10 demandes (modification ou renouvellement) par 24 h et par clinique, et 3 demandes ouvertes au plus par animal et par champ. Pas d'annulation ni de modification d'une demande envoyée. Rejouer la requête avec la même clé Idempotency-Key rend la même réponse sans seconde demande.
  _i7.Future<
    _i8.TonikResult<_i13.RequestPetChangeResponse, _i10.Response<_i7.Object?>>
  >
  requestPetChange({
    required _i14.PetChangeRequestCreation body,
    required _i7.String clinicId,
    required _i7.String petId,
    required _i7.String idempotencyKey,
    _i8.TonikCancellation? cancellation,
  }) async => this._requestPetChange(
    body: body,
    clinicId: clinicId,
    petId: petId,
    idempotencyKey: idempotencyKey,
    cancellation: cancellation,
  );

  /// Demande le renouvellement d'une ordonnance.
  /// Porte sur toute l'ordonnance ; la clinique rédige au besoin une nouvelle ordonnance, liée à la demande (`renewalStatus` de la liste des documents). Une seconde demande alors qu'une est ouverte rend 202 avec la même `{ requestId, status }`. 10 demandes (modification ou renouvellement) par 24 h et par clinique. Pas d'annulation d'une demande envoyée. Rejouer la requête avec la même clé Idempotency-Key rend la même réponse.
  _i7.Future<
    _i8.TonikResult<_i15.RequestRenewalResponse, _i10.Response<_i7.Object?>>
  >
  requestRenewal({
    required _i16.RenewalRequestCreation body,
    required _i7.String clinicId,
    required _i7.String prescriptionId,
    required _i7.String idempotencyKey,
    _i8.TonikCancellation? cancellation,
  }) async => this._requestRenewal(
    body: body,
    clinicId: clinicId,
    prescriptionId: prescriptionId,
    idempotencyKey: idempotencyKey,
    cancellation: cancellation,
  );

  /// Les demandes de modification et de renouvellement du propriétaire dans cette clinique.
  /// De la plus récente à la plus ancienne. `closed` = close sans traitement (lien révoqué, client archivé, ordonnance annulée, animal archivé ou décédé). Pas d'annulation ni de modification d'une demande envoyée en v1.
  _i7.Future<
    _i8.TonikResult<_i17.ListRequestsResponse, _i10.Response<_i7.Object?>>
  >
  listRequests({
    required _i7.String clinicId,
    _i7.String? cursor,
    _i7.int? limit,
    _i8.TonikCancellation? cancellation,
  }) async => this._listRequests(
    clinicId: clinicId,
    cursor: cursor,
    limit: limit,
    cancellation: cancellation,
  );
}
