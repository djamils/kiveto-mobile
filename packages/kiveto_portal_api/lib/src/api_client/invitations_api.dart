// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i6;

import 'package:dio/dio.dart' as _i9;
import 'package:kiveto_portal_api/src/model/invitation_acceptance.dart' as _i10;
import 'package:kiveto_portal_api/src/model/invitation_grant_acceptance.dart'
    as _i16;
import 'package:kiveto_portal_api/src/model/invitation_lookup.dart' as _i12;
import 'package:kiveto_portal_api/src/model/invitation_otp_request.dart'
    as _i14;
import 'package:kiveto_portal_api/src/operation/accept_invitation.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/accept_invitation_by_id.dart'
    as _i5;
import 'package:kiveto_portal_api/src/operation/lookup_invitation.dart' as _i3;
import 'package:kiveto_portal_api/src/operation/request_invitation_otp.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response_wrapper/accept_invitation_by_id_response.dart'
    as _i15;
import 'package:kiveto_portal_api/src/response_wrapper/accept_invitation_response.dart'
    as _i8;
import 'package:kiveto_portal_api/src/response_wrapper/lookup_invitation_response.dart'
    as _i11;
import 'package:kiveto_portal_api/src/response_wrapper/request_invitation_otp_response.dart'
    as _i13;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i7;

/// Resource 'Invitation' operations.
class InvitationsApi {
  InvitationsApi(_i1.Server server)
    : _acceptInvitation = _i2.AcceptInvitation(
        server.baseUrl,
        () => server.dio,
      ),
      _lookupInvitation = _i3.LookupInvitation(
        server.baseUrl,
        () => server.dio,
      ),
      _requestInvitationOtp = _i4.RequestInvitationOtp(
        server.baseUrl,
        () => server.dio,
      ),
      _acceptInvitationById = _i5.AcceptInvitationById(
        server.baseUrl,
        () => server.dio,
      );

  final _i2.AcceptInvitation _acceptInvitation;

  final _i3.LookupInvitation _lookupInvitation;

  final _i4.RequestInvitationOtp _requestInvitationOtp;

  final _i5.AcceptInvitationById _acceptInvitationById;

  /// Accepte une invitation par le lien : jeton + code reçu par SMS.
  /// Rejouable : la même requête (même code, avant son expiration) après une réponse perdue renvoie une paire neuve.
  _i6.Future<
    _i7.TonikResult<_i8.AcceptInvitationResponse, _i9.Response<_i6.Object?>>
  >
  acceptInvitation({
    required _i10.InvitationAcceptance body,
    _i7.TonikCancellation? cancellation,
  }) async => this._acceptInvitation(body: body, cancellation: cancellation);

  /// Affiche une invitation à partir du jeton de son lien (`#t=`).
  /// Le jeton voyage dans le corps, jamais dans l'URL.
  _i6.Future<
    _i7.TonikResult<_i11.LookupInvitationResponse, _i9.Response<_i6.Object?>>
  >
  lookupInvitation({
    required _i12.InvitationLookup body,
    _i7.TonikCancellation? cancellation,
  }) async => this._lookupInvitation(body: body, cancellation: cancellation);

  /// Envoie un code au mobile de l'invitation.
  /// Quotas : 3/h par invitation, 3/h et 10/24 h par numéro, 30/h par IP.
  _i6.Future<
    _i7.TonikResult<
      _i13.RequestInvitationOtpResponse,
      _i9.Response<_i6.Object?>
    >
  >
  requestInvitationOtp({
    required _i14.InvitationOtpRequest body,
    _i7.TonikCancellation? cancellation,
  }) async =>
      this._requestInvitationOtp(body: body, cancellation: cancellation);

  /// Accepte une invitation après connexion par numéro, avec le jeton d'onboarding.
  /// Le jeton d'onboarding vient de `/auth/otp/verify` et n'est accepté que par cette route. Après l'acceptation de la dernière invitation du numéro, il est révoqué : en cas de `401 onboarding_invalid` après une réponse perdue, refaire la connexion par numéro.
  _i6.Future<
    _i7.TonikResult<
      _i15.AcceptInvitationByIdResponse,
      _i9.Response<_i6.Object?>
    >
  >
  acceptInvitationById({
    required _i16.InvitationGrantAcceptance body,
    required _i6.String invitationId,
    _i7.TonikCancellation? cancellation,
  }) async => this._acceptInvitationById(
    body: body,
    invitationId: invitationId,
    cancellation: cancellation,
  );
}
