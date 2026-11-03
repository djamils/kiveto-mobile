import 'package:kiveto_mobile/features/identity_access/domain/invitation_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';

/// Accepts one pending invitation with the onboarding grant of a verified
/// number and the version of the terms accepted, then opens the session
/// it gives (the first acceptance creates the account).
final class AcceptPendingInvitation {
  const new(this._invitations, this._session);

  final InvitationRepository _invitations;
  final SessionStore _session;

  /// Throws the `ApiFailure` of a refused acceptance; the session is then
  /// unchanged.
  Future<void> call({
    required String invitationId,
    required OnboardingGrant onboarding,
    required String termsVersion,
  }) async {
    final tokens = await _invitations.acceptPending(
      invitationId: invitationId,
      onboarding: onboarding,
      termsVersion: termsVersion,
    );
    await _session.open(tokens);
  }
}
