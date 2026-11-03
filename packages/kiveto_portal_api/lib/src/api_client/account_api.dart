// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i15;

import 'package:dio/dio.dart' as _i18;
import 'package:kiveto_portal_api/src/model/deletion_request.dart' as _i26;
import 'package:kiveto_portal_api/src/model/email_change.dart' as _i29;
import 'package:kiveto_portal_api/src/model/email_change_verification.dart'
    as _i32;
import 'package:kiveto_portal_api/src/operation/accept_link_suggestion.dart'
    as _i14;
import 'package:kiveto_portal_api/src/operation/get_data_export_file.dart'
    as _i7;
import 'package:kiveto_portal_api/src/operation/get_me.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/list_booking_requests.dart'
    as _i4;
import 'package:kiveto_portal_api/src/operation/list_data_exports.dart' as _i6;
import 'package:kiveto_portal_api/src/operation/list_link_suggestions.dart'
    as _i13;
import 'package:kiveto_portal_api/src/operation/request_data_export.dart'
    as _i5;
import 'package:kiveto_portal_api/src/operation/request_deletion.dart' as _i8;
import 'package:kiveto_portal_api/src/operation/request_deletion_otp.dart'
    as _i9;
import 'package:kiveto_portal_api/src/operation/request_email_change.dart'
    as _i10;
import 'package:kiveto_portal_api/src/operation/request_email_change_otp.dart'
    as _i11;
import 'package:kiveto_portal_api/src/operation/update_me.dart' as _i3;
import 'package:kiveto_portal_api/src/operation/verify_email_change.dart'
    as _i12;
import 'package:kiveto_portal_api/src/request_body/api_portal_v1_me_patch_body_request_body.dart'
    as _i20;
import 'package:kiveto_portal_api/src/response_wrapper/accept_link_suggestion_response.dart'
    as _i34;
import 'package:kiveto_portal_api/src/response_wrapper/get_data_export_file_response.dart'
    as _i24;
import 'package:kiveto_portal_api/src/response_wrapper/get_me_response.dart'
    as _i17;
import 'package:kiveto_portal_api/src/response_wrapper/list_booking_requests_response.dart'
    as _i21;
import 'package:kiveto_portal_api/src/response_wrapper/list_data_exports_response.dart'
    as _i23;
import 'package:kiveto_portal_api/src/response_wrapper/list_link_suggestions_response.dart'
    as _i33;
import 'package:kiveto_portal_api/src/response_wrapper/request_data_export_response.dart'
    as _i22;
import 'package:kiveto_portal_api/src/response_wrapper/request_deletion_otp_response.dart'
    as _i27;
import 'package:kiveto_portal_api/src/response_wrapper/request_deletion_response.dart'
    as _i25;
import 'package:kiveto_portal_api/src/response_wrapper/request_email_change_otp_response.dart'
    as _i30;
import 'package:kiveto_portal_api/src/response_wrapper/request_email_change_response.dart'
    as _i28;
import 'package:kiveto_portal_api/src/response_wrapper/update_me_response.dart'
    as _i19;
import 'package:kiveto_portal_api/src/response_wrapper/verify_email_change_response.dart'
    as _i31;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i16;

/// Resource 'Compte' operations.
class AccountApi {
  AccountApi(_i1.Server server)
    : _getMe = _i2.GetMe(server.baseUrl, () => server.dio),
      _updateMe = _i3.UpdateMe(server.baseUrl, () => server.dio),
      _listBookingRequests = _i4.ListBookingRequests(
        server.baseUrl,
        () => server.dio,
      ),
      _requestDataExport = _i5.RequestDataExport(
        server.baseUrl,
        () => server.dio,
      ),
      _listDataExports = _i6.ListDataExports(server.baseUrl, () => server.dio),
      _getDataExportFile = _i7.GetDataExportFile(
        server.baseUrl,
        () => server.dio,
      ),
      _requestDeletion = _i8.RequestDeletion(server.baseUrl, () => server.dio),
      _requestDeletionOtp = _i9.RequestDeletionOtp(
        server.baseUrl,
        () => server.dio,
      ),
      _requestEmailChange = _i10.RequestEmailChange(
        server.baseUrl,
        () => server.dio,
      ),
      _requestEmailChangeOtp = _i11.RequestEmailChangeOtp(
        server.baseUrl,
        () => server.dio,
      ),
      _verifyEmailChange = _i12.VerifyEmailChange(
        server.baseUrl,
        () => server.dio,
      ),
      _listLinkSuggestions = _i13.ListLinkSuggestions(
        server.baseUrl,
        () => server.dio,
      ),
      _acceptLinkSuggestion = _i14.AcceptLinkSuggestion(
        server.baseUrl,
        () => server.dio,
      );

  final _i2.GetMe _getMe;

  final _i3.UpdateMe _updateMe;

  final _i4.ListBookingRequests _listBookingRequests;

