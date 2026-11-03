import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_preview.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [InvitationRepository] on the generated `InvitationsApi`. The link token
/// travels in request bodies only, never in a path, a query or a log.
final class PortalInvitationRepository implements InvitationRepository {
  new(api.Server server, this._failures) : _api = api.InvitationsApi(server);

  final api.InvitationsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<InvitationPreview> lookup(String token) async => switch (await _api
      .lookupInvitation(body: api.InvitationLookup(token: token))) {
    TonikSuccess(value: api.LookupInvitationResponse200(:final body)) =>
      InvitationPreview(
        invitationId: body.invitationId,
        clinicId: ClinicId(body.clinic.id),
        clinicName: body.clinic.name,
        clinicCity: body.clinic.city,
        email: body.email,
        maskedPhone: body.maskedPhone,
        petNames: body.petNames,
        expiresAt: body.expiresAt.toUtc(),
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<OtpChallenge> requestCode(String token) async => switch (await _api
      .requestInvitationOtp(body: api.InvitationOtpRequest(token: token))) {
    TonikSuccess(value: api.RequestInvitationOtpResponse202(:final body)) =>
      OtpChallenge(
        id: body.challengeId,
        expiresAt: body.expiresAt.toUtc(),
        resendAvailableAt: body.resendAvailableAt.toUtc(),
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<SessionTokens> acceptByLink({
    required String token,
    required String challengeId,
    required String code,
    required String termsVersion,
  }) async => switch (await _api.acceptInvitation(
    body: api.InvitationAcceptance(
      token: token,
      challengeId: challengeId,
      code: code,
      termsVersion: termsVersion,
    ),
  )) {
    TonikSuccess(value: api.AcceptInvitationResponse200(:final body)) =>
      SessionTokens(
        accessToken: body.accessToken,
        refreshToken: body.refreshToken,
        accessTokenExpiresAt: body.accessTokenExpiresAt.toUtc(),
        refreshTokenExpiresAt: body.refreshTokenExpiresAt.toUtc(),
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<SessionTokens> acceptPending({
    required String invitationId,
    required OnboardingGrant onboarding,
    required String termsVersion,
  }) async => switch (await _api.acceptInvitationById(
    invitationId: invitationId,
    body: api.InvitationGrantAcceptance(
      onboardingToken: onboarding.token,
      termsVersion: termsVersion,
    ),
  )) {
    TonikSuccess(value: api.AcceptInvitationByIdResponse200(:final body)) =>
      SessionTokens(
        accessToken: body.accessToken,
        refreshToken: body.refreshToken,
        accessTokenExpiresAt: body.accessTokenExpiresAt.toUtc(),
        refreshTokenExpiresAt: body.refreshTokenExpiresAt.toUtc(),
      ),
    final other => throw apiFailureOf(other, _failures),
  };
}
