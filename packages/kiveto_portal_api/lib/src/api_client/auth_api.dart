// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i8;

import 'package:dio/dio.dart' as _i11;
import 'package:kiveto_portal_api/src/model/otp_request.dart' as _i14;
import 'package:kiveto_portal_api/src/model/otp_resend.dart' as _i18;
import 'package:kiveto_portal_api/src/model/otp_verification.dart' as _i16;
import 'package:kiveto_portal_api/src/model/registration.dart' as _i22;
import 'package:kiveto_portal_api/src/model/session_logout.dart' as _i12;
import 'package:kiveto_portal_api/src/model/session_refresh.dart' as _i20;
import 'package:kiveto_portal_api/src/operation/logout.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/refresh_session.dart' as _i6;
import 'package:kiveto_portal_api/src/operation/register.dart' as _i7;
import 'package:kiveto_portal_api/src/operation/request_otp.dart' as _i3;
import 'package:kiveto_portal_api/src/operation/resend_otp.dart' as _i5;
import 'package:kiveto_portal_api/src/operation/verify_otp.dart' as _i4;
import 'package:kiveto_portal_api/src/response_wrapper/logout_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response_wrapper/refresh_session_response.dart'
    as _i19;
import 'package:kiveto_portal_api/src/response_wrapper/register_response.dart'
    as _i21;
import 'package:kiveto_portal_api/src/response_wrapper/request_otp_response.dart'
    as _i13;
import 'package:kiveto_portal_api/src/response_wrapper/resend_otp_response.dart'
    as _i17;
import 'package:kiveto_portal_api/src/response_wrapper/verify_otp_response.dart'
    as _i15;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i9;

/// Resource 'Authentification' operations.
class AuthApi {
  AuthApi(_i1.Server server)
    : _logout = _i2.Logout(server.baseUrl, () => server.dio),
      _requestOtp = _i3.RequestOtp(server.baseUrl, () => server.dio),
      _verifyOtp = _i4.VerifyOtp(server.baseUrl, () => server.dio),
      _resendOtp = _i5.ResendOtp(server.baseUrl, () => server.dio),
      _refreshSession = _i6.RefreshSession(server.baseUrl, () => server.dio),
      _register = _i7.Register(server.baseUrl, () => server.dio);

  final _i2.Logout _logout;

  final _i3.RequestOtp _requestOtp;

  final _i4.VerifyOtp _verifyOtp;

  final _i5.ResendOtp _resendOtp;

  final _i6.RefreshSession _refreshSession;

  final _i7.Register _register;

  /// Révoque la famille du refresh token (déconnexion).
  /// Sans effet si le jeton n'appartient pas à l'appelant. L'access token reste valable jusqu'à son expiration (15 min).
  _i8.Future<_i9.TonikResult<_i10.LogoutResponse, _i11.Response<_i8.Object?>>>
  logout({
    required _i12.SessionLogout body,
    _i9.TonikCancellation? cancellation,
  }) async => this._logout(body: body, cancellation: cancellation);

  /// Envoie un code de connexion par SMS.
  /// Même réponse que le numéro ait un compte ou non. Quotas : 3/h et 10/24 h par numéro, 30/h par IP. Pour un numéro inconnu, le SMS part dans la limite d'un budget par réseau (/24 en IPv4, /64 en IPv6), par appareil (`X-Device-Id`, simple indice) et global (500/h) ; au-delà, même réponse 202 sans SMS.
  _i8.Future<
    _i9.TonikResult<_i13.RequestOtpResponse, _i11.Response<_i8.Object?>>
  >
  requestOtp({
    required _i14.OtpRequest body,
    _i8.String? deviceId,
    _i9.TonikCancellation? cancellation,
  }) async => this._requestOtp(
    body: body,
    deviceId: deviceId,
    cancellation: cancellation,
  );

  /// Vérifie un code de connexion.
  /// Vérifie un code de connexion.
  _i8.Future<
    _i9.TonikResult<_i15.VerifyOtpResponse, _i11.Response<_i8.Object?>>
  >
  verifyOtp({
    required _i16.OtpVerification body,
    _i9.TonikCancellation? cancellation,
  }) async => this._verifyOtp(body: body, cancellation: cancellation);

  /// Renvoie un nouveau code pour le même challenge.
  /// Le code précédent ne fonctionne plus. `email` n'est honoré que pour un code de **connexion** dont le numéro a un compte actif avec e-mail **vérifié** (second facteur) ; sinon même 202, rien ne change et le code SMS reste valable. Les codes d'action (changement d'e-mail, suppression) ne sont jamais renvoyés par e-mail ; un code de vérification d'e-mail n'est jamais renvoyé.
  _i8.Future<
    _i9.TonikResult<_i17.ResendOtpResponse, _i11.Response<_i8.Object?>>
  >
  resendOtp({
    required _i18.OtpResend body,
    required _i8.String challengeId,
    _i9.TonikCancellation? cancellation,
  }) async => this._resendOtp(
    body: body,
    challengeId: challengeId,
    cancellation: cancellation,
  );

  /// Échange un refresh token contre une nouvelle paire.
  /// Rotation à chaque usage. Le client doit sérialiser ses refresh : rejouer un jeton plus de 30 s après son usage, ou deux fois, révoque toute la famille.
  _i8.Future<
    _i9.TonikResult<_i19.RefreshSessionResponse, _i11.Response<_i8.Object?>>
  >
  refreshSession({
    required _i20.SessionRefresh body,
    _i9.TonikCancellation? cancellation,
  }) async => this._refreshSession(body: body, cancellation: cancellation);

  /// Crée le compte d'un numéro sans invitation, avec le jeton d'inscription.
  /// Le `registrationToken` vient de la réponse `registration_required` de `/auth/otp/verify` (15 min, usage unique) et n'est accepté que par cette route. Rejouer la requête avec le même jeton pendant ses 15 minutes rend le même compte avec une nouvelle paire de jetons (réponse perdue). `email` est ignoré sans erreur quand un autre compte l'utilise déjà ; il n'est pas vérifié. 10 inscriptions par heure et par IP.
  _i8.Future<_i9.TonikResult<_i21.RegisterResponse, _i11.Response<_i8.Object?>>>
  register({
    required _i22.Registration body,
    _i9.TonikCancellation? cancellation,
  }) async => this._register(body: body, cancellation: cancellation);
}