  final _i5.RequestDataExport _requestDataExport;

  final _i6.ListDataExports _listDataExports;

  final _i7.GetDataExportFile _getDataExportFile;

  final _i8.RequestDeletion _requestDeletion;

  final _i9.RequestDeletionOtp _requestDeletionOtp;

  final _i10.RequestEmailChange _requestEmailChange;

  final _i11.RequestEmailChangeOtp _requestEmailChangeOtp;

  final _i12.VerifyEmailChange _verifyEmailChange;

  final _i13.ListLinkSuggestions _listLinkSuggestions;

  final _i14.AcceptLinkSuggestion _acceptLinkSuggestion;

  /// Le compte et ses cliniques rattachées.
  /// Ne liste pas les invitations en attente : elles apparaissent à la prochaine connexion par code.
  _i15.Future<_i16.TonikResult<_i17.GetMeResponse, _i18.Response<_i15.Object?>>>
  getMe({_i16.TonikCancellation? cancellation}) async =>
      this._getMe(cancellation: cancellation);

  /// Modifie le nom ou l'adresse du profil Portal.
  /// Chaque champ absent (ou `null`) reste inchangé. Modifie le profil Portal uniquement : les fiches client des cliniques ne changent pas. Adresse enregistrée telle que saisie, sans géocodage. Le téléphone et l'e-mail ne se modifient pas par cette route.
  _i15.Future<
    _i16.TonikResult<_i19.UpdateMeResponse, _i18.Response<_i15.Object?>>
  >
  updateMe({
    required _i20.ApiPortalV1MePatchBodyRequestBody body,
    _i16.TonikCancellation? cancellation,
  }) async => this._updateMe(body: body, cancellation: cancellation);

  /// Les demandes de rendez-vous du compte auprès de cliniques de l'annuaire.
  /// Toutes cliniques, de la plus récente à la plus ancienne. Une demande confirmée donne `appointmentId` : le rendez-vous se lit alors sous `/clinics/{c}/appointments`. Une demande refusée donne `declineReason`.
  _i15.Future<
    _i16.TonikResult<
      _i21.ListBookingRequestsResponse,
      _i18.Response<_i15.Object?>
    >
  >
  listBookingRequests({
    _i15.String? cursor,
    _i15.int? limit,
    _i16.TonikCancellation? cancellation,
  }) async => this._listBookingRequests(
    cursor: cursor,
    limit: limit,
    cancellation: cancellation,
  );

  /// Demande un export des données du compte.
  /// Construit en asynchrone (suivi par `GET /me/data-exports`), sans exigence d'e-mail. Une archive ZIP (`schemaVersion: 1`) : `account.json`, `clinics/<clinicId>.json` par clinique rattachée, `summary.pdf`. Une adresse e-mail vérifiée reçoit seulement un avis, sans lien. Un export par 24 h ; le quota est rendu si la construction échoue.
  _i15.Future<
    _i16.TonikResult<
      _i22.RequestDataExportResponse,
      _i18.Response<_i15.Object?>
    >
  >
  requestDataExport({_i16.TonikCancellation? cancellation}) async =>
      this._requestDataExport(cancellation: cancellation);

  /// Les exports de données du compte.
  /// Les plus récents d'abord. `ready` : l'archive se télécharge par `GET /me/data-exports/{id}/file` jusqu'à `expiresAt` (48 h), puis l'export est `expired`. `failed` : une nouvelle demande est acceptée aussitôt.
  _i15.Future<
    _i16.TonikResult<_i23.ListDataExportsResponse, _i18.Response<_i15.Object?>>
  >
  listDataExports({_i16.TonikCancellation? cancellation}) async =>
      this._listDataExports(cancellation: cancellation);

  /// Télécharger un export de données.
  /// Export de l'appelant à l'état `ready`, dans ses 48 h : redirige vers une URL signée valable 5 minutes. Un export expiré, supprimé, en cours, en échec ou d'un autre compte répond 404.
  _i15.Future<
    _i16.TonikResult<
      _i24.GetDataExportFileResponse,
      _i18.Response<_i15.Object?>
    >
  >
  getDataExportFile({
    required _i15.String exportId,
    _i16.TonikCancellation? cancellation,
  }) async =>
      this._getDataExportFile(exportId: exportId, cancellation: cancellation);

  /// Supprime le compte, confirmé par le code SMS.
  /// Le code de `POST /me/deletion-request/otp` est vérifié. Dès la 202, le compte est désactivé : tout access token et tout refresh répondent 401. En asynchrone : liens, invitations en attente, jetons et challenges du numéro révoqués ; exports supprimés ; profil et compte anonymisés (« Compte supprimé », téléphone et e-mail effacés). Les fiches `Client` des cliniques et leurs consentements ne sont pas modifiés. Une nouvelle invitation vers ce numéro crée un nouveau compte.
  _i15.Future<
    _i16.TonikResult<_i25.RequestDeletionResponse, _i18.Response<_i15.Object?>>
  >
  requestDeletion({
    required _i26.DeletionRequest body,
    _i16.TonikCancellation? cancellation,
  }) async => this._requestDeletion(body: body, cancellation: cancellation);

