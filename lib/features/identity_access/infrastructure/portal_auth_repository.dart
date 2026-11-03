import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/identity_access/domain/auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_channel.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [AuthRepository] on the generated `AuthApi`, through the app's
/// authenticated chain (`portalServerProvider`).
///
/// The logout goes through that chain too. With an expired access token,
/// the auth interceptor refreshes (the refresh token rotates) and replays
/// the same body, whose refresh token is then spent: the backend still
/// revokes the whole family, since it finds a refresh token by its hash
/// whatever its rotation state (`RevokePortalSessionHandler`, checked live
/// on 2026-11-03). Pinned by the logout test on `PortalHarness`.
final class PortalAuthRepository implements AuthRepository {
  new(api.Server server, this._failures) : _api = api.AuthApi(server);

  final api.AuthApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<OtpChallenge> requestCode(PhoneNumber phone) async =>
      switch (await _api.requestOtp(body: api.OtpRequest(phone: phone.e164))) {
        TonikSuccess(value: api.RequestOtpResponse202(:final body)) =>
          OtpChallenge(
            id: body.challengeId,
            expiresAt: body.expiresAt.toUtc(),
            resendAvailableAt: body.resendAvailableAt.toUtc(),
          ),
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<OtpVerification> verifyCode({
    required String challengeId,
    required String code,
  }) async => switch (await _api.verifyOtp(
    body: api.OtpVerification(challengeId: challengeId, code: code),
  )) {
    TonikSuccess(value: api.VerifyOtpResponse200(:final body)) => _verification(
      body,
    ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<OtpChallenge> resendCode({
    required String challengeId,
    required OtpChannel channel,
  }) async => switch (await _api.resendOtp(
    challengeId: challengeId,
    body: api.OtpResend(
      channel: switch (channel) {
        OtpChannel.sms => api.OtpResendChannelModel.sms,
        OtpChannel.email => api.OtpResendChannelModel.email,
      },
    ),
  )) {
    TonikSuccess(value: api.ResendOtpResponse202(:final body)) => OtpChallenge(
      id: body.challengeId,
      expiresAt: body.expiresAt.toUtc(),
      resendAvailableAt: body.resendAvailableAt.toUtc(),
    ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<SessionTokens> register(RegistrationRequest request) async =>
      switch (await _api.register(
        body: api.Registration(
          registrationToken: request.grant.token,
          firstName: request.firstName,
          lastName: request.lastName,
          email: request.email,
          termsVersion: request.termsVersion,
        ),
      )) {
        TonikSuccess(value: api.RegisterResponse201(:final body)) =>
          SessionTokens(
            accessToken: body.accessToken,
            refreshToken: body.refreshToken,
            accessTokenExpiresAt: body.accessTokenExpiresAt.toUtc(),
            refreshTokenExpiresAt: body.refreshTokenExpiresAt.toUtc(),
          ),
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<void> logout(String refreshToken) async {
    switch (await _api.logout(
      body: api.SessionLogout(refreshToken: refreshToken),
    )) {
      case TonikSuccess(value: api.LogoutResponse204()):
        return;
      case final other:
        throw apiFailureOf(other, _failures);
    }
  }

  /// The branch of a verified code; a status this app does not know, or a
  /// branch without its tokens, is an answer it cannot use.
  static OtpVerification _verification(api.OtpVerificationResult body) {
    final onboarding = switch ((
      body.onboardingToken,
      body.onboardingTokenExpiresAt,
    )) {
      (final String token, final DateTime expiresAt) => OnboardingGrant(
        token: token,
        expiresAt: expiresAt.toUtc(),
      ),
      _ => null,
    };
    switch (body.status) {
      case api.OtpVerificationOtpVerificationViewStatusModel.authenticated:
        final (access, refresh) = (body.accessToken, body.refreshToken);
        if (access == null || refresh == null) throw const ServerFailure();
        return AuthenticatedVerification(
          tokens: SessionTokens(
            accessToken: access,
            refreshToken: refresh,
            accessTokenExpiresAt: body.accessTokenExpiresAt?.toUtc(),
            refreshTokenExpiresAt: body.refreshTokenExpiresAt?.toUtc(),
          ),
          pendingInvitations: [
            for (final invitation in body.pendingInvitations)
              PendingInvitation(
                id: invitation.invitationId,
                clinicName: invitation.clinic.name,
                clinicCity: invitation.clinic.city,
              ),
          ],
          onboarding: onboarding,
        );
      case api.OtpVerificationOtpVerificationViewStatusModel.invitationPending:
        if (onboarding == null) throw const ServerFailure();
        return InvitationPendingVerification(
          onboarding: onboarding,
          invitations: [
            for (final invitation in body.invitations)
              PendingInvitation(
                id: invitation.invitationId,
                clinicName: invitation.clinic.name,
                clinicCity: invitation.clinic.city,
              ),
          ],
        );
      case api
          .OtpVerificationOtpVerificationViewStatusModel
          .registrationRequired:
        final (token, expiresAt) = (
          body.registrationToken,
          body.registrationTokenExpiresAt,
        );
        if (token == null || expiresAt == null) throw const ServerFailure();
        return RegistrationRequiredVerification(
          registration: RegistrationGrant(
            token: token,
            expiresAt: expiresAt.toUtc(),
          ),
        );
      case api.OtpVerificationOtpVerificationViewStatusModel.unknown:
        throw const ServerFailure();
    }
  }
}
