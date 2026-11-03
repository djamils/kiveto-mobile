import 'package:kiveto_mobile/features/identity_access/domain/invitation_preview.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';

/// The clinic invitations of the Portal API: by their link token (sent in
/// request bodies only), or pending after a sign-in by number. Every method
/// throws an `ApiFailure` (shared/domain).
abstract interface class InvitationRepository {
  /// `POST /invitations/lookup`.
  Future<InvitationPreview> lookup(String token);

  /// `POST /invitations/otp`: sends a code to the invited mobile.
  Future<OtpChallenge> requestCode(String token);

  /// `POST /invitations/accept`: accepts it with the code, signed in.
  Future<SessionTokens> acceptByLink({
    required String token,
    required String challengeId,
    required String code,
    required String termsVersion,
  });

  /// `POST /invitations/{invitationId}/accept`: accepts a pending
  /// invitation with the onboarding grant, signed in.
  Future<SessionTokens> acceptPending({
    required String invitationId,
    required OnboardingGrant onboarding,
    required String termsVersion,
  });
}
