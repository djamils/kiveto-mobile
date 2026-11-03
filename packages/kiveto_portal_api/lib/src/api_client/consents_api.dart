// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i5;

import 'package:dio/dio.dart' as _i8;
import 'package:kiveto_portal_api/src/model/consent_update.dart' as _i11;
import 'package:kiveto_portal_api/src/operation/get_consent_history.dart'
    as _i3;
import 'package:kiveto_portal_api/src/operation/get_consents.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/update_consent.dart' as _i4;
import 'package:kiveto_portal_api/src/response_wrapper/get_consent_history_response.dart'
    as _i9;
import 'package:kiveto_portal_api/src/response_wrapper/get_consents_response.dart'
    as _i7;
import 'package:kiveto_portal_api/src/response_wrapper/update_consent_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i6;

/// Resource 'Consentements' operations.
class ConsentsApi {
  ConsentsApi(_i1.Server server)
    : _getConsents = _i2.GetConsents(server.baseUrl, () => server.dio),
      _getConsentHistory = _i3.GetConsentHistory(
        server.baseUrl,
        () => server.dio,
      ),
      _updateConsent = _i4.UpdateConsent(server.baseUrl, () => server.dio);

  final _i2.GetConsents _getConsents;

  final _i3.GetConsentHistory _getConsentHistory;

  final _i4.UpdateConsent _updateConsent;

  /// Les consentements de l'appelant dans la clinique.
  /// Les cinq `kind` sont toujours renvoyés ; `channels: []` = non consenti. Relié à plusieurs fiches de la clinique : union des canaux par `kind` sur les fiches confirmées non archivées ; `grantedAt` = la date la plus récente parmi ces fiches. `effect` : `send_control` (sans consentement, le message n'est pas envoyé) ou `channel_preference` (le message part de toute façon, le consentement choisit le canal).
  _i5.Future<
    _i6.TonikResult<_i7.GetConsentsResponse, _i8.Response<_i5.Object?>>
  >
  getConsents({
    required _i5.String clinicId,
    _i6.TonikCancellation? cancellation,
  }) async => this._getConsents(clinicId: clinicId, cancellation: cancellation);

  /// L'historique des consentements de l'appelant dans la clinique.
  /// Ajout seul, du plus récent au plus ancien ; un changement appliqué à plusieurs fiches donne une seule ligne. `source: clinic` = saisie à la clinique, auteur « La clinique » ; `source: system` + `approximate: true` = reprise des consentements existants (date au plus tard).
  _i5.Future<
    _i6.TonikResult<_i9.GetConsentHistoryResponse, _i8.Response<_i5.Object?>>
  >
  getConsentHistory({
    required _i5.String clinicId,
    _i5.String? cursor,
    _i5.int? limit,
    _i6.TonikCancellation? cancellation,
  }) async => this._getConsentHistory(
    clinicId: clinicId,
    cursor: cursor,
    limit: limit,
    cancellation: cancellation,
  );

  /// Choisit les canaux d'un consentement.
  /// `kind` : `appointment_reminders`, `vaccination_reminders`, `clinical_documents`, `billing` ou `marketing`. `channels` vide = retrait (types `send_control` seulement). S'applique à chaque fiche confirmée non archivée de la clinique, en une transaction ; chaque changement ajoute des lignes d'historique (source `portal`, auteur = nom du profil). Ajouter un canal = consentement daté du jour. Renvoie la même forme que `GET /clinics/{clinicId}/consents`.
  _i5.Future<
    _i6.TonikResult<_i10.UpdateConsentResponse, _i8.Response<_i5.Object?>>
  >
  updateConsent({
    required _i11.ConsentUpdate body,
    required _i5.String clinicId,
    required _i5.String kind,
    _i6.TonikCancellation? cancellation,
  }) async => this._updateConsent(
    body: body,
    clinicId: clinicId,
    kind: kind,
    cancellation: cancellation,
  );
}