  /// Envoie par SMS le code qui confirme la suppression du compte.
  /// Code de finalité `account_deletion`, lié au compte, envoyé au mobile du compte (« Code de confirmation de suppression de votre compte Kiveto »). Mêmes quotas que les codes de connexion (par numéro, par jour, par IP). Renvoi : `POST /auth/otp/{challengeId}/resend` avec `sms` (jamais par e-mail).
  _i15.Future<
    _i16.TonikResult<
      _i27.RequestDeletionOtpResponse,
      _i18.Response<_i15.Object?>
    >
  >
  requestDeletionOtp({_i16.TonikCancellation? cancellation}) async =>
      this._requestDeletionOtp(cancellation: cancellation);

  /// Vérifie le code SMS et envoie un code à la nouvelle adresse.
  /// Le code SMS (`POST /me/email-change/otp`) est vérifié ; un code est envoyé à `email` (challenge `email_verification`, 10 min, 5 essais), à saisir sur `POST /me/email-change/verify`. Sert aussi à revérifier l'adresse actuelle non vérifiée. Aucune collision n'est signalée ici.
  _i15.Future<
    _i16.TonikResult<
      _i28.RequestEmailChangeResponse,
      _i18.Response<_i15.Object?>
    >
  >
  requestEmailChange({
    required _i29.EmailChange body,
    _i16.TonikCancellation? cancellation,
  }) async => this._requestEmailChange(body: body, cancellation: cancellation);

  /// Envoie par SMS le code qui confirme un changement d'e-mail.
  /// Code de finalité `email_change`, lié au compte, envoyé au mobile du compte (« Code de confirmation de changement d'e-mail »). Mêmes quotas que les codes de connexion (par numéro, par jour, par IP). Renvoi : `POST /auth/otp/{challengeId}/resend` avec `sms` (jamais par e-mail).
  _i15.Future<
    _i16.TonikResult<
      _i30.RequestEmailChangeOtpResponse,
      _i18.Response<_i15.Object?>
    >
  >
  requestEmailChangeOtp({_i16.TonikCancellation? cancellation}) async =>
      this._requestEmailChangeOtp(cancellation: cancellation);

  /// Vérifie le code reçu à la nouvelle adresse : elle devient l'e-mail vérifié du compte.
  /// Un autre compte qui détenait l'adresse sans l'avoir vérifiée la perd ; s'il l'a vérifiée → `email_taken` (seulement ici). L'ancienne adresse vérifiée reçoit un avis de changement. Une fois vérifiée, l'adresse sert de second facteur de connexion (`resend` par e-mail).
  _i15.Future<
    _i16.TonikResult<
      _i31.VerifyEmailChangeResponse,
      _i18.Response<_i15.Object?>
    >
  >
  verifyEmailChange({
    required _i32.EmailChangeVerification body,
    _i16.TonikCancellation? cancellation,
  }) async => this._verifyEmailChange(body: body, cancellation: cancellation);

  /// Les cliniques qui ont un dossier client avec le numéro du compte.
  /// Une suggestion par clinique (les dossiers d'une même famille sont regroupés), par nom de clinique. Seuls le nom et la ville de la clinique sont exposés, jamais un dossier client ; `id` est opaque. Le numéro doit être le mobile (`mobile`) d'un dossier non archivé d'une clinique active. Une clinique disparaît dès que le compte a un lien (quel que soit son statut) avec chacun de ses dossiers correspondants : une suggestion refusée par la clinique ne revient pas.
  _i15.Future<
    _i16.TonikResult<
      _i33.ListLinkSuggestionsResponse,
      _i18.Response<_i15.Object?>
    >
  >
  listLinkSuggestions({_i16.TonikCancellation? cancellation}) async =>
      this._listLinkSuggestions(cancellation: cancellation);

  /// Demande le rattachement à la clinique suggérée.
  /// Ouvre un lien `pending` vers chaque dossier correspondant de la clinique ; la clinique le confirme ou le refuse dans VetApp. En attendant, `GET /me` liste la clinique avec `linkStatus: pending` et `linkedAt: null`, et les routes `/clinics/{clinicId}/…` répondent 404. Rejouer l'acceptation d'une demande en attente rend la même réponse.
  _i15.Future<
    _i16.TonikResult<
      _i34.AcceptLinkSuggestionResponse,
      _i18.Response<_i15.Object?>
    >
  >
  acceptLinkSuggestion({
    required _i15.String suggestionId,
    _i16.TonikCancellation? cancellation,
  }) async => this._acceptLinkSuggestion(
    suggestionId: suggestionId,
    cancellation: cancellation,
  );
}
